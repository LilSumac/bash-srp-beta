local BASH = BASH;

function BASH:Initialize()
	surface.CreateFont("bash-icons-1", {
		font = "bash-icons-1",
		size = 16
	});
	surface.CreateFont("bash-icons-2", {
		font = "bash-icons-2",
		size = 16
	});
end

function BASH:Init()
	if self.Initialized then return end;

	self.Cookies:Init();
	self.GUI:Init();
	self.Themes:Init();
	self.Commands:Init();
	self.Config:Init();
	self.Modules:Init();
	self.Ranks:Init();
	self.Registry:Init();

	hook.Call("OnInit", self);
	MsgCon(color_green, true, "Successfully initialized client-side. Init time: %f seconds.", math.Round(SysTime() - self.StartTime, 5));
	self.Initialized = true;
end

function BASH:Exit()
	hook.Call("OnExit", self);
	MsgCon(color_green, true, "Finalizing shutdown. Uptime: %f minutes.", math.Round((SysTime() - self.StartTime) / 60, 5));
end

timer.Destroy("HintSystem_OpeningMenu");
timer.Destroy("HintSystem_Annoy1");
timer.Destroy("HintSystem_Annoy2");
concommand.Remove("gm_save");
concommand.Remove("act");
