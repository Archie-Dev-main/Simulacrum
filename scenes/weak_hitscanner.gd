extends KinematicBody


var player = null

var health : int = 100

var speed : float = 1

var velocity : Vector3 = Vector3.ZERO

onready var muzzle_flash = $Weak_Hitscanner/Spine/RIght_Arm/Right_Shoulder/Right_Upper_Arm/Right_Elbow/Gun/Muzzle_Flash
onready var muzzle_flash_timer = $Weak_Hitscanner/Spine/RIght_Arm/Right_Shoulder/Right_Upper_Arm/Right_Elbow/Gun/muzzle_flash_timer


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
		queue_free()
	
	velocity = Vector3.ZERO
	
	if player:
		$LOS.cast_to = player.translation
		velocity = translation.direction_to(player.translation)
		look_at(player.translation, Vector3.UP)
		rotation.x = clamp(rotation.x, 0, 0)
		rotate_object_local(Vector3.UP, PI)
	
	velocity = move_and_slide(Vector3(velocity.x * speed, 0, velocity.z * speed), Vector3.UP)


func body_spotted(body):
	if body.name == "Player":
		player = body


func body_blocked(body):
	if body.name == "Player":
		player = null


func attack():
	if player and $LOS.is_colliding() and $LOS.get_collider().name == "Player":
		muzzle_flash.show()
		muzzle_flash_timer.start(0.1)
		player.damage(10)
		$attack_timer.start()


func hide_flash():
	muzzle_flash.hide()


func damage(damage):
	health -= damage
