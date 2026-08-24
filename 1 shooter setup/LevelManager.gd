extends Node

signal all_enemies_defeated

func register_level_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not enemy.tree_exiting.is_connected(_on_enemy_removed):
			enemy.tree_exiting.connect(_on_enemy_removed)
	
func register_enemy(enemy: Node) -> void:
	if not enemy.tree_exiting.is_connected(_on_enemy_removed):
		enemy.tree_exiting.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	call_deferred("_check_clear")

func _check_clear() -> void:
	if get_tree().get_nodes_in_group("enemy").is_empty():
		all_enemies_defeated.emit()
