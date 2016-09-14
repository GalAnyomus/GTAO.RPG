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

-- element data: "work:step" [1] = nazwa pracy - [2] = aktualny etap w pracy
-- load: poczatkowy etap pracy, musimy zaladowac beton
-- loading: trwa ladowanie betonu na betoniarke
-- loaded: zaladowano beton, wybieramy cel 

local unloadPositions = {
{-2106.20776, 190.95424, 35.34848},
{2429.45972, 1917.81250, 6.01563},
{-2103.17188, 271.58994, 35.35028}
}

local sx, sy = guiGetScreenSize()

local vehicle, targetMarker, targetBlip, start

function loadWork() 
	local rand = math.random(1, #unloadPositions)
	targetMarker = createMarker(unloadPositions[rand][1], unloadPositions[rand][2], unloadPositions[rand][3]-1.2, "cylinder", 2.5, 255,255,255,128)
	targetBlip = createBlipAttachedTo(targetMarker, 11)
	
	setElementFrozen(vehicle, false)
	setElementData(localPlayer, "work:step", {"concrete", "loaded"})
	addEventHandler("onClientMarkerHit", targetMarker, function(hitElement, dim) 
		if hitElement == localPlayer and dim then 
			triggerServerEvent("onServerCreateEffect", localPlayer) 
		end
	end)
	
	toggleAllControls(true)
	exports["jb-notyfikacje"]:addNotification("Udaj się do miejsca rozładunku oznaczonego na mapie.")
end 

function loadAnimation()
	dxDrawRectangle(sx/2-400/2, sy/2-25/2, 400, 25, tocolor(128,0,0,128))
	
	local progress = (getTickCount() - start)/7000
	local rectWidth = interpolateBetween(0, 0, 0, 400, 0, 0, progress, "Linear")
	dxDrawRectangle(sx/2-400/2, sy/2-25/2, rectWidth, 25, tocolor(255,0,0,255))
	if progress >= 1 then
		loadWork()
		removeEventHandler("onClientRender", root, loadAnimation)
		return
	end
end

addEvent("onClientStartLoadingConcrete", true)
addEventHandler("onClientStartLoadingConcrete", root, function(veh)
	local state = getElementData(localPlayer, "work:step") or {} 
	if state[2] == "loading" or state[2] == "loaded" then return end 
	
	vehicle = veh
	start = getTickCount()
		
	setElementFrozen(vehicle, true)
	toggleAllControls(false)
	addEventHandler("onClientRender", root, loadAnimation)
end)

addEvent("onClientForceFinishConcreteJob", true)
addEventHandler("onClientForceFinishConcreteJob", root, function() 
	if isElement(targetMarker) then 
		destroyElement(targetMarker) 
		targetMarker = nil 
	end 
	
	if isElement(targetBlip) then 
		destroyElement(targetBlip) 
		targetBlip = nil 
	end 
end)
 
function createCementEffect()
    local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then return end 
	
	setElementFrozen(vehicle, true)
	toggleAllControls(false)
	setElementRotation(vehicle, 0, 0, 180)
	
    local x, y, z = getPositionFromElementOffset(vehicle, 0.1, -3.7, 1)
    local _, _, rz = getElementRotation(vehicle)

    local effect = createEffect("cement", x, y, z, 0, 0, rz, 300)
	
	function destroyTargets()
		destroyElement(effect)
				
		destroyElement(targetMarker)
		destroyElement(targetBlip)
		
		targetBlip = false
		targetMarker = false
		
		setElementData(localPlayer, "work:step", {"concrete", "load"})
		triggerServerEvent("onPlayerGetReward", localPlayer)
		
		exports["jb-notyfikacje"]:addNotification("Udaj się po nowy załadunek lub odbierz wypłatę w miejscu rozpoczęcia pracy.")
		
		setElementFrozen(vehicle, false)
		toggleAllControls(true)
	end
    setTimer(destroyTargets, 7000, 1)
end
addEvent("onClientCreateCementEffect", true)
addEventHandler("onClientCreateCementEffect", root, createCementEffect)