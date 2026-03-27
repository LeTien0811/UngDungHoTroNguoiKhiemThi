import csv
import re
from bs4 import BeautifulSoup

# Thay thế đoạn HTML này bằng việc đọc từ file hoặc dùng thư viện requests để tải từ URL
# Ví dụ đọc từ file:
# with open('index.html', 'r', encoding='utf-8') as file:
#     html_content = file.read()

html_content = """
<table border="0" cellspacing="0" cellpadding="0" width="0"><!--VABWAFAATABfADIAMAAyADUAMQAyADIANQA=-->
 <tbody><tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center"><b>TT</b></p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border:solid windowtext 1.0pt;
  border-left:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center"><b>TÊN NHÓM HÀNG
  HÓA</b></p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border:solid windowtext 1.0pt;
  border-left:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center"><b>NỘI DUNG BẮT
  BUỘC</b></p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">1</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Lương thực</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">2</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thực phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin, cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">3</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thực phẩm bảo vệ sức khỏe</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần, thành phần định lượng hoặc giá trị
  dinh dưỡng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">e) Công bố khuyến cáo về nguy cơ (nếu có);</p>
  <p style="margin-top:6.0pt">g) Ghi cụm từ: “Thực phẩm bảo vệ sức khỏe”;</p>
  <p style="margin-top:6.0pt">h) Ghi cụm từ: “Thực phẩm này không phải là
  thuốc, không có tác dụng thay thế thuốc chữa bệnh.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">4</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thực phẩm đã qua chiếu xạ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Ghi cụm từ: “Thực phẩm đã qua chiếu xạ”;</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center"><a name="muc_5" class="clsBookmark clsopentLogin clsBookmarkGuider" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">5</a></p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt"><a name="muc_5_name">Thực phẩm biến đổi gen</a></p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Ghi cụm từ: “Thực phẩm biến đổi gen” hoặc
  “biến đổi gen” bên cạnh tên của thành phần nguyên liệu biến đổi gen kèm theo
  hàm lượng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">6</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồ uống (trừ rượu):</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">7</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Rượu</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Hàm lượng etanol;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng (nếu có);</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn bảo quản (đối với rượu vang);</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo (nếu có);</p>
  <p style="margin-top:6.0pt">e) Mã nhận diện lô (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">8</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thuốc lá</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">d) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">đ) Mã số, mã vạch.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">9</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Phụ gia thực phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">e) Ghi cụm từ: “Phụ gia thực phẩm”;</p>
  <p style="margin-top:6.0pt">g) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">10</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Vi chất dinh dưỡng</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thành phần;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">đ) Ghi cụm từ: “Dùng cho thực phẩm”.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">11</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Nguyên liệu thực phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nguyên liệu;</p>
  <p style="margin-top:6.0pt">b) Định lượng;</p>
  <p style="margin-top:6.0pt">c) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">d) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng và bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">12</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thuốc, nguyên liệu làm thuốc dùng cho người</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần định lượng, hàm lượng, nồng độ hoặc
  khối lượng dược chất, dược liệu của thuốc, nguyên liệu làm thuốc;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng/hạn dùng;</p>
  <p style="margin-top:6.0pt">d) Dạng bào chế trừ nguyên liệu làm thuốc;</p>
  <p style="margin-top:6.0pt">đ) Quy cách đóng gói, tiêu chuẩn chất lượng;</p>
  <p style="margin-top:6.0pt">e) Số đăng ký hoặc số giấy phép nhập khẩu, số lô sản
  xuất;</p>
  <p style="margin-top:6.0pt">g) Thông tin, cảnh báo vệ sinh, an toàn, sức khỏe;</p>
  <p style="margin-top:6.0pt">h) Hướng dẫn sử dụng trừ nguyên liệu làm thuốc, hướng
  dẫn (điều kiện) bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">13</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt"><a name="cumtu_5" class="clsBookmark clsopentLogin clsBookmarkGuider" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">Trang thiết bị y tế</a></p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Số lưu hành hoặc số giấy phép nhập khẩu <a name="cumtu_6" class="clsBookmark clsopentLogin" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">trang thiết bị y tế</a>;</p>
  <p style="margin-top:6.0pt">b) Số lô hoặc số sê ri của <a name="cumtu_7" class="clsBookmark clsopentLogin" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">trang
  thiết bị y tế</a>;</p>
  <p style="margin-top:6.0pt">c) Ngày sản xuất, hạn sử dụng: <a name="cumtu_8" class="clsBookmark clsopentLogin" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">Trang
  thiết bị y tế</a> tiệt trùng, sử dụng một lần, thuốc thử, chất hiệu chuẩn,
  vật liệu kiểm soát, hóa chất phải ghi hạn sử dụng. Các trường hợp khác ghi
  ngày sản xuất hoặc hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo, hướng dẫn sử dụng, hướng
  dẫn bảo quản, cơ sở bảo hành: Có thể được thể hiện trực tiếp trên nhãn <a name="cumtu_9" class="clsBookmark clsopentLogin clsBookmarkGuider" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">trang thiết bị y tế</a> hoặc ghi rõ hướng dẫn tra cứu các
  thông tin này trên nhãn <a name="cumtu_10" class="clsBookmark clsopentLogin" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">trang thiết bị y tế</a>.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">14</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Mỹ phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">c) Số lô sản xuất;</p>
  <p style="margin-top:6.0pt">d) Ngày sản xuất hoặc hạn sử dụng/hạn dùng;</p>
  <p style="margin-top:6.0pt">đ) Với những sản phẩm có độ ổn định dưới 30 tháng,
  bắt buộc phải ghi ngày hết hạn;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng trừ khi dạng trình bày đã
  thể hiện rõ cách sử dụng của sản phẩm;</p>
  <p style="margin-top:6.0pt">g) Thông tin, cảnh báo.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center"><a name="muc_15" class="clsBookmark clsopentLogin clsBookmarkGuider" onmouseover="LS_Tootip_Type_Bookmark_Archive();" onmouseout="hideddrivetip();">15</a></p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt"><a name="muc_15_name">Hóa chất gia dụng</a></p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc hàm lượng hoạt chất;</p>
  <p style="margin-top:6.0pt">đ) Số lô sản xuất;</p>
  <p style="margin-top:6.0pt">e) Số đăng ký lưu hành tại Việt Nam;</p>
  <p style="margin-top:6.0pt">g) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">h) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">16</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thức ăn chăn nuôi</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">17</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thuốc thú y, vắcxin, chế phẩm sinh học dùng trong
  thú y</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, bảo quản;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">18</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thức ăn thủy sản</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, bảo quản;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">g) Số điện thoại (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">19</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Chế phẩm sinh học, vi sinh vật, hóa chất, chất xử
  lý cải tạo môi trường trong nuôi trồng thủy sản</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, bảo quản;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">g) Số điện thoại (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">20</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thuốc bảo vệ thực vật</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hàm lượng; </p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">21</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Giống cây trồng</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">22</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Giống vật nuôi</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">23</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Giống thủy sản</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên giống thủy sản (bao gồm tên thương mại và tên
  khoa học);</p>
  <p style="margin-top:6.0pt">b) Tên và địa chỉ của cơ sở sản xuất, ương dưỡng;</p>
  <p style="margin-top:6.0pt">c) Số lượng giống thủy sản;</p>
  <p style="margin-top:6.0pt">d) Chỉ tiêu chất lượng theo Tiêu chuẩn công bố áp
  dụng;</p>
  <p style="margin-top:6.0pt">đ) Ngày xuất bán;</p>
  <p style="margin-top:6.0pt">e) Thời hạn sử dụng (nếu có);</p>
  <p style="margin-top:6.0pt">g) Hướng dẫn vận chuyển, bảo quản và sử dụng;</p>
  <p style="margin-top:6.0pt">h) Số điện thoại (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">24</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồ chơi trẻ em</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">đ) Năm sản xuất.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">25</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Sản phẩm dệt, may, da, giầy</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">đ) Năm sản xuất.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">26</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Sản phẩm nhựa, cao su</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thành phần;</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật; </p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">27</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Giấy, bìa, cacton</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">28</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồ dùng giảng dạy, đồ dùng học tập, văn phòng phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">29</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Ấn phẩm chính trị, kinh tế, văn hóa, khoa học,
  giáo dục, văn học, nghệ thuật, tôn giáo</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Nhà xuất bản (Nhà sản xuất), nhà in;</p>
  <p style="margin-top:6.0pt">b) Tên tác giả, dịch giả;</p>
  <p style="margin-top:6.0pt">c) Giấy phép xuất bản;</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật (khổ, kích thước, số trang);</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">30</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Nhạc cụ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">b) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">31</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Dụng cụ thể dục thể thao, máy tập thể dục thể
  thao</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thành phần;</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật; </p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">32</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồ gỗ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">33</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Sản phẩm sành, sứ, thủy tinh</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">34</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Hàng thủ công mỹ nghệ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">35</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồ gia dụng, thiết bị gia dụng (không dùng điện)</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">36</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Bạc</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">37</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đá quý</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">38</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Vàng trang sức, mỹ nghệ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Hàm lượng;</p>
  <p style="margin-top:6.0pt">b) Khối lượng;</p>
  <p style="margin-top:6.0pt">c) Khối lượng vật gắn (nếu có);</p>
  <p style="margin-top:6.0pt">d) Mã ký hiệu sản phẩm;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">39</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Trang thiết bị bảo hộ lao động, phòng cháy chữa
  cháy</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần;</p>
  <p style="margin-top:6.0pt">đ) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">g) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">40</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Thiết bị bưu chính, viễn thông, công nghệ thông tin,
  điện, điện tử; Sản phẩm công nghệ thông tin được tân trang, làm mới.</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">đ) Với sản phẩm công nghệ thông tin được tân trang
  làm mới phải ghi rõ bằng tiếng Việt là “sản phẩm tân trang làm mới” hoặc bằng
  tiếng Anh có ý nghĩa tương đương.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">41</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Máy móc, trang thiết bị cơ khí</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo an toàn;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">42</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Máy móc, trang thiết bị đo lường, thử nghiệm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">43</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Sản phẩm luyện kim</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thành phần định lượng;</p>
  <p style="margin-top:6.0pt">c) Thông số kỹ thuật.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">44</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Dụng cụ đánh bắt thủy sản</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có);</p>
  <p style="margin-top:6.0pt">d) Số điện thoại (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">45</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Ô tô</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">b) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (Model code);</p>
  <p style="margin-top:6.0pt">c) Số khung hoặc số VIN;</p>
  <p style="margin-top:6.0pt">d) Khối lượng bản thân;</p>
  <p style="margin-top:6.0pt">đ) Số người cho phép chở (đối với xe chở người);</p>
  <p style="margin-top:6.0pt">e) Khối lượng toàn bộ thiết kế;</p>
  <p style="margin-top:6.0pt">g) Số chứng nhận phê duyệt kiểu (Type Approved) -
  đối với xe sản xuất lắp ráp trong nước;</p>
  <p style="margin-top:6.0pt">h) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">i) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">46</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Rơmooc, sơmi rơmooc</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">b) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (model code);</p>
  <p style="margin-top:6.0pt">c) Số khung hoặc số VIN;</p>
  <p style="margin-top:6.0pt">d) Khối lượng bản thân;</p>
  <p style="margin-top:6.0pt">e) Khối lượng toàn bộ thiết kế;</p>
  <p style="margin-top:6.0pt">g) Số chứng nhận phê duyệt kiểu (Type Approved) -
  đối với xe sản xuất lắp ráp trong nước;</p>
  <p style="margin-top:6.0pt">h) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">i) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">47</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Mô tô, xe máy</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">b) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (Model code);</p>
  <p style="margin-top:6.0pt">c) Số khung;</p>
  <p style="margin-top:6.0pt">d) Khối lượng bản thân; </p>
  <p style="margin-top:6.0pt">đ) Dung tích xi lanh;</p>
  <p style="margin-top:6.0pt">g) Số chứng nhận phê duyệt kiểu (Type Approved) -
  đối với xe sản xuất lắp ráp trong nước;</p>
  <p style="margin-top:6.0pt">h) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">i) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">48</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Xe máy chuyên dùng</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">b) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (Model code);</p>
  <p style="margin-top:6.0pt">c) Số khung;</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật đặc trưng; </p>
  <p style="margin-top:6.0pt">đ) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">e) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">49</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Xe chở người bốn bánh có gắn động cơ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">f) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">g) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (Model code);</p>
  <p style="margin-top:6.0pt">h) Khối lượng bản thân;</p>
  <p style="margin-top:6.0pt">i) Số người cho phép chở;</p>
  <p style="margin-top:6.0pt">đ) Khối lượng toàn bộ thiết kế;</p>
  <p style="margin-top:6.0pt">e) Số khung hoặc số VIN;</p>
  <p style="margin-top:6.0pt">g) Số chứng nhận phê duyệt kiểu (Type Approved) -
  đối với xe sản xuất lắp ráp trong nước;</p>
  <p style="margin-top:6.0pt">h) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">i) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">50</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Xe đạp</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Tên nhà sản xuất;</p>
  <p style="margin-top:6.0pt">b) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thông số kỹ thuật cơ bản;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">51</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Phụ tùng của phương tiện giao thông</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Nhãn hiệu, tên thương mại (Commercial name), mã
  kiểu loại (Model code) (nếu có);</p>
  <p style="margin-top:6.0pt">b) Mã phụ tùng (part number);</p>
  <p style="margin-top:6.0pt">c) Năm sản xuất (nếu có);</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật (nếu có); </p>
  <p style="margin-top:6.0pt">đ) Thông tin, cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">52</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Vật liệu xây dựng và trang trí nội thất</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">53</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Các sản phẩm từ dầu mỏ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Thành phần;</p>
  <p style="margin-top:6.0pt">c) Thông tin, cảnh báo;</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">54</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Chất tẩy rửa</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">c) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">d) Thông tin, cảnh báo; </p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">55</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Hóa chất</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng (nếu có);</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Mã nhận dạng hóa chất (nếu có);</p>
  <p style="margin-top:6.0pt">e) Hình đồ cảnh báo, từ cảnh báo, cảnh báo nguy cơ
  (nếu có);</p>
  <p style="margin-top:6.0pt">g) Biện pháp phòng ngừa (nếu có);</p>
  <p style="margin-top:6.0pt">h) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">56</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Phân bón</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng, hướng dẫn bảo quản;</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">57</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Vật liệu nổ công nghiệp</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Định lượng;</p>
  <p style="margin-top:6.0pt">b) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">c) Hạn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thành phần hoặc thành phần định lượng;</p>
  <p style="margin-top:6.0pt">đ) Thông tin cảnh báo;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng, hướng dẫn bảo quản.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">58</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Kính mắt</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có);</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">59</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Đồng hồ</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có);</p>
  <p style="margin-top:6.0pt">d) Hướng dẫn sử dụng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">60</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Bỉm, băng vệ sinh, khẩu trang, bông tẩy trang, bông
  vệ sinh tai, giấy vệ sinh</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">đ) Tháng sản xuất;</p>
  <p style="margin-top:6.0pt">e) Hạn sử dụng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">61</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Bàn chải đánh răng</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">đ) Tháng sản xuất.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">62</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Khăn ướt</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">đ) Ngày sản xuất;</p>
  <p style="margin-top:6.0pt">e) Hạn sử dụng.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">63</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Máy móc, dụng cụ làm đẹp</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">b) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">c) Thông tin cảnh báo (nếu có);</p>
  <p style="margin-top:6.0pt">d) Năm sản xuất.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">64</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Dụng cụ, vật liệu bao gói chứa đựng thực phẩm</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Thành phần;</p>
  <p style="margin-top:6.0pt">b) Thông số kỹ thuật;</p>
  <p style="margin-top:6.0pt">c) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">d) Thông tin cảnh báo (nếu có); </p>
  <p style="margin-top:6.0pt">đ) Ngày sản xuất.</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">65</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Mũ bảo hiểm dùng cho người đi mô tô, xe gắn máy, xe
  đạp điện, xe máy điện, xe đạp máy (gọi tắt là mũ bảo hiểm)</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Cỡ mũ;</p>
  <p style="margin-top:6.0pt">b) Tháng, năm sản xuất;</p>
  <p style="margin-top:6.0pt">c) Kiểu mũ (Model);</p>
  <p style="margin-top:6.0pt">d) Định lượng;</p>
  <p style="margin-top:6.0pt">đ) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">e) Ghi cụm từ: “Mũ bảo hiểm dùng cho người đi mô
  tô, xe máy”;</p>
  <p style="margin-top:6.0pt">g) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
 <tr>
  <td width="4%" valign="top" style="width:4.78%;border:solid windowtext 1.0pt;
  border-top:none;padding:0in 0in 0in 0in">
  <p align="center" style="margin-top:6.0pt;text-align:center">66</p>
  </td>
  <td width="17%" valign="top" style="width:17.82%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">Xe đạp điện, xe máy điện, xe đạp máy</p>
  </td>
  <td width="77%" valign="top" style="width:77.4%;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0in 0in 0in 0in">
  <p style="margin-top:6.0pt">a) Nhãn hiệu;</p>
  <p style="margin-top:6.0pt">b) Loại Model;</p>
  <p style="margin-top:6.0pt">c) Tự trọng (Khối lượng bản thân);</p>
  <p style="margin-top:6.0pt">d) Thông số kỹ thuật; </p>
  <p style="margin-top:6.0pt">đ) Năm sản xuất;</p>
  <p style="margin-top:6.0pt">e) Hướng dẫn sử dụng;</p>
  <p style="margin-top:6.0pt">g) Thông tin cảnh báo (nếu có).</p>
  </td>
 </tr>
</tbody></table>
"""

soup = BeautifulSoup(html_content, 'lxml')
grouped_data = {}

# TỪ ĐIỂN TỪ VIẾT TẮT ĐỜI THỰC (Bổ sung linh hoạt)
CUSTOM_ABBREVIATIONS = {
    "hướng dẫn sử dụng": "hdsd|hd sd|cách dùng",
    "hướng dẫn bảo quản": "hdbq|bảo quản",
    "ngày sản xuất": "nsx|mfg",
    "hạn sử dụng": "hsd|exp",
    "khối lượng tịnh": "kl tịnh|trọng lượng",
    "thể tích thực": "thể tích|dung tích|vol",
    "thành phần": "t/p|nguyên liệu",
    "thành phần định lượng": "t/p",
    "định lượng": "d/l"
}


# HÀM 1: Gắn Tag Category ngắn gọn (The Category Bloat Solution)
def get_short_category(raw_cat_string):
    cat_lower = raw_cat_string.lower()
    # Nhận diện theo từ khóa trong mớ text dài thò lò
    if any(k in cat_lower for k in ["thực phẩm", "lương thực", "ăn", "uống"]):
        return "FOOD"
    if any(k in cat_lower for k in ["thuốc", "dược", "y tế", "sức khỏe"]):
        return "MED"
    if any(k in cat_lower for k in ["hóa", "tẩy rửa", "mỹ phẩm", "sinh học"]):
        return "CHEM"
    return "OTHER"


# HÀM 2: Loại bỏ ngoặc đơn pháp lý TRƯỚC khi cắt chuỗi
def remove_legal_brackets(text):
    return re.sub(
        r'(?i)\((?:nếu có|điều kiện|bao gồm.*?|Nhà sản xuất|khổ.*?|Commercial name|Model code|đối với.*?|Type Approved|part number|Model)\)',
        '', text)


# HÀM 3: Làm sạch từng mảnh Keyword sau khi cắt
def clean_chunk(text):
    text = text.strip()
    if not text: return ""

    # Ưu tiên hốt ruột ngoặc kép (Ghi cụm từ: "...")
    match = re.search(r'(?i)ghi\s+(?:cụm từ|dòng chữ|chữ)\s*:?\s*["“](.*?)["”]', text)
    if match:
        return match.group(1).strip()

    # Xóa ký tự đầu dòng (a), b), 1., -...)
    text = re.sub(r'^([a-zA-Z0-9đĐ]+\s*[)\.]\s*|[-+*]\s*)', '', text)
    # Xóa dấu chấm (.) ở cuối dòng
    text = re.sub(r'[.\s]+$', '', text)
    # Dọn dẹp khoảng trắng thừa giữa các từ
    text = re.sub(r'\s+', ' ', text)

    return text.strip()


# HÀM 4: Bỏ dấu tiếng Việt
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


# THỰC THI CHÍNH
table = soup.find('table')
rows = table.find_all('tr')

for row in rows:
    cols = row.find_all('td')
    if len(cols) >= 3:
        # Lấy Tag phân loại xịn (FOOD, MED...) thay vì lấy đoạn text dài
        short_cat = get_short_category(cols[1].get_text())

        # Lấy khối text lớn
        raw_text_block = cols[2].get_text(separator=' ')

        # BƯỚC 1: Xóa các ngoặc đơn chứa dấu phẩy để tránh cắt nhầm
        block_no_brackets = remove_legal_brackets(raw_text_block)

        # BƯỚC 2: CẮT CHUỖI SÁT THỦ (Giải quyết Bureaucracy Trap & Combination Nightmare)
        # Cắt chuỗi nếu gặp: dấu chấm phẩy (;), dấu phẩy (,), chữ " hoặc ", chữ " và ", hoặc xuống dòng (\n)
        raw_keywords = re.split(r'[;,\n]|\s+hoặc\s+|\s+và\s+', block_no_brackets)

        for raw_kw in raw_keywords:
            kw_clean = clean_chunk(raw_kw)
            if len(kw_clean) < 2:  # Bỏ qua các chuỗi rỗng hoặc rác quá ngắn
                continue

                # Format tên chuẩn
            kw_standard = kw_clean.capitalize()
            kw_lower = kw_clean.lower()
            kw_unaccent = remove_vietnamese_accents(kw_clean)

            # BƯỚC 3: TẠO VARIANTS VÀ NỐI TỪ ĐIỂN ĐỜI THỰC (The Real-world Missing Link)
            variants_list = [kw_lower, kw_unaccent]
            if kw_lower in CUSTOM_ABBREVIATIONS:
                variants_list.append(CUSTOM_ABBREVIATIONS[kw_lower])

            var_clean = "|".join(dict.fromkeys(variants_list))  # Dùng dict.fromkeys để xóa trùng lặp nếu có

            # BƯỚC 4: GOM NHÓM
            if kw_standard not in grouped_data:
                grouped_data[kw_standard] = {
                    'variants': var_clean,
                    'categories': {short_cat}
                }
            else:
                grouped_data[kw_standard]['categories'].add(short_cat)

# XUẤT CSV
csv_filename = 'domain_keywords.csv'
with open(csv_filename, mode='w', newline='', encoding='utf-8') as csv_file:
    writer = csv.writer(csv_file)
    writer.writerow(['Keyword_Standard', 'Variants', 'Category'])

    for keyword, data in grouped_data.items():
        # Xử lý Logic ALL cho Category
        # Nếu 1 Keyword thuộc nhiều nhóm (VD: cả FOOD và CHEM), hoặc thuộc nhóm OTHER, ta gán là ALL
        tags = data['categories']
        if len(tags) > 1 or "OTHER" in tags:
            final_cat = "ALL"
        else:
            final_cat = list(tags)[0]  # Lấy tag duy nhất

        writer.writerow([keyword, data['variants'], final_cat])

print(f"Xử lý thành công! File xuất: {csv_filename}")