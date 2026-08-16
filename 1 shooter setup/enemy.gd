extends CharacterBody3D
var player : CharacterBody3D
var index: int

func _ready():
	for sprite in $Skin/NozzleBurst.get_children():
		sprite.scale = Vector3.ZERO

func _process(delta):
	if player:
		var target_direction = (player.position - position).normalized()
		var current_dir = -global_transform.basis.z
		var new_dir = current_dir.slerp(target_direction, 5 * delta).normalized()
		look_at(global_transform.origin + new_dir)
func _on_player_detection_area_body_entered(body):
	player = body
	$ShootTimer.start()


func _on_player_detection_area_body_exited(_body):
	player = null
	$ShootTimer.stop()

func _on_shoot_timer_timeout():
	index = posmod(index + 1, $Skin/NozzleBurst.get_child_count())
	var tween = create_tween()
	tween.tween_property($Skin/NozzleBurst.get_child(index), 'scale', Vector3.ONE, 0.1).from(Vector3.ZERO)
	tween.tween_property($Skin/NozzleBurst.get_child(index), 'scale', Vector3.ZERO, 0.2).from(Vector3.ONE)
	if player:
		player.hit()

func hit():
	flash()
	
func flash():
	var tween = create_tween()
	tween.set_parallel()
	for mesh in $Skin.get_children():
		if mesh is MeshInstance3D:
			tween.tween_property(mesh.material_overlay, 'shader_parameter/Progress', 1.0, 0.1)
		tween.set_parallel(false)
		tween.tween_interval(0.2)
		tween.set_parallel()
			
