--[[
Autorzy kodu:
	- Jurandovsky
	- Brzysiek

Zasób odpowiadający za pracę rozwożenia betonu do wyznaczonych przez kod punktów.

Aby zasób działał poprawnie, muszą być uruchomione zasoby takie jak:
	- 3d text
	- notifications
również naszego autorstwa.

Dziękujemy za mile spędzony z Wami czas, zapraszamy ponownie do skorzystania z naszych linii lotniczych.
--]]

----------------------------------------------
-- Ustawienia zarobków 
local DIST_MULTIPLIER = 0.2 -- mnożnik dystansu od punktu załadunku do rozładunku. Z tego wyliczany jest zarobek.
----------------------------------------------

local workStart = createMarker(-1016.90192, -695.13550, 32.00781-0.9, "cylinder", 1.3, 255, 255, 255, 100)
createBlipAttachedTo(workStart, 52)
local wsText = createElement("3dtext")
setElementPosition(wsText, -1016.90192, -695.13550, 32.00781)
setElementData(wsText, "text", "Praca dorywcza: kierowca betoniarki")

local workEnd = createMarker(-1013.66254, -695.12909, 32.0078-0.9, "cylinder", 1.3, 155,0,195, 128)
local weText = createElement("3dtext")
setElementPosition(weText, -1013.66254, -695.12909, 32.0078)
setElementData(weText, "text", "Zakończ pracę")

local colshape = createColSphere(-991.85449, -691.92145, 32.00781, 2)

local vehicles = {}

local targetPositions = {
{-1024.07251, -684.28210, 32.00781},
{-1030.07251, -684.28210, 32.00781}, -- od tego punktu liczymy wynagrodzenie
{-1036.07251, -684.28210, 32.00781}
}

for _, position in ipairs(targetPositions) do
	local text = createElement("3dtext")
	setElementPosition(text, position[1], position[2], position[3])
	setElementData(text, "text", "Załadunek betonu")
	
	loadConcreteMarker = createMarker(position[1], position[2], position[3]-1.2, "cylinder", 4, 255,255,255,100)
	setElementData(loadConcreteMarker, "loadConcrete", true)
end

function startLoading(player)
	local vehicle = getPedOccupiedVehicle(player)
	local rx, ry, rz = getElementRotation(vehicle)
	if (rz > 0 and rz < 20) or (rz > 340 and rz < 360) then
		triggerClientEvent(player, "onClientStartLoadingConcrete", player, vehicle)
		setElementData(player, "work:step", {"concrete", "loading"})
	else
		exports["jb-notyfikacje"]:addNotification(player, "Musisz ustawić się tyłem.")
	end
end
	
addEventHandler("onMarkerHit", resourceRoot, function(element, dimension)
	if not dimension then return end
	if getElementType(element) == "player" then
		if not isPedInVehicle(element) then
			if source == workStart then
				triggerClientEvent(element, "onClientShowConcreteGUI", element, "start")
			elseif source == workEnd then
				triggerClientEvent(element, "onClientShowConcreteGUI", element, "end")
			end
		else 
			local vehicle = getPedOccupiedVehicle(element)
			if vehicle and getElementModel(vehicle) == 524 then
				local player = getVehicleController(vehicle)
				if getElementData(player, "work:step")[2] == "load" then
					if not isKeyBound(player, "h", "up", startLoading) then 
						bindKey(player, "h", "up", startLoading)
					end 
					exports["jb-notyfikacje"]:addNotification(player, "By załadować beton kliknij H.")
				end
			end
		end 
	end
end)	

addEventHandler("onMarkerLeave", resourceRoot, function(element, dimension)
	if not dimension then return end
	if getElementType(element) == "player" then 
		if not isPedInVehicle(element) then 
			if not getElementData(source, "loadConcrete") then
				triggerClientEvent(element, "onClientHideConcreteGUI", element)
			end
		else 
			local vehicle = getPedOccupiedVehicle(element)
			if vehicle then 
				unbindKey(getVehicleController(vehicle), "h", "up", startLoading)
			end
		end
	end
end)
		
		
addEvent("onServerConcreteWorkStart", true)
addEventHandler("onServerConcreteWorkStart", root, function()
	local vehiclesInShape = getElementsWithinColShape(colshape, "vehicle")
	if #vehiclesInShape > 0 then
		exports["jb-notyfikacje"]:addNotification(client, "Jakiś pojazd zajmuje miejsce spawnu.") 
		return 
	end
	
	if not vehicles[client] then
		vehicles[client] = createVehicle(524, -991.85449, -691.92145, 32.00781) -- bede sie bawil rotacją omg
		warpPedIntoVehicle(client, vehicles[source])
		setElementData(client, "work:step", {"concrete", "load"})
		setElementData(client, "reward", 0)
	end
end)

addEvent("onServerCreateEffect", true)
addEventHandler("onServerCreateEffect", root, function()
	triggerClientEvent(source, "onClientCreateCementEffect", source)
end)

addEvent("onPlayerGetReward", true)
addEventHandler("onPlayerGetReward", root, function()
	local x,y,z = getElementPosition(client)
	local dist = getDistanceBetweenPoints3D(x,y,z, -1030.07251, -685.28210, 32.00781)
	local health = getElementHealth(vehicles[client])/100
	local money = math.floor((dist*DIST_MULTIPLIER)*((health/100)))
	setElementData(source, "reward", getElementData(source, "reward") + money)
	exports["jb-notyfikacje"]:addNotification(client, "Do twojego zarobku dodano: $"..tostring(money)..". Na chwilę obecną zarobiłeś: $"..tostring(getElementData(source, "reward"))..".")
end)

function onWorkEnd()
	local muns = getElementData(source, "reward") or 0
	if muns == 0 then 
		exports["jb-notyfikacje"]:addNotification(client, "Nic nie zarobiłeś.")
	else 
		exports["jb-notyfikacje"]:addNotification(client, "Zarobiłeś $"..tostring(muns)..".")
		givePlayerMoney(source, muns)
	end 
	
	setElementData(source, "reward", 0)

	if vehicles[source] and isElement(vehicles[source]) then
		destroyElement(vehicles[source])
		vehicles[source] = false
		
		setElementData(source, "work:step", false)
	end
	
	triggerClientEvent(source, "onClientForceFinishConcreteJob", source)
end
addEvent("onServerConcreteWorkEnd", true)
addEventHandler("onServerConcreteWorkEnd", root, onWorkEnd)

addEventHandler("onVehicleStartExit", resourceRoot, function(plr, seat)
	if seat == 0 then
		if getElementData(plr, "work:step")[2] == "loading" then
			cancelEvent()
		end
	end
end)

addEventHandler("onVehicleStartEnter", resourceRoot, function(plr, seat)
	if seat == 0 then
		local step = getElementData(plr, "work:step")
		if step[1] ~= "concrete" then 
			cancelEvent()
		end
	end
end)

addEventHandler("onPlayerQuit", root, function()
	if vehicles[source] and isElement(vehicles[source]) then
		destroyElement(vehicles[source])
		vehicles[source] = false
	end
end)

addEventHandler("onPlayerWasted", root, function()
	if vehicles[source] and isElement(vehicles[source]) then
		setElementData(source, "work:step", false)
		destroyElement(vehicles[source])
		vehicles[source] = false
	end
end)

for k,v in ipairs(getElementsByType("player")) do 
	setElementData(v, "work:step", false)
end 