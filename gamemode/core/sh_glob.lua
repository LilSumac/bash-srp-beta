color_trans = Color(0, 0, 0, 0);
color_con = Color(192, 192, 192, 255);
color_red = Color(200, 0, 0, 255);
color_green = Color(0, 200, 0, 255);
color_blue = Color(0, 0, 200, 255);
color_purple = Color(200, 0, 200, 255);
color_sql = Color(0, 204, 204, 255);
color_cookie = Color(204, 102, 0, 255);

CORE_DIRS = {
    ["core"] =      true, ["external"] =  true,
    ["hooks"] =     true, ["items"] =     true,
    ["libs"] =      true, ["net"] =       true,
    ["obj"] =       true, ["vgui"] =      true
};
CORE_EXCLUDED = {
    ["sh_ell"] =    true,
    ["sh_glob"] =   true,
    ["sh_util"] =   true
};

CHARACTERS = {
	'q', 'w', 'e', 'r',
	't', 'y', 'u', 'i',
	'o', 'p', 'a', 's',
	'd', 'f', 'g', 'h',
	'j', 'k', 'l', 'z',
	'x', 'c', 'v', 'b',
	'n', 'm', 'Q', 'W',
	'E', 'R', 'T', 'Y',
	'U', 'I', 'O', 'P',
	'A', 'S', 'D', 'F',
	'G', 'H', 'J', 'K',
	'L', 'Z', 'X', 'C',
	'V', 'B', 'N', 'M'
};
CHARACTERS_SPECIAL = {
	'0', '1', '2', '3',
	'4', '5', '6', '7',
	'8', '9', '!', '@',
	'$', '&', '-', '_'
};
CHARACTERS_RANDOM = table.insert(CHARACTERS, CHARACTERS_SPECIAL);

DATA_PLY = 1;
DATA_CHAR = 2;
DATA_SERVER = 3;

Fmt = Format;

LOG_ALL = 1;
LOG_ERR = 2;
LOG_IC = 3;

ITEM_TINY = 0;
ITEM_SMALL = 1;
ITEM_MED = 2;
ITEM_LARGE = 3;
ITEM_HUGE = 4;

NET_TYPE = {};
NET_TYPE["boolean"] = "Bit";
NET_TYPE["number"] = "Int";
NET_TYPE["string"] = "String";

OPER = {};
OPER["=="] = function(a, b) return a == b end;
OPER["!="] = function(a, b) return a != b end;
OPER[">>"] = function(a, b) return a > b end;
OPER[">="] = function(a, b) return a >= b end;
OPER["<<"] = function(a, b) return a < b end;
OPER["<="] = function(a, b) return a <= b end;

PREFIXES_CLIENT = {"cl_", "vgui_"};
PREFIXES_SERVER = {"sv_"};
PREFIXES_SHARED = {"sh_", "item_", "obj_", string.Explode('_', game.GetMap())[1] .. "_"};

SQL_TYPE = {};
SQL_TYPE["boolean"] = "TINYINT(4) UNSIGNED NOT NULL";
SQL_TYPE["number"] = "INT(18) UNSIGNED NOT NULL";
SQL_TYPE["string"] = "TEXT NOT NULL";

SQL_LOCAL = 1;
SQL_GLOBAL = 2;

if CLIENT then
    LP = LocalPlayer;

	SCRW = ScrW();
	SCRH = ScrH();
	CENTER_X = SCRW / 2;
	CENTER_Y = SCRH / 2;

    ALIGN_ABOVE =       1;
    ALIGN_ABOVELEFT =   2;
    ALIGN_ABOVECENT =   3;
    ALIGN_ABOVERIGHT =  4;
    ALIGN_BELOW =       5;
    ALIGN_BELOWLEFT =   6;
    ALIGN_BELOWCENT =   7;
    ALIGN_BELOWRIGHT =  8;
    ALIGN_LEFT =        9;
    ALIGN_LEFTTOP =     10;
    ALIGN_LEFTCENT =    11;
    ALIGN_LEFTBOT =     12;
    ALIGN_RIGHT =       13;
    ALIGN_RIGHTTOP =    14;
    ALIGN_RIGHTCENT =   15;
    ALIGN_RIGHTBOT =    16;

    TEXT_LEFT = 0;
    TEXT_CENT = 1;
    TEXT_RIGHT = 2;
    TEXT_TOP = 3;
    TEXT_BOT = 4;

    TAB_TEXT = 1;
    TAB_ICON = 2;
    TAB_BOTH = 3;

    TEXTURE_ERROR = Material("vgui/ERROR.png");

	COLOR_MOD = {
		DEFAULT = {
			["$pp_colour_addr"] = 		0,
			["$pp_colour_addg"] = 		0,
			["$pp_colour_addb"] = 		0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 	1,
			["$pp_colour_colour"] = 	1,
			["$pp_colour_mulr"] =		0,
			["$pp_colour_mulg"] = 		0,
			["$pp_colour_mulb"] = 		0
		},
		DEPRESSING = {
			["$pp_colour_addr"] = 		0,
			["$pp_colour_addg"] = 		0,
			["$pp_colour_addb"] = 		0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 	1.25,
			["$pp_colour_colour"] = 	0.5,
			["$pp_colour_mulr"] =		0,
			["$pp_colour_mulg"] = 		0,
			["$pp_colour_mulb"] = 		0
		}
	};

	DISABLED_HUD = {
		"CHudHealth",
		"CHudSuitPower",
		"CHudBattery",
		"CHudCrosshair",
		"CHudAmmo",
		"CHudChat",
		"CHudDamageIndicator",
		"CHudHintDisplay",
		"CHudVoiceStatus",
		"CHudVoiceSelfStatus",
		"CHudWeaponSelection",
		"CHudZoom",
		"CHudPoisonDamageIndicator"
	};

	ENABLED_CROSSHAIRS = {
		"gmod_tool",
		"weapon_physgun"
	};
end
