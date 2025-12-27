# MVP Test Planning & Flow Revisions

Dựa trên yêu cầu MVP và tập trung vào "Happy Case" (Luồng đi suôn sẻ nhất), đây là các điểm chưa hợp lý cần điều chỉnh để giảm tải dev và đảm bảo user flow mượt mà.

## 1. Các Flow cần điều chỉnh (Unreasonable vs MVP)

### 🔴 1. Flow Tính Calo (Core Loop)
- **Vấn đề:** Công thức tính Calo cần **Cân nặng (Weight)**. Flow đăng ký hiện tại (UC-01, UC-02) **không hỏi** cân nặng.
- **Tại sao không hợp lý:** MVP thì không nên bắt user nhập nhiều, nhưng nếu hiển thị "0 Cal" hoặc tính sai thì mất tính năng "Wow".
- **Giải pháp MVP:**
    - **Hard-code cân nặng mặc định là 65kg** cho tất cả users. 
    - Ẩn/Bỏ qua input cân nặng ở màn hình Profile.
    - -> **Dev Action:** Gán `const DEFAULT_WEIGHT = 65;` trong logic tính toán.

### 🔴 2. Flow Đổi quà (Rewards)
- **Vấn đề:** Hiện tại có 2 bước: `Redeem (Pending)` -> `Mark as Used (Done)`.
- **Tại sao không hợp lý:** Quá phức tạp cho MVP. Vợ/chồng đổi quà là để dùng luôn hoặc xác nhận bằng miệng. Việc phải vào app bấm thêm 1 lần "Đã dùng" là dư thừa (friction).
- **Giải pháp MVP:**
    - **Instant Redeem:** Bấm "Đổi" -> Trừ tiền + Bắn thông báo + Lưu lịch sử là xong.
    - Bỏ qua trạng thái "Pending" và màn hình quản lý trạng thái coupon.

### 🟡 3. Flow Mời thành viên (Household)
- **Vấn đề:** Dùng QR Code / Deep Link.
- **Tại sao không hợp lý:** Triển khai Deep Link (Universal Links/App Links) cho cả iOS/Android tốn nhiều thời gian setup và dễ lỗi trong giai đoạn đầu.
- **Giải pháp MVP:**
    - Dùng **House ID (hoặc Code 6 ký tự)** đơn giản.
    - User copy code gửi qua tin nhắn -> Người kia paste vào app để join. Đơn giản, chắc chắn chạy (Robust).

---

## 2. Test Cases cho MVP Happy Path

Chuẩn bị các kịch bản test tập trung vào luồng chính (không test các case biên dị/lỗi mạng phức tạp).

### Module 1: Authentication & Setup
| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| **HP-01** | Login & Setup | 1. Login Google.<br>2. Nhập tên "Test User", chọn Avatar mặc định.<br>3. Bấm Next. | Vào màn hình Home/House Setup thành công. |

### Module 2: Household (Simple Invite)
| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| **HP-02** | Tạo & Join Nhà | 1. User A: Tạo nhà "Happy House". Copy Code `123456`.<br>2. User B: Nhập Code `123456`. | User B join thành công vào nhà "Happy House". A và B nhìn thấy nhau. |

### Module 3: Core Loop (The "Meat")
| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| **HP-03** | Làm việc nhà & Nhận điểm | 1. Chọn "Rửa bát" -> Start.<br>2. Chờ 1 phút (để valid point).<br>3. Finish -> Vuốt sạch màn hình (Wipe). | - Timer chạy đúng.<br>- Vuốt xong hiện hiệu ứng Confetti.<br>- Điểm cộng vào ví.<br>- Calo hiển thị số > 0 (dùng weight mặc định 65kg). |

### Module 4: Simple Rewards
| ID | Scenario | Steps | Expected Result |
|----|----------|-------|-----------------|
| **HP-04** | Đổi thưởng nhanh | 1. User A (đủ điểm) bấm đổi "Massage". | - Trừ điểm ngay lập tức.<br>- User B nhận thông báo: "A vừa đổi Massage!".<br>- Lịch sử ghi nhận transaction. |
