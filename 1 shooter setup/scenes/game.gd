extends Node3D

@export var next_scene_path : String = ""

func _ready():
	LevelManager.register_level_enemies()
	LevelManager.all_enemies_defeated.connect(_on_level_clear)
	
func _on_level_clear():
	if not is_inside_tree():
		return
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)


func _on_die_area_body_entered(body):
	print('yes')
	call_deferred("_do_reload()")

func _do_reload():
	get_tree().reload_current_scene()
