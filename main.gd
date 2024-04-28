extends Node

var player_pre = preload("res://characters/mc_player.tscn")
var level_pre = preload("res://world/region_001.tscn")

func _on_multiplayer_ui_connected(id):
	var map = load_map(id)
	call_deferred("add_child",map)
	var player = load_player(id)
	map.call_deferred("add_child",player)
	
	


func load_player(id):
	var player = player_pre.instantiate()
	player.name = str(id)
	return player

func load_map(id):
	var map = level_pre.instantiate()
	map.name = str(id)
	return map
