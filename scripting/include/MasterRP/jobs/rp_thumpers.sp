//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_thumpers_included_
  #endinput
#endif
#define _rp_thumpers_included_

//Defines:
#define PLUGINVERSION		"1.00.00"
#define MAXTHUMPERS		10

//Combine Thumper:
static ThumperValue[MAXTHUMPERS + 1];
static ThumperEnt[MAXTHUMPERS + 1];

public Action:PluginInfo_Thumpers(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Combine Thumpers and Resources!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Plugin Info:
public Plugin:myinfo =
{
	name = "Combine Thumpers - Extension",
	author = "Master(D)",
	description = "Extension for the Main Plugin",
	version = PLUGINVERSION,
	url = ""
};

initThumpers()
{

	//Entity Event Hook:
	HookEntityOutput("Prop_Thumper", "OnThumped", OnThumped);

	//Thumpers
	RegAdminCmd("sm_createthumper", Command_CreateThumper, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removethumper", Command_RemoveThumper, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listthumper", Command_ListThumpers, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipethumpers", Command_WipeThumpers, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbThumper);
}

//Create Database:
public Action:CreateSQLdbThumper(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Thumper`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ThumperId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadThumper(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Thumper WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadThumper, query);
}

//Thumped Event:
public OnThumped(const String:Output[], Caller, Activator, Float:Delay)
{

	//Is Valid:
	if(IsValidEdict(Caller))
	{

		//EntCheck:
		if(CheckMapEntityCount() < 2000)
		{

			//Declare:
			new Float:Origin[3];

			//Get Prop Data:
			GetEntPropVector(Caller, Prop_Send, "m_vecOrigin", Origin);

			//Temp Ent:
			TE_SetupSparks(Origin, NULL_VECTOR, 5, 5);

			//Send:
			TE_SendToAll();
		}

		//Loop:
		for(new X = 0; X < MAXTHUMPERS; X++)
		{

			//Valid:
			if(ThumperEnt[X] == Caller && ThumperValue[X] != 1000)
			{

				//Declare:
				new AddValue; AddValue += GetRandomInt(5, 10);

				//Too Much:
				if(ThumperValue[X] + AddValue > 1000)
				{

					//Initulize:
					ThumperValue[X] = 1000;
				}

				//Override:
				else
				{
					//Initulize:
					ThumperValue[X] += AddValue;
				}
			}
		}
	}
}

//Create Thumper:
public Action:Command_CreateThumper(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createthumper <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3]; decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	decl String:query[512], String:Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if(ThumperEnt[StringToInt(SpawnId)] > 0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Thumper SET Position = '%s' WHERE Map = '%s' AND ThumperId = %i;", Position, ServerMap(), StringToInt(SpawnId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Thumper (`Map`,`ThumperId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(SpawnId), Position);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Thumper \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action:Command_RemoveThumper(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removethumper <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Spawn Already Created:
	if(!IsValidEdict(ThumperEnt[StringToInt(SpawnId)]))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM Thumper WHERE ThumperId = %i AND Map = '%s';", StringToInt(SpawnId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Thumper (ID #\x0732CD32%s\x07FFFFFF)", SpawnId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListThumpers(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Thumper List: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= 10 + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM Thumper WHERE Map = '%s' AND ThumperId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintThumpers, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public Action:Command_WipeThumpers(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Thumper List Wiped: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 1; X < MAXTHUMPERS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM Thumpers WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBLoadThumper(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadThumper: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Thumpers Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new X; decl String:Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Declare:
			decl String:Dump[3][64]; new Float:Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Create Thumper:
			CreatePropThumper(Position, X);
		}

		//Print:
		PrintToServer("|RP| - Thumpers Found!");
	}
}

public T_DBPrintThumpers(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintThumpers: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SpawnId, String:Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}

//damage = 0
//size = 200 CreatePropThumper(ent, Pos, 1, "220", "0.0");
stock CreatePropThumper(Float:Pos[3], X)
{

	//Initulize::
	new Thumper = CreateEntityByName("Prop_Thumper");

	//Is Valid:
	if(IsValidEdict(Thumper))
	{

		//Declare:
		decl String:SpawnOrg[50];

		//Format:
		Format(SpawnOrg, sizeof(SpawnOrg), "%f %f %f", Pos[0], Pos[1], Pos[2]);

		//Dispatch:
		DispatchKeyValue(Thumper, "origin", SpawnOrg);

		DispatchKeyValue(Thumper, "model", "models/props_combine/CombineThumper002.mdl");

		DispatchKeyValue(Thumper, "dustscale", "5.0");

		//Spawn:
		DispatchSpawn(Thumper);

		//Accept:
		AcceptEntityInput(Thumper, "TurnOn");

		//Initulize:
		ThumperValue[X] = GetRandomInt(100, 200);

		ThumperEnt[X] = Thumper;
	}
}

//Handle Use Forward:
public Action:OnThumperUse(Client, Ent)
{

	//Is In Time:
	if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
	{

		//Loop:
		for(new X = 0; X < MAXTHUMPERS; X++)
		{

			//Valid:
			if(ThumperEnt[X] == Ent)
			{

				//Valid:
				if(ThumperValue[X] > 0)
				{

					//Has Energy:
					if(GetEnergy(Client) >= 100)
					{

						//Declare:
						new AddValue = ThumperValue[X];

						//Initulize:
						SetResources(Client, (GetResources(Client) + AddValue));

						ThumperValue[X] = 0;

						//Check:
						if(IsCop(Client))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Resources|\x07FFFFFF - You have collected \x0732CD32%i\x07FFFFFF combine resources", AddValue);
						}

						//Override:
						else
						{

							//Initulize:
							SetCrime(Client, (AddValue * 2 + GetCrime(Client)));

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP-Resources|\x07FFFFFF - You have Stolen \x0732CD32%i\x07FFFFFF combine resources", AddValue);
						}

						//Initialize:
						SetEnergy(Client, (GetEnergy(Client) - 100));
					}

					//Override:
					else	
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Resources|\x07FFFFFF - You Dont have enough energy to collect resources!");
					}
				}

				//Override:
				else	
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Resources|\x07FFFFFF - Combine Thumper has to resources to collect!");
				}
			}
		}

		//Initulize:
		SetLastPressedE(Client, 0.0);
	}

	//Override:
	else	
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Resources|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Gain Resorces!.");

		//Initulize:
		SetLastPressedE(Client, GetGameTime()); 
	}

	//Return:
	return Plugin_Handled;
}

public Action:ThumperHud(Client, Ent)
{

	//Loop:
	for(new X = 0; X < MAXTHUMPERS; X++)
	{

		//Valid:
		if(ThumperEnt[X] == Ent)
		{

			//Declare:
			decl String:FormatMessage[255];

			//Format:
			Format(FormatMessage, sizeof(FormatMessage), "Combine Thumper:\nResources %i!", ThumperValue[X]);

			//Setup Hud:
			SetHudTextParams(-1.0, -0.805, 1.0, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

			//Show Hud Text:
			ShowHudText(Client, 1, FormatMessage);
		}
	}
}

public bool:IsValidThumper(Ent)
{

	//Declare:
	decl String:ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "Prop_Thumper"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}