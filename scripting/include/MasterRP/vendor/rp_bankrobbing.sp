//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bankrobbing_included_
  #endinput
#endif
#define _rp_bankrobbing_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

#define MAXNPCS			30

static Float:RobOrigin[MAXPLAYERS + 1][3];
static RobCash[MAXPLAYERS + 1] = {0,...};

static RobNPC[MAXNPCS + 1];


initBankRobbing()
{

	//Loop:
	for(new X = 1; X <= MAXNPCS; X++)
	{

		//Is Valid:
		if(RobNPC[X] > 0)
		{

			//Initulize:
			RobNPC[X] -= 1;
		}
	}
}

public Action:BeginBankRob(Client, const String:Name[32], NPCCash, Id)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to rob the Banker!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are cuffed you can't robbing!");

		//Return:
		return Plugin_Continue;
	}

	//In Critical:
	else if(GetIsCritical(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You have to weak to robbing");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(RobCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are already robbing!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(GetEnergy(Client) < 15)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You don't have enough energy to rob this \x0732CD32%s\x07FFFFFF!", Name);

		//Return:
		return Plugin_Continue;
	}

	//Ready:
	else if(RobNPC[Id] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This \x0732CD32%s\x07FFFFFF has been robbed too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", Name, RobNPC[Id]);

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Initulize:
		SetEnergy(Client, (GetEnergy(Client) - 15));

		//Is Valid:
		if(IsAdmin(Client) || StrContains(GetJob(Client), "Street Thug", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Is Banker:
			if(StrContains(Name, "Banker", false) != -1)
			{

				//Initialize:
				SetJobExperience(Client, (GetJobExperience(Client) + 6));
			}

			//Is Vendor:
			if(StrContains(Name, "Vendor", false) != -1)
			{

				//Initialize:
				SetJobExperience(Client, (GetJobExperience(Client) + 4));
			}

			//Override:
			else
			{

				//Initialize:
				SetJobExperience(Client, (GetJobExperience(Client) + 2));
			}

		}

		//Declare:
		new Float:Origin[3];

		//Initialize:
		GetClientAbsOrigin(Client, Origin);

		//Initialize:
		RobOrigin[Client] = Origin;

		//Save:
		RobNPC[Id] = 600;

		//Start:
		RobCash[Client] = NPCCash;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is robbing a \x0732CD32%s\x07FFFFFF!", Client, Name);

		//Timer:
		CreateTimer(1.0, BeginRobberyBank, Client, TIMER_REPEAT);
	}

	//Return:
	return Plugin_Continue;
}

public Action:BeginRobberyBank(Handle:Timer, any:Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client)) return Plugin_Handled;

	//Cleared:
	if(RobCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped robbing an NPC!", Client);

		//Initulize::
		RobCash[Client] = 0;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Dist, Float:ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	Dist = GetVectorDistance(RobOrigin[Client], ClientOrigin);

	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		RobCash[Client] = 0;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "SELECT * FROM `Player` ORDER BY RANDOM() LIMIT 1;");

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadRandomPlayer, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public T_LoadRandomPlayer(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Banking] T_LoadRandomPlayer: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:query[255];

			//Declare:
			new SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading INTEGER:
			new OldBank = SQL_FetchInt(hndl, 4);

			//Declare:
			new Random;

			//Is Valid:
			if(StrContains(GetJob(Client), "Street Thug", false) != -1 || IsAdmin(Client))
			{

				//Initulize:
				Random = GetRandomInt(5, 10);
			}

			//Override:
			else
			{

				//Initulize:
				Random = GetRandomInt(2, 5);
			}

			//Initulize:
			RobCash[Client] -= Random;

			//Initialize:
			SetCash(Client, (GetCash(Client) + Random));

			//Initialize:
			SetCrime(Client, (GetCrime(Client) + (Random * Random)));

			//Set Menu State:
			CashState(Client, Random);

			//Declare:
			new NewBank = 0;

			//Check:
			if((OldBank - Random) > 0)
			{

				//Initialize:
				NewBank = (OldBank - Random);
			}

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SteamId == SteamIdToInt(i))
					{

						//Initialize:
						SetBank(i, NewBank);

						//Set Menu State:
						BankState(i, (Random *= -1));

						//Print
						OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Cash has been stolen from your bank account!");
					}
				}
			}

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", NewBank, SteamId);

			//Update Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}
