_addon.name = 'Briareus'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.command = 'briareus'
_addon.version = '1.0.0'

texts = require('texts')

local defaults = {
	pos = {
		x = 0,
		y = 0
	}
}

settings = defaults

local text_box = texts.new(settings)

windower.register_event('load', 'login', 'add item', 'remove item', function()

  local inventory = windower.ffxi.get_items().inventory
  local pop_items = get_pop_items_from_inventory(inventory)
  regenerate_text(pop_items, currency, inventory_counts)
end)

function get_pop_items_from_inventory(inventory)
  local shield = false
  local sock = false
  local armband = false

  for _,item in pairs(inventory) do
    if type(item) == "table" then
      if item.id == 2894 then
        shield = true
      elseif item.id == 2895 then
        sock = true
      elseif item.id == 2896 then
        armband = true
      end
    end
  end

  return {
    shield = shield,
    sock = sock,
    armband = armband
  }
end

function regenerate_text(pop_items)
  local success = '\\cs(0,255,0)'
  local warning = '\\cs(255,170,0)'
  local danger = '\\cs(255,0,0)'
  local normal = '\\cs(255,255,255)'

  local shield_text = 'Trophy Shield'
  local sock_text = 'Oversized Sock'
  local armband_text = 'Massive Armband'

  if pop_items.shield then
    shield_text = success .. shield_text .. '\\cr'
  else
    shield_text = danger .. shield_text .. '\\cr'
  end

  if pop_items.sock then
    sock_text = success .. sock_text .. '\\cr'
  else
    sock_text = danger .. sock_text .. '\\cr'
  end

  if pop_items.armband then
    armband_text = success .. armband_text .. '\\cr'
  else
    armband_text = danger .. armband_text .. '\\cr'
  end

  local text = _addon.name .. '\n\n' ..
    shield_text .. '\n' ..
    sock_text .. '\n' ..
    armband_text .. '\n'

	text_box:text(text)
	text_box:visible(true)
end
