extends Node

@onready var main_node: Control = get_node("/root/MainControl")

func _ready() -> void:
	process_thread_group = PROCESS_THREAD_GROUP_SUB_THREAD
	process_thread_messages = FLAG_PROCESS_THREAD_MESSAGES
	
	DisplayServer.window_set_drop_files_callback(files_dropped)

func files_dropped(files_paths: PackedStringArray) -> void:
	print(files_paths)
	main_node.importSingleSong(files_paths[0])
