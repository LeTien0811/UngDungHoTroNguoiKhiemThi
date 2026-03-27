import tabula
import pandas as pd

pdf_file = "09-vbhn-byt.pdf"

# Thay vì convert_into, ta dùng read_pdf để lấy dữ liệu vào bộ nhớ
# lattice=True: Ép Tabula quét các đường kẻ ngang/dọc để tạo ô (Cực kỳ hiệu quả với bảng có viền)
dfs = tabula.read_pdf(
    pdf_file,
    pages='all',
    lattice=True,  # Quét theo đường viền bảng
    multiple_tables=True  # Cho phép đọc nhiều bảng nối tiếp nhau
)

print(f"Đã tìm thấy {len(dfs)} bảng trong file PDF!")

if dfs:
    # Nối tất cả các trang của bảng lại thành một khối duy nhất
    df_final = pd.concat(dfs, ignore_index=True)

    # Xuất ra file CSV, dùng 'utf-8-sig' để Excel không bị lỗi font tiếng Việt
    df_final.to_csv("output_sach_se.csv", index=False, encoding='utf-8-sig')
    print("Đã nối và lưu thành công ra file output_sach_se.csv!")
else:
    print("Không tìm thấy bảng nào. Hãy thử đổi lattice=False và stream=True")