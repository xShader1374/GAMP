extends ColorRect

@export_range(10, 100) var VU_COUNT: int = 30
@export_range(1000, 20000) var FREQ_MAX: float = 11050.0
@export_range(0, 80) var MIN_DB: float = 60
@export_range(0.01, 1.0) var ANIMATION_SPEED: float = 0.1
@export_range(0.1, 20.0) var HEIGHT_SCALE: float = 8.0

var spectrum: AudioEffectSpectrumAnalyzerInstance
var min_values: PackedFloat32Array
var max_values: PackedFloat32Array

func _ready() -> void:
	# Verifica esistenza effetto audio
	if AudioServer.get_bus_effect_count(2) > 0:
		spectrum = AudioServer.get_bus_effect_instance(2, 0)
	else:
		push_error("Nessun effetto spectrum analyzer sul bus audio!")
	
	# Inizializza arrays con dimensione predefinita
	min_values = PackedFloat32Array()
	max_values = PackedFloat32Array()
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)

func _process(delta: float) -> void:
	if not spectrum:
		return
	
	var data: PackedFloat32Array = PackedFloat32Array()
	data.resize(VU_COUNT)
	
	var freq_step: float = FREQ_MAX / VU_COUNT
	var prev_hz: float = 0.0
	
	# Calcolo ottimizzato delle frequenze
	for i: int in VU_COUNT:
		var hz: float = (i + 1) * freq_step
		var magnitude: Vector2 = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		
		# Converti in dB con controllo zero
		var energy: float = clamp(
			(MIN_DB + linear_to_db(magnitude.length())) / MIN_DB,
			0.0, 
			1.0
		) * HEIGHT_SCALE
		
		data[i] = energy
		prev_hz = hz
	
	# Aggiornamento valori con interpolazione frame-rate independent
	var t: float = ANIMATION_SPEED * delta * 60  # Normalizza per 60 FPS
	
	for i: int in VU_COUNT:
		# Peak detection
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], t)
		
		# Decadimento minimo
		min_values[i] = lerp(min_values[i], data[i] if data[i] > 0 else 0.0, t)
	
	# Prepara dati per lo shader
	var fft: PackedFloat32Array = PackedFloat32Array()
	fft.resize(VU_COUNT)
	
	for i: int in VU_COUNT:
		fft[i] = lerp(min_values[i], max_values[i], 0.5)
	
	# Aggiorna shader in modo sicuro
	if material:
		material.set_shader_parameter("freq_data", fft)
