# | Ký hiệu dùng trong dự án | Ý nghĩa | Đơn vị |
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

**Giả thiết dự án** nu=0.3 hoặc plasticity lý tưởng.

Sổ dữ liệu cần các cột: tham số; giá trị gốc; đơn vị gốc; điều kiện; trang/bảng/phương trình; giá trị trong code; phép đổi đơn vị; đã đo/đã fit/giả thiết; miền áp dụng.

# 2. Quyết định mô hình:
Stress dùng cho Norton và Cocks–Ashby; hardening; regularisation ở sigma_eq≈0 và eta_tr thấp; quy tắc D đạt 1; history/bounds cho d; cách tạo vết nứt đầu; dạng PF; quy ước viscosity. Nếu bản công bố không đủ rõ, ghi giả thiết, liên hệ nguồn/subroutine khi có thể và kiểm tra nhạy.