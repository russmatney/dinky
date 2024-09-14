extends "res://addons/gd-plug/plug.gd"

func _plugging():
	plug("ephread/inkgd", {branch="godot4", inclue=["addons/inkgd"]})
