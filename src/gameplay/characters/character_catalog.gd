class_name CharacterCatalog
extends RefCounted
## Which Job x Element characters exist, and how far along each one is. Update a
## character's status here when its kit is ported; docs/ROADMAP.md explains the steps.

# Gameplay exists in the Phaser game, not yet in Godot.
const PLAYABLE_IN_PHASER := "playable_in_phaser"
# The Phaser game has a model and a name for it, but no gameplay.
const MODEL_ONLY := "model_only"
# Allowed by Job x Element, nothing built.
const NOT_BUILT := "not_built"

# The one pairing each job has so far in the Phaser game (names in meleeModel.ts).
const FLAGSHIP_ELEMENT := {
	Job.WARRIOR: Element.FIRE,
	Job.FIGHTER: Element.EARTH,
	Job.SWORDSMAN: Element.METAL,
	Job.MAGE: Element.WATER,
	Job.ARCHER: Element.WOOD,
}
const _PLAYABLE_IN_PHASER := [Job.MAGE, Job.ARCHER]


static func status(job: String, element: String) -> String:
	assert(job in Job.ALL and element in Element.ALL, "Invalid character.")
	if FLAGSHIP_ELEMENT[job] != element:
		return NOT_BUILT
	return PLAYABLE_IN_PHASER if job in _PLAYABLE_IN_PHASER else MODEL_ONLY
