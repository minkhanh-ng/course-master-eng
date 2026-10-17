# 

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

Dùng mm–N–MPa–giờ xuyên suốt. Không lấy nguyên A với thời gian giây. Không dùng tên eta cho cả viscosity và triaxiality. Tensor biến dạng nhỏ là 3×3 kể cả khi chuyển vị mô hình 2D; thành phần out-of-plane cần xử lý theo giả thiết cơ học.

# 1. Material properties table

| Tham số P91 | Giá trị | Nguồn/trạng thái |
|---|---:|---|
| T | 650 °C | Ragab 2024, Bảng 2 |
| E | 132000 MPa | Bảng 2 |
| Sy | 262 MPa | Bảng 2|
| A | 1.762e-14 $MPa^(-n) h^(-1)$ | Bảng 2; fit tốc độ creep trung bình |
| n | 5.58 | Bảng 2 |
| eps_f | 0.28 | Bảng 2 |
| Gc0 | 100 N/mm | Bảng 2; giá trị đã hiệu chỉnh |
| v | 1 | Bảng 2 |
| beta0 | 0.01 | Bảng 2 |
| ell | 0.4 mm thanh khía; 0.6 mm CT | Mục 4.2 và 5.1; không phải một ell dùng xuyên mọi mẫu |
| k0 | 1e-6 | Mục 2.1.2.1 |
| mu_pf | 1e-3 trong phân tích thanh khía | Mục 4.2; cần xác nhận quy ước thời gian/đơn vị triển khai |
| nu | 0.3 | **Giả thiết dự án** |
| Luật hardening | Perfectly - Plastic | **Giả thiết dự án** |

**Giả thiết Dẻo lý tưởng (Perfect Plasticity) - RẤT KHUYÊN DÙNG**
Đây là cách an toàn, dễ code nhất cho FEniCSx và phù hợp với yêu cầu của Assignment.Mô hình: Elastic - Perfectly Plastic.Thông số: Ứng suất chảy $S_y = 262$ MPa (giữ cố định, không tăng lên khi biến dạng). Mô đun tiếp tuyến (Tangent Modulus) $E_T = 0$.Lưu ý code: Để tránh lỗi ma trận kỳ dị (singular matrix) trong FEniCSx khi đường cong ứng suất nằm ngang, người ta thường dùng một Mô đun tiếp tuyến giả rất nhỏ, ví dụ: $E_T = \frac{E}{1000} \approx 132$ MPa. Decision log: "Sử dụng giả thiết Perfect Plasticity với $E_T \approx 0$ để phục vụ mô hình hóa ban đầu."

| Tham số | Ký hiệu | Giá trị gốc | Đơn vị | Nguồn / Vị trí | Giá trị Code | Đổi đơn vị | Phân loại | Điều kiện / Miền áp dụng |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Nhiệt độ** | $T$ | $650$ | $^\circ\text{C}$ | Ragab 2024, Bảng 2 | $650.0$ | Giữ nguyên | Thực nghiệm | Nhiệt độ mô phỏng đẳng nhiệt |
| **Mô đun đàn hồi** | $E$ | $132000$ | $\text{MPa}$ | Ragab 2024, Bảng 2 | $132000.0$ | Giữ nguyên | Đã đo | Biến dạng đàn hồi nhỏ |
| **Hệ số Poisson** | $\nu$ | $0.3$ | $1$ | DeSantis, Bảng 3.2 | $0.3$ | Giữ nguyên | **Giả thiết** | Ma trận đàn hồi đẳng hướng |
| **Giới hạn chảy** | $S_y$ | $262$ | $\text{MPa}$ | Ragab 2024, Bảng 2 | $262.0$ | Giữ nguyên | Đã đo | Điểm khởi phát dẻo |
| **Biến cứng dẻo** | $E_T$ | N/A | $\text{MPa}$ | Lựa chọn dự án | $\approx 0.0$ | N/A | **Giả thiết** | Dẻo lý tưởng (Perfectly-Plastic) |
| **Hệ số từ biến** | $A$ | $1.762\text{e-}14$ | $\text{MPa}^{-n}\text{h}^{-1}$ | Ragab 2024, Bảng 2 | $1.762\text{e-}14$ | Giữ nguyên | Đã fit | Từ biến Norton thứ cấp |
| **Số mũ từ biến** | $n$ | $5.58$ | $1$ | Ragab 2024, Bảng 2 | $5.58$ | Giữ nguyên | Đã fit | Từ biến Norton thứ cấp |
| **Độ dẻo giới hạn** | $\varepsilon_f$ | $0.28$ | $1$ | Ragab 2024, Bảng 2 | $0.28$ | Giữ nguyên | Đã fit | Mô hình cạn kiệt độ dẻo |
| **Năng lượng nứt** | $G_{c0}$ | $100$ | $\text{N/mm}$ | Ragab 2024, Bảng 2 | $100.0$ | Giữ nguyên | Đã hiệu chỉnh | Sức kháng nứt cơ sở |
| **Mũ hàm suy giảm** | $v$ | $1$ | $1$ | Ragab 2024, Bảng 2 | $1.0$ | Giữ nguyên | Đã fit | Khớp hàm độ dẻo dai phá hủy |
| **Hệ số bền dư** | $\beta_0$ | $0.01$ | $1$ | Ragab 2024, Bảng 2 | $0.01$ | Giữ nguyên | Đã hiệu chỉnh | Giới hạn $\mathcal{G}_{eff}$ tối thiểu |
| **Hệ số nhiễu** | $k_0$ | $1\text{e-}6$ | $1$ | Ragab 2024, Mục 2.1 | $1\text{e-}6$ | Giữ nguyên | Thuật toán | Ngăn ma trận độ cứng suy biến |
| **Chiều dài PF** | $\ell$ | $0.4 / 0.6$ | $\text{mm}$ | Ragab 2024, Mục 4, 5 | Tùy bài toán | Giữ nguyên | Thuật toán | $0.4$ (thanh khía); $0.6$ (mẫu CT) |
| **Độ nhớt chuẩn** | $\mu_{pf}$ | $1\text{e-}3$ | $\text{h/mm}^2$ | Ragab 2024, Mục 4.2 | $1\text{e-}3$ | Giữ nguyên | Thuật toán | Ổn định đạo hàm vết nứt |

# 2. Quyết định mô hình:
Stress dùng cho Norton và Cocks–Ashby; hardening; regularisation ở sigma_eq≈0 và eta_tr thấp; quy tắc D đạt 1; history/bounds cho d; cách tạo vết nứt đầu; dạng PF; quy ước viscosity. Nếu bản công bố không đủ rõ, ghi giả thiết, liên hệ nguồn/subroutine khi có thể và kiểm tra nhạy.