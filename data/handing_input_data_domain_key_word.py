import csv
import os
import re

# Tên file CSV bạn đang lưu trữ dữ liệu
csv_filename = 'domain_keywords.csv'

# Dictionary chứa dữ liệu trong bộ nhớ
data_dict = {}


# HÀM: Bỏ dấu tiếng Việt để tự động tạo Variant
def remove_vietnamese_accents(s):
    s = re.sub(r'[àáạảãâầấậẩẫăằắặẳẵ]', 'a', s)
    s = re.sub(r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]', 'A', s)
    s = re.sub(r'[èéẹẻẽêềếệểễ]', 'e', s)
    s = re.sub(r'[ÈÉẸẺẼÊỀẾỆỂỄ]', 'E', s)
    s = re.sub(r'[òóọỏõôồốộổỗơờớợởỡ]', 'o', s)
    s = re.sub(r'[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]', 'O', s)
    s = re.sub(r'[ìíịỉĩ]', 'i', s)
    s = re.sub(r'[ÌÍỊỈĨ]', 'I', s)
    s = re.sub(r'[ùúụủũưừứựửữ]', 'u', s)
    s = re.sub(r'[ÙÚỤỦŨƯỪỨỰỬỮ]', 'U', s)
    s = re.sub(r'[ỳýỵỷỹ]', 'y', s)
    s = re.sub(r'[ỲÝỴỶỸ]', 'Y', s)
    s = re.sub(r'[Đ]', 'D', s)
    s = re.sub(r'[đ]', 'd', s)
    return s.lower()


# HÀM: Làm sạch khoảng trắng thừa do người dùng nhập lỗi
def clean_input_spaces(text):
    # Xóa khoảng trắng thừa ở 2 đầu và thu gọn nhiều dấu cách ở giữa thành 1 dấu cách
    return re.sub(r'\s+', ' ', text.strip())


# 1. TẢI DỮ LIỆU TỪ FILE CSV CŨ LÊN (Nếu có)
if os.path.exists(csv_filename):
    with open(csv_filename, mode='r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            keyword = row['Keyword_Standard']
            dict_key = keyword.lower()

            data_dict[dict_key] = {
                'Keyword_Standard': keyword,
                'Variants': set(row['Variants'].split('|')) if row['Variants'] else set(),
                'Category': set(c.strip() for c in row['Category'].split(',')) if row['Category'] else set()
            }
    print(f"[+] Đã tải thành công {len(data_dict)} từ khóa từ {csv_filename}")
else:
    print(f"[-] Không tìm thấy {csv_filename}. Sẽ tạo file mới khi lưu.")

print("\n" + "=" * 50)
print("CÔNG CỤ NHẬP DỮ LIỆU TỪ ĐIỂN OCR (AUTO VARIANTS)")
print("Gõ 'exit' vào ô Keyword để thoát và LƯU FILE.")
print("=" * 50 + "\n")

# 2. VÒNG LẶP NHẬP LIỆU THỦ CÔNG
while True:
    # Nhập và dọn dẹp Keyword ngay lập tức
    raw_kw = input("1. Nhập Keyword_Standard (VD: Hướng dẫn sử dụng): ")
    kw_input = clean_input_spaces(raw_kw)

    if kw_input.lower() == 'exit':
        break
    if not kw_input:
        continue

    # TỰ ĐỘNG PARSE VARIANTS
    kw_lower = kw_input.lower()
    kw_unaccent = remove_vietnamese_accents(kw_input)
    auto_variants = {kw_lower, kw_unaccent}

    # Cho phép nhập thêm Variant viết tắt (VD: hdsd), hoặc chỉ cần bấm Enter để bỏ qua
    print(f"   [Auto] Đã tạo sẵn variants: {kw_lower}|{kw_unaccent}")
    raw_var = input("2. Nhập THÊM Variants viết tắt (nếu có, Enter để bỏ qua): ")
    var_input = clean_input_spaces(raw_var)

    raw_cat = input("3. Nhập Category (FOOD, MED, CHEM, ALL): ")
    cat_input = clean_input_spaces(raw_cat)

    dict_key = kw_lower

    # XỬ LÝ LOGIC: CẬP NHẬT HOẶC THÊM MỚI
    if dict_key in data_dict:
        print(f"   -> [TỒN TẠI] Đang gộp dữ liệu vào '{data_dict[dict_key]['Keyword_Standard']}'...")

        # Gộp auto_variants và var_input (nếu có gõ thêm) vào Set cũ
        data_dict[dict_key]['Variants'].update(auto_variants)
        if var_input:
            new_variants = [v.strip() for v in var_input.split('|') if v.strip()]
            data_dict[dict_key]['Variants'].update(new_variants)

        # Gộp Category mới vào Set cũ
        if cat_input:
            new_categories = [c.strip() for c in cat_input.split(',') if c.strip()]
            data_dict[dict_key]['Category'].update(new_categories)
    else:
        print(f"   -> [THÊM MỚI] Đã tạo mới từ khóa '{kw_input}'.")

        # Khởi tạo dữ liệu mới với Variants tự động
        new_variants_set = auto_variants.copy()
        if var_input:
            new_variants_set.update([v.strip() for v in var_input.split('|') if v.strip()])

        data_dict[dict_key] = {
            'Keyword_Standard': kw_input.capitalize(),
            'Variants': new_variants_set,
            'Category': set([c.strip() for c in cat_input.split(',') if c.strip()])
        }
    print("-" * 30)

# 3. GHI ĐÈ LẠI XUỐNG FILE CSV
print("\nĐang tiến hành lưu file...")
with open(csv_filename, mode='w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['Keyword_Standard', 'Variants', 'Category'])

    for val in data_dict.values():
        var_str = "|".join(sorted(list(val['Variants'])))

        cat_set = val['Category']
        if len(cat_set) > 1 or "ALL" in cat_set:
            cat_str = "ALL"
        else:
            cat_str = list(cat_set)[0] if cat_set else ""

        writer.writerow([val['Keyword_Standard'], var_str, cat_str])

print(f"Hoàn tất! Dữ liệu đã được lưu an toàn vào {csv_filename}.")