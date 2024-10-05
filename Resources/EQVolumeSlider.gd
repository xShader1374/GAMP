extends VSlider

@onready var main : Control = $"../../../../../../../../../../../../../.."
var EQNumber : int = 0

signal dragValue(Body : Node, Value : float)

func _ready() -> void:
	self.connect("dragValue", Callable(main, "EQBandSliderValueChanged"))
	self.connect("value_changed", _on_value_changed) # revisione potenziale
	self.connect("drag_started", Callable(main, "EQBandSliderDragStarted"))
	self.connect("drag_ended", Callable(main, "EQBandSliderDragEnded"))

func setEQNumber(index: int) -> void:
	EQNumber = index


func _on_value_changed(Value: float) -> void:
	emit_signal("dragValue", self, Value)
