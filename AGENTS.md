# Luật cho AI: bản Godot

Áp dụng cho mọi công cụ AI (Claude Code, Codex...) khi làm trong repo này. Đây là nguồn luật duy nhất; `CLAUDE.md` chỉ trỏ về file này. Nếu yêu cầu mới mâu thuẫn với luật ở đây, báo người dùng trước khi làm.

## Cấu trúc nhân vật

Code nhân vật nằm ở `src/presentation/characters/`. Giữ đúng các mục, không gộp lại:

| Mục | Chứa gì |
| --- | --- |
| `body/male`, `body/female`, `body/face` | Thân gốc và khuôn mặt, không có đồ |
| `equipment/clothing` | Mỗi loại đồ một file |
| `equipment/weapons` | Mỗi vũ khí một file, chỉ có hình dáng |
| `equipment/equipment_catalog.gd` | Danh sách ô và món đồ |
| `moves/common` | Động tác mọi class dùng chung |
| `moves/<class>/<hệ>` | Tư thế cầm và chiêu riêng của từng class và hệ |
| `effects` | Hình hiệu ứng chiêu |
| `rig` | Xương và ghép nhân vật, không chứa hình đồ hay bảng động tác |

- Quần áo, trang bị và động tác không được đưa vào `rig/jointed_rig.gd`.
- Động tác của class này không đặt trong thư mục của class khác.
- Thêm động tác: làm theo `src/presentation/characters/moves/README.md`, rồi chạy `rig/tools/build_rig.gd`.
- Không sửa tay `rig/JointedRig.tscn` hay `rig/rig_animations.tres` nếu sau đó còn chạy `build_rig.gd`, vì script sẽ ghi đè.
- Không tạo thư mục rỗng hay class giữ chỗ. Ngoại lệ duy nhất là `body/female`, do người dùng yêu cầu.

## Ranh giới code

- `src/gameplay`, `src/world`, `src/config`, `src/engine` chỉ chứa luật: không dùng scene tree, input hay hình ảnh.
- Trang phục và vũ khí chỉ đổi ngoại hình, không đổi va chạm, chỉ số hay sát thương.
- Hệ ngũ hành là dữ liệu, không tạo class riêng cho từng hệ.
- Không thêm framework, ECS hay event bus khi chưa thật sự cần.
- Chi tiết ở `docs/ARCHITECTURE.md`.

## Nhân vật và cảm giác chơi

- Không chép hành động hay animation của nhân vật cũ. Chuyển động được làm riêng cho nhân vật ghép bộ phận.
- Giữ nguyên camera, tốc độ và cách di chuyển hiện tại.

## Kiểm thử

Mốc duy nhất, chạy từ thư mục gốc repo, phải kết thúc bằng `RESULT: PASS`:

```bash
godot --path . res://tests/RigTestRunner.tscn
```

- Trong lúc làm, chỉ test phần đang sửa, hạn chế chạy lại test cũ. Chạy cả bộ khi người dùng yêu cầu hoặc khi thay đổi đụng tới phần dùng chung.
- Lệnh mở cửa sổ game; báo trước để người dùng không nhầm với bản đang chơi.
- Không dựng lại các bộ test so với Phaser hay bản thử cũ.
- Test không đánh giá được hình đẹp xấu. Điều chưa xem bằng mắt thì phải nói rõ là chưa kiểm chứng.

## Trọng tâm hiện tại

Pháp Sư hệ Thủy, theo `docs/MAGE_PLAN.md`. Chiêu lấy một phần từ bản cũ nhưng sẽ đổi khác; chưa áp dụng cho tới khi người dùng yêu cầu. Luật trong repo này được ưu tiên.

## Repo cũ

Repo này độc lập. `D:\VietPhach` (bản Phaser, gồm `CORE_RULES.md`) chỉ để tham chiếu khi cần:

- Không sửa, xóa hay commit gì trong repo đó.
- Không để code, scene hay test ở đây phụ thuộc vào đường dẫn của repo đó. Muốn dùng gì thì chép số liệu hoặc asset sang đây.

## Làm việc

- Chỉ commit hoặc push khi người dùng yêu cầu.
- Khi đổi cấu trúc, cập nhật luôn file này và README của thư mục liên quan.
