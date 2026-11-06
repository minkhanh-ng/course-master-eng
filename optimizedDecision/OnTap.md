# TÀI LIỆU ÔN TẬP THI CUỐI KỲ: MÔN TỐI ƯU HOÁ TOÁN HỌC (GK5045)

**Thời gian làm bài:** 90 phút | **Được sử dụng tài liệu**

---

## BẢNG TRA CỨU CÔNG THỨC TRỌNG TÂM (EXAM CHEATSHEET)

| Bài toán | Phương pháp chính | Công thức / Điều kiện cốt lõi |
| :--- | :--- | :--- |
| **B1. Tối ưu đơn biến** | Phương pháp Newton | \(x^{(k+1)} = x^{(k)} - \frac{f'(x^{(k)})}{f''(x^{(k)})}\)<br>với điều kiện dừng \(\|f'(x^{(k)})\| \le \epsilon\) |
| **B2. Mô hình hóa LP** | Lập bài toán sản xuất | \(\text{Maximize } Z = \sum_{j=1}^n c_j x_j\)<br>thỏa \(\sum_{j=1}^n a_{ij} x_j \le b_i \; (i=1..m)\) và \(x_j \ge 0\) |
| **B3. Tối ưu LP** | Thuật toán Đơn hình (Simplex) | Tỷ số chọn biến ra: \(\theta = \min_{i} \left\{ \frac{b_i}{a_{i, \text{in}}} \;\Big\vert\; a_{i, \text{in}} > 0 \right\}\) |
| **B4. Ràng buộc đa biến** | Nhân tử Lagrange & KKT | \(\nabla L(\mathbf{x}, \boldsymbol{\lambda}, \boldsymbol{\mu}) = \mathbf{0}\)<br>\(g_i(\mathbf{x}) = 0;\; h_k(\mathbf{x}) \le 0;\; \mu_k \ge 0;\; \mu_k \cdot h_k(\mathbf{x}) = 0\) |

---

## BÀI 1 (B1): TỐI ƯU HOÁ HÀM ĐƠN BIẾN BẰNG PHƯƠNG PHÁP NEWTON

### 1.1. Cơ sở Lý thuyết & Bản chất Thuật toán

Bài toán xét việc tìm điểm cực trị (cực tiểu hoặc cực đại) của hàm đơn biến không ràng buộc \(f(x)\) trên tập số thực.

Điều kiện cần cấp 1 cho cực trị là đạo hàm bằng 0: \(f'(x^*) = 0\). Phương pháp Newton chuyển bài toán tìm cực trị của \(f(x)\) thành bài toán tìm nghiệm của phương trình phi tuyến \(f'(x) = 0\).

Khai triển Taylor cấp 2 của hàm \(f(x)\) xung quanh điểm xấp xỉ hiện tại \(x^{(k)}\):
\[
f(x) \approx f(x^{(k)}) + f'(x^{(k)})(x - x^{(k)}) + \frac{1}{2}f''(x^{(k)})(x - x^{(k)})^2
\]

Đạo hàm theo \(x\) và cho bằng 0 để tìm điểm cực trị của hàm xấp xỉ bậc hai:
\[
f'(x^{(k)}) + f''(x^{(k)})(x - x^{(k)}) = 0 \implies x = x^{(k)} - \frac{f'(x^{(k)})}{f''(x^{(k)})}
\]

Đây chính là **Công thức lặp Newton**:
\[
x^{(k+1)} = x^{(k)} - \frac{f'(x^{(k)})}{f''(x^{(k)})}
\]

### 1.2. Quy trình Thực hành 4 Bước Trên Giấy Thi

1. **Bước 1 (Đạo hàm):** Tính đạo hàm cấp 1 \(f'(x)\) và đạo hàm cấp 2 \(f''(x)\).
2. **Bước 2 (Khởi tạo):** Xác định giá trị xấp xỉ ban đầu \(x^{(0)}\) và sai số cho phép \(\epsilon\) (ví dụ \(\epsilon = 10^{-3}\) hoặc theo yêu cầu đề bài).
3. **Bước 3 (Thực hiện vòng lặp \(k = 0, 1, 2, \dots\)):**
   * Tính giá trị \(f'(x^{(k)})\) và \(f''(x^{(k)})\).
   * **Kiểm tra điều kiện dừng:** Nếu \(|f'(x^{(k)})| \le \epsilon\) thì dừng lặp, kết luận \(x^* \approx x^{(k)}\).
   * Nếu chưa đạt, tính điểm tiếp theo: \(x^{(k+1)} = x^{(k)} - \frac{f'(x^{(k)})}{f''(x^{(k)})}\).
4. **Bước 4 (Kết luận):** Báo cáo nghiệm tối ưu \(x^*\) và giá trị cực trị \(f(x^*)\). Kiểm tra \(f''(x^*) > 0\) (cực tiểu) hoặc \(f''(x^*) < 0\) (cực đại).

### 1.3. Ví dụ Minh họa Chi tiết

**Đề bài:** Tìm điểm cực tiểu của hàm số \(f(x) = x^4 - 4x^2 + 4x + 1\) bằng phương pháp Newton với điểm xuất phát \(x^{(0)} = 2.0\) và sai số cho phép \(\epsilon = 10^{-3}\).

**Bài giải:**

* Tính đạo hàm cấp 1 và cấp 2: 
  \(f'(x) = 4x^3 - 8x + 4\)
  \(f''(x) = 12x^2 - 8\)

* **Lần lặp \(k = 0\):**
  * \(x^{(0)} = 2.0\)
  * \(f'(2.0) = 4(2.0)^3 - 8(2.0) + 4 = 32 - 16 + 4 = 20.0\)
  * Kiểm tra điều kiện dừng: \(|f'(x^{(0)})| = 20.0 > 10^{-3} \implies\) Tiếp tục lặp.
  * \(f''(2.0) = 12(2.0)^2 - 8 = 48 - 8 = 40.0\)
  * Cập nhật điểm mới: \(x^{(1)} = 2.0 - \frac{20.0}{40.0} = 2.0 - 0.5 = 1.5\)

* **Lần lặp \(k = 1\):**
  * \(x^{(1)} = 1.5\)
  * \(f'(1.5) = 4(1.5)^3 - 8(1.5) + 4 = 13.5 - 12 + 4 = 5.5\)
  * \(|f'(x^{(1)})| = 5.5 > 10^{-3} \implies\) Tiếp tục lặp.
  * \(f''(1.5) = 12(1.5)^2 - 8 = 27 - 8 = 19.0\)
  * Cập nhật điểm mới: \(x^{(2)} = 1.5 - \frac{5.5}{19.0} \approx 1.5 - 0.28947 = 1.21053\)

* **Lần lặp \(k = 2\):**
  * \(x^{(2)} = 1.21053\)
  * \(f'(1.21053) = 4(1.21053)^3 - 8(1.21053) + 4 \approx 7.0955 - 9.6842 + 4 = 1.4113\)
  * \(|f'(x^{(2)})| = 1.4113 > 10^{-3} \implies\) Tiếp tục lặp.
  * \(f''(1.21053) = 12(1.21053)^2 - 8 \approx 17.5846 - 8 = 9.5846\)
  * Cập nhật điểm mới: \(x^{(3)} = 1.21053 - \frac{1.4113}{9.5846} \approx 1.21053 - 0.14725 = 1.06328\)

* **Lần lặp \(k = 3\):**
  * \(x^{(3)} = 1.06328\)
  * \(f'(1.06328) \approx 0.1583\)
  * \(f''(1.06328) \approx 5.5662\)
  * \(x^{(4)} = 1.06328 - \frac{0.1583}{5.5662} \approx 1.03484\)

Tốc độ hội tụ của phương pháp Newton là bậc hai (quadratic convergence). Sau một số bước lặp tiếp theo, chuỗi điểm hội tụ về \(x^* = 1.0\) (tại đây \(f'(1) = 4(1)^3 - 8(1) + 4 = 0\) và \(f''(1) = 4 > 0\)).

---

## BÀI 2 (B2): XÂY DỰNG MÔ HÌNH TOÁN HỌC TỐI ƯU TỪ QUÁ TRÌNH SẢN XUẤT

### 2.1. Quy trình 4 Bước Lập Mô hình Tối ưu

Để chuyển đổi một bài toán quản lý/sản xuất thực tế thành mô hình Quy hoạch tuyến tính (LP), áp dụng đúng 4 bước chuẩn hóa:

1. **Bước 1: Xác định Biến quyết định (Decision Variables)**
   Đặc tả rõ ràng các đại lượng cần tìm. Đặt \(x_j\) là số lượng đơn vị sản phẩm/mặt hàng loại \(j\) (\(j = 1, 2, \dots, n\)) được sản xuất trong kỳ.
2. **Bước 2: Xác định Hàm mục tiêu (Objective Function)**
   Biểu diễn chỉ tiêu kinh tế cần tối ưu (thường là Tối đa hóa Lợi nhuận \(Z\) hoặc Tối thiểu hóa Chi phí \(C\)) dưới dạng hàm tuyến tính của các biến quyết định:
   \[
\text{Maximize } Z = c_1 x_1 + c_2 x_2 + \dots + c_n x_n = \sum_{j=1}^n c_j x_j
\]
3. **Bước 3: Xác định Các Ràng buộc Tài nguyên (Resource Constraints)**
   Biểu diễn các hạn chế về tài nguyên (nguyên vật liệu, thời gian máy, nhân công, ngân sách, dung lượng thị trường) dưới dạng hệ bất đẳng thức hoặc phương trình tuyến tính:
   \[
\sum_{j=1}^n a_{ij} x_j \le b_i \quad (i = 1, 2, \dots, m)
\]
   trong đó \(a_{ij}\) là định mức tiêu hao tài nguyên \(i\) cho một đơn vị sản phẩm \(j\), và \(b_i\) là giới hạn tối đa của tài nguyên \(i\).
4. **Bước 4: Điều kiện Phi âm (Non-negativity Constraints)**
   Các biến sản lượng thực tế không thể nhận giá trị âm:
   \[
x_j \ge 0 \quad \forall j = 1, 2, \dots, n
\]

### 2.2. Ví dụ Mô hình hóa Chi tiết Bài toán Sản xuất

**Đề bài:** Một nhà máy sản xuất 3 loại sản phẩm A, B, C. Quá trình sản xuất tiêu thụ 2 loại nguyên liệu thô (NL1, NL2) và thời gian gia công trên máy. Định mức tiêu hao, giới hạn tài nguyên và lợi nhuận đơn vị được cho trong bảng sau:

| Tài nguyên / Chỉ tiêu | Sản phẩm A (\(x_1\)) | Sản phẩm B (\(x_2\)) | Sản phẩm C (\(x_3\)) | Hạn mức tài nguyên khả dụng |
| :--- | :---: | :---: | :---: | :---: |
| Nguyên liệu NL1 (kg) | 2 | 1 | 3 | 150 kg |
| Nguyên liệu NL2 (kg) | 1 | 2 | 1 | 120 kg |
| Giờ công máy (giờ) | 1 | 1 | 2 | 100 giờ |
| Lợi nhuận đơn vị (tr.đ) | 4 | 5 | 6 | — |

Ngoài ra, do hợp đồng bao tiêu, tổng số lượng sản phẩm A và B sản xuất ra phải đạt ít nhất 20 đơn vị. Hãy lập bài toán quy hoạch tuyến tính.

**Bài giải chi tiết:**

* **Bước 1: Gọi biến quyết định:**
  * \(x_1\): Số lượng sản phẩm A cần sản xuất (\(x_1 \ge 0\)).
  * \(x_2\): Số lượng sản phẩm B cần sản xuất (\(x_2 \ge 0\)).
  * \(x_3\): Số lượng sản phẩm C cần sản xuất (\(x_3 \ge 0\)).
* **Bước 2: Xây dựng Hàm mục tiêu:** Tổng lợi nhuận thu được là \(Z = 4x_1 + 5x_2 + 6x_3\) (triệu đồng). Mục tiêu là tối đa hóa lợi nhuận: \(\text{Maximize } Z = 4x_1 + 5x_2 + 6x_3\)
* **Bước 3: Thiết lập hệ Ràng buộc:**
  * Ràng buộc Nguyên liệu NL1: \(2x_1 + 1x_2 + 3x_3 \le 150\)
  * Ràng buộc Nguyên liệu NL2: \(1x_1 + 2x_2 + 1x_3 \le 120\)
  * Ràng buộc Giờ công máy: \(1x_1 + 1x_2 + 2x_3 \le 100\)
  * Ràng buộc Hợp đồng cam kết tối thiểu: \(x_1 + x_2 \ge 20\)
* **Bước 4: Ràng buộc phi âm:** \(x_1 \ge 0, \quad x_2 \ge 0, \quad x_3 \ge 0\)

**Phát biểu Hoàn chỉnh Mô hình LP (Primal Problem):**
\[
\begin{aligned}
\text{Maximize } \quad & Z = 4x_1 + 5x_2 + 6x_3 \\
\text{Subject to: } \quad & 2x_1 + x_2 + 3x_3 \le 150 \\
& x_1 + 2x_2 + x_3 \le 120 \\
& x_1 + x_2 + 2x_3 \le 100 \\
& x_1 + x_2 \ge 20 \\
& x_1, x_2, x_3 \ge 0
\end{aligned}
\]

---

## BÀI 3 (B3): TỐI ƯU HOÁ QUY HOẠCH TUYẾN TÍNH BẰNG PHƯƠNG PHÁP ĐƠN HÌNH (SIMPLEX METHOD)

### 3.1. Chuyển Bài toán về Dạng Chính tắc (Canonical Form)

Để giải bài toán LP bằng Thuật toán Đơn hình, cần đưa bài toán bất đẳng thức dạng chuẩn về dạng phương trình chính tắc bằng cách thêm các biến bù / biến nới (Slack variables) \(s_i \ge 0\).

Bài toán tổng quát dạng Maximize:
\[
\text{Maximize } Z = \mathbf{c}^T \mathbf{x} \quad \text{thỏa } \mathbf{A}\mathbf{x} \le \mathbf{b}, \; \mathbf{x} \ge \mathbf{0}
\]

Chuyển thành dạng chính tắc:
\[
\mathbf{A}\mathbf{x} + \mathbf{I}\mathbf{s} = \mathbf{b}, \quad \mathbf{x} \ge \mathbf{0}, \; \mathbf{s} \ge \mathbf{0}
\]

### 3.2. Quy trình Thuật toán Đơn hình (Simplex Algorithm Steps)

1. **Bước 1 (Lập Bảng Đơn hình ban đầu):**
   * Các biến bù \(s_1, s_2, \dots, s_m\) tạo thành Hệ biến cơ sở ban đầu (Initial Basic Variables) với các cột đơn vị.
   * Hàng đánh giá (Hàng \(Z\) hay Reduced Costs): \(C_j = c_j - z_j\) hoặc biểu diễn dòng mục tiêu dưới dạng \(Z - \sum c_j x_j = 0\).
2. **Bước 2 (Kiểm tra Điều kiện Tối ưu):**
   * Bài toán Maximize: Nếu tất cả các hệ số trên dòng \(Z\) tương ứng với các biến không cơ sở đều \(\ge 0\) (hoặc mọi chỉ số \(c_j - z_j \le 0\) tùy theo ký hiệu quy ước), phương án hiện tại là Tối ưu. Dừng thuật toán.
3. **Bước 3 (Chọn Biến vào cơ sở - Entering Variable):**
   * Chọn biến có hệ số âm nhất trên dòng \(Z\) (hoặc \(c_j - z_j\) dương lớn nhất) làm biến vào cơ sở. Cột tương ứng gọi là Cột xoay (Pivot Column).
4. **Bước 4 (Chọn Biến ra khỏi cơ sở - Leaving Variable):**
   * Áp dụng Quy tắc Tỷ số Tối thiểu (Minimum Ratio Test) để xác định biến phải rời khỏi cơ sở:
     \[
\theta = \min_{i} \left\{ \frac{b_i}{a_{i, \text{in}}} \;\Big|\; a_{i, \text{in}} > 0 \right\}
\]
   * Hàng đạt giá trị nhỏ nhất \(\theta\) gọi là Hàng xoay (Pivot Row). Giao của cột xoay và hàng xoay là Phần tử xoay (Pivot Element) \(a_{p, q}\).
5. **Bước 5 (Thực hiện Biến đổi Gauss-Jordan - Pivoting):**
   * Chia toàn bộ Hàng xoay cho phần tử xoay \(a_{p, q}\) để biến phần tử xoay thành 1.
   * Biến đổi các hàng còn lại (bao gồm cả hàng mục tiêu \(Z\)) sao cho tất cả các phần tử khác trên Cột xoay đều trở thành 0.
   * Cập nhật biến cơ sở mới và quay lại Bước 2.

### 3.3. Ví dụ Giải Chi tiết Bằng Bảng Đơn hình

**Đề bài:** Giải bài toán quy hoạch tuyến tính sau bằng Phương pháp Đơn hình:
\[
\begin{aligned}
\text{Maximize } \quad & Z = 3x_1 + 5x_2 \\
\text{Subject to: } \quad & x_1 \le 4 \\
& 2x_2 \le 12 \\
& 3x_1 + 2x_2 \le 18 \\
& x_1, x_2 \ge 0
\end{aligned}
\]

**Bài giải:**

* **Chuyển về Dạng Chính tắc:** Thêm các biến bù \(s_1, s_2, s_3 \ge 0\):
  \[
  \begin{aligned}
  Z - 3x_1 - 5x_2 + 0s_1 + 0s_2 + 0s_3 &= 0 \\
  x_1 + s_1 &= 4 \\
  2x_2 + s_2 &= 12 \\
  3x_1 + 2x_2 + s_3 &= 18
  \end{aligned}
  \]

* **Bảng Đơn hình 1 (Khởi tạo):**

| Biến CS | \(Z\) | \(x_1\) | \(x_2\) | \(s_1\) | \(s_2\) | \(s_3\) | Phương án (\(b\)) | Tỷ số \(\theta\) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Z** | 1 | -3 | **-5** | 0 | 0 | 0 | 0 | — |
| \(s_1\) | 0 | 1 | 0 | 1 | 0 | 0 | 4 | 4 / 0 (Không xét) |
| \(s_2\) | 0 | 0 | **2** | 0 | 1 | 0 | 12 | 12 / 2 = 6 \(\leftarrow\) Min |
| \(s_3\) | 0 | 3 | 2 | 0 | 0 | 1 | 18 | 18 / 2 = 9 |

* **Cột xoay:** Cột \(x_2\) (hệ số âm nhất trên dòng \(Z\) là -5). Biến \(x_2\) vào cơ sở.
* **Tỷ số:** \(\theta = \min \{12/2, 18/2\} = 6\) tại hàng \(s_2\). Phần tử xoay là 2 (ô hàng \(s_2\), cột \(x_2\)). Biến \(s_2\) ra khỏi cơ sở.
* **Biến đổi Gauss-Jordan:**
  * Hàng \(s_2\) mới = Hàng \(s_2\) cũ / 2 \(\implies [0, 0, 1, 0, 0.5, 0, 6]\).
  * Hàng \(Z\) mới = Hàng \(Z\) cũ + 5 \(\times\) Hàng xoay mới.
  * Hàng \(s_3\) mới = Hàng \(s_3\) cũ - 2 \(\times\) Hàng xoay mới.

* **Bảng Đơn hình 2:**

| Biến CS | \(Z\) | \(x_1\) | \(x_2\) | \(s_1\) | \(s_2\) | \(s_3\) | Phương án (\(b\)) | Tỷ số \(\theta\) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Z** | 1 | **-3** | 0 | 0 | 2.5 | 0 | 30 | — |
| \(s_1\) | 0 | **1** | 0 | 1 | 0 | 0 | 4 | 4 / 1 = 4 \(\leftarrow\) Min |
| \(x_2\) | 0 | 0 | 1 | 0 | 0.5 | 0 | 6 | 6 / 0 (Không xét) |
| \(s_3\) | 0 | **3** | 0 | 0 | -1 | 1 | 6 | 6 / 3 = 2 |

* **Kiểm tra dòng \(Z\):** Còn hệ số âm -3 tại cột \(x_1\). Cột xoay là cột \(x_1\). Biến \(x_1\) vào cơ sở.
* **Tỷ số:** \(\theta = \min \{4/1, 6/3\} = 2\) tại hàng \(s_3\). Phần tử xoay là 3 (ô hàng \(s_3\), cột \(x_1\)). Biến \(s_3\) ra khỏi cơ sở.
* **Biến đổi Gauss-Jordan:**
  * Hàng \(s_3\) mới = Hàng \(s_3\) cũ / 3 \(\implies [0, 1, 0, 0, -1/3, 1/3, 2]\).
  * Hàng \(Z\) mới = Hàng \(Z\) cũ + 3 \(\times\) Hàng \(x_1\) mới.
  * Hàng \(s_1\) mới = Hàng \(s_1\) cũ - 1 \(\times\) Hàng \(x_1\) mới.

* **Bảng Đơn hình 3 (Tối ưu):**

| Biến CS | \(Z\) | \(x_1\) | \(x_2\) | \(s_1\) | \(s_2\) | \(s_3\) | Phương án (\(b\)) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Z** | 1 | 0 | 0 | 0 | 1.5 | 1.0 | **36** |
| \(s_1\) | 0 | 0 | 0 | 1 | 1/3 | -1/3 | 2 |
| \(x_2\) | 0 | 0 | 1 | 0 | 0.5 | 0 | 6 |
| \(x_1\) | 0 | 1 | 0 | 0 | -1/3 | 1/3 | 2 |

* **Kết luận:** Tất cả các hệ số trên dòng \(Z\) đều \(\ge 0\) (0, 0, 0, 1.5, 1.0). Phương án tối ưu đã đạt được:
  \[
x_1^* = 2, \quad x_2^* = 6, \quad s_1^* = 2, \quad s_2^* = 0, \quad s_3^* = 0
\]
  Giá trị hàm mục tiêu tối ưu: **\(Z_{\max} = 36\)**

---

## BÀI 4 (B4): TỐI ƯU ĐA BIẾN CÓ RÀNG BUỘC BẰNG NHÂN TỬ LAGRANGE VÀ ĐIỀU KIỆN KKT

### 4.1. Bài toán Ràng buộc Đẳng thức — Phương pháp Nhân tử Lagrange

Dạng bài toán:
\[
\begin{aligned}
\text{Minimize/Maximize } \quad & f(x_1, x_2, \dots, x_n) \\
\text{Subject to: } \quad & g_i(x_1, x_2, \dots, x_n) = 0 \quad (i = 1, 2, \dots, m)
\end{aligned}
\]

**Hàm Lagrange:**
\[
L(\mathbf{x}, \boldsymbol{\lambda}) = f(\mathbf{x}) + \sum_{i=1}^m \lambda_i g_i(\mathbf{x})
\]

**Hệ Phương trình Điều kiện Cần Cấp 1:**
\[
\begin{cases}
\frac{\partial L}{\partial x_j} = \frac{\partial f}{\partial x_j} + \sum_{i=1}^m \lambda_i \frac{\partial g_i}{\partial x_j} = 0 \quad (j = 1, \dots, n) \\[1ex]
\frac{\partial L}{\partial \lambda_i} = g_i(\mathbf{x}) = 0 \quad (i = 1, \dots, m)
\end{cases}
\]

Giải hệ \(n + m\) phương trình tìm tọa độ điểm dừng \(\mathbf{x}^*\) và nhân tử Lagrange \(\boldsymbol{\lambda}^*\).

### 4.2. Bài toán Ràng buộc Bất đẳng thức — Điều kiện Karush-Kuhn-Tucker (KKT)

Bài toán tối ưu tổng quát dạng thu nhỏ (Minimize):
\[
\begin{aligned}
\text{Minimize } \quad & f(\mathbf{x}) \\
\text{Subject to: } \quad & g_i(\mathbf{x}) = 0 \quad (i = 1, \dots, m) \\
& h_k(\mathbf{x}) \le 0 \quad (k = 1, \dots, p)
\end{aligned}
\]

**Hàm Lagrange Tổng quát:**
\[
L(\mathbf{x}, \boldsymbol{\lambda}, \boldsymbol{\mu}) = f(\mathbf{x}) + \sum_{i=1}^m \lambda_i g_i(\mathbf{x}) + \sum_{k=1}^p \mu_k h_k(\mathbf{x})
\]

**Bộ 4 Điều kiện KKT (KKT System):**
1. **Điều kiện Triệt tiêu Gradient (Stationarity):**
   \[
\nabla_{\mathbf{x}} L = \mathbf{0} \iff \nabla f(\mathbf{x}^*) + \sum_{i=1}^m \lambda_i^* \nabla g_i(\mathbf{x}^*) + \sum_{k=1}^p \mu_k^* \nabla h_k(\mathbf{x}^*) = \mathbf{0}
\]
2. **Chấp nhận được của Bài toán Gốc (Primal Feasibility):**
   \[
g_i(\mathbf{x}^*) = 0 \quad \forall i = 1, \dots, m
\]
   \[
h_k(\mathbf{x}^*) \le 0 \quad \forall k = 1, \dots, p
\]
3. **Chấp nhận được của Bài toán Đối ngẫu (Dual Feasibility):**
   \[
\mu_k^* \ge 0 \quad \forall k = 1, \dots, p \quad (\text{đối với bài toán Minimize})
\]
4. **Điều kiện Bù Slack (Complementary Slackness):**
   \[
\mu_k^* \cdot h_k(\mathbf{x}^*) = 0 \quad \forall k = 1, \dots, p
\]

> **Lưu ý quan trọng cho bài toán Maximize \(f(\mathbf{x})\):** Nếu bài toán là \(\text{Maximize } f(\mathbf{x})\) với \(h_k(\mathbf{x}) \le 0\), ta đổi dấu hàm mục tiêu thành \(\text{Minimize } -f(\mathbf{x})\) hoặc giữ nguyên điều kiện Dual Feasibility là \(\mu_k^* \ge 0\) khi đặt \(L = f(\mathbf{x}) - \sum \mu_k h_k(\mathbf{x})\).

### 4.3. Ví dụ Giải Chi tiết Bài toán KKT

**Đề bài:** Giải bài toán tối ưu có ràng buộc bất đẳng thức sau bằng điều kiện KKT:
\[
\begin{aligned}
\text{Minimize } \quad & f(x_1, x_2) = (x_1 - 4)^2 + (x_2 - 4)^2 \\
\text{Subject to: } \quad & h(x_1, x_2) = x_1 + x_2 - 5 \le 0 \\
& x_1 \ge 0, \; x_2 \ge 0
\end{aligned}
\]

**Bài giải:**

* **Biến đổi ràng buộc phi âm về dạng chuẩn \(h_k(\mathbf{x}) \le 0\):**
  \(h_1(x_1, x_2) = x_1 + x_2 - 5 \le 0\)
  \(h_2(x_1, x_2) = -x_1 \le 0\)
  \(h_3(x_1, x_2) = -x_2 \le 0\)

* **Hàm Lagrange:**
  \[
L(x_1, x_2, \mu_1, \mu_2, \mu_3) = (x_1 - 4)^2 + (x_2 - 4)^2 + \mu_1 (x_1 + x_2 - 5) + \mu_2 (-x_1) + \mu_3 (-x_2)
\]

* **Bộ điều kiện KKT:**
  1. **Stationarity:**
     \[
\frac{\partial L}{\partial x_1} = 2(x_1 - 4) + \mu_1 - \mu_2 = 0 \implies 2x_1 - 8 + \mu_1 - \mu_2 = 0
\]
     \[
\frac{\partial L}{\partial x_2} = 2(x_2 - 4) + \mu_1 - \mu_3 = 0 \implies 2x_2 - 8 + \mu_1 - \mu_3 = 0
\]
  2. **Primal Feasibility:** \(x_1 + x_2 - 5 \le 0, \quad x_1 \ge 0, \quad x_2 \ge 0\)
  3. **Dual Feasibility:** \(\mu_1 \ge 0, \quad \mu_2 \ge 0, \quad \mu_3 \ge 0\)
  4. **Complementary Slackness:**
     \[
\mu_1 (x_1 + x_2 - 5) = 0
\]
     \[
\mu_2 x_1 = 0
\]
     \[
\mu_3 x_2 = 0
\]

* **Phân tích theo các trường hợp (Case Analysis):**
  * **Trường hợp 1 (Ràng buộc không hoạt động: \(\mu_1 = 0, \mu_2 = 0, \mu_3 = 0\)):**
    * Từ Stationarity: \(2x_1 - 8 = 0 \implies x_1 = 4\); \(2x_2 - 8 = 0 \implies x_2 = 4\).
    * Thử vào Primal Feasibility: \(x_1 + x_2 = 4 + 4 = 8 > 5\) (Vi phạm ràng buộc \(x_1 + x_2 \le 5\)).
    * \(\implies\) **Loại Trường hợp 1.**
  * **Trường hợp 2 (Ràng buộc \(h_1\) hoạt động: \(x_1 + x_2 - 5 = 0 \implies x_1 + x_2 = 5\), giả sử \(x_1 > 0, x_2 > 0 \implies \mu_2 = 0, \mu_3 = 0\)):**
    * Hệ phương trình Stationarity trở thành:
      \(2x_1 - 8 + \mu_1 = 0 \implies \mu_1 = 8 - 2x_1\)
      \(2x_2 - 8 + \mu_1 = 0 \implies \mu_1 = 8 - 2x_2\)
    * Từ đây suy ra \(8 - 2x_1 = 8 - 2x_2 \implies x_1 = x_2\).
    * Thay vào ràng buộc \(x_1 + x_2 = 5\): \(2x_1 = 5 \implies x_1 = 2.5, \quad x_2 = 2.5\)
    * Tính nhân tử Lagrange: \(\mu_1 = 8 - 2(2.5) = 3.0\)
    * **Kiểm tra các điều kiện:**
      * \(x_1 = 2.5 \ge 0, x_2 = 2.5 \ge 0, x_1 + x_2 = 5 \le 5 \implies\) **Primal Feasible!**
      * \(\mu_1 = 3.0 \ge 0, \mu_2 = 0 \ge 0, \mu_3 = 0 \ge 0 \implies\) **Dual Feasible!**
      * Bù slack: \(\mu_1 (5 - 5) = 0, \mu_2 (2.5) = 0, \mu_3 (2.5) = 0 \implies\) **Thỏa mãn!**

* **Kết luận:** Điểm tối ưu duy nhất thỏa mãn bộ điều kiện KKT là:
  \[
x_1^* = 2.5, \quad x_2^* = 2.5
\]
  Nhân tử Lagrange tương ứng:
  \[
\mu_1^* = 3.0, \quad \mu_2^* = 0, \quad \mu_3^* = 0
\]
  Giá trị cực tiểu của hàm mục tiêu:
  \[
f(2.5, 2.5) = (2.5 - 4)^2 + (2.5 - 4)^2 = (-1.5)^2 + (-1.5)^2 = 2.25 + 2.25 = 4.5
\]

-----------------

# MỘT SỐ VÍ DỤ THỰC TẾ

Dưới đây là bản render lại nội dung tài liệu tổng hợp các bài toán thực tế từ slide bài giảng, được trình bày rõ ràng với định dạng Markdown và công thức toán học (LaTeX) để bạn dễ dàng theo dõi và ôn tập.

---

# BÁO CÁO TỔNG HỢP CÁC BÀI TOÁN THỰC TẾ TRONG SLIDE BÀI GIẢNG TỐI ƯU HÓA (GK5045)

Tài liệu này hệ thống hóa toàn bộ các ví dụ và mô hình bài toán thực tế được giảng dạy trong các slide bài giảng môn Tối ưu hóa Toán học (GK5045). Mỗi bài toán được trích xuất chi tiết từ ngữ cảnh thực tế, cách đặt biến quyết định, xây dựng hàm mục tiêu, hệ thống ràng buộc kỹ thuật, cùng với giải thích ý nghĩa kinh tế - kỹ thuật của các bài toán đối ngẫu hoặc mô hình mạng tương đương.

---

## 1. Nhóm Bài toán Quy hoạch Tuyến tính và Đối ngẫu

### 1.1. Bài toán Vận tải Sản xuất (Production-Transportation Problem)

**Bối cảnh Thực tế**
Một nhà sản xuất cần lập lịch trình vận chuyển hàng hóa từ 2 nhà kho trung tâm (\(W_1\) và \(W_2\)) đến 3 cửa hàng bán lẻ (\(R_1, R_2, R_3\)) sao cho tổng chi phí vận chuyển là nhỏ nhất.

**Thông số Dữ liệu**
*   **Nguồn cung tối đa tại nhà kho:**
    *   Kho \(W_1 \le 300\) sản phẩm
    *   Kho \(W_2 \le 600\) sản phẩm
*   **Nhu cầu tối thiểu tại cửa hàng bán lẻ:**
    *   Cửa hàng \(R_1 \ge 200\) sản phẩm
    *   Cửa hàng \(R_2 \ge 300\) sản phẩm
    *   Cửa hàng \(R_3 \ge 400\) sản phẩm
*   **Ma trận chi phí vận chuyển đơn vị (\(c_{ij}\)):**

| Nhà kho | Cửa hàng \(R_1\) | Cửa hàng \(R_2\) | Cửa hàng \(R_3\) |
| :--- | :---: | :---: | :---: |
| **Kho \(W_1\)** | 2 | 4 | 3 |
| **Kho \(W_2\)** | 5 | 3 | 4 |

**Mô hình Bài toán Gốc (Primal Problem)**
*   **Biến quyết định:** Gọi \(x_{ij}\) là số lượng hàng hóa vận chuyển từ kho \(W_i\) (\(i = 1, 2\)) đến cửa hàng \(R_j\) (\(j = 1, 2, 3\)), với \(x_{ij} \ge 0\).
*   **Hàm mục tiêu (Giảm thiểu chi phí):**
    \[
\min Z = 2x_{11} + 4x_{12} + 3x_{13} + 5x_{21} + 3x_{22} + 4x_{23}
\]
*   **Ràng buộc:**
    *   *Ràng buộc nguồn cung:*
        \[
x_{11} + x_{12} + x_{13} \le 300
\]
        \[
x_{21} + x_{22} + x_{23} \le 600
\]
    *   *Ràng buộc nhu cầu:*
        \[
x_{11} + x_{21} \ge 200
\]
        \[
x_{12} + x_{22} \ge 300
\]
        \[
x_{13} + x_{23} \ge 400
\]

**Giải thích Ý nghĩa Kinh tế của Bài toán Đối ngẫu (Dual Interpretation)**
Một công ty vận tải độc lập đến đàm phán và đề xuất nhà sản xuất nhượng lại toàn bộ khâu vận chuyển:
*   Công ty vận tải chào mua toàn bộ hàng tại kho \(W_1\) với giá \(y_1\)/sản phẩm và kho \(W_2\) với giá \(y_2\)/sản phẩm.
*   Công ty vận tải giao và bán lại cho cửa hàng \(R_1\) với giá \(y_3\)/sản phẩm, \(R_2\) với giá \(y_4\)/sản phẩm, và \(R_3\) với giá \(y_5\)/sản phẩm.
*   Để nhà sản xuất chấp nhận hợp đồng, mức chênh lệch giá bán trừ giá mua trên mỗi tuyến đường không được vượt quá chi phí tự vận chuyển của nhà sản xuất (ví dụ: \(y_3 - y_1 \le 2\)).
*   **Mô hình Bài toán Đối ngẫu** (Tối đa hóa lợi nhuận đơn vị vận tải):
    \[
\max W = -300y_1 - 600y_2 + 200y_3 + 300y_4 + 400y_5
\]
    sao cho các ràng buộc chênh lệch giá \(y_j - y_i \le c_{ij}\) và \(y_i \ge 0\) được thỏa mãn.

---

### 1.2. Bài toán Khẩu phần Ăn kiêng (Diet Problem)

**Bối cảnh Thực tế**
Bài toán yêu cầu thiết lập một chế độ ăn kiêng hằng ngày dựa trên 4 loại thực phẩm cơ bản nhằm đảm bảo đáp ứng đầy đủ dinh dưỡng tối thiểu cho cơ thể nhưng với tổng chi phí mua thực phẩm là nhỏ nhất.

**Danh mục Thực phẩm và Hàm lượng Dinh dưỡng**

| Thực phẩm | Calo (cal) | Chocolate (oz) | Đường (oz) | Chất béo (oz) | Chi phí (cents) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| Bánh Brownie | 400 | 3 | 2 | 2 | 50 |
| Kem Chocolate (scoop) | 200 | 2 | 2 | 4 | 20 |
| Nước Cola (chai) | 150 | 0 | 4 | 1 | 30 |
| Bánh Pineapple Cheesecake | 500 | 0 | 4 | 5 | 80 |

*   **Yêu cầu dinh dưỡng tối thiểu mỗi ngày:**
    *   Calo: \(\ge 500\) cal
    *   Chocolate: \(\ge 6\) oz
    *   Đường (Sugar): \(\ge 10\) oz
    *   Chất béo (Fat): \(\ge 8\) oz

**Mô hình Bài toán Gốc (Primal Problem)**
*   **Biến quyết định:** Gọi \(x_1, x_2, x_3, x_4 \ge 0\) lần lượt là số lượng đơn vị bánh brownie, kem chocolate, chai cola và bánh cheesecake tiêu thụ trong ngày.
*   **Hàm mục tiêu (Chi phí tối thiểu):**
    \[
\min Z = 50x_1 + 20x_2 + 30x_3 + 80x_4
\]
*   **Hệ ràng buộc dinh dưỡng:**
    \[
400x_1 + 200x_2 + 150x_3 + 500x_4 \ge 500 \quad (\text{Calo})
\]
    \[
3x_1 + 2x_2 + 0x_3 + 0x_4 \ge 6 \quad (\text{Chocolate})
\]
    \[
2x_1 + 2x_2 + 4x_3 + 4x_4 \ge 10 \quad (\text{Đường})
\]
    \[
2x_1 + 4x_2 + 1x_3 + 5x_4 \ge 8 \quad (\text{Chất béo})
\]

**Ý nghĩa Kinh tế Bài toán Đối ngẫu**
Một nhà cung cấp dinh dưỡng dạng viên tổng hợp muốn bán riêng lẻ từng chất dinh dưỡng (calo, chocolate, đường, chất béo) cho người ăn kiêng với đơn giá tương ứng \(y_1, y_2, y_3, y_4\).
*   **Mục tiêu** nhà cung cấp là tối đa hóa tổng doanh thu bán chất dinh dưỡng:
    \[
\max W = 500y_1 + 6y_2 + 10y_3 + 8y_4
\]
*   **Ràng buộc cạnh tranh:** Tổng giá thành các chất dinh dưỡng chứa trong một loại thực phẩm không được đắt hơn giá bán của chính thực phẩm đó trên thị trường (ví dụ ràng buộc bánh brownie: \(400y_1 + 3y_2 + 2y_3 + 2y_4 \le 50\)).

---

## 2. Nhóm Bài toán Tối ưu hóa Mạng lưới và Vận chuyển

### 2.1. Bài toán Luồng Cực đại trên Mạng lưới và Lát cắt Nhỏ nhất (Max-Flow / Min-Cut Transport)

**Bối cảnh Thực tế**
Vận chuyển một loại hàng hóa từ nút nguồn phát (\(s\)) qua mạng lưới bao gồm các nút trung chuyển trung gian (\(1, 2, 3, 4, 5...\)) đến nút đích thu nhận (\(t\)). Mỗi cung kết nối \((i,j)\) có một giới hạn dung lượng vận chuyển tối đa \(k_{ij}\).

**Phát biểu Toán học của Mạng lưới**
*   **Biến quyết định:** \(f_{ij}\) là luồng hàng hóa vận chuyển thực tế trên cung \((i,j)\).
*   **Ràng buộc dung lượng:** \(0 \le f_{ij} \le k_{ij}\).
*   **Định luật bảo toàn dòng chảy (Flow Conservation):**
    *   Tại đỉnh phát \(s\): Tổng luồng đi ra bằng tổng luồng toàn mạng \(f = \sum_{i} f_{si}\).
    *   Tại đỉnh thu \(t\): Tổng luồng đi vào bằng tổng luồng toàn mạng \(\sum_{i} f_{it} = f\).
    *   Tại mỗi nút trung gian \(j\): Tổng luồng vào bằng tổng luồng ra \(\sum_{i} f_{ij} = \sum_{k} f_{jk}\).

**Ứng dụng Thực tế: Mạng Nhiều Nguồn và Nhiều Đích (Feasibility & Deficit Analysis)**
*   **Kịch bản:** Hệ thống có nhiều điểm phát và nhiều điểm tiêu thụ được đưa về nút nguồn siêu tổng (\(\hat{s}\)) và nút đích siêu tổng (\(\hat{t}\)).
*   **Bài toán đánh giá khả thi:** Tổng nhu cầu tại các điểm đích là 35. Khi phân tích lát cắt nhỏ nhất (Min-Cut) của mạng, tổng dung lượng thông qua cực đại chỉ đạt \(15 + 5 + 5 + 5 = 30\).
*   **Kết luận thực tế:** Bài toán vận chuyển không khả thi do nghẽn cổ chai mạng lưới, dẫn đến sự thiếu hụt cung ứng nhỏ nhất là \(5\) đơn vị hàng hóa.

---

### 2.2. Bài toán Phân công Nhân lực Kỹ sư (Manpower Management / Assignment Problem)

**Bối cảnh Thực tế**
Một công ty kỹ thuật có 4 kỹ sư cần phân công đảm nhận 4 dự án lớn (A, B, C, D) kéo dài trong thời hạn 6 tháng.

**Các Ràng buộc Quản lý Nhân sự**
1.  Công ty sở hữu cố định 4 kỹ sư.
2.  Mỗi dự án trong một tháng nhất định chỉ được tiếp nhận tối đa 2 kỹ sư.
3.  Mỗi kỹ sư tại một thời điểm không được phân công quá 1 dự án.

**Mô hình Hóa dưới dạng Bài toán Mạng lưới**
*   **Điểm nguồn (Sources):** Thời hạn 6 tháng (\(i = 1, 2, \dots, 6\)).
*   **Điểm đích (Sinks):** 4 dự án (\(j = A, B, C, D\)).
*   **Cung (i,j):** Đại diện cho khả năng phân công kỹ sư làm việc tại tháng \(i\) cho dự án \(j\). Dung lượng cung \(k_{ij} = 2\).
*   **Mục tiêu:** Sử dụng thuật toán luồng cực đại để xác định liệu có tồn tại phương án phân công nhân lực khả thi thỏa mãn tiến độ dự án hay không.

---

### 2.3. Bài toán Thay thế Thiết bị (Equipment Replacement Problem)

**Bối cảnh Thực tế**
Trong quản lý vận hành máy móc công nghiệp, thiết bị qua thời gian sử dụng sẽ bị hao mòn, dẫn đến chi phí vận hành và bảo trì (O&M - Operation and Maintenance) tăng cao. Việc thay thế bằng thiết bị mới giúp giảm chi phí O&M nhưng lại đòi hỏi chi phí đầu tư vốn cố định ban đầu cao. Bài toán đặt ra là lập kế hoạch thay thế thiết bị định kỳ trong vòng 5 năm tới sao cho tổng chi phí là nhỏ nhất.

**Cấu trúc Chi phí**
\[
\text{Tổng chi phí} = \text{Chi phí vốn (cố định)} + \text{Chi phí vận hành \& bảo dưỡng (biến đổi)}
\]
*   \(p_j\): Chi phí mua thiết bị mới trong năm \(j\).
*   \(s_{j-i}\): Giá trị thanh lý/còn lại của thiết bị sau \(j-i\) năm sử dụng.
*   \(c_\tau\): Chi phí O&M trong năm thứ \(\tau\) hoạt động.

**Mô hình Hóa thành Bài toán Đường đi Ngắn nhất (Shortest Path Problem)**
*   **Đồ thị mạng lưới:** Các nút đại diện cho các mốc thời gian từ năm 1 đến năm 6.
*   **Trọng số cung \(d_{ij}\)** (Chi phí khi mua máy ở năm \(i\) và giữ lại sử dụng đến năm \(j\)):
    \[
d_{ij} = p_i - s_{j-i} + \sum_{\tau=1}^{j-i} c_\tau \quad (j > i)
\]
*   **Giải pháp tối ưu:** Tìm đường đi ngắn nhất từ nút 1 đến nút 6. Ví dụ, nếu đường đi tối ưu là \(\{(1,2), (2,3), (3,4), (4,5), (5,6)\}\), giải pháp thực tế là thay mới thiết bị định kỳ hàng năm với tổng chi phí \(\sum_{i=1}^5 p_i - 5s_1 + 5c_1\).

---

### 2.4. Bài toán Lưu trữ Sách trong Thư viện (Library Book Storage Problem)

**Bối cảnh Thực tế**
Một thư viện có không gian lưu trữ hạn chế cần phân loại và sắp xếp hàng ngàn cuốn sách lên các kệ lưu trữ sao cho tối thiểu hóa diện tích không gian bị lãng phí.

**Nguyên lý Mô hình Hóa**
*   Các cuốn sách được phân loại theo chiều cao tăng dần: \(H_1 < H_2 < \dots < H_n\).
*   Bài toán tối ưu hóa việc chọn các chiều cao kệ sách chuẩn và độ dày ngăn kệ tương ứng để chứa hết các nhóm sách mà không tốn thừa không gian chiều cao dư thừa.

---

## 3. Bảng Phân loại và Phân tích Tổng hợp các Mô hình Thực tế

| Bài toán Thực tế | Miền Ứng dụng | Mô hình Toán học Sử dụng | Thuật toán / Phương pháp Giải |
| :--- | :--- | :--- | :--- |
| **Vận tải Sản xuất** | Chuỗi cung ứng, Logistics | Quy hoạch tuyến tính (LP) & Đối ngẫu | Thuật toán Đơn hình (Simplex), Đối ngẫu |
| **Khẩu phần Ăn kiêng** | Y tế, Dinh dưỡng, Kinh tế | Quy hoạch tuyến tính (LP) & Đơn giá ẩn | Thuật toán Đơn hình (Simplex), KKT |
| **Luồng Cực đại Mạng lưới** | Giao thông, Viễn thông | Luồng trên mạng (Network Flow) | Đồ thị Mạng, Định lý Max-Flow Min-Cut |
| **Quản lý Nhân lực** | Quản trị dự án, HR | Bài toán Phân công / Luồng mạng | Luồng cực đại trên mạng |
| **Thay thế Thiết bị** | Quản lý tài sản công nghiệp | Đường đi ngắn nhất (Shortest Path) | Thuật toán Dijkstra, Quy hoạch động |
| **Lưu trữ Thư viện** | Quản lý kho bãi, Không gian | Tối ưu hóa rời rạc / Phân hoạch | Quy hoạch tuyến tính / Đơn hình |
