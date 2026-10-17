# Sửa bảng C.3.1 — thêm dòng `% đạt < 1e-6`

#### C.3.1. Kết quả trên hàm Rosenbrock

| dim | Chỉ số | PSO | DE | **GWO** |
|---|---|---|---|---|
| 10 | Median | 6.35 | **0.311** | 6.24 |
| 10 | Best | 2.70 | **0** | 6.05 |
| 10 | Std | 109.9 | 1.55 | **0.331** |
| 10 | % đạt < 1e-6 | 0% | **20%** | 0% |
| 13 | Median | 11.08 | **4.38** | 9.38 |
| 13 | Best | 1.15 | **1.55e-16** | 9.24 |
| 13 | Std | 172.6 | 2.48 | **0.378** |
| 13 | % đạt < 1e-6 | 0% | **3.33333%** | 0% |

**Nhận xét:**

1. **DE cho kết quả tốt nhất** trên Rosenbrock: best đạt đúng $0$ ở dim=10 và $\sim 10^{-16}$ ở dim=13, median nhỏ hơn GWO ~20 lần (dim=10) và ~2.1 lần (dim=13). Tỉ lệ đạt $< 1\text{e-}6$ của DE là **20%** ở dim=10 và **3.33333%** ở dim=13 — trong khi PSO và GWO đều **0%** ở cả hai chiều. Đây là lợi thế cấu trúc của DE/rand/1 — toán tử sai phân $F(X_{r1}-X_{r2})$ di chuyển dọc theo thung lũng Rosenbrock rất hiệu quả.
2. **GWO ổn định nhất** (Std = 0.331 ở dim=10, 0.378 ở dim=13) nhưng hội tụ về cùng một vùng local optimum — min ≈ 6, max chỉ ~9. Đây là hiện tượng "premature convergence" đặc trưng của GWO: ba leaders sớm bị "kẹt" ở một local optimum, kéo cả bầy vào đó.
3. **PSO có variance rất cao** (Std > 150 ở dim=13, best chỉ ~2) — điển hình đuôi nặng; PSO dễ bị "văng" ra khỏi thung lũng.
4. **Khi tăng dim 10 → 13:** GWO chỉ tăng median ~50% (6.24 → 9.38), trong khi DE tăng ~14 lần (0.311 → 4.38). Tỉ lệ đạt $< 1\text{e-}6$ của DE cũng giảm mạnh (20% → **3.33333%**). GWO "chịu chiều" tốt hơn nhưng mức nền đã kém từ đầu. Với Rosenbrock, DE vẫn là lựa chọn số 1.

#### C.3.2. Kết quả trên hàm Rastrigin

| dim | Chỉ số | PSO | DE | **GWO** |
|---|---|---|---|---|
| 10 | Median | 14.92 | 2.98 | **0** |
| 10 | Best | 3.98 | 0 | **0** |
| 10 | % đạt < 1e-6 | 0% | **3.33333%** | **100%** |
| 13 | Median | 19.90 | 4.12 | **0** |
| 13 | Best | 6.96 | 1.57 | **0** |
| 13 | % đạt < 1e-6 | 0% | 0% | **100%** |

**Nhận xét:**

1. **GWO cho kết quả tốt nhất** trên Rastrigin: 100% lần chạy đạt cực tiểu toàn cục $f=0$ ở cả hai chiều — một kết quả rất ấn tượng, trong khi DE chỉ đạt **3.33333%** ở dim=10 và **0%** ở dim=13, còn PSO đều **0%** ở cả hai chiều.
2. **Cơ chế "thoát local optimum" của GWO phát huy tối đa:** vector $C = 2r_2 \in [0,2]$ tạo dao động ngẫu nhiên lớn quanh mỗi leader, giúp bầy "nhảy" qua các đỉnh Rastrigin (mỗi ô vuông đơn vị có một cực tiểu địa phương) rất hiệu quả.
3. **DE và PSO đều kẹt ở local optimum:** DE median ~3 (tương đương mắc ở cực tiểu địa phương bậc 1), PSO median ~15 (mắc ở cực tiểu xa hơn). Nguyên nhân: DE có $CR=0.9$, $F=0.8$ thiên về exploitation, thiếu đa dạng để "nhảy" đỉnh; PSO có quán tính $w=0.86$ cao nhưng vẫn không đủ để thoát khỏi basin of attraction.
4. **GWO "chịu chiều" xuất sắc:** tăng dim 10 → 13 không suy giảm (vẫn 100% đạt $f=0$). So sánh: DE median tăng 38%, PSO median tăng 33%. Riêng DE, tỉ lệ đạt $< 1\text{e-}6$ còn sụt từ **3.33333%** (dim=10) xuống **0%** (dim=13). Đây là điểm mạnh vượt trội của GWO trên landscape đa cực trị — nhờ cơ chế ngẫu nhiên hóa của $C$ không phụ thuộc vào số chiều như crossover của DE (vốn "pha loãng" theo $D$).

#### C.3.3. Kết luận tổng hợp

| Landscape | Thuật toán tốt nhất | Nhì | Kém nhất |
|---|---|---|---|
| **Rosenbrock** (thung lũng hẹp, gần như unimodal) | **DE** | PSO / GWO (ổn định) | PSO (mean/median) |
| **Rastrigin** (đa cực trị mạnh) | **GWO** (vượt trội tuyệt đối) | DE | PSO |

**Kết luận:**

1. **Không có metaheuristic nào là "vạn năng"** — kết quả phụ thuộc mạnh vào landscape của hàm mục tiêu. DE mạnh trên hàm có cấu trúc "thung lũng" như Rosenbrock; GWO mạnh trên hàm "nhiều đỉnh" như Rastrigin.
2. **GWO là lựa chọn đúng cho Rastrigin:** đạt 100% success ở cả hai chiều — vượt trội hoàn toàn so với DE (chỉ **3.33333%** ở dim=10, **0%** ở dim=13) và PSO (**0%** ở cả hai chiều), và không suy giảm khi tăng chiều. Đây là lý do chính khiến GWO được chọn trong phần C.
3. **Trên Rosenbrock, DE vẫn là "vua":** GWO ổn định nhưng hội tụ về local optimum (median ~6–9, không đạt được cực tiểu $f=0$). Do đó, nếu chỉ dùng một thuật toán cho cả hai hàm, DE là lựa chọn an toàn hơn; nhưng nếu ưu tiên hàm đa cực trị (Rastrigin), GWO lại vượt trội hơn.

---
