
# 🛒 MINI E-COMMERCE APP

## Tổng quan
Dự án Flutter mini-ecommerce, quản lý trạng thái bằng Provider, tích hợp Firebase Auth và Firestore, mô phỏng trải nghiệm Shopee/Lazada.

## Cấu trúc thư mục
- `lib/models/`: Định nghĩa dữ liệu sản phẩm, giỏ hàng.
- `lib/providers/`: Quản lý trạng thái (giỏ hàng, đồng bộ Firestore).
- `lib/services/`: Xử lý API, dịch vụ mạng.
- `lib/screens/`: Giao diện các màn hình (auth, home, detail, cart, checkout, orders, profile).
- `lib/widgets/`: Thành phần UI dùng chung (product card, custom button).
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: Hỗ trợ đa nền tảng.

## Chức năng chính
- Đăng nhập/Đăng ký bằng Firebase Auth.
- Trang chủ: SliverAppBar, Carousel, Infinite Scroll.
- Trang chi tiết: Chọn phân loại, số lượng, hiệu ứng Hero.
- Giỏ hàng: Checkbox chọn lẻ/tất cả, tính tiền realtime, đồng bộ Firestore.
- Thanh toán: Chọn địa chỉ, phương thức, lưu đơn hàng vào Firestore.
- Lịch sử đơn mua: Xem lại đơn hàng đã đặt.
- Quản lý profile: Đổi địa chỉ, xem email.

## Quy trình phát triển
1. Chạy `flutter pub get` để cài thư viện (`provider`, `firebase_core`, `cloud_firestore`, `firebase_auth`, ...).
2. Luôn cập nhật code mới nhất bằng `git pull origin main`.
3. Phát triển trên nhánh riêng: `feature/[ten-tinh-nang]`.
4. Kiểm tra lỗi, test UI trước khi gửi Pull Request.

## Hướng dẫn chạy
- Đảm bảo đã cấu hình Firebase (file `firebase_options.dart` được tạo tự động bởi FlutterFire CLI, không chỉnh sửa thủ công).
- Chạy `flutter run` trên thiết bị hoặc trình duyệt.

## Ghi chú
- Giá tiền được chuẩn hoá hiển thị theo USD ($).
- Dự án hỗ trợ đa nền tảng: Android, iOS, Web, Desktop.

## 🚀 HƯỚNG DẪN CÀI ĐẶT
```bash
# Clone dự án
git clone [https://github.com/jovee112/baocaoTH4.git](https://github.com/jovee112/baocaoTH4.git)

# Tải các thư viện
flutter pub get

# Chạy ứng dụng
flutter run