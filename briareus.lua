_addon.name = "Briareus"
_addon.author = "Dean James (Xurion of Bismarck)"
_addon.command = "briareus"
_addon.version = "1.0.0"

texts = require("texts")
config = require("config")
res = require("resources")
file = require("files")

local defaults = {
  text = {
    pos = {
      x = 0,
      y = 0
    },
    bg = {
      alpha = 150,
      blue = 0,
      green = 0,
      red = 0,
      visible = true
    },
    padding = 8,
    text = {
      font = "Consolas",
      size = 10
    }
  },
  tracking = "briareus"
}

settings = config.load(defaults)
text_box = texts.new(settings.text, settings)

color = {}
color.success = "\\cs(100,255,100)"
color.warning = "\\cs(255,170,0)"
color.danger = "\\cs(255,50,50)"
color.normal = "\\cs(255,255,255)"
color.close = "\\cr"

tracking = settings.tracking
tracking_file = nil
tracking_nm_data = nil

function load_tracking_data(nm)
  if package.loaded[tracking_file] then
    package.loaded[tracking_file] = nil
  end
  tracking_file = "nms/" .. nm
  tracking_nm_data = require(tracking_file)
end

load_tracking_data(tracking)

windower.register_event(
  "load",
  "incoming text",
  "remove item",
  function()
    if tracking then
      local items = windower.ffxi.get_items().inventory
      local key_items = windower.ffxi.get_key_items()
      regenerate_text(items, key_items)
    end
  end
)

windower.register_event(
  "addon command",
  function(command, arg)
    if command == "track" and arg then
      if not file.exists("nms/" .. arg .. ".lua") then
        print("Unknown NM: " .. arg)
      else
        tracking = arg
        settings.tracking = arg
        load_tracking_data(tracking)
        config.save(settings)
      end
    end
  end
)

function set_text_bg(has_all_kis)
  if has_all_kis then
    text_box:bg_color(0, 75, 0)
  else
    text_box:bg_color(0, 0, 0)
  end
end

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

function regenerate_text(items, key_items)
  local text = ucwords(tracking)
  local has_all_kis = true
  for _, key_item_data in pairs(tracking_nm_data.data) do
    local pop_ki_name = ucwords(res.key_items[key_item_data.id].en)
    local has_pop_ki = owns_item(key_item_data.id, key_items)
    local pop_ki_color = color.success
    local mob_data = key_item_data.from
    local pop_items = {}
    local indent = "  "

    if mob_data.pop_items then
      for _, pop_item in pairs(mob_data.pop_items) do
        table.insert(
          pop_items,
          {
            en = res.items[pop_item].en,
            owned = owns_item(pop_item, items)
          }
        )
      end
    end

    if not has_pop_ki then
      pop_ki_color = color.danger
      has_all_kis = false
    end

    text = text .. "\n\n" .. mob_data.name
    for _, pop_item in pairs(pop_items) do
      local pop_item_color = color.danger
      if pop_item.owned then
        pop_item_color = color.success
      end
      text = text .. "\n" .. indent .. pop_item_color .. pop_item.en .. color.close
    end
    if #pop_items > 0 then
      indent = indent .. indent
    end
    text = text .. "\n" .. indent .. pop_ki_color .. pop_ki_name .. color.close
  end

  set_text_bg(has_all_kis)
  text_box:text(text)
  text_box:visible(true)
end
