local BASH = BASH;

/*
**  Client-Side Network Strings
*/
util.AddNetworkString("BASH_PLAYER_INIT");

net.Receive("BASH_PLAYER_INIT", function(len, ply)
    hook.Call("PostEntInitialize", BASH, ply);
end);
