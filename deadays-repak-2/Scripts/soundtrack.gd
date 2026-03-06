extends AudioStreamPlayer

func _ready():
	autoplay = true 
	stream.loop = true 
	play()
