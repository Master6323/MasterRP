//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_garbagezone_included_
  #endinput
#endif
#define _rp_garbagezone_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Defines:
#define MAXGARBAGE		100
#define MAXGARBAGEZONE		10

//Garbage system:
static Garbage[2047] = {0,...};
static Float:GarbageZones[MAXGARBAGEZONE + 1][3];
static Float:TrashCans[MAXGARBAGEZONE + 1][3];
static GarbageOnMap = 0;

static String:TrashCanModel[255] = "models/props_junk/trashdumpster02.mdl";

public Action:PluginInfo_GarbageZone(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Server Trash SQL and Garbage Zone System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.04.48");
}

initGarbageZone()
{

	//Commands:
	RegAdminCmd("sm_creategarbagezone", Command_CreateGarbageZone, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removegarbagezone", Command_RemoveGarbageZone, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listgarbagezone", Command_ListGarbageZone, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipegarbagezones", Command_WipeGarbageZone, ADMFLAG_ROOT, "");

	//Commands:
	RegAdminCmd("sm_createtrashcan", Command_CreateTrashCan, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_savetrashcan", Command_SaveTrashCan, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removetrashcan", Command_RemoveTrashCan, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listtrashcan", Command_ListTrashCan, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_wipegarbagezones", Command_WipeGarbageZone, ADMFLAG_ROOT, "");

	//Clean map entitys:
	for(new X = 0; X < 2047; X++)
	{

		//Initialize:
		Garbage[X] = 0;
	}

	//Loop:
	for(new Z = 0; Z <= 10; Z++) for(new i = 0; i < 3; i++)
	{

		//Initulize:
		GarbageZones[Z][i] = 69.0;

		TrashCans[Z][i] = 69.0;
	}

	//PreCache Model
	PrecacheModel("models/props_junk/popcan01a.mdl");

	PrecacheModel("models/props_junk/garbage_takeoutcarton001a.mdl");

	PrecacheModel("models/props_junk/garbage_bag001a.mdl");

	PrecacheModel("models/props_junk/garbage_plasticbottle003a.mdl");

	PrecacheModel("models/props_junk/garbage_metalcan001a.mdl");

	PrecacheModel("models/props_junk/cardboard_box004a.mdl");

	PrecacheModel("models/sal/trash/binbag.mdl");

	//Timer
	CreateTimer(0.2, CreateSQLdbGarbageZone);

	CreateTimer(0.2, CreateSQLdbTrashCans);
}

ResetGarbage()
{

	//Clean map entitys:
	for(new X = 0; X < 2047; X++)
	{

		//Initialize:
		Garbage[X] = 0;
	}

	//Loop:
	for(new Z = 0; Z <= 10; Z++) for(new i = 0; i < 3; i++)
	{

		//Initulize:
		GarbageZones[Z][i] = 69.0;

		TrashCans[Z][i] = 69.0;
	}
}

initMapTrashCans()
{

	//Clean map entitys:
	for(new Ent = 0; Ent < 2047; Ent++)
	{

		if(IsValidEdict(Ent))
		{

			//Declare:
			decl String:ClassName[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Trash Can:
			if(StrContains(ClassName, "prop_physics", false) != -1)
			{

				//Declare:
				decl String:ModelName[128];

				//Initialize:
				GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

				//Is Trash Can:
				if(StrContains(ModelName, TrashCanModel, false) != -1)
				{

					//Added Effect:
					new Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

					SetEntAttatchedEffect(Ent, 0, Effect);

					//Set Trans Effect:
					SetEntityRenderMode(Ent, RENDER_GLOW);

					//Set Color:
					SetEntityRenderColor(Ent, 120, 255, 120, 145);
				}
			}
		}
	}
}
//Create Database:
public Action:CreateSQLdbGarbageZone(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `GarbageZone`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `ZoneId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:CreateSQLdbTrashCans(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `TrashCan`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `PropId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL, `Angles` varchar(64) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public initGarbage()
{

	//Loop:
	for(new Z = 0; Z <= 10; Z++)
	{

		//Check:
		if(GarbageZones[Z][0] != 69.0)
		{

			//Anti Spam
			if(GarbageOnMap < MAXGARBAGE)
			{

				//Declare:
				new Random = GetRandomInt(1, 3);

				//Loop:
				for(new R = 1; R <= Random; R++)
				{

					//Spawner:
					SpawnGarbageInZone(Z);
				}
			}
		}
	}

	//Print:
	if(GarbageOnMap >= MAXGARBAGE)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - The server is full of trash!");
	}
}

public initGarbageReset()
{
	//Initulize:
	GarbageOnMap = 0;
}

//Create Database:
public Action:LoadGarbageZone(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM GarbageZone WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadGarbageZones, query);
}

//Create Database:
public Action:LoadTrashCans(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM TrashCan WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadTrashCans, query);
}


//PlayerMenu Handle:
public HandleEmptyTrashCan(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			decl String:info[64]; new TrashCount, Float:Dist, String:query[255];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Ent = StringToInt(info);

			//Declare:
			new Float:EntOrigin[3], Float:TrashOrigin[3]; decl String:ClassName[32];

			//Initialize:
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);

			//Loop:
			for(new X = 0; X < 2047; X++)
			{

				//Is Valid:
				if(IsValidEdict(X) && IsValidEntity(X) && X != Ent && Ent > GetMaxClients() && Garbage[X] == 1)
				{

					//Get Entity Info:
					GetEdictClassname(Ent, ClassName, sizeof(ClassName));

					//Is Prop:
					if(StrEqual(ClassName, "prop_physics") || StrEqual(ClassName, "prop_physics_override"))
					{

						//Initialize:
						GetEntPropVector(X, Prop_Send, "m_vecOrigin", TrashOrigin);

						//Declare:
						Dist = GetVectorDistance(EntOrigin, TrashOrigin);

						//In Distance:
						if(Dist <= 175)
						{

							//Remove:
							AcceptEntityInput(X, "Kill");

							//Initulize:
							Garbage[X] = 0;

							//Initulize:
							TrashCount += 1;

							//Initulize:
							SetPropSpawnedTimer(X, -1);

							SetPropIndex((GetPropIndex() - 1));
						}
					}
				}
			}

			//No Trash:
			if(TrashCount == 0)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There was no trash in this dumpster!");
			}

			//Override:
			else
			{

				//Declare
				new AddCash = (TrashCount * 20);

				//Set Menu State:
				CashState(Client, AddCash);

				//Initulize:
				SetCash(Client, (GetCash(Client) + AddCash));

				GarbageOnMap -= TrashCount;

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have recycled %i props and earned â‚¬%i.", TrashCount, AddCash);

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

public bool:IsTrashCan(Ent)
{

	//Declare:
	decl String:ClassName[32];

	//Get Entity Info:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Trash Can:
	if(StrContains(ClassName, "prop_physics", false) != -1)
	{

		//Declare:
		decl String:ModelName[128];

		//Initialize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

		//Is Trash Can:
		if(StrContains(ModelName, TrashCanModel, false) != -1)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action:OnTrashCanUse(Client, Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Valid Job:
		if(StrContains(GetJob(Client), "Street Sweeper", false) != -1 || StrContains(GetJob(Client), "Root Admin", false) != -1 || StrEqual(GetJob(Client), "Admin", false))
		{

			//Declare:
			decl String:TrashCan[128];

			//Convert:
			IntToString(Ent, TrashCan, sizeof(TrashCan));

			//Handle:
			new Handle:Menu = CreateMenu(HandleEmptyTrashCan);

			//Menu Title:
			SetMenuTitle(Menu, "Would you like to empty\ntrash can, you gain experience\nfrom emptying the trash!");

			//Menu Button:
			AddMenuItem(Menu, TrashCan, "Empty Trash");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Set Menu Buttons:
			SetMenuPagination(Menu, 7);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
		}
	}

	//Return:
	return Plugin_Handled;
}

public SpawnGarbage(Client, Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 1800 && GarbageOnMap >= MAXGARBAGE)
	{

		//Return:
		return -1;
	}

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return -1;
	}

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEntity(Ent))
	{

		//Declare:
		new Float:ClientOrigin[3], Float:GarbageOrigin[3], Float:EyeAngles[3]; decl String:ModelName[256];

		if(Var == 1)
		{

			//Declare:
			new Roll = GetRandomInt(0, 2);

			if(Roll == 0)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_takeoutcarton001a.mdl";
			}

			if(Roll == 1)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_bag001a.mdl";
			}

			if(Roll == 2)
			{

				//Initulize:
				ModelName = "models/props_junk/garbage_metalcan001a.mdl";
			}
		}

		if(Var == 2)
		{

			//Initulize:
			ModelName = "models/props_junk/popcan01a.mdl";
		}

		if(Var == 3)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		if(Var == 4)
		{

			//Initulize:
			ModelName = "models/props_junk/garbage_plasticbottle003a.mdl";
		}

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		GarbageOrigin[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		GarbageOrigin[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		GarbageOrigin[2] = (ClientOrigin[2] + 100);

		//Teleport:
		TeleportEntity(Ent, GarbageOrigin, NULL_VECTOR, NULL_VECTOR);

		Garbage[Ent] = 1;

		GarbageOnMap++;

		//Initulize:
		SetPropSpawnedTimer(Ent, 0);

		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}

public SpawnGarbageInZone(ZoneId)
{

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

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
		ModelName = "models/sal/trash/binbag.mdl";

		//Dispatch:
		DispatchKeyValue(Ent, "physdamagescale", "0.0");

		DispatchKeyValue(Ent, "model", ModelName);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		new Float:Position[3]; new Float:Angles[3] = {0.0, 0.0, 0.0};

		//Initulize:
		Angles[1] = GetRandomFloat(0.0, 360.0);
		Position[0] = GarbageZones[ZoneId][0] + GetRandomFloat(-50.0, 50.0);
		Position[1] = GarbageZones[ZoneId][1] + GetRandomFloat(-50.0, 50.0);
		Position[2] = GarbageZones[ZoneId][2] + GetRandomFloat(-5.0, 5.0);

		//Teleport:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

		//Initulize:
		Garbage[Ent] = 1;

		GarbageOnMap++;

		//Initulize:
		SetPropSpawnedTimer(Ent, 0);

		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}

//Create Garbage Zone:
public Action:Command_CreateGarbageZone(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_creategarbagezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3]; decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	decl String:buffer[255], String:Position[32];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
	//Spawn Already Created:
	if(GarbageZones[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(buffer, sizeof(buffer), "UPDATE GarbageZone SET Position = '%s' WHERE Map = '%s' AND ZoneId = %i;", Position, ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(buffer, sizeof(buffer), "INSERT INTO GarbageZone (`Map`,`ZoneId`,`Position`) VALUES ('%s',%i,'%s');", ServerMap(), StringToInt(ZoneId), Position);
	}

	//Initulize:
	GarbageZones[StringToInt(ZoneId)] = ClientOrigin;

	//Override:
	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action:Command_RemoveGarbageZone(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removegarbagezone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Zone:
	if(GarbageZones[StringToInt(ZoneId)][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	GarbageZones[StringToInt(ZoneId)][0] = 69.0;

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "DELETE FROM GarbageZone WHERE ZoneId = %i  AND Map = '%s';", StringToInt(ZoneId), ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Garbage Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListGarbageZone(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Garbage Spawns: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= MAXGARBAGEZONE; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM GarbageZone WHERE Map = '%s' AND ZoneId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintGarbageZones, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Beta:
public Action:Command_WipeGarbageZone(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Garbage Spawns Wiped: %s", ServerMap());

	//Declare:
	decl String:buffer[255];

	//Loop:
	for(new X = 1; X < MAXGARBAGEZONE; X++)
	{

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM GarbageZone WHERE ZoneId = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);
	}

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action:Command_CreateTrashCan(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3], Float:Origin[3], Float:EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Spawn Prop
	new Ent = CreateProp(Origin, EyeAngles, TrashCanModel, false, false, false);

	//Added Effect:
	new Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Set Trans Effect:
	SetEntityRenderMode(Ent, RENDER_GLOW);

	//Set Color:
	SetEntityRenderColor(Ent, 120, 255, 120, 145);

	//Return:
	return Plugin_Handled;
}

//Create Garbage Zone:
public Action:Command_SaveTrashCan(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createTrashCan <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Check:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(!IsTrashCan(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Origin[3], Float:Angles[3]; 

	//Initluze:
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin);

	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Declare:
	decl String:query[512], String:Position[64], String:Ang[64];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", Origin[0], Origin[1], Origin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Spawn Already Created:
	if(TrashCans[StringToInt(ZoneId)][0] != 69.0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE TrashCan SET Position = '%s', Angles = '%s' WHERE Map = '%s' AND PropId = %i;", Position, Ang, ServerMap(), StringToInt(ZoneId));
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO TrashCan (`Map`,`PropId`,`Position`,`Angles`) VALUES ('%s',%i,'%s','%s');", ServerMap(), StringToInt(ZoneId), Position, Ang);
	}

	//Accept:
	AcceptEntityInput(Ent, "disablemotion", Ent);

	//Initulize:
	TrashCans[StringToInt(ZoneId)] = Origin;

	//Override:
	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created spawn \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", ZoneId, Origin[0], Origin[1], Origin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action:Command_RemoveTrashCan(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeTrashCan <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ZoneId[32];

	//Initialize:
	GetCmdArg(1, ZoneId, sizeof(ZoneId));

	//No Zone:
	if(TrashCans[StringToInt(ZoneId)][0] == 69.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no spawnpoint found in the db. (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	TrashCans[StringToInt(ZoneId)][0] = 69.0;

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "DELETE FROM TrashCan WHERE PropId = %i  AND Map = '%s';", StringToInt(ZoneId), ServerMap);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Garbage Zone (ID #\x0732CD32%s\x07FFFFFF)", ZoneId);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListTrashCan(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Garbage Spawns: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= MAXGARBAGEZONE; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM TrashCan WHERE Map = '%s' AND PropId = %i;", ServerMap, X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintTrashCans, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Beta:
public Action:Command_WipeTrashCan(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Garbage Spawns Wiped: %s", ServerMap());

	//Declare:
	decl String:buffer[255];

	//Loop:
	for(new X = 1; X < MAXGARBAGEZONE; X++)
	{

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM TrashCan WHERE PropId = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBLoadGarbageZones(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadGarbageZones: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Garbage Zones Found in DB!");

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
			GarbageZones[X] = Position;
		}

		//Print:
		PrintToServer("|RP| - Garbage Zones Loaded!");
	}
}

public T_DBLoadTrashCans(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadTrashCans: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Trash Cans Found in DB!");

			//Return:
			return;
		}

		//Declare:
		decl String:Buffer[64];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:Dump[3][64]; new Float:Origin[3], Float:Angles[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Origin[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angles[Y] = StringToFloat(Dump[Y]);
			}

			//Spawn Prop
			new Ent = CreateProp(Origin, Angles, TrashCanModel, false, true, false);

			//Added Effect:
			new Effect = CreateLight(Ent, 1, 120, 255, 120, "null");

			SetEntAttatchedEffect(Ent, 0, Effect);

			//Set Trans Effect:
			SetEntityRenderMode(Ent, RENDER_GLOW);

			//Set Color:
			SetEntityRenderColor(Ent, 120, 255, 120, 145);
		}

		//Print:
		PrintToServer("|RP| - Trash Cans Loaded!");
	}
}

public T_DBPrintGarbageZones(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintGarbageZones: Query failed! %s", error);
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
			SQL_FetchString(hndl,2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

public T_DBPrintTrashCans(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintTrashCan: Query failed! %s", error);
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
			SQL_FetchString(hndl,2, Buffer, 64);

			//Print:
			PrintToConsole(Client, "%i: <%s>", ZoneId, Buffer);
		}
	}
}

public bool:IsValidGarbage(Ent)
{

	//Check:
	if(Garbage[Ent] == 1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public GetGarbage(Ent)
{

	//Return:
	return Garbage[Ent];
}

public SetGarbage(Ent, Value)
{

	//Initulize:
	Garbage[Ent] = Value;
}

public GetGarbageOnMap()
{

	//Return:
	return GarbageOnMap;
}

public SetGarbageOnMap(Value)
{

	//Initulize:
	GarbageOnMap = Value;
}
