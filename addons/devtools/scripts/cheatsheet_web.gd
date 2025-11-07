extends Node


const FINAL_HTML_PATH := "user://devtools/web/index.html"
const ROOT_HTML_PATH := "res://addons/devtools/web/index.html"
const COMMAND_HTML_PATH := "res://addons/devtools/web/components/command.html"


signal updated_html()


var is_updating := false
var invalid_html := true
var html_mutex := Mutex.new()


func _ready() -> void:
	DevTools.command_registered.connect(func(): invalid_html = true, Node.CONNECT_DEFERRED)


func open() -> void:
	if is_updating: return
	await update_commands_json()
	OS.shell_open(ProjectSettings.globalize_path(FINAL_HTML_PATH))


func update_commands_json() -> void:
	if is_updating:
		await updated_html
		return
	
	is_updating = true
	
	var thread := Thread.new()
	thread.start(_update_commands_json_threaded.bind(DevTools.commands_by_id))
	
	await updated_html
	
	is_updating = false


func _update_commands_json_threaded(commands_by_id: Dictionary[StringName, DEV_Command]) -> void:
	var index_hbs = FileAccess.get_file_as_string(ROOT_HTML_PATH)
	var command_hbs = FileAccess.get_file_as_string(COMMAND_HTML_PATH)
	
	var commands: Array[String] = []
	
	for command: DEV_Command in commands_by_id.values():
		var part := command_hbs\
				.replace("{{NAME}}", command.name)\
				.replace("{{DESCRIPTION}}", command.description)
		commands.append(part)
	
	var app_name := ProjectSettings.get_setting_with_override(&"application/config/name")
	
	var final := index_hbs\
			.replace("{{TITLE}}", app_name + " - DevTools")\
			.replace("{{COMMAND_COUNT}}", str(commands.size()))\
			.replace("{{APP_NAME}}", app_name)\
			.replace("{{COMMANDS}}", "\n".join(commands))
	
	DirAccess.make_dir_recursive_absolute(FINAL_HTML_PATH.get_base_dir())
	
	var file := FileAccess.open(FINAL_HTML_PATH, FileAccess.WRITE)
	file.store_string(final)
	file.flush()
	file.close()
	
	updated_html.emit.call_deferred()
