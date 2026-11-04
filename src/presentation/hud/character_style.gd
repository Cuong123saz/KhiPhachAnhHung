class_name CharacterStyle
extends RefCounted
## Display names and colours for jobs and elements. Gameplay code never reads these.

# ELEMENT_PRESENTATION in src/presentation/hud/enemyHudModel.ts.
const ELEMENT_NAMES := {
	Element.METAL: "Kim", Element.WOOD: "Mộc", Element.WATER: "Thủy", Element.FIRE: "Hỏa", Element.EARTH: "Thổ",
}
const ELEMENT_COLORS := {
	Element.METAL: Color("f4d57c"), Element.WOOD: Color("95df97"), Element.WATER: Color("7fdaff"),
	Element.FIRE: Color("ffaaa0"), Element.EARTH: Color("deb899"),
}
const JOB_NAMES := {
	Job.WARRIOR: "Chiến Binh", Job.FIGHTER: "Đấu Sĩ", Job.SWORDSMAN: "Kiếm Khách",
	Job.MAGE: "Pháp Sư", Job.ARCHER: "Cung Thủ",
}
const STATUS_NAMES := {
	CharacterCatalog.PLAYABLE_IN_PHASER: "có gameplay ở bản Phaser",
	CharacterCatalog.MODEL_ONLY: "mới có model ở bản Phaser",
	CharacterCatalog.NOT_BUILT: "chưa làm",
}
const RELATION_NAMES := {
	Element.SAME: "cùng hệ", Element.GENERATES: "tương sinh", Element.GENERATED_BY: "được sinh",
	Element.OVERCOMES: "khắc", Element.OVERCOME_BY: "bị khắc", Element.UNRELATED: "không liên quan",
}
# JointedRig item index for each weapon kind.
const WEAPON_ITEMS := {"sword": 1, "staff": 2}
