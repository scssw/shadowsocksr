#!/usr/bin/env python3
# -*- coding: UTF-8 -*-

import sys

def load(name):
	try:
		if sys.version_info[0] == 2:
			import imp
			return imp.load_source(name, name + '.py')
		elif sys.version_info[0] == 3:
			import importlib.util
			spec = importlib.util.spec_from_file_location(name, name + '.py')
			module = importlib.util.module_from_spec(spec)
			spec.loader.exec_module(module)
			return module
	except:
		pass

	try:
		import importlib
		return importlib.import_module(name)
	except:
		pass

	return None

def loads(namelist):
	for name in namelist:
		obj = load(name)
		if obj is not None:
			return obj
