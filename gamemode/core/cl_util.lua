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

function draw.FadeColor(from, rate, toR, toG, toB, toA)
	from.r = Lerp(rate, from.r, toR);
	from.g = Lerp(rate, from.g, toG);
	from.b = Lerp(rate, from.b, toB);
	if toA then
		from.a = Lerp(rate, from.a, toA);
	end
end

function draw.FadeColorAlpha(from, rate, toA)
	from.a = Lerp(rate, from.a, toA);
end
