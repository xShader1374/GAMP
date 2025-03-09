extends Node

## Lyrics will never be synced perfectly cus Godot's idle process isn't precise enough to get 2 digits milliseconds, it can be precise enough to take just one

@export var syncSeconds: PackedStringArray = []
@export var lyricsLineLabels: Array[Label] = []

@export var click_delay: float = 0.15

@onready var MusicPlayer: AudioStreamPlayer = get_node("/root/MainControl/MusicPlayer")
@onready var lyricsScrollContainer: ScrollContainer = get_node("/root/MainControl/MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/PanelContainer/SmoothScrollContainer")


var lineCounter: int = 0

var click_timer: Timer
var clicked_label: Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	
	process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	process_thread_messages = FLAG_PROCESS_THREAD_MESSAGES
	
	click_timer = Timer.new()
	click_timer.one_shot = true
	click_timer.timeout.connect(_on_click_timer_timeout)
	add_child(click_timer)

func parseSongDuration(duration_str: String) -> float:
	if duration_str != "":
		# Rimuove gli parentesi quadre e divide la stringa in componenti
		var duration_parts: PackedStringArray = duration_str.substr(1, duration_str.length() - 2).split(":")
		
		var minutes_str: String = duration_parts[0]
		var seconds_str: String = duration_parts[1].substr(0, duration_parts[1].length() - 1) # Rimuove il punto
		var milliseconds_str: String = duration_parts[1].substr(duration_parts[1].find(".") + 1)
		
		var minutes: int = int(minutes_str.to_float())
		var seconds: int = int(seconds_str.to_float())
		var milliseconds: int = int(milliseconds_str.to_float())
		
		var total_duration_seconds: float = minutes * 60.0 + seconds + milliseconds / 1000.0
		return total_duration_seconds
	else:
		return 0.0

func animationHoverIn(text: Label) -> void:
	text.pivot_offset = text.size / 2.0
	
	var animationHoverInTween: Tween = create_tween()
	
	animationHoverInTween.set_ease(Tween.EASE_IN_OUT)
	animationHoverInTween.set_trans(Tween.TRANS_SINE)
	
	#animationHoverInTween.tween_property(text, "modulate", Color(1.25, 1.25, 1.25), 0.15).from_current()
	animationHoverInTween.tween_property(text, "scale", Vector2(1.125, 1.125), 0.15).from_current()

func animationHoverOut(text: Label) -> void:
	text.pivot_offset = text.size / 2.0
	
	var animationHoverOutTween: Tween = create_tween()
	
	animationHoverOutTween.set_ease(Tween.EASE_IN_OUT)
	animationHoverOutTween.set_trans(Tween.TRANS_SINE)
	
	#animationHoverOutTween.tween_property(text, "modulate", Color.WHITE, 0.15).from_current()
	animationHoverOutTween.tween_property(text, "scale", Vector2.ONE, 0.15).from_current()

func animationFocus(text: Label) -> void:
	var animationFocusTween: Tween = create_tween()
	
	animationFocusTween.set_ease(Tween.EASE_IN_OUT)
	animationFocusTween.set_trans(Tween.TRANS_SINE)
	
	animationFocusTween.tween_property(text, "modulate", Color(1.5, 1.5, 1.5), 0.15).from_current()
	animationFocusTween.parallel().tween_property(text, "scale", Vector2(1.25, 1.25), 0.15).from_current()

func animationUnfocus(text: Label) -> void:
	var animationUnfocusTween: Tween = create_tween()
	
	animationUnfocusTween.set_ease(Tween.EASE_IN_OUT)
	animationUnfocusTween.set_trans(Tween.TRANS_SINE)
	
	animationUnfocusTween.tween_property(text, "modulate", Color(0.75, 0.75, 0.75), 0.15).from_current()
	animationUnfocusTween.parallel().tween_property(text, "scale", Vector2(1.0, 1.0), 0.15).from_current()

func lyrics_line_mouse_entered(lyrics_line_label: Label) -> void:
	if lineCounter != lyrics_line_label.get_index() + 1:
		animationHoverIn(lyrics_line_label)

func lyrics_line_mouse_exited(lyrics_line_label: Label) -> void:
	if lineCounter != lyrics_line_label.get_index() + 1:
		animationHoverOut(lyrics_line_label)

func lyrics_line_GUI_input_event(event: InputEvent, lyrics_line_label: Label) -> void:
	if (event is InputEventMouseButton and event.is_action_pressed("mouse_left") and !lyricsScrollContainer.is_scrolling) or (event is InputEventScreenTouch and !lyricsScrollContainer.is_scrolling):
		clicked_label = lyrics_line_label
		click_timer.start(click_delay)

func _on_click_timer_timeout() -> void:
	if !lyricsScrollContainer.is_scrolling and syncSeconds.size():
		set_process(true)
		lineCounter = clicked_label.get_index()
		
		# De-evidenzia tutte le righe precedenti
		for i: int in range(lineCounter - 1, -1, -1):
			lyricsLineLabels[i].set_deferred("modulate", Color(0.75, 0.75, 0.75))
			lyricsLineLabels[i].set_deferred("scale", Vector2(1.0, 1.0))
		
		# De-evidenzia tutte le righe successive
		for i: int in range(lineCounter + 1, lyricsLineLabels.size()):
			lyricsLineLabels[i].set_deferred("modulate", Color(1.0, 1.0, 1.0))
			lyricsLineLabels[i].set_deferred("scale", Vector2(1.0, 1.0))
		
		
		MusicPlayer.call_deferred("seek", parseSongDuration(syncSeconds[lineCounter]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if syncSeconds.is_empty():
		return
	
	var current_time: float = MusicPlayer.get_playback_position()
	var closest_index: int = -1
	
	# Trova l'indice del timestamp più vicino non superiore al tempo corrente
	for i: int in range(syncSeconds.size()):
		var line_time: float = parseSongDuration(syncSeconds[i])
		if line_time <= current_time:
			closest_index = i
		else:
			break
	
	# Calculates new line counter
	var new_line_counter: int = closest_index + 1 if closest_index != -1 else 0
	
	# Gestione fine canzone
	if new_line_counter >= syncSeconds.size():
		if lineCounter < lyricsLineLabels.size():
			animationUnfocus(lyricsLineLabels[lineCounter - 1])
		set_process(false)
		return
	
	# Aggiorna la visualizzazione solo se cambia la riga
	if new_line_counter != lineCounter:
		# Rimuovi evidenziazione dalla riga precedente
		if lineCounter > 0 and lineCounter - 1 < lyricsLineLabels.size():
			animationUnfocus(lyricsLineLabels[lineCounter - 1])
		
		# Evidenzia la nuova riga
		if new_line_counter > 0 and closest_index < lyricsLineLabels.size():
			lyricsLineLabels[closest_index].set_deferred("pivot_offset", lyricsLineLabels[lineCounter].size / 2.0)
			lyricsLineLabels[closest_index].set_deferred("focus_mode", Control.FOCUS_ALL)
			lyricsLineLabels[closest_index].call_deferred("grab_focus")
			
			animationFocus(lyricsLineLabels[closest_index])
		
		lineCounter = new_line_counter
	
	# Debug
	# var current_debug_time: float = parseSongDuration(syncSeconds[closest_index]) if closest_index != -1 else 0.0
	# printt(current_time, current_debug_time)
