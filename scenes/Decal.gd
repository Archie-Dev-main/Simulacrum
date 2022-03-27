extends Spatial


export(float) var lifetime : float = 0.1
var timer = Timer.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(timer)
	timer.connect("timeout", self, "timeout")
	timer.start(lifetime)


func timeout():
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
