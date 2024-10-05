@tool
extends EditorPlugin

# Editor will continue to work if class_name is removed from network_texture_rect.gd
const _NetworkTextureRect := preload("./network_texture_rect.gd")
var network_texture_rect_editor_inspector_plugin := NetworkTextureRectEditorInspectorPlugin.new()

func _enter_tree():
	add_inspector_plugin(network_texture_rect_editor_inspector_plugin)

func _exit_tree():
	remove_inspector_plugin(network_texture_rect_editor_inspector_plugin)

# my_inspector_plugin.gd
class NetworkTextureRectEditorInspectorPlugin extends EditorInspectorPlugin:

	const DOWNLOAD_ICON := preload("./icons/Download.svg")
	const DOWNLOAD_CANCEL := preload("./icons/StatusError.svg")
	const CLEAR_ICON := preload("./icons/Clear.svg")

	func _can_handle(object: Object):
		return object is _NetworkTextureRect

	func _parse_property(
		object: Object,
		type: int,
		name: String,
		hint_type: int,
		hint_string: String,
		usage_flags: int,
		wide: bool
	):
		var o := object as _NetworkTextureRect

		if name == "status":
			var label := Label.new()
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.text = "Status: %s" % _NetworkTextureRect.ImageLoadingStatus.keys()[o.status]
			var margin_container := MarginContainer.new()
			var hbox := HBoxContainer.new()
			margin_container.add_child(hbox)
			hbox.add_child(label)
			var action_button := Button.new()
			action_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			# action_button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			# action_button.alignment = HORIZONTAL_ALIGNMENT_LEFT

			match o.status:
				_NetworkTextureRect.ImageLoadingStatus.IDLE:
					action_button.text = "Load Image"
					action_button.icon = DOWNLOAD_ICON
					action_button.pressed.connect(func(): o.request())
				_NetworkTextureRect.ImageLoadingStatus.LOADING:
					action_button.text = "Cancel"
					action_button.icon = DOWNLOAD_CANCEL
					action_button.pressed.connect(func(): o.cancel())
				_NetworkTextureRect.ImageLoadingStatus.COMPLETED:
					action_button.text = "Clear"
					action_button.icon = CLEAR_ICON
					action_button.pressed.connect(func(): o.clear())
				_NetworkTextureRect.ImageLoadingStatus.ERRORED:
					action_button.text = "Clear"
					action_button.icon = CLEAR_ICON
					action_button.pressed.connect(func(): o.clear())
			hbox.add_child(action_button)

			add_custom_control(margin_container)
			return true
