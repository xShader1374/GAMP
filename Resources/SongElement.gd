extends Control

@onready var songElementButton : Button = $SongElementButton
@onready var main : Control = $"../../../../../../../../../../.."
@onready var song_thumbnail_texture_rect: TextureRect = $Panel/HBoxContainer/MarginContainer/TextureRect2/songThumbnailTextureRect
@onready var song_thumbnail_panel_container: PanelContainer = $Panel/HBoxContainer/MarginContainer/TextureRect2/songThumbnailTextureRect/songThumbnailPanelContainer
@export var songFileName : String = "" # example: "author - song title.mp3"
@export var songFileNamePath : String = "" # example: "C:\user\desktop\musicfolder\author - song title.mp3"
@export var songFileNameDir : String = " " # example: "C:\user\desktop\musicfolder\"

var playing : bool = false

var hover : bool = false

var songMetadataExtractor : MusicMetadata = MusicMetadata.new()

signal songElementSelected(songElementNode : Node, songFileName : String, songFileNamePath : String, songFileNameDir : String, songAuthor : String, songTitle : String, songTotalDuration : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("songElementSelected", Callable(main, "songElementSelectedFunction"))
	pivot_offset = size / 2
	$Panel.pivot_offset = $Panel.size / 2
	songElementButton.pivot_offset = songElementButton.size / 2
	
	var songFileData : PackedByteArray = FileAccess.get_file_as_bytes(songFileNamePath)
	
	songMetadataExtractor.set_from_data(songFileData)
	
	song_thumbnail_texture_rect.texture = songMetadataExtractor.cover
	%SongTitle.text = songMetadataExtractor.title.strip_edges(true, true)
	%Author.text = songMetadataExtractor.artist.strip_edges(true, true)
	
	songFileData.clear()
	songMetadataExtractor = null

func songElementPressed():
	songElementButton.grab_focus()
	emit_signal("songElementSelected", self, songFileName, songFileNamePath, songFileNameDir, %Author.text, %SongTitle.text, %TotalDuration.text)
	

func _on_song_element_button_mouse_entered() -> void:
	hover = true
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property($Panel, "scale", Vector2(0.98, 0.98), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(0.98, 0.98), .15)
	
	$Panel/Panel.show()


func _on_song_element_button_mouse_exited() -> void:
	hover = false
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property($Panel, "scale", Vector2(1.0, 1.0), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(1.0, 1.0), .15)
	
	$Panel/Panel.hide()


func _on_song_element_button_pressed() -> void:
	pass


func _on_song_element_button_button_up() -> void:
	songElementPressed()
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(1.0, 1.0), .15)


func _on_song_element_button_button_down() -> void:
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), .15)
	tween.chain().tween_property(songElementButton, "scale", Vector2(0.95, 0.95), .15)

func setTitle(title : String):
	%SongTitle.text = title

func setAuthor(Author : String):
	%Author.text = Author

func setProgressBarValue(value : float):
	%songProgressBar.value = value

func setCurrentDuration(currentDuration : String):
	%CurrentDuration.text = currentDuration

func setTotalDuration(totalDuration : String):
	%TotalDuration.text = totalDuration

func setSongFileName(songName : String):
	songFileName = songName

func setSongFileNamePath(songPath : String):
	songFileNamePath = songPath

func setSongFileNameDir(songDir : String):
	songFileNameDir = songDir

func songElementSelectedThumbnailOpacityOnAnimation():
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0.5), 0.35)

func songElementSelectedThumbnailOpacityOffAnimation():
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0), 0.35)

func playPlayingAnimation():
	#$Panel/Label.show()
	%linesAnimationPlayer.play("playing")
	songElementSelectedThumbnailOpacityOnAnimation()
	$Panel/HBoxContainer/MarginContainer/TextureRect2/HBoxContainer.show()

func stopPlayingAnimation():
	#$Panel/Label.hide()
	%linesAnimationPlayer.play("RESET")
	songElementSelectedThumbnailOpacityOffAnimation()
	$Panel/HBoxContainer/MarginContainer/TextureRect2/HBoxContainer.hide()


func _on_song_element_button_focus_entered() -> void:
	$Panel/Panel.show()

func _on_song_element_button_focus_exited() -> void:
	$Panel/Panel.hide()
