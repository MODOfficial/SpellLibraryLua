function GetDirectoryFromPath(path)
	return path:match("(.*[/\\])")
end

function ModuleRequire(path,file)
	return require(GetDirectoryFromPath(path) .. file)
end