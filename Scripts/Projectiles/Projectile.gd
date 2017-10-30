extends KinematicBody2D

func _ready():
	pass

func _on_Area2D_area_enter( area ):
	var other = area.get_parent()

	if "element" in other: # Makes shure it's something interactable with projectile
		if other.level > self.level:
			die()
		elif other.element == (self.element + 1) % 4: # Oposing element
			die()
# Lightning = 0, Nature = 1, Fire = 2, Water = 3