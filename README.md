# SchoolMobile - Sổ liên lạc điện tử THPT

Ứng dụng Flutter hỗ trợ học sinh theo dõi thông tin học tập hằng ngày: điểm số, thời khóa biểu, lịch thi, điểm danh, thông báo và hồ sơ cá nhân.

## 1) Tổng quan

- Nền tảng: **Flutter (Material 3)**.
- Kiến trúc gọn nhẹ theo module: `core`, `models`, `services`, `screens`.
- Kết nối backend qua REST API, có xử lý timeout và thông báo lỗi rõ ràng.
- Lưu phiên đăng nhập cục bộ bằng `SharedPreferences`.

## 2) Tính năng đã hoàn thiện

### Xác thực
- Đăng nhập bằng số điện thoại + mật khẩu.
- Đặt lại mật khẩu.
- Điều hướng sau đăng nhập tới trang chủ.

### Trang chủ
- Hiển thị thông tin học sinh (họ tên, lớp).
- Menu truy cập nhanh tới các phân hệ chính.
- Bottom navigation cho Trang chủ / Thông báo / Hồ sơ.

### Các phân hệ học vụ
- **Kết quả học tập**: xem điểm theo học kỳ.
- **Thời khóa biểu**: xem theo tuần, lọc theo ngày.
- **Lịch thi**: xem lịch kiểm tra/thi theo học kỳ.
- **Điểm danh**: xem tổng quan và chi tiết theo tháng.
- **Thông báo**: nhận thông báo từ nhà trường.
- **Hồ sơ cá nhân**: xem thông tin học sinh, đăng xuất.

## 3) Cấu trúc dự án

```text
lib/
  core/
    app_router.dart        # Khai báo route và điều hướng
    app_theme.dart         # Theme và style dùng chung
    constants.dart         # Màu sắc, hằng số app, API base URL
  models/
    student.dart           # Model học sinh
    app_data.dart          # Model điểm, lịch học, lịch thi, điểm danh, thông báo
  services/
    api_service.dart       # Tầng gọi REST API
    session_service.dart   # Lưu/đọc phiên đăng nhập cục bộ
  screens/
    login_screen.dart
    reset_password_screen.dart
    home_screen.dart
    grades_screen.dart
    schedule_screen.dart
    exam_screen.dart
    attendance_screen.dart
    notifications_screen.dart
    profile_screen.dart
  main.dart
```

## 4) Cấu hình môi trường

### Yêu cầu
- Flutter SDK tương thích với `Dart SDK ^3.10.4`.
- Android Studio/Xcode (tuỳ nền tảng chạy).

### Cài đặt nhanh

```bash
flutter pub get
flutter run
```

## 5) Cấu hình API

Ứng dụng đọc base URL qua `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=https://your-domain/api
```

Nếu không truyền biến môi trường, app dùng mặc định:

```text
https://schoolapp-r3w2.onrender.com/api
```

## 6) Danh sách API tích hợp

- `POST /auth/login`
- `POST /auth/reset-password`
- `GET /app/grades/{studentId}?semester=...`
- `GET /app/schedules?className=...&week=...`
- `GET /app/exams/{studentId}?semester=...`
- `GET /app/attendances/{studentId}`
- `GET /app/notifications/{studentId}`

## 7) Thư viện chính

- `http`: gọi API.
- `shared_preferences`: lưu phiên đăng nhập.
- `intl`: format ngày/tháng.
- `google_fonts`: đồng bộ typography.

## 8) Ghi chú vận hành

- Ứng dụng khởi động tại màn hình đăng nhập.
- Toàn bộ dữ liệu màn hình học vụ lấy từ backend theo thông tin học sinh đã đăng nhập.
- Khi chạy trên thiết bị thật, đảm bảo backend cho phép truy cập từ mạng thiết bị.

---
