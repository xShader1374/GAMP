extends Node

## Lyrics will never be synced perfectly cus Godot's idle process isn't precise enough to get 2 digits milliseconds, it can be precise enough to take just one

@export var syncSeconds : PackedStringArray = []
@export var lyricsLineLabels : Array[Label] = []

@onready var MusicPlayer : AudioStreamPlayer = get_node("/root/MainControl/MusicPlayer")

var lineCounter : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	
	process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	process_thread_messages = FLAG_PROCESS_THREAD_MESSAGES
	

func parseSongDuration(duration_str : String) -> float:
	# Rimuove gli parentesi quadre e divide la stringa in componenti
	var duration_parts := duration_str.substr(1, duration_str.length() - 2).split(":")
	
	var minutes_str : String = duration_parts[0]
	var seconds_str : String = duration_parts[1].substr(0, duration_parts[1].length() - 1) # Rimuove il punto
	var milliseconds_str : String = duration_parts[1].substr(duration_parts[1].find(".") + 1)
	
	var minutes : int = int(minutes_str.to_float())
	var seconds : int = int(seconds_str.to_float())
	var milliseconds : int = int(milliseconds_str.to_float())
	
	var total_duration_seconds : float = minutes * 60 + seconds + milliseconds / 1000.0
	return total_duration_seconds

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if lineCounter != syncSeconds.size() - 1:
		if str(MusicPlayer.get_playback_position()).left(3) == str(parseSongDuration(syncSeconds[lineCounter])).left(3):
			print(lyricsLineLabels[lineCounter].text)
			
			if lineCounter != 0:
				lyricsLineLabels[lineCounter-1].set_deferred("modulate", Color(0.75, 0.75, 0.75))
				lyricsLineLabels[lineCounter-1].set_deferred("scale", Vector2(1.0, 1.0))
			
			lyricsLineLabels[lineCounter].set_deferred("modulate", Color(1.5, 1.5, 1.5))
			lyricsLineLabels[lineCounter].set_deferred("pivot_offset", lyricsLineLabels[lineCounter].size / 2)
			lyricsLineLabels[lineCounter].set_deferred("focus_mode", Control.FOCUS_ALL)
			lyricsLineLabels[lineCounter].call_deferred("grab_focus")
			lyricsLineLabels[lineCounter].set_deferred("scale", Vector2(1.25, 1.25))
			
			lineCounter += 1
	else:
		# This is needed because the last sync seconds got from musicxmatch are always empty
		# and this usually means the song has ended
		lyricsLineLabels[lineCounter].set_deferred("modulate", Color(0.75, 0.75, 0.75))
		lyricsLineLabels[lineCounter].set_deferred("scale", Vector2(1.0, 1.0))
		set_process(false)
