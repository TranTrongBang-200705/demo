# Đưa bản demo lên Render miễn phí

> **Đây chỉ là bản demo.** Dịch vụ Render miễn phí có thể ngủ khi không có truy cập; lần mở lại có thể mất khoảng một phút. Tệp trên máy chủ Render không bền sau khi khởi động lại. Database được lưu riêng trên TiDB. Không bật thanh toán thật và không lưu dữ liệu nhạy cảm trên bản này.

## 1. Tạo database TiDB

1. Đăng nhập TiDB Cloud và tạo cụm **Starter**. Chọn Singapore hoặc khu vực gần nhất nếu được cung cấp.
2. Tạo một database trống. Ghi lại host, database, username và password; giữ cổng `4000` và yêu cầu TLS.
3. Kết nối từ máy Windows bằng MySQL CLI của Laragon (thay các giá trị viết hoa bằng thông tin TiDB của bạn):

   ```powershell
   & 'D:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe' --connect-timeout 150 -u 'USERNAME' -h 'HOST' -P 4000 -D 'DATABASE' --ssl-mode=VERIFY_IDENTITY --ssl-ca='PATH_TO_CA_CERTIFICATE' -p
   ```

   Tại dấu nhắc `mysql>`, nạp dữ liệu demo:

   ```sql
   source D:/laragon/www/SU/deploy/staging/staging_content.sql;
   ```

   Thay `PATH_TO_CA_CERTIFICATE` bằng đường dẫn CA tải từ phần kết nối TiDB. Không gửi thông tin kết nối hoặc mật khẩu vào chat.

## 2. Tạo dịch vụ Render từ Blueprint

1. Đăng nhập Render, chọn **New → Blueprint** và kết nối GitHub repository `TranTrongBang-200705/demo`. Cấp quyền truy cập repo nếu GitHub hỏi.
2. Render sẽ đọc `render.yaml` ở thư mục gốc và tạo web service gói **Free**. Khi được hỏi giá trị bí mật, điền `APP_KEY`, `DB_HOST`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` từ bước trên.
3. Tạo `APP_KEY` riêng cho bản demo trong PowerShell tại máy bạn:

   ```powershell
   php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"
   ```

   Dán kết quả trực tiếp vào Render. Đừng commit key vào GitHub.
4. Chờ Render build và deploy. Mở URL `onrender.com` được Render cấp; `APP_URL` tự lấy URL đó.

## 3. Kiểm tra demo

- Mở trang chủ, danh sách đề, bắt đầu một đề và xem kết quả.
- `STAGING_DEMO=true` giữ thanh toán SePay tắt. Không thêm biến `SEPAY_*`.
- Nếu trang báo lỗi kết nối database, kiểm tra host, database, username, password, quyền truy cập public và TLS trong TiDB.

## Tệp trong repository

- `render.yaml`: cấu hình Blueprint và các biến môi trường demo.
- `Dockerfile`, `apache-site.conf`, `start.sh`: chạy Laravel/PHP bằng Apache.
- `app_freehosting_light.zip`: gói ứng dụng demo khoảng 71 MB.

Tệp SQL chứa kho đề không nằm trong repo để tránh công khai nội dung đề. Gói ZIP cũng có dữ liệu đề, vì vậy hãy giữ repository ở chế độ **Private** nếu chưa muốn chia sẻ kho câu hỏi.

## Giới hạn bản miễn phí

Render Free có thể ngủ khi không có truy cập và không có persistent disk. TiDB Starter có quota miễn phí và giới hạn theo chính sách hiện hành của TiDB. Đây là môi trường thử nghiệm; trước khi nhận thanh toán thật cần chuyển sang cấu hình production có lưu trữ bền, sao lưu, giám sát và bảo mật phù hợp.

Tài liệu: [Render Blueprints](https://render.com/docs/blueprint-spec), [Render free instances](https://render.com/docs/free), [TiDB Cloud TLS](https://docs.pingcap.com/tidbcloud/secure-connections-to-serverless-clusters/).
