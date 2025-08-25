extends Camera2D

const MIN_ZOOM : float = 1.0
const MAX_ZOOM : float = 6.0
const ZOOM_STEPS : int = 15
var zoom_step : float = 0
var sharp_zoom : Vector2

const SCREEN : Vector2 = Vector2(325, 280) * 3
const BOUND : Rect2 = Rect2(-SCREEN / (MIN_ZOOM * 2.0), SCREEN / MIN_ZOOM)

func clamp_cam():
	var screen : Vector2 = SCREEN / zoom.x
	var bound : Rect2 = BOUND
	bound.position += screen / 2.0
	bound.end -= screen
	position = position.clamp(bound.position, bound.end)

func update_zoom(delta):
	var prev_zoom : float = zoom.x
	sharp_zoom = Vector2.ONE * exp(lerp(log(MIN_ZOOM), log(MAX_ZOOM), zoom_step / (ZOOM_STEPS - 1)))
	if abs(zoom.x - sharp_zoom.x) > 0.01:
		zoom = lerp(zoom, sharp_zoom, min(delta * 10.0, 1.0))
	elif zoom_step == 0:
		if abs(zoom.x - sharp_zoom.x) < 0.002:
			zoom = sharp_zoom
		else:
			zoom = lerp(zoom, sharp_zoom, min(delta * 20.0, 1.0))
	var zoom_ratio : float = zoom.x / prev_zoom
	var cursor_pos : Vector2 = get_viewport().get_mouse_position() - SCREEN / 2
	var zoomed_cursor_pos : Vector2 = cursor_pos * zoom_ratio
	position += (zoomed_cursor_pos - cursor_pos) / zoom

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var m : Vector2 = -event.relative / zoom.x
		position += m
	
	elif event is InputEventMouseButton and event.is_pressed():
		if event.is_action("zoom_in"):
			zoom_step = min(zoom_step + 1, ZOOM_STEPS - 1)
		elif event.is_action("zoom_out"):
			zoom_step = max(zoom_step - 1, 0)

func _ready():
	sharp_zoom = Vector2.ONE * MIN_ZOOM
	zoom = sharp_zoom
	position = Vector2.ZERO
	

func _process(delta):
	update_zoom(delta)
	clamp_cam()
	for n in get_tree().get_nodes_in_group("constant_size"):
		n.scale = Vector2.ONE * max(3.0 / zoom.x, 1.5)
	for n in get_tree().get_nodes_in_group("constant_size_label"):
		n.scale = Vector2.ONE * max(1.0 / zoom.x, 0.5) * 0.8
		n.position = -n.size * n.scale.x / 2
		const Z1 = 1.5
		const Z2 = 2.0
		n.modulate.a = clamp(lerp(0, 1, (zoom.x - Z1) / (Z2 - Z1)), 0, 1) * 0.7
