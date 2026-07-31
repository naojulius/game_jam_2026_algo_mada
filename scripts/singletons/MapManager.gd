@tool
extends Node
var map: Node2D

func read_map_text(path: String) -> Array[String]:
	var map_lines: Array[String] = []

	if not FileAccess.file_exists(path):
		push_error("MapHelper: Le fichier n'existe pas -> " + path)
		return map_lines

	var file := FileAccess.open(path, FileAccess.READ)
	
	while not file.eof_reached():
		var line := file.get_line()
		if not line.is_empty():
			map_lines.append(line)
			
	file.close()
	return map_lines
