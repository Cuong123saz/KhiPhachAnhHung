class_name Element
extends RefCounted
## The five elements and their two cycles, from src/gameplay/combat/Element.ts.
## An element is data on an actor or a hit, never a class of its own (CORE_RULES.md).

const METAL := "metal"
const WOOD := "wood"
const WATER := "water"
const FIRE := "fire"
const EARTH := "earth"
const ALL: Array[String] = [METAL, WOOD, WATER, FIRE, EARTH]

const SAME := "same"
const GENERATES := "generates"
const GENERATED_BY := "generatedBy"
const OVERCOMES := "overcomes"
const OVERCOME_BY := "overcomeBy"
const UNRELATED := "unrelated"

const _OVERCOMES := {WOOD: EARTH, EARTH: WATER, WATER: FIRE, FIRE: METAL, METAL: WOOD}
const _GENERATES := {WOOD: FIRE, FIRE: EARTH, EARTH: METAL, METAL: WATER, WATER: WOOD}


static func relation(source: String, target: String) -> String:
	assert(source in ALL and target in ALL, "Invalid element.")
	if source == target:
		return SAME
	if _OVERCOMES[source] == target:
		return OVERCOMES
	if _OVERCOMES[target] == source:
		return OVERCOME_BY
	if _GENERATES[source] == target:
		return GENERATES
	if _GENERATES[target] == source:
		return GENERATED_BY
	return UNRELATED


## Only the overcoming cycle changes damage; generating does not.
static func multiplier(relation_name: String) -> float:
	match relation_name:
		OVERCOMES:
			return CoreBalance.ELEMENT_ADVANTAGE
		OVERCOME_BY:
			return CoreBalance.ELEMENT_DISADVANTAGE
	return CoreBalance.ELEMENT_NORMAL
