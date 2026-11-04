# Việt Phách Desktop

Bản Godot 4 chạy offline trên Windows. Hiện là sandbox phát triển: nhân vật ghép bộ phận thay được đồ và vũ khí, đang chuẩn bị cho Pháp Sư hệ Thủy. Toàn bộ hình là khối tạm, chưa có combat thật.

## Chạy thử

1. Tải **Godot 4 Standard** cho Windows tại <https://godotengine.org/download/windows/>, giải nén. Đã test với bản **4.7.2**. Không dùng bản .NET.
2. Trong Project Manager chọn **Import**, trỏ tới `project.godot` trong thư mục này, rồi **Import & Edit**.
3. Nhấn **F5**.

## Điều khiển

| Phím | Tác dụng |
| --- | --- |
| WASD hoặc mũi tên | Di chuyển |
| 1 / 2 / 3 / 4 / 5 / 6 | Đổi tóc / áo / quần / giày / vũ khí / áo choàng |
| 0 | Cởi hết |
| 7 | Đổi kiểu mặt |
| Space | Vung thử (chỉ là hình) |
| Q | Giơ trượng hai tay niệm, rồi vung mạnh về trước, đứng yên khi thi triển |
| E | Xoay nhanh trượng, vừa chạy vừa xoay được |
| R | Cắm trượng khựng lại, nước trồi dần lên, đứng yên khi thi triển |
| T | So nhịp 12 hình/giây với chuyển động trơn |
| Esc | Thoát |

Q, E, R hiện chỉ là động tác thử, chưa phải chiêu thật. Trên map, chỉ cây đa, miếu, nhà, tre và hàng rào chặn đường; nước và ruộng vẫn đi xuyên được.

## Kiểm thử

Đây là mốc phát triển duy nhất, chạy từ thư mục này (thay `godot` bằng đường dẫn tới `Godot_v4.x-stable_win64_console.exe`). Lệnh mở một cửa sổ game trong vài chục giây và phải kết thúc bằng `RESULT: PASS`:

```bash
godot --path . res://tests/RigTestRunner.tscn
```

Ảnh chụp để xem bằng mắt nằm ở `tests/results/rig_test/`.

## Chỉnh animation

Mở `src/presentation/characters/rig/JointedRig.tscn`, chọn node `Base` hoặc `Action` rồi dùng panel Animation. Script `src/presentation/characters/rig/tools/build_rig.gd` sẽ ghi đè các chỉnh sửa này, nên sau khi chỉnh tay thì đừng chạy lại nó.

## Xuất file .exe

Bước này **chưa kiểm chứng**. Cần cài export templates (**Editor > Manage Export Templates**, khoảng 1,3 GB), rồi vào **Project > Export** và chọn preset **Windows Desktop**.

## Tài liệu

- [Quy tắc phát triển](CLAUDE.md)
- [Kiến trúc](docs/ARCHITECTURE.md)
- [Kế hoạch Pháp Sư](docs/MAGE_PLAN.md)
