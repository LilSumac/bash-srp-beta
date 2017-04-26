local BASH = BASH;

local function loadFonts()
	surface.CreateFont("bash-icons-1", {
		font = "bash-icons-1",
		size = 16
	});
	surface.CreateFont("bash-icons-2", {
		font = "bash-icons-2",
		size = 16
	});
	surface.CreateFont("bash-light-24", {
		font = "Ubuntu Light",
		size = 24
	});
	surface.CreateFont("bash-regular-24", {
		font = "Ubuntu",
		size = 24
	});
	surface.CreateFont("bash-regular-36", {
		font = "Ubuntu",
		size = 36
	});
	surface.CreateFont("bash-mono-24", {
		font = "Ubuntu Mono",
		size = 24
	});
end
hook.Add("InitPostEntity", "BASH_FontBug", loadFonts);

function BASH:Init()
	if self.Initialized then return end;

	self:LibInit();
	hook.Call("OnInit", self);
	MsgCon(color_darkgreen, true, "Successfully initialized client-side. Init time: %f seconds.", math.Round(SysTime() - self.StartTime, 5));
	self.Initialized = true;
end

function BASH:Exit()
	hook.Call("OnExit", self);
	MsgCon(color_darkgreen, true, "Finalizing shutdown. Uptime: %f minutes.", math.Round((SysTime() - self.StartTime) / 60, 5));
end

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy1");
timer.Destroy("HintSystem_Annoy2");
concommand.Remove("gm_save");
concommand.Remove("act");
loadFonts();
