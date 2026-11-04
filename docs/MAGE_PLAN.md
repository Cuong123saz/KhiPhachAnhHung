# Kế hoạch Pháp Sư hệ Thủy

Mục tiêu đầu tiên: một Pháp Sư đánh được bia trong sandbox, đúng số liệu của `CORE_RULES.md` trong repo cũ `D:\VietPhach`, với chuyển động làm mới cho nhân vật ghép bộ phận.

## Điều cần chốt trước

**Bộ chiêu dùng lại luật cũ hay thiết kế mới?** Đã chốt không chép hành động và animation cũ. Chưa chốt phần luật: Thủy Pháo, Q, E, R, Mạch và tiến hóa. Kế hoạch dưới đây giả định giữ luật cũ và chỉ làm mới phần hình ảnh. Nếu thiết kế lại thì bước 3 trở đi phải viết lại.

## Các bước

Mỗi bước phải giữ `RigTestRunner` đạt và thêm test cho luật mới.

| # | Việc | Nguồn tham chiếu trong `D:\VietPhach\src\gameplay` | Xong khi |
|---|---|---|---|
| 1 | Chỉ số, HP/MP, Potential, cấp độ | `characters/core/`, `MageStats.ts`, `progression/` | Pháp Sư Lv1 có đúng chỉ số: 140 HP, 160 MP, 12 ATK, 8 DEF |
| 2 | Tính sát thương và bia thử | `combat/Damage.ts`, `Targeting.ts`, `Shield.ts` | Crit → DEF → Ngũ Hành → HP đúng số |
| 3 | Thủy Pháo: giữ để nạp, thả để bắn | `WaterCannon.ts`, `WaterCannonCombat.ts`, `combat/Projectile` | Bắn trúng bia, có tư thế nạp và bắn mới |
| 4 | Q, E, R và Mạch | `WaterMageSkills.ts`, `WaterMageState.ts`, `WaterMagePassive.ts` | Cả ba chiêu chạy, tốn MP và có hồi chiêu |
| 5 | HUD tối thiểu | `presentation/hud/` | Thấy HP, MP, Mạch, hồi chiêu |
| 6 | Quái và AI | `gameplay/enemies/` | Có quái đánh lại |
| 7 | Tiến hóa A1, B1 | Các file còn lại trong `jobs/mage/` | Lên được cấp 15 |

Quy mô tham khảo: `gameplay/combat` khoảng 280 dòng TypeScript, `characters/core` 120, `jobs/mage` 940, `enemies` 840, `run` 1.130. Luật có thể chép sang khá thẳng; phần hình ảnh thì làm mới.

Cấu trúc đích trong `README.md` của repo cũ nói `WaterMageRuntime` chỉ điều phối, không ôm mọi thứ. Giữ nguyên nguyên tắc này khi port.

## Các động tác hiện có

Phím Q, E, R trong sandbox hiện chỉ là động tác thử: xoay trượng, giơ trượng hai tay, cắm trượng. Chúng chưa gây sát thương và chưa phải bộ chiêu thật. Tới bước 4 sẽ gắn chúng hoặc động tác mới vào chiêu.

## Chưa quyết

- Art thật cho nhân vật và map. Hiện toàn bộ là khối tạm.
- Co-op: `README.md` của repo cũ có nhắc, còn brief Godot là offline. Chưa đưa vào kế hoạch.
- Bản Phaser sẽ dừng phát triển từ lúc nào.
