extends Node

func _ready():
	await get_tree().process_frame
	
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		print("Modifier: Патчим UI напрямую")
		
		# Сохраняем оригинальный ready_2 если нужно
		var original_ready_2 = null
		if ui.has_method("ready_2"):
			original_ready_2 = ui.ready_2
		
		# Переопределяем _ready прямо в экземпляре
		ui._ready = func():
			print("Новый _ready (прямой патч)")
			print("Ждем 3 секунды...")
			await get_tree().create_timer(3.0).timeout
			
			if original_ready_2:
				print("Вызываем оригинальную ready_2")
				original_ready_2.call()
			else:
				print("ready_2 не найдена!")
		
		# Если _ready уже был вызван, вызываем новый
		if ui.is_inside_tree():
			ui._ready()
