extends Node

@onready var main_node: Control = get_node("/root/MainControl")

var importerThread: Thread

func _ready() -> void:
	process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	process_thread_messages = FLAG_PROCESS_THREAD_MESSAGES
	
	DisplayServer.window_set_drop_files_callback(files_dropped)

func importThreaded(files_paths: PackedStringArray) -> void:
	for filePath: String in files_paths:
		print("Importing dropped file: ", filePath)
		main_node.importSingleSong(filePath)
		#main_node.call_deferred("importSingleSong", filePath)
	call_deferred("finishedImportingDroppedSongs")

func files_dropped(files_paths: PackedStringArray) -> void:
	print(files_paths)
	
	importerThread = Thread.new()
	importerThread.start(importThreaded.bind(files_paths))

func finishedImportingDroppedSongs() -> void:
	importerThread.wait_to_finish()
	print("--- Finished Importing Dropped Songs! ---")
