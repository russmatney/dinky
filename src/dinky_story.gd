extends Node

## vars ##############################################

@onready var background_texture_rect = $%Background
@onready var portrait_texture_rect = $%Portrait
@onready var choices_list = $%ChoicesList
@onready var speaker_label = $%SpeakerLabel
@onready var speaker_container = $%SpeakerContainer
@onready var dialogue_label = $%DialogueLabel
@onready var ink_player = $%InkPlayer

@onready var sprite_left = $%SpriteLeft
@onready var sprite_center = $%SpriteCenter
@onready var sprite_right = $%SpriteRight

@onready var button_scene = preload("res://src/DinkyChoiceButton.tscn")

enum StoryState {
	None=0,
	Processing=1,
	Reading=2,
	Animating=3,
	Choosing=4,
	Ended=5,
	}

var story_state = StoryState.None

## ready ##############################################

func _ready():
	Log.pr("Ready!")

	story_state = StoryState.Processing

	speaker_container.visible = false

	ink_player.loaded.connect(story_loaded)
	ink_player.continued.connect(continued)
	ink_player.prompt_choices.connect(prompt_choices)
	ink_player.ended.connect(ended)

	ink_player.create_story()

## input ##############################################

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		match story_state:
			StoryState.Reading:
				ink_player.continue_story()
			_:
				pass

## ink_player callbacks ##############################################

func story_loaded(successfully: bool):
	if !successfully:
		return

	ink_player.continue_story()

func continued(text, tags):
	Log.pr("story continued")
	story_state = StoryState.Animating

	if !tags.is_empty():
		handle_tags(tags)

	# TODO animate text
	dialogue_label.text = text

	story_state = StoryState.Reading

func prompt_choices(choices):
	if !choices.is_empty():
		story_state = StoryState.Choosing
		Log.pr("choices", choices)

		for choice in choices:
			var btn = button_scene.instantiate()
			btn.text = choice.text
			btn.pressed.connect(select_choice.bind(choice.index))
			choices_list.add_child(btn)

func select_choice(index):
	remove_choices()
	ink_player.choose_choice_index(index)
	ink_player.continue_story()

func ended():
	story_state = StoryState.Ended
	print("The End")

## misc helpers ##############################################

func remove_choices():
	for ch in choices_list.get_children():
		ch.queue_free()

## tag handlers ##############################################

var tag_handlers = {
	"SetImage": set_image,
	"ClearImage": clear_image,
	"PlayAnim": play_animation,
	"ClearAnim": clear_animation,
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

## node refs

var node_refs = {
	"Background": func(): return background_texture_rect,
	"Portrait": func(): return portrait_texture_rect,
	"Center": func(): return sprite_center,
	"Left": func(): return sprite_left,
	"Right": func(): return sprite_right,
	}

func get_node_for_label(args):
	if args.is_empty():
		Log.warn("empty image args!", args)
		return
	var ref = args[0]
	if ref not in node_refs:
		Log.warn("ref not handled by node_refs!", args, ref)
		return
	return node_refs[ref].call()

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
	Log.pr("set_image", args)
	var texture_rect = get_node_for_label(args)
	var path = get_image_path(args)
	if not texture_rect or not path:
		Log.warn("Error setting image with args", args)
		return

	var texture = load(path)
	texture_rect.set_texture(texture)
	texture_rect.visible = true;

func clear_image(args):
	Log.pr("clear_image", args)

	var texture_rect = get_node_for_label(args)
	if not texture_rect:
		Log.warn("Error clearing image with args", args)
		return
	texture_rect.visible = false;

## animation handling

func get_anim_node(args):
	if len(args) < 2:
		Log.warn("expected anim args to have a character name!", args)
		return
	var scene_path = str("res://src/portraits/" + args[1] + ".tscn")
	var packed_scene = load(scene_path)
	var node = packed_scene.instantiate()
	return node

func get_animation_name(args):
	if len(args) < 3:
		Log.warn("expected anim args to include an animation name!", args)
		return
	return args[2]

# PlayAnim Center ThiefGuard happy
# PlayAnim Left Superintendent sad
func play_animation(args):
	Log.pr("play_animation", args)

	var anim_container = get_node_for_label(args)
	var anim_node = get_anim_node(args)
	var animation_name = get_animation_name(args)
	if not anim_container or not anim_node or not animation_name:
		Log.warn("Error playing_animation for args", args, anim_container, anim_node, animation_name)
		return

	for ch in anim_container.get_children():
		ch.queue_free()

	anim_node.play(animation_name)
	anim_container.add_child(anim_node)

func clear_animation(args):
	var containers = []
	if args.is_empty():
		containers.append_array([sprite_center, sprite_left, sprite_right])
	elif args[0] == "Center":
		containers.append(sprite_center)
	elif args[0] == "Left":
		containers.append(sprite_left)
	elif args[0] == "Right":
		containers.append(sprite_right)

	for container in containers:
		for ch in container.get_children():
			ch.queue_free();
