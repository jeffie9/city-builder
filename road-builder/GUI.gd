extends MarginContainer

signal straight_selected
signal curve_selected

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StraightButton_pressed():
	emit_signal("straight_selected")



func _on_CurveButton_pressed():
	emit_signal("curve_selected")
