extends CanvasLayer

@onready var button: Button = $ToggleButton

func _ready() -> void:
	DarkModeManager.dark_mode_changed.connect(_on_dark_mode_changed)
	_on_dark_mode_changed(DarkModeManager.dark_mode_enabled)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_dark_mode"):
		print("F pressed, toggling dark mode")
		DarkModeManager.toggle_dark_mode()


func _on_dark_mode_changed(enabled: bool) -> void:
	button.text = "Dark Mode: ON (F)" if enabled else "Dark Mode: OFF (F)"
	visible = not DarkModeManager.locked
