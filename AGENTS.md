# AGENTS.md

## 1. Project Overview
- Tên dự án: `build_access`
- Mục tiêu chính:
    - Đây là một đề tài nghiên cứu khoa học với tên Ứng dụng hỗ trợ người khiếm thị đọc thông tin sản phẩm bằng.
    - Ưu tiên trải nghiệm thực tế: ổn định, dễ hiểu, ít spam âm thanh hơn là “thông minh nhưng chập chờn”.
    - Và mọi thứ làm trong dự án này phải ưu tiên tính học thuật.
- Ưu tiên kỹ thuật:
    - Độ ổn định > tốc độ
    - Dễ maintain > tối ưu vi mô
    - Hành vi nhất quán > xử lý phức tạp
    - Yêu cầu độ chính xác cao.

## 2. Product Principles
- Người dùng chính là người khiếm thị.
- Mọi thay đổi liên quan đến camera, OCR, TTS phải ưu tiên:
    - ít gây nhiễu
    - phản hồi ngắn, rõ
    - không spam speech
    - không thay đổi trạng thái liên tục gây khó hiểu
- Khi có tradeoff:
    - chọn ít thông báo hơn nhưng đúng lúc
    - không chọn nhiều thông báo ngắn liên tiếp

## 3. Architecture Rules
- Kiến trúc sử dụng: `MVVM`
- Quy ước tầng:
    - `features/`: màn hình, widget, UI composition
    - `view_models/`: logic của màn hình, orchestration UI flow
    - `services/`: nghiệp vụ dùng lại được, hạ tầng, pipeline
    - `services/scan/`: logic scan/OCR/camera flow
    - `providers/`: app state hoặc shared state
    - `models/`: DTO, result object, model dữ liệu
    - `core/`: base classes, shared utilities
    - `ml/`: wrapper cho ML Kit / detector / recognizer
    - `engine/`: xử lý nền, isolate, native/image worker
- Không tạo thêm folder mới nếu chưa có lý do rõ ràng.
- Ưu tiên giữ boundary rõ hơn là gom mọi thứ vào một file.
- Viết code phân lớp theo quy tắc SOLID

## 4. Responsibility Boundaries
- `ViewModel`:
    - điều phối luồng màn hình
    - gọi service
    - không chứa xử lý OCR/camera mức thấp nếu có thể tách ra
- `Service`:
    - chứa nghiệp vụ và pipeline tái sử dụng
    - không update UI trực tiếp
- `Provider`:
    - giữ state chia sẻ
    - không ôm quá nhiều business logic
- `Model/Result`:
    - chỉ giữ dữ liệu
    - không nhét side effect vào model
- `Widget/UI`:
    - không chứa business logic nặng

## 5. Camera / OCR / TTS Rules
- Camera:
    - tránh gọi `refocus()` liên tục mỗi frame
    - mọi logic refocus cần có ngưỡng hoặc cooldown
- OCR:
    - ưu tiên crop đúng vùng sản phẩm trước khi tăng độ phức tạp của hậu xử lý
    - nếu phải tradeoff, ưu tiên ảnh đầu vào sạch hơn là hậu xử lý text quá nhiều
- TTS:
    - không `speakQueue()` ở nhiều nơi cho cùng một trạng thái lỗi
    - mọi speech lỗi nên đi qua một cổng logic thống nhất
    - không nói theo từng frame
    - chỉ nói khi đủ ngưỡng frame hoặc đủ cooldown
- Blur / lỗi scan:
    - mặc định dùng nguyên tắc “n frame liên tiếp rồi mới phản hồi”
    - frame thành công phải reset counter lỗi liên quan
    - nếu nhiều loại lỗi khác nhau, phải xác định rõ có reset lẫn nhau hay không

## 6. Coding Style
- Ngôn ngữ: Dart / Flutter
- Quy tắc:
    - file name: `snake_case`
    - class: `PascalCase`
    - variable / method: `camelCase`
- Viết code theo hướng:
    - hàm ngắn
    - tên rõ nghĩa
    - ít side effect ẩn
    - không lặp logic
- Ưu tiên early return thay vì lồng `if` sâu.
- Chỉ thêm comment khi logic khó hiểu hoặc có lý do nghiệp vụ đặc biệt.
- Khi AI sửa hay thêm cái gì phải comment đoạn code đó nêu rõ nhiệm vụ lý do giải thích code.

## 7. Logging Rules
- Dùng log có chủ đích, không spam.
- Mỗi log nên giúp trả lời một trong các câu hỏi:
    - đang ở bước nào?
    - input gì?
    - quyết định gì?
    - fail ở đâu?
- Log camera/OCR nên ưu tiên:
    - rotation
    - crop
    - blur score
    - trạng thái detector/recognizer
- Không để log rác kéo dài làm khó đọc phiên debug.

## 8. Refactor Rules
- Không đổi behavior nếu user chưa yêu cầu.
- Khi refactor:
    - ưu tiên đổi ít nhưng làm rõ boundary
    - không rename hàng loạt nếu không cần
    - không phá vỡ luồng đang chạy ổn
- Nếu cần đổi cấu trúc thư mục:
    - phải giữ import rõ ràng
    - tránh trạng thái nửa cũ nửa mới quá lâu

## 9. When Reviewing Code
- Ưu tiên phát hiện:
    - bug logic
    - race condition
    - regression
    - spam side effect
    - kiến trúc lệch trách nhiệm
- Nếu review:
    - nêu findings trước
    - có file/path rõ ràng
    - summary chỉ là phần phụ

## 10. When Editing Code
- Ưu tiên sửa đúng chỗ nhỏ nhất có thể.
- Nếu bug do kiến trúc:
    - nêu rõ nguyên nhân
    - sau đó mới refactor tối thiểu để sửa triệt để
- Không tự ý “làm đẹp” những phần ngoài phạm vi task.

## 11. Project-Specific Preferences
- Ưu tiên tiếng Việt rõ nghĩa cho thông báo người dùng.
- TTS nên ngắn, dứt khoát, ít lặp.
- Với user mù hoặc khiếm thị:
    - tránh thông báo dài
    - tránh 2-3 câu liên tiếp cho cùng một trạng thái
    - chỉ dẫn phải hành động được ngay

## 12. Things The Agent Should Ask Before Big Changes
- Nếu thay đổi ảnh hưởng:
    - kiến trúc tổng thể
    - public API
    - luồng camera chính
    - cách TTS hoạt động
    - cấu trúc thư mục lớn
- thì cần báo trước ngắn gọn về hướng sửa.

## 13. Preferred Output Style From Agent
- Trả lời ngắn, trực tiếp.
- Khi phân tích code:
    - chỉ ra file liên quan
    - nói rõ bug nằm ở đâu
    - đề xuất cách sửa rõ ràng
- Khi hoàn thành:
    - tóm tắt thay đổi
    - nêu phần đã kiểm tra
    - nêu phần chưa kiểm tra được nếu có

## 14. Current Known Issues
- Liệt kê các vấn đề đang chấp nhận tạm thời ở đây.
- Ví dụ:
    - `services/scan/` chưa tách sạch hoàn toàn khỏi code cũ
    - OCR tiếng Việt còn sai khi nhãn bị cong mạnh
    - cần cooldown tốt hơn cho refocus/TTS

## 15. Do Not
- Không spam speech cho mỗi frame.
- Không để business logic rải ở nhiều tầng.
- Không thêm abstraction nếu chưa có lợi ích rõ ràng.
- Không sửa ngoài phạm vi task nếu không cần.
