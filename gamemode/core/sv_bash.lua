local BASH = BASH;

function BASH:Init()
	if self.Initialized then return end;

	self:LibInit();

	MsgCon(color_green, true, "Successfully initialized server-side. Init time: %f seconds.", math.Round(SysTime() - self.StartTime, 5));
	self.Initialized = true;
	hook.Call("OnInit", self);
end

function BASH:Exit()
	self.Config:Exit();

	hook.Call("OnExit", self);
	MsgCon(color_green, true, "Finalizing shutdown. Uptime: %f minutes.", math.Round((SysTime() - self.StartTime) / 60, 5));
end

concommand.Add("gm_save", function(ply, cmd, arg)
	if checkply(ply) then ply:Kick("Nice try small idiot") end;
end);
