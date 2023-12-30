extends Node2D

onready var walker_scene : PackedScene = preload("res://Walker/Walker.tscn")

var floors = []

const floor_colors = [
	Color8(218, 215, 205, 220),
	Color8(163, 177, 138, 220),
	Color8(88, 129, 87, 220),
	Color8(58, 90, 64, 220),
	Color8(52, 78, 65, 220),
]

func _ready():
	randomize()
	var building = get_node("Building")
	var i = 0
	for node in building.get_children():
		var color_with_less_alpha = Color8(floor_colors[i].r, floor_colors[i].g, floor_colors[i].b, 200)
		node.set_modulate(floor_colors[i])
		floors.append(node)
		i += 1

func _on_WalkerTimer_timeout():
	var walker = walker_scene.instance()
	var chosen_floor_index = randi() % len(floors)
	var chosen_floor = floors[chosen_floor_index]
	
	walker.connect("entered_waiting_queue", chosen_floor, "_on_Walker_entered_waiting_queue", [walker])
	walker.position = chosen_floor.get_node("WalkerSpawn").global_position
	walker.spawn_floor = chosen_floor_index
	walker.set_random_desired_floor()
	walker.set_color(floor_colors[walker.desired_floor])
	
	add_child(walker)
