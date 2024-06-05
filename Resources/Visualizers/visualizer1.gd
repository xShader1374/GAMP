extends TextureRect

@onready var visualizerTextureRect := self
@onready var spectrum_shader : ShaderMaterial = visualizerTextureRect.get_material()

@onready var analyzer : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(0, 0)

@export var VU_COUNT : int = 16
@export var FREQ_MAX : float = 11050.0

@export var WIDTH : int = 400

@export var MIN_DB : int = 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $"../../../../../../../../MusicPlayer".playing:
		var w : float = WIDTH / VU_COUNT
		var prev_hz = 0
		var heights = []
		for i in range(1, VU_COUNT+1):
			var hz = i * FREQ_MAX / VU_COUNT;
			var magnitude: float = analyzer.get_magnitude_for_frequency_range(prev_hz, hz).length()
			var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, -1, 1)
			var height = energy
			heights.append(height)
			spectrum_shader.set_shader_parameter("heights", heights)
			prev_hz = hz
		
	
