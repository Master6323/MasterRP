//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sleeping_included_
  #endinput
#endif
#define _rp_sleeping_included_

//Sleeping:
static Sleeping[MAXPLAYERS + 1] = {0,...};

//Couch Models:
static String:Couch01[255] = "models/props_c17/FurnitureCouch001a.mdl";

public Action:PluginInfo_Sleeping(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Sleeping Mod!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initSleeping()
{

	//Commands:
	RegConsoleCmd("sm_wakeup", Command_Wakeup);
}

Action:OnCouchUse(Client, Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Declare:
			new bool:Result = false;

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Check:
					if(Sleeping[i] == Ent)
					{

						//Initulize:
						Result = true;
					}
				}
			}

			//Check:
			if(Result == false)
			{

				//Sleeping:
				Sleeping[Client] = Ent;

				//Declare:
				new Float:CouchOrigin[3];

				//Get Prop Data:
				GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", CouchOrigin);

				//Initulize:
				CouchOrigin[2] -= 15;

				//Teleport:
				TeleportEntity(Client, CouchOrigin, NULL_VECTOR, NULL_VECTOR);

				//Set Speed:
				SetEntitySpeed(Client, 0.0);

				//Set Screen:
				PerformBlind(Client, 250);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - type '!wakeup' to get off the couch!");

				// Noblock active ie: Players can walk thru each other
				SetEntData(Client, GetCollisionOffset(), 2, 4, true);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - A player is already sleeping on this couch!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Couch!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}

	//Return:
	return Plugin_Handled;
}

Action:CouchHud(Client, Ent)
{

	//Declare:
	new bool:Result = false; new Player = 0; new len = 0;
	decl String:CouchHudMessage[255];

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Check:
			if(Sleeping[i] == Ent && Sleeping[i] != -1 && i != 33)
			{

				//Initulize:
				Result = true;

				Player = i;

				//Break:
				break;
			}
		}
	}

	//Check:
	if(Result == true)
	{

		//Format:
		len += Format(CouchHudMessage[len], sizeof(CouchHudMessage)-len, "Sleeping:\n%N is sleeping on this couch!", Player);
	}

	//Override:
	else
	{

		//Format:
		len += Format(CouchHudMessage[len], sizeof(CouchHudMessage)-len, "Sleeping:\nPress <<Use>> to go to sleep on the couch!");
	}

	//Setup Hud:
	SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

	//Show Hud Text:
	ShowHudText(Client, 1, CouchHudMessage);
}

public Action:Command_Wakeup(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - this command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Sleeping[Client] != -1)
	{

		//Declare:
		new Ent = Sleeping[Client];

		//Declare:
		new Float:CouchOrigin[3];

		//Get Prop Data:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", CouchOrigin);

		//Initulize:
		CouchOrigin[2] += 18;

		//Teleport:
		TeleportEntity(Client, CouchOrigin, NULL_VECTOR, NULL_VECTOR);

		//Set Speed:
		SetEntitySpeed(Client, 1.0);

		//Set Screen:
		PerformUnBlind(Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have woke up from sleep!");

		//Initulize:
		Sleeping[Client] = -1;

		// CAN NOT PASS THRU ie: Players can jump on each other
		SetEntData(Client, GetCollisionOffset(), 5, 4, true);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not asleep you can't wakeup!");
	}

	//Return:
	return Plugin_Handled;
}

public IsSleeping(Client)
{

	//Return:
	return Sleeping[Client];
}

//Disconnect:
public Action:ResetSleeping(Client)
{

	//Initulize:
	Sleeping[Client] = -1;
}

bool:IsValidCouch(Ent)
{

	//Declare:
	decl String:ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Valid:
	if(StrContains(ClassName, "Prop", false) != -1)
	{

		//Declare:
		decl String:ModelName[128];

		//Initialize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Valid:
		if(StrContains(ModelName, Couch01, false) != -1)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}
