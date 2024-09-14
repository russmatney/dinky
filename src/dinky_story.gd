extends Node

## vars ##############################################

@onready var background_texture_rect = $%Background
@onready var portrait_texture_rect = $%Portrait
@onready var choices_list = $%ChoicesList
@onready var speaker_label = $%SpeakerLabel
@onready var speaker_container = $%SpeakerContainer
@onready var dialogue_label = $%DialogueLabel
@onready var ink_player = $%InkPlayer

@onready var button_scene = preload("res://src/DinkyChoiceButton.tscn")

## ready ##############################################

func _ready():
	Log.pr("Ready!")

	speaker_container.visible = false

	ink_player.loaded.connect(story_loaded)
	ink_player.continued.connect(continued)
	ink_player.prompt_choices.connect(prompt_choices)
	ink_player.ended.connect(ended)

	ink_player.create_story()

## ink_player callbacks ##############################################

func story_loaded(successfully: bool):
	if !successfully:
		return

	ink_player.continue_story()

func continued(text, tags):
	Log.pr("story continued")

	if !tags.is_empty():
		handle_tags(tags)

	dialogue_label.text = text

	# TODO animate text
	# TODO skip with input

	# wait for timer or input
	await get_tree().create_timer(3.0).timeout

	ink_player.continue_story()

func prompt_choices(choices):
	if !choices.is_empty():
		Log.pr("choices", choices)

		for choice in choices:
			var btn = button_scene.instantiate()
			btn.text = choice.text
			btn.pressed.connect(select_choice.bind(choice.index))
			choices_list.add_child(btn)

func select_choice(index):
	remove_choices()
	ink_player.choose_choice_index(index)
	print("finished choice selection, continuing story")
	ink_player.continue_story()

func ended():
	print("The End")

## misc helpers ##############################################

func remove_choices():
	for ch in choices_list.get_children():
		ch.queue_free()

## tag handlers ##############################################

var tag_handlers = {
	"SetImage": set_image,
	"ClearImage": clear_image,
	}

func handle_tags(tags):
	if (tags.is_empty()):
		Log.warn("Empty tags passed")
		return
	for tag in tags:
		handle_tag(tag)

func handle_tag(tag):
	var tag_parts = Array(tag.split(" "))
	if (tag_parts.is_empty()):
		Log.warn("Empty tags passed (no command?)")
		return

	var cmd = tag_parts.pop_front()
	Log.pr("tag", {cmd=cmd, args=tag_parts})

	if cmd in tag_handlers:
		tag_handlers[cmd].call(tag_parts)

## image handlers ##############################################

var image_refs = {
	"Background": func(): return background_texture_rect,
	"Portrait": func(): return portrait_texture_rect,
	}

func get_image_texture_rect(args):
	if args.is_empty():
		Log.warn("empty image args!", args)
		return
	var ref = args[0]
	if ref not in image_refs:
		Log.warn("ref not handled by image_refs!", args, ref)
		return
	return image_refs[ref].call()

func get_image_path(args):
	if len(args) < 2:
		Log.warn("expected image args to have path!", args)
		return
	var p = str("res://assets/" + args[1] + ".png")
	if not FileAccess.file_exists(p):
		Log.warn("No file found at a path", p)
		return
	return p

func set_image(args):
	Log.pr("set_image: ", args)
	var texture_rect = get_image_texture_rect(args)
	var path = get_image_path(args)
	if not texture_rect or not path:
		Log.warn("Error setting image with args", args)
		return

	var texture = load(path)
	texture_rect.set_texture(texture)
	texture_rect.visible = true;

func clear_image(args):
	Log.pr("clear_image: ", args)

	var texture_rect = get_image_texture_rect(args)
	if not texture_rect:
		Log.warn("Error clearing image with args", args)
		return
	texture_rect.visible = false;
