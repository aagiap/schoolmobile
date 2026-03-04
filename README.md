# schoolmobile

Ứng dụng mobile **Sổ liên lạc điện tử cho học sinh THPT** (Flutter).

## Những gì đã được chuẩn bị sẵn

- Khung theme dùng chung (màu, input, button).
- Router tập trung cho các màn hình cơ bản.
- Service gọi API theo đúng web service bạn mô tả:
  - `POST /api/auth/login`
  - `POST /api/auth/reset-password`
  - `GET /api/app/grades/{studentId}?semester=...`
  - `GET /api/app/schedules?className=...&week=...`
  - `GET /api/app/exams/{studentId}?semester=...`
  - `GET /api/app/attendances/{studentId}`
  - `GET /api/app/notifications/{studentId}`
- Model dữ liệu cho toàn bộ module: học sinh, bảng điểm, thời khóa biểu, lịch thi, điểm danh, thông báo.
- Session service để lưu thông tin đăng nhập cục bộ (`SharedPreferences`).
- Màn hình nền tảng:
  - Đăng nhập (đã gọi API thật)
  - Đặt lại mật khẩu (đã gọi API thật)
  - Trang chủ placeholder để nối tiếp các màn hình chi tiết.

## Cấu trúc thư mục chính

```text
lib/
  core/
    app_router.dart
    app_theme.dart
    constants.dart
  models/
    student.dart
    app_data.dart
  services/
    api_service.dart
    session_service.dart
  screens/
    login_screen.dart
    reset_password_screen.dart
    home_screen.dart
  main.dart
```

## Cấu hình API base URL

Mặc định đang dùng:

- Android emulator: `http://10.0.2.2:8080/api`

Có thể override khi chạy app:

```bash
flutter run --dart-define=API_BASE_URL=http://<your-ip>:8080/api
```

## Lộ trình đề xuất hoàn thiện theo từng bước

1. Dựng lại UI chính xác theo ảnh cho từng màn hình (ưu tiên login → home → các tab).  
2. Tạo `BottomNavigation` và state quản lý tab.  
3. Kết nối từng màn hình với `ApiService` (đã có sẵn hàm gọi).  
4. Bổ sung xử lý loading / empty / error cho từng module.  
5. Thêm format ngày giờ, semester/week picker theo dữ liệu thực tế.  
6. Viết widget test + integration test cho flow đăng nhập và gọi API.

## Chạy dự án

```bash
flutter pub get
flutter run
```

> Nếu chạy trên máy thật/emulator khác, nhớ chỉnh `API_BASE_URL` cho đúng IP backend Spring Boot.
