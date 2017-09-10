//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_teamfix_included_
  #endinput
#endif
#define _rp_teamfix_included_

public Action:PluginInfo_TeamFix(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Team Fix And Blocker!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V2.11.52");
}

//ManageTeams:
public Action:OnManageClientTeam()
{

	//Loop:
	for(new Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client) && IsLoaded(Client))
		{

			//FakeClient:
			if(IsFakeClient(Client))
			{

				//Initulize:
				ChangeClientTeam(Client, 1);
			}

			else if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0)) 
			{

				//Initulize VIP
				ChangeClientTeamEx(Client, 3);
				ChangeClientTeam(Client, 3);
				ChangeClientTeamEx(Client, 1);
			}

			//Is Client Cop:
			else if(IsCop(Client))
			{

				//Initulize:
				ChangeClientTeamEx(Client, 2);
				ChangeClientTeam(Client, 2);
			}

			//Override:
			else
			{
				//Initulize:
				ChangeClientTeamEx(Client, 3);
				ChangeClientTeam(Client, 3);
			}

			//Declare:
			decl String:ModelName[128];

			//Initialize:
			GetEntPropString(Client, Prop_Data, "m_ModelName", ModelName, 128);

			//Is PreCached:
			if(!IsModelPrecached(GetModel(Client)))
			{

				//PreCache:
				PrecacheModel(GetModel(Client));
			}

			//Initialize:
			//SetEntityModel(Client, ModelName);
			SetEntityModel(Client, GetModel(Client));
		}
	}
}

