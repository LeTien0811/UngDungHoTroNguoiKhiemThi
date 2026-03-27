import os
import re

# Cấu hình file đầu ra chuẩn SymSpell (thường dùng khoảng trắng hoặc tab)
OUTPUT_FILE = 'domain_terms.txt'
MAGIC_FREQ = 9999999

# Load dữ liệu cũ lên để không bị trùng lặp (tránh file to không cần thiết)
domain_dict = {}
if os.path.exists(OUTPUT_FILE):
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) >= 2:
                # Lấy từ vựng (có thể là từ ghép nên join lại phần đầu), phần cuối là tần suất
                word = " ".join(parts[:-1])
                freq = parts[-1]
                domain_dict[word] = freq
    print(f"[+] Đã tải {len(domain_dict)} từ chuyên ngành từ {OUTPUT_FILE}")
else:
    print(f"[-] Chưa có file {OUTPUT_FILE}. Sẽ tự động tạo mới.")

print("\n" + "=" * 60)
print("🚀 CÔNG CỤ BƠM TẦN SUẤT TỪ ĐIỂN SYMSPELL (DOMAIN ENTITIES)")
print("👉 Cách dùng: Nhập 1 từ (paracetamol) HOẶC dán một danh sách (Kali, Natri, Sorbate)")
print("👉 Gõ 'exit' để lưu và thoát.")
print("=" * 60 + "\n")

while True:
    raw_input = input("Nhập Thực thể Chuyên ngành: ").strip()

    if raw_input.lower() == 'exit':
        break

    if not raw_input:
        continue

    # Tách các từ nếu bạn copy 1 cục cách nhau bằng dấu phẩy hoặc chấm phẩy
    # VD: "Acid ascorbic, Natri benzoate; Kali sorbate"
    terms = re.split(r'[,;]', raw_input)

    new_count = 0
    for term in terms:
        # Làm sạch: xóa khoảng trắng thừa, chuyển thành chữ thường (SymSpell cực thích chữ thường)
        clean_term = re.sub(r'\s+', ' ', term.strip()).lower()

        if clean_term and clean_term not in domain_dict:
            domain_dict[clean_term] = MAGIC_FREQ
            new_count += 1
            print(f"   [+] Đã hack tần suất: {clean_term} -> {MAGIC_FREQ}")
        elif clean_term in domain_dict:
            print(f"   [-] Đã tồn tại: {clean_term}")

    if new_count > 0:
        print(f"   => Đã thêm {new_count} từ mới vào bộ nhớ.\n")

# GHI RA FILE (Format: word frequency)
print("\nĐang ghi file cho SymSpell...")
with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
    for word, freq in sorted(domain_dict.items()):
        # SymSpell thường dùng khoảng trắng để cách giữa chữ và số tần suất
        f.write(f"{word} {freq}\n")

print(f"🎉 Xong! File {OUTPUT_FILE} đã sẵn sàng nạp thẳng vào thuật toán.")



# -3