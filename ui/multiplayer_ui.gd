extends Control

func _on_host_btn_pressed():
	NetworkConnection.create_server()
	hide()

func _on_client_btn_pressed():
	NetworkConnection.create_client()
	hide()


func _on_host_2_btn_pressed():
	NetworkConnection.create_server("region_002")
	hide()
