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
      ***Note***
      Thuật toán Đơn hình (Simplex) về bản chất là thuật toán đại số tuyến tính, nó chỉ giải được hệ phương trình (có dấu ==). Nó hoàn toàn "mù tịt" với các bất phương trình (dấu $\le$ hoặc $\ge$).

      Bài toán gốc: $x_1 \le 4x_1 \le 4$

      Để biến nó thành phương trình, ta thêm một lượng dương $s_1​≥0$ vào: $x_1+s_1=4$.
      Lúc này $s_1$​ đóng vai trò là "phần còn trống" để bù vào cho đủ 4.
   * Hàng đánh giá (Hàng \(Z\) hay Reduced Costs): \(C_j = c_j - z_j\) hoặc biểu diễn dòng mục tiêu dưới dạng \(Z - \sum c_j x_j = 0\).
2. **Bước 2 (Kiểm tra Điều kiện Tối ưu):**
   * Bài toán Maximize: Nếu tất cả các hệ số trên dòng \(Z\) tương ứng với các biến không cơ sở đều \(\ge 0\) (hoặc mọi chỉ số \(c_j - z_j \le 0\) tùy theo ký hiệu quy ước), phương án hiện tại là Tối ưu. Dừng thuật toán.
3. **Bước 3 (Chọn Biến vào cơ sở - Entering Variable):**
   * Chọn biến có hệ số âm nhất **(chỉ) trên dòng \(Z\)** (hoặc \(c_j - z_j\) dương lớn nhất) làm biến vào cơ sở. Cột tương ứng gọi là Cột xoay (Pivot Column).
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

* **Cột xoay:** Cột \(x_2\) (hệ số âm nhất trên dòng \(Z\) là -5). **Chọn Biến \(x_2\) vào cơ sở.**
* **Tỷ số:** \(\theta = \min \{12/2, 18/2\} = 6\) tại hàng \(s_2\). Phần tử xoay là 2 (ô hàng \(s_2\), cột \(x_2\)). Biến \(s_2\) ra khỏi cơ sở. (mẫu số là hệ số của biến đang chọn vào cơ sở)
* **Biến đổi Gauss-Jordan:**
  * Hàng \(s_2\) mới = Hàng \(s_2\) cũ / 2 \(\implies [0, 0, 1, 0, 0.5, 0, 6]\).
  * Hàng \(Z\) mới = Hàng \(Z\) cũ + 5 \(\times\) Hàng xoay mới.
  * Hàng \(s_3\) mới = Hàng \(s_3\) cũ - 2 \(\times\) Hàng xoay mới.

* **Bảng Đơn hình 2:**

| Biến CS | \(Z\) | \(x_1\) | \(x_2\) | \(s_1\) | \(s_2\) | \(s_3\) | Phương án (\(b\)) | Tỷ số \(\theta\) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **Z** | 1 | **-3** | 0 | 0 | 2.5 | 0 | 30 | — |
| \(s_1\) | 0 | **1** | 0 | 1 | 0 | 0 | 4 | 4 / 1 = 4 |
| \(x_2\) | 0 | 0 | 1 | 0 | 0.5 | 0 | 6 | 6 / 0 (Không xét) |
| \(s_3\) | 0 | **3** | 0 | 0 | -1 | 1 | 6 | 6 / 3 = 2 \(\leftarrow\) Min |

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

  ***Note***
  Điều này có nghĩa là: Để đạt lợi nhuận cao nhất, chỉ cần sản xuất 2 đơn vị sản phẩm (dùng 2 giờ máy), và dư ra 2 giờ máy chưa dùng đến (đó chính là $s_1=2$).

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