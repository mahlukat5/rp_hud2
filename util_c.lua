sx,sy = guiGetScreenSize()
SAFEZONE_X = sx*0.02
SAFEZONE_Y = sy*0.12
renkler = {
	["siyah"] = tocolor(0,0,0,255),
	["siyaha"] = tocolor(0,0,0,150),
	["beyaz"] = tocolor(255,255,255,255),
	["can"] = tocolor(255,0,0,255),
	["zirh"] = tocolor(90,165,200,255),
	["hunger"] = tocolor(205,103,0,255),
	["thirst"] = tocolor(0,143,187,255),
	["para"] = tocolor(18,140,8,255),
	["level"] = tocolor(252,123,3,255),
}

-- Kısaltılmış faction isimlerini buraya girebilirsiniz. Girmezseniz faction'un full ismini çeker.
---------->>
factionNames = {
	[1] = "LSPD",
}

local newG = sx*0.10
local newX = sx*0.101
hudsira = {"heart","zirh","hunger","thirst","faction","money"}
positions = {
	["heart"] = {
		x=sx-(newX),
		y=21,
		g=newG,
		u=20,
	},
	["zirh"] = {
		x=sx-(newX),
		y=21*2,
		g=newG,
		u=20,
	},
	["hunger"] = {
		x=sx-(newX),
		y=21*3,
		g=newG,
		u=20,
		isData="hunger",
		isBar = "bar",
	},
	["thirst"] = {
		x=sx-(newX),
		y=21*4,
		g=newG,
		u=20,
		isData="thirst",
		isBar = "bar",
		pic="water"
	},
	["faction"] = {
		x=sx-(newX),
		y=21*4,
		g=newG,
		u=20,
		isData="faction",
		isBar = "text",
		pic="briefcase"
	},
	["money"] = {
		x=sx-(newX),
		y=21*5,
		g=newG,
		u=20,
		isData="money",
		isBar = "text",
		pic="dollar"
	},
}
function dxDrawRoundedRectangle(radius,x,y,w,h,color,postGUI,subPixel,noTL,noTR,noBL,noBR)
	local noTL = not noTL and dxDrawCircle(x+radius,y+radius,radius,180,270,color,color,9,1,postGUI) -- top left corner
	local noTR = not noTR and dxDrawCircle(x+w-radius,y+radius,radius,270,360,color,color,9,1,postGUI) -- top right corner
	local noBL = not noBL and dxDrawCircle(x+radius,y+h-radius,radius,90,180,color,color,9,1,postGUI) -- bottom left corner
	local noBR = not noBR and dxDrawCircle(x+w-radius,y+h-radius,radius,0,90,color,color,9,1,postGUI) -- bottom right corner
	dxDrawRectangle(x+radius-(not noTL and radius or 0),y,w-2*radius+(not noTL and radius or 0)+(not noTR and radius or 0),radius,color,postGUI,subPixel) -- top rectangle
	dxDrawRectangle(x,y+radius,w,h-2*radius,color,postGUI,subPixel) -- center rectangle
	dxDrawRectangle(x+radius-(not noBL and radius or 0),y+h-radius,w-2*radius+(not noBL and radius or 0)+(not noBR and radius or 0),radius,color,postGUI,subPixel)-- bottom rectangle
end
function rounded(x,y,w,h,text,image)
	dxDrawRoundedRectangle(8,x,y,w,h,renkler["siyaha"],false,false,noTL,noTR,noBL,noBR)
	dxDrawRoundedRectangle(8,x+w-30,y,30,h,renkler["siyah"],false,false,true,noTR,true,noBR)
	if text then
		dxDrawText(text,x+w-30,y,(x+w-30)+30,y+h,renkler["beyaz"],1,"default-bold","center","center")
	end
	if image then
		local nx = x+w-30
		dxDrawImage(nx+(30-18)/2,y+(h-18)/2,18,18,image,0,0,0,renkler["beyaz"])
	end
end

function dxDrawRoundedRectangle2(x, y, w, h, borderColor, bgColor, postGUI)
	if (x) and (y) and (w) and (h) then
		borderColor = borderColor or tocolor(0, 0, 0, 200)
		bgColor = bgColor or borderColor
	
		--> Background
		dxDrawRectangle(x, y, w, h, bgColor, postGUI);
		
		--> Border
		dxDrawRectangle(x - 1, y + 1, 1, h - 2, borderColor, postGUI)-- left
		dxDrawRectangle(x + w, y + 1, 1, h - 2, borderColor, postGUI)-- right
		dxDrawRectangle(x + 1, y - 1, w - 2, 1, borderColor, postGUI)-- top
		dxDrawRectangle(x + 1, y + h, w - 2, 1, borderColor, postGUI)-- bottom
		dxDrawRectangle(x, y, 1, 1, borderColor, postGUI)
		dxDrawRectangle(x + w - 1, y, 1, 1, borderColor, postGUI)
		dxDrawRectangle(x, y + h - 1, 1, 1, borderColor, postGUI)
		dxDrawRectangle(x + w - 1, y + h - 1, 1, 1, borderColor, postGUI)
	end
end
function tocomma(number)
	while true do
		number, k = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return number
end
function isData(elm,data)
	return getElementData(elm,data)
end
function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
		end
	else
		outputDebugString("Not an element. Can't get speed")
		return false
	end
end

function showToolTips(x,y,g,text,text2,corner_color)
	if isMouseInCircle(x, y, g) then
		local f =(g^2)
		tooltip((x-g),(y)-g*2,text,text2,corner_color)
	end
end
function showToolTips(x,y,w,h,text,text2,corner_color)
	if isMouseInPosition(x,y,w,h) then
		-- local f =(g^2)
		tooltip(x+(w/2),(y),text,text2,corner_color)
	end
end

function isMouseInPosition(x,y,w,h)
	if not isCursorShowing() then
		return false
	end
	local cx,cy = getCursorPosition()
	local cx,cy = (cx*sx),(cy*sy)
	return ((cx >= x and cx <= x+w) and (cy >= y and cy <= y+h))
end
function isMouseInCircle(x, y, r)
    if isCursorShowing() then
        local cx, cy = getCursorPosition( )
        local cx, cy = cx*sx, cy*sy
        return (x-cx)^2+(y-cy)^2 <= r^2
    end
    return false
end
local tooltip_background_color = tocolor( 0, 0, 0, 180 )
local tooltip_corner_color = tocolor( 255, 255, 255, 180 )
local tooltip_text_color = tocolor( 255, 255, 255, 255 )
--MAXIME / SHOW TOOLTIP AT CURSOR POSITION
function tooltip( x, y, text, text2,corner_color )
	text = tostring( text )
	if text2 then
		text2 = tostring( text2 )
	end
	
	if text == text2 then
		text2 = nil
	end
	
	local width = dxGetTextWidth( text, 1, "clear" ) + 10
	if text2 then
		width = math.max( width, dxGetTextWidth( text2, 1, "clear" ) + 20 )
		text = text .. "\n" .. text2
	end
	local height = 5 * ( text2 and 5 or 3 )
	x = math.max( 5, math.min( x, sx - width - 5 ) )
	y = math.max( 5, math.min( y, sy - height - 5 ) )
	
	dxDrawRoundedRectangle2( x, y, width, height, corner_color or tooltip_corner_color,tooltip_background_color,true)
	-- dxDrawRoundedRectangle( x-2, y-2, width+4, height+4, corner_color or tooltip_corner_color,11)
	dxDrawText( text, x, y, x + width, y + height, tooltip_text_color, 1, "clear", "center", "center", false, false, true )
end

