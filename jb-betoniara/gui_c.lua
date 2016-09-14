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

----------------------------------------------------
-- Ustawienia 
local GUI_R, GUI_G, GUI_B = 231, 76, 60 -- dopasuj kolor interfejsu do swojego serwera 
----------------------------------------------------

local screenW, screenH = guiGetScreenSize()
local baseX = 1920
local zoom = 1.0 -- jak bardzo interfejs ma byc zmniejszony 
local minZoom = 2 -- najwieksze zmniejszenie 
if screenW < baseX then -- jesli rozdzielczosc jest mniejsza niz full hd to stopniowo zmniejszamy interfejs 
	zoom = math.min(minZoom, baseX/screenW)
end 


-- zmienne interfejsu 
local currentGUIType = "start"

-- wymiary 
local bgPos = {x=(screenW/2)-(768/zoom)/2, y=(screenH/2)-(480/zoom)/2, w=768/zoom, h=480/zoom}
local bgButton = {} 
bgButton[1] = {x=bgPos.x+150/zoom, y=bgPos.y+bgPos.h-120/zoom, w=150/zoom, h=45/zoom} 
bgButton[2] = {x=bgPos.x+bgPos.w-290/zoom, y=bgPos.y+bgPos.h-120/zoom, w=150/zoom, h=45/zoom} 

local titleTextPos = {x=bgPos.x, y=bgPos.y, w=bgPos.w+bgPos.x, h=bgPos.y+105/zoom}
local descTextPos = {x=bgPos.x+135/zoom, y=bgPos.y, w=bgPos.w+bgPos.x-135/zoom, h=bgPos.h+bgPos.y-105/zoom}

-- zmienne do animacji przyciskow :v

function showConcreteGUI(type) 
	if type == "start" then 
		local state = getElementData(localPlayer, "work:step") or false
		if state then 
			exports["jb-notyfikacje"]:addNotification("Już pracujesz!")
			return 
		end 
		
	elseif type == "end" then 
		local state = getElementData(localPlayer, "work:step") or {} 
		if state[1] ~= "concrete" then 
			exports["jb-notyfikacje"]:addNotification("Musisz pracować jako kierowca betoniarki!")
			return
		end
	end  
	
	font = dxCreateFont("fonts/f.ttf", math.floor(20/zoom)) or "default-bold"
	
	currentGUIType = type 
	addEventHandler("onClientRender", root, renderConcreteGUI)
	addEventHandler("onClientClick", root, clickConcreteGUI)
	
	showCursor(true)
end
addEvent("onClientShowConcreteGUI", true) 
addEventHandler("onClientShowConcreteGUI", root, showConcreteGUI)

function hideConcreteGUI() 
	removeEventHandler("onClientRender", root, renderConcreteGUI)
	removeEventHandler("onClientClick", root, clickConcreteGUI)
	showCursor(false)
	
	if isElement(font) then destroyElement(font) end 
end 
addEvent("onClientHideConcreteGUI", true)
addEventHandler("onClientHideConcreteGUI", root, hideConcreteGUI) 

function clickConcreteGUI(button, state) 
	if button == "left" and state == "up" then 
		if isCursorOnElement(bgButton[1].x, bgButton[1].y, bgButton[1].w, bgButton[1].w, bgButton[1].h) then
			if currentGUIType == "start" then -- zaczęcie pracy 
				triggerServerEvent("onServerConcreteWorkStart", localPlayer)
				exports["jb-notyfikacje"]:addNotification("Rozpoczynasz pracę kierowcy betoniarki. Załaduj pojazd w punkcie.")
			elseif currentGUIType == "end" then -- zakończenie pracy
				triggerServerEvent("onServerConcreteWorkEnd", localPlayer)
			end 
			
			hideConcreteGUI()
		elseif isCursorOnElement(bgButton[2].x, bgButton[2].y, bgButton[2].w, bgButton[2].h) then -- ten przycisk tylko zamyka gui 
			hideConcreteGUI()
		end
	end
end 


function renderConcreteGUI()
	dxDrawImage(bgPos.x, bgPos.y, bgPos.w, bgPos.h, "img/bg.png")
	
	if isCursorOnElement(bgButton[1].x, bgButton[1].y, bgButton[1].w, bgButton[1].h) then 
		dxDrawRectangle(bgButton[1].x, bgButton[1].y, bgButton[1].w, bgButton[1].h, tocolor(GUI_R, GUI_G, GUI_B, 150))
	else 
		dxDrawRectangle(bgButton[1].x, bgButton[1].y, bgButton[1].w, bgButton[1].h, tocolor(30, 30, 30, 150))
	end 
	
	if isCursorOnElement(bgButton[2].x, bgButton[2].y, bgButton[2].w, bgButton[2].h) then 
		dxDrawRectangle(bgButton[2].x, bgButton[2].y, bgButton[2].w, bgButton[2].h, tocolor(GUI_R, GUI_G, GUI_B, 150))
	else 
		dxDrawRectangle(bgButton[2].x, bgButton[2].y, bgButton[2].w, bgButton[2].h, tocolor(30, 30, 30, 205))
	end 
	
	if currentGUIType == "start" then
		dxDrawText("Praca dorywcza: kierowca betoniarki", titleTextPos.x, titleTextPos.y, titleTextPos.w, titleTextPos.h, tocolor(GUI_R, GUI_G, GUI_B, 230), 0.9, font, "center", "center") 
		dxDrawText("Zatrudnij się jako kierowca betoniarki. Musisz wypełnić Cement Trucka betonem w miejscu załadunku, a następnie dowieźć i wylać na budowie. Jedź ostrożnie i nie uszkodź pojazdu.\n\nRuszaj w drogę czym prędzej! Budowa czeka na beton.", descTextPos.x, descTextPos.y, descTextPos.w, descTextPos.h, tocolor(200, 200, 200, 200), 0.8, font, "center", "center", false, true)
	
		dxDrawText("Rozpocznij", bgButton[1].x, bgButton[1].y, bgButton[1].x+bgButton[1].w, bgButton[1].y+bgButton[1].h, tocolor(230, 230, 230, 230), 0.8, font, "center", "center")
		dxDrawText("Zamknij", bgButton[2].x, bgButton[2].y, bgButton[2].x+bgButton[2].w, bgButton[2].y+bgButton[2].h, tocolor(230, 230, 230, 230), 0.8, font, "center", "center")
	elseif currentGUIType == "end" then 
		dxDrawText("Praca dorywcza: kierowca betoniarki", titleTextPos.x, titleTextPos.y, titleTextPos.w, titleTextPos.h, tocolor(GUI_R, GUI_G, GUI_B, 230), 0.9, font, "center", "center") 
		dxDrawText("Zarobiłeś: $"..tostring(getElementData(localPlayer, "reward") or 0)..". Możesz zakończyć pracę i otrzymać zarobek.", descTextPos.x, descTextPos.y, descTextPos.w, descTextPos.h, tocolor(200, 200, 200, 200), 0.8, font, "center", "center", false, true)
	
		dxDrawText("Zakończ", bgButton[1].x, bgButton[1].y, bgButton[1].x+bgButton[1].w, bgButton[1].y+bgButton[1].h, tocolor(230, 230, 230, 230), 0.8, font, "center", "center")
		dxDrawText("Zamknij", bgButton[2].x, bgButton[2].y, bgButton[2].x+bgButton[2].w, bgButton[2].y+bgButton[2].h, tocolor(230, 230, 230, 230), 0.8, font, "center", "center")
	end 
end 