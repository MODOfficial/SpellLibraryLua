
if GameMode == nil then
	GameMode = class({})
end


require('util/util');
require('events');
require('filter');
require('modules/index');
function GameMode:InitGameMode()
    GameMode:ActivateFilters()
    InitModules()
end