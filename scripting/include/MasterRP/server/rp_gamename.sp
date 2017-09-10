//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_gamename_included_
  #endinput
#endif
#define _rp_gamename_included_

public Action:PluginInfo_GameName(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Game Description Changer!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

public Action:OnGetGameDescription(String:GameDesc[64])
{

	//Check Is Map Running
	if(IsMapRunning())
	{

		//Declare:
		decl String:GameInfo[64];

		//Format:
		Format(GameInfo, sizeof(GameInfo), "DarkRP V%s", MainVersion());

		//Copy String:
		//strcopy(gameDesc, sizeof(gameDesc), GameInfo);

		//Format:
		Format(GameDesc, sizeof(GameDesc), "%s", GameInfo);

		//Return:
		return Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}