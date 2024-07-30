extends StaticBody3D

var life = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	set_multiplayer_authority(name.to_int())	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(life <= 0):
		queue_free()


func _on_body_detector_body_entered(body):
	if body.get_groups().has("Tools"):
		life = life - 2
		rpc("_set_remote", life)


@rpc("any_peer")
func _set_remote(remoteLife):
	life = remoteLife
