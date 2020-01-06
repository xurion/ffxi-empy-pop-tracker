_addon.name = "Empyrean Weapon Tracker"
_addon.author = "Dean James (Xurion of Bismarck)"
_addon.commands = { "ewt", "empyreanweapontracker" }
_addon.version = "2.0.0"

res = require("resources")
nm_data = require("nms/index")

local EmpyreanWeaponTracker = {}

local defaults = {}
defaults.text = {}
defaults.text.pos = {}
defaults.text.pos.x = 0
defaults.text.pos.y = 0
defaults.text.bg = {}
defaults.text.bg.alpha = 150
defaults.text.bg.blue = 0
defaults.text.bg.green = 0
defaults.text.bg.red = 0
defaults.text.bg.visible = true
defaults.text.bg.visible = true
defaults.text.padding = 8
defaults.text.text = {}
defaults.text.text.font = "Consolas"
defaults.text.text.size = 10
defaults.tracking = "briareus"

EmpyreanWeaponTracker.settings = require("config").load(defaults)
EmpyreanWeaponTracker.text = require("texts").new(EmpyreanWeaponTracker.settings.text, EmpyreanWeaponTracker.settings)

colors = {}
colors.success = "\\cs(100,255,100)"
colors.warning = "\\cs(255,170,0)"
colors.danger = "\\cs(255,50,50)"
colors.normal = "\\cs(255,255,255)"
colors.close = "\\cr"

function owns_item(id, items)
  local owned = false

  for _, item_id in pairs(items) do
    if item_id == id then
      owned = true
      break
    end
  end

  return owned
end

function ucwords(str)
  return string.gsub(" " .. str, "%W%l", string.upper):sub(2)
end

function get_indent(depth)
  return string.rep("  ", depth)
end

function generate_text(data, depth)
  local text = depth == 1 and data.name .. "\n" or ""
  for _, pop in pairs(data.pops) do
    local ki_resource = res.key_items[pop.id]
    local pop_ki_name = 'Unknown KI'
    if ki_resource then
      pop_ki_name = ucwords(ki_resource.en)
    end

    text = text .. "\n" .. pop.dropped_from.name .. "\n" .. get_indent(depth) .. pop_ki_name
    if pop.dropped_from.pops then
      text = text .. generate_text(pop.dropped_from, depth + 1)
    end
  end
  return text
end

EmpyreanWeaponTracker.add_to_chat = function(message)
  if type(message) ~= 'string' then
    error('add_to_chat requires the message arg to be a string')
  end

  windower.add_to_chat(8, message)
end

EmpyreanWeaponTracker.generate_info = function(nm, key_items, items)
  local nm_type = type(nm)
  if nm_type ~= 'table' then
    error('generate_info requires the nm arg to be a table, but got ' .. nm_type .. ' instead')
  end

  local info = {
    has_all_kis = true,
    text = ""
  }

  if nm.pops then
    for _, key_item_data in pairs(nm.pops) do
      local has_pop_ki = owns_item(key_item_data.id, key_items)

      if not has_pop_ki then
        info.has_all_kis = false
      end

      info.text = generate_text(nm, 1)
    end
  end

  return info
end

function find_nms(query)
  local matching_nms = {}
  local lower_query = query:lower()
  for _, nm in pairs(nm_data) do
    local result = string.match(nm.name, '(.*' .. lower_query .. '.*)')
    if result then
      table.insert(matching_nms, result)
    end
  end
  return matching_nms
end

windower.register_event("addon command", function(command, ...)
  if commands[command] then
    commands[command](...)
  else
    commands.help()
  end
end)

local commands = {}

commands.track = function(...)
  local args = {...}
  local nm_name = args[1]
  local matching_nm_names = find_nms(nm_name)

  if #matching_file_names == 0 then
    EmpyreanWeaponTracker.add_to_chat('Unable to find a NM using: "' .. nm_name .. '"')
  elseif #matching_file_names > 1 then
    EmpyreanWeaponTracker.add_to_chat('"' .. nm_name .. '" matches ' .. #matching_file_names .. ' NMs. Please be more explicit:')
    for key, matching_file_name in pairs(matching_file_names) do
      EmpyreanWeaponTracker.add_to_chat('  Match ' .. key .. ': ' .. ucwords(matching_file_name))
    end
  else
    EmpyreanWeaponTracker.add_to_chat("Now tracking: " .. ucwords(matching_file_names[1]))
    EmpyreanWeaponTracker.settings.tracking = matching_file_names[1]
  end
end

commands.help = function()
  EmpyreanWeaponTracker.add_to_chat("---Empyrean Weapon Tracker---")
  EmpyreanWeaponTracker.add_to_chat("Trackable NMs:")
  for _, nm in pairs(nm_data) do
    EmpyreanWeaponTracker.add_to_chat(ucwords(nm.name))
  end
  EmpyreanWeaponTracker.add_to_chat("")
  EmpyreanWeaponTracker.add_to_chat("Available commands:")
  EmpyreanWeaponTracker.add_to_chat("//" .. _addon.commands[1] .. " track briareus - tracks Briareus pops. You can also supply partial names such as bri")
  EmpyreanWeaponTracker.add_to_chat("//" .. _addon.commands[1] .. " help - displays this help")
end

EmpyreanWeaponTracker.update = function()
  local key_items = windower.ffxi.get_key_items()
  local inventory = windower.ffxi.get_items().inventory
  local tracked_nm_data = nm_data[EmpyreanWeaponTracker.settings.tracking]
  local generated_info = EmpyreanWeaponTracker.generate_info(tracked_nm_data, key_items, inventory)
  EmpyreanWeaponTracker.text:update(generated_info.text)
  if generated_info.has_all_kis then
    EmpyreanWeaponTracker.text:bg_color(0, 75, 0)
  else
    EmpyreanWeaponTracker.text:bg_color(0, 0, 0)
  end
  EmpyreanWeaponTracker.text:visible(true)
end

windower.register_event('load', 'incoming text', 'remove item', function()
  EmpyreanWeaponTracker.update()
end)

return EmpyreanWeaponTracker
