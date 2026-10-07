# Deploy bản demo miễn phí lên Render

Gói này chạy ứng dụng PHP 7.4 bằng Docker trên Render và dùng TiDB Cloud Starter làm cơ sở dữ liệu MySQL tương thích. Đây là bản demo; Render miễn phí có thể tạm dừng khi vắng truy cập và khởi động lại khi có người mở trang. Không dùng bản này để nhận thanh toán hoặc lưu thông tin nhạy cảm.

## Tạo repository riêng tư

Tạo một repository GitHub **Private** mới. Đưa vào repository các tệp sau từ thư mục này:

- `Dockerfile`
- `apache-site.conf`
- `start.sh`
- `app_freehosting_light.zip`

Vì gói ZIP khoảng 71 MB, dùng GitHub Desktop hoặc Git CLI để đẩy repository; trang tải tệp của GitHub trên trình duyệt không nhận tệp lớn như vậy. Chỉ đẩy thư mục `deploy/render`, không đẩy toàn bộ project gốc.

Không đưa `staging_content.sql` lên GitHub nếu muốn giữ kín bộ đề. Tệp SQL có thể dùng để nạp database ở bước sau.

## Tạo database TiDB

1. Đăng ký TiDB Cloud bằng GitHub hoặc email và tạo một cụm **Starter** ở khu vực gần Singapore nếu được cung cấp.
2. Đặt mức chi tiêu tháng bằng `0` để giữ trong hạn mức miễn phí. Lưu lại host, cổng `4000`, tên database, username có tiền tố cụm và mật khẩu.
3. Cho phép kết nối public. TiDB yêu cầu TLS; image Docker đã có CA hệ thống.
4. Tạo một database trống trong TiDB. Trên Windows, mở MySQL CLI của Laragon, kết nối tới TiDB bằng TLS và nhập mật khẩu khi được hỏi:

   ```powershell
   & 'D:\laragon\bin\mysql\mysql-8.0.30-winx64\bin\mysql.exe' --connect-timeout 150 -u 'USERNAME' -h 'HOST' -P 4000 -D 'DATABASE' --ssl-mode=VERIFY_IDENTITY --ssl-ca='PATH_TO_CA_CERTIFICATE' -p
   ```

   Tại dấu nhắc `mysql>`, nạp tệp SQL bằng lệnh:

   ```sql
   source D:/laragon/www/SU/deploy/staging/staging_content.sql;
   ```

   Thay `PATH_TO_CA_CERTIFICATE` bằng đường dẫn CA root của máy. TiDB yêu cầu TLS; hướng dẫn chính thức về vị trí CA có ở [tài liệu TLS của TiDB](https://docs.pingcap.com/tidbcloud/secure-connections-to-serverless-clusters/).

## Tạo dịch vụ Render

1. Đăng ký Render và liên kết GitHub. Chọn **New → Web Service**, kết nối repository riêng tư vừa tạo, chọn **Docker** và gói **Free**.
2. Tạo khóa Laravel mới bằng `php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"`, rồi đặt kết quả vào biến `APP_KEY`. Không dùng khóa máy local.
3. Thêm các biến môi trường:

   ```text
   APP_NAME=Goc hoc tap cua em
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://TEN-DICH-VU.onrender.com
   STAGING_DEMO=true
   DB_CONNECTION=mysql
   DB_HOST=HOST_TIDB
   DB_PORT=4000
   DB_DATABASE=TEN_DATABASE
   DB_USERNAME=USERNAME_TIDB
   DB_PASSWORD=MAT_KHAU_TIDB
   DB_SSL_CA=/etc/ssl/certs/ca-certificates.crt
   CACHE_DRIVER=file
   SESSION_DRIVER=cookie
   QUEUE_DRIVER=sync
   MAIL_DRIVER=log
   ```

4. Để trống toàn bộ biến `SEPAY_*`. Render sẽ build Docker image và cấp HTTPS cho URL dịch vụ.
5. Mở URL sau khi deploy xong, tạo tài khoản thử và kiểm tra danh sách đề, làm đề, kết quả. Dịch vụ miễn phí có thể ngủ sau 15 phút không hoạt động; lần mở tiếp theo thường cần khoảng một phút để thức dậy.

## Giới hạn cần biết

- Render Free có thể khởi động lại dịch vụ; hệ thống tệp của ứng dụng không bền sau khi restart. Database nằm riêng trên TiDB nên nội dung database vẫn lưu.
- TiDB Starter miễn phí có hạn mức lưu trữ 5 GiB dữ liệu hàng và 50 triệu Request Units mỗi tháng; khi chạm hạn mức, thao tác database có thể bị giới hạn cho tới kỳ mới.
- Đây là cấu hình demo. Trước khi mở thanh toán thật cần chuyển sang môi trường có lưu trữ bền, sao lưu, giám sát và cấu hình bảo mật production phù hợp.
