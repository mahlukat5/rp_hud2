pics,renderTargets = {},{}
local baslangic,isLoggedIn,isMinimize,needUpdate = getTickCount(),nil,false,false
local sure3dakika,sure2dakika,sure1dakika = getTickCount(),getTickCount(),getTickCount()
local isLoggedIn,isMinimize,needUpdate = nil,false,false
local hudElements = {}
local disabledHUD = {"health", "armour", "breath", "clock", "money", "weapon", "ammo", "vehicle_name", "area_name", "wanted"} 
local rectG = 10
for i,v in ipairs({"heart","zirh","hunger","water","dollar","briefcase"}) do
	pics[v] = dxCreateTexture("images/nhud/"..v..".png")
end

local updatedatas = {
	-- burdaki data isimleri güncellenince hud güncellenir.
	["money"]=true, -- oyuncuPara
	["bankmoney"]=true, -- oyuncuBankaPara
	["hunger"]=true, -- oyuncuAclik
	["thirst"]=true, -- oyuncuSusuzluk
	["stamina"]=true, -- oyuncuStamina
	["playerid"]=true, -- id
	["faction"]=true, -- faction
}

function getUpdateData(key)
	return updatedatas[key] or 0
end
addEventHandler("onClientResourceStart", resourceRoot, function()
	for i,hud in ipairs(disabledHUD) do
		setPlayerHudComponentVisible(hud, false)
	end
	for key,v in pairs(updatedatas) do
		updatedatas[key] = getElementData(localPlayer,key) or 0
	end
	isLoggedIn = tonumber(isData(localPlayer,"loggedin") or 0) == 1
	if isLoggedIn then
		createTarget("yemek_su_level_paralar")
		addEventHandler("onClientRender",root,render)
	end	
end)

function canElementRender(part)
	local oyuncuzirh = getPedArmor(localPlayer)
	local oyuncuzirh = getPedArmor(localPlayer)
	if	part == "zirh" and oyuncuzirh <= 0 then return false end
	if	part == "faction" and getUpdateData("faction") < 1 then return false end
	
	return true
end
function getPartText(part,bilgi)
	if part == "money" then return "$"..tocomma(getUpdateData("money")) end
	local takim = getUpdateData("faction")
	if part == "faction" and takim > 0 then 
		return factionNames[takim] or getTeamName(getPlayerTeam(localPlayer))
	end
	
	return ""
end

function createTarget(data)
	if isMinimize then needUpdate=true return end
	if renderTargets[data] then destroyElement(renderTargets[data]) end
	if isTimer(zirhtimer) then killTimer(zirhtimer) end
	zirhtimer = setTimer(zirhKontrol,2000,0)
	hudElements = {}
	if data == "yemek_su_level_paralar" then
		local texture = dxCreateRenderTarget(sx,sy,true)
		dxSetRenderTarget(texture)
		local startY = 21
		for i,v in ipairs(hudsira) do
			if canElementRender(v) then
				local p = positions[v]
				positions[v].y = startY
				rounded(p.x,startY,p.g,p.u,nil,pics[p.pic or v])
				if p.isData and p.isBar and p.isBar == "bar" then
					local ilerleme = math.ceil((getUpdateData(p.isData)/100)*(positions[v].g-35))
					dxDrawRoundedRectangle(4,(p.x+p.g-30)-(ilerleme),startY+(p.u-rectG)/2,ilerleme,rectG,renkler[v],false,false,nil,true,nil,true)
				end
				if tostring(p.isBar) == "text" then
					dxDrawText(getPartText(v,p),p.x,startY,p.x+p.g-30,startY+p.u,renkler["beyaz"],1,"default-bold","center","center",true)
				end
				hudElements[v]=true
				startY = startY+21
			end	
		end
		dxSetRenderTarget()	
		renderTargets[data]=texture
	end
end
addEventHandler("onClientRestore",root,function(didClearRenderTargets)
	isMinimize = false
    if didClearRenderTargets or needUpdate then
		setTimer(function()
			createTarget("yemek_su_level_paralar")
		end,1000,1)
    end
end)
addEventHandler( "onClientMinimize", root,function()
	isMinimize = true
end)


function zirhKontrol()
	local oyuncuZirh = getPedArmor(localPlayer)
	if oyuncuZirh > 0 and not hudElements["zirh"] then createTarget("yemek_su_level_paralar") return end
	if hudElements["zirh"] and oyuncuZirh < 1 then createTarget("yemek_su_level_paralar") return end
end	



function render()
	local suan = getTickCount()
	-- Yemek Azaltma
	---------->>
	if suan-sure3dakika >= 180000 then 
		sure3dakika = getTickCount()
		if getUpdateData("hunger") > 0 then
			if isData(localPlayer, "duty_admin" )  == 0 or isData(localPlayer,"duty_supporter" ) == 0 or isData(localPlayer, "dead") == 0 or not isData(localPlayer, "adminjailed") then
				setElementData(localPlayer,"hunger",getUpdateData("hunger")-1)
			end
		end
	end
	-- Su Azaltma
	---------->>
	if suan-sure2dakika >= 120000 then 
		sure2dakika = getTickCount()
		if getUpdateData("thirst") > 0 then
			if isData(localPlayer, "duty_admin" )  == 0 or isData(localPlayer,"duty_supporter" ) == 0 or isData(localPlayer, "dead") == 0 or not isData(localPlayer, "adminjailed") then
				setElementData(localPlayer,"thirst",getUpdateData("thirst")-1)
			end
		end
		if getUpdateData("hunger") >= 50 and getUpdateData("thirst") >= 50 then
			if getElementHealth(localPlayer) > 5 and getElementHealth(localPlayer) < 100 then
				setElementHealth(localPlayer, getElementHealth(localPlayer) + 2)
			end	
		end
		if getUpdateData("hunger") <= 0 then
			setElementHealth(localPlayer, getElementHealth(localPlayer) - 5)
		end
		if getUpdateData("thirst") <= 0 then
			setElementHealth(localPlayer, getElementHealth(localPlayer) - 5)
		end
	end
	if isPlayerMapVisible() then return end
	
	

	-- Can
	---------->>
	local oyuncuCan = math.floor(getElementHealth(localPlayer))
	local can_ilerleme = math.ceil((oyuncuCan/100)*(positions["heart"].g-35))
	dxDrawRoundedRectangle(4,(positions["heart"].x+positions["heart"].g-30)-(can_ilerleme),positions["heart"].y+(positions["heart"].u-rectG)/2,can_ilerleme,rectG,renkler["can"],false,false,nil,true,nil,true)
	-- Zırh
	---------->>
	local oyuncuZirh = math.floor(getPedArmor(localPlayer))
	if hudElements["zirh"] then
		local zirh_ilerleme = math.ceil((oyuncuZirh/100)*(positions["zirh"].g-35))
		dxDrawRoundedRectangle(4,(positions["zirh"].x+positions["zirh"].g-30)-(zirh_ilerleme),positions["zirh"].y+(positions["zirh"].u-rectG)/2,zirh_ilerleme,rectG,renkler["zirh"],false,false,nil,true,nil,true)
	end
	-- Diğer parçalar
	---------->>
	if renderTargets["yemek_su_level_paralar"] then
		dxDrawImage(0,0,sx,sy, renderTargets["yemek_su_level_paralar"])
	end

	-- Tooltips
	---------->>
	if isCursorShowing() then
		showToolTips(positions["heart"].x,positions["heart"].y,positions["heart"].g,positions["heart"].u,"%"..math.ceil(oyuncuCan),nil,renkler["can"])
		showToolTips(positions["hunger"].x,positions["hunger"].y,positions["hunger"].g,positions["hunger"].u,"%"..math.ceil(getUpdateData("hunger")),nil,renkler["hunger"])
		showToolTips(positions["thirst"].x,positions["thirst"].y,positions["thirst"].g,positions["thirst"].u,"%"..math.ceil(getUpdateData("thirst")),nil,renkler["thirst"])
		showToolTips(positions["money"].x,positions["money"].y,positions["money"].g,positions["money"].u,"$"..tocomma(getUpdateData("money")),nil,renkler["para"])
		if hudElements["zirh"] then
			showToolTips(positions["zirh"].x,positions["zirh"].y,positions["zirh"].g,positions["zirh"].u,"%"..math.ceil(oyuncuZirh),nil,renkler["zirh"])
		end	
	end
	
	-- Silah
	---------->>
	
	local weapon = getPedWeapon(localPlayer)
	local clip = getPedAmmoInClip(localPlayer)
	local ammo = getPedTotalAmmo(localPlayer)
	if (weapon == 0 or weapon == 1 or ammo == 0) then return end
	
	local len = #tostring(clip)
	if string.find(tostring(clip), 1) then len = len - 0.5 end
	local xoff = (len*17) + 10
	
	local len2 = #tostring(ammo-clip)
	if string.find(tostring(ammo-clip), 1) then len2 = len2 - 0.5 end
	local weapLen = ((len+len2)*17) + 20
	if (weapon >= 15 and weapon ~= 40 and weapon <= 44 or weapon >= 46) then
			-- Ammo in Clip
		local dX,dY,dW,dH = sx-6,35,sx-6,30
		local dX,dY,dW,dH = dX-SAFEZONE_X, dY+SAFEZONE_Y, dW-SAFEZONE_X, dH+SAFEZONE_Y
		dxDrawText(clip, dX+2,dY,dW+2,dH, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(clip, dX,dY+2,dW,dH+2, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(clip, dX-2,dY,dW-2,dH, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(clip, dX,dY-2,dW,dH-2, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(clip, dX,dY,dW,dH, tocolor(110,110,110,255), 1.25, "pricedown", "right")
			-- Total Ammo
		local dX,dY,dW,dH = sx-6-xoff,35,sx-6-xoff,30
		local dX,dY,dW,dH = dX-SAFEZONE_X, dY+SAFEZONE_Y, dW-SAFEZONE_X, dH+SAFEZONE_Y
		dxDrawText(ammo-clip, dX+2-xoff,dY,dW+2,dH, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(ammo-clip, dX,dY+2,dW,dH+2, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(ammo-clip, dX-2,dY,dW-2,dH, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(ammo-clip, dX,dY-2,dW,dH-2, renkler["siyah"], 1.25, "pricedown", "right")
		dxDrawText(ammo-clip, dX,dY,dW,dH, tocolor(220,220,220,255), 1.25, "pricedown", "right")
	else
		xoff = 0
		weapLen = 0
	end
	if (weapon == 0 or weapon == 1) then return end

	local img = pics["weapons"..weapon]
	if not img then pics["weapons"..weapon] = dxCreateTexture("images/nhud/weapons/"..weapon..".png","argb", false, "clamp") return end
	local dX,dY,dW,dH = sx-133-weapLen,35,128,40
	local dX,dY,dW,dH = dX-SAFEZONE_X, dY+SAFEZONE_Y, dW, dH
	dxDrawImage(dX, dY, dW, dH, img)
end

function dataChanger(theKey, oldValue, newValue)
    if (getElementType(source) == "player") then
		if updatedatas[theKey] then
			updatedatas[theKey] = newValue
			createTarget("yemek_su_level_paralar")
		elseif (theKey == "loggedin") then
			isLoggedIn = tonumber(newValue) == 1
			if isLoggedIn then 
				setTimer(function()
					createTarget("yemek_su_level_paralar")
					addEventHandler("onClientRender",root,render)
				end,2000,1)	
			else
				removeEventHandler("onClientRender",root,render)
			end	
		end
    end
end
addEventHandler("onClientElementDataChange", localPlayer, dataChanger)


