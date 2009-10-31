--[[
LuCI - Lua Configuration Interface

Copyright 2008 Steven Barth <steven@midlink.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
require("luci.tools.webadmin")
require("luci.model.uci")
require("luci.util")

m = Map("dhcp",
	translate("DHCP"),
	translate("With <abbr title=\"Dynamic Host Configuration Protocol\">DHCP</abbr> network " ..
		"members can automatically receive their network settings (<abbr title=" ..
		"\"Internet Protocol\">IP</abbr>-address, netmask, <abbr title=\"Domain Name " ..
		"System\">DNS</abbr>-server, ...)."))

s = m:section(TypedSection, "dhcp", "")
s.addremove = true
s.anonymous = true

iface = s:option(ListValue, "interface", translate("Interface"))
luci.tools.webadmin.cbi_add_networks(iface)

local uci = luci.model.uci.cursor()
uci:foreach("network", "interface",
	function (section)
		if section[".name"] ~= "loopback" then
			iface.default = iface.default or section[".name"]
			s:depends("interface", section[".name"])
		end
	end)

uci:foreach("network", "alias",
	function (section)
		iface:value(section[".name"])
		s:depends("interface", section[".name"])
	end)

s:option(Value, "start", translate("Start")).rmempty = true

s:option(Value, "limit", translate("Limit")).rmempty = true

s:option(Value, "leasetime", translate("Leasetime")).rmempty = true

local dd = s:option(Flag, "dynamicdhcp",
	translate("Dynamic <abbr title=\"Dynamic Host Configuration Protocol\">DHCP</abbr>"))

dd.rmempty = false
function dd.cfgvalue(self, section)
	return Flag.cfgvalue(self, section) or "1"
end

s:option(Value, "name", translate("Name")).optional = true

ignore = s:option(Flag, "ignore",
	translate("Ignore interface"),
	translate("disable <abbr title=\"Dynamic Host Configuration Protocol\">DHCP</abbr> for " ..
		"this interface"))

ignore.optional = true

s:option(Value, "netmask", translate("<abbr title=\"Internet Protocol Version 4\">IPv4</abbr>-Netmask")).optional = true

s:option(Flag, "force", translate("Force")).optional = true

s:option(DynamicList, "dhcp_option", translate("DHCP-Options")).optional = true


for i, n in ipairs(s.children) do
	if n ~= iface and n ~= ignore then
		n:depends("ignore", "")
	end
end

return m
