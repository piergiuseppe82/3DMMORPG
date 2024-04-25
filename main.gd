extends Node

var player_pre = preload("res://characters/mc_player.tscn")

func _on_multiplayer_ui_connected(id):
	var player = load_player(id)
	call_deferred("add_child",player)
	
	


func load_player(id):
	var player = player_pre.instantiate()
	player.name = str(id)
	return player
