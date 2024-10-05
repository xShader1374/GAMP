extends TextureRect

@onready var spectrum_shader : ShaderMaterial = self.get_material()

@onready var analyzer : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(0, 0)

@export var VU_COUNT : int = 1024
@export var FREQ_MAX : float =  3000.0

@export var WIDTH : int = 400

@export var MIN_DB : float = 85.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		var prev_hz : float = 0.0
		
		var columns : Array[float] = [] # heights of the columns
		
		if %MusicPlayer.playing:
			for i : int in range( VU_COUNT ):
				var hz : float = ( i + 1 ) * FREQ_MAX / VU_COUNT
				var magnitude : float = analyzer.get_magnitude_for_frequency_range( prev_hz, hz ).length( )
				var energy : float = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0.0, 1.0)
				columns.append(energy)
				spectrum_shader.set_shader_parameter("columns", columns)
				prev_hz = hz
		else:
			for i : int in range( VU_COUNT ):
				var hz : float = ( i + 1 ) * FREQ_MAX / VU_COUNT
				var magnitude : float = 0
				var energy : float = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0.0, 1.0)
				columns.append(energy)
				spectrum_shader.set_shader_parameter("columns", columns)
				prev_hz = hz
