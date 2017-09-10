//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcdynamic_included_
  #endinput
#endif
#define _rp_npcdynamic_included_

#define MAXNPCSPAWNS		10
#define MAXNPCTYPES		10

static Float:Spawns[MAXNPCSPAWNS + 1][MAXNPCTYPES + 1][3];

//Track Client Damage
static Float:ClientDamage[MAXPLAYERS + 1];
static NpcsOnMap = 0;

public Action:PluginInfo_NpcDynamic(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Game Description Changer!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initNpcDynamic()
{

	//Commands
	RegAdminCmd("sm_createnpcspawn", Command_CreateNpcSpawn, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removenpcspawn", Command_RemoveNpcSpawn, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listnpcspawn", Command_ListNpcSpawn, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipenpcspawns", Command_WipeNpcSpawn, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbNpcSpawns);

	//Loop:
	for(new Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Initialize:
		ClientDamage[Client] = 0.0;
	}

	//Loop:
	for(new Z = 0; Z <= MAXNPCSPAWNS; Z++) for(new Y = 0; Y <= MAXNPCTYPES; Y++) for(new i = 0; i < 3; i++)
	{

		//Initulize:
		Spawns[Z][Y][i] = 69.0;
	}
}

//Create Database:
public Action:CreateSQLdbNpcSpawns(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NpcSpawns`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `SpawnId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `NpcType` int(12) NULL, `Position` varchar(64) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadNpcSpawns(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NpcSpawns WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLoadNpcSpawns, query);
}

public T_DBLoadLoadNpcSpawns(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNpcSpawns: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Dynamic Npc Spawns Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new X, Type; decl String:Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 2);

			//Declare:
			decl String:Dump[3][64]; new Float:Position[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			Spawns[X][Type] = Position;
		}

		//Print:
		PrintToServer("|RP| - Dynamic Npc Spawns Loaded!");
	}
}

//Create Npc Spawn:
public Action:Command_CreateNpcSpawn(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createnpcspawns <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Id, Type, Float:ClientOrigin[3]; decl String:sId[32], String:sType[32];

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	GetCmdArg(2, sType, sizeof(sType));

	GetClientAbsOrigin(Client, ClientOrigin);

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	//Declare:
	decl String:query[512], String:Position[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Spawn Already Created:
	if(Spawns[Id][Type][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NpcSpawns SET Position = '%s' WHERE Map = '%s' AND SpawnId = %i AND NpcType = %i;", Position, ServerMap(), Id, Type);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NpcSpawns (`Map`,`SpawnId`,`NpcType`,`Position`) VALUES ('%s',%i,%i,'%s');", ServerMap(), Id, Type, Position);
	}

	//Initulize:
	Spawns[Id][Type] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Npc Spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", Id, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Npc Spawn:
public Action:Command_RemoveNpcSpawn(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removenpcspawn <id> <type>");

		//Return:
		return Plugin_Handled;
	}


	//Declare:
	new Id, Type; decl String:sId[32], String:sType[32];

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	GetCmdArg(2, sType, sizeof(sType));

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	//Spawn Already Created:
	if(Spawns[Id][Type][0] != 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", Id);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NpcSpawns WHERE SpawnId = %i AND NpcType = %i AND Map = '%s';", Id, Type, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed NpcSpawn (ID #\x0732CD32%s\x07FFFFFF)", Id);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListNpcSpawn(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Npc Spawn List: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= MAXNPCSPAWNS; X++)
	{

		//Loop:
		for(new Y = 0; Y <= MAXNPCTYPES; Y++)
		{

			//Format:
			Format(query, sizeof(query), "SELECT * FROM NpcSpawns WHERE Map = '%s' AND SpawnId = %i AND NpcType = %i;", ServerMap(), X, Y);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBPrintNpcSpawn, query, conuserid);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:Command_WipeNpcSpawn(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Npc Spawn List Wiped: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 1; X < MAXTHUMPERS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM NpcSpawns WHERE SpawnId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintNpcSpawn(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintNpcSpawn: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SpawnId, Type, String:Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: Type %i <%s>", SpawnId, Type, Buffer);
		}
	}
}

public Action:NpcHealthHud(Client, Ent)
{

	//Declare:
	decl String:FormatMessage[255];

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "NPC:\nHealth: %i!", GetEntHealth(Ent));

	//Setup Hud:
	SetHudTextParams(-1.0, -0.805, 1.0, 50, 255, 50, 200, 0, 6.0, 0.1, 0.2);

	//Show Hud Text:
	ShowHudText(Client, 1, FormatMessage);
}

public bool:IsValidDymamicNpc(Ent)
{

	//Declare:
	decl String:ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Valid NPC:
	if(StrContains(ClassName, "npc_", false) == 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public GetNpcsOnMap()
{

	//Return:
	return NpcsOnMap;
}

public SetNpcsOnMap(Amount)
{

	//Initulize:
	NpcsOnMap = Amount;
}

public Float:GetDamage(Client)
{

	//Return:
	return ClientDamage[Client];
}

public SetDamage(Client, Float:Amount)
{

	//Initulize:
	ClientDamage[Client] = Amount;
}

public AddDamage(Client, Float:Amount)
{

	//Initulize:
	ClientDamage[Client] += Amount;
}

public GetDynamicNpcSpawn(Id, Type, Float:Origin[3])
{

	//Initulize:
	Origin = Spawns[Id][Type];
}