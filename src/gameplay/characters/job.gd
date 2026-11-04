class_name Job
extends RefCounted
## The five jobs. A character is Job x Element; see CharacterCatalog.
##
## combat_role is the melee/ranged role threat already uses in the Phaser game.
## weapon is the kind each job carries; how it looks is a presentation concern.

const WARRIOR := "warrior"
const FIGHTER := "fighter"
const SWORDSMAN := "swordsman"
const MAGE := "mage"
const ARCHER := "archer"
const ALL: Array[String] = [WARRIOR, FIGHTER, SWORDSMAN, MAGE, ARCHER]

const DEFINITIONS := {
	WARRIOR: {"combat_role": "melee", "weapon": "great_blade"},
	FIGHTER: {"combat_role": "melee", "weapon": "stone_hammer"},
	SWORDSMAN: {"combat_role": "melee", "weapon": "sword"},
	MAGE: {"combat_role": "ranged", "weapon": "staff"},
	ARCHER: {"combat_role": "ranged", "weapon": "bow"},
}
