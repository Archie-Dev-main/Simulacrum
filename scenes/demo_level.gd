extends Spatial


var key = false
var open_door = false
var num_turrets_dead = 0
#onready var endscreen = preload("res://scenes/EndScreen.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	$key.connect("body_entered", self, "key_collected")
	$Door/Area.connect("body_entered", self, "use_door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if open_door:
		$Door.translation.y += 30 * delta
	
	if Input.is_action_just_pressed("win_game"):
		$turret.health = 0
		$turret2.health = 0
	
	if $turret.health <= 0:
		num_turrets_dead += 1
		$turret.queue_free()
	if $turret2.health <= 0:
		num_turrets_dead += 1
		$turret2.queue_free()
	
	if num_turrets_dead > 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().change_scene("res://scenes/EndScreen.tscn")


func key_collected(body):
	if body.name == "Player":
		key = true
		$key.queue_free()


func use_door(body):
	if body.name == "Player" and key:
		open_door = true
