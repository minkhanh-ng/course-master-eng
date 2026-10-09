# Assignment: Creep-induced crack growth in P91 using FEniCSx

**Hướng dẫn triển khai và kiểm chứng, làm nền cho hai hướng nghiên cứu**  
Phiên bản 1.0 — 09/10/2026

## 1. Mục tiêu và phạm vi đã thiết kế lại

**Tên đề tài đề xuất:** *Implementation and verification of a creep–phase-field fracture model for P91 steel using FEniCSx: foundations for multiaxial ductility and spatial fracture-resistance studies.*

Mục tiêu assignment là xây dựng một nền tính toán có thể kiểm tra và tái sử dụng: (i) giải đúng luật vật liệu; (ii) mô phỏng phát triển nứt theo thời gian dưới tải giữ; (iii) phân biệt ảnh hưởng vật lý, lựa chọn mô hình và sai số số học. Việc chuyển từ Abaqus sang FEniCSx chưa tự tạo ra tính mới khoa học.

Hai nhánh nghiên cứu tiếp theo:

- **R1 — Ductility/constraint:** mô hình ductility đa trục có chuyển được dự đoán giữa các mức crack-tip constraint mà không hiệu chỉnh lại không?
- **R2 — Sức kháng nứt theo không gian:** khi nào có thể bỏ gradient của sức kháng nứt phát sinh từ creep damage, và sai khác dự đoán là bao nhiêu?

**Phần bắt buộc:** P91 đồng nhất ở 650 °C, small strain, tải tăng rồi giữ; luật Norton, damage ductility exhaustion, AT2; bộ kiểm chứng và một bài toán tấm có vết nứt. Plasticity là yêu cầu của mô hình đầy đủ Ragab; các bước bỏ plasticity phải được gọi là mô hình giản lược.

**Phần mở rộng theo nguồn lực:** thanh khía axisymmetric; CT 3D; bình chịu áp lực. Bình vẫn là mục tiêu ứng dụng đã thảo luận nhưng không phải điều kiện bắt buộc để nền phục vụ R1/R2 hoàn thành. HAZ, creep–fatigue, nhiệt thay đổi, ứng suất dư và luật creep 2022 chưa đưa vào phần chính.

Assignment chỉ chuẩn bị nền và khảo sát thăm dò hai nhánh; không đặt mục tiêu hoàn thành hai bài báo trong cùng thời hạn. Khả năng xuất bản phụ thuộc kết quả và rà soát tính mới bổ sung.

## 2. Ba mức độ kết quả cần phân biệt

| Mức độ | Có thể khẳng định | Không tự suy ra |
|---|---|---|
| Verification — kiểm tra số | Code giải đúng phương trình và nghiệm chuẩn | Mô hình đúng vật lý cho P91 |
| Calibration/reproduction | Khớp hoặc tái lập dữ liệu đã dùng chọn tham số | Dự đoán tốt trên dữ liệu độc lập |
| Validation — kiểm chứng vật lý | Dự đoán được dữ liệu không dùng hiệu chỉnh | Chính xác cho mọi nhiệt độ, vật liệu, kết cấu |

Nếu chưa đủ dữ liệu độc lập, báo cáo là verification và nghiên cứu mô hình, không tuyên bố đã validation hoặc dự đoán tuổi thọ bình thực.

## 3. Nguồn chính và cách đọc

Nguồn nền: Ragab et al. (2024), *Phase-field finite element modelling of creep crack growth in martensitic steels*, Engineering Fracture Mechanics 310, 110491. DOI: https://doi.org/10.1016/j.engfracmech.2024.110491. Bản đã cung cấp: `CreepCrackGrowthPhaseField.pdf`.

| Phần trong bài | Việc phải ghi vào sổ mô hình |
|---|---|
| Mục 2.1, Eq. (5), (8) | AT2, hàm suy giảm độ cứng và quy ước phase-field |
| Eq. (10)–(14) | Suy giảm toughness, damage, Cocks–Ashby |
| Eq. (17), (18), (29) | History field, phương trình cơ học và phase-field |
| Mục 2.2 | Phân rã biến dạng, plasticity, Norton và công không đàn hồi |
| Mục 3 | Cách Abaqus triển khai; tách khỏi lựa chọn solver FEniCSx |
| Mục 4, Bảng 1–2 | Nguồn dữ liệu, hiệu chỉnh, tham số và điều kiện áp dụng |
| Mục 5 | CT 3D, side grooves, tiêu chí đo nứt và dữ liệu đối chiếu |
| Phụ lục A | Bài toán đồng nhất giản lược; kiểm tra đúng giả thiết khi sử dụng |

Không đồng nhất tuyên bố “thermodynamically consistent” của tác giả với một kết luận đã được ta chứng minh cho mọi sửa đổi.

## 4. Từ điển biến và hệ đơn vị

| Ký hiệu dùng trong dự án | Ý nghĩa | Đơn vị |
|---|---|---|
| u | Chuyển vị | mm |
| d | Phase-field, tương ứng phi trong bài; 0 nguyên vẹn, 1 nứt | 1 |
| D | Creep damage; khác d | 1 |
| eps_e, eps_p, eps_cr | Biến dạng đàn hồi, dẻo, creep | 1 |
| sigma | Ứng suất truyền tải đã suy giảm | MPa = N/mm² |
| sigma_prime | Ứng suất đàn hồi chưa suy giảm bởi d | MPa |
| eta_tr | Triaxiality = sigma_m/sigma_eq | 1 |
| H, W_p, W_cr | Năng lượng thúc đẩy, công dẻo/creep tích lũy theo mô hình | MPa |
| Gc0, G_eff | Sức kháng phá hủy nền và hiệu dụng | N/mm |
| ell | Chiều dài phase-field | mm |
| eta_v | Hệ số nhớt trong phương trình chưa chuẩn hóa | MPa·h |
| mu_pf | eta_v/(G_eff ell) | h/mm² |
| t, dt | Thời gian và bước thời gian | h |

Dùng mm–N–MPa–giờ xuyên suốt. Không lấy nguyên A với thời gian giây. Không dùng tên eta cho cả viscosity và triaxiality. Tensor biến dạng nhỏ là 3×3 kể cả khi chuyển vị mô hình 2D; thành phần ngoài mặt phẳng cần xử lý theo giả thiết cơ học.

## 5. Dữ liệu vật liệu và giả thiết cần đóng trước khi ghép

| Tham số P91 | Giá trị | Nguồn/trạng thái |
|---|---:|---|
| T | 650 °C | Ragab 2024, Bảng 2 |
| E | 132000 MPa | Bảng 2 |
| Sy | 262 MPa | Bảng 2; chưa đủ để xác định hardening |
| A | 1.762e-14 MPa^(-n) h^(-1) | Bảng 2; fit tốc độ creep trung bình |
| n | 5.58 | Bảng 2 |
| eps_f | 0.28 | Bảng 2 |
| Gc0 | 100 N/mm | Bảng 2; giá trị đã hiệu chỉnh |
| v | 1 | Bảng 2 |
| beta0 | 0.01 | Bảng 2 |
| ell | 0.4 mm thanh khía; 0.6 mm CT | Mục 4.2 và 5.1; không phải một ell dùng xuyên mọi mẫu |
| k0 | 1e-6 | Mục 2.1.2.1 |
| mu_pf | 1e-3 trong phân tích thanh khía | Mục 4.2; cần xác nhận quy ước thời gian/đơn vị triển khai |
| nu | Chưa chốt từ nguồn | Bảng 2 không cung cấp |
| Luật hardening | Chưa chốt | Cần tài liệu gốc hoặc giả thiết ghi rõ |

Nếu tạm dùng nu=0.3 hoặc plasticity lý tưởng, phải gắn nhãn **giả thiết dự án**, khảo sát nhạy và không gọi là tái lập chính xác bài. Không trộn bộ P91 625 °C năm 2022 với bộ 650 °C này.

Sổ dữ liệu cần các cột: tham số; giá trị gốc; đơn vị gốc; điều kiện; trang/bảng/phương trình; giá trị trong code; phép đổi đơn vị; đã đo/đã fit/giả thiết; miền áp dụng.

Sổ quyết định mô hình cần chốt: stress dùng cho Norton và Cocks–Ashby; hardening; regularisation ở sigma_eq≈0 và eta_tr thấp; quy tắc D đạt 1; history/bounds cho d; cách tạo vết nứt đầu; dạng PF; quy ước viscosity. Nếu bản công bố không đủ rõ, ghi giả thiết, liên hệ nguồn/subroutine khi có thể và kiểm tra nhạy.

## 6. Lý thuyết nền phải triển khai

### 6.1. Cơ học

$$
\varepsilon=\operatorname{sym}\nabla u,
\qquad \varepsilon^e=\varepsilon-\varepsilon^p-\varepsilon^{cr},
$$
$$
\sigma'=\mathbb C_0:\varepsilon^e,
\quad \sigma=g(d)\sigma',
\quad g(d)=(1-d)^2+k_0.
$$

Dạng yếu cơ học:

$$
R_u(v)=\int_\Omega\sigma:\varepsilon(v)\,dx
-\int_\Omega b\cdot v\,dx-\int_{\Gamma_t}\bar t\cdot v\,ds=0.
$$

Để loại rigid motion, chỉ ràng buộc các bậc tự do cần thiết. Không kẹp toàn mặt đầu thanh nếu mục tiêu là nghiệm kéo một trục đồng nhất với co Poisson tự do.

### 6.2. Norton và damage

Với tensor ứng suất được chọn cho luật vật liệu:

$$
s=\sigma_{\rm law}-\tfrac13\operatorname{tr}(\sigma_{\rm law})I,
\quad \sigma_{eq}=\sqrt{\tfrac32s:s},
\quad \dot\varepsilon^{cr}=\tfrac32A\sigma_{eq}^{n-1}s.
$$
$$
\dot{\bar\varepsilon}^{cr}=\sqrt{\tfrac23\dot\varepsilon^{cr}:\dot\varepsilon^{cr}},
\quad \dot D=\dot{\bar\varepsilon}^{cr}/\varepsilon_f^*.
$$

Đặt $\alpha_n=(n−0.5)/(n+0.5), \eta_tr=\sigma_m/\sigma_eq$. Hai mô hình có thể thay thế:

$$
F_{CA}=\frac{\sinh(2\alpha_n/3)}{\sinh(2\alpha_n\eta_{tr})},
\qquad F_{WT}=\exp[2\alpha_n(1/3-\eta_{tr})],
\quad \varepsilon_f^*=\varepsilon_fF.
$$

Cả hai cho F=1 ở kéo một trục. Miền eta_tr→0 của Cocks–Ashby cần xử lý bằng inverse ductility; không thay bằng cutoff tùy ý mà không ghi lại. Các trạng thái nén ngoài miền khảo sát phải được phát hiện, không âm thầm tạo damage âm. sigma_eq=0 đã cho không có J2 creep trong mô hình này; đây không phải mô tả đầy đủ cavity growth dưới hydrostatic tension.

D đạt 1: chọn và ghi rõ quy tắc bão hòa D ở 1, hoặc dừng bài toán giới hạn. Nếu cần mô phỏng tiếp, cập nhật D có ràng buộc và báo thời điểm bão hòa; không để phép lũy thừa (1−D)^v dùng D>1. D=1 không tự thay thế tiêu chí vết nứt hay structural failure.

### 6.3. Crack-driving history và toughness

$$
W_p=\int\sigma':\dot\varepsilon^p\,dt,
\quad W_{cr}=\int\sigma':\dot\varepsilon^{cr}\,dt,
\quad \Psi_e=\tfrac12\varepsilon^e:\mathbb C_0:\varepsilon^e,
$$
$$
H=\max_{\tau\le t}(\Psi_e+W_p+W_{cr}),
\quad \beta(D)=(1-\beta_0)(1-D)^v+\beta_0,
\quad \mathcal G=G_{c0}\beta(D).
$$

Công không đàn hồi được dùng làm driving contribution theo Ragab; không gọi toàn bộ nó là thế đàn hồi có thể thu hồi. UFL tự động vi phân không thay thế local return mapping hoặc cập nhật lịch sử tích phân thời gian.

## 7. Hai dạng phase-field bắt buộc tách trong code

Năng lượng mặt nứt AT2:

$$
\Psi_f=\int_\Omega\mathcal G\left(\frac{d^2}{2\ell}+\frac\ell2|\nabla d|^2\right)dx.
$$

**V — dạng biến phân với D giữ cố định trong subproblem:**

$$
R_V(q)=\int_\Omega\left[
\mathcal G\ell\nabla d\cdot\nabla q+
\frac{\mathcal G}{\ell}dq-2(1-d)Hq+
\eta_v\frac{d-d_n}{\Delta t}q\right]dx.
$$

**L — dạng Laplacian chuẩn hóa theo phương trình công bố:**

$$
R_L(q)=\int_\Omega\left[
\nabla d\cdot\nabla q+
\left(\frac d{\ell^2}-\frac{2(1-d)H}{\mathcal G\ell}
+\frac{\eta_v}{\mathcal G\ell}\frac{d-d_n}{\Delta t}\right)q\right]dx.
$$

Không lấy R_V rồi chia từng tích phân cho G_eff để suy ra R_L khi G_eff biến thiên. Ở dạng strong, V có thêm −grad(log G_eff)·grad(d) sau chuẩn hóa. delta D=0 không có nghĩa grad D=0. Khi G_eff đồng nhất trong không gian, hai dạng tương đương ở mức liên tục nếu viscosity và boundary conditions tương ứng.

Dùng một assembler riêng cho mỗi dạng. Dạng V là lựa chọn chính của dự án khi biến phân Psi_f; dạng L là đối chứng và đường tái lập phương trình công bố. Không đổi V thành L giữa chừng mà giữ nhãn “cùng mô hình”.

Khi ràng buộc d_n≤d≤1 hoạt động, bài toán là variational inequality, không phải R(q)=0 cho mọi hướng thử. History field và lower bound không mặc nhiên là cùng thuật toán. Chế độ chính dùng H theo Ragab, kiểm tra healing; có chế độ explicit bounds ghi riêng khi cần bảo đảm d không giảm. Không tự nhận hội tụ minimum năng lượng của toàn hệ history-dependent.

Natural boundary: (G_eff ell grad d)·n=0 trong V. Với G_eff>0 và ell hằng, tương ứng grad d·n=0. Vết nứt có sẵn được khởi tạo profile d0 phân giải được hoặc notch hình học; chọn một cách xuyên các đối chứng và ghi rõ phần nào đã được coi là nứt trước.

## 8. Thiết kế code để dùng cho cả R1 và R2

Cấu trúc dưới đây là **đề xuất triển khai**, chưa phải các module đã viết:

| Module | Trách nhiệm |
|---|---|
| parameters.py | Material, units, nguồn và giới hạn |
| constitutive.py | Norton/J2, tangent, tensor invariants |
| ductility.py | Cocks–Ashby, Wen–Tu; cùng interface |
| toughness.py | beta(D), G_eff, trường cho trước |
| history.py | committed/trial, snapshot/rollback |
| mechanics.py | R_u, Jacobian và boundary conditions |
| phasefield.py | Hai assembler V/L; bounds/history |
| time_solver.py | Staggered loop, adapt dt, commit |
| geometries.py | Thanh, tấm nứt, thanh khía, CT |
| diagnostics.py | Crack length, CMOD, errors, năng lượng |
| cases/ | Cấu hình thí nghiệm, không hard-code trong solver |
| verification/ | Nghiệm chuẩn và checks có ý nghĩa |
| results/ | Metadata, CSV, trường XDMF/VTX, log hội tụ |

Cấu hình tối thiểu: case_id; geometry; loading; material; creep_law; ductility_model; pf_form; stress_convention; irreversibility_mode; viscosity_mode; ell; mesh; dt_policy; crack_measure; parameter_source; calibration_id.

Các lựa chọn cốt lõi: `ductility_model=CA|WT`, `pf_form=V|L`. Không sửa Norton khi đang khảo sát ductility. Không sửa ductility khi đang khảo sát gradient toughness.

Chuyển vị và d dùng Lagrange; internal variables ở quadrature points. Lưới Gmsh hoặc mesh chuẩn DOLFINx, solver PETSc. Cố định một bộ phiên bản DOLFINx/UFL/Basix/FFCx/PETSc/mpi4py tương thích sau smoke test, ghi manifest và container/lockfile; không giả định tutorial cũ chạy nguyên trên bản mới.

## 9. Local integration và thuật toán thời gian

File đã có `ragab2024_material_point.py` chỉ tích phân trapezoidal dưới prescribed stress; không phải implicit constitutive solver cho FEM. Khi ghép cần local solve với eps_{n+1}, eps_cr_n và eps_p_n; chọn backward Euler hoặc scheme khác có kiểm chứng, trả stress và algorithmic tangent. Kiểm tra tangent bằng finite difference ở trạng thái trơn trước khi dùng Newton.

Thuật toán đề xuất:

1. Lưu snapshot committed tại t_n, gồm u_n, d_n và toàn bộ internal variables.
2. Chọn dt, cập nhật tải tại t_{n+1}; dự đoán u,d.
3. Với d hiện tại, giải mechanics. Mỗi residual/Jacobian evaluation tính trial constitutive state **từ cùng committed state t_n**.
4. Cập nhật trial W_p, W_cr, D, H và G_eff phù hợp cùng trạng thái.
5. Giải PF V hoặc L, với d_n là bound nếu chọn chế độ bounds.
6. Lặp mechanics/PF; kiểm tra residual và thay đổi trường/internal variables.
7. Chỉ commit khi toàn hệ đạt tiêu chí. Nếu thất bại, rollback tất cả rồi giảm dt.
8. Sau commit mới lưu kết quả và quyết định dt tiếp.

Newton iteration, staggered iteration và physical time step là ba khái niệm khác nhau. Không cộng thêm creep/công/H sau mỗi iteration như một bước thời gian mới. Không cập nhật H_committed bằng max của các trial thất bại: H_trial=max(H_n,Psi_trial).

Adaptive dt xét độ tăng D,d, số iteration và sai số kiểm tra; không dựa duy nhất vào D=1. Kiểm soát ramp tải, có thể giải trạng thái đàn hồi–dẻo ban đầu rồi chọn t=0 tại đầu hold; tất cả mô hình dùng cùng quy ước.

## 10. Lộ trình bắt buộc và tiêu chí chuyển bước

Các ngưỡng bên dưới là mục tiêu chất lượng **đề xuất cho dự án**, không phải yêu cầu trong Ragab hoặc tiêu chuẩn ngành. Nếu bài toán gần instability, dùng log và nghiên cứu độ nhạy để giải thích; không chỉnh tolerance chỉ để cho qua.

### M0 — Đóng mô hình, môi trường và dữ liệu

Lập material ledger, decision log; chạy smoke test elasticity/PF trên phiên bản đã chọn. Xác nhận tensor conventions và đơn vị. Liệt kê rõ dữ liệu calibration/validation có thật, dữ liệu chưa lấy được và giả thiết thay thế. Kiểm tra nu/hardening trước mô hình elastoplastic đầy đủ.

**Đầu ra:** đặc tả mô hình; bảng tham số; environment manifest; danh sách benchmark và data split. Chỉ tiếp tục các phần phụ thuộc sau khi quyết định tương ứng được chốt.

### M1 — Material point: đã có nền, bổ sung local solver khi cần

Thử uniaxial hold 82 MPa, 24 h. Nghiệm Norton: eps_eq=A sigma^n t; D=eps_eq/eps_f; W_cr=A sigma^(n+1)t. Tensor creep có eps11=eps_eq, eps22=eps33=−eps_eq/2. Thêm stress ramp để kiểm tra bậc hội tụ; cộng hydrostatic stress giữ sigma_eq để tách creep khỏi damage; kiểm tra rotation invariance và committed-state isolation khi tích hợp vào FEM.

Kết quả script hiện có: eps_eq≈0.020197538, D≈0.072134066, W_cr≈1.6561981 MPa, G_eff≈92.858728 N/mm. Đây là đáp ứng prescribed stress không có phase-field hay structural failure. Giảm một nửa dt đã cho sai số ramp giảm xấp xỉ 4 lần với scheme trapezoidal; không kỳ vọng backward Euler có cùng bậc.

**Qua mốc:** constant-stress analytic check ở gần machine precision cho bộ prescribed stress; chứng minh bậc hội tụ phù hợp local solver được chọn; mỗi luật ductility cho F(1/3)=1.

### M2 — Đàn hồi FEM

Thanh 2D hoặc 3D chịu traction; bắt đầu plane stress để thuận nghiệm một trục. Kiểm tra u_x=sigma x/E, co Poisson, phản lực và strain energy. Không dùng tensor stress 2×2 để tính triaxiality 3D. Mô hình plane strain cần eps33=0 và sigma33 tương ứng.

**Qua mốc:** error u/sigma và imbalance reaction mục tiêu <1e-6 cho nghiệm affine phân giải được; ghi norm, mẫu số và lỗi tuyệt đối khi mẫu số gần zero. Có output mesh/BC và deformation.

### M3 — Creep trong kết cấu chưa nứt

(i) Traction hold: đối chiếu creep một trục. (ii) Giữ tổng biến dạng: đối chiếu stress relaxation của scalar elastic–Norton, không plasticity:

$$
\sigma(t)=\left[\sigma_0^{1-n}+(n-1)EA t\right]^{1/(1-n)}.
$$

Công thức trên chỉ cho uniaxial stress kinematics phù hợp, không áp dụng nguyên cho thanh 3D bị khóa tất cả strain ngang. Giải thích boundary conditions trước khi đối chiếu.

**Qua mốc:** giảm dt làm lỗi giảm theo scheme; sai số mục tiêu <1% ở case đã hội tụ; rollback không giữ internal history thất bại.

### M4 — AT2 không creep

Dùng benchmark nứt đàn hồi có hình học/BC từ nguồn rõ. Tutorial NewFrac có thể dùng khung solver nhưng ví dụ w(d)=d là AT1; phải đổi crack density và normalization đúng AT2, không coi tutorial đó là Ragab. Thử một bài profile 1D và một tấm nứt kéo. Kiểm tra bounds/healing, reaction–displacement và cách tạo d0.

**Qua mốc:** khớp nghiệm 1D, benchmark định lượng; d không giảm trong unload; refinement giữ ell cố định và có kết quả hội tụ.

### M5 — Sức kháng nứt cho trước, hai assembler V/L

Không creep, không plasticity. Trên [0,L], đặt G_eff=G0 exp(kappa x), H=0, eta_v=0; profile chính xác của V:

$$
r_-=\frac{-\kappa-\sqrt{\kappa^2+4/\ell^2}}2,
\quad d_V(x)=e^{r_-x}.
$$

Đặt **cùng BC** d(0)=1 và d(L)=exp(r_-L) cho cả V/L. Với L, nghiệm là a exp(−x/ell)+b exp(x/ell), a+b=1 và a exp(−L/ell)+b exp(L/ell)=exp(r_-L); tính ổn định số cho L/ell lớn. Không so hai mô hình với hai giá trị d(L) khác nhau.

Thêm kappa=0, kappa dương/âm trong miền hữu hạn nơi G_eff>0; cùng mesh/BC/quadrature. Có thể thêm manufactured source smooth để kiểm tra residual khác. Exponential là benchmark toán học, không giả thiết P91.

**Qua mốc:** từng code hội tụ về nghiệm riêng; V/L khớp khi G đồng nhất; so Psi_f của hai profile với BC giống nhau, không khẳng định minimum từ một solution bất kỳ của hệ ghép.

### M6 — Ghép creep–PF giản lược

Bật D và W_cr, bỏ plasticity có nhãn rõ. Kiểm tra case đồng nhất; nếu dùng Phụ lục A, bảo đảm cách chọn prescribed stress và H/G_eff khớp đúng giả thiết. Không coi nghiệm phụ lục là nghiệm chính xác của thanh lực giữ đã có stiffness degradation tự nhất quán.

Thực hiện các ablation: (a) elastic driving only, beta=1; (b) có creep work, beta=1; (c) elastic driving + beta(D); (d) cả creep work và beta(D). Dùng chúng để giải thích cơ chế, không gọi cả bốn là mô hình vật liệu đã validation.

**Qua mốc:** tái lập giới hạn đồng nhất; hội tụ theo dt và staggering; đo được nứt phát triển trong hold nếu điều kiện cho phép. Nếu không phát triển, phân tích H/G_eff và tải, không ép sửa tham số để tạo hình nứt.

### M7 — Plasticity và mô hình đầy đủ

Kiểm tra return mapping với uniaxial tension/unload, hardening law, yield condition và tangent; ghép creep/plasticity có local residual phù hợp. Đóng góp W_p được tính nhất quán theo thời gian. Perfect plasticity chỉ là giả thiết nếu không có dữ liệu hardening.

**Qua mốc:** plasticity độc lập đúng, bước thời gian hội tụ; solver đầy đủ quay về các giới hạn khi A→0 hoặc inelastic driving bị tắt. Muốn gọi “tái lập Ragab” phải báo mức độ matching của luật, stress, solver, dữ liệu và geometry.

### M8 — Bài toán nứt của assignment

Bắt đầu tấm nứt 2D như benchmark thăm dò, dùng một cấu hình tải hold dưới ngưỡng phá hủy tức thời nếu có thể. Geometry, ramp, load và crack depth phải được ghi trong file cấu hình; không nhận kết quả 2D này là CT 3D của Ragab.

Sau khi ổn định, thêm thanh khía axisymmetric để tái lập calibration và CT 3D để đối chiếu dữ liệu. Axisymmetric chỉ dùng cho thanh khía tròn; CT không phải bài toán axisymmetric. 2D plane stress/plane strain là hai lý tưởng hóa, không hai chiều dày thực. 3D dùng các mặt phẳng symmetry, không “axisymmetric boundary” cho CT.

**Qua mốc assignment tối thiểu:** một case nứt ghép có a(t), CMOD, trường D/d/sigma_eq/eta_tr, ablation giải thích cơ chế và nghiên cứu hội tụ. Nếu có dữ liệu độc lập cùng điều kiện, bổ sung validation; nếu chưa có thì ghi rõ numerical study.

## 11. Đo đầu nứt, constraint và sai số

- **Crack length 2D:** chọn d_threshold cố định (ví dụ 0.95 như lựa chọn dự án), lấy điểm xa nhất thuộc vùng connected với initial crack trên đường đo xác định. Không tính vùng damage rời rạc là phần mở rộng vết nứt. Nội suy crossing; báo sensitivity với threshold, ví dụ 0.90/0.95/0.99.
- **Initiation:** thời gian Delta a vượt một giá trị định trước, lớn hơn độ bất định đo do mesh; d=1 trong AT2 có residual stiffness/viscosity có thể không đạt chính xác. Giữ định nghĩa chung cho mọi case.
- **CT 3D:** báo a(z,t), average crack extension và tunnelling; cách average/đo phải khớp dữ liệu thực nghiệm. Không lấy max crack depth làm average experimental crack length.
- **CMOD:** hiệu chuyển vị tại hai vị trí gauge đã định nghĩa. Reaction dùng residual/traction integration nhất quán.
- **Constraint:** lưu eta_tr(r,t) dọc các đường trước đầu nứt với r/ell hoặc khoảng cách vật lý giống nhau; mask vùng fully cracked và điểm có sigma_eq quá nhỏ. Một maximum eta phụ thuộc lưới không đủ làm chỉ số constraint.
- **Error a(t):** dùng thời gian chung để nội suy, báo RMSE tính bằng mm, thời điểm khởi nứt và relative error với mẫu số không zero. Không ngoại suy phần thí nghiệm chưa có.

Không dùng J-integral thông thường như đại lượng path-independent để validation trong môi trường toughness biến thiên và creep nếu chưa suy ra correction/điều kiện thích hợp.

## 12. Hội tụ và chẩn đoán năng lượng

Với mỗi case đại diện, giữ ell và profile material/toughness cố định rồi chạy ít nhất ba lưới; bắt đầu h gần vùng nứt khoảng ell/4, ell/6, ell/8 như gợi ý thực hành và refine thêm nếu chưa hội tụ. Với transition width delta, phải phân giải cả delta lẫn ell. Không biến delta thành h để rồi gọi là convergence vật lý.

Giữ lưới đủ tốt, giảm dt ít nhất ba mức. Xét reaction/CMOD/a(t), initiation và time-to-Delta a; mục tiêu dự án thay đổi <2–5% giữa hai mức cuối, nêu riêng từng đại lượng. Nếu threshold nứt tạo bước nhảy, báo uncertainty chứ không ép criterion.

Sau mesh/time convergence mới khảo sát ell riêng. Giữ cùng ell trong so sánh R1/R2; nếu đổi ell giữa thanh khía và CT như bài phải báo là thay đổi mô hình/thiết lập và đánh giá ảnh hưởng. Không re-fit ell trên validation data.

Viscosity: kiểm tra ít nhất hai mức giảm, dt tương thích; phân biệt `fixed_eta_v` với `fixed_mu_pf`. Đối chứng V/L chính giữ cùng eta_v (hoặc cả hai không viscosity khi solver ổn định); chế độ tái lập mu_pf của bài được ghi riêng.

Lưu: external work, elastic energy theo quy ước suy giảm đã chọn, Psi_f, W_p, W_cr, viscous diagnostic và residual. Khi G_eff thay đổi:

$$
\dot\Psi_f=\int_\Omega\dot{\mathcal G}\gamma_\ell\,dx
+\int_\Omega\mathcal G\left(\frac d\ell\dot d+\ell\nabla d\cdot\nabla\dot d\right)dx.
$$

Không bỏ integral đầu rồi gọi chênh lệch là lỗi solver. Phần năng lượng này giảm ngay trên vùng crack đã hình thành; cần giải thích bookkeeping và thermodynamic interpretation. Dẫn xuất đúng PF ở D frozen chưa chứng minh dissipative consistency toàn mô hình; assignment phải ghi giới hạn này và kiểm tra local/global balance trong các benchmark phù hợp.

D ở quadrature có thể không smooth. V không cần lấy grad D trực tiếp. Chỉ số gradient ở R2 phải dùng trường smooth benchmark hoặc reconstruction có kiểm tra nhạy, không grad tùy ý của nodal projection.

## 13. Ma trận khảo sát tối thiểu cho assignment

| Nhóm | Case tối thiểu | Điều phải giữ cố định |
|---|---|---|
| Verification | M1–M5 và kiểm tra plasticity | Units, BC, nghiệm đối chiếu |
| Baseline ghép | CA + V; hai mức tải hold ổn định | Material, ell, crack measure |
| Cơ chế | Bốn ablation M6 ở một case | Tải và lịch sử vật liệu |
| Ductility thăm dò | CA/WT ở một hình học, một tải | PF=V và toàn bộ tham số khác |
| Gradient thăm dò | V/L ở G đồng nhất và một G không đồng nhất | CA, tải, eta_v, mesh |
| Numerical reliability | Ba mesh và ba dt ở case đại diện | ell và physical transition width |

Hai khảo sát thăm dò không đủ để kết luận ưu thế vật lý của một mô hình; chúng xác nhận nền đã hỗ trợ hai nhánh. Tăng số case sau khi benchmark qua gates.

## 14. Nhánh R1: ductility và khả năng chuyển dự đoán

**Câu hỏi:** fit ở một geometry/constraint có dự đoán đúng ở geometry/constraint khác không?

Thiết kế:

1. Thu thập uniaxial creep/ductility và tensile data cùng grade, heat, temperature khi có thể. Nếu phải ghép nguồn, nêu rõ và không dùng scatter như bằng chứng một luật tốt hơn.
2. Fit Norton bằng dữ liệu vật liệu; giữ cố định trong so sánh ductility. CA/WT dùng cùng eps_f và cùng conventions; tùy chọn luật rate-dependent chỉ khi dữ liệu đủ.
3. Thí nghiệm computational “frozen parameters”: CA/WT, cùng Gc0,v,beta0,ell, PF=V; định lượng riêng ảnh hưởng luật.
4. Thí nghiệm “fair recalibration”: mỗi luật fit trên **cùng calibration split**, cùng objective/weighting/bounds. Tập validation không dùng chọn tham số, ell, thresholds hoặc tuning solver.
5. Validation trên thanh khía notch radius khác, CT geometry khác hoặc CT thickness khác. Chiều dày phải mô hình 3D; chỉ dùng plane-stress/strain như thăm dò.
6. Báo a(t), initiation, CMOD, eta profiles, uncertainty và scatter. Nếu chưa có dữ liệu khác geometry, kết quả chỉ là numerical sensitivity/transfer giữa bài toán mô phỏng, không experimental predictive transfer.

Nhận dạng tham số: kiểm tra profile objective/sensitivity hoặc multistart để phát hiện eps_f,v,Gc0,ell bù nhau. Ductility đầu vào phụ thuộc stress/rate chưa được nhận dạng chỉ bằng thêm một parameter trong PF.

**Đóng góp có thể hướng tới:** hiểu miền constraint mà lựa chọn ductility ảnh hưởng dự đoán và calibration transfer. Đổi CA→WT một mình không phải luật mới. Rà soát Wen–Tu 2014, Wen et al. 2016, Wu et al. 2023 và các nghiên cứu mới hơn trước tuyên bố novelty.

## 15. Nhánh R2: sức kháng nứt phát sinh theo không gian

**Câu hỏi:** khi nào dạng L là xấp xỉ chấp nhận được của V trong creep cracking?

Ba lớp nghiên cứu:

1. **Profile 1D** M5, nghiệm giải tích; thêm piecewise toughness nếu cần, dùng weak form và transmission conditions thay vì grad G tại discontinuity.
2. **Tấm 2D G cho trước**, dùng vùng yếu tanh/Gaussian dương, trơn. Thay contrast G_min/G_max; transition width delta/ell; vị trí và hướng gradient. Giữ elastic field/material giống nhau lúc đầu để tách toughness heterogeneity.
3. **G phát sinh do D**, P91 creep–PF. Giữ CA và luật creep; chỉ đổi V/L. Phân tích G_eff(x,t), crack path, a(t), initiation và sensitivity.

Chỉ số thăm dò:

$$
\chi=\ell|\nabla\ln\mathcal G|,
\quad \nabla\ln\mathcal G=\frac{\beta'(D)}{\beta(D)}\nabla D.
$$

chi là scaling indicator do dự án đề xuất, không threshold phổ quát. Hướng tương đối với grad d và crack path cũng quan trọng. Thống kê chi chỉ trong active crack/process zone; không lấy global maximum ở góc lưới làm đại diện.

Thực hiện frozen-parameter comparison trước, sau đó nếu có dữ liệu làm fair recalibration. V/L phải cùng BC, eta_v, threshold, dt policy đủ hội tụ. Không đòi V luôn nhanh/chậm hơn L. Trong case G prescribed có thể so residual/energy với cùng functional; trong coupled creep case cần bookkeeping section 12.

**Đóng góp có thể hướng tới:** error map, miền sử dụng approximation, và hậu quả khi G evolving. Spatial G và dạng divergence không mới tự thân; benchmark/numerical consequences trong bối cảnh creep và kiểm chứng có thể tạo đóng góp nếu chưa được nghiên cứu đầy đủ.

Đọc heterogeneous/interface literature để tránh bỏ qua tương tác delta/ell và effective toughness. Không gọi hạng gradient là “cavity diffusion”: nó xuất phát từ biến phân surface energy, không tự thêm phương trình khuếch tán D.

## 16. Ma trận nghiên cứu mở rộng 2×2

| | PF dạng V | PF dạng L |
|---|---|---|
| Ductility CA | Nền chính | Đối chứng R2 |
| Ductility WT | Đối chứng R1 | Tương tác hai lựa chọn, chỉ khảo sát sau |

Thứ tự: CA–V verification → CA–L R2 → WT–V R1 → WT–L interaction nếu cần. Không dùng một case đổi cả hai để quy trách nhiệm sai khác cho riêng ductility hoặc gradient. Một publication nên có một câu hỏi chính; không gom mọi extension vào một bài nếu chưa có chứng cứ.

## 17. Dữ liệu, lưu kết quả và tái lập

Mỗi run lưu một metadata file: run_id; code revision; exact environment; source material; geometry dimensions; mesh checksum; symmetry/2D hypothesis; load ramp/hold; sigma convention; CA/WT; V/L; ell; viscosity; numerical tolerances; dt history; threshold; calibration split. Field output: u,d,D,G_eff,sigma_eq,eta_tr,eps_eq_cr,H; scalar output: t, reaction, CMOD,a,energy diagnostics,iterations,accepted/rejected step counts.

CSV dữ liệu thực nghiệm cần: dataset_id, specimen_id, material/heat, BM/HAZ/WM, T, geometry, B, a0/W, load, time, crack extension, displacement nếu có, measurement definition, source figure/page, extracted/raw, uncertainty, calibration/validation label. Giữ raw và processed riêng; digitized figure data có sai số, không giả độ chính xác vượt resolution.

Dữ liệu tối thiểu để bài báo R1: calibration ở một nhóm và validation ở constraint khác, cùng điều kiện vật liệu hợp lý. R2 có thể bắt đầu bằng theoretical/numerical verification; claim cải thiện predictive accuracy cần experimental validation hoặc physical reference phù hợp. Data availability của bài không đồng nghĩa ta đã có raw data; contact author là bước sau chỉ khi được người dùng cho phép gửi.

## 18. Lịch trình gợi ý 10 tuần, điều chỉnh theo gates

| Tuần | Công việc | Sản phẩm |
|---|---|---|
| 1 | M0–M1: lý thuyết, dữ liệu, material point | Ledger, equations, analytic checks |
| 2 | M2–M3: elasticity, creep FEM | Traction/relaxation benchmarks |
| 3 | M4–M5: AT2, spatial G verification | Hai assembler, profile/error curves |
| 4 | M6: coupling giản lược, rollback | Homogeneous case, ablations |
| 5 | M7: plasticity và đầy đủ | Local checks, coupled solver |
| 6 | M8: tấm nứt; thanh khía nếu kịp | a(t), CMOD, fields |
| 7 | Hội tụ và chốt diagnostics | Mesh/dt/viscosity studies |
| 8 | Thăm dò CA/WT và V/L | Ma trận assignment |
| 9 | CT/dữ liệu độc lập hoặc hoàn thiện nền | Validation hoặc limits rõ |
| 10 | Báo cáo, code/documentation | Deliverables hoàn chỉnh |

Đây là lịch đề xuất cho người có nền FEM/Python; chưa biết deadline/kinh nghiệm nên không bảo đảm thời lượng. Nếu chỉ 6–8 tuần, giảm CT 3D và phạm vi validation, giữ material/elasticity/creep/AT2/tấm ghép và verification. Mô hình chưa hoàn thành plasticity phải gọi elastic–creep PF, không elastoplastic Ragab đầy đủ.

## 19. Cấu trúc báo cáo và sản phẩm bàn giao

Báo cáo chính gợi ý 15–25 trang, phụ lục chứa chi tiết code/ledger:

1. Câu hỏi, phạm vi và hai nhánh mở rộng.
2. Cơ chế creep fracture, D khác d, nền fracture mechanics.
3. Phương trình vật liệu và hai PF formulations; giả thiết còn thiếu.
4. Dữ liệu, calibration split và hệ đơn vị.
5. Discretization, local integration, solver/time history.
6. Verification results và convergence.
7. Coupled crack growth, ablation và thăm dò R1/R2.
8. Discussion: constraint, spatial toughness, identifiability, limitations.
9. Kết luận trên bằng chứng; việc tiếp theo.

**Bộ bàn giao:** code cấu trúc module, environment manifest, case configs, dữ liệu có nguồn, run instructions, benchmark checks, kết quả đại diện, báo cáo, decision log và research backlog. File hướng dẫn này là thiết kế; ngoài material-point script đã có, các solver FEM/module đề xuất chưa được triển khai hoặc chạy.

Danh sách figure tối thiểu: creep/damage one-point; stress relaxation; profile 1D V/L analytic/numerical; load–displacement AT2; coupled a(t)/CMOD; D–d–G_eff–eta snapshots; mesh/time convergence; CA/WT thăm dò; V/L thăm dò. Bảng contour luôn đi kèm định lượng và định nghĩa measurement.

## 20. Bình chịu áp lực: mốc ứng dụng sau nền

Nếu tiếp tục mục tiêu ban đầu, làm bình đàn hồi chưa nứt và kiểm tra Lamé; sau đó thêm creep chưa nứt. Chọn crack topology trước dimensionality: nứt dọc trục dài → mặt cắt ngang với axial condition thích hợp; nứt vòng liên tục → axisymmetric; surface semi-ellipse hữu hạn → 3D. Xét tải do nắp kín, có/không pressure trên crack faces và ramp. Không dùng axisymmetric cho crack dọc trục cục bộ.

Sau verification CT/tấm, khảo sát áp suất và a0/t_wall, giữ material/ell đã chốt. Không dùng tuổi thọ bình là kết quả đã validation khi chỉ có số tham số ở sample test. HAZ và vật liệu nhiều vùng là extension sau cùng, vì thêm property gradients làm R2 khó tách hơn.

## 21. Tài liệu tham khảo và mục đích

- Ragab et al. (2024), DOI https://doi.org/10.1016/j.engfracmech.2024.110491 — nguồn chính cho equations, P91 650 °C, calibration và CT.
- Ragab et al. (2022), DOI https://doi.org/10.1016/j.euromechsol.2021.104424 — creep–damage Grade 91 vessel weldment; đọc để phân biệt với mô hình 2024, không ghép tham số nguyên trạng.
- Wen & Tu (2014), DOI https://doi.org/10.1016/j.engfracmech.2014.03.001 — cơ sở Wen–Tu và multiaxial ductility.
- Wen et al. (2016), DOI https://doi.org/10.1016/j.jmst.2016.02.014 — stress level/state dependence; nền R1.
- Wu et al. (2023), DOI https://doi.org/10.15632/jtam-pl/166369 — các mô hình ductility đã có; kiểm tra novelty R1.
- Kristensen et al. (2021), https://www.empaneda.com/wp-content/uploads/2021/03/RoyalSocietySubmitted.pdf — AT1/AT2, ell và crack initiation.
- Yoshioka, Mollaali & Kolditz (2021), DOI https://doi.org/10.1016/j.cma.2021.113951 — spatial/interface toughness, profile và energetic equivalence; nền R2.
- Hansen–Dörr et al., DOI https://doi.org/10.1007/s00419-020-01759-3 — heterogeneous media, interface/phase-field scales và convergence; nền R2.
- NewFrac, https://newfrac.github.io/fenicsx-fracture/notebooks/phase-field/phase-field.html — DOLFINx phase-field, alternate minimization/bounds; phải phân biệt AT1 tutorial và AT2 dự án.
- dolfinx_materials, https://bleyerj.github.io/dolfinx_materials/ — constitutive integration/internal variables; tham khảo cách triển khai, không solver Ragab có sẵn.

## 22. Việc tiếp theo trong phiên làm việc

1. Đóng decision log và chọn environment FEniCSx.
2. Xây dựng thanh đàn hồi M2 và creep M3, kiểm tra bằng nghiệm đơn giản.
3. Xây dựng benchmark spatial-toughness 1D M5 song song theo thứ tự thực hiện trong cùng dự án; không cần đợi CT.
4. Sau khi cả hai nền đúng, ghép M6 và thêm plasticity M7.

Hai nghiên cứu sau này dùng chung nền verified, data pipeline và diagnostics. Không cần làm lại toàn bộ code; chỉ thay module ductility hoặc PF assembler theo cấu hình.
