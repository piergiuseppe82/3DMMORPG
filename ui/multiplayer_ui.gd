extends Control

const PORT = 1382
const HOST = "127.0.0.1"

signal connected(id : int) 
var peer = ENetMultiplayerPeer.new()

func _on_host_btn_pressed():
	var error = peer.create_server(PORT,2)
	if error != OK:
		OS.alert("Error on server creation: " +error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	emit_signal("connected",1)
	hide()


func _on_client_btn_pressed():
	peer.create_client(HOST,PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	hide()

func _add_player(id = 1):
	emit_signal("connected",id)
