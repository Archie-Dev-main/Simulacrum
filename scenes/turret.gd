extends Spatial


var player = null
onready var muzzle_flash = $Turn_Rod/Head/Barrel/Muzzle_Flash
onready var muzzle_flash_timer = $Turn_Rod/Head/Barrel/muzzle_flash_timer
onready var rocket = preload("res://scenes/rocket.tscn")
var health = 500
var dead = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$Area.connect("body_entered", self, "body_spotted")
# warning-ignore:return_value_discarded
	$Area.connect("body_exited", self, "body_blocked")
# warning-ignore:return_value_discarded
	$attack_timer.connect("timeout", self, "attack")
	muzzle_flash_timer.connect("timeout", self, "hide_flash")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if health <= 0:
		GlobalVariables.num_turrets_dead += 1
		queue_free()
	if player:
		$Turn_Rod.look_at(player.translation, Vector3.UP)
		#$Turn_Rod.rotation.x = clamp(rotation.x, 0, 0)
		$Turn_Rod.rotate_object_local(Vector3.UP, PI)


func damage(damage):
	health -= damage


func body_spotted(body):
	if body.name == "Player":
		player = body


func body_blocked(body):
	if body.name == "Player":
		player = null


func attack():
	if player:
		muzzle_flash.show()
		muzzle_flash_timer.start(0.1)
		var r = rocket.instance()
		add_child(r)
		r.global_transform = $Turn_Rod/Head/Barrel/muzzle.global_transform
		$attack_timer.start(1)


func hide_flash():
	muzzle_flash.hide()
