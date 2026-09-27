from collections.abc import Callable

import numpy as np

# ==========================================
# 1. PHƯƠNG PHÁP SECANT CHO LINE SEARCH
# ==========================================

# Reused
def secant(
    function: Callable[[float], float],
    x_previous: float,
    x_current: float,
    epsilon: float,
) -> tuple[float, int]:
    iteration = 0

    while True:
        denominator = function(x_current) - function(x_previous)
        if denominator == 0:
            raise ZeroDivisionError("The secant slope is zero.")

        x_next = x_current - function(x_current) * (x_current - x_previous) / denominator
        iteration += 1

        if abs(x_next - x_current) < abs(x_current) * epsilon:
            return x_next, iteration

        x_previous, x_current = x_current, x_next

def secant_line_search(
    x,
    d,
    gradient: Callable[[np.ndarray], np.ndarray],
    epsilon=1e-6,
):
    """
    Tìm bước nhảy alpha tối ưu bằng phương pháp Secant.
    Bài toán: Tìm alpha sao cho g(alpha) = Grad_f(x + alpha*d)^T * d = 0
    """
    def g(alpha):
        # Đạo hàm theo hướng d tại điểm x + alpha*d
        return np.dot(gradient(x + alpha * d), d)
    
    alpha, _ = secant(
        function=g,
        x_previous=0.0,
        x_current=1.0,
        epsilon=epsilon,
    )
    return alpha

# ==========================================
# 2. THUẬT TOÁN STEEPEST DESCENT
# ==========================================
def steepest_descent_secant(
    x0,
    function: Callable[[np.ndarray], float],
    gradient: Callable[[np.ndarray], np.ndarray],
    epsilon=1e-6,
    max_iter=1000,
):
    """
    Thuật toán Steepest Descent sử dụng Secant cho Line Search.
    """
    x = np.array(x0, dtype=float)
    print(f"Điểm bắt đầu: x = {x}, f(x) = {function(x):.6f}\n")
    
    for k in range(max_iter):
        # Tính gradient và chuẩn
        grad = gradient(x)
        grad_norm = np.linalg.norm(grad) # ||g^(k)||
        
        print(f"Vòng lặp {k}: x = {x}, f(x) = {function(x):.6f}, ||grad|| = {grad_norm:.2e}")
        
        # TIÊU CHÍ DỪNG: ||g^(k)|| <= epsilon
        if grad_norm <= epsilon:
            print(f"\n=> Hội tụ sau {k} vòng lặp!")
            break
            
        # Xác định hướng tìm kiếm (Steepest Descent)
        d = -grad
        
        # Tìm bước nhảy alpha bằng phương pháp Secant
        alpha = secant_line_search(x, d, gradient, epsilon=1e-6)
        
        # Cập nhật điểm mới
        x = x + alpha * d
        
    return x

# ==========================================
# 3. CHẠY CHƯƠNG TRÌNH
# ==========================================
if __name__ == "__main__":
    def function(x: np.ndarray) -> float:
        """Objective function for this run."""
        x1, x2 = x[0], x[1]
        return x1 + 0.5 * x2 + 0.5 * x1**2 + x2**2 + 3

    def gradient(x: np.ndarray) -> np.ndarray:
        """Gradient of the objective function for this run."""
        x1, x2 = x[0], x[1]
        return np.array([1 + x1, 0.5 + 2 * x2])

    # Điểm khởi tạo x^(0) = 0
    x0 = [0.0, 0.0]
    
    # Ngưỡng hội tụ epsilon = 10^-6
    epsilon = 1e-6
    
    # Gọi hàm tối ưu
    x_opt = steepest_descent_secant(x0, function, gradient, epsilon)
    
    print("\n" + "="*40)
    print("KẾT QUẢ CUỐI CÙNG:")
    print(f"Nghiệm tối ưu tìm được: x* = {x_opt}")
    print(f"Giá trị hàm mục tiêu: f(x*) = {function(x_opt):.8f}")
    print("Nghiệm giải tích chính xác: x* = [-1.0, -0.25]")
    print("="*40)