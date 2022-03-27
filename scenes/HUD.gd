extends Control

onready var player = get_parent().get_parent()
onready var health_lbl = $HBoxContainer/VBoxContainer/Health


# Called when the node enters the scene tree for the first time.
func _ready():
	health_lbl.text = "Health: " + str(player.health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	health_lbl.text = "Health: " + str(player.health)
