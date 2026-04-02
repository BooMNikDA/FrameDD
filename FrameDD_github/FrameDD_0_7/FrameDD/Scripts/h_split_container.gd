extends HSplitContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame

	$Panel.size = get_viewport().get_visible_rect().size
	$Panel.position = Vector2(0, 0)

	# Настраиваем HSplitContainer
	var hsplit = $Panel/VBoxContainer/HSplitContainer
	hsplit.size = Vector2($Panel.size.x, $Panel.size.y - 100)
	hsplit.position = Vector2(0, 100)
