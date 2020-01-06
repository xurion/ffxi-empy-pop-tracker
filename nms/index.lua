
local nms = {
  'alfard',
  'apademak',
  'azdaja',
  'briareus',
  'bukhis',
  'carabosse',
  'chloris',
  'cirein-croin',
  'dragua',
  'glavoid',
  'isgebind',
  'itzpapalotl',
  'kukulkan',
  'orthrus',
  'sedna',
  'sobek',
  'ulhuadshi'
}

nm_data = {}
for _, nm in pairs(nms) do
  nm_data[nm] = require('nms/' .. nm)
end

return nm_data
