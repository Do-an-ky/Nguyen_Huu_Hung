📱 Ứng dụng Flutter - Hệ thống Cảnh báo Té ngã

Ứng dụng di động (dành cho người thân/người giám hộ) thuộc hệ thống IoT cảnh báo té ngã. Ứng dụng kết nối với Firebase Realtime Database để nhận dữ liệu cảm biến (MPU6050) từ thiết bị đeo (ESP32) theo thời gian thực và gửi lệnh phản hồi (ACK, RESET, TEST).

🛠 Yêu cầu hệ thống (Prerequisites)

Để chạy được dự án này, máy tính của bạn cần cài đặt sẵn:

Flutter SDK: Phiên bản ổn định mới nhất (Stable channel).

Android Studio: Đã cài đặt plugin Flutter và Dart.

Máy ảo (Emulator) hoặc Thiết bị thật chạy Android/iOS đã bật chế độ Gỡ lỗi USB (USB Debugging).

Tài khoản Firebase: Đã tạo project Firebase và cấu hình Realtime Database.

🚀 Hướng dẫn Cài đặt và Chạy dự án

Bước 1: Mở dự án bằng Android Studio

Mở Android Studio.

Chọn Open (hoặc File > Open).

Trỏ đến thư mục chứa mã nguồn ứng dụng Flutter này và nhấn OK.

Bước 2: Tải các thư viện phụ thuộc (Dependencies)

Ứng dụng sử dụng các thư viện như firebase_core, firebase_database, firebase_auth.

Mở Terminal trong Android Studio (nằm ở thanh công cụ dưới cùng).

Chạy lệnh sau để tải các package:

flutter pub get


Bước 3: Cấu hình Firebase (Rất quan trọng)

Do mã nguồn sử dụng firebase_options.dart để khởi tạo, bạn cần đảm bảo ứng dụng đã được liên kết với Project Firebase của bạn.

Cài đặt Firebase CLI và FlutterFire CLI (nếu chưa có).

Mở Terminal trong thư mục dự án và chạy:

flutterfire configure


Chọn Project Firebase của bạn và chọn các nền tảng (Android, iOS). Lệnh này sẽ tự động sinh/cập nhật file lib/firebase_options.dart và android/app/google-services.json.

⚠️ CẤU HÌNH TRÊN FIREBASE CONSOLE:

Authentication: Vào mục Authentication > Sign-in method, bật (Enable) phương thức Anonymous (Ẩn danh). Nếu không bật, ứng dụng sẽ không thể lấy token để đọc/ghi dữ liệu.

Realtime Database: Import file database_rules_v2.json vào tab Rules của Realtime Database để cấp quyền bảo mật.

Bước 4: Chạy ứng dụng

Trên thanh công cụ của Android Studio, chọn thiết bị đích (Ví dụ: Pixel 7 API 33 hoặc thiết bị thật của bạn cắm qua cáp).

Nhấn nút Run (Biểu tượng tam giác màu xanh lá) hoặc nhấn tổ hợp phím Shift + F10.

Quá trình build lần đầu có thể mất từ 1-3 phút. Khi build xong, ứng dụng sẽ tự động mở trên màn hình thiết bị.

🧪 Hướng dẫn Kiểm tra (Testing)

Khi ứng dụng đã chạy lên, bạn có thể kiểm tra các chức năng:

Trạng thái Mất kết nối: Nếu chưa bật mạch ESP32, ứng dụng sẽ hiển thị ô màu xám xanh "MẤT KẾT NỐI THIẾT BỊ".

Kiểm tra luồng dữ liệu ảo: Nếu chưa có phần cứng ESP32, bạn có thể vào Firebase Console, thêm tay cấu trúc JSON vào nhánh devices/device01/status với state: "ALARM". Ngay lập tức màn hình điện thoại sẽ chuyển sang màu đỏ cảnh báo té ngã.

Nút "Kiểm tra hệ thống": Nhấn nút này ở trạng thái An toàn, ứng dụng sẽ gửi lệnh TEST lên node command. Bạn có thể quan sát thay đổi này trên Firebase Console.

🐛 Khắc phục sự cố thường gặp (Troubleshooting)

Lỗi FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created:
👉 Thiếu file firebase_options.dart hoặc chưa chạy Firebase.initializeApp(). Chạy lại flutterfire configure.

Ứng dụng màn hình trắng hoặc kẹt ở trạng thái loading:
👉 Kiểm tra kết nối mạng của điện thoại/máy ảo. Đăng nhập ẩn danh Firebase yêu cầu có Internet.

Dữ liệu không cập nhật hoặc lỗi "Permission Denied":
👉 Bạn chưa bật đăng nhập Anonymous trên Firebase Console, hoặc file Rules cấu hình sai.

Phát triển bởi: Nguyễn Hữu Hùng (Mã SV: 523100198)
