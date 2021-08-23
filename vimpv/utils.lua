local U = {}
U.__index = U

function U:remove_suffix(filename) return filename:gsub('%.%w+$', '') end


return U
