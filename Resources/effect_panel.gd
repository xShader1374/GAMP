extends PanelContainer

var effect_name: String = ""
var choosed_effect_index: int = 17

var audio_effect_index: int = 0
var audioEffect: AudioEffect

# Dizionario per mappare i tipi di proprietà ai loro nomi leggibili
const PROPERTY_TYPES: Dictionary[Variant, String] = {
	TYPE_NIL: "Null",
	TYPE_BOOL: "Boolean",
	TYPE_INT: "Integer",
	TYPE_FLOAT: "Float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_VECTOR3: "Vector3",
	TYPE_COLOR: "Color"
}

# Lista delle proprietà da ignorare
const IGNORED_PROPERTIES: PackedStringArray = ["script", "resource_local_to_scene", "resource_path", "resource_name", "Resource", "RefCounted", "resource_scene_unique_id", "AudioEffect", "AudioEffectReverb"]

func _ready() -> void:
	update_index()
	setup_effect(choosed_effect_index)
	%effectNameLabel.text = effect_name

func setup_effect(index: int) -> void:
	match index:
		0:
			audioEffect = AudioEffectAmplify.new()
		1:
			audioEffect = AudioEffectBandLimitFilter.new()
		2:
			audioEffect = AudioEffectBandPassFilter.new()
		3:
			audioEffect = AudioEffectChorus.new()
		4:
			audioEffect = AudioEffectCompressor.new()
		5:
			audioEffect = AudioEffectDelay.new()
		6:
			audioEffect = AudioEffectDistortion.new()
		7:
			audioEffect = AudioEffectFilter.new()
		8:
			audioEffect = AudioEffectHighPassFilter.new()
		9:
			audioEffect = AudioEffectHighShelfFilter.new()
		10:
			audioEffect = AudioEffectLimiter.new()
		11:
			audioEffect = AudioEffectLowPassFilter.new()
		12:
			audioEffect = AudioEffectLowShelfFilter.new()
		13:
			audioEffect = AudioEffectNotchFilter.new()
		14:
			audioEffect = AudioEffectPanner.new()
		15:
			audioEffect = AudioEffectPhaser.new()
		16:
			audioEffect = AudioEffectPitchShift.new()
		17:
			audioEffect = AudioEffectReverb.new()
		18:
			audioEffect = AudioEffectStereoEnhance.new()
	
	setup_effect_properties()
	
	AudioServer.add_bus_effect(1, audioEffect, audio_effect_index)

func setup_effect_properties() -> void:
	for property: Dictionary[String, Variant] in audioEffect.get_property_list():
		# Ignora le proprietà che non ci interessano e le categorie (TYPE_NIL)
		if property.name in IGNORED_PROPERTIES or property["name"] == "" or property.type == TYPE_NIL:
			continue
		
		# Crea un container per ogni proprietà
		var property_container: HBoxContainer = HBoxContainer.new()
		
		# Aggiungi il nome della proprietà
		var name_label: Label = Label.new()
		name_label.text = property.name
		property_container.add_child(name_label)
		
		# Aggiungi il tipo della proprietà
		# var type_label: Label = Label.new()
		# type_label.text = " (" + get_property_type_name(property.type) + ")"
		# property_container.add_child(type_label)
		
		var current_value: Variant = audioEffect.get(property.name)
		
		
		# Aggiungi un controllo appropriato in base al tipo
		add_property_control(property_container, property, current_value)
		
		# Aggiungi il valore corrente
		var value_label: Label = Label.new()
		value_label.text = str(current_value).pad_decimals(2)
		property_container.add_child(value_label)
		
		%effectPropertiesListVBoxContainer.add_child(property_container)

func get_property_type_name(type: int) -> String:
	return PROPERTY_TYPES.get(type, "Unknown")

func add_property_control(container: HBoxContainer, property: Dictionary, current_value: Variant) -> void:
	print("Property Type is: ", property.type)
	match property.type:
		TYPE_BOOL:
			var checkbox: CheckBox = CheckBox.new()
			checkbox.button_pressed = current_value
			checkbox.connect("toggled", _on_property_bool_changed.bind(property.name))
			container.add_child(checkbox)
		
		TYPE_FLOAT:
			var slider: HSlider = HSlider.new()
			if "hint" in property and property.hint == PROPERTY_HINT_RANGE:
				var hint_string: PackedStringArray = property.hint_string.split(",")
				slider.min_value = float(hint_string[0])
				slider.max_value = float(hint_string[1])
				slider.step = float(hint_string[2]) if hint_string.size() > 2 else 0.1
			else:
				slider.min_value = 0.0
				slider.max_value = 1.0
				slider.step = 0.1
			slider.value = current_value
			slider.custom_minimum_size.x = 100
			slider.connect("value_changed", _on_property_float_changed.bind(property.name))
			container.add_child(slider)
		
		TYPE_INT:
			var spinbox: SpinBox = SpinBox.new()
			if "hint" in property and property.hint == PROPERTY_HINT_RANGE:
				var hint_string: PackedStringArray = property.hint_string.split(",")
				spinbox.min_value = int(hint_string[0])
				spinbox.max_value = int(hint_string[1])
				spinbox.step = int(hint_string[2]) if hint_string.size() > 2 else 1
			spinbox.value = current_value
			spinbox.connect("value_changed", _on_property_int_changed.bind(property.name))
			container.add_child(spinbox)

func _on_property_bool_changed(value: bool, property_name: String) -> void:
	audioEffect.set(property_name, value)

func _on_property_float_changed(value: float, property_name: String) -> void:
	audioEffect.set(property_name, value)

func _on_property_int_changed(value: int, property_name: String) -> void:
	audioEffect.set(property_name, value)

func _on_effect_enabled_check_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_effect_enabled(1, audio_effect_index, toggled_on)

func update_index() -> void:
	audio_effect_index = clamp(get_index() - 2, 0, INF)

func _on_delete_button_pressed() -> void:
	queue_free()

func _on_tree_exiting() -> void:
	AudioServer.remove_bus_effect(1, audio_effect_index)
