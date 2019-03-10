mob_data = {
	name = "Alfard",
	pops = { {
		id = 1530, --Venomous hydra fang
		dropped_from = {
			name = "Ningishzida (Forced, (I-7/I-8))",
			pops = { {
				id = 3262, --Jaculus Wing
				dropped_from = {
					name = "Jaculus (Timed, 10-15 mins, (I-8/I-9))"
				}
			}, {
				id = 3261, --Minaruja Skull
				dropped_from = {
					name = "Minaruja (Forced, (I-9))",
					pops = { {
						id = 3267, --Pursuer's Wing
						dropped_from = { name = "Faunus Wyvern (I-9/I-10)" }
					} }
				}
			}, {
				id = 3268, --High-Quality Wivre Hide
				dropped_from = { name = "Glade Wivre (I-8/J-7)" }
			} }
		}
	} }
}

function get_indent(depth)
	return string.rep("  ", depth)
end

function generate(data, depth)
	local text = depth == 1 and data.name .. "\n" or ""
	for _, pop in pairs(data.pops) do
		text =
			text .. "\n" .. get_indent(
				depth
			) .. "Popped with " .. pop.id .. " from " .. pop.dropped_from.name .. "\n"
		if pop.dropped_from.pops then
			text = text .. generate(pop.dropped_from, depth + 1)
		end
	end
	return text
end

--windower.register_event('load', function()
--print(generate(mob_data, 1))
--end

print(generate(mob_data, 1))