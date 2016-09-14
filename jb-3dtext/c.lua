--[[
Autorzy kodu:
	- Jurandovsky
	- Brzysiek

Zasób odpowiadający za 3d texty.

Dziękujemy za mile spędzony z Wami czas, zapraszamy ponownie do skorzystania z naszych linii lotniczych.
--]]

MAX_DRAW_DISTANCE = 40
FONT_SIZE = 1.2

function dxDrawBorderedText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak,postGUI) 
	for oX = -1, 1 do
		for oY = -1, 1 do
			dxDrawText(text, left + oX, top + oY, right + oX, bottom + oY, tocolor(0, 0, 0, 255), scale, font, alignX, alignY, clip, wordBreak,postGUI) 
		end 
     end 
	 
    dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI) 
end 

local texts = {} 
function refreshNearbyTexts() 
	texts = {} 
	
	local cx, cy, cz = getCameraMatrix()
	for k,v in ipairs(getElementsByType("3dtext")) do 
		local x, y, z = getElementPosition(v)
		local dist = getDistanceBetweenPoints3D(x, y, z, cx, cy, cz)
		if dist < MAX_DRAW_DISTANCE then 
			table.insert(texts, v)
		end
	end
end 
setTimer(refreshNearbyTexts, 1000, 0)

function render3DText()
	local cx, cy, cz = getCameraMatrix()
	
	for k,v in ipairs(texts) do 
		if isElement(v) then 
			local x, y, z = getElementPosition(v)
			local dist = getDistanceBetweenPoints3D(x, y, z, cx, cy, cz)
			if dist < MAX_DRAW_DISTANCE then 
				if isLineOfSightClear(cx, cy, cz, x, y, z, true, true, false, true, true, true) then 
					local sx, sy = getScreenFromWorldPosition(x, y, z, 1, false)
					if sx and sy then 
						local text = getElementData(v, "text") or "" 
						dxDrawBorderedText(text, sx, sy, sx, sy, tocolor(230, 230, 230, 255), FONT_SIZE * ( (MAX_DRAW_DISTANCE - dist) / MAX_DRAW_DISTANCE ), "default-bold", "center", "center", false, false, false)
					end
				end
			end
		end
	end
	
end 
addEventHandler("onClientRender", root, render3DText)
