module("luci.passwall.util_naiveproxy", package.seeall)
local api = require "luci.passwall.api"
local uci = api.uci
local jsonc = api.jsonc

function to_json(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- 注意：这里假定了所有的key都是字符串，所有的value要么是字符串，要么是数字
        result = result .. "\"" .. k .. "\":\"" .. v .. "\","
    end
    -- 去掉最后一个逗号，并添加闭合的大括号
    result = result:sub(1, -2) .. "}"
    return result
end

function gen_config(var)
	local node_id = var["-node"]
	if not node_id then
		print("-node 不能为空")
		return
	end
	local node = uci:get_all("passwall", node_id)
	local run_type = var["-run_type"]
	local local_addr = var["-local_addr"]
	local local_port = var["-local_port"]
	local server_host = var["-server_host"] or node.address
	local server_port = var["-server_port"] or node.port

	if api.is_ipv6(server_host) then
		server_host = api.get_ipv6_full(server_host)
	end
	local server = server_host .. ":" .. server_port

	local config = {
		listen = run_type .. "://" .. local_addr .. ":" .. local_port,
		proxy = node.protocol .. "://" .. node.username .. ":" .. node.password .. "@" .. server
	}

    return to_json(config)  -- 使用自定义的to_json函数来生成JSON字符串
end

_G.gen_config = gen_config

if arg[1] then
	local func =_G[arg[1]]
	if func then
		print(func(api.get_function_args(arg)))
	end
end
