extends TileMapLayer
class_name BTWY_TileMapLayer

func set_cells_by_array(cells_array:Array[Vector2i]):
	var new_tile_map_data := PackedByteArray([0,0])
	for c in cells_array:
		new_tile_map_data.append_array(cell_to_byte(c))
	set("tile_map_data",new_tile_map_data)

func cell_to_byte(coors:Vector2i)->PackedByteArray:
	var result:PackedByteArray
	var coors_:Vector2i
	coors_.x = coors.x if coors.x>=0 else 256*256 + coors.x
	coors_.y = coors.y if coors.y>=0 else 256*256 + coors.y
	return [\
	coors_.x%256,coors_.x/256 , coors_.y%256,coors_.y/256,\
	0,0,\
	0,0 , 0,0,\
	0,0]
