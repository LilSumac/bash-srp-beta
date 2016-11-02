local BASH = BASH;
local draw = draw;

/*
**  BASH Util Functions
*/
function checkpanel(panel)
	return panel and panel:IsValid();
end

/*
**	'draw' Library Functions
*/
function draw.PositionIsInArea(posX, posY, firstPosX, firstPosY, secondPosX, secondPosY)
	return ((posX >= firstPosX and posX <= secondPosX) and (posY >= firstPosY and posY <= secondPosY));
end

function draw.Circle(posX, posY, radius, quality, color)
	local points = {};
	local temp;

	for index = 1, quality do
		temp = math.rad(index * 360) / quality;

		points[index] = {
			x = posX + (math.cos(temp) * radius),
			y = posY + (math.sin(temp) * radius)
		};
	end

	draw.NoTexture();
	surface.SetDrawColor(color);
	surface.DrawPoly(points);
end

function draw.Radial(x, y, r, ang, rot, color)
	local segments = 360;
	local segmentstodraw = 360 * (ang / 360);
	rot = rot * (segments / 360);
	local poly = {};

	local temp = {};
	temp['x'] = x;
	temp['y'] = y;
	table.insert(poly, temp);

	for i = 1 + rot, segmentstodraw + rot do
		local temp = {};
		temp['x'] = math.cos((i * (360 / segments)) * (math.pi / 180)) * r + x;
		temp['y'] = math.sin((i * (360 / segments)) * (math.pi / 180)) * r + y;

		table.insert(poly, temp);
	end

	draw.NoTexture();
	surface.SetDrawColor(color);
	surface.DrawPoly(poly);
end

function draw.FadeColor(from, to, rate, doAlpha)
	for chan, val in pairs(from) do
		if chan == "a" and !doAlpha then continue end;
		if val != to[chan] then
			if math.abs(val - to[chan]) < 0.5 then
				from[chan] = to[chan];
			else
				from[chan] = Lerp(rate, val, to[chan]);
			end
		end
	end
end

function draw.FadeColorAlpha(from, to, rate)
	if from.a != to.a then
		if math.abs(from.a - to.a) < 0.5 then
			from.a = to.a;
		else
			from.a = Lerp(rate, from.a, to.a);
		end
	end
end
