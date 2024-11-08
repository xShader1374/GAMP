@tool
@icon("./icons/NetworkTextureRect.svg")
class_name NetworkTextureRect
extends TextureRect

signal loading
signal completed
signal errored(error_code: int)

enum ImageLoadingStatus {
	IDLE,
	LOADING,
	COMPLETED,
	ERRORED
}

## Current status of the image
@export var status : ImageLoadingStatus = ImageLoadingStatus.IDLE:
	set(value):
		if status == value:
			return
		status = value
		if !is_node_ready():
			await ready
		if status in [ImageLoadingStatus.IDLE, ImageLoadingStatus.ERRORED, ImageLoadingStatus.COMPLETED]:
			_hide_or_free_loading_placeholder()
		if status in [ImageLoadingStatus.IDLE, ImageLoadingStatus.LOADING, ImageLoadingStatus.COMPLETED]:
			_free_error_placeholder()
		if status == ImageLoadingStatus.LOADING:
			_create_or_show_loading_placeholder()
		if status == ImageLoadingStatus.ERRORED:
			_create_error_placeholder_if_null()
		notify_property_list_changed()

## URL to request an image from
@export_multiline var url: String = "https://loremflickr.com/320/240":
	set(value):
		url = value
		if !Engine.is_editor_hint() and url and is_node_ready() and auto_request:
			request()

## Whether or not to use threads. See HTTPRequest.use_threads for more info
@export var use_threads: bool = true

## If true, requests image as soon as this node is ready in the running game
## the scene tree and also whenever the url parameter is changed
##
## Has no effect on in-editor behavior. Only when running the game
@export var auto_request: bool = true
## If texture was already loaded in the editor, still load it again when the game/app is running
##
## This is useful for testing UI layout and loading speed.
@export var clear_on_play: bool = false

@export_group("Loading Placeholder")

## Scene to display when loading
@export var loading_placeholder_scene : PackedScene

## Whether to free or hide the loading placeholder when not in use
@export var loading_placeholder_keep_around := false

@export_group("Error Placeholder")
## Scene to display when errored
@export var error_placeholder_scene : PackedScene

var _http_request : HTTPRequest
var _loading_placeholder : Control
var _error_placeholder : Control
var _image: Image = Image.new()

#region Download Optimization Region
# Chunk size constants
const MIN_CHUNK_SIZE: int = 65536  # 64KB (Godot default)
const MAX_CHUNK_SIZE: int = 1048576  # 1MB
const MEDIUM_FILE_SIZE: int = 10485760  # 10MB
const LARGE_FILE_SIZE: int = 104857600  # 100MB

var known_file_size: int = 0

func calculate_optimal_chunk_size(file_size: int) -> int:
	# Per file molto piccoli, usa il chunk size minimo
	if file_size < MIN_CHUNK_SIZE:
		return MIN_CHUNK_SIZE
	
	var chunk_size: int
	
	# Scala il chunk size in base alla dimensione del file
	if file_size < MEDIUM_FILE_SIZE:
		# Per file piccoli (<10MB), scala linearmente da 64KB a 256KB
		chunk_size = lerp(MIN_CHUNK_SIZE, MIN_CHUNK_SIZE * 4, float(file_size) / MEDIUM_FILE_SIZE)
	elif file_size < LARGE_FILE_SIZE:
		# Per file medi (10MB-100MB), scala da 256KB a 512KB
		chunk_size = lerp(MIN_CHUNK_SIZE * 4, MIN_CHUNK_SIZE * 8, float(file_size - MEDIUM_FILE_SIZE) / (LARGE_FILE_SIZE - MEDIUM_FILE_SIZE))
	else:
		# Per file grandi (>100MB), usa il chunk size massimo
		chunk_size = MAX_CHUNK_SIZE
	
	# Arrotonda al multiplo di 4KB più vicino per ottimizzazione
	chunk_size = floor(chunk_size / 4096.0) * 4096
	
	# Assicurati che il chunk size sia sempre tra MIN e MAX
	return clampi(chunk_size, MIN_CHUNK_SIZE, MAX_CHUNK_SIZE)

# Esempio di utilizzo con HTTPRequest
func configure_http_request(http_request: HTTPRequest, file_size: int) -> void:
	http_request.download_chunk_size = calculate_optimal_chunk_size(file_size)

# Utility per ottenere la dimensione del file da un header Content-Length
func get_file_size_from_headers(response_headers: PackedStringArray) -> int:
	for header: String in response_headers:
		if header.begins_with("Content-Length: "):
			return header.substr(16).to_int()
	return -1
#endregion

func request() -> void:
	status = ImageLoadingStatus.LOADING
	_http_request.cancel_request()
	var error: Error = _http_request.request(url)
	if !error == OK:
		_set_image_loading_errored(error)
		return
	loading.emit()

func cancel() -> void:
	if status == ImageLoadingStatus.LOADING:
		_set_image_loading_errored(45)
		_http_request.cancel_request()

func clear() -> void:
	texture = null
	status = ImageLoadingStatus.IDLE

func _ready() -> void:
	if !is_instance_valid(_http_request):
		_http_request = HTTPRequest.new()
		add_child(_http_request)
	_http_request.download_chunk_size = MEDIUM_FILE_SIZE
	_http_request.accept_gzip = true
	_http_request.use_threads = use_threads
	_http_request.request_completed.connect(_set_network_texture)
	if !Engine.is_editor_hint():
		if clear_on_play:
			texture = null
		if !texture:
			request()

func _create_or_show_loading_placeholder() -> void:
	if !_loading_placeholder:
		if loading_placeholder_scene:
			_loading_placeholder = loading_placeholder_scene.instantiate()
		else:
			_loading_placeholder = DefaultLoadingPlaceholderSpinner.new()
		_loading_placeholder.name = "LoadingPlaceholder"
		add_child(_loading_placeholder, true, INTERNAL_MODE_BACK)
		_loading_placeholder.hide()
	_loading_placeholder.show()

func _create_error_placeholder_if_null() -> void:
	if !_error_placeholder:
		if error_placeholder_scene:
			_error_placeholder = error_placeholder_scene.instantiate()
		else:
			_error_placeholder = DefaultErrorPlaceholderIcon.new()
		_error_placeholder.name = "ErrorPlaceholder"
		add_child(_error_placeholder, true, INTERNAL_MODE_BACK)
	_error_placeholder.show()

func _set_image_loading_errored(error: int) -> void:
	status = ImageLoadingStatus.ERRORED
	errored.emit()
	push_warning("NetworkTextureRect: " + error_string(error))

func _set_network_texture(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_set_image_loading_errored(result)
		return
	var image_type: String = ""
	for header: String in headers:
		if header.begins_with(&"Content-Type: "):
			image_type = header.replace(&"Content-Type: ", "")
			break
	var error: Error = _attempt_load_buffer(_image, body, image_type)
	if error != OK:
		_set_image_loading_errored(error)
		return
	_loading_placeholder.hide()
	texture = ImageTexture.create_from_image(_image)
	completed.emit()
	status = ImageLoadingStatus.COMPLETED
	_hide_or_free_loading_placeholder()

func _hide_or_free_loading_placeholder() -> void:
	if is_instance_valid(_loading_placeholder):
		if loading_placeholder_keep_around:
			_loading_placeholder.hide()
		else:
			_loading_placeholder.queue_free()

func _free_error_placeholder() -> void:
	if is_instance_valid(_error_placeholder):
		remove_child(_error_placeholder)
		_error_placeholder.queue_free()

func _attempt_load_buffer(image: Image, buffer: PackedByteArray, content_type: String) -> int:
	var error: int = 15
	match content_type:
		&"image/jpeg":
			error = image.load_jpg_from_buffer(buffer)
		&"image/png":
			error = image.load_png_from_buffer(buffer)
		&"image/svg+xml":
			error = image.load_svg_from_buffer(buffer)
		&"image/webp":
			error = image.load_webp_from_buffer(buffer)
		# tga not supported on web
		&"image/ktx":
			error = image.load_ktx_from_buffer(buffer)

	# return _attempt_load_any_format_from_buffer(image, buffer)
	return error

# Not on or even toggleable. Uncomment 2 lines up to enable
func _attempt_load_any_format_from_buffer(image: Image, buffer: PackedByteArray) -> int:
	var error: int= 0
	push_warning("NetworkTextureRect: Attempting to brute force load image. There will likely be errors.")
	# Engine.print_error_messages = false
	error = image.load_jpg_from_buffer(buffer)
	if error == 0: return 0
	error = image.load_png_from_buffer(buffer)
	if error == 0: return 0
	error = image.load_svg_from_buffer(buffer)
	if error == 0: return 0
	error = image.load_webp_from_buffer(buffer)
	if error == 0: return 0
	error = image.load_tga_from_buffer(buffer)
	if error == 0: return 0
	error = image.load_ktx_from_buffer(buffer)
	if error == 0: return 0
	# Engine.print_error_messages = true
	return error

class DefaultLoadingPlaceholderSpinner extends Control:

	var _loading_spinner_angle_offset: int = 0

	func _ready() -> void:
		set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	func _process(delta: float) -> void:
		_loading_spinner_angle_offset += delta * 360.0
		queue_redraw()

	func _draw() -> void:
		draw_arc(
			size / 2,
			min(size.x, size.y) / 4,
			deg_to_rad(-90 + _loading_spinner_angle_offset),
			deg_to_rad(0 + _loading_spinner_angle_offset),
			32,
			Color(0.6, 0.49, 1), 4.0, true
		)

class DefaultErrorPlaceholderIcon extends TextureRect:
	const ICON := preload("./icons/StatusError.svg")
	const COLOR := Color(0.996, 0.373, 0.373)
	const STROKE := 4

	func _ready() -> void:
		set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		stretch_mode = STRETCH_KEEP_CENTERED
		texture = ICON
	
	func _draw() -> void:
		var stroke_inset := Vector2(STROKE / 2, STROKE / 2)
		draw_rect(Rect2(Vector2.ZERO + stroke_inset, size - stroke_inset), COLOR, false, 4)
