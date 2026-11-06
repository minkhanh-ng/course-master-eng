# BTVN Week 6 - Bài Tập 2

## Đề bài (Consider the linear program)
**Maximize:**  
$$ Z = 2x_1 + x_2 $$

**Subject to:**  
$$ 0 \leq x_1 \leq 5 $$
$$ 0 \leq x_2 \leq 7 $$
$$ x_1 + x_2 \leq 9 $$

Convert the problem to standard form and solve it using the simplex method.

---

## 1. Dạng chuẩn (Standard form)
Thêm các biến bù (slack variables) $s_1, s_2, s_3$ để chuyển các bất phương trình thành phương trình:
$$ x_1 + s_1 = 5 $$
$$ x_2 + s_2 = 7 $$
$$ x_1 + x_2 + s_3 = 9 $$
Với điều kiện: $x_1, x_2, s_1, s_2, s_3 \geq 0$

---

## 2. Giải bằng phương pháp Đơn hình (Simplex Method)

### Bảng Simplex khởi tạo

| Cơ sở | $Z$ | $x_1$ | $x_2$ | $s_1$ | $s_2$ | $s_3$ | RHS | Tỷ số |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **$Z$** | 1 | -2 | -1 | 0 | 0 | 0 | 0 | |
| **$s_1$** | 0 | 1 | 0 | 1 | 0 | 0 | 5 | $5/1 = 5$ |
| **$s_2$** | 0 | 0 | 1 | 0 | 1 | 0 | 7 | $7/0$ |
| **$s_3$** | 0 | 1 | 1 | 0 | 0 | 1 | 9 | $9/1 = 9$ |

*   **Biến vào:** $x_1$ (có hệ số âm lớn nhất ở dòng Z, là -2).
*   **Biến ra:** $s_1$ (tỷ số RHS/$x_1$ dương nhỏ nhất, $5 < 9$).
*   **Phần tử xoay (Pivot):** Giao của cột $x_1$ và hàng $s_1$, có giá trị là 1.

---

### Bảng sau vòng lặp 1 (Biến vào $x_1$, biến ra $s_1$)
Làm cho phần tử xoay bằng 1 (đã là 1). Các phần tử khác trong cột $x_1$ thành 0 bằng cách thực hiện phép toán trên hàng.
*   **Hàng $x_1$:** Giữ nguyên do hệ số xoay là 1.
*   **Hàng $Z$ mới** = Hàng $Z$ cũ - (-2) * Hàng $x_1$ mới = Hàng $Z$ cũ + 2 * Hàng $x_1$ mới.
*   **Hàng $s_2$ mới:** Hệ số $x_1$ ở hàng $s_2$ đã là 0, nên giữ nguyên.
*   **Hàng $s_3$ mới** = Hàng $s_3$ cũ - 1 * Hàng $x_1$ mới.

| Cơ sở | $Z$ | $x_1$ | $x_2$ | $s_1$ | $s_2$ | $s_3$ | RHS | Tỷ số |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **$Z$** | 1 | 0 | -1 | 2 | 0 | 0 | 10 | |
| **$x_1$** | 0 | 1 | 0 | 1 | 0 | 0 | 5 | $5/0$ |
| **$s_2$** | 0 | 0 | 1 | 0 | 1 | 0 | 7 | $7/1 = 7$ |
| **$s_3$** | 0 | 0 | 1 | -1 | 0 | 1 | 4 | $4/1 = 4$ |

*(Chi tiết phép tính: Hàng Z: -2 -(-2*1)=0; -1 -(-2*0)=-1; 0-(-2*1)=2; 0-(-2*5)=10. Hàng s3: 1-(1*1)=0; 1-(0*1)=1; 0-(1*1)=-1; 9-(1*5)=4)*

*   **Biến vào:** $x_2$ (có hệ số âm lớn nhất ở dòng Z, là -1).
*   **Biến ra:** $s_3$ (tỷ số RHS/$x_2$ dương nhỏ nhất, $4 < 7$).
*   **Phần tử xoay (Pivot):** Giao của cột $x_2$ và hàng $s_3$, có giá trị là 1.

---

### Bảng sau vòng lặp 2 (Biến vào $x_2$, biến ra $s_3$)
*   **Hàng $x_2$ mới (từ hàng $s_3$):** Giữ nguyên do hệ số xoay là 1.
*   **Hàng $Z$ mới** = Hàng $Z$ cũ - (-1) * Hàng $x_2$ mới = Hàng $Z$ cũ + Hàng $x_2$ mới.
*   **Hàng $x_1$ mới:** Do hệ số của $x_2$ ở hàng $x_1$ đã là 0 nên giữ nguyên.
*   **Hàng $s_2$ mới** = Hàng $s_2$ cũ - 1 * Hàng $x_2$ mới.

| Cơ sở | $Z$ | $x_1$ | $x_2$ | $s_1$ | $s_2$ | $s_3$ | RHS | Tỷ số |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **$Z$** | 1 | 0 | 0 | 1 | 0 | 1 | 14 | |
| **$x_1$** | 0 | 1 | 0 | 1 | 0 | 0 | 5 | - |
| **$s_2$** | 0 | 0 | 0 | 1 | 1 | -1 | 3 | |
| **$x_2$** | 0 | 0 | 1 | -1 | 0 | 1 | 4 | |

*(Chi tiết phép tính: Hàng Z: -1 -(-1*1)=0; 2-(-1*-1)=1; 0-(-1*1)=1; 10-(-1*4)=14. Hàng s2: 1-(1*1)=0; 0-(1*-1)=1; 0-(1*1)=-1; 7-(1*4)=3)*

**Kết luận:**
Sau Vòng lặp 2, nhìn vào hàng $Z$ của bảng cuối cùng, tất cả các hệ số của các biến đều $\geq 0$. Điều này cho thấy bảng đã đạt trạng thái tối ưu.
*   Nhìn vào cột RHS của hàng $Z$, ta được giá trị tối đa: **$Z = 14$**.
*   Nhìn vào cột RHS của các biến cơ sở, ta có: **$x_1 = 5$** và **$x_2 = 4$**.

---

## 3. Vẽ đồ thị (Graphical Method)

Từ đồ thị (hình đính kèm trong bài):
*   **Vùng đỏ:** Biểu diễn miền nghiệm của bất phương trình $0 \leq x_1 \leq 5$.
*   **Vùng xanh dương:** Biểu diễn miền nghiệm của bất phương trình $0 \leq x_2 \leq 7$.
*   **Vùng xanh lá:** Biểu diễn miền nghiệm của bất phương trình $x_1 + x_2 \leq 9$.
*   **Đường màu đen:** Đường biểu diễn hàm mục tiêu với giá trị tối ưu: $2x_1 + x_2 = 14$. 

Giao điểm tối ưu nằm tại tọa độ $(x_1, x_2) = (5, 4)$, tương ứng với giá trị lớn nhất $Z = 14$.