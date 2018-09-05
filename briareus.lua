_addon.name = 'Briareus'
_addon.author = 'Dean James (Xurion of Bismarck)'
_addon.command = 'briareus'
_addon.version = '1.0.0'

texts = require('texts')
config = require('config')

local defaults = {
	pos = {
		x = 0,
		y = 0
	},
	text = {
		font = 'Consolas',
		size = 10
	}
}

settings = config.load(defaults)
local text_box = texts.new(settings)

windower.register_event('load', 'incoming text', 'remove item', function()

  local inventory = windower.ffxi.get_items().inventory
  local key_items = windower.ffxi.get_key_items()
  local pop_items = get_pop_items_from_inventory(inventory)
  local pop_key_items = get_pop_items_from_key_items(key_items)
  regenerate_text(pop_items, pop_key_items)
end)

function get_pop_items_from_key_items(key_items)
	local shield = false
	local armband = false
  local collar = false
  for _,item_id in pairs(key_items) do
    if item_id == 1482 then
      shield = true
    elseif item_id == 1483 then
      armband = true
    elseif item_id == 1484 then
      collar = true
    end
  end

  return {
    shield = shield,
    armband = armband,
    collar = collar
  }
end

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

function regenerate_text(pop_items, pop_key_items)
  local success = '\\cs(0,255,0)'
  local warning = '\\cs(255,170,0)'
  local danger = '\\cs(255,0,0)'
  local normal = '\\cs(255,255,255)'

  local shield_item_text = 'Trophy Shield'
	local shield_key_item_text = 'Dented Gigas Shield'

  local sock_item_text = 'Oversized Sock'
	local armband_key_item_text = 'Warped Gigas Armband'

  local armband_item_text = 'Massive Armband'
	local collar_key_item_text = 'Severed Gigas Collar'

  if pop_items.shield then
    shield_item_text = success .. shield_item_text .. '\\cr'
  else
    shield_item_text = danger .. shield_item_text .. '\\cr'
  end

	if pop_key_items.shield then
    shield_key_item_text = success .. shield_key_item_text .. '\\cr'
  else
    shield_key_item_text = danger .. shield_key_item_text .. '\\cr'
  end

  if pop_items.sock then
    sock_item_text = success .. sock_item_text .. '\\cr'
  else
    sock_item_text = danger .. sock_item_text .. '\\cr'
  end

	if pop_key_items.armband then
    armband_key_item_text = success .. armband_key_item_text .. '\\cr'
  else
    armband_key_item_text = danger .. armband_key_item_text .. '\\cr'
  end

  if pop_items.armband then
    armband_item_text = success .. armband_item_text .. '\\cr'
  else
    armband_item_text = danger .. armband_item_text .. '\\cr'
  end

	if pop_key_items.collar then
    collar_key_item_text = success .. collar_key_item_text .. '\\cr'
  else
    collar_key_item_text = danger .. collar_key_item_text .. '\\cr'
  end

  local text = _addon.name .. '\n\n' ..
		'Adamastor (North)' .. '\n' ..
		'  ' .. shield_item_text .. ' > ' .. shield_key_item_text .. '\n\n' ..
	  'Grandgousier (South)' .. '\n' ..
    '  ' .. armband_item_text .. ' > ' .. collar_key_item_text .. '\n\n' ..
		'Pantagruel (East)' .. '\n' ..
    '  ' .. sock_item_text .. ' > ' .. armband_key_item_text

	text_box:text(text)
	text_box:visible(true)
end
