# Kiến trúc bản Godot

Cấu trúc thư mục theo cùng tên miền với `src/` của bản Phaser, để đọc code cũ và tìm chỗ đặt code mới đều dễ. Chỉ tạo thư mục khi đã có code thật, theo quy tắc không tạo kiến trúc rỗng trong `AGENTS.md`.

```text
src/
├── config/        Thông số đã chốt: di chuyển, cân bằng
├── engine/        Hạ tầng dùng chung: nhịp khung hình
├── world/         Va chạm và biên map
├── gameplay/      Luật chơi
│   ├── combat/       Ngũ hành
│   └── characters/   Lớp nhân vật, danh mục Job × Element, input di chuyển
├── presentation/  Mọi thứ hiển thị
│   ├── characters/   body/ (male, female, face), equipment/ (clothing, weapons), moves/ (common, <class>/<hệ>), effects/, rig/
│   ├── hud/          Tên và màu của lớp, hệ
│   ├── ink/          Nét và màu khối tạm
│   └── world/        Nền và vật thể khối tạm
└── dev/sandbox/   Scene phát triển, hiện cũng là scene chính
tests/             Mốc kiểm thử, xem CLAUDE.md
docs/              Tài liệu
```

## Hướng phụ thuộc

```text
dev/sandbox → presentation → gameplay → world, config, engine
```

- Luật chơi không biết gì về hình ảnh. `src/gameplay`, `src/world`, `src/config`, `src/engine` không dùng scene tree, input hay màu sắc. Test tự quét điều này.
- Hình ảnh không tự quyết định luật. Trang phục và vũ khí không đổi va chạm hay sức mạnh; vòng chân cố định ở 12.
- Không thêm framework, event bus hay ECS khi chưa thật sự cần.

## Job × Element

- `Job` có 5 lớp, `Element` có 5 hệ. `CharacterCatalog` ghi trạng thái của 25 tổ hợp.
- Hệ là dữ liệu, không phải class riêng.
- Lớp mới đặt ở `src/gameplay/characters/jobs/<lớp>/`, chỉ tạo khi bắt đầu làm lớp đó.

## Khung hình

Mỗi khung chạy theo thứ tự: làm mượt thời gian khung, di chuyển nhân vật, camera đi theo. Mọi thứ nằm trong `_process`, không dùng `CharacterBody2D`, vì solver va chạm và camera giữ đúng công thức của bản cũ.

## Nhân vật

- Bản đồ file nằm ở `src/presentation/characters/README.md`.
- `rig/JointedRig.tscn` gồm các bộ phận có khớp, mỗi bộ phận có lớp thân và lớp đồ.
- Hai `AnimationPlayer`: `Base` cho toàn thân, `Action` viết đè tay cầm vũ khí, nên vừa chạy vừa vung được.
- Tay thứ hai tự tìm trượng trong chiêu hai tay.
- `rig/tools/build_rig.gd` tạo scene và animation từ các bảng tư thế trong `moves/`, và sẽ ghi đè mọi chỉnh tay trong editor.

## Phần đã đưa ra khỏi project

Scene làng và sprite cũ, bản thử đầu, các bộ test so với Phaser và báo cáo audit không ở repo này. Chúng nằm ở `D:\VietPhach\.tmp\godot-archive-2026-11-03\` (không vào git, không phải nơi lưu lâu dài) và commit `cb03c55` của repo cũ.
