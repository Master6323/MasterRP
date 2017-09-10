//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vipdoors_included_
  #endinput
#endif
#define _rp_vipdoors_included_

//Defines:
#define MAXVIPDOORS		50

//Police Doors:
static VipDoors[MAXVIPDOORS + 1] = {-1,...};

public Action:PluginInfo_VipDoors(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Vip Door Sytem");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

ResetVipDoors()
{

	//Loop:
	for(new i = 0; i <= MAXVIPDOORS; i++)
	{

		//Initulize:
		VipDoors[i] = -1;
	}
}

initVipDoors()
{

	//Vip Doors:
	RegAdminCmd("sm_createvipdoor", Command_CreateVipDoor, ADMFLAG_ROOT, "- <1-50> - Create a default Vip door.");

	RegAdminCmd("sm_removevipdoor", Command_RemVipDoor, ADMFLAG_ROOT, "- <1-50> - Remove a default Vip door.");

	RegAdminCmd("sm_listvipvoors", Command_ListVipDoors, ADMFLAG_SLAY, "- <No Args> - List the default Vip doors.");

	//Beta
	RegAdminCmd("sm_wipevipvoors", Command_WipeVipDoors, ADMFLAG_ROOT, "<No Args> - Remove All SQL Data");

	//Timer:
	CreateTimer(0.2, CreateSQLdbVipDoors);
}

//Create Database:
public Action:CreateSQLdbVipDoors(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VipDoors`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `EntId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadVipDoors(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVipDoors, query);
}

public T_DBLoadVipDoors(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVipDoors: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vip Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new X, Ent;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 2);

			//Initulize:
			VipDoors[X] = Ent;
		}

		//Print:
		PrintToServer("|RP| - Vip Doors Loaded!");
	}
}

//Use Handle:
public Action:OnVipDoorFuncUse(Client, Ent)
{

	//Check To Prevent Spam:
	if(!IsDoorOpening(Ent))
	{

		//Set:
		SetIsDoorOpening(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Unlock", Client);

		//Accept:
		AcceptEntityInput(Ent, "Toggle", Client);
/*
		//Declare:
		new Float:Origin[3]; decl String:Sound[128];

		//Format:
		Format(Sound, sizeof(Sound), "buttons/button3.wav");

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecVelocity", Origin);

		//Play Sound:
		EmitAmbientSound(Sound, Origin, Ent, SOUND_FROM_WORLD, SNDLEVEL_RAIDSIREN);
*/
	}
}

//Use Handle:
public Action:OnVipDoorPropShift(Client, Ent)
{

	//Set:
	SetIsDoorOpening(Ent, true);

	//Check To Prevent Spam:
	if(!IsDoorOpening(Ent))
	{

		//Set:
		SetIsDoorOpening(Ent, true);

		//Is Door Locked:
		if(GetDoorLocked(Ent))
		{

			//Initulize:
			SetDoorLocked(Ent, false);

			//Accept:
			AcceptEntityInput(Ent, "Unlock", Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - You have just Unlocked this door!");
		}

		//Is Door Locked:
		else
		{

			//Initulize:
			SetDoorLocked(Ent, true);

			//Accept:
			AcceptEntityInput(Ent, "Lock", Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - You have just Locked this door!");
		}

		//Accept:
		AcceptEntityInput(Ent, "Toggle", Client);
	}
}

public bool:NativeIsVipDoor(Ent)
{

	//Loop:
	for(new i = 0; i <= MAXVIPDOORS; i++)
	{

		//Is Vip Door:
		if(VipDoors[i] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action:Command_CreateVipDoor(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_createVipDoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Var = StringToInt(Arg);

	//Is Valid:
	if(Var > MAXVIPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Usage: sm_createVipDoor <\x0732CD320-%i\x07FFFFFF>", MAXVIPDOORS);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	new bool:alreadyadded = false;

	//Loop:
	for(new i = 0; i <= MAXVIPDOORS; i++)
	{

		//Is Vip Door:
		if(VipDoors[i] == Entdoor)
		{

			//Initulize:
			alreadyadded = true;
		}
	}

	//Check:
	if(alreadyadded)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i has already been added to the db!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(VipDoors[Var] > -1)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE VipDoors SET EntId = %i WHERE Map = '%s' AND DoorId = %i;", Entdoor, ServerMap(), Var);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO VipDoors (`Map`,`DoorId`,`EntId`) VALUES ('%s',%i,%i);", ServerMap(), Var, Entdoor);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initialize:
	VipDoors[Var] = Entdoor;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been added to the default Vip door database", Entdoor);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemVipDoor(Client, Args)
{

	//Is Valid:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removeVipDoor <ID>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new String:Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Var = StringToInt(Arg);

	//Is Valid:
	if(Var > MAXVIPDOORS || Var < 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Wrong Parameter Usage: sm_removeVipDoor <\x0732CD320-%i\x07FFFFFF>", 200);

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(VipDoors[Var] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door #%i isn't a Vip door!", Var);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	VipDoors[Var] = -1;

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM VipDoors WHERE DoorId = %i AND Map = '%s';", Var, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VipDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted to the default Vip door database", Var);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListVipDoors(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Vip Door List:");

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VipDoors WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVipDoors, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action:Command_WipeVipDoors(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 1; X < MAXVIPDOORS; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM VipDoors WHERE ThumperId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintVipDoors(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVipDoors: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new DoorId, EntId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			DoorId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			EntId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: <%i>", DoorId, EntId);
		}
	}
}
