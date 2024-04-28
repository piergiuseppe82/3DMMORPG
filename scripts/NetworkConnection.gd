extends Node

const PORT = 1382
const PORT_2 = 1383
const HOST = "127.0.0.1"

var peer
var player_pre = preload("res://characters/mc_player.tscn")

var map 

var region_servers = {
		"region_001":{"host":HOST,"port":PORT},
		"region_002":{"host":HOST,"port":PORT_2},
	}

func create_server(region = "region_001"):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(region_servers[region]["port"])
	if error != OK:
		OS.alert("Error on server creation: " +str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_rem_player)
	map = load("res://world/"+region+".tscn").instantiate()
	get_node("/root/Main").add_child(map)	

func create_client(_server = HOST, _port = PORT):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(_server,_port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer

func disconnect_client(player):
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	player.queue_free()

func change_server(player,server = HOST, port = PORT):
	get_tree().paused = true
	disconnect_client(player)
	create_client(server,port)
	get_tree().paused = false

func change_region(player,region):
	change_server(player,region_servers[region]["host"],region_servers[region]["port"])

func _add_player(id = 1):
	var player = load_player(id)
	map.call_deferred("add_child",player)

func _rem_player(id = 1):
	remove_player_in_map(id)

func remove_player_in_map(id):
	for c in map.get_children():
		if c.name == str(id):
			map.remove_child(c)
			c.queue_free()	

func load_player(id):
	var player = player_pre.instantiate()
	player.name = str(id)
	return player

