# 🛒 MINI E-COMMERCE APP - BÀI THỰC HÀNH 4

Dự án tổng hợp kiến thức Flutter từ TH1 đến TH3, tập trung vào quản lý trạng thái (State Management) và trải nghiệm người dùng TMĐT chuẩn Shopee/Lazada.

## 👥 THÔNG TIN NHÓM
- **Tên nhóm:** 4
- **Thanh AppBar:** `TH4 - Nhóm 4`
- **Công nghệ sử dụng:** Flutter, Provider (State Management), FakeStore API.

## 🏗 KIẾN TRÚC DỰ ÁN (MVVM)
Dự án được tổ chức theo mô hình MVVM (Model-View-ViewModel) để đảm bảo tính tách biệt giữa giao diện và logic:
- `lib/models/`: Định nghĩa cấu trúc dữ liệu sản phẩm và giỏ hàng.
- `lib/providers/`: Quản lý trạng thái hệ thống (Giỏ hàng, Logic tính tiền realtime).
- `lib/services/`: Xử lý gọi API và xử lý dữ liệu mạng.
- `lib/screens/`: Giao diện các màn hình (Home, Detail, Cart, Checkout).
- `lib/widgets/`: Các thành phần giao diện dùng chung (Product Card, Custom Button).

## ✨ CÁC TÍNH NĂNG NỔI BẬT
- [x] **Trang chủ:** SliverAppBar sticky, Carousel Slider, Infinite Scrolling (Cuộn để tải thêm).
- [x] **Trang Chi tiết:** Hero Animation, BottomSheet chọn phân loại, đồng bộ số lượng Badge.
- [x] **Giỏ hàng:** Logic Checkbox thông minh (Chọn tất cả/Chọn lẻ), tính tiền Realtime qua Provider.
- [x] **Thanh toán:** Xử lý logic đặt hàng và lưu trữ lịch sử đơn mua qua SharedPreferences.

## 🛠 QUY TRÌNH PHÁT TRIỂN (DÀNH CHO THÀNH VIÊN)
1. **Khởi tạo:** `flutter pub get` để cài đặt thư viện (`provider`, `http`, `carousel_slider`).
2. **Lấy code mới nhất:** Luôn chạy `git pull origin main` trước khi bắt đầu.
3. **Phát triển:** Tạo nhánh riêng `feature/[tên-tính-năng]` để làm việc.
4. **Kiểm tra:** Đảm bảo không còn dòng gạch đỏ (Error) trước khi gửi Pull Request cho Leader.

## 🚀 HƯỚNG DẪN CÀI ĐẶT
```bash
# Clone dự án
git clone [https://github.com/jovee112/baocaoTH4.git](https://github.com/jovee112/baocaoTH4.git)

# Tải các thư viện
flutter pub get

# Chạy ứng dụng
flutter run