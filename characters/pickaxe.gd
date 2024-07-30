extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_3d_body_entered(body):
	if body.get_groups().has("Coal"):
		var mcplayer = get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_parent_node_3d()
		for child in mcplayer.get_children():
			var inv := child as Inventory
			if not inv:
				continue
			inv._put_in_iventory("COAL")
			
