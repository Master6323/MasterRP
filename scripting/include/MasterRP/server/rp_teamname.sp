//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_teamname_included_
  #endinput
#endif
#define _rp_teamname_included_

public Action:PluginInfo_TeamName(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Team Name Changer!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Set Team Name:
ReplaceTeamName()
{

	//Declare:
	new iEnt = -1;

	//Switch:
	while ((iEnt = FindEntityByClassname(iEnt, "team_manager")) != -1)
	{

		//Declare:
		decl String:sName[48];

		new iEntNum = 0;

		//Get Entity Team:
		iEntNum = GetEntData(iEnt, FindSendPropInfo("CTeam", "m_iTeamNum"));

		//Get Team:
		if(iEntNum == 3)
		{

			//Format:
			Format(sName, sizeof(sName), "Civilian");

			//Set Ent Data:
			SetEntDataString(iEnt, FindSendPropInfo("CTeam", "m_szTeamname"), sName, sizeof(sName));
		}

		if(iEntNum == 2)
		{

			//Format:
			Format(sName, sizeof(sName), "Civil Protection");

			//Set Ent Data:
			SetEntDataString(iEnt, FindSendPropInfo("CTeam", "m_szTeamname"), sName, sizeof(sName));
		}

		if(iEntNum == 1)
		{

			//Format:
			Format(sName, sizeof(sName), "VIP");

			//Set Ent Data:
			SetEntDataString(iEnt, FindSendPropInfo("CTeam", "m_szTeamname"), sName, sizeof(sName));
		}

		if(iEntNum == 0)
		{

			//Format:
			Format(sName, sizeof(sName), "Spectate");

			//Set Ent Data:
			SetEntDataString(iEnt, FindSendPropInfo("CTeam", "m_szTeamname"), sName, sizeof(sName));
		}
	}
}
