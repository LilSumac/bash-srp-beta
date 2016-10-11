local BASH = BASH;

gameevent.Listen("player_disconnect");
hook.Add("player_disconnect", "BASH_Exit", function(data)
    if CLIENT then
        BASH:Exit();
    end
end);

/*
**  GMod Hooks
*/

/*
**  #!/BASH Hooks
*/
function BASH:InitModules() end;
