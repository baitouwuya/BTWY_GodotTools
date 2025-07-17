#============================================================
#    Hash Set
#============================================================
# - author: zhangxuetu
# - datetime: 2023-05-25 10:09:55
# - version: 4.0
#============================================================
## 集合
class_name HashSet


var _data : Dictionary = {}
var _current : int = 0


#============================================================
#  内置
#============================================================
func _init(values = []):
	merge(values)


#func _get(property):
#	if str(property).is_valid_int():
#		return _data.keys()[str(property).to_int()]

func _to_string():
	return str(_data.keys())


#============================================================
#  迭代器
#============================================================
func _iter_init(arg):
	_current = 0
	return _current < _data.size()

func _iter_next(arg):
	_current += 1
	return _current < _data.size()

func _iter_get(arg):
	return _data.keys()[_current]


#============================================================
#  自定义
#============================================================
func append(value) -> void:
	_data[value] = null

func append_array(values) -> void:
	for value in values:
		_data[value] = null

func earse(value) -> bool:
	return _data.erase(value)

func remove(idx: int) -> bool:
	assert(idx < _data.size(), "idx 值超出索引")
	var key = _data.keys()[idx]
	return _data.erase(key)

func has(value) -> bool:
	return _data.has(value)

func has_all(values) -> bool:
	if values is HashSet:
		return _data.has_all(values.to_array())
	elif values is Array:
		return _data.has_all(values)
	return false

func to_array() -> Array:
	return _data.keys()

func size() -> int:
	return _data.size()

func is_empty() -> bool:
	return _data.is_empty()

func clear() -> void:
	_data.clear()

func duplicate(deep: bool = false) -> HashSet:
	return HashSet.new(_data.keys())

func merge(values) -> void:
	for i in values:
		_data[i] = null

func hash() -> int:
	return _data.keys().hash()


#============================================================
#  集合操作
#============================================================
## 是否相同
func equals(hash_set: HashSet) -> bool:
	return self.hash() == hash_set.hash()


## 并集。两个集合中的所有的元素合并后的集合
func union(hash_set: HashSet) -> HashSet:
	var tmp = HashSet.new(_data.keys())
	tmp.merge(hash_set)
	return tmp


## 交集。两个集合中都存在的元素的集合
func intersection(hash_set: HashSet) -> HashSet:
	var list = []
	var tmp = HashSet.new(self.to_array())
	tmp.append_array(hash_set.to_array())
	for item in tmp:
		if has(item) and hash_set.has(item):
			list.append(item)
	return HashSet.new(list)


## 差集。两个集合之间存在有不相同的元素的集合
func difference(hash_set: HashSet) -> HashSet:
	var list = []
	var tmp = HashSet.new(self.to_array())
	tmp.append_array(hash_set.to_array())
	for item in tmp:
		if not has(item) or not hash_set.has(item):
			list.append(item)
	return HashSet.new(list)


## 补集/余集。a 集合中不在此集合的元素的集合
func complementary(a: HashSet) -> HashSet:
	var list = []
	if self.has_all(a):
		for item in _data:
			if not a.has(item):
				list.append(item)
	else:
		assert(false, "参数 a 集合不是当前集合的子集")
	return HashSet.new(list)


## 减去集合中的元素后的集合
func subtraction(hash_set: HashSet) -> HashSet:
	var list = []
	for item in _data.keys():
		if not hash_set.has(item):
			list.append(item)
	return HashSet.new(list)
