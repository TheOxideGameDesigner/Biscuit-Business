extends Panel

const CONFIG_PATH = "user://settings.cfg"
var config = ConfigFile.new()

var master_bus = AudioServer.get_bus_index("Master")
var sfx_bus = AudioServer.get_bus_index("sfx")
var music_bus = AudioServer.get_bus_index("music")

func _ready():
	if FileAccess.file_exists(CONFIG_PATH):
		config.load(CONFIG_PATH)
	
	$Master.value = config.get_value("audio", "volume", 50)
	_on_master_value_changed($Master.value)
	
	$Music.value = config.get_value("audio", "music", 50)
	_on_music_value_changed($Music.value)
	
	$Sfx.value = config.get_value("audio", "sfx", 50)
	_on_sfx_value_changed($Sfx.value)
	
	config.save(CONFIG_PATH)

func _on_master_value_changed(value):
	config.set_value("audio", "volume", value)
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value / 100.0))


func _on_sfx_value_changed(value):
	config.set_value("audio", "sfx", value)
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value / 100.0))


func _on_music_value_changed(value):
	config.set_value("audio", "music", value)
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value / 100.0))
	
func _on_close_options_pressed():
	get_parent().visible = false
	config.save(CONFIG_PATH)
