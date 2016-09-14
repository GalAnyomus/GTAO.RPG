function normalize (vec)
    len = math.sqrt(vec[1]^2 + vec[2]^2 + vec[3]^2)
    return {vec[1]/len, vec[2]/len, vec[3]/len}
end


function drawCricle3D(posX, posY, posZ, radius, width, color)
      for i=0,360,0.1 do
          local _i = i*(math.pi/180)
          dxDrawLine3D(math.cos(_i)*(radius-width)+posX, math.sin(_i)*(radius-width)+posY, posZ, math.cos(_i)*(radius+width)+posX, math.sin(_i)*(radius+width)+posY, posZ, color, width, false)
      end
end

function drawRectangle3D(x,y,z,radius)
	dxDrawLine3D(x,y,z,x+radius,y,z,tocolor(255,0,0,255), 1, false)
	dxDrawLine3D(x,y-radius,z,x,y,z,tocolor(255,0,0,255), 1, false)	
	dxDrawLine3D(x+radius,y-radius,z,x+radius,y,z,tocolor(255,0,0,255), 1, false)
	dxDrawLine3D(x,y-radius,z,x+radius,y-radius,z,tocolor(255,0,0,255), 1, false)
end

function create3DOctagon(x,y,z,radius,width)
local radius2 = radius/math.sqrt(2)
point = {}
for i=1,8 do
	point[i] = {}
end
point[1].x = x
point[1].y = y-radius
point[2].x = x+radius2
point[2].y = y-radius2
point[3].x = x+radius
point[3].y = y
point[4].x = x+radius2
point[4].y = y+radius2
point[5].x = x
point[5].y = y+radius
point[6].x = x-radius2
point[6].y = y+radius2
point[7].x = x-radius
point[7].y = y
point[8].x = x-radius2
point[8].y = y-radius2
	for i=1,8 do
		if i ~= 8 then
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[i+1].x,point[i+1].y,z
		else
			x, y, z, x2, y2, z2 = point[i].x,point[i].y,z,point[1].x,point[1].y,z
		end
		dxDrawLine3D(x, y, z, x2, y2, z2,tocolor(255,255,255,150), width)
	end
end


local sin, cos, pi = math.sin , math.cos , math.pi
function DrawSphere3D(posX, posY, posZ, radius, width, color)
	local stepsize = 0.02
	local count = 0
	local n = 0
	local time = 0
	for j = 0, 1, stepsize/radius do
			for i = -1, 1+stepsize/radius, stepsize/radius do
			n = n+1
			if n >= 2 then
				if time == 50 then
					n = 0
				else
					time = time+1
				end
			else
				n = n+1
				local a = sin(j * pi)
				local b = cos(j * pi)
				local x = a * sin(i * pi) * radius
				local y = a * cos(i * pi) * radius
				local z = b * radius
				local posZ = posZ + radius/2
				count = count+1
		    	dxDrawLine3D(posX,posY,posZ,posX+x,posY+y,posZ+z,color,1)
		    	local j1 = j + stepsize
		    	local a = sin(j1 * pi)
				local b = cos(j1 * pi)
				local x = a * sin(i * pi) * radius 
				local y = a * cos(i * pi) * radius
				local z = b * radius
				count = count+1
		    	dxDrawLine3D(posX,posY,posZ,posX+x,posY+y,posZ+z,color,1)
		    end
		 end
	end
	return count
end