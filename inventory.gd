extends Control



func _input(_event):
	if Input.is_action_pressed("inventory"):
		visible = !visible


func _on_btn_close_pressed():
	visible = false
