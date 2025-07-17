class_name BTWY_ComputeShader


static var _rd 	: RenderingDevice


var _uniform_buffers	:= Dictionary({},TYPE_INT,"",null,TYPE_RID,"",null)
var _uniform_set 	:= Dictionary({},TYPE_INT,"",null,TYPE_OBJECT,"RDUniform",null)
var _uniform_set_rid : RID


var _shader:RID
var _pipeline:RID


func _init(shader_file:RDShaderFile) -> void:
	if not _rd :
		_rd = RenderingServer.create_local_rendering_device()
	_shader = _rd.shader_create_from_spirv(shader_file.get_spirv())
	_pipeline = _rd.compute_pipeline_create(_shader)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# 1. 释放uniform缓冲区（遍历所有binding）
		for buf_rid in _uniform_buffers.values():
			if  _rd.framebuffer_is_valid(buf_rid):  # 检查资源有效性
				_rd.free_rid(buf_rid)
		_uniform_buffers.clear()  # 清空字典，避免残留引用

		# 2. 释放统一变量集
		if  _rd.uniform_set_is_valid(_uniform_set_rid):
			_rd.free_rid(_uniform_set_rid)
		_uniform_set_rid = RID()  # 重置为无效RID

		# 3. 释放计算管线
		if  _rd.compute_pipeline_is_valid(_pipeline):
			_rd.free_rid(_pipeline)
		_pipeline = RID()

		_rd.free_rid(_shader)
		_shader = RID()

		# 5. 释放RenderingDevice（仅当是本地创建的）
		if  _rd != RenderingServer.get_rendering_device():
			# 确认没有其他资源依赖此rd后再释放
			_rd.free()
		_rd = null  # 置空，避免后续误操作

func set_uniform(binding:int,data:PackedByteArray,size_bytes:int = 0):
	if _uniform_buffers.has(binding):
		_rd.free_rid(_uniform_buffers[binding])
	if size_bytes>0:
		_uniform_buffers[binding] = _rd.storage_buffer_create(size_bytes,data)
	else:
		_uniform_buffers[binding] = _rd.storage_buffer_create(data.size(),data)

	if not _uniform_set.has(binding):
		_uniform_set[binding] = RDUniform.new()
		_uniform_set[binding].binding = binding
		_uniform_set[binding].uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	else:
		_uniform_set[binding].clear_ids()
	_uniform_set[binding].add_id(_uniform_buffers[binding])

func update_uniform():
	if _rd.uniform_set_is_valid(_uniform_set_rid):
		_rd.free_rid(_uniform_set_rid)
	_uniform_set_rid = _rd.uniform_set_create(_uniform_set.values(),_shader,0)

func compute(workgroups_x:int=1,workgroups_y:int=1,workgroups_z:int=1) -> Dictionary:
	var compute_list := _rd.compute_list_begin()
	_rd.compute_list_bind_compute_pipeline(compute_list, _pipeline)
	_rd.compute_list_bind_uniform_set(compute_list, _uniform_set_rid, 0)
	_rd.compute_list_dispatch(compute_list, max(workgroups_x,1), max(workgroups_y,1), max(workgroups_z,1))
	_rd.compute_list_end()
	_rd.submit()
	#await RenderingServer.frame_post_draw
	_rd.sync()

	var output := Dictionary({},TYPE_INT,"",null,TYPE_PACKED_BYTE_ARRAY,"",null)
	for i in _uniform_buffers:
		output[i] = _rd.buffer_get_data(_uniform_buffers[i])
	return output
