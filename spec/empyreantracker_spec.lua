-- Empyrean Tracker Unit tests

package.path = "./?.lua;./spec/mock/?.lua"

local match = require("luassert.match")

-- Include mock libs
config = require("config")
texts = require("texts")
resources = nil

describe("Empyrean Tracker", function()
	local get_addon = function()
		package.loaded["empyreantracker"] = nil
		return require("empyreantracker")
	end

	local sent_chats
	local registered_events
	local nm_data

	local trigger_event = function(event, ...)
		for _, v in pairs(registered_events[event]) do
			v(...)
		end
	end

	before_each(function()
		_G._addon = {}
		package.loaded.empyreantracker = nil
		package.loaded.resources = nil
		resources = require("resources")
		registered_events = {}
		sent_chats = {}
		_G.windower = {}
		_G.windower.register_event = function(event, ...)
			if registered_events[event] then
				table.insert(registered_events, ...)
			else
				registered_events[event] = { ... }
			end
		end
		_G.windower.add_to_chat = function(mode, text)
			table.insert(sent_chats, { mode, text })
		end
		nm_data = {
			name = "Mock NM",
			pops = { {
				id = 1,
				type = "key item",
				dropped_from = {
					name = "Mock Sub NM",
					pops = { {
						id = 1,
						type = "item",
						dropped_from = { name = "Jaculus (Timed, 10-15 mins, (I-8/I-9))" }
					}, {
						id = 2,
						type = "item",
						dropped_from = {
							name = "Minaruja (Forced, (I-9))",
							pops = { {
								id = 3,
								type = "item",
								dropped_from = { name = "Faunus Wyvern (I-9/I-10)" }
							} }
						} 
					} }
				}
			} }
		}
	end)

	it("sets the _addon name to Empyrean Tracker", function()
		get_addon()

		assert.is.equal("Empyrean Tracker", _G._addon.name)
	end)

	it("sets the _addon author as Dean James (Xurion of Bismarck)", function()
		get_addon()

		assert.is.equal("Dean James (Xurion of Bismarck)", _G._addon.author)
	end)

	it("sets the available _addon commands to be empyreantracker, empytracker and empy", function()
		get_addon()

		assert.are.same({ "empyreantracker", "empytracker", "empy" }, _G._addon.commands)
	end)

	it("sets the _addon version", function()
		get_addon()

		assert.is.truthy(_G._addon.version)
	end)

	it("creates/loads settings from the config and passes the text config it to a new instance of text", function()
		local config_data = {
			text = "text config",
			other = "other config"
		}
		stub(config, "load", config_data)
		spy.on(texts, "new")

		get_addon()

		assert.stub(config.load).was.called(1)
		assert.spy(texts.new).was.called_with(config_data.text, config_data)
	end)

	it("sets a default text x and y setting of 0", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(0, config.load.calls[1].vals[1].text.pos.x)
		assert.are.same(0, config.load.calls[1].vals[1].text.pos.y)
	end)

	it("sets a default text alpha background setting of 150", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(150, config.load.calls[1].vals[1].text.bg.alpha)
	end)

	it("sets default text rgb background settings to black (0, 0, 0)", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(0, config.load.calls[1].vals[1].text.bg.blue)
		assert.are.same(0, config.load.calls[1].vals[1].text.bg.green)
		assert.are.same(0, config.load.calls[1].vals[1].text.bg.red)
	end)

	it("sets a default text visible background setting to true", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(true, config.load.calls[1].vals[1].text.bg.visible)
	end)

	it("sets a default text padding setting to 8", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(8, config.load.calls[1].vals[1].text.padding)
	end)

	it("sets a default text font setting to Consolas", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same("Consolas", config.load.calls[1].vals[1].text.text.font)
	end)

	it("sets a default text size setting to 10", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same(10, config.load.calls[1].vals[1].text.text.size)
	end)

	it("sets a default tracking setting to briareus", function()
		spy.on(config, "load")

		get_addon()

		assert.are.same("briareus", config.load.calls[1].vals[1].tracking)
	end)

	describe("generate_info(nm, key_items, items)", function()
		it("throws an error if the nm arg is not a table", function()
			local addon = get_addon()

			assert.has_error(function()
				addon.generate_info(nil, {}, {})
			end, "generate_info requires the nm arg to be a table")
		end)

		it("returns a table with a has_all_kis property set to false when the key_items arg does not contain all of the entries of the nm arg", function()
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = 'a' }
			}, {
				id = 2,
				dropped_from = { name = 'b' }
			}, {
				id = 3,
				dropped_from = { name = 'c' }
			}}
			local key_items = { 1, 3 } --missing KI 2

			local result = addon.generate_info(nm_data, key_items, {})

			assert.equal(false, result.has_all_kis)
		end)

		it("returns a table with a has_all_kis property set to true when the key_items arg contains all of the entries of the nm arg", function()
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = 'a' }
			}, {
				id = 2,
				dropped_from = { name = 'b' }
			}, {
				id = 3,
				dropped_from = { name = 'c' }
			}}
			local key_items = { 1, 2, 3 }

			local result = addon.generate_info(nm_data, key_items, {})

			assert.equal(true, result.has_all_kis)
		end)

		it("returns a table with a text property that starts with the name from the nm arg", function()
			local addon = get_addon()
			local key_items = {}
			nm_data.name = "Bennu"

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Bennu", lines[1])
		end)

		it("returns a table with a text property that contains a spacer line followed by the name of the nm that drops the key item in the nm arg", function()
			local addon = get_addon()
			nm_data.pops[1].dropped_from = { name = "Sub Mob" }

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("", lines[2])
			assert.equal("Sub Mob", lines[3])
		end)

		it("returns a table with a text property that contains the name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "Bennu Pop KI"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "Bennu Sub NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Bennu Pop KI", strip_indent_from_string(lines[4]))
		end)

		it("returns a table with a text property that contains the capitalised name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "the pop key item"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("The Pop Key Item", strip_indent_from_string(lines[4]))
		end)

		it("returns a table with a text property that contains the indented name of the key item the nm drops in the nm arg", function()
			resources.key_items[1].en = "Indented Pop KI"
			local addon = get_addon()
			nm_data.pops = {{
				id = 1,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			local indent = get_indent_from_string(lines[4])
			assert.equal(2, #indent)
		end)

		it('returns a table with a text property that contains the name of the key item as "Unknown KI" if the KI ID is not found in Windower Resources', function()
			resources.key_items[10] = nil
			local addon = get_addon()
			nm_data.pops = {{
				id = 10,
				dropped_from = { name = "NM" }
			}}

			local result = addon.generate_info(nm_data, {}, {})

			local lines = get_lines_from_string(result.text)
			assert.equal("Unknown KI", strip_indent_from_string(lines[4]))
		end)
	end)

	describe("list command", function()
		it('sends "Trackable NMs:" as the first chat in chat mode 8', function()
			local addon = get_addon()
			local files = { "nm.lua" }
			stub(io, "popen", function(arg)
				return files
			end)

			trigger_event("addon command", "list")

			assert.is.equal(8, sent_chats[1][1])
			assert.is.equal("Trackable NMs:", sent_chats[1][2])
		end)

		it("lists the files in the nms directory with capitalised first letter and no file extension", function()
			local addon = get_addon()
			local files = { "nm.lua", "another.lua" }

			stub(io, "popen", function(arg)
				if arg == "nms" then
					return files
				else
					return {}
				end
			end)

			trigger_event("addon command", "list")

			assert.is.equal(8, sent_chats[2][1])
			assert.is.equal("Nm", sent_chats[2][2])
			assert.is.equal(8, sent_chats[3][1])
			assert.is.equal("Another", sent_chats[3][2])
		end)

		it("lists the files in the nms directory with capitalised first letter and no file extension", function()
			local addon = get_addon()
			local files = { "nm.lua", "another-nm.lua" }

			stub(io, "popen", function(arg)
				if arg == "nms" then
					return files
				else
					return {}
				end
			end)

			trigger_event("addon command", "list")

			assert.is.equal(8, sent_chats[2][1])
			assert.is.equal("Nm", sent_chats[2][2])
			assert.is.equal(8, sent_chats[3][1])
			assert.is.equal("Another Nm", sent_chats[3][2])
		end)

		it("does not list files in the nms directory that are not .lua", function()
			local addon = get_addon()
			local files = { "nm.txt", "another-nm.lua", "third-nm" }

			stub(io, "popen", function(arg)
				if arg == "nms" then
					return files
				else
					return {}
				end
			end)

			trigger_event("addon command", "list")

			assert.is.equal("Another Nm", sent_chats[2][2])
			assert.is_nil(sent_chats[3])
		end)
	end)
end)

function get_lines_from_string(str)
	local lines = {}
	for line in str:gmatch("([^\r\n]*)") do
		table.insert(lines, line)
	end
	return lines
end

function get_indent_from_string(str)
	return str:match("^(%s*)")
end

function strip_indent_from_string(str) 
	return str:match("^%s*(.+)")
end

function print_r(t)
	local print_r_cache = {}
	local function sub_print_r(t, indent)
		if print_r_cache[tostring(t)] then
			print(indent .. "*" .. tostring(t))
		else
			print_r_cache[tostring(t)] = true
			if (type(t) == "table") then
				for pos, val in pairs(t) do
					if (type(val) == "table") then
						print(
							indent .. "[" .. pos .. "] => " .. tostring(
								t
							) .. " {"
						)
						sub_print_r(
							val,
							indent .. string.rep(" ", string.len(pos) + 8)
						)
						print(
							indent .. string.rep(
								" ",
								string.len(pos) + 6
							) .. "}"
						)
					elseif (type(val) == "string") then
						print(indent .. "[" .. pos .. '] => "' .. val .. '"')
					else
						print(indent .. "[" .. pos .. "] => " .. tostring(val))
					end
				end
			else
				print(indent .. tostring(t))
			end
		end
	end

	if (type(t) == "table") then
		print(tostring(t) .. " {")
		sub_print_r(t, "  ")
		print("}")
	else
		sub_print_r(t, "  ")
	end
	print()
end
