class_name ScreenData extends Node

static var num_screens=6

static var nil = -1
static var intro = 0 # The Xbox 360 intro video
static var movie = 1 # Video or Music. This takes up the entire screen and has controls
static var blades = 2
static var blades_maximized = 3
static var fullscreen_menu = 4
static var ingame = 5 # Entire dashboard is hidden, but some elements, like the guide and notifications, are still visible.
static var modified_time = FileAccess.get_modified_time("res://CFG/ScreenData.json")

static var Data = JSON.parse_string(FileAccess.get_file_as_string("res://CFG/ScreenData.json"))

static var formatters = {
	"Vector2": func(_data): 
		if _data is Array and _data.size()>=2 and _data[0] is float and _data[1] is float:
			return Vector2(_data[0],_data[1])
		else:
			return Vector2(1,1)
}


static func get_data(index: int, object: String, entry = "nil"):
	var _modified_time = FileAccess.get_modified_time("res://CFG/ScreenData.json") # If we get data and our file was modified, reload
	if modified_time != _modified_time:
		modified_time = _modified_time
		Data = JSON.parse_string(FileAccess.get_file_as_string("res://CFG/ScreenData.json"))
	var screen_data = Data["data"].get(Data["key"].get(str(index),"nil"))
	var object_data = screen_data.get(object,Data["data"]["nil"].get(object))
	if not entry == "nil":
		var entry_data = object_data.get(entry,Data["data"]["nil"][object][entry])
		return format_data(object,entry,entry_data)
	else:
		return object_data


static func format_data(object_type,entry_name,unformatted_data):
	return formatters.get(Data.get("format",{}).get(object_type,{}).get(entry_name, ""),func(_data): return _data).call(unformatted_data)
