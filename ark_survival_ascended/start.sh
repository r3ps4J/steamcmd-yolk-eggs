rmv() { echo "stopping server"; rcon -t rcon -a 127.0.0.1:${RCON_PORT} -p ${ARK_ADMIN_PASSWORD} KeepAlive && rcon -t rcon -a 127.0.0.1:${RCON_PORT} -p ${ARK_ADMIN_PASSWORD} DoExit && wait ${ARK_PID}; echo "Server Closed"; exit; }; trap rmv 15 2; proton run ./ShooterGame/Binaries/Win64/ArkAscendedServer.exe {{SERVER_MAP}}?listen?MaxPlayers={{MAX_PLAYERS}}?SessionName=\"{{SESSION_NAME}}\"?Port={{SERVER_PORT}}?QueryPort={{QUERY_PORT}}?RCONPort={{RCON_PORT}}?RCONEnabled=True$( [  "$SERVER_PVE" == "0" ] || printf %s '?ServerPVE=True' )?ServerPassword="{{SERVER_PASSWORD}}"{{ARGS_PARAMS}}?ServerAdminPassword="{{ARK_ADMIN_PASSWORD}}" -WinLiveMaxPlayers={{MAX_PLAYERS}} -oldconsole -servergamelog $( [ -z "$MOD_IDS" ] || printf %s ' -mods=' $MOD_IDS )$( [ "$BATTLE_EYE" == "1" ] || printf %s ' -NoBattlEye' ) -Port={{SERVER_PORT}} {{ARGS_FLAGS}} & ARK_PID=$! ; tail -c0 -F ./ShooterGame/Saved/Logs/ShooterGame.log --pid=$ARK_PID & until echo "waiting for rcon connection..."; (rcon -t rcon -a 127.0.0.1:${RCON_PORT} -p ${ARK_ADMIN_PASSWORD})<&0 & wait $!; do sleep 5; done