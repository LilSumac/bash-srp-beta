local BASH = BASH;
BASH.RegistryQueue = {};
BASH.LastRegistered = "";
local Player = FindMetaTable("Player");

/*
**	BASH Hooks
*/
function BASH:PostEntInitialize(ply)
	ply.Initialized = true;
	ply:SQLInit();
end

/*
**  Utility Functions
*/
function Player:Initialize()
	if !checkply(self) then return end;

	self:SetTeam(TEAM_SPECTATOR);
	self:StripAmmo();
	self:StripWeapons();
	self:Spectate(OBS_MODE_ROAMING);
	self:SetMoveType(MOVETYPE_NOCLIP);
	self:Freeze(true);
end

function Player:NoClip(clip)
	self:SetNoDraw(clip);
	self:SetNotSolid(clip);

	if self:GetActiveWeapon() and self:GetActiveWeapon():IsValid() then
		self:GetActiveWeapon():SetNoDraw(clip);
	end

	if clip then
		self:SetMoveType(MOVETYPE_NOCLIP);
		self:GodEnable();
	else
		self:SetMoveType(MOVETYPE_WALK);
		self:GodDisable();
	end
end
