extends CharacterBody3D

var direction : Vector2 
var speed := 10
var mouse_acceleration := Vector2(0.001,0.001)
@export var impact_animation : PackedScene
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _input(event):
	if event is InputEventMouseMotion:
		$Camera3D.rotation.y -= event.relative.x * mouse_acceleration.x
		$Camera3D.rotation.x -= event.relative.y* mouse_acceleration.y
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/3, PI/3)
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var collider = $Camera3D/RayCast3D.get_collider()
			if collider:
				var impact = impact_animation.instantiate()
				get_tree().root.add_child(impact)
				var pos = $Camera3D/RayCast3D.get_collision_point()
				impact.position = pos + Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
				impact.look_at($Camera3D.global_transform.origin)
				
func get_input():
	direction = Input.get_vector('left','right','forward','backward').rotated(-$Camera3D.global_rotation.y)
	velocity.x = direction.x * speed
	velocity.z = direction.y * speed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta: float)-> void:
	get_input()
	move_and_slide()
	$Camera3D/RayCast3D.get_collider()
