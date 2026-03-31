extends CanvasLayer

func clear_map() -> void:
	# Delete all rooms
	pass

func set_map(floor_graph: Array) -> void:
	# Create and place rooms
	for x in range(len(floor_graph)):
		for y in range(len(floor_graph[x])):
			var room: RoomNode = floor_graph[x][y]
			if room == null:
				continue

			var room_pos = Vector2i(room.position.x * 32 + room.position.x * 4, room.position.y * 18 + room.position.y * 4)

			var room_rect: ColorRect = ColorRect.new()
			room_rect.size = Vector2(32, 18)
			room_rect.position = room_pos
			match room.room_type:
				Enums.RoomType.ENTRY:
					room_rect.color = Color.DARK_GREEN
				Enums.RoomType.COMBAT:
					room_rect.color = Color.INDIAN_RED
				Enums.RoomType.BOSS:
					room_rect.color = Color.DARK_RED
				Enums.RoomType.SHOP:
					room_rect.color = Color.BLUE
				Enums.RoomType.CAMP:
					room_rect.color = Color.DARK_ORANGE
				Enums.RoomType.TREASURE:
					room_rect.color = Color.GOLD
				Enums.RoomType.EMPTY:
					room_rect.color = Color.GRAY
			
			get_node("Control/Rooms").add_child(room_rect)

			for con in room.connections:
				var con_rect: ColorRect = ColorRect.new()
				con_rect.size = Vector2(4, 4)
				con_rect.color = Color.SLATE_GRAY
				
				match con:
					Enums.ExitDirection.NORTH:
						con_rect.position = Vector2(room_pos.x + 14, room_pos.y + 18)
					Enums.ExitDirection.WEST:
						con_rect.position = Vector2(room_pos.x + 32, room_pos.y + 7)
					Enums.ExitDirection.SOUTH:
						con_rect.position = Vector2(room_pos.x + 14, room_pos.y - 4)
					Enums.ExitDirection.EAST:
						con_rect.position = Vector2(room_pos.x - 4, room_pos.y + 7)

				get_node("Control/Connections").add_child(con_rect)
