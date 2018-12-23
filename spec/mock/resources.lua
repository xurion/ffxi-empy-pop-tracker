local key_items = {}

for i = 0, 10 do
	table.insert(key_items, {
		id = i,
		en = "Mock Key Item",
		ja = "モックキーアイテム",
		category = "Temporary Key Items"
	})
end

return { key_items = key_items }