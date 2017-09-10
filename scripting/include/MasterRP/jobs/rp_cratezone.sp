//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cratezone_included_
  #endinput
#endif
#define _rp_cratezone_included_

//Defines:
#define MAXCRATEZONES		10

//Random Supply Crate!
static Float:CrateZones[MAXCRATEZONES + 1][3];
static SupplyCrateTimer = 0;
static CrateEnt = -1;

public Action:PluginInfo_CrateZones(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Random Supply Crates!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initRandomCrate()
{

	//Random Supply Crates
	RegAdminCmd("sm_createrandomcrate", CommandCreateRandomCrateZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removerandomcrate", CommandRemoveRandomCrateZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listrandomcrates", CommandListRandomCrates, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta
	RegAdminCmd("sm_wipecratezones", Command_WipeCrateZone, ADMFLAG_ROOT, "");

	//Timers:
	CreateTimer(0.2, CreateSQLdbRandomCrateZone);

	//PreCache Model
	PrecacheModel("models/Items/item_item_crate.mdl");

	//Loop:
	for(new Z = 0; Z < MAXCRATEZONES; Z++)  for(new i = 0; i < 3; i++)
	{

		//Initulize:
		CrateZones[Z][i] = 69.0;
	}
}

//Create Database:
public Action:CreateSQLdbRandomCrateZone(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `RandomCrate`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadRandomCrateZone(Handle:Timer)
{

	//Loop:
	for(new Z = 0; Z <= 10; Z++) for(new i = 0; i < 3; i++)
	{

		//Initulize:
		CrateZones[Z][i] = 69.0;
	}

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM RandomCrate WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadRandomCrateZones, query);
}

public T_DBLoadRandomCrateZones(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadRandomCrateZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Random Crates Zones Found in DB!");

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

			//Initulize:
			CrateZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Random Crate Zones Found!");
	}
}

public T_DBPrintCrateZones(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintCrateZones: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new ZoneId, String:Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ZoneId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

// remove players from Vehicles before they are destroyed or the server will crash!
public OnCrateDestroyed(Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Someone Broke the RandomCrate:
		if(CrateEnt == Entity)
		{
			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - Someone has destroyed the suppy crate!");

			//Initulize:
			CrateEnt = -1;
		}
	}
}

//Client Hud:
public Action:initCrateTick()
{

	//Crates!
	if(CrateEnt != -1)
	{

		//Declare:
		decl Float:CrateOrigin[3];

		//Initulize:
		GetEntPropVector(CrateEnt, Prop_Data, "m_vecOrigin", CrateOrigin);

		//Declare:
		new Color[4] = {255, 255, 50, 255};

		//EntCheck:
		if(CheckMapEntityCount() < 2047)
		{

			//Show To Client:
			TE_SetupBeamRingPoint(CrateOrigin, 1.0, 50.0, Laser(), Sprite(), 0, 10, 1.0, 5.0, 0.5, Color, 10, 0);

			//Show To Client:
			TE_SendToAll();
		}
	}

	//Initulize:
	SupplyCrateTimer++;

	//TimerCheck
	if(SupplyCrateTimer >= 900)
	{

		//Initulize:
		SupplyCrateTimer = 0;

		//Invalid Check:
		if(CrateEnt == -1)
		{

			//Declare:
			new Var = GetRandomInt(0, 10);

			//Loop:
			for(new Z = 0; Z <= 10; Z++)
			{

				//Check:
				if(CrateZones[Z][0] != 69.0 && Var == Z)
				{

					//Spawn:
					SpawnCrate(Var);

					//Print:
					CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - A supply crate has been dropped!");
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - There is already a crate spawned on the map!");
		}
	}
}

//Use Handle:
public Action:OnCrateUse(Client, Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Remove Ent:
		AcceptEntityInput(CrateEnt, "Kill", Client);

		//Initulize:
		CrateEnt = -1;

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - The Supply Crate has been found by \x0732CD32%N\x07FFFFFF!", Client);

		//Random:
		new Random = GetRandomInt(0, 100); new R;

		if(Random >= 0 && Random < 5)
		{

			//Declare:
			R = GetRandomInt(500, 2000);

			SetBank(Client, (GetBank(Client) + R));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found \x0732CD32€%i!", R);
		}

		if(Random >= 5 && Random < 10)
		{

			//Initialize:
			//Item[Client][189] += 2;

			//Save:
			//SaveItem(Client, 189, Item[Client][189]);

			//Print
			//CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found 2x of %s!", ItemName[189]);
		}

		if(Random >= 10 && Random < 20)
		{

			//Declare:
			new AddValue = 500;

			//Initulize:
			SetResources(Client, (GetResources(Client) + AddValue));

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 500g of combine Resources!");
		}

		if(Random >= 20 && Random < 40)
		{

			//Initialize:
			//Item[Client][224] += 5;

			//Save:
			//SaveItem(Client, 224, Item[Client][224]);

			//Print
			//CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found 5x of %s!", ItemName[224]);
		}

		if(Random >= 50 && Random < 60)
		{

			//Declare:
			R = GetRandomInt(1, 10);

			if(R == 7) R = 1;

			//Initialize:
			//Item[Client][R] += 5;

			//Save:
			//SaveItem(Client, R, Item[Client][R]);

			//Print
			//CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have found 5x of %s!", ItemName[R]);
		}

		if(Random >= 60 && Random < 70)
		{

			//Slay Client:
			ForcePlayerSuicide(Client);

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been slayed!");
		}

		if(Random >= 70 && Random <= 100)
		{

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Found nothing in the supply crate!");
		}
	}
}

public SpawnCrate(Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return -1;
	}

	//Declare:
	new  Float:Position[3]; new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	Angles[1] = GetRandomFloat(0.0, 360.0);
	Position[0] = CrateZones[Var][0] + GetRandomFloat(-25.0, 25.0);
	Position[1] = CrateZones[Var][1] + GetRandomFloat(-25.0, 25.0);

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Unable to Drop Supply Crate Due to outside of world");

		PrintToServer("|RP| - Unable to Drop Supply Crate Due to outside of world");

		//Return:
		return -1;
	}

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		decl String:ModelName[256];

		//Initulize:
		ModelName = "models/Items/item_item_crate.mdl";

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Teleport:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

		//Set Damage:
		SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

		//Initulize:
		CrateEnt = Ent;
	}

	//Return:
	return Ent;
}

//Create Garbage Zone:
public Action:CommandCreateRandomCrateZone(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createrandomcrate <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3]; decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	decl String:query[512], String:Position[128];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(CrateZones[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE RandomCrate SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO RandomCrate (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	CrateZones[StringToInt(ZoneId)] = ClientOrigin;

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created random crate spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action:CommandRemoveRandomCrateZone(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removerandomcrate <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Zone:
	if(CrateZones[StringToInt(ZoneId)][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	CrateZones[StringToInt(ZoneId)][0] = 69.0;

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM RandomCrate WHERE ZoneId = %i  AND Map = '%s';", StringToInt(ZoneId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Random Crate Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:CommandListRandomCrates(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Random Crate Spawns: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= MAXCRATEZONES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM RandomCrate WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintCrateZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action:Command_WipeCrateZone(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Random Crate Spawns Wiped: %s", ServerMap());

	//Declare:
	decl String:query[255];

	//Loop:
	for(new X = 1; X < MAXCRATEZONES; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM RandomCrate WHERE ZoneId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool:IsRandomCrate(Client, Ent)
{

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Found Crate!
		if(CrateEnt == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public GetCrateEnt()
{

	//Return:
	return CrateEnt;
}

public SetCrateEnt(Ent)
{

	//Initulize:
	CrateEnt = Ent;
}