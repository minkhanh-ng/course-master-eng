# **Báo Cáo Nghiên Cứu và Đề Xuất Kế Hoạch: Lộ Trình Phát Triển Bộ Giải GNN-FEM Trường Pha và Toán Tử Surrogate KANO-GNN Tương Thích Nhiệt Động Lực Học**

## **Tổng Quan Khung Nghiên Cứu và Lộ Trình Công Nghệ**

Sự toàn vẹn cấu trúc của các hệ thống thiết bị hoạt động trong môi trường nhiệt độ và áp suất cao, điển hình như các nhà máy nhiệt điện, lò phản ứng hạt nhân và tổ hợp hóa dầu, phụ thuộc sống còn vào khả năng chịu đựng hiện tượng từ biến (creep) của các vật liệu hợp kim tiên tiến. Thép P91 (Modified 9Cr-1Mo), một loại thép martensite ram, đã trở thành vật liệu tiêu chuẩn nhờ đặc tính cơ học vượt trội ở dải nhiệt độ 550°C \- 650°C. Tuy nhiên, quá trình hàn chế tạo làm thay đổi cấu trúc vi mô của vật liệu, tạo ra một hệ thống mối hàn đa vùng (multi-zone weldment) với các đặc tính cơ lý không đồng nhất, dẫn đến hiện tượng suy giảm độ bền từ biến cục bộ và khởi phát các cơ chế nứt nghiêm trọng, đặc biệt là nứt Loại IV (Type IV cracking).  
Việc dự đoán chính xác tuổi thọ còn lại và hành vi lan truyền vết nứt trong các cấu trúc phức tạp này bằng phương pháp phần tử hữu hạn (FEM) truyền thống đòi hỏi khối lượng tính toán khổng lồ, khiến các hoạt động đánh giá rủi ro thời gian thực (real-time assessment) theo các tiêu chuẩn khắt khe như API 579-1/ASME FFS-1 và BS 7910 trở nên bất khả thi. Báo cáo này trình bày một bản thiết kế toàn diện cho lộ trình nghiên cứu và phát triển chiến lược chia làm hai giai đoạn nhằm giải quyết triệt để rào cản tính toán này.  
Giai đoạn thứ nhất (Từ Tháng 0 đến Tháng 8\) tập trung phát triển bộ giải lai GNN-FEM (Mạng Nơ-ron Đồ thị \- Phần tử Hữu hạn) cho bài toán đứt gãy trường pha do từ biến trên hệ thống mối hàn thép P91. Giai đoạn này sử dụng mô hình cơ sở của Ragab và cộng sự (2024) được triển khai trên nền tảng tính toán hiệu năng cao FEniCSx. Giai đoạn thứ hai (Từ Tháng 9 trở đi) đánh dấu bước nhảy vọt về mặt công nghệ bằng việc phát triển Toán tử Surrogate KANO-GNN (Kolmogorov-Arnold Neural Operator) tương thích hoàn toàn với các định luật nhiệt động lực học, phục vụ cho việc tạo mẫu ảo (virtual prototyping) và phân tích các kịch bản giả định (what-if analysis) theo tiêu chuẩn Đánh giá Sự Phù hợp với Dịch vụ (Fitness-For-Service \- FFS).

## **Đặc Tính Vi Cấu Trúc và Cơ Chế Phá Hủy Từ Biến Của Hệ Thống Mối Hàn Thép P91**

### **Sự Biến Đổi Vi Cấu Trúc Đa Vùng Do Chu Trình Nhiệt Hàn**

Thép P91 là dòng hợp kim chứa 9% Cr và 1% Mo, được bổ sung các nguyên tố vi lượng như V, Nb và N để tạo ra các kết tủa carbonitride mịn. Ở trạng thái kim loại cơ bản (Base Metal \- BM), cấu trúc vi mô của P91 là martensite ram được sắp xếp theo cấu trúc phân cấp bao gồm các hạt austenite nguyên thủy (Prior Austenite Grains \- PAGs), các khối (blocks), và laths. Mạng lưới lath này chứa mật độ lệch mạng (dislocation density) rất cao, được khóa chặt (pinning) bởi sự kết tủa của hạt carbide M_{23}C_6 trên các biên hạt và hạt MX (V(C,N), Nb(C,N)) bên trong lath, tạo ra khả năng chống biến dạng từ biến xuất sắc.  
Khi thực hiện quá trình hàn, chu trình nhiệt (thermal cycle) nung nóng và làm nguội nhanh chóng tạo ra một dải biến thiên liên tục về vi cấu trúc, được chia thành bốn vùng cơ bản: Kim loại hàn (Weld Metal \- WM), Vùng ảnh hưởng nhiệt hạt thô (Coarse-Grained Heat-Affected Zone \- CGHAZ), Vùng ảnh hưởng nhiệt hạt mịn (Fine-Grained Heat-Affected Zone \- FGHAZ) và Vùng ảnh hưởng nhiệt liên tới hạn (Intercritical HAZ \- ICHAZ). Động học đứt gãy từ biến của toàn bộ cấu trúc bị chi phối hoàn toàn bởi sự tương tác cơ học và sự khác biệt về độ cứng giữa các vùng này.  
Vùng FGHAZ được hình thành khi nhiệt độ đạt mức vừa vượt qua ranh giới biến đổi pha Ac_3, đủ để chuyển đổi cấu trúc sang austenite nhưng không đủ thời gian và nhiệt năng để hòa tan hoàn toàn các kết tủa và làm cho hạt phát triển. Kết quả là vùng này sở hữu kích thước hạt nguyên thủy rất mịn. Kích thước hạt nhỏ làm tăng đáng kể tổng diện tích biên hạt, biến chúng thành các kênh khuếch tán nhanh ở nhiệt độ cao. Sự gia tăng tốc độ khuếch tán này dẫn đến việc các kết tủa carbide M_{23}C_6 bị thô hóa nhanh chóng (coarsening), hòa tan một phần kết tủa MX mịn, và làm tăng tốc độ phục hồi các lệch mạng trong quá trình hoạt động ở nhiệt độ cao (ví dụ: 600°C \- 650°C). Những thay đổi luyện kim này biến FGHAZ thành vùng có sức bền từ biến thấp nhất trong toàn bộ cấu trúc mối hàn, thường được gọi là "mắt xích yếu" (weak link).

### **Cơ Học Từ Biến và Sự Cạn Kiệt Độ Dẻo Ở Điều Kiện Ứng Suất Đa Trục**

Hành vi từ biến của thép P91 tuân theo quy luật lũy thừa Norton-Bailey cho giai đoạn từ biến ổn định thứ hai (steady-state secondary creep), được biểu diễn bởi phương trình:
$$
\dot{\varepsilon}_{cr} = A \sigma^n
$$  
Trong đó, $\dot{\varepsilon}_{cr}$ là tốc độ biến dạng từ biến, $\sigma$ là ứng suất hiệu dụng, A và n là các hằng số vật liệu. Các thử nghiệm nới lỏng ứng suất (stress relaxation) và thử nghiệm mẫu thanh đôi nhỏ (Two-Bar Specimen \- TBS) ở nhiệt độ 650°C cho thấy số mũ ứng suất n của thép P91 dao động quanh giá trị 7.3 đến 9.9, và năng lượng hoạt hóa Q xấp xỉ 597 kJ/mol. Sự khác biệt về hằng số Norton giữa Kim loại hàn (thường có độ bền cao hơn \- over-matched), BM, CGHAZ và FGHAZ tạo ra sự kiềm chế ứng suất (stress constraint) cực kỳ phức tạp.  
Cụ thể, khi chịu tải trọng cơ học ở nhiệt độ cao, vùng FGHAZ mềm hơn sẽ có xu hướng biến dạng từ biến nhanh hơn, nhưng nó lại bị giới hạn (constrained) bởi các vùng cứng hơn kẹp hai bên là CGHAZ và BM. Sự kìm hãm này ngăn cản biến dạng dẻo vĩ mô, làm gia tăng mạnh mẽ ứng suất thủy tĩnh (hydrostatic stress) và dẫn đến trạng thái ứng suất đa trục cục bộ. Trạng thái ứng suất đa trục làm gia tốc quá trình tạo mầm (nucleation) và phát triển các khoang rỗng (creep cavities) trên các biên hạt tại FGHAZ.  
Nghiên cứu đột phá của Ragab và cộng sự (2022, 2024) nhấn mạnh rằng cơ chế đứt gãy giòn ở các hệ thống thép martensite ram bị kiềm chế chủ yếu được kiểm soát bởi hiện tượng "cạn kiệt độ dẻo" (ductility exhaustion). Độ dẻo từ biến (creep ductility), đại diện cho khả năng chống lại sự tích lũy tổn thương của vật liệu, không phải là một hằng số mà thay đổi theo trạng thái ứng suất. Ở chế độ ứng suất cao (từ biến gia tốc), độ dẻo cao và đứt gãy mang tính dẻo; trong khi ở chế độ ứng suất thấp dài hạn (long-term creep), độ dẻo giảm mạnh, và đứt gãy tiến triển theo cơ chế giòn. Hơn nữa, việc tích lũy các chu kỳ mỏi vòng đời thấp (Low Cycle Fatigue \- LCF) trước đó càng làm suy giảm nghiêm trọng độ dẻo từ biến. Việc không tính toán đầy đủ sự cạn kiệt độ dẻo đa trục này chính là nguyên nhân khiến các mô hình sinh trưởng rạn nứt truyền thống thường dự báo sai thời điểm sụp đổ của cấu trúc.

| Đặc Tính Cơ Lý | Kim Loại Cơ Bản (BM) | Vùng Hạt Thô (CGHAZ) | Vùng Hạt Mịn (FGHAZ) | Kim Loại Hàn (WM) |
| :---- | :---- | :---- | :---- | :---- |
| **Kích thước hạt (PAG)** | Trung bình | Lớn | Rất nhỏ, mịn | Lớn (Dạng nhánh) |
| **Mật độ kết tủa M_{23}C_6** | Ổn định, phân bố đều | Hòa tan một phần | Bị thô hóa mạnh | Thay đổi theo vật liệu bù |
| **Tốc độ từ biến thứ cấp** | Tiêu chuẩn cơ sở | Trung bình | Rất cao | Rất thấp (Over-matched) |
| **Độ dẻo từ biến (Ductility)** | Cao | Trung bình | Cạn kiệt cực nhanh | Thấp / Trung bình |
| **Kiểu hư hỏng điển hình** | Ít khi xảy ra phá hủy | Nứt vi mô cục bộ | Nứt loại IV (Type IV) | Rỗ khí, nứt đông đặc |

## **Giai Đoạn 1: Xây Dựng Bộ Giải GNN-FEM Cho Đứt Gãy Từ Biến Trường Pha (Tháng 0 \- Tháng 8\)**

Giai đoạn đầu tiên của dự án thiết lập nền tảng tính toán cơ học vi mô chi tiết, dựa trên phương pháp trường pha kết hợp với phương pháp phần tử hữu hạn truyền thống để mô tả chính xác vết nứt từ biến mà không cần các thuật toán theo dõi đường nứt (crack tracking) đắt đỏ.

### **Khung Cấu Trúc Trường Pha (Phase-Field Fracture Formulation)**

Mô hình trường pha thay thế bề mặt gián đoạn sắc nét của một vết nứt bằng một dải chuyển tiếp liên tục thông qua một biến vô hướng (scalar damage field) $d in [0,1]$. Ở đây, $d = 0$ đại diện cho vật liệu nguyên vẹn, và d = 1 đại diện cho sự đứt gãy hoàn toàn. Dựa trên khuôn khổ lý thuyết cơ học phá hủy biến phân của Francfort và Marigo, được làm mịn bởi mô hình Ambrosio-Tortorelli (AT-2), tổng năng lượng tự do $\Psi_{total}$ của hệ thống cơ học được xác định là:
$$  
\Psi_{total} = \int_{\Omega} \left[ (1-d)^2 \psi_e(\mathbf{\varepsilon}) + \frac{G_c}{4\ell} (d^2 + \ell^2 |\nabla d|^2) \right] d\Omega
$$
Trong đó, $\psi_e(\mathbf{\varepsilon})$ là mật độ năng lượng đàn hồi, $G_c$ là tỷ lệ giải phóng năng lượng tới hạn (chống lại sự lan truyền vết nứt), và \ell là tham số độ dài chính quy hóa (regularization length) kiểm soát độ rộng của vùng tổn thương khuếch tán.  
Theo công trình nghiên cứu cơ sở của Ragab et al. (2024), sự tiến hóa của tham số tổn thương d trong môi trường từ biến của thép P91 được dẫn động bởi sự tiêu tán năng lượng từ biến và sự cạn kiệt độ dẻo cục bộ. Năng lượng dẫn động phân rã được điều chỉnh bởi một hàm độ dẻo phụ thuộc vào độ ba chiều của ứng suất (stress triaxiality) và lịch sử mỏi. Tốc độ sinh trưởng của vết nứt từ biến tại FGHAZ tương quan rất chặt chẽ với tham số $C^*$ - đại lượng cơ học đứt gãy đặc trưng cho vật liệu không thuần nhất (homogeneous material) hoạt động trong vùng từ biến.

### **Triển Khai Mô Phỏng Số Bằng FEniCSx**

Hệ thống FEniCSx (phiên bản hiện đại hóa của dự án FEniCS) được lựa chọn làm công cụ giải quyết bài toán do khả năng biên dịch ký hiệu các phương trình đạo hàm riêng thông qua Ngôn ngữ Biểu diễn Khối lượng Hợp nhất (UFL). Việc lập trình mô hình cấu thành phi tuyến tính như độ dẻo và đứt gãy trường pha trở nên mạnh mẽ nhờ khả năng tự động tính toán đạo hàm (automatic differentiation) của FEniCSx, giúp sinh ra ma trận độ cứng tiếp tuyến (tangent stiffness matrix) một cách chính xác mà không cần giải tích bằng tay.  
Bài toán đứt gãy trường pha là một hệ phương trình ghép nối phi tuyến mạnh giữa trường chuyển vị \mathbf{u} và trường tổn thương d. FEniCSx áp dụng lược đồ giải xen kẽ (staggered scheme) để đảm bảo độ ổn định hội tụ. Thuật toán bao gồm hai bài toán giá trị biên (Boundary Value Problems \- BVP) được giải tuần tự trong mỗi bước thời gian:

> 1. **Bài toán Đàn hồi \- Từ biến (Elastic-Viscoplastic Sub-problem):** Với trường tổn thương d được giữ cố định từ bước lặp trước, giải tìm trường chuyển vị \mathbf{u} để thỏa mãn phương trình cân bằng động lượng, đồng thời tích phân lịch sử biến dạng từ biến \varepsilon_{cr}.  
> 2. **Bài toán Tổn thương (Damage Sub-problem):** Với trường chuyển vị \mathbf{u} đã được cập nhật, giải tìm biến trường pha d để cực tiểu hóa phiếm hàm năng lượng, chịu sự ràng buộc không thể đảo ngược (irreversibility constraint) d_{n+1} \ge d_n, đảm bảo vết nứt từ biến không tự hàn gắn.

Để thực thi ràng buộc biến phân d_{n+1} \ge d_n, FEniCSx loại bỏ việc sử dụng các kỹ thuật hàm phạt (penalty function) truyền thống vốn gây nhiễu số học. Thay vào đó, nó tận dụng đối tượng dolfinx.fem.petsc.NonlinearProblem liên kết trực tiếp với bộ giải SNES VI (Scalable Nonlinear Equations Solvers \- Variational Inequalities) của PETSc. Bộ giải SNES VI ứng dụng thuật toán tập hợp tích cực (active set method) kết hợp tối ưu hóa có giới hạn (bound-constrained optimization), duy trì độ sắc nét của gradient biên hạt tại vùng đứt gãy.

### **Tích Hợp Mạng Nơ-ron Phần Tử Hữu Hạn (IFENN)**

Dù FEniCSx tối ưu hóa cao độ, việc giải bài toán FEM cho vết nứt trường pha vẫn yêu cầu chia lưới cực mịn (mesh refinement) tại vùng nứt, khiến chi phí thời gian không thể đáp ứng cho thiết kế thời gian thực. Để khắc phục, Giai đoạn 1 sẽ phát triển mô hình Mạng Nơ-ron Phần tử Hữu hạn Tích hợp (IFENN \- Integrated Finite Element Neural Network).  
IFENN kết hợp Mạng Nơ-ron Đồ thị (GNN) để học trực tiếp từ cấu trúc tô-pô của lưới FEM phi cấu trúc. Mỗi nút trên đồ thị tương ứng với một điểm nút (node) của phần tử hữu hạn, và các cạnh đại diện cho sự kết nối hình học. Thông qua cơ chế truyền thông điệp (message passing), GNN thu thập thông tin về ứng suất, độ cạn kiệt độ dẻo, và trường tổn thương d ở các vùng lân cận để trực tiếp suy diễn sự phân bố mới của d mà không cần thực hiện các vòng lặp nghịch đảo ma trận Newton-Raphson đắt đỏ. IFENN hoạt động như một bộ tiền điều hòa (preconditioner) hoặc một bộ giải nội bộ, đảm bảo khả năng mở rộng hình học vô hạn mà vẫn giảm thiểu đáng kể chi phí điện toán.

| Giai Đoạn 1 | Cột Mốc Thời Gian (M0-M8) | Chi Tiết Kỹ Thuật (FEniCSx & IFENN) |
| :---- | :---- | :---- |
| **M0 \- M2** | Khởi tạo mô hình & Thiết lập vật liệu | Thu thập dữ liệu từ biến P91 theo chuẩn Ragab 2024; Định nghĩa hàm UFL cho G_c, \ell và năng lượng. |
| **M3 \- M5** | Tích hợp thuật toán lược đồ xen kẽ | Thiết lập bài toán BVP 1 (Elasticity) và BVP 2 (Damage). Cấu hình SNES VI solver trong PETSc để đảm bảo d_{n+1} \ge d_n. |
| **M6 \- M7** | Huấn luyện bộ mã IFENN (GNN-FEM) | Trích xuất ma trận độ cứng hệ thống \mathbf{K} và vector lực \mathbf{f} từ FEniCSx; Đào tạo GNN theo cấu trúc lưới đồ thị. |
| **M8** | Đánh giá chéo và Nghiệm thu mô hình | Khớp kết quả dự đoán lan truyền nứt Type IV tại vùng FGHAZ với dữ liệu thực nghiệm của thép P91 tại 650°C. |

## **Cơ Sở Nhiệt Động Lực Học Cho Trí Tuệ Nhân Tạo: Bất Đẳng Thức Clausius-Duhem**

Một giới hạn lớn của các mô hình học máy (Machine Learning) truyền thống là hiện tượng "ảo giác" (hallucinations), nơi các dự đoán sai lệch khỏi các quy luật vật lý nền tảng. Lộ trình này giải quyết triệt để rủi ro đó bằng cách ép buộc mô hình tuân thủ tuyệt đối Định luật thứ hai của Nhiệt động lực học, thông qua Bất đẳng thức Clausius-Duhem (Clausius-Duhem inequality).  
Trong khuôn khổ của cơ học môi trường liên tục (continuum mechanics) và quy trình Nhiệt động lực học Hợp lý (Rational Thermodynamics), bất đẳng thức Clausius-Duhem mô tả sự gia tăng entropy không thể đảo ngược trong một hệ thống. Đối với hệ tọa độ tham chiếu, bất đẳng thức được biểu diễn dưới dạng:  
D = \mathbf{P} : \dot{\mathbf{F}} \- \dot{e} \+ T\dot{s} \+ \mathbf{q} \cdot \mathbf{g} \ge 0  
Trong đó, \mathbf{P} là tensor ứng suất Piola-Kirchhoff loại I, \mathbf{F} là gradient biến dạng, e là nội năng, T là nhiệt độ, s là entropy, \mathbf{q} là thông lượng nhiệt và \mathbf{g} là gradient nhiệt độ.  
Đối với quá trình mô phỏng sự tích lũy hư hỏng từ biến tại nhiệt độ không đổi, ta đưa vào hàm năng lượng tự do Helmholtz \psi = e \- Ts. Giả sử trạng thái nhiệt động của vật liệu được định nghĩa đầy đủ bởi biến dạng và một tập hợp các biến trạng thái nội tại \mathbf{z} = \{ \varepsilon^p, \varepsilon^{cr}, d \} đại diện cho biến dạng dẻo, biến dạng từ biến và biến tổn thương trường pha, ta có thể viết lại bất đẳng thức tiêu tán năng lượng nội tại (internal dissipation) như sau:  
D_{int} = \mathbf{P} : \dot{\mathbf{F}} \- \dot{\psi}(\mathbf{F}, \mathbf{z}) \ge 0  
Sử dụng phép khai triển vi phân đạo hàm riêng, điều kiện để bất đẳng thức này luôn đúng (theo thủ tục Coleman-Noll) là ứng suất phải tuân theo quan hệ \mathbf{P} = \frac{\partial \psi}{\partial \mathbf{F}}, và phần tiêu tán năng lượng thu gọn (reduced dissipation) do sự phát triển của các biến nội tại phải luôn dương:  
D_{red} = \- \sum_{\alpha} \frac{\partial \psi}{\partial z_\alpha} \dot{z}_\alpha \ge 0  
Trong phương pháp Học Sâu Dựa Trên Vật Lý (Physics-Informed Deep Learning \- PIDL), sự tương thích nhiệt động lực học này được chuyển đổi trực tiếp thành một thành phần của hàm mất mát (loss function) trong quá trình huấn luyện mạng nơ-ron. Cụ thể, hàm mất mát tổng \mathcal{L}_{total} được cấu trúc như sau:  
\mathcal{L}_{total} = \mathcal{L}_{data} \+ \mathcal{L}_{PDE} \+ \lambda_{CD} \mathcal{L}_{CD}  
Trong đó:

> * \mathcal{L}_{data}: Sai số dữ liệu so với bộ giải chuẩn (ground truth) từ FEniCSx.  
> * \mathcal{L}_{PDE}: Mức độ vi phạm phương trình cân bằng động lượng cục bộ.  
> * \mathcal{L}_{CD}: Ràng buộc Clausius-Duhem, được thiết kế để phạt nặng mạng lưới nếu mô hình dự đoán một trạng thái dẫn đến D_{red} \< 0 (nghĩa là vi phạm định luật II nhiệt động lực học). Hàm phạt thường dùng là một hàm ReLU hoặc Softplus: \mathcal{L}_{CD} = \frac{1}{N} \sum \max(0, \-D_{red})^2. Bằng cách này, mạng lưới học được sự biểu diễn ẩn của năng lượng tự do Helmholtz và tiềm năng tiêu tán (dissipation potential).

## **Giai Đoạn 2: Kiến Trúc Toán Tử Surrogate KANO-GNN Đột Phá (Tháng 9 Trở Đi)**

Bước sang Giai đoạn 2, mô hình tính toán IFENN sẽ được nâng cấp kiến trúc để tạo ra một toán tử đại diện (surrogate operator) hoạt động trong thời gian thực, có khả năng khái quát hóa hoàn toàn cho bất kỳ loại hình dạng học (geometry) và tải trọng (loadings) nào của thiết bị áp lực. Cốt lõi của bước nhảy vọt này là Toán tử Nơ-ron Kolmogorov-Arnold (KANO).

### **Hạn Chế Của Toán Tử Fourier (FNO) Và Sự Ra Đời Của KANO**

Các mô hình toán tử nơ-ron truyền thống như Fourier Neural Operator (FNO) thường gặp phải trở ngại lớn mang tên "tắc nghẽn phổ" (spectral bottleneck). Khi lập mô hình đứt gãy từ biến, các vùng lân cận đầu vết nứt (crack tip) xuất hiện độ dốc ứng suất (gradient) cực lớn, tạo ra các trường tín hiệu phi tuyến tính cao và phụ thuộc vị trí. Để mô tả những gián đoạn này, FNO đòi hỏi các mode Fourier tần số cao, kéo theo chi phí tính toán bùng nổ theo hàm đa thức và làm suy giảm sự hội tụ. Hơn nữa, việc sử dụng các hàm kích hoạt tuyến tính tĩnh khiến mô hình MLP/PINN truyền thống trở thành những hộp đen thiếu khả năng diễn giải.  
Toán tử Nơ-ron Kolmogorov-Arnold (KANO), được công bố tại hội nghị ICLR 2026 bởi Lee et al., vượt qua rào cản này bằng một cách tiếp cận hoàn toàn khác biệt. KANO là một toán tử nơ-ron hoạt động trên miền kép (dual-domain), kết hợp đồng thời sự tham số hóa trên cả cơ sở phổ (spectral bases) và cơ sở không gian (spatial bases).  
Kiến trúc này được truyền cảm hứng từ Định lý biểu diễn Kolmogorov-Arnold, chứng minh rằng bất kỳ hàm đa biến liên tục nào cũng có thể được biểu diễn chính xác thông qua sự kết hợp hữu hạn của các hàm đơn biến liên tục. Công thức cốt lõi được phát biểu:  
f(\mathbf{x}) = \sum_{q=1}^{2n+1} \Phi_q \left( \sum_{p=1}^n \psi_{q,p}(x_p) \right)  
Trong đó f: \[0,1\]^n \rightarrow \mathbb{R} là một hàm trơn, và \psi_{q,p}, \Phi_q là các hàm kích hoạt. Không giống như các Mạng Nơ-ron truyền thống đặt các hàm kích hoạt (như ReLU, Sigmoid) tại các điểm nút (nodes), KANO phân bổ các hàm kích hoạt học được (learnable activation functions) trực tiếp lên các **kết nối (edges)** giữa các nút.

### **Giải Mã Tượng Trưng (Symbolic Interpretability) Và Cơ Chế Hoạt Động**

Đặc tính vượt trội của KANO trong cơ học đứt gãy là sự khai thác các biểu diễn thưa (sparse representations) ở cả miền không gian và miền phổ. Sự phân tích miền kép giúp tách biệt sai số chiếu hình (\epsilon_{proj}) và sai số mạng lưới (\epsilon_{net}), vì nó không bao giờ áp dụng ma trận nhân chập đặc (dense convolution). Thay vì phải tính toán hàng triệu điểm tích phân để đánh giá các hàm phi tuyến, KANO giữ sai số tổng quát hóa cực nhỏ ngay cả trên các bộ dữ liệu kích thước giới hạn.  
Bên cạnh đó, quá trình tối ưu hóa các thành phần của mạng lưới tuân thủ phương pháp Nhân tử Đa hướng Luân phiên (ADMM \- Alternating Direction Method of Multipliers), hướng lộ trình tối ưu hóa đi theo những ưu tiên về cấu trúc vật lý đã định sẵn. Bằng cách học trực tiếp trên các liên kết, người dùng có thể trực quan hóa và khai phá các biểu thức toán học khép kín (closed-form symbolic formulas) quy định tốc độ hao mòn độ dẻo từ mô hình. Điều này mang lại khả năng diễn giải ký hiệu (symbolic interpretability), cho phép các chuyên gia vật liệu dễ dàng đánh giá, chỉnh sửa và xác nhận lý thuyết luyện kim đằng sau thuật toán AI, biến "hộp đen" thành một phương trình minh bạch. Kết hợp với mạng GNN để tiếp thu cấu trúc biên hình học (topology), hệ thống KANO-GNN giải quyết hoàn hảo bài toán biên phức tạp của mối hàn, cung cấp độ chính xác tiệm cận mô phỏng vi phân trực tiếp (DNS) nhưng nhanh hơn gấp nhiều lần.

## **Ứng Dụng Đánh Giá FFS: API 579-1/ASME FFS-1 Và BS 7910**

Đỉnh cao của lộ trình phát triển là việc ứng dụng hệ thống KANO-GNN mô phỏng thời gian thực này vào quy trình Đánh giá Tính Phù hợp với Dịch vụ (Fitness-For-Service \- FFS) trong các hệ thống công nghiệp. Hai bộ tiêu chuẩn nền tảng được hướng đến là API 579-1/ASME FFS-1 của Viện Dầu khí Hoa Kỳ và BS 7910 của Viện Tiêu chuẩn Anh.

### **Đánh Giá API 579-1/ASME FFS-1: Phân Tích Cấp Độ 3 (Level 3 Assessment)**

Tiêu chuẩn API 579-1/ASME FFS-1 cung cấp các quy trình toàn diện để đánh giá tuổi thọ còn lại của các thiết bị có áp lực. Part 9 của tiêu chuẩn được sử dụng để đánh giá các khuyết tật dạng nứt (crack-like flaws), trong khi Part 10 đánh giá sự hư hỏng từ biến (Creep Damage). Tiêu chuẩn chia các phân tích thành ba cấp độ (Level 1, 2 và 3), trong đó Cấp độ 1 và 2 dựa trên các công thức bảo thủ đơn giản (như đo đạc độ dày bị mất và so sánh với nhiệt độ cho phép).  
Tuy nhiên, đối với mối hàn đa vùng P91 hoạt động ở chế độ từ biến dài hạn, Cấp độ 1 và 2 thường quá bảo thủ, buộc kỹ sư phải chuyển sang Đánh giá Cấp độ 3 (Level 3 Assessment). Cấp độ 3 yêu cầu sử dụng kỹ thuật phân tích ứng suất nâng cao bằng phương pháp phần tử hữu hạn (như mô hình KANO-GNN) để đánh giá trạng thái tái phân bố ứng suất do từ biến và độ dẻo tại các vị trí không liên tục về hình học.  
Quy trình tự động hóa dựa trên KANO-GNN sẽ thực hiện:

> 1. **Dự đoán Lịch sử Thiệt hại:** Tính toán lượng tổn thương từ biến tích lũy tổng cộng D_{c}^{total} cho mỗi chu kỳ hoạt động và so sánh nó với giới hạn cho phép (D_{c}^{allow} = 1.0).  
> 2. **Đánh giá Phát triển Nứt (Creep Crack Growth):** Dựa trên hàm tổn thương trường pha d, KANO-GNN xuất thông số tốc độ sinh trưởng của nứt và liên hệ với tham số cơ học phá hủy C^\*.  
> 3. **Hành động Quyết định (What-if Analysis):** Với tốc độ mô phỏng theo thời gian thực của KANO, kỹ sư có thể thử nghiệm tạo mẫu ảo (virtual prototyping) cho hàng trăm kịch bản áp suất và nhiệt độ trong vài phút để đưa ra quyết định: Thay đổi thông số vận hành (Rerate), sửa chữa (Repair), thay thế (Replace) hay loại bỏ cấu kiện (Retire).

### **Đánh Giá BS 7910 Và Biểu Đồ FAD (Failure Assessment Diagram)**

Song song với hệ thống của Hoa Kỳ, BS 7910 là "Hướng dẫn về các phương pháp đánh giá khả năng chấp nhận các khuyết tật ở các cấu trúc kim loại" của Vương quốc Anh, được sử dụng rộng rãi toàn cầu. Trong bản sửa đổi kết hợp phương pháp R5 và R6, BS 7910 đã phát triển Điều 9 (Clause 9\) chuyên biệt để đánh giá tính toàn vẹn của kết cấu có rạn nứt từ biến.  
BS 7910 sử dụng kỹ thuật Biểu đồ Đánh giá Hư hỏng (Failure Assessment Diagram \- FAD). Trục hoành của biểu đồ đánh giá tải trọng tỷ lệ (sụp đổ dẻo dập \- plastic collapse) và trục tung đánh giá tỷ lệ cường độ ứng suất (đứt gãy giòn \- brittle fracture). Khi tích hợp KANO-GNN vào hệ thống này, các điểm dữ liệu lịch sử trạng thái (K_r, L_r) từ các dây chằng (ligaments) bị phá hủy do cạn kiệt độ dẻo tại vùng FGHAZ sẽ được xuất ra ở mọi thời điểm.  
Hệ thống surrogate KANO-GNN khắc phục được điểm mù lớn nhất của BS 7910: thay vì giả định hình thái và vận tốc phát triển hình học của vết nứt, biến trường pha d theo thời gian vẽ ra chính xác cấu hình nứt vật lý 3D cục bộ, sau đó tự động cung cấp thông số để đối chiếu với quỹ đạo FAD, định vị chính xác thời điểm ranh giới an toàn của vòng đời cấu trúc (end of life) bị vượt qua.

| So Sánh Tính Năng | Hệ Thống Surrogate KANO-GNN Tích Hợp (Đề Xuất) | API 579-1 / ASME FFS-1 Level 3 (Part 9, 10\) | BS 7910 (Clause 9, FAD) |
| :---- | :---- | :---- | :---- |
| **Mô phỏng Nứt Đa Vùng P91** | Mô phỏng tự động nứt loại IV tại FGHAZ dựa trên cạn kiệt độ dẻo. | Đòi hỏi tham số mô phỏng từ biến chi tiết (như Omega) cho tính toán. | Đánh giá lan truyền nứt phụ thuộc vào phương pháp tham số C^\*. |
| **Tốc độ Xử lý tính toán** | Thời gian thực (Real-time), giải quyết qua biểu diễn học sâu miền kép. | Phân tích FEM đa trục rất chậm và đắt đỏ (vài giờ/ngày). | Tính toán tĩnh hoặc cập nhật đồ thị thời gian tuần tự (chậm). |
| **Tính Vật lý và An toàn** | Đảm bảo entropy dương (Clausius-Duhem) qua hàm penalty loss. | Yêu cầu thẩm định FEM nghiêm ngặt. | Giới hạn bởi đồ thị FAD; cảnh báo khi L_r hoặc K_r vượt bao hình. |
| **Cơ chế Ra quyết định** | Tối ưu hóa vận hành What-if / Virtual prototyping tức thì. | Xuất kết luận D_c^{total} \le 1.0 (Rerate/Repair/Retire). | Cung cấp thông số an toàn dựa trên FAD cuối chu kỳ. |

## **Kết Luận và Khuyến Nghị Chuyển Giao**

Lộ trình phát triển được đề xuất thiết lập một hệ thống công nghệ toàn diện nhằm giải quyết sự suy giảm toàn vẹn cấu trúc trong môi trường từ biến nhiệt độ cao, đặc biệt đối với các hiện tượng biến đổi đa vùng (multi-zone) phức tạp tại mối hàn thép P91. Giai đoạn đầu tiên, thiết lập cấu trúc GNN-FEM giải quyết đứt gãy trường pha thông qua FEniCSx (Ragab 2024 baseline), cung cấp tính toán có độ chính xác vi cơ học. Giai đoạn thứ hai, sự chuyển mình lên cấu trúc Toán tử Surrogate KANO-GNN, loại bỏ nút thắt tính toán, đảm bảo tính diễn dịch minh bạch bằng toán học và sự tuân thủ vô điều kiện đối với định luật nhiệt động lực học Clausius-Duhem.  
Đối với các thực thể điều hành năng lượng và luyện kim công nghiệp, sự chuyển đổi sang mô phỏng thời gian thực này mang lại năng lực vượt trội trong việc phân tích rủi ro giả định (What-if analysis) và thiết lập mô hình tạo mẫu ảo (virtual prototyping). Năng lực dự đoán thời gian thực này giúp đánh giá Đảm bảo Dịch vụ (FFS) theo bộ tiêu chuẩn API 579-1 và BS 7910 được đưa ra một cách nhanh chóng, tiết kiệm hàng triệu đô-la chi phí do các vụ sụp đổ bất ngờ do từ biến hoặc các khoảng thời gian dừng máy (downtime) không cần thiết, đánh dấu bước chuyển mình quan trọng vào thời đại công nghệ số hóa thiết kế cấu trúc chịu lực.