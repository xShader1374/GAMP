extends Control

#region Onready Vars
@onready var songTitleLabel : Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/HBoxContainer/VBoxContainer/SongTitle
@onready var songAuthorLabel : Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/HBoxContainer/VBoxContainer/Author
@onready var currentDurationLabel : Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrentDuration
@onready var progressBar : HSlider = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/ProgressSlider
@onready var totalDurationLabel : Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer/Panel/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/TotalDuration
@onready var volumeSlider : VSlider = %VolumeSlider
@onready var smooth_scroll_container: ScrollContainer = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/SmoothScrollContainer
@onready var songElementsContainer : VBoxContainer = $MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/SmoothScrollContainer/HBoxContainer/VBoxContainer

@onready var song_lyrics_label: Label = $"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/PanelContainer/songLyricsLabel"
@onready var song_lyrics_http_request: HTTPRequest = $"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/PanelContainer/songLyricsLabel/songLyricsHTTPRequest"

@onready var manual_search_popup_control: Control = $"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/manuallySearchLyricsButton/manualSearchPopupControl"

@onready var addEffectButtonPopup: PopupMenu = %AddEffectButton.get_popup()

#endregion

var SongElementScene: PackedScene = preload("res://Resources/songElement.tscn")
var globalUserDataPath : String = OS.get_user_data_dir()

#region EQ Variables Region
@onready var EQBands : Array[VSlider] = [
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer2/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer3/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer4/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer5/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer6/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer7/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer8/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer9/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer10/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer/VBoxContainer11/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer2/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer3/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer4/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer5/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer6/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer7/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer8/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer9/VBoxContainer/VSlider,
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Equalizer/HBoxContainer/HBoxContainer/Panel/VBoxContainer/HBoxContainer2/VBoxContainer10/VBoxContainer/VSlider
]

#region Presets
var defaultPreset: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var bassBoostedPreset: PackedFloat32Array = [13.586, 16.237, 18.888, 13.586, 14.47, -0.552, 13.586, 14.47, -4.971, 2.982, 13.586, 9.074, 10.824, 3.827, -0.547, 8.2, -8.418, -21.538, -32.034, -39.905, -47.777]
var bassBoostedPreset2: PackedFloat32Array = [13.586, 16.237, 18.888, 13.586, 14.47, -0.552, 13.586, 14.47, -4.971, 2.982, 13.586, 9.074, 10.824, 3.827, 12.137, 18.229, 19.511, 16.626, 15.664, 15.985, 10.855]
var enhanchedVocalsPreset: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.952, 10.824, 7.325, 9.949, 13.586, 6.45, -1.421, -2.296, -0.552]
var enhanchedVocalsPreset2: PackedFloat32Array = [6.046, 8.611, 9.573, 9.252, 8.931, 8.611, 7.328, 2.198, -2.29, -8.702, -2.611, 6.366, 3.802, 10.855, 18.229, 24.0, 24.0, 24.0, 24.0, 24.0, 24.0]
var enhanchedVocalsPreset3: PackedFloat32Array  = [22.244, 20.195, 16.976, 17.561, 17.072, 16.206, 15.34, 17.854, 18.732, 14.927, 8.412, 6.366, 3.802, 10.855, 18.229, 24.0, 24.0, 24.0, 24.0, 24.0, 24.0]
var powerfulPreset: PackedFloat32Array = [13.586, 16.237, 18.888, 13.586, 14.47, -0.552, 13.586, 14.47, 7.214, 3.5, 0.0, 0.0, 2.952, 10.824, 7.325, 9.949, 13.586, 6.45, -1.421, -2.296, -0.552]
var powerful2Preset: PackedFloat32Array = [13.586, 16.237, 18.888, 13.586, 14.47, -0.552, 13.586, 14.47, 7.214, 3.5, 0.0, -5.875, 4.198, 9.666, 16.572, 16.285, 13.586, 12.543, 12.256, 11.392, 7.363]
var powerful3Preset: PackedFloat32Array = [13.586, 16.237, 18.098, 20.112, 18.961, 18.385, 17.522, -1.759, 8.025, 10.615, 10.903, -5.875, 4.198, 9.666, 16.572, 16.285, 13.586, 12.543, 12.256, 11.392, 7.363]
var powerful4Preset: PackedFloat32Array = [13.586, 16.237, 18.098, 20.112, 18.961, 18.385, 17.522, -1.759, 8.025, 10.615, 10.903, 7.651, 12.543, 11.392, 11.392, 16.285, 14.408, 19.45, 20.221, 21.675, 21.752]
var powerful5Preset: PackedFloat32Array = [24, 24, 24, 24, 20.473, 11.496, 6.687, 15.023, 20.794, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24]
var customPreset1: PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

var EQpresets: Array[PackedFloat32Array] = [
	defaultPreset,
	bassBoostedPreset,
	bassBoostedPreset2,
	enhanchedVocalsPreset,
	enhanchedVocalsPreset2,
	enhanchedVocalsPreset3,
	powerfulPreset,
	powerful2Preset,
	powerful3Preset,
	powerful4Preset,
	powerful5Preset,
	customPreset1
]
#endregion

@onready var EQ21Effect : AudioEffectEQ21 = AudioServer.get_bus_effect(1, 0)
var EQbandDragStarted : bool = false

#endregion

#region Effects Vars Region
const EFFECT_PANEL: PackedScene = preload("res://Resources/effect_panel.tscn")
#endregion

var currentSongElement : Node

var location : String = ""

var playing : bool = false
var loop : bool = false

var progressBarDragStarted : bool = false

#region Volume Variables
var volumeSliderDragStarted : bool = false

var volumeButtonHover : bool = false
var volumeSliderHover : bool = false
var volumeSliderPanelHover : bool = false

var hover_states: Dictionary = {
	"button": false,
	"panel": false,
	"slider": false
}
#endregion

#region Window Management
var dragging: bool = false
var mouse_pos: Vector2 = Vector2.ZERO
var drag_from: Vector2 = Vector2.ZERO
var border_threshold: int = 20  # Tollerance zone of the screen's border
var fullscreen: bool = false
var near_border_last_frame: bool = false  # Nuovo flag per tracciare lo stato del bordo
#endregion

var authorNameToRequestImage: String = ""
var songTitleToRequestImage: String = ""

var downloadingTrackID: String = ""
var downloadingSongAuthorName: String = ""
var downloadingSongName: String = ""

var savify_output: Array = []

var lyricsFullscreen: bool = false

var initialImporterThread: Thread
var importerSongsThread: Thread

#region Preferences Region
@export var default_songs_folder: String = OS.get_system_dir(OS.SYSTEM_DIR_MUSIC).path_join("GAMP-Downloaded")
@export var auto_import_at_start: bool = true
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Android":
		OS.request_permissions()
		$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer2.hide()
		$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer.tabs_position = 1
	
	check_songs_dir_exists()
	
	AudioServer.set_enable_tagging_used_audio_streams(true)
	
	%borderTimer.one_shot = true
	%borderTimer.wait_time = 0.25  # un quarto di secondo di tolleranza
	
	for i: int in EQBands.size(): # EQ Part, sets the index to each band slider (0, 1, 2 etc.)
		EQBands[i].setEQNumber(i)
	
	setAudioBusVolume(-16)
	volumeSlider.value = -16
	
	if location == null or location == "":
		print("Location is void!")
	else:
		print("Location isn't void!")
	
	addEffectButtonPopup.index_pressed.connect(add_effect_button_pressed)
	
	$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/PanelContainer/songLyricsLabel".mouse_filter = MOUSE_FILTER_IGNORE
	%loadingLyricsCenterContainer.mouse_filter = MOUSE_FILTER_IGNORE
	$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/Panel/VBoxContainer/PanelContainer/songLyricsLabel/loadingLyricsCenterContainer/MarginContainer".mouse_filter = MOUSE_FILTER_IGNORE
	%loadingLyricsLabel.mouse_filter = MOUSE_FILTER_IGNORE
	%loadingLyricsBytesLabel.mouse_filter = MOUSE_FILTER_IGNORE
	%loadingLyricsProgressBar.mouse_filter = MOUSE_FILTER_IGNORE
	
	if auto_import_at_start:
		initialImporterThread = Thread.new()
		initialImporterThread.start(dirSelectedImportSong.bind(default_songs_folder))

func check_songs_dir_exists() -> void:
	if !DirAccess.dir_exists_absolute(default_songs_folder):
		DirAccess.make_dir_absolute(default_songs_folder)

func initially_import_songs(dir: String) -> void:
	var diraccess: DirAccess = DirAccess.open(dir)
	var filesInDir: PackedStringArray = diraccess.get_files()
	
	if filesInDir.size() != 0:
		call_deferred("hideEmptyListSongLabel")
		
		importerSongsThread = Thread.new()
		importerSongsThread.start(importSongsThreaded.bind(filesInDir, dir))
	
	call_deferred("finished_initial_song_importing")

func finished_initial_song_importing() -> void:
	initialImporterThread.wait_to_finish()
	print("\n--- FINISHED STARTING SONGS IMPORTING ---")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if %MusicPlayer.playing:
		progressBar.value = %MusicPlayer.get_playback_position()
		currentDurationLabel.text = formatSongDuration(%MusicPlayer.get_playback_position())
		currentSongElement.get_node("Panel/MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/songProgressBar").value = progressBar.value
		currentSongElement.get_node("Panel/MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrentDuration").text = formatSongDuration($MusicPlayer.get_playback_position())
		currentSongElement.currentSongTimestamp = %MusicPlayer.get_playback_position()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("play_pause_key"):
		pauseAndResume()
	elif event.is_action_pressed("stop_key"):
		stop()
	elif event.is_action_pressed("prev_key"):
		prev()
	elif event.is_action_pressed("next_key"):
		next()

#region Window Managament Section
func _on_minimize_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _on_maximize_button_pressed() -> void:
	if !fullscreen:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
		$MarginContainer["theme_override_constants/margin_left"] = 0
		$MarginContainer["theme_override_constants/margin_top"] = 0
		$MarginContainer["theme_override_constants/margin_right"] = 0
		$MarginContainer["theme_override_constants/margin_bottom"] = 0
		
		%loadingLyricsLabel.label_settings.font_size = 22
		%songLyricsLabel.label_settings.font_size = 32
		
		fullscreen = true
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		
		$MarginContainer["theme_override_constants/margin_left"] = 4
		$MarginContainer["theme_override_constants/margin_top"] = 4
		$MarginContainer["theme_override_constants/margin_right"] = 4
		$MarginContainer["theme_override_constants/margin_bottom"] = 4
		
		%loadingLyricsLabel.label_settings.font_size = 16
		%songLyricsLabel.label_settings.font_size = 26
		
		fullscreen = false

func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_border_timer_timeout() -> void:
	if dragging and near_border_last_frame:  # Controlla se siamo ancora vicino al bordo
		_on_maximize_button_pressed()  # Passa a fullscreen
		dragging = false  # Importante: resetta il dragging dopo il fullscreen

func check_window_borders() -> void:
	var screen_size: Vector2i = DisplayServer.screen_get_size()
	var window_pos: Vector2i = DisplayServer.window_get_position()  # Posizione attuale della finestra
	var window_size: Vector2i = DisplayServer.window_get_size()  # Dimensione attuale della finestra
	mouse_pos = DisplayServer.mouse_get_position()  # Posizione globale del mouse
	
	# Calcola la posizione relativa del mouse rispetto allo schermo
	var relative_mouse_x: int = mouse_pos.x - window_pos.x
	var relative_mouse_y: int = mouse_pos.y - window_pos.y
	
	# Controlla se il mouse è vicino ai bordi dello schermo (non della finestra)
	var near_border: bool = (
		mouse_pos.x <= border_threshold or  # Bordo sinistro dello schermo
		mouse_pos.x >= screen_size.x - border_threshold or  # Bordo destro dello schermo
		mouse_pos.y <= border_threshold or  # Bordo superiore dello schermo
		mouse_pos.y >= screen_size.y - border_threshold  # Bordo inferiore dello schermo
	)
	
	# Aggiorna lo stato solo se è cambiato
	if near_border != near_border_last_frame:
		if near_border and dragging:
			print("Fullscreen")
			%borderTimer.start()
		else:
			print("NOT Fullscreen")
			%borderTimer.stop()
		
		near_border_last_frame = near_border

func _on_panel_gui_input(event: InputEvent) -> void:
	if !fullscreen:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed and !dragging:
					$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer2.mouse_default_cursor_shape = CURSOR_DRAG
					dragging = true
					drag_from = get_global_mouse_position()
				else:
					$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer2.mouse_default_cursor_shape = CURSOR_ARROW
					dragging = false
					%borderTimer.stop()
		
		if event is InputEventMouseMotion:
			if dragging:
				var window: Window = get_window()
				var real_mouse_pos: Vector2 = get_global_mouse_position() - drag_from
				@warning_ignore("narrowing_conversion")
				window.position += Vector2i(real_mouse_pos.x, real_mouse_pos.y)
				check_window_borders()  # Checks borders during dragging
	else:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					_on_maximize_button_pressed()
					dragging = true
#endregion


#region Importing Section
func _on_import_dir_button_pressed() -> void:
	check_songs_dir_exists()
	var filters: PackedStringArray = ["*.mp3", "*.wav", "*.ogg"]
	DisplayServer.file_dialog_show("Import Directory", default_songs_folder, "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, filters, onNativeFileDialogDirSelected)

func onNativeFileDialogDirSelected(status: bool, selected_paths: PackedStringArray, selected_filter_index: int) -> void:
	if status:
		printt(status, selected_paths, selected_filter_index)
		
		dirSelectedImportSong(selected_paths[0])
	else:
		print("Failed to import folder")

func hideEmptyListSongLabel() -> void:
	%emptySongListLabel.hide()

func dirSelectedImportSong(dir: String) -> void:
	var diraccess: DirAccess = DirAccess.open(dir)
	var filesInDir: PackedStringArray = diraccess.get_files()
	
	if filesInDir.size() != 0:
		call_deferred("hideEmptyListSongLabel")
		
		importerSongsThread = Thread.new()
		importerSongsThread.start(importSongsThreaded.bind(filesInDir, dir))

func importSongsThreaded(filesInDir: PackedStringArray, dir: String) -> void:
	for i: int in filesInDir.size():
			var fileName: String = filesInDir[i]
			var fileExtension: String = fileName.get_extension()
			var baseFileName: String = fileName.get_basename() # File name, without the extension, ex. "g.mp3" becomes "g"
			var splittedFileName: PackedStringArray = baseFileName.split("")
			# now we gotta take everything before the "-" so that it becomes the Author and whatever it's over "-" it's the Song Title
			var delimiterFound : bool = false
			
			var songAuthor: String = ""
			var songTitle: String = ""
			
			for j: int in splittedFileName.size():
				var fileNameChars: String = splittedFileName[j]
				if !delimiterFound:
					if fileNameChars != "-":
						songAuthor += fileNameChars
						delimiterFound = false
					else:
						delimiterFound = true
				else:
					songTitle += fileNameChars
			
			songAuthor = songAuthor.strip_edges(true, true)
			songTitle = songTitle.strip_edges(true, true)
			
			#print("Done reading the song: '", songAuthor, " - ", songTitle, "', importing it now...")
			
			if fileExtension == "wav" or fileExtension == "mp3" or fileExtension == "ogg":
				var SongElement: MarginContainer = SongElementScene.instantiate()
				songElementsContainer.call_deferred("add_child", SongElement, true) #.add_child(SongElement)
				
				#SongElement.setTitle(songTitle)
				#SongElement.setAuthor(songAuthor)
				SongElement.setSongFileName(fileName)
				SongElement.setSongFileNamePath(dir.path_join(fileName))
				SongElement.setSongFileNameDir(dir)
				SongElement.setCurrentDuration("0:00")
				
				var fileCompletePath: String = dir.path_join(fileName)
				var songTotalDuration: String
				
				match fileExtension:
					"wav":
						var tempStream: AudioStreamWAV = AudioStreamWAV.new()
						
						tempStream.set_format(AudioStreamWAV.FORMAT_16_BITS)
						tempStream.mix_rate = 48000
						tempStream.stereo = true
						tempStream.data = load_song_data(fileCompletePath)
						
						songTotalDuration = formatSongDuration(tempStream.get_length())
					
					"mp3":
						var tempStream: AudioStreamMP3 = AudioStreamMP3.new()
						
						tempStream.data = load_song_data(fileCompletePath)
						songTotalDuration = formatSongDuration(tempStream.get_length())
					
					"ogg":
						var tempStream: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(fileCompletePath)
						songTotalDuration = formatSongDuration(tempStream.get_length())
						
				
				SongElement.call_deferred("setTotalDuration", songTotalDuration)
				
			else:
				print("File: '", fileName, "' is not an .mp3/.wav/.ogg, skipping...")
			
			print(filesInDir[i])
	
	call_deferred("importer_Thread_Finished_Importing")

func importer_Thread_Finished_Importing() -> void:
	importerSongsThread.wait_to_finish()

func importSingleSong(filePath: String) -> void:
			var fileName: String = filePath.get_basename() + "." + filePath.get_extension()
			var fileExtension: String = filePath.get_extension()
			var baseFileName: String = filePath.get_basename() # File name, without the extention, ex. "g.mp3" becomes "g"
			
			#region Maybe Delete
			#var songAuthor : String = ""
			#var songTitle : String = ""
			
			#for j: int in splittedFileName.size():
			#	var fileNameChars : String = splittedFileName[j]
			#	if !delimiterFound:
			#		if fileNameChars != "-":
			#			songAuthor += fileNameChars
			#			delimiterFound = false
			#		else:
			#			delimiterFound = true
			#	else:
			#		songTitle += fileNameChars
			
			#songAuthor = songAuthor.strip_edges(true, true)
			#songTitle = songTitle.strip_edges(true, true)
			#endregion
			
			print("Done.")
			
			if fileExtension == "wav" or fileExtension == "mp3" or fileExtension == "ogg":
				var SongElement: MarginContainer = SongElementScene.instantiate()
				songElementsContainer.call_deferred("add_child", SongElement) #.add_child(SongElement)
				
				#SongElement.setTitle(songTitle)
				#SongElement.setAuthor(songAuthor)
				SongElement.setSongFileName(fileName)
				
				SongElement.setSongFileNamePath(filePath)
				SongElement.setSongFileNameDir(fileName.get_base_dir())
				
				SongElement.setCurrentDuration("0:00")
				
				var fileCompletePath: String = fileName
				var songTotalDuration: String
				
				match fileExtension:
					"wav":
						var tempStream: AudioStreamWAV = AudioStreamWAV.new()
						
						tempStream.set_format(AudioStreamWAV.FORMAT_16_BITS)
						tempStream.mix_rate = 48000
						tempStream.stereo = true
						tempStream.data = load_song_data(fileCompletePath)
						
						songTotalDuration = formatSongDuration(tempStream.get_length())
					
					"mp3":
						var tempStream: AudioStreamMP3 = AudioStreamMP3.new()
						
						tempStream.data = load_song_data(fileCompletePath)
						songTotalDuration = formatSongDuration(tempStream.get_length())
					
					"ogg":
						var tempStream : AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(fileCompletePath)
						songTotalDuration = formatSongDuration(tempStream.get_length())
						
				SongElement.call_deferred("setTotalDuration", songTotalDuration)
			else:
				print("File: '", fileName, "' is not an .mp3/.wav/.ogg, skipping...")

func load_song_data(path: String) -> PackedByteArray:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var buffer: PackedByteArray = file.get_buffer(file.get_length())
	file.close()
	return buffer

#endregion

func _on_play_button_pressed() -> void:
	pauseAndResume()

func prev() -> void: # goes to the previous song (if there is one)
	if %MusicPlayer.stream != null:
		var parentChildCount: int = songElementsContainer.get_child_count()
		var currentSongElementPosition: int = currentSongElement.get_index()
		var prevChildIndex: int = currentSongElementPosition - 1
		
		if prevChildIndex > 2:
			var nextChild: MarginContainer = songElementsContainer.get_child(prevChildIndex)
			nextChild.songElementPressed()
		else:
			var nextChild: MarginContainer = songElementsContainer.get_child(parentChildCount - 1)
			nextChild.songElementPressed()

func next() -> void: # skips to the next song (if there is one, if there is not, it goes to the first one)
	if %MusicPlayer.stream != null:
		var parentChildCount: int = songElementsContainer.get_child_count()
		var currentSongElementPosition: int = currentSongElement.get_index()
		var nextChildIndex: int = currentSongElementPosition + 1
		
		if nextChildIndex < parentChildCount:
			var nextChild: MarginContainer = songElementsContainer.get_child(nextChildIndex)
			nextChild.songElementPressed()
		else:
			var nextChild: MarginContainer = songElementsContainer.get_child(2)
			nextChild.songElementPressed()

func pauseAndResume() -> void: # pauses if it's playing and resumes if it's not (but has started) a song 
	if %MusicPlayer.stream_paused == true:
		
		%playButton.add_theme_font_size_override("font_size", 22)
		%playButton.text = "ıı"
		
		%MusicPlayer.stream_paused = false
	else:
		
		%playButton.add_theme_font_size_override("font_size", 16)
		%playButton.text = "▶"
		
		%MusicPlayer.stream_paused = true


func formatSongDuration(duration: float) -> String:
	var minutes : int = int(duration / 60.0)
	var seconds : int = int(duration - minutes * 60.0)
	var finalDuration : String = str(minutes).pad_zeros(1) + ":" + str(seconds).pad_zeros(2)
	return finalDuration

func reverseFormatSongDuration(duration: String) -> float:
	var parts: PackedStringArray = duration.split(":")
	if parts.size() != 2:
		push_error("Formato durata non valido. Deve essere in formato 'mm:ss'")
		return 0.0
	
	var minutes: int = int(parts[0])
	var seconds: int = int(parts[1])
	
	return float(minutes * 60.0 + seconds)

func setSongTitleAuthorDuration(author : String, title : String, _duration : String) -> void:
	songAuthorLabel.text = author
	songTitleLabel.text = title
	totalDurationLabel.text = formatSongDuration(%MusicPlayer.stream.get_length())
	
	# from here it changes the progressbar's values to match total duration etc., 
	# i could use some math but why should i make the cpu calculate things when 
	# i can just change existing values?
	progressBar.max_value = %MusicPlayer.stream.get_length()
	currentSongElement.get_node("Panel/MarginContainer/HBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/songProgressBar").max_value = progressBar.max_value

func play(stream: AudioStream = null, fromPosition: float = 0.0) -> void: # plays the song
	if stream != null:
		%MusicPlayer.stream = stream
	%MusicPlayer.play(fromPosition)

## Resets the song to 0:00 and pauses it
func stop() -> void:
	%MusicPlayer.play(0.0)
	
	%playButton.add_theme_font_size_override("font_size", 16)
	%playButton.text = "▶"
	
	%MusicPlayer.stream_paused = true

func loopOn() -> void:
	if !%MusicPlayer.stream == AudioStreamWAV:
		%MusicPlayer.stream.loop = true

func loopOff() -> void:
	if !%MusicPlayer.stream == AudioStreamWAV:
		%MusicPlayer.stream.loop = false

func loopButton() -> void: # loops the song
	if !loop:
		loop = true
	else:
		loop = false

func loadSongFile(filepath : String) -> AudioStream: # loads the song file (supports only .wav, .mp3 and .ogg)
	var extension: String = filepath.get_extension()
	
	var data: PackedByteArray = load_song_data(filepath)
	
	match extension:
		"mp3":
			print("file is an mp3!")
			
			var newStream : AudioStreamMP3 = AudioStreamMP3.new()
			newStream.set_data(data)
			print()
			
			data.clear()
			return newStream
		"wav":
			print("file is a wav!")
			var newStream : AudioStreamWAV = AudioStreamWAV.new()
			newStream.set_format(AudioStreamWAV.FORMAT_16_BITS)
			newStream.mix_rate = 48000
			newStream.stereo = true
			newStream.set_data(data)
			
			data.clear()
			return newStream
		"ogg":
			print("file is an ogg!")
			var newStream : AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(filepath)
			
			data.clear()
			return newStream
		_:
			return null

func songElementSelectedFunction(songElementNode : Node, songFileName : String, songFileNamePath : String, songFileNameDir : String, songAuthor : String, songTitle : String, songTotalDuration : String, songCurrentTimestamp: float, songMetadata: Dictionary[String, Variant]) -> void:
	if currentSongElement != null and currentSongElement.playing :
		currentSongElement.stopPlayingAnimation()
		currentSongElement.playing = false
	songElementNode.playPlayingAnimation()
	
	print("\nsongElementNode is: " + songElementNode.name)
	print("\nsongFileName is: " + songFileName)
	print("\nsongFileNamePath is: " + songFileNamePath)
	print("\nsongFileNameDir is: " + songFileNameDir)
	
	%playButton.add_theme_font_size_override("font_size", 20)
	%playButton.text = "ıı"
	
	currentSongElement = songElementNode
	
	currentSongElement.playing = true
	
	play(loadSongFile(songFileNamePath), songCurrentTimestamp)
	setSongTitleAuthorDuration(songAuthor, songTitle, songTotalDuration)
	
	# Lyrics Retriever Section: 
	
	requestSongLyrics(songTitle, songAuthor, songTotalDuration)
	#requestSongImage(songAuthor, songTitle)
	requestAuthorImage(songAuthor, songTitle)
	changeSongCoverImage(currentSongElement.song_thumbnail_texture_rect.texture)
	changeMetadataSongCoverImage(currentSongElement.song_thumbnail_texture_rect.texture)
	changeBGImage(currentSongElement.song_thumbnail_texture_rect.texture)
	
	%metaTitleLineEdit.text = songMetadata["title"]
	%metaArtistLineEdit.text = songMetadata["artist"]
	%metaAlbumLineEdit.text = songMetadata["album"]
	%metaAlbumArtistLineEdit.text = songMetadata["album_artist"]
	%metaLyricistLineEdit.text = songMetadata["lyricist"]
	%metaGenreLineEdit.text = songMetadata["genre"]
	%metaYearLineEdit.text = str(songMetadata["year"])
	%metaDateLineEdit.text = songMetadata["date"]
	%metaReleaseLabelLineEdit.text = songMetadata["release_label"]
	%metaCopyrightLineEdit.text = songMetadata["copyright"]
	%metaIsrcLineEdit.text = songMetadata["isrc"]
	%metaCommentsLineEdit.text = songMetadata["comments"]
	%metaUserLineEdit.text = songMetadata["user"]
	%metaMoodLineEdit.text = songMetadata["mood"]
	
	
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer.current_tab = 2

func changeBGImage(newBGImage: ImageTexture) -> void:
	var changeBGImageTween: Tween = create_tween()
	
	changeBGImageTween.set_ease(Tween.EASE_IN_OUT)
	changeBGImageTween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	changeBGImageTween.set_trans(Tween.TRANS_QUAD)
	
	changeBGImageTween.tween_property(%BGTextureRect, "self_modulate", Color.BLACK, 0.2)
	changeBGImageTween.chain().tween_property(%BGTextureRect, "texture", newBGImage, 0)
	changeBGImageTween.chain().tween_property(%BGTextureRect, "self_modulate", Color.WHITE, 0.2)
	

func changeAuthorImage() -> void:
	var changeAuthorImageTween: Tween = create_tween()
	
	changeAuthorImageTween.set_ease(Tween.EASE_IN_OUT)
	changeAuthorImageTween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	changeAuthorImageTween.set_trans(Tween.TRANS_QUAD)
	
	changeAuthorImageTween.tween_property(%authorCoverTextureRect, "self_modulate", Color.BLACK, 0.2)
	changeAuthorImageTween.chain().tween_callback(%authorCoverTextureRect.request) #(%songCoverTextureRect, "texture", newSongCoverImage, 0)
	changeAuthorImageTween.chain().tween_property(%authorCoverTextureRect, "self_modulate", Color.WHITE, 0.2).set_delay(0.2)

func changeSongCoverImage(newSongCoverImage: ImageTexture) -> void:
	var changeSongCoverImageTween: Tween = create_tween()
	
	changeSongCoverImageTween.set_ease(Tween.EASE_IN_OUT)
	changeSongCoverImageTween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	changeSongCoverImageTween.set_trans(Tween.TRANS_QUAD)
	
	changeSongCoverImageTween.tween_property(%songCoverTextureRect, "self_modulate", Color.BLACK, 0.2)
	changeSongCoverImageTween.chain().tween_callback(%songCoverTextureRect.set_texture.bind(newSongCoverImage)) #(%songCoverTextureRect, "texture", newSongCoverImage, 0)
	changeSongCoverImageTween.chain().tween_property(%songCoverTextureRect, "self_modulate", Color.WHITE, 0.2)

func changeMetadataSongCoverImage(newSongCoverImage: ImageTexture) -> void:
	var changeMetadataSongCoverImageTween: Tween = create_tween()
	
	changeMetadataSongCoverImageTween.set_ease(Tween.EASE_IN_OUT)
	changeMetadataSongCoverImageTween.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	changeMetadataSongCoverImageTween.set_trans(Tween.TRANS_QUAD)
	
	changeMetadataSongCoverImageTween.tween_property(%metadataSongCoverTextureRect, "self_modulate", Color.BLACK, 0.2)
	changeMetadataSongCoverImageTween.chain().tween_callback(%metadataSongCoverTextureRect.set_texture.bind(newSongCoverImage)) #(%metadataSongCoverTextureRect, "texture", newSongCoverImage, 0)
	changeMetadataSongCoverImageTween.chain().tween_property(%metadataSongCoverTextureRect, "self_modulate", Color.WHITE, 0.2)


func time_to_seconds(time_string: String) -> int:
	var parts: PackedStringArray = time_string.split(":")
	if parts.size() != 2:
		push_error("Formato tempo non valido. Deve essere in formato 'mm:ss'")
		return 0
	
	var minutes: int = int(parts[0])
	var seconds: int = int(parts[1])
	
	return minutes * 60 + seconds

#region Lyrics Management
func requestSongLyrics(Title: String, Author: String, Duration: String) -> void:
	%manualLyricsSearchSongNameLineEdit.text = Title
	%manualLyricsSearchSongNameAuthorLineEdit.text = Author
	%manualLyricsSearchSongNameDurationLineEdit.text = Duration
	
	## This is the API we get the Lyrics from
	var url_starting_part: String = "https://lrclib.net/api/get?artist_name="
	
	var songTitleURL: String = Title.uri_encode()
	var songAuthorURL: String = Author.uri_encode()
	var moreAuthors: PackedStringArray = Author.split(", ")
	songAuthorURL = moreAuthors[0].uri_encode() # Always choose the first author
	
	var final_url: String = url_starting_part + songAuthorURL + "&track_name=" + songTitleURL + "&duration=" + str(time_to_seconds(Duration))
	
	print("Searching lyrics with URL: ", final_url)
	
	var headers: PackedStringArray = [
		"User-Agent: GAMP v1.0 (https://github.com/xShader1374/GAMP)"
	]
	
	LyricsSynchronizer.set_process(false)
	LyricsSynchronizer.lineCounter = 0
	LyricsSynchronizer.syncSeconds.clear()
	LyricsSynchronizer.lyricsLineLabels.clear()
	
	song_lyrics_http_request.cancel_request()
	song_lyrics_http_request.request(final_url, headers, HTTPClient.METHOD_GET)
	
	# Start and show the loading thingy
	song_lyrics_label.text = ""
	
	%songLyricsLinesVBoxContainer.hide()
	%loadingLyricsCenterContainer.show()

func _on_song_lyrics_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# stop and hide the loading thingy
	
	#printt(result, response_code, headers, body)
	
	var parsedBody: Dictionary = {}
	parsedBody = JSON.parse_string(body.get_string_from_utf8())
	
	%loadingLyricsCenterContainer.hide()
	
	if response_code == 200:
		# Checks if body is not null
		if body:
			song_lyrics_label.text = ""
			
			if !parsedBody["instrumental"]:
				%songLyricsLinesVBoxContainer.show()
				%songLyricsLinesVBoxContainer.get_parent().scroll_to_top()
				
				if parsedBody.syncedLyrics:
					loadImportedSyncedLyrics(parsedBody.syncedLyrics)
				else:
					loadImportedPlainLyrics(parsedBody.plainLyrics)
				LyricsSynchronizer.set_process(true)
			else:
				%loadingLyricsCenterContainer.hide()
				song_lyrics_label.text = "♪ Instrumental ♪"
	else:
		print(parsedBody)
		song_lyrics_label.text = "Can't find lyrics for this song.\n(Using LRCLIB API)"

func stripEverythingBetweenSomethingFromString(string : String, symbol1 : String, symbol2 : String) -> String:
	var newString : String = ""
	var insideDelimeters : bool = false
	
	for Char: String in string:
		
		if Char == symbol1:
			insideDelimeters = true
		elif Char == symbol2:
			insideDelimeters = false
		elif !insideDelimeters:
			newString += Char
	
	return newString

func stripSyncSecondsFromLyrics(FullLyrics : String) -> String:
	return stripEverythingBetweenSomethingFromString(FullLyrics, "[", "]")

func loadImportedSyncedLyrics(fullLyrics : String) -> void:
	var lyricsLinesOLD : Array[Node] = %songLyricsLinesVBoxContainer.get_children()
	
	for child: Label in lyricsLinesOLD:
		child.queue_free()
	
	var lyricsLines : PackedStringArray = fullLyrics.split("\n")
	
	# 10 characters
	
	for line: String in lyricsLines:
		
		var lyricLineStripped: String = line.right(line.length() - 10)
		
		LyricsSynchronizer.syncSeconds.append(line.left(10))
		
		
		var newLyricsLineNode: Label = Label.new()
		
		newLyricsLineNode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		newLyricsLineNode.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newLyricsLineNode.label_settings = %loadingLyricsLabel.label_settings
		
		if lyricLineStripped == " ":
			newLyricsLineNode.text = "♪"
		else:
			newLyricsLineNode.text = lyricLineStripped.right(-1)
		
		newLyricsLineNode.pivot_offset = newLyricsLineNode.size / 2.0
		
		%songLyricsLinesVBoxContainer.add_child(newLyricsLineNode)
		
		LyricsSynchronizer.lyricsLineLabels.append(newLyricsLineNode)
		
		newLyricsLineNode.gui_input.connect(LyricsSynchronizer.lyrics_line_GUI_input_event.bind(newLyricsLineNode))
		newLyricsLineNode.mouse_entered.connect(LyricsSynchronizer.lyrics_line_mouse_entered.bind(newLyricsLineNode))
		newLyricsLineNode.mouse_exited.connect(LyricsSynchronizer.lyrics_line_mouse_exited.bind(newLyricsLineNode))
		
		newLyricsLineNode.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		newLyricsLineNode.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		newLyricsLineNode.mouse_filter = Control.MOUSE_FILTER_PASS
	
	print(LyricsSynchronizer.syncSeconds, LyricsSynchronizer.syncSeconds.size())
	print(LyricsSynchronizer.lyricsLineLabels, LyricsSynchronizer.lyricsLineLabels.size())

func loadImportedPlainLyrics(fullLyrics: String) -> void:
	#LyricsSynchronizer.set_process(false)
	
	var lyricsLinesOLD: Array[Node] = %songLyricsLinesVBoxContainer.get_children()
	
	for child: Label in lyricsLinesOLD:
		child.queue_free()
	
	var lyricsLines: PackedStringArray = fullLyrics.split("\n")
	
	for line: String in lyricsLines:
		
		#var lyricLineStripped: String = line.right(line.length() - 10)
		
		#LyricsSynchronizer.syncSeconds.append(line.left(10))
		
		var newLyricsLineNode: Label = Label.new()
		
		newLyricsLineNode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		newLyricsLineNode.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		newLyricsLineNode.label_settings = %loadingLyricsLabel.label_settings
		
		if line == " ":
			newLyricsLineNode.text = "♪"
		else:
			newLyricsLineNode.text = line.right(-1)
		
		newLyricsLineNode.pivot_offset = newLyricsLineNode.size / 2.0
		
		%songLyricsLinesVBoxContainer.add_child(newLyricsLineNode)
		
		LyricsSynchronizer.lyricsLineLabels.append(newLyricsLineNode)
		
		newLyricsLineNode.gui_input.connect(LyricsSynchronizer.lyrics_line_GUI_input_event.bind(newLyricsLineNode))
		newLyricsLineNode.mouse_entered.connect(LyricsSynchronizer.lyrics_line_mouse_entered.bind(newLyricsLineNode))
		newLyricsLineNode.mouse_exited.connect(LyricsSynchronizer.lyrics_line_mouse_exited.bind(newLyricsLineNode))
		
		newLyricsLineNode.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		newLyricsLineNode.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		newLyricsLineNode.mouse_filter = Control.MOUSE_FILTER_PASS
	
#endregion


func requestAuthorImage(Author: String, Title: String) -> void:
	authorNameToRequestImage = Author
	songTitleToRequestImage = Title
	%authorCoverTokenHTTPRequest.cancel_request()
	%authorCoverTokenHTTPRequest.request("https://open.spotify.com/get_access_token?reason=transport&productType=web_player")
	
	printt("Requesting image with params: ", Author, Title)

func _on_author_cover_token_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var parsedBody: Dictionary = JSON.parse_string(body.get_string_from_ascii())
		#print(parsedBody)
		print("Token is: ", parsedBody["accessToken"])
		
		# Se ci sono più di 1 autore, prende sempre il primo + codifica in uri
		var finalAuthorName: String = authorNameToRequestImage.split(", ")[0].uri_encode()
		var finalTrackName: String = songTitleToRequestImage.uri_encode()
		
		%authorCoverHTTPRequest.cancel_request()
		%authorCoverHTTPRequest.request(("https://api.spotify.com/v1/search?type=artist&q=" + finalAuthorName + "&track=" + finalTrackName + "&decorate_restrictions=false&best_match=true&include_external=audio&limit=3"), ["Authorization: Bearer " + parsedBody["accessToken"]])
	else:
		printerr("Couldn't get TOKEN Author Image from Spotify API: ", response_code)

func _on_author_cover_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var parsedBody: Dictionary = JSON.parse_string(body.get_string_from_ascii()) if body.size() > 15 else {"response_code": response_code}
	if response_code == 200:
		var images: Array = parsedBody["artists"]["items"][0]["images"]
		
		# Può capitare che spotify sbagli e non azzecchi alla prima l'artista, quindi, nel dubbio, se le immagini sono vuote, si prende il secondo accanto
		# o almeno, così l'ho interpretata io, boh, non ho capito bene 'sta cosa, onestamente
		if !images.size():
			images = parsedBody["artists"]["items"][1]["images"]
		
		var foundURL: String = ""
		
		foundURL = images[0]["url"]
		
		%authorCoverTextureRect.url = foundURL
		changeAuthorImage()
		
		print("\nBest Match Author Image pfp URL: ", foundURL)
	else:
		%authorCoverTextureRect.url = "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fstatic.vecteezy.com%2Fsystem%2Fresources%2Fpreviews%2F010%2F892%2F324%2Foriginal%2Fx-transparent-free-png.png&f=1&nofb=1&ipt=a964354a8dad0bca3ff81c5fbf84ca99eb4420b3ed26f6b9b29e3dcb7a36232c&ipo=images"
		changeAuthorImage()
		printerr("Getting Author Cover: Something went wrong, code: ", response_code)
		print(parsedBody)




func requestSongImage(Author : String, Title : String) -> void:
	var output : Array = []
	var url_starting_part : String = "https://open.spotify.com/oembed?url="
	
	#OS.execute("C:/Users/shader/AppData/Roaming/Godot/app_userdata/GAMP/linkSongGetter.exe", [str("-a " + Author), str("-s " + Title)], output) 
	
	var args : PackedStringArray = [
		str(globalUserDataPath + "/SpotifyLinkSongGetter.exe"),
		str("-a ", Author),
		str("-s ", Title)
	]
	
	print("Does link.txt exist? ", FileAccess.file_exists(globalUserDataPath + "/link.txt"))
	
	#OS.execute(globalUserDataPath + "/SpotifyLinkSongGetter.exe", args, output, true, true)
	
	OS.execute('powershell.exe', args, output, true, true)
	
	for i : int in output.size():
		print("\n--- ", str(output[i]), " ---\n")
	
	print("Does link.txt exist? ", FileAccess.file_exists(globalUserDataPath + "/link.txt"))
	
	
	
	var foundURL : String = FileAccess.get_file_as_string(globalUserDataPath + "/link.txt")
	
	#DirAccess.remove_absolute(globalUserDataPath + "/link.txt")
	
	print("SpotifyLinkSongGetter.exe found this link: " + foundURL)
	
	var final_url : String = url_starting_part + foundURL
	
	final_url = final_url.strip_edges(false, true)
	
	print("Searching song cover with URL: ", final_url)
	
	%songCoverHTTPRequest.cancel_request()
	var error : Error = %songCoverHTTPRequest.request(final_url)
	
	if error != OK:
		print("Couldn't Get Song Thumbnail Link: ", error)
	

func EQBandSliderDragStarted() -> void:
	EQbandDragStarted = true

func EQBandSliderDragEnded(_value_changed: bool) -> void:
	EQbandDragStarted = false

func EQBandSliderValueChanged(body: Node, value: float) -> void:
	#if EQbandDragStarted:
	EQ21Effect.set_band_gain_db(body.EQNumber, value)

func _on_progress_bar_2_drag_started() -> void:
	progressBarDragStarted = true

func _on_progress_bar_2_value_changed(value: float) -> void:
	if songElementsContainer.get_child_count() > 1 and progressBarDragStarted:
		
		if %MusicPlayer.stream_paused:
			%MusicPlayer.stream_paused = false
			%playButton.add_theme_font_size_override("font_size", 20)
			%playButton.text = "ıı"
		
		%MusicPlayer.seek(progressBar.value)

func _on_progress_bar_2_drag_ended(_value_changed: bool) -> void:
	progressBarDragStarted = false


func _check_volume_button_hover_states() -> void:
	# Verifica tutti gli stati contemporaneamente
	
	if hover_states.values().all(func(state: bool) -> bool: return state == false):
		%volumeTimer.stop()
		%volumeAnimationPlayer.play_backwards("show")

func _on_volume_button_mouse_entered() -> void:
	hover_states["button"] = true
	%volumeAnimationPlayer.play("show")
	%volumeTimer.start(0.0)

func _on_volume_button_mouse_exited() -> void:
	hover_states["button"] = false

func _on_panel_mouse_entered() -> void:
	hover_states["panel"] = true

func _on_panel_mouse_exited() -> void:
	hover_states["panel"] = false

func _on_volume_slider_mouse_entered() -> void:
	hover_states["slider"] = true

func _on_volume_slider_mouse_exited() -> void:
	hover_states["slider"] = false

func _on_volume_timer_timeout() -> void:
	%volumeTimer.start(0.0)
	_check_volume_button_hover_states()


func setAudioBusVolume(volume : float) -> void:
	AudioServer.set_bus_volume_db(0, volume)

func _on_volume_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_mute(0, true)
		%volumeMutedLabel.show()
	else:
		AudioServer.set_bus_mute(0, false)
		%volumeMutedLabel.hide()


func _on_volume_slider_drag_started() -> void:
	volumeSliderDragStarted = true


func _on_volume_slider_drag_ended(_value_changed: bool) -> void:
	volumeSliderDragStarted = false


func _on_volume_slider_value_changed(value: float) -> void:
	if volumeSliderDragStarted:
		setAudioBusVolume(value)


func _on_total_duration_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			print("premuto")
		#else:
		#	print("rilasciato")
	#TODO: make a "-2:39" or 4:20, essentially adding the option to view the remaining time or the total duration

func animatePresetChangingValues(index: int, value: float) -> void:
	var tween: Tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(EQBands[index], "value", value, 0.15).from_current()

func _on_presets_option_button_item_selected(index: int) -> void:
	for i: int in EQ21Effect.get_band_count():
		animatePresetChangingValues(i, EQpresets[index][i])

func _on_music_player_finished() -> void:
	if loop:
		%MusicPlayer.play(0.0)
	else:
		next()

func get_track_part(url : String) -> String:
	var pos: int = url.find("track")
	if pos != -1:
		# Se "track" viene trovato, estrae tutto dal carattere successivo a "track"
		return "track" + url.substr(pos + len("track"))
	else:
		# Se "track" non viene trovato, restituisci l'URL originale
		return url

func _on_spotify_line_edit_text_submitted(new_text: String) -> void:
	downloadingTrackID = get_track_part(new_text).erase(0, 6)
	print(downloadingTrackID)
	
	%SpotifyLineEdit.editable = false
	%ImportSpotifyButton.disabled = true
	%ImportDirButton.disabled = true
	%downloadingLabel.text = "Downloading..."
	$MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Import/HBoxContainer/MarginContainer.show()
	
	%"TOKENsongTitle&AuthorRetriever".cancel_request()
	%"TOKENsongTitle&AuthorRetriever".request("https://open.spotify.com/get_access_token?reason=transport&productType=web_player")

func _on_toke_nsong_title_author_retriever_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json: JSON = JSON.new()
		
		json.parse(body.get_string_from_utf8())
		
		print("Requested TOKEN is: ", json.get_data().accessToken)
		
		%"songTitle&AuthorRetriever".cancel_request()
		%"songTitle&AuthorRetriever".request("https://api.spotify.com/v1/tracks/".path_join(downloadingTrackID), ["Authorization: Bearer " + json.get_data().accessToken])
	else:
		printerr("Couldn't get TOKEN for getting downloading_author_image_and_title from Spotify API: ", response_code)

func _on_song_title_author_retriever_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var parsedBody: Dictionary = JSON.parse_string(body.get_string_from_ascii())
	if response_code == 200:
		print(parsedBody)
		
		var artist: String = parsedBody["album"]["artists"][0]["name"]
		var title: String = parsedBody["name"]
		
		downloadingSongAuthorName = artist
		downloadingSongName = title
		
		%downloadingProgress.start_checking()
		
		%spotifyDownloadHTTPRequest.cancel_request()
		%spotifyDownloadHTTPRequest.request("https://yank.g3v.co.uk/track/".path_join(downloadingTrackID))
		print("Downloading song with URL: ", "https://yank.g3v.co.uk/track/".path_join(downloadingTrackID))
	else:
		printerr("Couldn't get AUTHOR & TITLE from Spotify API: ", response_code)
		print(parsedBody)

func _on_spotify_download_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	%SpotifyLineEdit.editable = true
	%ImportSpotifyButton.disabled = false
	%ImportDirButton.disabled = false
	%downloadingProgress.stop_checking()
	
	var result_name: PackedStringArray = [
		"RESULT_SUCCESS",
		"RESULT_CHUNKED_BODY_SIZE_MISMATCH",
		"RESULT_CANT_CONNECT",
		"RESULT_CANT_RESOLVE",
		"RESULT_CONNECTION_ERROR",
		"RESULT_TLS_HANDSHAKE_ERROR",
		"RESULT_NO_RESPONSE",
		"RESULT_BODY_SIZE_LIMIT_EXCEEDED",
		"RESULT_BODY_DECOMPRESS_FAILED",
		"RESULT_REQUEST_FAILED",
		"RESULT_DOWNLOAD_FILE_CANT_OPEN",
		"RESULT_DOWNLOAD_FILE_WRITE_ERROR",
		"RESULT_REDIRECT_LIMIT_REACHED",
		"RESULT_TIMEOUT"
	]
	
	if body.size() > 1:
		if result == HTTPRequest.Result.RESULT_SUCCESS:
			if response_code == 200:
				%downloadingLabel.text = "Song Downloaded!"
				
				printt("Download finished!\n", result_name[result], response_code, headers, body.get_string_from_utf8())
				%SpotifyLineEdit.text = "Download finished!"
				
				check_songs_dir_exists()
				
				# Sanitizza i nomi del file
				var safe_author: String = downloadingSongAuthorName.uri_decode().strip_edges().replace("/", "-").replace("\\", "-").replace("?", "_")
				var safe_name: String = downloadingSongName.uri_decode().strip_edges().replace("/", "-").replace("\\", "-").replace("?", "_")
				var file_path: String = default_songs_folder.path_join(safe_author + " - " + safe_name + ".mp3")
				
				print("\n", file_path)
				
				# Verifica se il file esiste già
				if FileAccess.file_exists(file_path):
					printerr("File already exists:", file_path)
					%downloadingLabel.text = "Error: File already exists"
					return
				
				# Prova ad aprire il file e gestisci gli errori
				var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
				var error: Error = FileAccess.get_open_error()
				
				if error != OK:
					printerr("Failed to open file. Error code:", error)
					%downloadingLabel.text = "Error saving file: " + str(error)
					return
				
				# Scrivi il file e gestisci eventuali errori
				file.store_buffer(body)
				file.close()
				
				# Verifica che il file sia stato effettivamente creato
				if not FileAccess.file_exists(file_path):
					printerr("File was not created successfully")
					%downloadingLabel.text = "Error: File not saved"
					return
				
				importSingleSong(file_path)
			else:
				%downloadingLabel.text = "HTTP Error " + str(response_code)
				var parsedBody: Dictionary = JSON.parse_string(body.get_string_from_ascii())
				if parsedBody.has("message"):
					%downloadingLabel.text += ": " + parsedBody["message"]
				printerr("HTTP Error: ", response_code, "Result:", result_name[result])
		else:
			%downloadingLabel.text = "Download Error: " + result_name[result]
			printerr("Download Error: ", result_name[result])
	else:
		%downloadingLabel.text = "Download Error:\n" + "content too small(corrupted?)"
		printerr("Download Error: ", "Body was too small(corrupted?)")
	
	downloadingTrackID = ""
	downloadingSongAuthorName = ""
	downloadingSongName = ""

func _on_import_spotify_button_pressed() -> void:
	_on_spotify_line_edit_text_submitted(%SpotifyLineEdit.text)


func _on_manually_search_lyrics_button_pressed() -> void:
	if !manual_search_popup_control.visible:
		manual_search_popup_control.show()
	else:
		manual_search_popup_control.hide()

func _on_lyrics_full_screen_button_pressed() -> void:
	if !lyricsFullscreen:
		lyricsFullscreen = true
		
		$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/VBoxContainer".hide()
		$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/VSeparator2".hide()
	else:
		lyricsFullscreen = false
		
		$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/VBoxContainer".show()
		$"MarginContainer/Panel/MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/TabContainer/Song Info/HBoxContainer/HBoxContainer/VSeparator2".show()


func _on_final_manual_search_button_pressed() -> void:
	if !manual_search_popup_control.visible:
		manual_search_popup_control.show()
	else:
		manual_search_popup_control.hide()
	
	# Search Lyrics with Name, Author, Duration inputs
	
	print("\n--- User asked to search for Lyrics: ---\n",
	"Song Name: " + %manualLyricsSearchSongNameLineEdit.text + "\n",
	"Song Author: " + %manualLyricsSearchSongNameAuthorLineEdit.text + "\n",
	"Song Duration: " + %manualLyricsSearchSongNameDurationLineEdit.text + "\n",
	)
	
	requestSongLyrics(%manualLyricsSearchSongNameLineEdit.text, %manualLyricsSearchSongNameAuthorLineEdit.text, %manualLyricsSearchSongNameDurationLineEdit.text)
	

func _on_song_cover_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	
	var json: JSON = JSON.new()
	
	json.parse(body.get_string_from_utf8())
	
	var imageURL : String = json.get_data().thumbnail_url
	
	print("Song Thumbnail Found: ", imageURL)
	
	%songCoverActualHTTPRequest.cancel_request()
	%songCoverActualHTTPRequest.request(imageURL)
	


func _on_song_cover_actual_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var image : Image = Image.new()
	var error : Error = image.load_jpg_from_buffer(body)
	
	if error != OK:
		push_error("Couldn't load the image.")
	
	var texture : ImageTexture = ImageTexture.create_from_image(image)
	
	%songCoverTextureRect.texture = texture


func _on_check_for_text_file_timer_timeout() -> void:
	pass # Replace with function body.


func add_effect_button_pressed(index: int) -> void:
	print("requested adding effect: ", addEffectButtonPopup.get_item_text(index), " (", index, ")")
	var newEffectPanel: PanelContainer = EFFECT_PANEL.instantiate()
	newEffectPanel.choosed_effect_index = index
	newEffectPanel.effect_name = addEffectButtonPopup.get_item_text(index)
	%EffectsHBoxContainer.get_child(%EffectsHBoxContainer.get_child_count() - 2).add_sibling(newEffectPanel)


func _on_playback_tempo_h_slider_value_changed(value: float) -> void:
	AudioServer.set_playback_speed_scale(value)
	if value != 1.0:
		%resetPlaybackTempoButton.show()
	else:
		%resetPlaybackTempoButton.hide()


func _on_reset_playback_tempo_button_pressed() -> void:
	AudioServer.set_playback_speed_scale(1.0)
	%playbackTempoHSlider.value = 1.0
	%resetPlaybackTempoButton.hide()


func _on_playback_pitch_h_slider_value_changed(value: float) -> void:
	%MusicPlayer.pitch_scale = value
	if value != 1.0:
		%resetPlaybackPitchButton.show()
	else:
		%resetPlaybackPitchButton.hide()


func _on_reset_playback_pitch_button_pressed() -> void:
	%MusicPlayer.pitch_scale = 1.0
	%playbackPitchHSlider.value = 1.0
	%resetPlaybackPitchButton.hide()


func _on_effects_h_box_container_child_exiting_tree(_node: Node) -> void:
	for child: Control in %EffectsHBoxContainer.get_children():
		if child is PanelContainer:
			child.update_index()


func _on_metadata_confirm_apply_button_pressed() -> void:
	pass # Replace with function body.

func _on_fetch_metadata_button_pressed() -> void:
	pass # Replace with function body.

func _on_change_image_metadata_button_pressed() -> void:
	pass # Replace with function body.
