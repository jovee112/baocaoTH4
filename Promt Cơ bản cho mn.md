 -Home Screen (Giao diện & API)
Nhiệm vụ: Hiển thị danh sách từ API lên giao diện Trang chủ.

Hướng dẫn dùng Agent: * Mở file home_screen.dart.

Prompt: "Hãy sử dụng ApiService để fetch dữ liệu từ FakeStore API. Hiển thị danh sách sản phẩm bằng GridView 2 cột. Mỗi thẻ sản phẩm (Product Card) phải hiển thị ảnh, tên (tối đa 2 dòng), và giá format tiền tệ. Tích hợp tính năng vuốt để làm mới (Pull to refresh)."






 -Product Detail & Interaction
Nhiệm vụ: Trang chi tiết và logic thêm hàng vào giỏ.

Hướng dẫn dùng Agent:

Mở file detail_screen.dart.

Prompt: "Xây dựng giao diện chi tiết sản phẩm nhận vào ProductModel. Thêm nút 'Thêm vào giỏ hàng' ở phía dưới. Khi bấm nút, hãy gọi hàm addToCart từ CartProvider. Đồng thời hiện một BottomSheet để người dùng chọn số lượng và màu sắc trước khi xác nhận."




- Cart Screen (Logic Quản lý trạng thái)
Nhiệm vụ: Hiển thị giỏ hàng và xử lý Checkbox.

Hướng dẫn dùng Agent:

Mở file cart_screen.dart.

Prompt: "Lắng nghe dữ liệu từ CartProvider. Hiển thị danh sách sản phẩm trong giỏ dưới dạng ListView. Thêm logic Checkbox cho từng sản phẩm: chỉ khi sản phẩm được tick thì mới cộng vào 'Tổng thanh toán' ở dưới cùng. Thêm nút tăng/giảm số lượng và tính năng vuốt để xóa sản phẩm."







-Checkout & Order History (Persistence)
Nhiệm vụ: Thanh toán và lưu lịch sử.

Hướng dẫn dùng Agent:

Mở file checkout_screen.dart.

Prompt: "Nhận danh sách các sản phẩm đã tick từ trang Giỏ hàng. Tạo form nhập địa chỉ và phương thức thanh toán. Sau khi đặt hàng thành công, hãy sử dụng SharedPreferences để lưu đơn hàng này vào danh sách 'Lịch sử mua hàng' (Order History) và xóa các item đó khỏi CartProvider."