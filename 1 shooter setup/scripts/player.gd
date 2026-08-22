extends CharacterBody3D

var direction : Vector2 
var speed := 10
var mouse_acceleration := Vector2(0.001,0.001)
enum Gun {BLASTER,DUAL}
var jump_strength := 8.0
var gravity := 10.0
var health := 100

@onready var default_gun_pos : Vector3 = $Camera3D/Guns.get_child(current_gun).position
var current_gun : Gun = Gun.BLASTER:
	set(value):
		current_gun = value
		var tween = create_tween()
		tween.tween_property($Camera3D/Guns, "position", $Camera3D/Guns.position + Vector3(0,-1.1,0), 0.3)
		tween.tween_property($Camera3D/Guns.get_child(current_gun), "visible", true, 0)
		tween.tween_property($Camera3D/Guns.get_child(posmod(current_gun -1, Gun.size())), "visible", false, 0)
		tween.tween_property($Camera3D/Guns, "position", $Camera3D/Guns.position, 0.3)
		
		
@export var impact_animation : PackedScene
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for gun in $Camera3D/Guns.get_children():
		gun.hide()
	$Camera3D/Guns.get_child(current_gun).show()


func _input(event):
	if event is InputEventMouseMotion:
		$Camera3D.rotation.y -= event.relative.x * mouse_acceleration.x
		$Camera3D.rotation.x -= event.relative.y* mouse_acceleration.y
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -PI/3, PI/3)
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			var active_gun = $Camera3D/Guns.get_child(current_gun)
			if active_gun.name == "Blaster":
				$BlasterShoot.play()
			elif active_gun.name == "DualShooter":
				$RepeaterShooter.play()

			active_gun.nozzle_burst()
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.tween_property(active_gun, "position", default_gun_pos + Vector3(0, 0, 0.1), 0.05)
			tween.tween_property(active_gun, "position", default_gun_pos, 0.1)
			var collider = $Camera3D/RayCast3D.get_collider()
			if collider:
				var impact = impact_animation.instantiate()
				get_tree().root.add_child(impact)
				var pos = $Camera3D/RayCast3D.get_collision_point()
				impact.position = pos + Vector3(randf_range(-0.5,0.5),randf_range(-0.5,0.5),randf_range(-0.5,0.5))
				impact.look_at($Camera3D.global_transform.origin)
				if 'hit' in collider:
					collider.hit()



func get_input():
	direction = Input.get_vector('left','right','forward','backward').rotated(-$Camera3D.global_rotation.y)
	velocity.x = direction.x * speed
	velocity.z = direction.y * speed
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

		
	if Input.is_action_just_pressed('toggle_weapon'):
		current_gun = posmod(current_gun + 1, Gun.size()) as Gun
		$WeaponChange.play()
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			$Jump.play()
			velocity.y = jump_strength
	
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
func _physics_process(delta: float)-> void:
	get_input()
	apply_gravity(delta)
	move_and_slide()
	$Camera3D/RayCast3D.get_collider()

func hit():
	health -= 5
	get_tree().get_first_node_in_group('ui').change_health(health)
	if health <= 0:
		get_tree().quit()

func _unhandled_input(event):
	if event.is_action_pressed('reset'):
		set_process(false)
		set_physics_process(false)
		get_tree().reload_current_scene()
		return
