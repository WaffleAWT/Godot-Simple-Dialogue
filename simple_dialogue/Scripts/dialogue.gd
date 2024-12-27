@icon("res://addons/simple_dialogue/Assets/Dialogue.png")
class_name Dialogue
extends Label
##A simple dialogue plugin. it adds a custom node called Dialogue, it emits a signal when the dialogue starts, ends, which you can connect from the inscpector or in script. and you can play it by calling play(), you can customize it easily because it extends [Label].

##Emitted when you call [member play()]
signal dialogue_started
##Emitted when the dialogue ends.
signal dialogue_finished

##A list of [DialogueMessage], add messages to it to display for the dialogue.
@export var dialogue_messages : Array[DialogueMessage]
##If true the dialogue waits for player input before it proceeds to play the next dialogue message, this option is ignored if [member dialogue_messages] has one message only.
@export var wait_player_input : bool
##The string for what player input to expect, set to Enter by default, this option is ignored if [member wait_player_input] is set to [code]false[/code].
@export var player_input : String = "ui_accept"
##Custom delay time after each message ends, it affects when to expect [member player_input] if [member wait_player_input] is set to [code]true[/code].
@export var delay : float = 1.0
##Dialogue playback speed, higher values means slower dialogue.
@export_range(0.02, 2.0) var play_speed : float = 0.05
##Audio file to play when the dialogue types a character, it automatically sets the audio file's [member AudioStreamMP3.loop] to [code]false[/code], same goes if the file was [AudioStreamWAV], it will cause an error if the audio file was any other format.
@export var typing_audio : AudioStream

var _current_dialogue_index : int = 0
var _is_playing : bool = false
var _typing_audio_player
var _waiting_player_input : bool = false

func _ready() -> void:
	if typing_audio and (typing_audio is AudioStreamMP3 or typing_audio is AudioStreamWAV):
		if typing_audio is AudioStreamMP3:
			typing_audio.loop = false
		else:
			typing_audio.loop_mode = AudioStreamWAV.LOOP_DISABLED
		_typing_audio_player = AudioStreamPlayer.new()
		_typing_audio_player.stream = typing_audio
		get_tree().current_scene.add_child.call_deferred(_typing_audio_player)
	elif typing_audio and not (typing_audio is AudioStreamMP3 or typing_audio is AudioStreamWAV):
		push_error("The audio file should be in MP3 or WAV format.")

func _input(event : InputEvent) -> void:
	if event.is_action_pressed(player_input) and _waiting_player_input:
		_waiting_player_input = false
		_next_dialog()

##Starts the dialogue.
func play() -> void:
	if _is_playing:
		push_error("You can't call play while the dialogue is playing!")
		return
	elif dialogue_messages.is_empty():
		push_error("There are no dialogue messages to play!")
		return
	
	_is_playing = true
	_current_dialogue_index = 0
	dialogue_started.emit()
	_play_current_dialog()

func _play_current_dialog() -> void:
	if _current_dialogue_index >= dialogue_messages.size():
		_end_dialog()
		return
	
	if dialogue_messages[_current_dialogue_index]:
		var dialog = dialogue_messages[_current_dialogue_index]
		_typewriter_effect(dialog._message)
	else:
		push_error("You can't set the size of the dialogue_messages array higher than zero if you won't add any DialogueMessage to it.")

func _typewriter_effect(message : String) -> void:
	text = ""
	var char_index = 0
	
	for char in message:
		text += char
		if _typing_audio_player and _typing_audio_player.is_inside_tree():
			_typing_audio_player.playing = true
		await get_tree().create_timer(play_speed).timeout
	
	if _current_dialogue_index < dialogue_messages.size() - 1 and wait_player_input:
		_wait_for_input()
	else:
		_next_dialog_with_delay()

func _wait_for_input() -> void:
	_waiting_player_input = true

func _next_dialog_with_delay() -> void:
	await get_tree().create_timer(delay).timeout
	_next_dialog()

func _next_dialog() -> void:
	_current_dialogue_index += 1
	_play_current_dialog()

func _end_dialog() -> void:
	_is_playing = false
	dialogue_finished.emit()
