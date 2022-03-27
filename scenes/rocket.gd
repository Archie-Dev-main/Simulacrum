extends Area


var speed = 15


# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	connect("body_entered", self, "explode")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if translation >= Vector3.ONE * 1000:
		queue_free()
	translation += global_transform.basis.y * speed * delta


func explode(body):
	if body.name == "Player":
		body.damage(50)
		queue_free()
	
	if body.name != "turret":
		queue_free()
