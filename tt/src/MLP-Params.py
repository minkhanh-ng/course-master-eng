import os
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Đường dẫn tương đối từ vị trí file script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "../files/csv/raw_data_points_train.csv")
TEST_CSV_PATH = os.path.join(BASE_DIR, "../files/csv/raw_data_points_test.csv")

# ============ TIỀN XỬ LÝ DỮ LIỆU ============
def load_data():
    df = pd.read_csv(CSV_PATH, skiprows=2)
    # Cột P5 (D_side), P6 (D_mid), P7 (Q_side), P8 (Q_mid), P9 (Q_in)
    data = df[['P5', 'P6', 'P7', 'P8', 'P9']].to_numpy()
    # Trị tuyệt đối lưu lượng nếu có âm
    data[:, 2] = np.abs(data[:, 2])
    data[:, 3] = np.abs(data[:, 3])
    return data

data = load_data()
X = data[:, :2]  # D_side, D_mid
y = data[:, 2:4] # Q_side, Q_mid
Q_in = data[0, 4]  # 0.023333324 (CONST)

# Thống kê chuẩn hóa dưới dạng torch.tensor để tránh tính toán lai với numpy
X_mean = torch.tensor(X.mean(axis=0), dtype=torch.float32)
X_std = torch.tensor(X.std(axis=0), dtype=torch.float32)
y_mean = torch.tensor(y.mean(axis=0), dtype=torch.float32)
y_std = torch.tensor(y.std(axis=0), dtype=torch.float32)

X_norm = (X - X.mean(axis=0)) / X.std(axis=0)
y_norm = (y - y.mean(axis=0)) / y.std(axis=0)

# Chuyển thành tensor
X_tensor = torch.tensor(X_norm, dtype=torch.float32)
y_tensor = torch.tensor(y_norm, dtype=torch.float32)
Q_in_tensor = torch.tensor(Q_in, dtype=torch.float32)

# Tạo DataLoader (full batch)
dataset = TensorDataset(X_tensor, y_tensor)
loader = DataLoader(dataset, batch_size=len(X), shuffle=True)

# ============ MÔ HÌNH MLP ============
class FlowPredictor(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 32), nn.Tanh(),
            nn.Linear(32, 64), nn.Tanh(),
            nn.Linear(64, 32), nn.Tanh(),
            nn.Linear(32, 2)
        )

    def forward(self, x):
        return self.net(x)

model = FlowPredictor()

# ============ HUẤN LUYỆN CÓ RÀNG BUỘC VẬT LÝ ============
optimizer = optim.Adam(model.parameters(), lr=1e-3)
scheduler = optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=500, factor=0.5)
lambda_phy = 0.1
epochs = 5000
loss_history = []
loss_data_history = []
loss_phy_history = []

for epoch in range(epochs):
    for Xb, yb in loader:
        pred_norm = model(Xb)
        # Data loss (trên giá trị chuẩn hóa)
        loss_data = nn.MSELoss()(pred_norm, yb)
        # Physics loss (trên giá trị thực)
        Q_side_pred = pred_norm[:, 0] * y_std[0] + y_mean[0]
        Q_mid_pred = pred_norm[:, 1] * y_std[1] + y_mean[1]
        mass_residual = Q_side_pred + Q_mid_pred - Q_in_tensor
        loss_phy = torch.mean(mass_residual**2)
        loss = loss_data + lambda_phy * loss_phy

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # Collect losses for plotting
        loss_history.append(loss.item())
        loss_data_history.append(loss_data.item())
        loss_phy_history.append(loss_phy.item())

    scheduler.step(loss)
    if epoch % 500 == 0:
        with torch.no_grad():
            pred_all = model(X_tensor)
            Q_side_all = pred_all[:,0] * y_std[0] + y_mean[0]
            Q_mid_all = pred_all[:,1] * y_std[1] + y_mean[1]
            mass_err = torch.abs(Q_side_all + Q_mid_all - Q_in_tensor).mean().item()
            data_err = nn.MSELoss()(pred_all, y_tensor).item()
        print(f"Epoch {epoch}: Data MSE {data_err:.2e}, Phy Err {mass_err:.2e}, Loss {loss.item():.4e}")

# ============ VẼ ĐỒ THỊ HỘI TỤ (LOSS CONVERGENCE) ============
plt.figure(figsize=(8, 5))
plt.plot(loss_history, label='Total Loss', color='purple', alpha=0.8)
plt.plot(loss_data_history, label='Data MSE Loss', color='blue', linestyle='--', alpha=0.7)
plt.plot([l * lambda_phy for l in loss_phy_history], label='Physics Loss (scaled)', color='green', linestyle=':', alpha=0.7)
plt.yscale('log')
plt.xlabel('Epochs')
plt.ylabel('Loss (Log Scale)')
plt.title('Loss Convergence')
plt.legend()
plt.grid(True, which="both", ls="-", alpha=0.2)
plt.tight_layout()
loss_plot_path = os.path.join(BASE_DIR, "loss_convergence.png")
plt.savefig(loss_plot_path)
print(f"Saved loss convergence plot to: {loss_plot_path}")
plt.close()

# ============ ĐÁNH GIÁ NHANH ============
model.eval()
with torch.no_grad():
    pred_norm = model(X_tensor)
    Q_side_pred = (pred_norm[:, 0] * y_std[0] + y_mean[0]).numpy()
    Q_mid_pred = (pred_norm[:, 1] * y_std[1] + y_mean[1]).numpy()
Q_side_true = y[:, 0]
Q_mid_true = y[:, 1]

plt.figure(figsize=(10,4))
plt.subplot(1,2,1)
plt.scatter(Q_side_true, Q_side_pred, alpha=0.5)
plt.plot([min(Q_side_true), max(Q_side_true)], [min(Q_side_true), max(Q_side_true)], 'r--')
plt.xlabel('True Q_side'); plt.ylabel('Pred Q_side'); plt.title('Q_side')
plt.subplot(1,2,2)
plt.scatter(Q_mid_true, Q_mid_pred, alpha=0.5)
plt.plot([min(Q_mid_true), max(Q_mid_true)], [min(Q_mid_true), max(Q_mid_true)], 'r--')
plt.xlabel('True Q_mid'); plt.ylabel('Pred Q_mid'); plt.title('Q_mid')
plt.tight_layout()
plot_path = os.path.join(BASE_DIR, "evaluation.png")
plt.savefig(plot_path)
print(f"Saved evaluation plot to: {plot_path}")
plt.close()

# ============ ĐÁNH GIÁ TRÊN TẬP TEST ============
print("\n# ============ EVALUATION ON TEST SET ============")
df_test = pd.read_csv(TEST_CSV_PATH, skiprows=2)
data_test = df_test[['P5', 'P6', 'P7', 'P8', 'P9']].to_numpy()
data_test[:, 2] = np.abs(data_test[:, 2])
data_test[:, 3] = np.abs(data_test[:, 3])

X_test = data_test[:, :2]
y_test = data_test[:, 2:4]
Q_in_test = data_test[0, 4]

# Chuẩn hóa theo tham số của tập train (dùng numpy arrays từ training stats)
X_train_mean = X.mean(axis=0)
X_train_std = X.std(axis=0)
y_train_mean = y.mean(axis=0)
y_train_std = y.std(axis=0)

X_test_norm = (X_test - X_train_mean) / X_train_std
y_test_norm = (y_test - y_train_mean) / y_train_std

X_test_tensor = torch.tensor(X_test_norm, dtype=torch.float32)
y_test_tensor = torch.tensor(y_test_norm, dtype=torch.float32)
Q_in_test_tensor = torch.tensor(Q_in_test, dtype=torch.float32)

model.eval()
with torch.no_grad():
    pred_test_norm = model(X_test_tensor)
    Q_side_test_pred = pred_test_norm[:, 0] * y_std[0] + y_mean[0]
    Q_mid_test_pred = pred_test_norm[:, 1] * y_std[1] + y_mean[1]
    
    test_mse = nn.MSELoss()(pred_test_norm, y_test_tensor).item()
    test_mass_err = torch.abs(Q_side_test_pred + Q_mid_test_pred - Q_in_test_tensor).mean().item()
    
    # Tính sai số trên đơn vị thực tế (physical scale)
    y_test_tensor_side = torch.tensor(y_test[:, 0], dtype=torch.float32)
    y_test_tensor_mid = torch.tensor(y_test[:, 1], dtype=torch.float32)
    
    test_mae_side = torch.abs(Q_side_test_pred - y_test_tensor_side).mean().item()
    test_mae_mid = torch.abs(Q_mid_test_pred - y_test_tensor_mid).mean().item()
    test_mse_physical = (nn.MSELoss()(Q_side_test_pred, y_test_tensor_side).item() + 
                         nn.MSELoss()(Q_mid_test_pred, y_test_tensor_mid).item()) / 2

print(f"Test Set - Data MSE (Normalized): {test_mse:.2e}")
print(f"Test Set - Data MSE (Physical): {test_mse_physical:.2e} (m^3/s)^2")
print(f"Test Set - Q_side MAE (Physical): {test_mae_side:.2e} m^3/s")
print(f"Test Set - Q_mid MAE (Physical): {test_mae_mid:.2e} m^3/s")
print(f"Test Set - Physics Error (Mass residual): {test_mass_err:.2e} m^3/s")


# ============ INVERSE DESIGN ============
target_side = 2*0.0075
target_mid = 0.00833

# Khởi tạo biến tối ưu (trong không gian chuẩn hóa)
D_opt = torch.nn.Parameter(torch.tensor([0.0, 0.0], dtype=torch.float32))  # gần mean
optim_inv = torch.optim.Adam([D_opt], lr=1e-3)

for step in range(1000):
    optim_inv.zero_grad()
    pred_norm = model(D_opt.unsqueeze(0))
    Q_side = pred_norm[0,0] * y_std[0] + y_mean[0]
    Q_mid = pred_norm[0,1] * y_std[1] + y_mean[1]
    loss_inv = (Q_side - target_side)**2 + (Q_mid - target_mid)**2
    # Ràng buộc biên nhẹ: đưa về vùng quan sát
    D_real = D_opt * X_std + X_mean
    bound_loss = 0.01 * (torch.clamp(D_real, min=0.15, max=0.20) - D_real).pow(2).sum()
    total_loss = loss_inv + bound_loss
    total_loss.backward()
    optim_inv.step()
    if step % 200 == 0:
        D_side_mm = D_real[0].item()*1000
        D_mid_mm = D_real[1].item()*1000
        print(f"Step {step}: D_side={D_side_mm:.2f}mm, D_mid={D_mid_mm:.2f}mm, "
              f"Q_side={Q_side.item():.6f}, Q_mid={Q_mid.item():.6f}")

# Kết quả cuối
D_side_opt = D_real[0].item()
D_mid_opt = D_real[1].item()
print(f"\nOptimal diameter: Side={D_side_opt*1000:.2f} mm, Mid={D_mid_opt*1000:.2f} mm")
print(f"Predicted flow: Side={Q_side.item():.6f}, Mid={Q_mid.item():.6f} m^3/s")