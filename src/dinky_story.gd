extends Node

## vars ##############################################

@onready var background = $%Background
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
		Log.pr("tags to handle!", tags)

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
