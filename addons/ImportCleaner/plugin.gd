@tool
extends EditorPlugin


const MENU_ITEM_NAME: String = "Clean Up Import Data"
const IMPORT_DIR: String = "res://.godot/imported/"

var available_files: Array = []
var clean_files: Array = []


func _enter_tree() -> void:
	add_tool_menu_item(MENU_ITEM_NAME, clean_up_import_data)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM_NAME)


func clean_up_import_data() -> void:
	available_files.clear()
	clean_files.clear()
	scan_available()
	scan_clean()
	for name in clean_files:
		print("Removing " + name)
		DirAccess.remove_absolute(IMPORT_DIR + name)
	print("Removed %d %s." % [len(clean_files), "file" if len(clean_files) == 1 else "files"])


func scan_available() -> void:
	_scan(EditorInterface.get_resource_filesystem().get_filesystem())


func _scan(dir: EditorFileSystemDirectory) -> void:
	for i in range(dir.get_subdir_count()):
		_scan(dir.get_subdir(i))
	for i in range(dir.get_file_count()):
		if dir.get_file_import_is_valid(i) and FileAccess.file_exists(dir.get_file_path(i) + ".import"):
			available_files.append(dir.get_file(i) + "-" + dir.get_file_path(i).md5_text())


func scan_clean():
	var dir: DirAccess = DirAccess.open(IMPORT_DIR)
	dir.list_dir_begin()
	var name = dir.get_next()
	while name != "":
		if not dir.current_is_dir() and not name.get_basename() in available_files:
			clean_files.append(name)
		name = dir.get_next()
