Thành thật xin lỗi bạn vì sự bất tiện này. 

Nguyên nhân là do hệ thống chat của tôi khi hiển thị thì render công thức thành hình ảnh đẹp, nhưng khi bạn **copy (sao chép)** văn bản, nó sẽ copy **mã nguồn thô (raw text)**. Trong mã nguồn đó, hệ thống mặc định dùng cặp dấu `\[` và `\]` cho công thức khối (block), và `\(` `\)` cho công thức dòng (inline), thay vì `$$` và `$`. 

Còn dấu `\\` là cú pháp **bắt buộc** trong LaTeX để xuống dòng khi viết ma trận (matrix) hoặc hệ phương trình. Nếu bạn xóa nó, ma trận sẽ bị dồn thành 1 hàng ngang.

Để bạn dễ dàng copy và paste vào các trình soạn thảo Markdown (như Obsidian, Notion, Jupyter, v.v.), tôi đã **chuyển đổi toàn bộ** nội dung giải BT-1 bằng phương pháp Secant sang định dạng `$` và `$$` theo đúng yêu cầu của bạn dưới đây. Bạn hãy copy phần này nhé:

---

### Khởi tạo chung
Hàm số: $f(x_1, x_2) = x_1 + \frac{1}{2}x_2 + \frac{1}{2}x_1^2 + x_2^2 + 3$

Gradient: $\nabla f(x) = \begin{bmatrix} 1 + x_1 \\ 0.5 + 2x_2 \end{bmatrix}$

Điểm bắt đầu: $x^{(0)} = \begin{bmatrix} 0 \\ 0 \end{bmatrix}$

---

### Vòng lặp 1 (Iteration 1)

**Bước 1: Xác định hướng tìm kiếm**
$$\nabla f(x^{(0)}) = \begin{bmatrix} 1 \\ 0.5 \end{bmatrix} \implies d^{(0)} = -\nabla f(x^{(0)}) = \begin{bmatrix} -1 \\ -0.5 \end{bmatrix}$$

**Bước 2: Dùng Secant để tìm $\alpha_0$**
Ta cần tìm nghiệm của $g(\alpha) = \nabla f(x^{(0)} + \alpha d^{(0)})^T d^{(0)} = 0$.
Điểm $x(\alpha) = \begin{bmatrix} -\alpha \\ -0.5\alpha \end{bmatrix}$.
Gradient tại $x(\alpha)$: $\nabla f(x(\alpha)) = \begin{bmatrix} 1 - \alpha \\ 0.5 - \alpha \end{bmatrix}$.
Hàm đạo hàm theo hướng:
$$g(\alpha) = (1-\alpha)(-1) + (0.5-\alpha)(-0.5) = 1.5\alpha - 1.25$$

*Chọn 2 điểm khởi tạo cho Secant:* $\alpha_0 = 0$ và $\alpha_1 = 1$.
*   Tại $\alpha_0 = 0$: $g(0) = -1.25$
*   Tại $\alpha_1 = 1$: $g(1) = 1.5(1) - 1.25 = 0.25$

Áp dụng công thức Secant:
$$\alpha_2 = 1 - 0.25 \frac{1 - 0}{0.25 - (-1.25)} = 1 - 0.25 \left(\frac{1}{1.5}\right) = 1 - \frac{1}{6} = \frac{5}{6} \approx 0.8333$$

*(Nhận xét: Vì hàm $f$ là toàn phương nên $g(\alpha)$ là hàm bậc nhất. Secant nội suy một đường thẳng qua 2 điểm, mà hàm gốc đã là đường thẳng nên nó tìm ra nghiệm chính xác chỉ sau 1 bước lặp. Kết quả này trùng với công thức giải tích $\alpha_0 = 5/6$).*

**Bước 3: Cập nhật $x^{(1)}$**
$$x^{(1)} = x^{(0)} + \alpha_2 d^{(0)} = \begin{bmatrix} 0 \\ 0 \end{bmatrix} + \frac{5}{6} \begin{bmatrix} -1 \\ -0.5 \end{bmatrix} = \begin{bmatrix} -5/6 \\ -5/12 \end{bmatrix} \approx \begin{bmatrix} -0.8333 \\ -0.4167 \end{bmatrix}$$

---

### Vòng lặp 2 (Iteration 2)

**Bước 1: Xác định hướng tìm kiếm**
$$\nabla f(x^{(1)}) = \begin{bmatrix} 1 - 5/6 \\ 0.5 - 2(5/12) \end{bmatrix} = \begin{bmatrix} 1/6 \\ -1/3 \end{bmatrix} \implies d^{(1)} = \begin{bmatrix} -1/6 \\ 1/3 \end{bmatrix}$$

**Bước 2: Dùng Secant để tìm $\alpha_1$**
Điểm $x(\alpha) = \begin{bmatrix} -5/6 - \alpha/6 \\ -5/12 + \alpha/3 \end{bmatrix}$.
Gradient tại $x(\alpha)$: $\nabla f(x(\alpha)) = \begin{bmatrix} 1/6 - \alpha/6 \\ -1/3 + 2\alpha/3 \end{bmatrix}$.
Hàm đạo hàm theo hướng:
$$g(\alpha) = (1/6 - \alpha/6)(-1/6) + (-1/3 + 2\alpha/3)(1/3)$$
$$g(\alpha) = -1/36 + \alpha/36 - 1/9 + 2\alpha/9 = -5/36 + \alpha/4$$

*Chọn 2 điểm khởi tạo cho Secant:* $\alpha_0 = 0$ và $\alpha_1 = 1$.
*   Tại $\alpha_0 = 0$: $g(0) = -5/36$
*   Tại $\alpha_1 = 1$: $g(1) = -5/36 + 1/4 = 4/36 = 1/9$

Áp dụng công thức Secant:
$$\alpha_2 = 1 - \frac{1}{9} \frac{1 - 0}{1/9 - (-5/36)} = 1 - \frac{1/9}{1/9 + 5/36} = 1 - \frac{1/9}{4/36 + 5/36} = 1 - \frac{1/9}{9/36} = 1 - \frac{1/9}{1/4} = 1 - \frac{4}{9} = \frac{5}{9} \approx 0.5556$$

**Bước 3: Cập nhật $x^{(2)}$**
$$x^{(2)} = x^{(1)} + \alpha_2 d^{(1)} = \begin{bmatrix} -5/6 \\ -5/12 \end{bmatrix} + \frac{5}{9} \begin{bmatrix} -1/6 \\ 1/3 \end{bmatrix} = \begin{bmatrix} -5/6 - 5/54 \\ -5/12 + 5/27 \end{bmatrix} = \begin{bmatrix} -50/54 \\ -25/108 \end{bmatrix} = \begin{bmatrix} -25/27 \\ -25/108 \end{bmatrix} \approx \begin{bmatrix} -0.9259 \\ -0.2315 \end{bmatrix}$$

---

### Kết luận
Sau 2 vòng lặp sử dụng phương pháp Steepest Descent kết hợp tìm kiếm dòng bằng **Secant**, ta thu được nghiệm xấp xỉ:
$$x^{(2)} = \begin{bmatrix} -25/27 \\ -25/108 \end{bmatrix} \approx \begin{bmatrix} -0.9259 \\ -0.2315 \end{bmatrix}$$

**Lưu ý quan trọng:** Trong trường hợp hàm toàn phương cụ thể này, vì $g(\alpha)$ là hàm bậc nhất, phương pháp Secant hội tụ chỉ sau 1 bước lặp phụ (từ $\alpha_0, \alpha_1$ ra luôn $\alpha_2$ chính xác). Nếu hàm phức tạp hơn (ví dụ hàm bậc 4, hàm mũ), ta sẽ cần lặp Secant nhiều lần bên trong mỗi vòng lặp chính để tìm $\alpha$ đủ chính xác.

---

**Mẹo nhỏ:** Đối với các ma trận như $\begin{bmatrix} -1 \\ -0.5 \end{bmatrix}$, dấu `\\` là bắt buộc để LaTeX hiểu là xuống dòng giữa số `-1` và `-0.5`. Nếu bạn muốn viết ma trận trên cùng một hàng để tránh dấu `\\`, bạn có thể viết dưới dạng vector hàng: `[-1, -0.5]^T`. Tuy nhiên, cách viết ma trận cột như trên là chuẩn mực nhất trong tài liệu toán học.