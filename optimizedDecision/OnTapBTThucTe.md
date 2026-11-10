# BÁO CÁO TỔNG HỢP CÁC BÀI TOÁN THỰC TẾ TRONG SLIDE BÀI GIẢNG TỐI ƯU HÓA (GK5045)

Tài liệu này hệ thống hóa toàn bộ các ví dụ và mô hình bài toán thực tế được giảng dạy trong các slide bài giảng môn Tối ưu hóa Toán học (GK5045). Mỗi bài toán được trích xuất chi tiết từ ngữ cảnh thực tế, cách đặt biến quyết định, xây dựng hàm mục tiêu, hệ thống ràng buộc kỹ thuật, cùng với giải thích ý nghĩa kinh tế - kỹ thuật của các bài toán đối ngẫu hoặc mô hình mạng tương đương.

Dưới đây giữ nguyên cách diễn đạt và ký hiệu trong bản gốc, chỉ bổ sung dữ kiện còn thiếu.

---

## 1. Nhóm Bài toán Quy hoạch Tuyến tính và Đối ngẫu

### 1.1. Bài toán Vận tải Sản xuất (Production-Transportation Problem)

Một nhà sản xuất cần lập lịch trình vận chuyển hàng hóa từ 2 nhà kho trung tâm (\(W_1\) và \(W_2\)) đến 3 cửa hàng bán lẻ (\(R_1,R_2,R_3\)) sao cho tổng chi phí vận chuyển là nhỏ nhất.

**Thông số Dữ liệu**

- **Nguồn cung tối đa tại nhà kho:**
  - Kho \(W_1\le300\) sản phẩm.
  - Kho \(W_2\le600\) sản phẩm.
- **Nhu cầu tối thiểu tại cửa hàng bán lẻ:**
  - Cửa hàng \(R_1\ge200\) sản phẩm.
  - Cửa hàng \(R_2\ge300\) sản phẩm.
  - Cửa hàng \(R_3\ge400\) sản phẩm.
- **Ma trận chi phí vận chuyển đơn vị \((c_{ij})\):**

| Nhà kho | Cửa hàng \(R_1\) | Cửa hàng \(R_2\) | Cửa hàng \(R_3\) |
|---|---:|---:|---:|
| **Kho \(W_1\)** | 2 | 4 | 3 |
| **Kho \(W_2\)** | 5 | 3 | 4 |

---

### 1.2. Bài toán Khẩu phần Ăn kiêng (Diet Problem)

Bài toán yêu cầu thiết lập một chế độ ăn kiêng hằng ngày dựa trên 4 loại thực phẩm cơ bản nhằm đảm bảo đáp ứng đầy đủ dinh dưỡng tối thiểu cho cơ thể nhưng với tổng chi phí mua thực phẩm là nhỏ nhất.

**Danh mục Thực phẩm và Hàm lượng Dinh dưỡng**

| Thực phẩm | Calo (cal) | Chocolate (oz) | Đường (oz) | Chất béo (oz) | Chi phí (cents) |
|---|---:|---:|---:|---:|---:|
| **Bánh Brownie** | 400 | 3 | 2 | 2 | 50 |
| **Kem Chocolate (scoop)** | 200 | 2 | 2 | 4 | 20 |
| **Nước Cola (chai)** | 150 | 0 | 4 | 1 | 30 |
| **Bánh Pineapple Cheesecake** | 500 | 0 | 4 | 5 | 80 |

- **Yêu cầu dinh dưỡng tối thiểu mỗi ngày:**
  - Calo: \(\ge500\) cal.
  - Chocolate: \(\ge6\) oz.
  - Đường (Sugar): \(\ge10\) oz.
  - Chất béo (Fat): \(\ge8\) oz.

Lượng mỗi loại thực phẩm được phép nhận giá trị thực không âm.

---

## 2. Nhóm Bài toán Tối ưu hóa Mạng lưới và Vận chuyển

### 2.1. Bài toán Luồng Cực đại trên Mạng lưới và Lát cắt Nhỏ nhất (Max-Flow / Min-Cut Transport)

Vận chuyển một loại hàng hóa từ nút nguồn phát qua mạng lưới bao gồm các nút trung chuyển trung gian đến nút đích thu nhận. Mỗi cung kết nối \((i,j)\) có một giới hạn dung lượng vận chuyển tối đa \(k_{ij}\).

**Ứng dụng Thực tế: Mạng Nhiều Nguồn và Nhiều Đích (Feasibility & Deficit Analysis)**

- Hệ thống có 8 nút, được đánh số từ 1 đến 8.
- **Nguồn cung tối đa:**
  - Nút \(1\le20\) đơn vị hàng hóa.
  - Nút \(4\le20\) đơn vị hàng hóa.
- **Nhu cầu tại các điểm đích:**
  - Nút 5: 15 đơn vị hàng hóa.
  - Nút 8: 20 đơn vị hàng hóa.
- **Dung lượng vận chuyển tối đa trên các cung:**

| Cung \((i,j)\) | \(k_{ij}\) | Cung \((i,j)\) | \(k_{ij}\) |
|---|---:|---|---:|
| \((1,2)\) | 10 | \((4,3)\) | 5 |
| \((1,3)\) | 20 | \((4,6)\) | 5 |
| \((3,2)\) | 5 | \((4,7)\) | 5 |
| \((2,5)\) | 15 | \((7,6)\) | 10 |
| \((3,5)\) | 10 | \((6,5)\) | 5 |
| \((3,6)\) | 5 | \((6,8)\) | 10 |
| \((7,8)\) | 10 | — | — |

Các cung có hướng từ \(i\) đến \(j\). Tại mỗi nút trung gian, tổng luồng vào bằng tổng luồng ra.

Hệ thống có nhiều điểm phát và nhiều điểm tiêu thụ được đưa về nút nguồn siêu tổng \(\hat{s}\) và nút đích siêu tổng \(\hat{t}\). Xác định luồng cực đại, đánh giá khả năng đáp ứng tổng nhu cầu và sự thiếu hụt cung ứng nhỏ nhất nếu có.

---

### 2.2. Bài toán Phân công Nhân lực Kỹ sư (Manpower Management / Assignment Problem)

Một công ty kỹ thuật có 4 kỹ sư cần phân công đảm nhận 4 dự án lớn (A, B, C, D) kéo dài trong thời hạn 6 tháng.

**Thông số Dữ liệu bổ sung từ slide**

| Dự án | Tháng bắt đầu sớm nhất | Tháng hoàn thành muộn nhất | Yêu cầu nhân lực (kỹ sư-tháng) |
|---|---:|---:|---:|
| A | 1 | 4 | 6 |
| B | 1 | 6 | 8 |
| C | 2 | 5 | 3 |
| D | 1 | 6 | 4 |

**Các Ràng buộc Quản lý Nhân sự**

1. Công ty sở hữu cố định 4 kỹ sư.
2. Mỗi dự án trong một tháng nhất định chỉ được tiếp nhận tối đa 2 kỹ sư.
3. Mỗi kỹ sư tại một thời điểm không được phân công quá 1 dự án.

Các kỹ sư có năng lực tương đương và được phép chuyển dự án giữa các tháng. Công việc chỉ được thực hiện trong khoảng từ tháng bắt đầu sớm nhất đến tháng hoàn thành muộn nhất.

**Mục tiêu:** Sử dụng thuật toán luồng cực đại để xác định liệu có tồn tại phương án phân công nhân lực khả thi thỏa mãn tiến độ dự án hay không.

---

### 2.3. Bài toán Thay thế Thiết bị (Equipment Replacement Problem)

Trong quản lý vận hành máy móc công nghiệp, thiết bị qua thời gian sử dụng sẽ bị hao mòn, dẫn đến chi phí vận hành và bảo trì (O&M — Operation and Maintenance) tăng cao. Việc thay thế bằng thiết bị mới giúp giảm chi phí O&M nhưng lại đòi hỏi chi phí đầu tư vốn cố định ban đầu cao. Bài toán đặt ra là lập kế hoạch thay thế thiết bị định kỳ trong vòng 5 năm tới sao cho tổng chi phí là nhỏ nhất.

**Cấu trúc Chi phí**

- \(p_j\): Chi phí mua thiết bị mới trong năm \(j\).
- \(s_{j-i}\): Giá trị thanh lý/còn lại của thiết bị sau \(j-i\) năm sử dụng.
- \(c_\tau\): Chi phí O&M trong năm thứ \(\tau\) hoạt động.

**Thông số Dữ liệu bổ sung — giả định**

- Chi phí mua thiết bị mới: \(p_j=100\) triệu đồng, với \(j=1,\ldots,5\).

| Số năm sử dụng \(\tau\) | Giá trị thanh lý \(s_\tau\) (triệu đồng) | Chi phí O&M \(c_\tau\) (triệu đồng) |
|---|---:|---:|
| 1 | 60 | 10 |
| 2 | 45 | 20 |
| 3 | 30 | 30 |
| 4 | 20 | 55 |
| 5 | 10 | 80 |

Mua thiết bị mới vào đầu năm 1; có thể thay thế vào đầu các năm tiếp theo. Thiết bị cũ được thanh lý khi thay thế; thiết bị còn lại được thanh lý cuối năm 5. Không xét chiết khấu hoặc chi phí thay thế khác.

---

### 2.4. Bài toán Lưu trữ Sách trong Thư viện (Library Book Storage Problem)

Một thư viện có không gian lưu trữ hạn chế cần phân loại và sắp xếp hàng ngàn cuốn sách lên các kệ lưu trữ sao cho tối thiểu hóa diện tích không gian bị lãng phí.

**Nguyên lý Mô hình Hóa**

- Các cuốn sách được phân loại theo chiều cao tăng dần: \(H_1<H_2<\dots<H_n\).
- Chiều dài \(L_i\) của giá cần thiết cho chiều cao \(H_i\) được tính dựa trên độ dày của mỗi cuốn sách.
- Chi phí xây dựng các khu vực giá kệ theo từng hạng chiều cao gồm chi phí cố định \(s_j\) và chi phí biến đổi trên một đơn vị diện tích \(c_j\).

**Thông số Dữ liệu bổ sung — giả định**

| Nhóm sách \(i\) | Chiều cao \(H_i\) (m) | Chiều dài \(L_i\) (m) |
|---|---:|---:|
| 1 | 0.20 | 10 |
| 2 | 0.25 | 10 |
| 3 | 0.30 | 10 |
| 4 | 0.40 | 10 |

- Chi phí cố định: \(s_j=1.5\) triệu đồng/khu kệ.
- Chi phí biến đổi: \(c_j=1\) triệu đồng/m².
- Mỗi khu kệ chứa một hoặc nhiều nhóm chiều cao liên tiếp; chiều cao khu kệ bằng chiều cao lớn nhất trong các nhóm được chứa.
- Chiều dài khu kệ bằng tổng chiều dài của các nhóm được chứa.
- Diện tích kệ bằng chiều cao nhân với chiều dài. Không xét thêm giới hạn kích thước từng ngăn.

Bài toán là tìm tập hợp chiều cao và chiều dài của kệ để **giảm thiểu tổng chi phí giá kệ**, theo mô hình trong slide.

## 3. Bảng Phân loại và Phân tích Tổng hợp các Mô hình Thực tế

| Bài toán Thực tế | Miền Ứng dụng | Mô hình Toán học Sử dụng | Thuật toán / Phương pháp Giải |
| :--- | :--- | :--- | :--- |
| **Vận tải Sản xuất** | Chuỗi cung ứng, Logistics | Quy hoạch tuyến tính (LP) & Đối ngẫu | Thuật toán Đơn hình (Simplex), Đối ngẫu |
| **Khẩu phần Ăn kiêng** | Y tế, Dinh dưỡng, Kinh tế | Quy hoạch tuyến tính (LP) & Đơn giá ẩn | Thuật toán Đơn hình (Simplex), KKT |
| **Luồng Cực đại Mạng lưới** | Giao thông, Viễn thông | Luồng trên mạng (Network Flow) | Đồ thị Mạng, Định lý Max-Flow Min-Cut |
| **Quản lý Nhân lực** | Quản trị dự án, HR | Bài toán Phân công / Luồng mạng | Luồng cực đại trên mạng |
| **Thay thế Thiết bị** | Quản lý tài sản công nghiệp | Đường đi ngắn nhất (Shortest Path) | Thuật toán Dijkstra, Quy hoạch động |
| **Lưu trữ Thư viện** | Quản lý kho bãi, Không gian | Tối ưu hóa rời rạc / Phân hoạch | Quy hoạch tuyến tính / Đơn hình |

---

# LỜI GIẢI

## 1.1 **Bài 1.1 — Vận tải sản xuất** bằng **phương pháp đơn hình**:

- Chuyển \(\min C\) thành \(\max Z\), với \(Z=-C\).
- Viết hàng mục tiêu dưới dạng phương trình chứa \(Z\).
- Chọn biến có hệ số **âm nhất trên hàng \(Z\)** vào cơ sở.
- Chọn biến ra bằng **tỷ số nhỏ nhất với mẫu số dương**.
- Biến đổi Gauss–Jordan; dừng khi hàng \(Z\) không còn hệ số âm ở các cột biến.

Ở đây, \(C\) là **chi phí thực tế**, còn \(Z\) là **hàm mục tiêu đã đổi dấu**.

---

**Bước 1. Xác định biến quyết định và lập mô hình**

Dữ liệu bài toán:

| Nhà kho | Cửa hàng \(R_1\) | Cửa hàng \(R_2\) | Cửa hàng \(R_3\) | Nguồn cung tối đa |
|---|---:|---:|---:|---:|
| \(W_1\) | 2 | 4 | 3 | 300 |
| \(W_2\) | 5 | 3 | 4 | 600 |
| Nhu cầu tối thiểu | 200 | 300 | 400 | |

Gọi:

\[
x_{ij}=\text{số sản phẩm vận chuyển từ kho }W_i
\text{ đến cửa hàng }R_j,\qquad x_{ij}\ge0.
\]

Tổng chi phí vận chuyển là:

\[
C=2x_{11}+4x_{12}+3x_{13}
+5x_{21}+3x_{22}+4x_{23}.
\]

Bài toán gốc:

\[
\boxed{\min C}
\]

với các ràng buộc:

\[
\begin{cases}
x_{11}+x_{12}+x_{13}\le300, & \text{nguồn cung kho }W_1,\\
x_{21}+x_{22}+x_{23}\le600, & \text{nguồn cung kho }W_2,\\
x_{11}+x_{21}\ge200, & \text{nhu cầu cửa hàng }R_1,\\
x_{12}+x_{22}\ge300, & \text{nhu cầu cửa hàng }R_2,\\
x_{13}+x_{23}\ge400, & \text{nhu cầu cửa hàng }R_3,\\
x_{ij}\ge0.
\end{cases}
\]

Ví dụ, \(x_{11}+x_{21}\ge200\) nghĩa là tổng hàng \(R_1\) nhận từ hai kho phải đạt ít nhất 200 sản phẩm.

---

**Bước 2. Chuyển bài toán cực tiểu về cực đại**

Đặt:

\[
Z=-C.
\]

Ta giải bài toán tương đương:

\[
\boxed{
\max Z=-2x_{11}-4x_{12}-3x_{13}
-5x_{21}-3x_{22}-4x_{23}.
}
\]

**Các ràng buộc giữ nguyên.** Việc đổi dấu hàm mục tiêu không làm thay đổi các phương án vận chuyển được phép.

Chẳng hạn:

\[
C=3200\Rightarrow Z=-3200,
\qquad
C=2800\Rightarrow Z=-2800.
\]

Vì \(-2800>-3200\), làm \(Z\) lớn hơn chính là làm chi phí \(C\) nhỏ hơn.

Cuối bài phải đổi lại:

\[
\boxed{C_{\min}=-Z_{\max}.}
\]

---

**Bước 3. Đưa các ràng buộc về phương trình**

Trong bài này:

\[
\text{Tổng cung tối đa}=300+600=900,
\]
\[
\text{Tổng cầu tối thiểu}=200+300+400=900.
\]

Gọi \(T\) là tổng lượng hàng vận chuyển. Các ràng buộc nguồn cung cho \(T\le900\), trong khi các ràng buộc nhu cầu cho \(T\ge900\). Vì vậy:

\[
T=900.
\]

Điều này buộc **mỗi kho xuất hết nguồn cung và mỗi cửa hàng nhận đúng nhu cầu**. Nếu một kho xuất thiếu, tổng lượng hàng sẽ nhỏ hơn 900; nếu một cửa hàng nhận dư, tổng lượng hàng sẽ lớn hơn 900.

Do đó, hệ ràng buộc tương đương là:

\[
\begin{cases}
x_{11}+x_{12}+x_{13}=300,\\
x_{21}+x_{22}+x_{23}=600,\\
x_{11}+x_{21}=200,\\
x_{12}+x_{22}=300,\\
x_{13}+x_{23}=400.
\end{cases}
\]

**Vì sao không thêm biến bù như ví dụ trong bản tóm tắt?**

Ví dụ trong tài liệu dùng biến bù để chuyển bất đẳng thức thành phương trình và tạo cơ sở ban đầu. Ở đây, tính cân bằng cung–cầu đã cho phép chuyển trực tiếp sang phương trình. Ta sẽ tìm được cơ sở khả thi từ chính các biến vận chuyển.

Ngoài ra, năm phương trình trên có một phương trình phụ thuộc. Cộng ba phương trình nhu cầu rồi trừ phương trình nguồn cung của \(W_1\), ta được:

\[
x_{21}+x_{22}+x_{23}=900-300=600.
\]

Vì thế, có thể bỏ phương trình nguồn cung của \(W_2\), giữ bốn phương trình độc lập:

\[
\begin{cases}
x_{11}+x_{12}+x_{13}=300,\\
x_{11}+x_{21}=200,\\
x_{12}+x_{22}=300,\\
x_{13}+x_{23}=400.
\end{cases}
\]

---

**Bước 4. Xác định nghiệm cơ sở khả thi ban đầu**

Biểu diễn bốn biến theo \(x_{11},x_{12}\):

\[
\begin{aligned}
x_{13}&=300-x_{11}-x_{12},\\
x_{21}&=200-x_{11},\\
x_{22}&=300-x_{12},\\
x_{23}&=400-x_{13}
       =100+x_{11}+x_{12}.
\end{aligned}
\]

Chọn:

- **Biến không cơ sở:** \(x_{11},x_{12}\).
- **Biến cơ sở:** \(x_{13},x_{21},x_{22},x_{23}\).

Đặt các biến không cơ sở bằng 0:

\[
x_{11}=x_{12}=0.
\]

Khi đó:

\[
x_{13}=300,\quad x_{21}=200,\quad
x_{22}=300,\quad x_{23}=100.
\]

Tất cả đều không âm, nên đây là **nghiệm cơ sở khả thi**.

“Biến không cơ sở bằng 0” là cách xác định phương án tại một bước đơn hình, **không phải yêu cầu cố định các biến đó bằng 0 trong toàn bộ bài toán**. Sau phép xoay, chúng có thể trở thành biến cơ sở.

Viết hệ phương trình theo cơ sở vừa chọn:

\[
\begin{aligned}
R_1:\quad x_{11}+x_{12}+x_{13}&=300,\\
R_2:\quad x_{11}+x_{21}&=200,\\
R_3:\quad x_{12}+x_{22}&=300,\\
R_4:\quad -x_{11}-x_{12}+x_{23}&=100.
\end{aligned}
\]

Các cột \(x_{13},x_{21},x_{22},x_{23}\) tạo thành ma trận đơn vị, đúng yêu cầu của bảng đơn hình.

---

**Bước 5. Đưa hàng mục tiêu về dạng chính tắc**

Từ hàm mục tiêu đã đổi dấu:

\[
Z=-2x_{11}-4x_{12}-3x_{13}
-5x_{21}-3x_{22}-4x_{23},
\]

chuyển tất cả các biến sang vế trái:

\[
R_Z:\quad
Z+2x_{11}+4x_{12}+3x_{13}
+5x_{21}+3x_{22}+4x_{23}=0.
\]

**Chưa được kiểm tra tối ưu ngay trên hàng này**, vì hệ số của các biến cơ sở trên hàng \(Z\) chưa bằng 0.

Ta phải khử bốn biến cơ sở:

\[
\boxed{
R_Z\leftarrow R_Z-3R_1-5R_2-3R_3-4R_4.
}
\]

Tính từng hệ số còn lại:

- Tại cột \(x_{11}\):

\[
2-3(1)-5(1)-3(0)-4(-1)=-2.
\]

- Tại cột \(x_{12}\):

\[
4-3(1)-5(0)-3(1)-4(-1)=2.
\]

- Vế phải:

\[
0-3(300)-5(200)-3(300)-4(100)=-3200.
\]

Hàng mục tiêu chính tắc là:

\[
\boxed{Z-2x_{11}+2x_{12}=-3200.}
\]

Hay tương đương:

\[
Z=-3200+2x_{11}-2x_{12}.
\]

Công thức này cho thấy: giữ \(x_{12}=0\), mỗi đơn vị tăng thêm của \(x_{11}\) làm \(Z\) tăng 2, miễn phương án vẫn khả thi.

---

**Bước 6. Lập bảng đơn hình ban đầu**

Theo đúng cách trình bày trong bản tóm tắt, đặt hàng \(Z\) ở trên cùng:

| Biến CS | \(Z\) | \(x_{11}\) | \(x_{12}\) | \(x_{13}\) | \(x_{21}\) | \(x_{22}\) | \(x_{23}\) | Phương án \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | 1 | **−2** | 2 | 0 | 0 | 0 | 0 | **−3200** |
| \(x_{13}\) | 0 | 1 | 1 | 1 | 0 | 0 | 0 | 300 |
| \(x_{21}\) | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 200 |
| \(x_{22}\) | 0 | 0 | 1 | 0 | 0 | 1 | 0 | 300 |
| \(x_{23}\) | 0 | −1 | −1 | 0 | 0 | 0 | 1 | 100 |

Giá trị \(-3200\) ở hàng mục tiêu là bình thường vì \(Z=-C\). Điều kiện khả thi yêu cầu **các giá trị biến cơ sở ở các hàng ràng buộc không âm**, không yêu cầu giá trị mục tiêu không âm.

---

**Bước 7. Chọn biến vào cơ sở và biến ra khỏi cơ sở**

**Chọn biến vào cơ sở.**

Trên hàng \(Z\), hệ số âm duy nhất là:

\[
-2\quad\text{tại cột }x_{11}.
\]

Vì vậy:

\[
\boxed{x_{11}\text{ vào cơ sở}.}
\]

**Chọn biến ra khỏi cơ sở.**

Áp dụng quy tắc:

\[
\theta=
\min_i\left\{
\frac{b_i}{a_{i,\mathrm{in}}}
\ \middle|\ a_{i,\mathrm{in}}>0
\right\}.
\]

Cột đang xét là \(x_{11}\):

| Biến cơ sở | Hệ số cột \(x_{11}\) | \(b_i\) | Tỷ số |
|---|---:|---:|---:|
| \(x_{13}\) | 1 | 300 | \(300/1=300\) |
| \(x_{21}\) | 1 | 200 | **\(200/1=200\)** |
| \(x_{22}\) | 0 | 300 | Không xét |
| \(x_{23}\) | −1 | 100 | Không xét |

Do đó:

\[
\theta=\min\{300,200\}=200.
\]

\[
\boxed{x_{21}\text{ ra khỏi cơ sở}.}
\]

Phần tử xoay là số \(1\) tại giao của hàng \(x_{21}\) và cột \(x_{11}\).

**Giải thích giới hạn 200:** khi tăng \(x_{11}\), giữ \(x_{12}=0\), ta có:

\[
x_{13}=300-x_{11}\ge0\Rightarrow x_{11}\le300,
\]

\[
x_{21}=200-x_{11}\ge0\Rightarrow x_{11}\le200.
\]

Ràng buộc thứ hai chạm giới hạn trước. Tại \(x_{11}=200\), biến \(x_{21}=0\), nên nó ra khỏi cơ sở.

Hàng \(x_{23}\) không giới hạn bước tăng vì:

\[
x_{23}=100+x_{11},
\]

tức là \(x_{23}\) tăng, không giảm về 0.

---

**Bước 8. Thực hiện phép xoay Gauss–Jordan**

Hàng xoay \(R_2\) có phần tử xoay bằng 1 nên không cần chia lại:

\[
R_2:\quad x_{11}+x_{21}=200.
\]

Khử \(x_{11}\) ở các hàng khác, **bao gồm hàng mục tiêu**:

\[
\begin{aligned}
R_Z&\leftarrow R_Z+2R_2,\\
R_1&\leftarrow R_1-R_2,\\
R_3&\leftarrow R_3,\\
R_4&\leftarrow R_4+R_2.
\end{aligned}
\]

Cụ thể:

\[
\begin{aligned}
R_Z:\quad Z+2x_{12}+2x_{21}&=-2800,\\
R_1:\quad x_{12}+x_{13}-x_{21}&=100,\\
R_2:\quad x_{11}+x_{21}&=200,\\
R_3:\quad x_{12}+x_{22}&=300,\\
R_4:\quad -x_{12}+x_{21}+x_{23}&=300.
\end{aligned}
\]

Trong đó hàng \(R_2\) bây giờ có biến cơ sở là \(x_{11}\).

Bảng đơn hình mới:

| Biến CS | \(Z\) | \(x_{11}\) | \(x_{12}\) | \(x_{13}\) | \(x_{21}\) | \(x_{22}\) | \(x_{23}\) | Phương án \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | 1 | 0 | **2** | 0 | **2** | 0 | 0 | **−2800** |
| \(x_{13}\) | 0 | 0 | 1 | 1 | −1 | 0 | 0 | 100 |
| \(x_{11}\) | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 200 |
| \(x_{22}\) | 0 | 0 | 1 | 0 | 0 | 1 | 0 | 300 |
| \(x_{23}\) | 0 | 0 | −1 | 0 | 1 | 0 | 1 | 300 |

---

**Bước 9. Kiểm tra điều kiện dừng**

Trên hàng \(Z\), các hệ số ở những cột biến đều không âm:

\[
0,\ 2,\ 0,\ 2,\ 0,\ 0.
\]

Theo quy tắc cho bài toán cực đại trong bản tóm tắt:

\[
\boxed{\text{Dừng thuật toán: phương án hiện tại tối ưu}.}
\]

Có thể hiểu trực tiếp từ hàng mục tiêu:

\[
Z+2x_{12}+2x_{21}=-2800,
\]

hay:

\[
Z=-2800-2x_{12}-2x_{21}.
\]

Vì \(x_{12},x_{21}\ge0\), nên:

\[
Z\le-2800.
\]

Dấu bằng đạt được khi:

\[
x_{12}=x_{21}=0.
\]

**Lưu ý:** các số \(-1\) còn xuất hiện ở những hàng ràng buộc không làm thuật toán phải tiếp tục. Điều kiện chọn biến vào và dừng được kiểm tra trên **hàng mục tiêu \(Z\)**.

---

**Bước 10. Đọc nghiệm và đổi lại chi phí ban đầu**

Đặt các biến không cơ sở bằng 0:

\[
x_{12}=x_{21}=0.
\]

Đọc các biến cơ sở từ cột \(b\):

\[
x_{11}=200,\qquad x_{13}=100,\qquad
x_{22}=300,\qquad x_{23}=300.
\]

Phương án vận chuyển:

| Nhà kho | Cửa hàng \(R_1\) | Cửa hàng \(R_2\) | Cửa hàng \(R_3\) | Tổng xuất |
|---|---:|---:|---:|---:|
| \(W_1\) | 200 | 0 | 100 | 300 |
| \(W_2\) | 0 | 300 | 300 | 600 |
| **Tổng nhận** | **200** | **300** | **400** | **900** |

Giá trị cực đại của hàm đã đổi dấu:

\[
Z_{\max}=-2800.
\]

Đổi lại chi phí thực tế:

\[
\boxed{C_{\min}=-Z_{\max}=2800.}
\]

Kiểm tra bằng cách thế vào hàm chi phí ban đầu:

\[
\begin{aligned}
C
&=2(200)+4(0)+3(100)+5(0)+3(300)+4(300)\\
&=400+300+900+1200\\
&=\boxed{2800}.
\end{aligned}
\]

Như vậy, kho \(W_1\) giao 200 sản phẩm cho \(R_1\) và 100 sản phẩm cho \(R_3\); kho \(W_2\) giao 300 sản phẩm cho \(R_2\) và 300 sản phẩm cho \(R_3\). Tất cả nguồn cung và nhu cầu đều được thỏa mãn.

## 1.2 **Bài 1.2 — Khẩu phần ăn kiêng** bằng **đơn hình**:

> Với bài toán **Maximize**, chọn hệ số âm nhất trên hàng mục tiêu làm cột xoay; chọn hàng xoay bằng tỷ số nhỏ nhất có mẫu số dương; dừng khi hàng mục tiêu không còn hệ số âm.

Bài này có các ràng buộc dạng \(\ge\). Nếu đổi trực tiếp \(\min C\) thành \(\max(-C)\), các ràng buộc vẫn là \(\ge\), nên chưa có ngay cơ sở khả thi bằng biến bù như ví dụ trong tài liệu.

Vì vậy, ta **lập bài toán đối ngẫu dạng Maximize với các ràng buộc \(\le\)**, giải bằng bảng đơn hình, rồi suy ra khẩu phần tối ưu. Đây là cách kết hợp phần **đối ngẫu ở Week 6** với **đơn hình ở Week 5**.

---

**Bước 1. Lập bài toán gốc**

Gọi:

\[
\begin{aligned}
x_1&=\text{số phần bánh brownie},\\
x_2&=\text{số scoop kem chocolate},\\
x_3&=\text{số chai cola},\\
x_4&=\text{số miếng pineapple cheesecake}.
\end{aligned}
\]

Các biến đều không âm.

Chi phí cần tối thiểu hóa:

\[
\boxed{\min C=50x_1+20x_2+30x_3+80x_4.}
\]

Các ràng buộc:

\[
\begin{cases}
400x_1+200x_2+150x_3+500x_4\ge500,
&\text{Calo},\\
3x_1+2x_2\ge6,
&\text{Chocolate},\\
2x_1+2x_2+4x_3+4x_4\ge10,
&\text{Đường},\\
2x_1+4x_2+x_3+5x_4\ge8,
&\text{Chất béo},\\
x_1,x_2,x_3,x_4\ge0.
\end{cases}
\]

---

**Bước 2. Lập bài toán đối ngẫu dạng cực đại**

Quy tắc đối ngẫu áp dụng ở đây là:

\[
\begin{aligned}
\text{Gốc:}\quad&
\min \mathbf c^T\mathbf x,
\quad A\mathbf x\ge\mathbf b,\quad \mathbf x\ge0,\\
\text{Đối ngẫu:}\quad&
\max \mathbf b^T\mathbf y,
\quad A^T\mathbf y\le\mathbf c,\quad \mathbf y\ge0.
\end{aligned}
\]

Đặt \(y_1,y_2,y_3,y_4\ge0\) tương ứng với bốn yêu cầu calo, chocolate, đường và chất béo.

Bài toán đối ngẫu:

\[
\boxed{\max Z=500y_1+6y_2+10y_3+8y_4}
\]

với:

\[
\begin{cases}
400y_1+3y_2+2y_3+2y_4\le50,
&\text{Brownie},\\
200y_1+2y_2+2y_3+4y_4\le20,
&\text{Kem},\\
150y_1+4y_3+y_4\le30,
&\text{Cola},\\
500y_1+4y_3+5y_4\le80,
&\text{Cheesecake}.
\end{cases}
\]

**Cách hình thành một ràng buộc:** brownie chứa 400 calo, 3 oz chocolate, 2 oz đường và 2 oz chất béo, giá 50 cents. Vì vậy:

\[
400y_1+3y_2+2y_3+2y_4\le50.
\]

Mỗi thực phẩm tạo ra một ràng buộc đối ngẫu.

**Lưu ý về đổi dấu:** đây là chuyển sang **bài toán đối ngẫu**, không phải đặt \(Z=-C\). Khi tìm được nghiệm tối ưu, ta sẽ có:

\[
\boxed{C_{\min}=Z_{\max}.}
\]

---

**Bước 3. Thêm biến bù và lập bảng ban đầu**

Thêm \(s_1,s_2,s_3,s_4\ge0\):

\[
\begin{cases}
400y_1+3y_2+2y_3+2y_4+s_1=50,\\
200y_1+2y_2+2y_3+4y_4+s_2=20,\\
150y_1+4y_3+y_4+s_3=30,\\
500y_1+4y_3+5y_4+s_4=80.
\end{cases}
\]

Hàng mục tiêu:

\[
Z-500y_1-6y_2-10y_3-8y_4=0.
\]

Đặt \(y_1=y_2=y_3=y_4=0\), ta được:

\[
s_1=50,\quad s_2=20,\quad s_3=30,\quad s_4=80.
\]

Các biến bù tạo thành cơ sở khả thi ban đầu, đúng như ví dụ trong bản tóm tắt.

Trong các bảng dưới, **lược bỏ cột \(Z\)** để bảng gọn hơn: cột này luôn bằng 1 ở hàng mục tiêu và bằng 0 ở các hàng ràng buộc.

| Biến CS | \(y_1\) | \(y_2\) | \(y_3\) | \(y_4\) | \(s_1\) | \(s_2\) | \(s_3\) | \(s_4\) | \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | **−500** | −6 | −10 | −8 | 0 | 0 | 0 | 0 | 0 |
| \(s_1\) | 400 | 3 | 2 | 2 | 1 | 0 | 0 | 0 | 50 |
| \(s_2\) | 200 | 2 | 2 | 4 | 0 | 1 | 0 | 0 | 20 |
| \(s_3\) | 150 | 0 | 4 | 1 | 0 | 0 | 1 | 0 | 30 |
| \(s_4\) | 500 | 0 | 4 | 5 | 0 | 0 | 0 | 1 | 80 |

---

**Bước 4. Lần xoay thứ nhất: đưa \(y_1\) vào cơ sở**

Hệ số âm nhất trên hàng \(Z\) là \(-500\), nên chọn \(y_1\) vào cơ sở.

Tỷ số:

| Hàng | Tỷ số \(b_i/a_{i,y_1}\) |
|---|---:|
| \(s_1\) | \(50/400=1/8\) |
| \(s_2\) | **\(20/200=1/10\)** |
| \(s_3\) | \(30/150=1/5\) |
| \(s_4\) | \(80/500=4/25\) |

Tỷ số nhỏ nhất là \(1/10\), nên:

\[
\boxed{y_1\text{ vào},\quad s_2\text{ ra},\quad
\text{phần tử xoay}=200.}
\]

Gọi các hàng ràng buộc theo thứ tự là \(R_1,\ldots,R_4\). Chuẩn hóa hàng xoay:

\[
R_2'\leftarrow\frac{R_2}{200}.
\]

Sau đó:

\[
\begin{aligned}
R_Z'&=R_Z+500R_2',\\
R_1'&=R_1-400R_2',\\
R_3'&=R_3-150R_2',\\
R_4'&=R_4-500R_2'.
\end{aligned}
\]

Ví dụ, hệ số \(y_2\) trên hàng mục tiêu mới là:

\[
-6+500\left(\frac{2}{200}\right)=-1.
\]

Bảng sau lần xoay thứ nhất:

| Biến CS | \(y_1\) | \(y_2\) | \(y_3\) | \(y_4\) | \(s_1\) | \(s_2\) | \(s_3\) | \(s_4\) | \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | 0 | −1 | **−5** | 2 | 0 | \(5/2\) | 0 | 0 | **50** |
| \(s_1\) | 0 | −1 | −2 | −6 | 1 | −2 | 0 | 0 | 10 |
| \(y_1\) | 1 | \(1/100\) | \(1/100\) | \(1/50\) | 0 | \(1/200\) | 0 | 0 | \(1/10\) |
| \(s_3\) | 0 | \(-3/2\) | \(5/2\) | −2 | 0 | \(-3/4\) | 1 | 0 | 15 |
| \(s_4\) | 0 | −5 | −1 | −5 | 0 | \(-5/2\) | 0 | 1 | 30 |

Hiện tại \(Z=50\), nhưng hàng \(Z\) vẫn còn hệ số âm nên tiếp tục.

---

**Bước 5. Lần xoay thứ hai: đưa \(y_3\) vào cơ sở**

Hệ số âm nhất trên hàng \(Z\) là \(-5\) tại cột \(y_3\).

Chỉ xét các hàng có hệ số **dương** tại cột này:

| Hàng | Hệ số cột \(y_3\) | \(b_i\) | Tỷ số |
|---|---:|---:|---:|
| \(s_1\) | −2 | 10 | Không xét |
| \(y_1\) | \(1/100\) | \(1/10\) | \(10\) |
| \(s_3\) | \(5/2\) | 15 | **\(6\)** |
| \(s_4\) | −1 | 30 | Không xét |

Do đó:

\[
\boxed{y_3\text{ vào},\quad s_3\text{ ra},\quad
\text{phần tử xoay}=\frac52.}
\]

Chuẩn hóa hàng xoay:

\[
R_3'\leftarrow\frac{R_3}{5/2}=\frac25R_3.
\]

Khử cột \(y_3\):

\[
\begin{aligned}
R_Z'&=R_Z+5R_3',\\
R_1'&=R_1+2R_3',\\
R_2'&=R_2-\frac1{100}R_3',\\
R_4'&=R_4+R_3'.
\end{aligned}
\]

Bảng mới:

| Biến CS | \(y_1\) | \(y_2\) | \(y_3\) | \(y_4\) | \(s_1\) | \(s_2\) | \(s_3\) | \(s_4\) | \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | 0 | **−4** | 0 | −2 | 0 | 1 | 2 | 0 | **80** |
| \(s_1\) | 0 | \(-11/5\) | 0 | \(-38/5\) | 1 | \(-13/5\) | \(4/5\) | 0 | 22 |
| \(y_1\) | 1 | \(2/125\) | 0 | \(7/250\) | 0 | \(1/125\) | \(-1/250\) | 0 | \(1/25\) |
| \(y_3\) | 0 | \(-3/5\) | 1 | \(-4/5\) | 0 | \(-3/10\) | \(2/5\) | 0 | 6 |
| \(s_4\) | 0 | \(-28/5\) | 0 | \(-29/5\) | 0 | \(-14/5\) | \(2/5\) | 1 | 36 |

Giá trị mục tiêu tăng từ 50 lên 80. Hàng \(Z\) vẫn còn hệ số âm nên chưa tối ưu.

---

**Bước 6. Lần xoay thứ ba: đưa \(y_2\) vào cơ sở**

Hệ số âm nhất trên hàng \(Z\) là \(-4\), tại cột \(y_2\).

Trong cột này, chỉ hàng \(y_1\) có hệ số dương:

\[
a_{y_1,y_2}=\frac{2}{125}.
\]

Tỷ số:

\[
\theta=\frac{1/25}{2/125}
=\frac1{25}\cdot\frac{125}{2}
=\frac52.
\]

Vậy:

\[
\boxed{y_2\text{ vào},\quad y_1\text{ ra},\quad
\text{phần tử xoay}=\frac{2}{125}.}
\]

Chuẩn hóa hàng xoay:

\[
R_2'\leftarrow\frac{R_2}{2/125}
=\frac{125}{2}R_2.
\]

Khử cột \(y_2\):

\[
\begin{aligned}
R_Z'&=R_Z+4R_2',\\
R_1'&=R_1+\frac{11}{5}R_2',\\
R_3'&=R_3+\frac35R_2',\\
R_4'&=R_4+\frac{28}{5}R_2'.
\end{aligned}
\]

Bảng sau lần xoay thứ ba:

| Biến CS | \(y_1\) | \(y_2\) | \(y_3\) | \(y_4\) | \(s_1\) | \(s_2\) | \(s_3\) | \(s_4\) | \(b\) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **\(Z\)** | **250** | 0 | 0 | **5** | 0 | **3** | **1** | 0 | **90** |
| \(s_1\) | \(275/2\) | 0 | 0 | \(-15/4\) | 1 | \(-3/2\) | \(1/4\) | 0 | \(55/2\) |
| \(y_2\) | \(125/2\) | 1 | 0 | \(7/4\) | 0 | \(1/2\) | \(-1/4\) | 0 | \(5/2\) |
| \(y_3\) | \(75/2\) | 0 | 1 | \(1/4\) | 0 | 0 | \(1/4\) | 0 | \(15/2\) |
| \(s_4\) | 350 | 0 | 0 | 4 | 0 | 0 | −1 | 1 | 50 |

---

**Bước 7. Kiểm tra tối ưu và đọc nghiệm đối ngẫu**

Hàng \(Z\) không còn hệ số âm ở các cột biến. Vì vậy, dừng thuật toán.

Các biến không cơ sở:

\[
y_1=y_4=s_2=s_3=0.
\]

Đọc các biến cơ sở từ cột \(b\):

\[
y_2=\frac52,\qquad y_3=\frac{15}{2},
\qquad s_1=\frac{55}{2},\qquad s_4=50.
\]

Nghiệm đối ngẫu tối ưu:

\[
\boxed{
(y_1^*,y_2^*,y_3^*,y_4^*)
=(0,2.5,7.5,0).
}
\]

Giá trị mục tiêu:

\[
\boxed{Z_{\max}=90.}
\]

Có thể kiểm tra trực tiếp từ hàng mục tiêu cuối:

\[
Z+250y_1+5y_4+3s_2+s_3=90.
\]

Do các biến đều không âm:

\[
Z\le90.
\]

Nghiệm vừa tìm đạt đúng 90, nên tối ưu.

---

**Bước 8. Tìm khẩu phần bằng điều kiện bù trừ**

Ta cần quay lại các biến thực phẩm \(x_1,x_2,x_3,x_4\).

Điều kiện bù trừ giữa bài toán gốc và đối ngẫu là:

\[
\boxed{x_js_j=0}
\]

và:

\[
\boxed{
y_i\left[(A\mathbf x)_i-b_i\right]=0.
}
\]

Ý nghĩa:

- Nếu một ràng buộc đối ngẫu còn dư, thì lượng thực phẩm tương ứng phải bằng 0 ở nghiệm tối ưu.
- Nếu một biến đối ngẫu dương, thì yêu cầu dinh dưỡng tương ứng phải đạt đúng mức tối thiểu.

**Xác định các thực phẩm không dùng.**

Ta có:

\[
s_1=\frac{55}{2}>0.
\]

Do \(x_1s_1=0\):

\[
x_1=0.
\]

Tương tự:

\[
s_4=50>0\Rightarrow x_4=0.
\]

Vậy khẩu phần tối ưu không dùng brownie và cheesecake.

**Xác định lượng kem và cola.**

Vì:

\[
y_2=2.5>0,
\]

ràng buộc chocolate phải đạt dấu bằng:

\[
3x_1+2x_2=6.
\]

Thay \(x_1=0\):

\[
2x_2=6
\Rightarrow
\boxed{x_2=3}.
\]

Vì:

\[
y_3=7.5>0,
\]

ràng buộc đường phải đạt dấu bằng:

\[
2x_1+2x_2+4x_3+4x_4=10.
\]

Thay \(x_1=x_4=0,\ x_2=3\):

\[
6+4x_3=10
\Rightarrow
\boxed{x_3=1}.
\]

Thu được:

\[
\boxed{(x_1,x_2,x_3,x_4)=(0,3,1,0).}
\]

---

**Bước 9. Kiểm tra khả thi và chi phí**

| Thành phần | Lượng nhận được | Mức tối thiểu | Phần dư |
|---|---:|---:|---:|
| Calo | \(200(3)+150(1)=750\) | 500 | 250 |
| Chocolate | \(2(3)=6\) | 6 | 0 |
| Đường | \(2(3)+4(1)=10\) | 10 | 0 |
| Chất béo | \(4(3)+1(1)=13\) | 8 | 5 |

Mọi ràng buộc đều được thỏa mãn.

Chi phí:

\[
C=50(0)+20(3)+30(1)+80(0)=90.
\]

Mặt khác, đối ngẫu yếu cho biết mọi khẩu phần khả thi đều có:

\[
C\ge Z_{\max}=90.
\]

Khẩu phần vừa tìm có chi phí đúng bằng cận dưới đó, nên:

\[
\boxed{
C_{\min}=90\text{ cents/ngày}.
}
\]

**Kết quả:** sử dụng **3 scoop kem chocolate và 1 chai cola**, không dùng brownie hoặc pineapple cheesecake. Đây là nghiệm tối ưu của mô hình với các yêu cầu dinh dưỡng đã cho.

### NOTE: Câu hỏi: Vì sao phải dùng đối ngẫu? Có thể dùng minimize để giải đơn hình không?

**Không bắt buộc dùng đối ngẫu. Có thể giải trực tiếp bài toán Minimize bằng phương pháp đơn hình.** Chọn đối ngẫu ở lời giải trước vì thuận tiện khi lập cơ sở ban đầu, chứ không phải vì đơn hình chỉ giải được Maximize.

Có **hai vấn đề riêng biệt** cần phân biệt.

**1. Hàm mục tiêu là Minimize hay Maximize**

Đơn hình giải được cả hai. Tuy nhiên, để giữ đúng quy tắc trong bản tóm tắt, ta chuyển:

\[
\min C
\quad\Longleftrightarrow\quad
\max Z=-C.
\]

Với bài khẩu phần:

\[
\min C=50x_1+20x_2+30x_3+80x_4
\]

được chuyển thành:

\[
\max Z=-50x_1-20x_2-30x_3-80x_4.
\]

**Các ràng buộc giữ nguyên.** Sau khi giải:

\[
C_{\min}=-Z_{\max}.
\]

Đây vẫn là **giải trực tiếp bài toán gốc**, không phải lập đối ngẫu.

**2. Làm thế nào có cơ sở khả thi ban đầu?**

Đây mới là điểm khó của bài khẩu phần.

Trong ví dụ ở bản tóm tắt, ràng buộc có dạng:

\[
x_1\le4.
\]

Thêm biến bù \(s_1\ge0\):

\[
x_1+s_1=4.
\]

Đặt \(x_1=0\), ta được \(s_1=4\ge0\). Vì vậy, biến bù tạo được một nghiệm cơ sở khả thi ngay.

Nhưng bài khẩu phần có ràng buộc:

\[
400x_1+200x_2+150x_3+500x_4\ge500.
\]

Muốn chuyển thành phương trình, phải **trừ biến dư** \(s_1\ge0\):

\[
400x_1+200x_2+150x_3+500x_4-s_1=500.
\]

Nếu đặt tất cả \(x_j=0\), ta có:

\[
-s_1=500
\Rightarrow s_1=-500<0.
\]

**Vậy không thể chọn các biến dư làm cơ sở khả thi ban đầu theo cách đơn giản trong bản tóm tắt.** Việc đổi \(\min C\) thành \(\max(-C)\) không giải quyết được vấn đề này.

---

**3. Nếu giải trực tiếp thì làm thế nào?**

Một cách chuẩn là **đơn hình hai pha**.

Thêm biến giả \(a_1\ge0\) vào phương trình trên:

\[
400x_1+200x_2+150x_3+500x_4-s_1+a_1=500.
\]

Khi \(x_j=0,\ s_1=0\), ta có:

\[
a_1=500\ge0.
\]

Làm tương tự cho bốn ràng buộc, ta có cơ sở ban đầu bằng các biến giả:

\[
a_1=500,\qquad a_2=6,\qquad a_3=10,\qquad a_4=8.
\]

Những biến này chỉ phục vụ tính toán, không phải lượng thực phẩm thực tế.

- **Pha 1:** giải
  \[
  \max Z_{\mathrm I}=-(a_1+a_2+a_3+a_4).
  \]
  Mục tiêu là đưa tất cả biến giả về 0. Nếu đạt giá trị tối ưu bằng 0, ta có nghiệm khả thi của bài gốc; nếu giá trị tối ưu nhỏ hơn 0, bài gốc không khả thi.

- **Pha 2:** loại các biến giả, dùng cơ sở khả thi tìm được để giải
  \[
  \max Z_{\mathrm{II}}
  =-50x_1-20x_2-30x_3-80x_4.
  \]
  Sau đó đổi dấu để lấy chi phí tối thiểu.

Cả hai pha đều có thể dùng quy tắc **chọn hệ số âm nhất trên hàng mục tiêu** như bạn đang học, sau khi đã đưa hàng mục tiêu về dạng chính tắc.

---

**4. Vì sao tôi chọn đối ngẫu ở lời giải trước?**

Vì đối ngẫu của bài này có dạng:

\[
\max \mathbf b^T\mathbf y,
\qquad A^T\mathbf y\le\mathbf c,\qquad \mathbf y\ge0,
\]

với các vế phải \(\mathbf c=(50,20,30,80)^T\) đều dương. Thêm biến bù là có ngay cơ sở khả thi ban đầu, giống ví dụ trong bản tóm tắt.

| Cách giải | Xử lý hàm mục tiêu | Cách khởi tạo |
|---|---|---|
| Giải trực tiếp bài gốc | Đổi \(\min C\) thành \(\max(-C)\) | Có thể dùng đơn hình hai pha |
| Giải qua đối ngẫu | Đối ngẫu đã là Maximize | Thêm biến bù là có cơ sở khả thi ngay |

---

## 2.1 **Bài 2.1 — Luồng cực đại trên mạng nhiều nguồn và nhiều đích**. Ta dùng **quy trình dán nhãn, tìm đường tăng luồng và kiểm chứng bằng lát cắt nhỏ nhất**,.

Bài này có mục tiêu **cực đại hóa lượng hàng vận chuyển**, nên không cần đổi dấu hàm mục tiêu.

---

**Bước 1. Xác định dữ liệu và yêu cầu**

Mạng có:

- Hai nguồn: nút 1 và nút 4, mỗi nguồn cung cấp tối đa 20 đơn vị.
- Hai đích: nút 5 cần 15 đơn vị; nút 8 cần 20 đơn vị.
- Các nút 2, 3, 6, 7 là nút trung chuyển.

Các cung có hướng:

| Cung | Dung lượng | Cung | Dung lượng |
|---|---:|---|---:|
| \(1\to2\) | 10 | \(4\to3\) | 5 |
| \(1\to3\) | 20 | \(4\to6\) | 5 |
| \(3\to2\) | 5 | \(4\to7\) | 5 |
| \(2\to5\) | 15 | \(7\to6\) | 10 |
| \(3\to5\) | 10 | \(6\to5\) | 5 |
| \(3\to6\) | 5 | \(6\to8\) | 10 |
| \(7\to8\) | 10 | — | — |

Tổng cung tối đa:

\[
20+20=40.
\]

Tổng nhu cầu:

\[
15+20=35.
\]

**Tổng cung lớn hơn nhu cầu chưa bảo đảm giao đủ hàng**, vì lượng vận chuyển còn bị giới hạn bởi dung lượng các tuyến.

---

**Bước 2. Thêm siêu nguồn và siêu đích**

Để áp dụng thuật toán một nguồn–một đích, thêm:

- **Siêu nguồn \(\hat s\)**, nối đến hai nguồn thật.
- **Siêu đích \(\hat t\)**, nhận hàng từ hai đích thật.

Các cung bổ sung:

| Cung | Dung lượng | Ý nghĩa |
|---|---:|---|
| \(\hat s\to1\) | 20 | Nguồn 1 cung cấp tối đa 20 |
| \(\hat s\to4\) | 20 | Nguồn 4 cung cấp tối đa 20 |
| \(5\to\hat t\) | 15 | Điểm 5 nhận tối đa nhu cầu 15 |
| \(8\to\hat t\) | 20 | Điểm 8 nhận tối đa nhu cầu 20 |

Bây giờ, ta tìm luồng cực đại từ \(\hat s\) đến \(\hat t\).

**Vì sao dung lượng các cung đến siêu đích bằng nhu cầu?** Để không tính lượng giao thừa ở một cửa hàng thành lượng đáp ứng nhu cầu cho cửa hàng khác.

Nếu tìm được:

\[
F_{\max}=35,
\]

thì cả hai đích đều được đáp ứng đầy đủ.

---

**Bước 3. Đặt biến và các điều kiện của luồng**

Gọi:

\[
f_{ij}=\text{lượng hàng vận chuyển trên cung }i\to j.
\]

Mỗi cung phải thỏa:

\[
\boxed{0\le f_{ij}\le k_{ij}.}
\]

Tại mọi nút ngoài \(\hat s,\hat t\):

\[
\boxed{\text{Tổng luồng vào}=\text{Tổng luồng ra}.}
\]

Ví dụ, tại nút 3:

\[
f_{13}+f_{43}=f_{32}+f_{35}+f_{36}.
\]

Tại nút 6:

\[
f_{36}+f_{46}+f_{76}=f_{65}+f_{68}.
\]

Giá trị luồng toàn mạng:

\[
F=f_{\hat s,1}+f_{\hat s,4}
=f_{5,\hat t}+f_{8,\hat t}.
\]

Mục tiêu:

\[
\boxed{\max F.}
\]

---

**Bước 4. Hiểu quy tắc tìm đường tăng luồng**

Khởi tạo tất cả các luồng bằng 0:

\[
f_{ij}=0.
\]

Khi đang xét một cung \(i\to j\):

- Nếu đi **thuận chiều cung**, còn có thể tăng:
  \[
  k_{ij}-f_{ij}.
  \]
- Nếu đi **ngược chiều một cung đã có luồng**, có thể giảm lượng luồng cũ, tối đa bằng:
  \[
  f_{ij}.
  \]

Đi ngược trong thuật toán có nghĩa là **điều chỉnh lại phân bổ trước đó**, không phải tạo thêm một tuyến vận chuyển thực tế.

Để dán nhãn, có thể ghi cho mỗi nút \(j\):

\[
(\text{nút trước},\ \text{thuận/nghịch},\ \delta_j),
\]

trong đó \(\delta_j\) là lượng luồng có thể tăng dọc đường đã tìm từ nguồn đến \(j\).

Với bước đi thuận từ \(i\) đến \(j\):

\[
\delta_j=\min\{\delta_i,\ k_{ij}-f_{ij}\}.
\]

Khi dán nhãn được \(\hat t\), truy ngược các nút trước để lấy đường tăng luồng. Lượng tăng bằng:

\[
\boxed{\delta=\min\{\text{dung lượng còn lại trên đường}\}.}
\]

Trong bài này, ta có thể đạt nghiệm tối ưu bằng các đường đi thuận dưới đây; không cần dùng bước đi ngược.

---

**Bước 5. Lần tăng luồng thứ nhất**

Chọn đường:

\[
\hat s\to1\to2\to5\to\hat t.
\]

Các dung lượng còn lại ban đầu:

| Cung | Dung lượng còn lại |
|---|---:|
| \(\hat s\to1\) | 20 |
| \(1\to2\) | 10 |
| \(2\to5\) | 15 |
| \(5\to\hat t\) | 15 |

Dán nhãn dọc đường:

\[
\begin{aligned}
1 &: (\hat s,+,20),\\
2 &: (1,+,10),\\
5 &: (2,+,10),\\
\hat t &: (5,+,10).
\end{aligned}
\]

Do đó:

\[
\delta_1=\min\{20,10,15,15\}=10.
\]

Tăng luồng trên mỗi cung của đường thêm 10:

\[
f_{\hat s,1}=f_{12}=f_{25}=f_{5,\hat t}=10.
\]

Tổng luồng:

\[
\boxed{F=10.}
\]

Cung \(1\to2\) đã đầy, nhưng các đường khác vẫn có thể vận chuyển thêm hàng.

---

**Bước 6. Lần tăng luồng thứ hai**

Tìm lại đường tăng luồng trên mạng sau cập nhật. Chọn:

\[
\hat s\to1\to3\to5\to\hat t.
\]

| Cung | Dung lượng còn lại |
|---|---:|
| \(\hat s\to1\) | \(20-10=10\) |
| \(1\to3\) | \(20-0=20\) |
| \(3\to5\) | \(10-0=10\) |
| \(5\to\hat t\) | \(15-10=5\) |

Vậy:

\[
\delta_2=\min\{10,20,10,5\}=5.
\]

Cập nhật:

\[
\begin{aligned}
f_{\hat s,1}&=15,\\
f_{13}&=5,\\
f_{35}&=5,\\
f_{5,\hat t}&=15.
\end{aligned}
\]

Tổng luồng:

\[
\boxed{F=15.}
\]

Cung \(5\to\hat t\) đã đầy, nghĩa là **nhu cầu tại nút 5 đã được đáp ứng đủ**.

---

**Bước 7. Lần tăng luồng thứ ba**

Chọn đường đến đích 8:

\[
\hat s\to1\to3\to6\to8\to\hat t.
\]

| Cung | Dung lượng còn lại |
|---|---:|
| \(\hat s\to1\) | \(20-15=5\) |
| \(1\to3\) | \(20-5=15\) |
| \(3\to6\) | 5 |
| \(6\to8\) | 10 |
| \(8\to\hat t\) | 20 |

Lượng tăng:

\[
\delta_3=\min\{5,15,5,10,20\}=5.
\]

Cập nhật:

\[
\begin{aligned}
f_{\hat s,1}&=20,\\
f_{13}&=10,\\
f_{36}&=5,\\
f_{68}&=5,\\
f_{8,\hat t}&=5.
\end{aligned}
\]

Tổng luồng:

\[
\boxed{F=20.}
\]

Nguồn 1 đã sử dụng hết khả năng cung cấp 20 đơn vị.

---

**Bước 8. Lần tăng luồng thứ tư**

Tiếp tục từ nguồn 4:

\[
\hat s\to4\to6\to8\to\hat t.
\]

| Cung | Dung lượng còn lại |
|---|---:|
| \(\hat s\to4\) | 20 |
| \(4\to6\) | 5 |
| \(6\to8\) | \(10-5=5\) |
| \(8\to\hat t\) | \(20-5=15\) |

Lượng tăng:

\[
\delta_4=\min\{20,5,5,15\}=5.
\]

Cập nhật:

\[
f_{\hat s,4}=5,\quad
f_{46}=5,\quad
f_{68}=10,\quad
f_{8,\hat t}=10.
\]

Tổng luồng:

\[
\boxed{F=25.}
\]

Cung \(6\to8\) đã đầy.

---

**Bước 9. Lần tăng luồng thứ năm**

Chọn đường:

\[
\hat s\to4\to7\to8\to\hat t.
\]

| Cung | Dung lượng còn lại |
|---|---:|
| \(\hat s\to4\) | \(20-5=15\) |
| \(4\to7\) | 5 |
| \(7\to8\) | 10 |
| \(8\to\hat t\) | \(20-10=10\) |

Lượng tăng:

\[
\delta_5=\min\{15,5,10,10\}=5.
\]

Cập nhật:

\[
f_{\hat s,4}=10,\quad
f_{47}=5,\quad
f_{78}=5,\quad
f_{8,\hat t}=15.
\]

Tổng luồng:

\[
\boxed{F=30.}
\]

Sau năm lần tăng, ta đã có **một luồng khả thi bằng 30**. Tuy nhiên, cần kiểm tra xem có thể tăng thêm hay không trước khi kết luận tối ưu.

---

**Bước 10. Dán nhãn lại để kiểm tra điều kiện dừng**

Xét mạng dư, bao gồm cả các bước thuận còn dung lượng và các bước ngược có thể giảm luồng cũ.

Bắt đầu từ \(\hat s\):

1. Đi được đến nút 4 vì cung \(\hat s\to4\) còn \(20-10=10\).
2. Từ 4 đi được đến 3 vì cung \(4\to3\) còn 5.
3. Từ 3 đi được đến 2 và 5 qua các cung thuận còn dung lượng.
4. Từ 3 cũng đi ngược được đến 1 vì cung \(1\to3\) đang có luồng 10.

Tập nút có thể dán nhãn là:

\[
S=\{\hat s,1,2,3,4,5\}.
\]

Không thể đi tiếp từ tập này đến các nút còn lại, vì các cung đi ra đều đầy:

\[
\begin{aligned}
f_{36}&=k_{36}=5,\\
f_{46}&=k_{46}=5,\\
f_{47}&=k_{47}=5,\\
f_{5,\hat t}&=k_{5,\hat t}=15.
\end{aligned}
\]

Cung \(6\to5\) đi theo chiều ngược lại, nhưng đang có luồng 0, nên cũng không thể dùng bước ngược \(5\to6\).

Vì vậy, **không dán nhãn được \(\hat t\)**. Không còn đường tăng luồng; thuật toán dừng.

---

**Bước 11. Xác định lát cắt nhỏ nhất và chứng minh tối ưu**

Chọn:

\[
S=\{\hat s,1,2,3,4,5\},
\]

\[
T=\{6,7,8,\hat t\}.
\]

Các cung đi từ \(S\) sang \(T\):

| Cung qua lát cắt | Dung lượng |
|---|---:|
| \(3\to6\) | 5 |
| \(4\to6\) | 5 |
| \(4\to7\) | 5 |
| \(5\to\hat t\) | 15 |
| **Tổng** | **30** |

Do đó:

\[
C(S,T)=5+5+5+15=30.
\]

**Không cộng cung \(6\to5\)** vì nó đi từ \(T\) về \(S\), không phải từ \(S\) sang \(T\).

Theo bổ đề lát cắt, mọi luồng khả thi đều thỏa:

\[
F\le C(S,T)=30.
\]

Trong khi ta đã xây dựng được luồng:

\[
F=30.
\]

Vậy:

\[
\boxed{F_{\max}=C_{\min}=30.}
\]

Đây là chứng nhận tối ưu: **luồng đạt đúng cận trên do lát cắt đặt ra**.

---

**Bước 12. Trình bày phương án vận chuyển và kết luận**

Luồng cuối cùng trên các cung gốc:

| Cung | Dung lượng \(k_{ij}\) | Luồng tối ưu \(f_{ij}\) |
|---|---:|---:|
| \(1\to2\) | 10 | 10 |
| \(1\to3\) | 20 | 10 |
| \(3\to2\) | 5 | 0 |
| \(2\to5\) | 15 | 10 |
| \(3\to5\) | 10 | 5 |
| \(3\to6\) | 5 | 5 |
| \(4\to3\) | 5 | 0 |
| \(4\to6\) | 5 | 5 |
| \(4\to7\) | 5 | 5 |
| \(7\to6\) | 10 | 0 |
| \(6\to5\) | 5 | 0 |
| \(6\to8\) | 10 | 10 |
| \(7\to8\) | 10 | 5 |

Kiểm tra, chẳng hạn tại nút 3:

\[
\underbrace{f_{13}+f_{43}}_{\text{luồng vào}}
=10+0=10,
\]

\[
\underbrace{f_{32}+f_{35}+f_{36}}_{\text{luồng ra}}
=0+5+5=10.
\]

Lượng hàng giao đến các đích:

| Điểm đích | Nhu cầu | Lượng giao | Thiếu hụt |
|---|---:|---:|---:|
| Nút 5 | 15 | 15 | 0 |
| Nút 8 | 20 | 15 | 5 |
| **Tổng** | **35** | **30** | **5** |

\[
\boxed{\text{Không thể đáp ứng toàn bộ nhu cầu}.}
\]

\[
\boxed{\text{Thiếu hụt nhỏ nhất}=35-30=5\text{ đơn vị hàng hóa}.}
\]

Trong phương án này, nguồn 4 vẫn còn 10 đơn vị chưa xuất được. Tuy nhiên, tăng nguồn cung không giải quyết được thiếu hụt vì giới hạn nằm ở **dung lượng các cung qua lát cắt**, không nằm ở tổng lượng hàng sẵn có.

Còn ba bài: **phân công kỹ sư, thay thế thiết bị và lưu trữ sách**. Ta giải theo các phương pháp trong slide:

- Phân công kỹ sư: **luồng cực đại**.
- Thay thế thiết bị và lưu trữ sách: **đường đi ngắn nhất bằng thuật toán Dijkstra**.

Hai bài cuối sử dụng **bộ số liệu giả định đã bổ sung vào đề**, không phải số liệu gốc của slide.

---

## 2.2 **Bài 2.2. Phân công Nhân lực Kỹ sư**

**Bước 1. Xác định dữ liệu và ý nghĩa của yêu cầu nhân lực**

Công ty có 4 kỹ sư, thực hiện bốn dự án trong 6 tháng:

| Dự án | Tháng bắt đầu sớm nhất | Tháng hoàn thành muộn nhất | Yêu cầu nhân lực, kỹ sư-tháng |
|---|---:|---:|---:|
| A | 1 | 4 | 6 |
| B | 1 | 6 | 8 |
| C | 2 | 5 | 3 |
| D | 1 | 6 | 4 |

Mỗi kỹ sư làm việc một tháng đóng góp **1 kỹ sư-tháng**. Chẳng hạn, dự án A cần 6 kỹ sư-tháng có thể được thực hiện bằng 2 kỹ sư trong 3 tháng.

Các giới hạn:

\[
\text{Tổng kỹ sư được phân công trong mỗi tháng}\le4,
\]

\[
\text{Số kỹ sư cho một dự án trong một tháng}\le2.
\]

Tổng khối lượng phải thực hiện:

\[
6+8+3+4=21\text{ kỹ sư-tháng}.
\]

Tổng nhân lực sẵn có:

\[
4\times6=24\text{ kỹ sư-tháng}.
\]

Tuy \(24\ge21\), **chưa thể kết luận khả thi**, vì còn thời hạn dự án và giới hạn 2 kỹ sư/dự án/tháng.

---

**Bước 2. Xây dựng mạng luồng**

Đặt:

- \(s\): nguồn.
- \(M_1,\ldots,M_6\): các nút đại diện cho tháng 1 đến tháng 6.
- \(A,B,C,D\): các nút dự án.
- \(t\): đích.

Tạo ba nhóm cung.

**Nhóm 1: từ nguồn đến mỗi tháng**

\[
s\to M_i,\qquad k_{s,M_i}=4.
\]

Dung lượng 4 thể hiện công ty chỉ có 4 kỹ sư trong mỗi tháng.

**Nhóm 2: từ tháng đến dự án**

Chỉ nối một tháng với dự án nếu dự án được phép thực hiện trong tháng đó:

| Tháng | Các dự án được phép thực hiện |
|---|---|
| \(M_1\) | A, B, D |
| \(M_2\) | A, B, C, D |
| \(M_3\) | A, B, C, D |
| \(M_4\) | A, B, C, D |
| \(M_5\) | B, C, D |
| \(M_6\) | B, D |

Mỗi cung có dung lượng:

\[
k_{M_i,j}=2.
\]

Ví dụ, không có cung \(M_1\to C\), vì C không được bắt đầu trước tháng 2.

**Nhóm 3: từ dự án đến đích**

\[
k_{A,t}=6,\qquad k_{B,t}=8,\qquad
k_{C,t}=3,\qquad k_{D,t}=4.
\]

Các dung lượng này chính là tổng khối lượng từng dự án.

**Ý nghĩa của một đường đi:**

\[
s\to M_2\to A\to t
\]

mang luồng 2 nghĩa là phân công **2 kỹ sư làm dự án A trong tháng 2**.

---

**Bước 3. Xác định điều kiện hoàn thành tất cả dự án**

Mục tiêu của mạng là:

\[
\max F.
\]

Tổng dung lượng các cung vào đích bằng:

\[
6+8+3+4=21.
\]

Do đó:

\[
F\le21.
\]

Nếu đạt \(F=21\), tất cả bốn cung dự án–đích đều đầy. Khi đó mọi dự án nhận đủ khối lượng nhân lực.

Vì vậy:

\[
\boxed{\text{Lịch phân công khả thi khi và chỉ khi }F_{\max}=21.}
\]

---

**Bước 4. Tìm luồng bằng các đường tăng luồng**

Khởi tạo luồng bằng 0. Mỗi lần chọn đường:

\[
s\to M_i\to j\to t,
\]

lượng tăng là:

\[
\delta=\min\left\{
\begin{array}{l}
\text{nhân lực còn lại của tháng }i,\\
\text{dung lượng còn lại trên cung }M_i\to j,\\
\text{khối lượng còn thiếu của dự án }j
\end{array}
\right\}.
\]

Một trình tự tăng luồng hợp lệ:

| Lần | Đường tăng luồng | \(\delta\) | Tổng luồng \(F\) |
|---|---|---:|---:|
| 1 | \(s\to M_1\to A\to t\) | 2 | 2 |
| 2 | \(s\to M_1\to B\to t\) | 2 | 4 |
| 3 | \(s\to M_2\to A\to t\) | 2 | 6 |
| 4 | \(s\to M_2\to C\to t\) | 2 | 8 |
| 5 | \(s\to M_3\to A\to t\) | 2 | 10 |
| 6 | \(s\to M_3\to B\to t\) | 2 | 12 |
| 7 | \(s\to M_4\to B\to t\) | 2 | 14 |
| 8 | \(s\to M_4\to C\to t\) | 1 | 15 |
| 9 | \(s\to M_4\to D\to t\) | 1 | 16 |
| 10 | \(s\to M_5\to B\to t\) | 2 | 18 |
| 11 | \(s\to M_5\to D\to t\) | 2 | 20 |
| 12 | \(s\to M_6\to D\to t\) | 1 | 21 |

Giải thích hai lần tăng có giá trị 1:

- Ở lần 8, dự án C đã nhận 2 từ tháng 2, chỉ còn thiếu \(3-2=1\), nên chỉ tăng được 1.
- Ở lần 9, tháng 4 đã phân công 2 cho B và 1 cho C, chỉ còn \(4-2-1=1\) kỹ sư.

Mỗi lần tăng đều bảo toàn luồng tại các nút trung gian và không vượt dung lượng.

---

**Bước 5. Đọc lịch phân công**

Luồng trên cung \(M_i\to j\) chính là số kỹ sư làm dự án \(j\) trong tháng \(i\).

| Tháng | A | B | C | D | Tổng phân công | Nhân lực còn lại |
|---|---:|---:|---:|---:|---:|---:|
| 1 | 2 | 2 | 0 | 0 | 4 | 0 |
| 2 | 2 | 0 | 2 | 0 | 4 | 0 |
| 3 | 2 | 2 | 0 | 0 | 4 | 0 |
| 4 | 0 | 2 | 1 | 1 | 4 | 0 |
| 5 | 0 | 2 | 0 | 2 | 4 | 0 |
| 6 | 0 | 0 | 0 | 1 | 1 | 3 |
| **Tổng** | **6** | **8** | **3** | **4** | **21** | **3** |

Kiểm tra:

- Mỗi hàng có tổng không vượt 4.
- Mỗi ô không vượt 2.
- A hoàn thành trước hết tháng 4.
- C chỉ thực hiện trong các tháng 2–5.
- B và D hoàn thành trong 6 tháng.
- Tổng nhân lực mỗi dự án đúng bằng yêu cầu.

Vì các kỹ sư có năng lực tương đương và được phép chuyển dự án giữa các tháng, có thể gán các vị trí trong từng hàng cho những kỹ sư khác nhau mà không bị trùng phân công.

---

**Bước 6. Chứng minh luồng đã cực đại**

Xét lát cắt gồm:

\[
S=\{s,M_1,\ldots,M_6,A,B,C,D\},
\qquad T=\{t\}.
\]

Dung lượng lát cắt:

\[
C(S,T)=6+8+3+4=21.
\]

Ta đã tìm được luồng bằng đúng dung lượng này, nên:

\[
\boxed{F_{\max}=21.}
\]

**Kết luận:** tồn tại phương án phân công đáp ứng tất cả dự án; bảng trên là một phương án như vậy.

Trong đề này, “tối ưu” của mô hình luồng là **đạt tối đa khối lượng được yêu cầu**. Không có tiêu chí phụ để ưu tiên một lịch khả thi hơn lịch khác.

---

## 2.3 **Bài 2.3. Thay thế Thiết bị**

**Bước 1. Nhắc lại dữ liệu**

Thời gian lập kế hoạch là 5 năm. Giá mua máy mới trong mọi năm:

\[
p_i=100\text{ triệu đồng}.
\]

| Tuổi máy \(a\), năm | Giá trị thanh lý \(s_a\) | Chi phí O&M trong năm tuổi \(a\), \(c_a\) |
|---|---:|---:|
| 1 | 60 | 10 |
| 2 | 45 | 20 |
| 3 | 30 | 30 |
| 4 | 20 | 55 |
| 5 | 10 | 80 |

Đơn vị chi phí: triệu đồng.

Mua máy đầu năm 1; có thể thay vào đầu các năm sau; thanh lý máy còn lại cuối năm 5. Không xét chiết khấu.

---

**Bước 2. Chuyển lịch sử dụng máy thành mạng**

Dùng sáu nút:

\[
1,2,3,4,5,6.
\]

Nút \(i\) là **đầu năm \(i\)**. Nút 6 là cuối thời gian kế hoạch, tức cuối năm 5.

Một cung:

\[
i\to j,\qquad j>i
\]

có nghĩa:

> Mua máy ở đầu năm \(i\), sử dụng trong \(j-i\) năm, rồi thanh lý tại mốc \(j\).

Chi phí cung:

\[
\boxed{
d_{ij}=p_i-s_{j-i}+\sum_{\tau=1}^{j-i}c_\tau.
}
\]

Ba thành phần lần lượt là:

\[
\text{Tiền mua máy}
-\text{tiền thu từ thanh lý}
+\text{tổng chi phí O\&M}.
\]

Ví dụ, cung \(1\to3\) nghĩa là dùng máy trong năm 1 và năm 2, thanh lý đầu năm 3:

\[
d_{13}=100-45+(10+20)=85.
\]

**Mỗi đường đi từ 1 đến 6 xác định một lịch thay máy.** Tổng chi phí lịch đó bằng tổng trọng số các cung trên đường.

---

**Bước 3. Tính chi phí các cung**

Do giá mua không đổi và chi phí chỉ phụ thuộc tuổi máy, mọi cung có cùng độ dài thời gian sẽ có cùng chi phí.

| Thời gian giữ máy | Tổng O&M | Chi phí mua − thanh lý + O&M |
|---|---:|---:|
| 1 năm | 10 | \(100-60+10=50\) |
| 2 năm | \(10+20=30\) | \(100-45+30=85\) |
| 3 năm | \(10+20+30=60\) | \(100-30+60=130\) |
| 4 năm | \(60+55=115\) | \(100-20+115=195\) |
| 5 năm | \(115+80=195\) | \(100-10+195=285\) |

Bảng trọng số:

| Từ \(i\) đến \(j\) | 2 | 3 | 4 | 5 | 6 |
|---|---:|---:|---:|---:|---:|
| 1 | 50 | 85 | 130 | 195 | 285 |
| 2 | — | 50 | 85 | 130 | 195 |
| 3 | — | — | 50 | 85 | 130 |
| 4 | — | — | — | 50 | 85 |
| 5 | — | — | — | — | 50 |

Các trọng số đều dương nên áp dụng được Dijkstra.

---

**Bước 4. Quy tắc dán nhãn Dijkstra**

Gọi \(L(j)\) là nhãn khoảng cách của nút \(j\).

- **Nhãn tạm thời:** chi phí nhỏ nhất đã tìm được đến nút đó.
- **Nhãn cố định:** chi phí ngắn nhất đã được xác nhận.

Khởi tạo:

\[
L(1)=0,\qquad L(j)=+\infty\quad(j\ne1).
\]

Mỗi lần cố định một nút \(i\), cập nhật các nút đi đến được từ \(i\):

\[
\boxed{
L(j)\leftarrow\min\{L(j),L(i)+d_{ij}\}.
}
\]

Sau đó chọn nút chưa cố định có nhãn nhỏ nhất để cố định tiếp.

Đồng thời lưu **nút trước** để truy ngược đường đi.

---

**Bước 5. Thực hiện Dijkstra**

**Cố định nút 1.**

Từ nút 1:

\[
L(2)=50,\quad L(3)=85,\quad L(4)=130,
\quad L(5)=195,\quad L(6)=285.
\]

Nhãn nhỏ nhất chưa cố định là \(L(2)=50\).

**Cố định nút 2.**

Cập nhật:

\[
\begin{aligned}
L(3)&=\min\{85,50+50\}=85,\\
L(4)&=\min\{130,50+85\}=130,\\
L(5)&=\min\{195,50+130\}=180,\\
L(6)&=\min\{285,50+195\}=245.
\end{aligned}
\]

Chọn tiếp nút 3, có nhãn 85.

**Cố định nút 3.**

\[
\begin{aligned}
L(4)&=\min\{130,85+50\}=130,\\
L(5)&=\min\{180,85+85\}=170,\\
L(6)&=\min\{245,85+130\}=215.
\end{aligned}
\]

Nút trước của 5 và 6 lúc này đều là nút 3.

Chọn tiếp nút 4, có nhãn 130.

**Cố định nút 4.**

\[
L(5)=\min\{170,130+50\}=170,
\]

\[
L(6)=\min\{215,130+85\}=215.
\]

Đối với nút 6, hai cách cho cùng chi phí:

\[
85+130=130+85=215.
\]

Do đó, lưu cả hai nút trước có thể là **3 hoặc 4**.

**Cố định nút 5.**

\[
L(6)=\min\{215,170+50\}=215.
\]

**Cố định nút 6 và dừng.**

Bảng nhãn tóm tắt; dấu \(*\) chỉ nhãn đã cố định:

| Sau khi cố định | \(L(1)\) | \(L(2)\) | \(L(3)\) | \(L(4)\) | \(L(5)\) | \(L(6)\) |
|---|---:|---:|---:|---:|---:|---:|
| 1 | \(0^*\) | 50 | 85 | 130 | 195 | 285 |
| 2 | \(0^*\) | \(50^*\) | 85 | 130 | 180 | 245 |
| 3 | \(0^*\) | \(50^*\) | \(85^*\) | 130 | 170 | 215 |
| 4 | \(0^*\) | \(50^*\) | \(85^*\) | \(130^*\) | 170 | 215 |
| 5 | \(0^*\) | \(50^*\) | \(85^*\) | \(130^*\) | \(170^*\) | 215 |
| 6 | \(0^*\) | \(50^*\) | \(85^*\) | \(130^*\) | \(170^*\) | \(215^*\) |

---

**Bước 6. Truy ngược lịch thay máy**

Nút 6 có hai nút trước tối ưu.

**Phương án 1:**

\[
6\leftarrow3\leftarrow1
\quad\Rightarrow\quad
\boxed{1\to3\to6}.
\]

Diễn giải:

- Mua máy đầu năm 1.
- Dùng máy trong 2 năm.
- Thanh lý và mua máy mới đầu năm 3.
- Dùng máy mới trong 3 năm, thanh lý cuối năm 5.

Chi phí:

\[
d_{13}+d_{36}=85+130=215.
\]

**Phương án 2:**

\[
6\leftarrow4\leftarrow1
\quad\Rightarrow\quad
\boxed{1\to4\to6}.
\]

Diễn giải:

- Mua máy đầu năm 1.
- Dùng máy trong 3 năm.
- Thanh lý và mua máy mới đầu năm 4.
- Dùng máy mới trong 2 năm, thanh lý cuối năm 5.

Chi phí:

\[
d_{14}+d_{46}=130+85=215.
\]

Vậy:

\[
\boxed{C_{\min}=215\text{ triệu đồng}.}
\]

Đây là bài toán **đường đi ngắn nhất**, nên thuật toán trực tiếp tìm giá trị nhỏ nhất; không cần đổi sang cực đại của hàm đổi dấu như khi dùng bảng đơn hình theo quy ước của bạn.

---

## 2.4 **Bài 2.4. Lưu trữ Sách trong Thư viện**

**Bước 1. Xác định dữ liệu và mục tiêu**

| Nhóm \(i\) | Chiều cao \(H_i\), m | Chiều dài cần thiết \(L_i\), m |
|---|---:|---:|
| 1 | 0.20 | 10 |
| 2 | 0.25 | 10 |
| 3 | 0.30 | 10 |
| 4 | 0.40 | 10 |

Mỗi khu kệ có:

\[
s_j=1.5\text{ triệu đồng/khu},
\]

\[
c_j=1\text{ triệu đồng/m}^2.
\]

Một khu có thể chứa nhiều nhóm chiều cao liên tiếp. Chiều cao khu bằng chiều cao lớn nhất trong nhóm được chứa.

Mục tiêu là:

\[
\boxed{\min\{\text{tổng chi phí cố định}+\text{tổng chi phí theo diện tích}\}.}
\]

Nếu chia nhiều khu, giảm được diện tích dư nhưng tăng chi phí cố định. Nếu gộp nhiều nhóm vào một khu cao, giảm số khu nhưng tăng diện tích sử dụng.

---

**Bước 2. Xây dựng mạng đường đi ngắn nhất**

Tạo các nút:

\[
0,1,2,3,4.
\]

Nút \(i\) biểu thị rằng **đã bố trí xong các nhóm sách từ 1 đến \(i\)**. Nút 0 nghĩa là chưa bố trí nhóm nào.

Cung:

\[
i\to j,\qquad j>i
\]

biểu diễn việc tạo một khu kệ chứa các nhóm:

\[
i+1,i+2,\ldots,j.
\]

Khu đó có:

\[
\text{Chiều cao}=H_j,
\]

\[
\text{Chiều dài}=\sum_{k=i+1}^{j}L_k.
\]

Do đó, chi phí cung là:

\[
\boxed{
d_{ij}=s_j+c_jH_j\sum_{k=i+1}^{j}L_k.
}
\]

Ví dụ:

\[
0\to2
\]

nghĩa là gộp nhóm 1 và 2 vào khu cao \(H_2=0.25\) m, dài \(10+10=20\) m.

Chi phí:

\[
d_{02}=1.5+1(0.25)(20)=6.5.
\]

Một đường đi từ 0 đến 4 phân chia toàn bộ sách thành các khu, không bỏ sót và không lặp nhóm nào.

---

**Bước 3. Tính toàn bộ chi phí cung**

Từ nút 0:

\[
\begin{aligned}
d_{01}&=1.5+0.20(10)=3.5,\\
d_{02}&=1.5+0.25(20)=6.5,\\
d_{03}&=1.5+0.30(30)=10.5,\\
d_{04}&=1.5+0.40(40)=17.5.
\end{aligned}
\]

Từ nút 1:

\[
\begin{aligned}
d_{12}&=1.5+0.25(10)=4.0,\\
d_{13}&=1.5+0.30(20)=7.5,\\
d_{14}&=1.5+0.40(30)=13.5.
\end{aligned}
\]

Từ nút 2:

\[
\begin{aligned}
d_{23}&=1.5+0.30(10)=4.5,\\
d_{24}&=1.5+0.40(20)=9.5.
\end{aligned}
\]

Từ nút 3:

\[
d_{34}=1.5+0.40(10)=5.5.
\]

Bảng trọng số, đơn vị triệu đồng:

| Từ \(i\) đến \(j\) | 1 | 2 | 3 | 4 |
|---|---:|---:|---:|---:|
| 0 | 3.5 | 6.5 | 10.5 | 17.5 |
| 1 | — | 4.0 | 7.5 | 13.5 |
| 2 | — | — | 4.5 | 9.5 |
| 3 | — | — | — | 5.5 |

---

**Bước 4. Áp dụng Dijkstra**

Để tránh nhầm với \(L_i\) là chiều dài kệ, gọi **nhãn khoảng cách** là \(D(i)\).

Khởi tạo:

\[
D(0)=0,\qquad D(1)=D(2)=D(3)=D(4)=+\infty.
\]

**Cố định nút 0.**

Cập nhật:

\[
D(1)=3.5,\quad D(2)=6.5,\quad
D(3)=10.5,\quad D(4)=17.5.
\]

Chọn nút 1 vì có nhãn tạm thời nhỏ nhất.

**Cố định nút 1.**

\[
\begin{aligned}
D(2)&=\min\{6.5,3.5+4.0\}=6.5,\\
D(3)&=\min\{10.5,3.5+7.5\}=10.5,\\
D(4)&=\min\{17.5,3.5+13.5\}=17.0.
\end{aligned}
\]

Chọn nút 2.

**Cố định nút 2.**

\[
D(3)=\min\{10.5,6.5+4.5\}=10.5,
\]

\[
D(4)=\min\{17.0,6.5+9.5\}=16.0.
\]

Nút trước của 4 hiện là nút 2.

Chọn nút 3.

**Cố định nút 3.**

\[
D(4)=\min\{16.0,10.5+5.5\}=16.0.
\]

Có thêm một cách đi đến nút 4 với cùng chi phí, nên lưu cả hai nút trước là 2 và 3.

**Cố định nút 4 và dừng.**

Bảng nhãn:

| Sau khi cố định | \(D(0)\) | \(D(1)\) | \(D(2)\) | \(D(3)\) | \(D(4)\) |
|---|---:|---:|---:|---:|---:|
| 0 | \(0^*\) | 3.5 | 6.5 | 10.5 | 17.5 |
| 1 | \(0^*\) | \(3.5^*\) | 6.5 | 10.5 | 17.0 |
| 2 | \(0^*\) | \(3.5^*\) | \(6.5^*\) | 10.5 | 16.0 |
| 3 | \(0^*\) | \(3.5^*\) | \(6.5^*\) | \(10.5^*\) | 16.0 |
| 4 | \(0^*\) | \(3.5^*\) | \(6.5^*\) | \(10.5^*\) | \(16.0^*\) |

---

**Bước 5. Truy ngược và diễn giải phương án tối ưu**

**Phương án 1: đường đi \(0\to2\to4\).**

- Cung \(0\to2\): nhóm 1–2 dùng chung một khu.
- Cung \(2\to4\): nhóm 3–4 dùng chung một khu.

| Khu | Nhóm sách | Chiều cao | Chiều dài | Diện tích | Chi phí |
|---|---|---:|---:|---:|---:|
| 1 | 1 và 2 | 0.25 m | 20 m | \(0.25(20)=5\) m² | \(1.5+5=6.5\) triệu |
| 2 | 3 và 4 | 0.40 m | 20 m | \(0.40(20)=8\) m² | \(1.5+8=9.5\) triệu |

Tổng:

\[
C=6.5+9.5=16\text{ triệu đồng}.
\]

**Phương án 2: đường đi \(0\to3\to4\).**

- Cung \(0\to3\): nhóm 1–3 dùng chung một khu.
- Cung \(3\to4\): nhóm 4 dùng riêng một khu.

| Khu | Nhóm sách | Chiều cao | Chiều dài | Diện tích | Chi phí |
|---|---|---:|---:|---:|---:|
| 1 | 1, 2 và 3 | 0.30 m | 30 m | \(0.30(30)=9\) m² | \(1.5+9=10.5\) triệu |
| 2 | 4 | 0.40 m | 10 m | \(0.40(10)=4\) m² | \(1.5+4=5.5\) triệu |

Tổng:

\[
C=10.5+5.5=16\text{ triệu đồng}.
\]

Vậy:

\[
\boxed{C_{\min}=16\text{ triệu đồng},}
\]

với hai phương án tối ưu:

\[
\boxed{\{1,2\}\mid\{3,4\}}
\qquad\text{hoặc}\qquad
\boxed{\{1,2,3\}\mid\{4\}}.
\]

Để kiểm tra ý nghĩa kinh tế:

- Gộp tất cả vào một khu cao 0.40 m: chi phí \(17.5\) triệu.
- Mỗi nhóm một khu riêng: chi phí \(3.5+4+4.5+5.5=17.5\) triệu.
- Hai khu theo một trong hai cách trên: chi phí \(16\) triệu.

Phương án tối ưu chấp nhận một phần diện tích dư để giảm số khu phải xây và tổng chi phí cố định.