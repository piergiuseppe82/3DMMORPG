extends Node

var player_pre = preload("res://characters/mc_player.tscn")
var level_pre = preload("res://world/region_001.tscn")
var current_map
func _on_multiplayer_ui_connected(id):
	if not current_map:
		current_map = load_map(id)
		call_deferred("add_child",current_map)
	var player = load_player(id)
	current_map.call_deferred("add_child",player)

func _on_multiplayer_ui_disconnected(id):
	for c in current_map.get_children():
		if c.name == str(id):
			current_map.remove_child(c)
			c.queue_free()

func load_player(id):
	var player = player_pre.instantiate()
	player.name = str(id)
	return player

func load_map(id):
	var map = level_pre.instantiate()
	map.name = str(id)
	return map
