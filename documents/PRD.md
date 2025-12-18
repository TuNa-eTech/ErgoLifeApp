Dưới đây là bản **Product Requirement Document (PRD)** phiên bản chính thức và đầy đủ nhất cho ứng dụng **ErgoLife**.
Tài liệu này đã được cập nhật toàn bộ các thay đổi chiến lược mà chúng ta đã thảo luận:
1. **Giao diện:** Light Mode & Clean Kinetic Style.
2. **Tính năng hoàn thành:** Thay thế "Chụp ảnh" bằng **"The Magic Wipe" (Cú Lau Thần Kỳ)**.
3. **Phạm vi:** Tập trung tối đa vào MVP (Minimum Viable Product).
Bạn có thể chuyển tiếp (Forward) nguyên văn tài liệu này cho đội ngũ Lập trình (Dev) và Thiết kế (Design).
---
#PRODUCT REQUIREMENT DOCUMENT (PRD)**Tên sản phẩm:** ErgoLife – The Home Athlete
**Phiên bản:** 1.0 (MVP Release)
**Ngày cập nhật:** 16/12/2025
**Tác giả:** Appalize & Founder
**Trạng thái:** Sẵn sàng phát triển (Ready for Development)
---
##1. TỔNG QUAN (EXECUTIVE SUMMARY)###1.1. Tầm nhìn sản phẩm (Product Vision)ErgoLife tái định nghĩa việc nhà (chores) không phải là gánh nặng, mà là cơ hội rèn luyện sức khỏe (functional fitness). Ứng dụng giúp các cặp đôi/hộ gia đình phân chia công việc công bằng dựa trên nỗ lực thể chất, đảm bảo an toàn cột sống qua hướng dẫn công thái học, và tạo niềm vui thông qua Gamification.
###1.2. Mục tiêu MVP (Objectives)* Xây dựng vòng lặp thói quen: Chọn việc -> Xem hướng dẫn -> Làm việc -> Nhận thưởng.
* Kiểm chứng giả thuyết: Người dùng thích thú với việc "lau màn hình" để nhận điểm và đổi quà thực tế.
* KPI kỹ thuật: Ứng dụng chạy mượt mà 60fps trên cả iOS và Android (Flutter).
###1.3. Đối tượng người dùng (Target Audience)* Các cặp đôi sống chung (Couples), bạn cùng phòng (Roommates).
* Độ tuổi: 22 - 35 (Gen Z, Millennials).
* Đặc điểm: Yêu công nghệ, quan tâm sức khỏe, thích sự công bằng.
---
##2. TRẢI NGHIỆM NGƯỜI DÙNG & GIAO DIỆN (UX/UI SPECIFICATIONS)###2.1. Định hướng nghệ thuật (Art Direction)* **Phong cách:** **Clean Kinetic Minimalism** (Tối giản & Động lực học).
* **Chủ đề (Theme):** **Light Mode Only** (Chế độ sáng duy nhất). Tạo cảm giác sạch sẽ, vệ sinh, rộng rãi.
* **Cảm giác (Vibe):** Tươi mới, Năng lượng, Thân thiện (như Headspace kết hợp Apple Fitness).
###2.2. Hệ thống màu sắc (Color Palette)| Tên màu | Mã Hex | Vai trò | Ghi chú |
| --- | --- | --- | --- |
| **Soft Porcelain** | `#F2F4F7` | Background | Màu nền chính (Xám cực nhạt/Trắng sứ). |
| **Pure White** | `#FFFFFF` | Surface | Nền của các thẻ (Cards), Modal. |
| **Vibrant Orange** | `#FF6B00` | Primary | Nút bấm (CTA), Thanh tiến trình, Icon active. |
| **Navy Blue** | `#1D2939` | Text Primary | Tiêu đề chính, Số đếm giờ. |
| **Slate Grey** | `#667085` | Text Secondary | Phụ đề, hướng dẫn phụ. |
| **Eucalyptus** | `#00C48C` | Success | Thông báo hoàn thành, Tăng điểm. |
###2.3. Typography* **Font:** Inter (Google Fonts) hoặc SF Pro Rounded.
* **Yêu cầu:** Font chữ đậm (Bold), bo tròn nhẹ, dễ đọc số liệu từ xa.
---
##3. YÊU CẦU CHỨC NĂNG (FUNCTIONAL REQUIREMENTS)###Module 1: Authentication & Onboarding (Đăng nhập)* **Sign-in:** Chỉ hỗ trợ **Google Sign-in** và **Apple Sign-in**. (Loại bỏ Email/Pass để giảm ma sát).
* **Setup Profile:**
* Nhập tên hiển thị (Display Name).
* Chọn Avatar (Từ bộ thư viện 3D Avatar có sẵn trong app - hạn chế upload ảnh cá nhân ở MVP).
###Module 2: Household Management (Quản lý Nhà)* **Create House:** User tạo một "Nhà" mới -> Hệ thống sinh ra `house_id`.
* **Invite Member:** Tạo QR Code hoặc Deep Link chứa `house_id`.
* **Join House:** User quét mã/bấm link -> Tham gia vào nhà.
* **Logic:** 1 User chỉ thuộc 1 House tại một thời điểm. Tối đa 4 members/House.
###Module 3: The Core Loop (Vòng lặp chính) - QUAN TRỌNG NHẤT####3.1. Task Selection (Chọn việc)* Hiển thị danh sách Card (Lưới 2 cột).
* Dữ liệu Hard-code 10 việc cơ bản: *Hút bụi, Lau nhà, Rửa bát, Cọ Toilet, Dọn giường, Phơi đồ, Đi chợ, Nấu ăn, Đổ rác, Chăm thú cưng.*
* Mỗi task hiển thị: Icon, Tên, Điểm ước tính/phút.
####3.2. Ergo-Coach Overlay (Hướng dẫn Công thái học)* **Trigger:** Khi user bấm vào 1 Task.
* **UI:** Modal popup nền trắng mờ (Glassmorphism).
* **Content:**
* 1 Animation (Lottie JSON) mô phỏng nhân vật 3D làm việc đúng tư thế.
* 1 câu Micro-copy ngắn: *"Gồng cơ bụng lên! Đừng để lưng chịu lực."*
* **Action:** Nút "Sẵn sàng" (Ready) -> Bắt đầu Timer.
####3.3. Active Session (Đếm giờ)* **Timer:** Đếm tiến (00:00 -> ...).
* **Display:** Thời gian, Calo ước tính (nhảy số real-time), Nhịp tim (giả lập hoặc lấy từ HealthKit nếu kịp, ưu tiên giả lập cho MVP).
* **Control:** Nút Pause (Tạm dừng) và Finish (Hoàn thành). Nút phải to, dễ bấm.
* **System:** Giữ màn hình luôn sáng (**Wakelock**) trong quá trình đếm.
####3.4. The Magic Wipe (Xác nhận hoàn thành) - TÍNH NĂNG MỚI* **Trigger:** Sau khi bấm Finish.
* **UI:** Một lớp phủ màu xám/bụi (Overlay Image) che toàn bộ màn hình. Dòng chữ: *"Lau sạch màn hình để nhận điểm!"*.
* **Interaction:** User dùng ngón tay vuốt (gestures) để xóa lớp phủ (như vé cào).
* **Feedback:**
* **Visual:** Lớp bụi biến mất theo đường ngón tay.
* **Haptic:** Điện thoại rung nhẹ theo từng nhịp vuốt.
* **Win Condition:** Khi xóa sạch > 70% diện tích -> Kích hoạt hiệu ứng chiến thắng (Confetti/Sparkles).
###Module 4: Economy & Rewards (Kinh tế & Đổi thưởng)####4.1. Point System (Hệ thống điểm)* **Công thức:** `ErgoPoints = Thời gian (phút) x METs x 10`.
* *Ví dụ:* Rửa bát (METs 2.5) trong 20 phút = 20 * 2.5 * 10 = 500 Points.
* **Lưu trữ:** Cộng dồn vào `wallet_balance` của User và `weekly_score` trên Bảng xếp hạng.
####4.2. Reward Shop (Cửa hàng)* **Tạo Coupon:** User tự nhập: Tên quà (VD: Massage chân), Giá (VD: 1000 EP), Icon.
* **Redeem (Đổi quà):**
* User A bấm đổi -> Trừ điểm User A -> Gửi thông báo cho User B (hoặc cả nhà).
* Coupon chuyển trạng thái sang "Đã dùng".
---
##4. YÊU CẦU KỸ THUẬT (TECHNICAL REQUIREMENTS)###4.1. Tech Stack* **Mobile Framework:** **Flutter** (Stable version). Ngôn ngữ: Dart.
* **Backend as a Service:** **Firebase**.
* Auth: Quản lý user.
* Firestore: NoSQL Database (Real-time update cho ví tiền/điểm số).
* Cloud Functions: Xử lý logic tính điểm an toàn (nếu cần) hoặc thông báo.
* Cloud Messaging (FCM): Push Notification.
###4.2. Thư viện đề xuất (Flutter Packages)* `scratcher`: Để làm tính năng **The Magic Wipe**.
* `lottie`: Để hiển thị animation Ergo-Coach.
* `provider` hoặc `flutter_bloc`: Quản lý trạng thái (State Management).
* `wakelock`: Giữ màn hình sáng.
* `shared_preferences`: Lưu settings cục bộ.
###4.3. Hiệu năng (Performance)* Animation "The Magic Wipe" phải mượt mà, không giật lag (frame drop).
* Thời gian khởi động App (Cold start) < 2 giây.
---
##5. CẤU TRÚC DỮ LIỆU (DATABASE SCHEMA - FIRESTORE)**Collection: `users**`
```json
{
"uid": "string (PK)",
"display_name": "string",
"avatar_id": "int",
"house_id": "string (FK)",
"wallet_balance": "int",
"fcm_token": "string"
}
```
**Collection: `houses**`
```json
{
"house_id": "string (PK)",
"name": "string",
"member_uids": ["string"],
"created_at": "timestamp"
}
```
**Collection: `activities**` (Lịch sử làm việc)
```json
{
"activity_id": "string (PK)",
"user_id": "string",
"house_id": "string",
"task_name": "string",
"duration_seconds": "int",
"points_earned": "int",
"timestamp": "timestamp"
}
```
**Collection: `rewards**` (Các coupon đang có trong Shop)
```json
{
"reward_id": "string (PK)",
"house_id": "string",
"title": "string",
"cost": "int",
"icon_id": "string",
"is_active": "boolean"
}
```
---
##6. KẾ HOẠCH TRIỂN KHAI (ROADMAP)* **Tuần 1-2:** Setup Project, UI Base (Light Mode), Authentication, Household Logic.
* **Tuần 3-4:** Core Loop (Timer, Ergo-Coach UI, Point Logic).
* **Tuần 5:** Tính năng "The Magic Wipe" (Tinh chỉnh hiệu ứng cào & rung).
* **Tuần 6:** Reward Shop & Notification.
* **Tuần 7:** Testing (UAT), fix bugs, Polish UI.
* **Tuần 8:** Submit lên App Store & Google Play.
---
###GHI CHÚ CHO ĐỘI NGŨ PHÁT TRIỂN> *"ErgoLife là một ứng dụng Lifestyle. Đừng chỉ code cho nó 'chạy được'. Hãy code cho nó 'chạm được' vào cảm xúc. Cú vuốt màn hình ở cuối (Magic Wipe) là khoảnh khắc đắt giá nhất - hãy làm cho nó thật sự thỏa mãn (Satisfying)."*