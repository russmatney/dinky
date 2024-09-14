extends Node


func _ready():
	Log.register_type_overwrite(InkChoice.new().get_class(),
		func(choice, _opts):
		# TODO should be able to just return an array here
		var args = [choice.index, choice.text]
		if choice.tags and not choice.tags.is_empty():
			args.append(choice.tags)
		return Log.to_pretty(args))
