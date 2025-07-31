
import json

def space_str(layer):
	spaces = ""
	for i in range(0, layer):
		spaces += '\t'
	return spaces

def dic_to_lua_str(data, prettyPrint=True, layer = 0):
	result = []
	if  isinstance(data, str):
		result.append("\"" + data + "\"")
	elif isinstance(data, bool):
		if data:
			result.append('true')
		else:
			result.append('false')
	elif isinstance(data, int) or isinstance(data, float):
		result.append(str(data))
	elif isinstance(data, list):
		result.append('{')
		if prettyPrint:
			result.append('\n')
			result.append(space_str(layer + 1))
		for i in range(0, len(data)):
			for sub in  dic_to_lua_str(data[i], prettyPrint, layer + 1):
				result.append(sub)
			if i < len(data) - 1:
				result.append(',')
		if prettyPrint:
			result.append('\n')
			result.append(space_str(layer))
		result.append('}')
	elif isinstance(data, dict):
		if prettyPrint:
			result.append('\n')
			result.append(space_str(layer))
		result.append('{')
		if prettyPrint:
			result.append('\n')
		data_len = len(data)
		data_count = 0
		for k,v in data.items():
			data_count += 1
			if prettyPrint:
				result.append(space_str(layer + 1))
			if isinstance(k, int):
				result.append('[' + str(k) + ']')
			else:
				result.append('["' + k + '"]') 
			result.append(' = ' if prettyPrint else '=')
			try:
				for sub in  dic_to_lua_str(v, prettyPrint, layer + 1):
					result.append(sub)
				if data_count < data_len:
					result.append(',')
					if prettyPrint:
						result.append('\n')

			except Exception as e:
				print('error in ', k, v)
				raise
		if prettyPrint:
			result.append('\n')
			result.append(space_str(layer))
		result.append('}')
	else:
		raise (type(data), 'is error')
	
	return result
