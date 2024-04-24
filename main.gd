extends Node

var player_pre = preload("res://mc_player.tscn")

func _on_multiplayer_ui_connected(id):
	var player = load_player(id)
	call_deferred("add_child",player)
	


func load_player(id):
	var player = player_pre.instantiate()
	player.name = str(id)
	return player

func load_map(_id):
	if get_node_or_null("LandingMap"):
		return get_node("LandingMap")
	else:
		var map =  load("res://landing_map.tscn").instantiate()
		map.name = "LandingMap"
		return map
