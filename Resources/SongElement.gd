extends MarginContainer

@onready var songElementButton : Button = $SongElementButton
@onready var main : Control = $"../../../../../../../../../../.."
@onready var song_thumbnail_texture_rect: TextureRect = $Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/songThumbnailTextureRect
@onready var song_thumbnail_panel_container: PanelContainer = $Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/songThumbnailTextureRect/songThumbnailPanelContainer
@export var songFileName : String = "" # example: "author - song title.mp3"
@export var songFileNamePath : String = "" # example: "C:\user\desktop\musicfolder\author - song title.mp3"
@export var songFileNameDir : String = " " # example: "C:\user\desktop\musicfolder\"

var currentSongTimestamp: float = 0.0

var playing : bool = false

var hover : bool = false

var songMetadataExtractor: MusicMetadata = MusicMetadata.new()

signal songElementSelected(songElementNode : Node, songFileName : String, songFileNamePath : String, songFileNameDir : String, songAuthor : String, songTitle : String, songTotalDuration : String, songCurrentTimestamp: float)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("songElementSelected", Callable(main, "songElementSelectedFunction"))
	pivot_offset = size / 2.0
	$Panel.pivot_offset = $Panel.size / 2.0
	songElementButton.pivot_offset = songElementButton.size / 2.0
	
	var songFileData: PackedByteArray = FileAccess.get_file_as_bytes(songFileNamePath)
	
	songMetadataExtractor.set_from_data(songFileData)
	
	var original_image: Image = songMetadataExtractor.cover.get_image()
	original_image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	original_image.compress(Image.COMPRESS_BPTC, Image.COMPRESS_SOURCE_GENERIC)
	var compressed_image: Image = original_image
	
	var texture: Texture2D = ImageTexture.create_from_image(compressed_image)
	song_thumbnail_texture_rect.texture = texture
	
	%SongTitle.text = songMetadataExtractor.title.strip_edges(true, true)
	%Author.text = songMetadataExtractor.artist.strip_edges(true, true)
	
	songFileData.clear()
	songMetadataExtractor = null

func songElementPressed() -> void:
	songElementButton.grab_focus()
	emit_signal("songElementSelected", self, songFileName, songFileNamePath, songFileNameDir, %Author.text, %SongTitle.text, %TotalDuration.text, currentSongTimestamp)
	
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.15, .2).from_current()
	

func _on_song_element_button_mouse_entered() -> void:
	hover = true
	
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(0.98, 0.98), .15).from_current()
	tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.175, .15).from_current()
	#tween.chain().tween_property(songElementButton, "scale", Vector2(0.98, 0.98), .15)
	
	$Panel/Panel.show()


func _on_song_element_button_mouse_exited() -> void:
	hover = false
	
	var tween: Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), .15).from_current()
	
	if playing:
		tween.parallel().tween_property(self, "modulate", Color.WHITE * 1.15, .2).from_current()
	else:
		tween.parallel().tween_property(self, "modulate", Color.WHITE, .15).from_current()
	
	#tween.chain().tween_property(songElementButton, "scale", Vector2(1.0, 1.0), .15)
	
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

func setTitle(title : String) -> void:
	%SongTitle.text = title

func setAuthor(Author : String) -> void:
	%Author.text = Author

func setProgressBarValue(value : float) -> void:
	%songProgressBar.value = value

func setCurrentDuration(currentDuration : String) -> void:
	%CurrentDuration.text = currentDuration

func setTotalDuration(totalDuration : String) -> void:
	%TotalDuration.text = totalDuration

func setSongFileName(songName : String) -> void:
	songFileName = songName

func setSongFileNamePath(songPath : String) -> void:
	songFileNamePath = songPath

func setSongFileNameDir(songDir : String) -> void:
	songFileNameDir = songDir

func songElementSelectedThumbnailOpacityOnAnimation() -> void:
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0.5), 0.35)

func songElementSelectedThumbnailOpacityOffAnimation() -> void:
	var tween : Tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(song_thumbnail_panel_container, "self_modulate", Color(0, 0, 0, 0), 0.35)

func playPlayingAnimation() -> void:
	#$Panel/Label.show()
	%linesAnimationPlayer.play("playing")
	songElementSelectedThumbnailOpacityOnAnimation()
	$Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/HBoxContainer.show()

func stopPlayingAnimation() -> void:
	#$Panel/Label.hide()
	%linesAnimationPlayer.play("RESET")
	songElementSelectedThumbnailOpacityOffAnimation()
	$Panel/MarginContainer/HBoxContainer/MarginContainer/PanelContainer/Panel/HBoxContainer.hide()


func _on_song_element_button_focus_entered() -> void:
	$Panel/Panel.show()

func _on_song_element_button_focus_exited() -> void:
	$Panel/Panel.hide()


func _on_resized() -> void:
	pivot_offset = size / 2.0
