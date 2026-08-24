extends Node


signal dark_mode_changed(enabled : bool)
var dark_mode_enabled := false
var locked := false

func _ready():
	get_tree().node_added.connect(_on_node_added)
	for n in get_tree().get_nodes_in_group("world_light"):
		print("world_light group contains: ", n.name, " - type: ", n.get_class())
	

func toggle_dark_mode():
	if locked:
		return
	set_dark_mode(not dark_mode_enabled)

func set_dark_mode(enabled : bool):
	dark_mode_enabled = enabled
	_apply_to_all()
	dark_mode_changed.emit(enabled)

func lock_and_reset():
	locked = true
	set_dark_mode(false)

func _apply_to_all() -> void:
	for env in get_tree().get_nodes_in_group("world_environment"):
		_apply_env(env)
	for light in get_tree().get_nodes_in_group("world_light"):
		_apply_dir_light(light)
	for plight in get_tree().get_nodes_in_group("player_light"):
		plight.visible = dark_mode_enabled

func _apply_env(env: WorldEnvironment) -> void:
	if env.environment:
		env.environment.ambient_light_energy = 0.05 if dark_mode_enabled else 1.0
		env.environment.background_energy_multiplier = 0.05 if dark_mode_enabled else 1.0

func _apply_dir_light(light: DirectionalLight3D) -> void:
	light.light_energy = 0.05 if dark_mode_enabled else 1.0

func _on_node_added(node: Node) -> void:
	if node.is_in_group("world_environment") or node.is_in_group("world_light") or node.is_in_group("player_light"):
		call_deferred("_apply_to_all")
