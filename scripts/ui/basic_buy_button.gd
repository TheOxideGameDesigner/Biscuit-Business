extends Node

var value
var json : Dictionary
var enabled : bool
@export var value_name : String

func ready_deff():
	value = json[value_name]

func _ready():
	ready_deff.call_deferred()
