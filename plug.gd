extends "res://addons/gd-plug/plug.gd"

func _plugging():
	plug("ephread/inkgd", {branch="godot4", include=["addons/inkgd"]})
	plug("russmatney/log.gd", {include=["addons/log"]})
