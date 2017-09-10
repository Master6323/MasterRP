/////////////////////////////////////////////////////////////////////
/////			      Database:				/////
/////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_spawns_included_
  #endinput
#endif
#define _rp_spawns_included_

//Max HL2 Spawns:
#define MAXSPAWNS		32

//Spawns:
static Float:SpawnPoints[MAXSPAWNS + 1][3];
static Float:CopSpawnPoints[MAXSPAWNS + 1][3];
static bool:ValidSpawn[2] = {false,...};

public Action:PluginInfo_Spawns(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Spawn System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initSpawn()
{

	//Commands:
	RegAdminCmd("sm_createspawn", CommandCreateSpawn, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removespawn", CommandRemoveSpawn, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_spawnlist", CommandListSpawns, ADMFLAG_SLAY, "Lists all the Spawnss in the database");

	//Timer:
	CreateTimer(0.2, CreateSQLdbSpawnPoints);

	//Loop:
	for(new Z = 0; Z < MAXSPAWNS; Z++)  for(new i = 0; i < 3; i++)
	{

		//Initulize:
		SpawnPoints[Z][i] = 69.0;

		CopSpawnPoints[Z][i] = 69.0;
	}
}

ResetSpawns()
{

	//Loop:
	for(new Z = 0; Z < MAXSPAWNS; Z++)  for(new i = 0; i < 3; i++)
	{

		//Initulize:
		SpawnPoints[Z][i] = 69.0;

		CopSpawnPoints[Z][i] = 69.0;
	}
}

public InitSpawnPos(Client, Effect)
{

	//Get Job Type:
	new Type;

	//Check:
	if(IsCop(Client))
	{

		//Initulize:
		Type = 1;
	}

	//Override:
	else
	{

		//Initulize:
		Type = 0;
	}

	//Spawn:
	RandomizeSpawn(Client, Type);

	//Added Spawn Effect:
	if(Effect == 1) InitSpawnEffect(Client);
}

public InitSpawnEffect(Client)
{

	//Check:
	if(IsCop(Client))
	{

		DispatchKeyValue(Client, "TargetName", "Police");
	}

	//Check:
	else if(IsCop(Client))
	{

		DispatchKeyValue(Client, "TargetName", "Admin");
	}

	//Override:
	else
	{

		DispatchKeyValue(Client, "TargetName", "Player");
	}

	//Set Ent:
	SetEntProp(Client, Prop_Send, "m_iFOVStart", 150);
	SetEntPropFloat(Client, Prop_Send, "m_flFOVTime", GetGameTime());
	SetEntPropFloat(Client, Prop_Send, "m_flFOVRate", 3.0);

	//Declare:
	new Tesla = -1;

	//Is Cop:
	if(IsCop(Client)) Tesla = CreatePointTesla(Client, "eyes", "50 50 250");

	//Is Admin:
	else if(IsAdmin(Client)) Tesla = CreatePointTesla(Client, "eyes", "50 250 50");

	//Is Player:
	else Tesla = CreatePointTesla(Client, "eyes", "250 50 50");

	//Timer:
	CreateTimer(1.5, RemoveSpawnEffect, Tesla);
}

//Remove Effect:
public Action:RemoveSpawnEffect(Handle:Timer, any:Ent)
{

	//Is Valid:
	if(Ent > -1 && IsValidEdict(Ent))
	{

		//Accept Entity Input:
		AcceptEntityInput(Ent, "Kill");
	}
}

//Create Database:
public Action:CreateSQLdbSpawnPoints(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `SpawnPoints`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `Type` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SpawnId` int(12) NULL, `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadSpawnPoints(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpawnPoints, query);
}

public T_DBLoadSpawnPoints(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadSpawnPoints: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Spawns Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Type, SpawnId; decl String:Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Weapon Check:
			if(SpawnId < MAXSPAWNS)
			{

				//Database Field Loading Intiger:
				Type = SQL_FetchInt(hndl, 1);

				//Declare:
				decl String:Dump[3][64]; new Float:Position[3];

				//Database Field Loading String:
				SQL_FetchString(hndl, 3, Buffer, 64);

				//Convert:
				ExplodeString(Buffer, "^", Dump, 3, 64);

				//Loop:
				for(new X = 0; X <= 2; X++)
				{

					//Initulize:
					Position[X] = StringToFloat(Dump[X]);
				}

				if(Type == 0)
				{

					//Initulize:
					SpawnPoints[SpawnId] = Position;

					ValidSpawn[0] = true;
				}

				//Override:
				else
				{

					//Initulize:
					CopSpawnPoints[SpawnId] = Position;

					ValidSpawn[1] = true;
				}
			}
		}

		//Print:
		PrintToServer("|RP| - Spawns Loaded!");
	}
}

//Random Spawn:
public Action:RandomizeSpawn(Client, SpawnType)
{

	//Declare:
	new Roll = GetRandomInt(1, MAXSPAWNS);

	if(SpawnType == 0)
	{

		//Invalid Spawn:
		if(SpawnPoints[Roll][0] == 69.0 && ValidSpawn[0] == true)
		{

			//Set Spawn:
			RandomizeSpawn(Client, SpawnType);
		}
	}

	if(SpawnType == 1)
	{

		//Invalid Spawn:
		if(CopSpawnPoints[Roll][0] == 69.0 && ValidSpawn[1] == true)
		{

			//Set Spawn:
			RandomizeSpawn(Client, SpawnType);
		}
	}

	//Declare:
	new Float:RandomAngles[3];

	//Initialize:
	GetClientAbsAngles(Client, RandomAngles);

	RandomAngles[1] = GetRandomFloat(0.0, 360.0);

	if(SpawnType == 1)
	{

		//Teleport:
		TeleportEntity(Client, CopSpawnPoints[Roll], RandomAngles, NULL_VECTOR);
	}

	//Override:
	else
	{

		//Teleport:
		TeleportEntity(Client, SpawnPoints[Roll], RandomAngles, NULL_VECTOR);
	}
}

//Create NPC:
public Action:CommandCreateSpawn(Client, Args)
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
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createspawn <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3]; decl String:SpawnId[32],String:Type[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetCmdArg(2, Type, sizeof(Type));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	decl String:query[512], String:Position[32];
	new Spawn = StringToInt(SpawnId);
	new IsCopSpawn = StringToInt(Type);

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if((IsCopSpawn == 0 && SpawnPoints[Spawn][0] != 69.0) || (IsCopSpawn == 1 && CopSpawnPoints[Spawn][0] != 69.0))
	{

		//Format:
		Format(query, sizeof(query), "UPDATE SpawnPoints SET Position = '%s' WHERE Map = '%s' AND Type = %i AND SpawnId = %i;", Position, ServerMap(), IsCopSpawn, Spawn);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO SpawnPoints (`Map`,`Type`,`SpawnId`,`Position`) VALUES ('%s',%i,%i,'%s');", ServerMap(), IsCopSpawn, Spawn, Position);
	}

	if(IsCopSpawn == 1)
	{

		//Initulize:
		CopSpawnPoints[Spawn] = ClientOrigin;
	}

	//Override:
	else
	{

		//Initulize:
		SpawnPoints[Spawn] = ClientOrigin;
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action:CommandRemoveSpawn(Client, Args)
{

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removespawn <id> <Type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SpawnId[32], String:Type[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetCmdArg(2, Type, sizeof(Type));

	new Spawn = StringToInt(SpawnId);
	new IsCopSpawn = StringToInt(Type);

	//No Spawn:
	if((IsCopSpawn == 1 && CopSpawnPoints[Spawn][0] == 69.0) || (IsCopSpawn == 0 && SpawnPoints[Spawn][0] == 69.0))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF  TYPE #\x0732CD32%s\x07FFFFFF)", SpawnId, Type);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM SpawnPoints WHERE SpawnId = %i AND Type = %i AND Map = '%s';", Spawn, IsCopSpawn, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Spawn (ID #\x0732CD32%s\x07FFFFFF  TYPE #\x0732CD32%s\x07FFFFFF)", SpawnId, Type);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:CommandListSpawns(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Spawns:");

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= MAXSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Type = 0 AND Map = '%s' AND SpawnId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintSpawnList, query, conuserid);
	}

	//Timer:
	CreateTimer(1.5, CopList, Client);
		
	//Return:
	return Plugin_Handled;
}

//Load Spawn:
public Action:CopList(Handle:Timer, any:Client)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Cop Spawns:");

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSPAWNS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM SpawnPoints WHERE Type = 1 AND Map = '%s' AND SpawnId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintSpawnList, query, conuserid);
	}
}

public T_DBPrintSpawnList(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintSpawnList: Query failed! %s", error);
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
			SpawnId = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", SpawnId, Buffer);
		}
	}
}