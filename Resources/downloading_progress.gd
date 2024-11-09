extends PanelContainer

func _ready() -> void:
	set_process(false)

func start_checking() -> void:
	set_process(true)

func stop_checking() -> void:
	set_process(false)

func _process(delta: float) -> void:
	httpmanager_progress_update(%spotifyDownloadHTTPRequest.get_body_size(), %spotifyDownloadHTTPRequest.get_downloaded_bytes())

func animateProgressBytes(newValue: float) -> void:
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(%downloadingProgressProgressBar, "value", newValue, 0.1).from_current()

func format_bytes(bytes: int) -> String:
	const KB: int = 1024
	const MB: int = KB * 1024
	const GB: int = MB * 1024
	const TB: int = GB * 1024
	
	# Utilizziamo var per memorizzare sia il valore che l'unità
	var value: float
	var unit: String
	
	if bytes >= TB:
		value = float(bytes) / TB
		unit = "tb"
	elif bytes >= GB:
		value = float(bytes) / GB
		unit = "gb"
	elif bytes >= MB:
		value = float(bytes) / MB
		unit = "mb"
	elif bytes >= KB:
		value = float(bytes) / KB
		unit = "kb"
	else:
		return str(bytes) + " b"
	
	# Arrotondiamo a 2 decimali per valori più grandi,
	# a 1 decimale per KB per mantenere la logica originale
	var decimal_places: float = 2 if unit != "kb" else 1
	return str(snapped(value, pow(0.1, decimal_places))) + " " + unit

func httpmanager_progress_update(total_bytes: int, current_bytes: int) -> void:
	%downloadingProgressLabel.set_deferred("text", format_bytes(total_bytes) + " / " + format_bytes(current_bytes))
	animateProgressBytes(current_bytes / (0.00001 + total_bytes) * 100)
