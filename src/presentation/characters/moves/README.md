# Động tác

| Thư mục | Nội dung |
| --- | --- |
| `move_builder.gd` | Biến bảng tư thế thành animation, giải thích các mã khớp |
| `common/` | Động tác mọi class dùng chung: chạy, đứng, dừng |
| `mage/water/` | Pháp Sư hệ Thủy |
| `swordsman/metal/` | Kiếm Khách hệ Kim (kiếm đang dùng để thử) |

Thêm class hoặc hệ mới: tạo `<class>/<hệ>/` có hàm `all()` giống các file trên, rồi thêm vào danh sách trong `rig/tools/build_rig.gd`. Tên động tác phải khác nhau giữa các class. Sửa xong chạy lại `build_rig.gd`.

Chưa có thư mục cho `warrior`, `fighter`, `archer` và các hệ khác vì chưa có động tác.
