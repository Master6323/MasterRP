//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_props_included_
  #endinput
#endif
#define _rp_props_included_

initProps()
{

	//Remove Props:
	RegAdminCmd("sm_removemapprop", Command_RemoveMapProp, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_restoremapprop", Command_RestoreMapProp, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listremovedprops", Command_ListRemovedProps, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	//Beta:
	RegAdminCmd("sm_restoreallmapprops", Command_RestoreAllMapProp, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	//Prop Tools:
	RegAdminCmd("sm_location", Command_getLoc, ADMFLAG_SLAY, "Returns the actual location");

	RegAdminCmd("sm_entitylocation", Command_getEntLoc, ADMFLAG_SLAY, "Returns the actual location");

    	RegAdminCmd("sm_info", Command_GetSkin, ADMFLAG_SLAY, "Returns everything you can know of an entity");   

    	RegAdminCmd("sm_create", Command_Create, ADMFLAG_SLAY, "Creates an Entity");

	RegAdminCmd("sm_delete", Command_Delete, ADMFLAG_SLAY, "delete");

	RegAdminCmd("sm_getanglesbetween", Command_GetAnglesBetween, ADMFLAG_SLAY, "- Changes the Angles on an object");

	RegAdminCmd("sm_setangles", Command_SetAngles, ADMFLAG_SLAY, "- Changes the Angles on an object");

	RegAdminCmd("sm_addangles", Command_AddAngles, ADMFLAG_SLAY, "- Changes the Angles on an object");

	RegAdminCmd("sm_freezeit", Command_Freezeit, ADMFLAG_SLAY, "Save an prop");

	RegAdminCmd("sm_unfreezeit", Command_UnFreezeit, ADMFLAG_SLAY, "delete a item");

	RegAdminCmd("sm_walkthru", Command_WalkThru, ADMFLAG_SLAY, "walkthru");

	RegAdminCmd("sm_setskin", Command_SetSkin, ADMFLAG_SLAY, "Set Skin");

	//Timers:
	CreateTimer(0.2, CreateSQLdbMapProps);
}

//Create Database:
public Action:CreateSQLdbMapProps(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `RemovedProps`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `PropId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadRemoveMapProps(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM RemovedProps WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadRemoveMapProps, query);
}

public T_DBLoadRemoveMapProps(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadRemoveMapProps: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Remove Map Props Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new X;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			X = SQL_FetchInt(hndl, 1);

			//Check:
			if(IsValidEdict(X))
			{

				//Kill:
				AcceptEntityInput(X, "Kill");

				SetPropIndex((GetPropIndex() - 1));
			}
		}

		//Print:
		PrintToServer("|RP| - Removed Map Props!");
	}
}

//Create Thumper:
public Action:Command_RemoveMapProp(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ClassName[32];

	//Initulize:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Check:
	if(StrContains(ClassName, "prop", false) == 0 || StrContains(ClassName, "func", false) == 0)
	{

		//Declare:
		decl String:query[512];

		//Format:
		Format(query, sizeof(query), "INSERT INTO RemovedProps (`Map`,`PropId`) VALUES ('%s',%i);", ServerMap(), Ent);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - #%i has been removed from the map permenantly", Ent);

		//Kill:
		AcceptEntityInput(Ent, "Kill");

		SetPropIndex((GetPropIndex() - 1));
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Prop - %s", ClassName);
	}

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action:Command_RestoreMapProp(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_restoremapprop <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `RemovedProps` WHERE Map = '%s' AND PropId = %i;", ServerMap(), SpawnId);

	//Declare:
	new Handle:hDatabase = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hDatabase)
	{

		//Restart SQL:
		SQL_Rewind(hDatabase);

		//Declare:
		new bool:fetch = SQL_FetchRow(hDatabase);

		//Already Inserted:
		if(fetch)
		{

			//Format:
			Format(query, sizeof(query), "DELETE FROM `RemovedProps` WHERE Map = '%s' AND PropId = %i;", ServerMap(), SpawnId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - #%i Has been successfully restored", SpawnId);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - unable to find #%i in the database!", SpawnId);
		}
	}

	//Close:
	CloseHandle(hDatabase);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListRemovedProps(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Map Props Removed: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X <= 10 + 1; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM RemovedProps WHERE Map = '%s' AND PropId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintRemovedProps, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_RestoreAllMapProp(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Server Map Props Restored: %s", ServerMap());

	//Declare:
	decl String:buffer[255];

	//Loop:
	for(new X = 1; X < 2047; X++)
	{

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM RemovedProps WHERE PropId = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintRemovedProps(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintRemovedProps: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SpawnId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Print:
			PrintToConsole(Client, "%i", SpawnId);
		}
	}
}

public Action:Command_getLoc(Client,args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
    	decl Float:ClientOrigin[3];

	//Initulize:
    	GetClientAbsOrigin(Client, ClientOrigin);

	//Print:
    	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Actual Location \x0732CD32%f %f %f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);         

	//Return:
	return Plugin_Handled;
}

public Action:Command_getEntLoc(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Ent < GetMaxClients())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot change angles on a person!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Angles[3], Float:Position[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - [Entity: %d] [Position] %f %f %f [Angles] %f %f %f", Ent, Position[0], Position[1], Position[2], Angles[0], Angles[1], Angles[2]);

	//Return:
	return Plugin_Handled;
}

public Action:Command_GetSkin(Client,args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(IsValidEntity(Ent))
	{

		//Declare:
		decl String:modelname[128], String:name[128];

		//Initulize:
		GetEdictClassname(Ent, name, sizeof(name));

		GetEntPropString(Ent, Prop_Data, "m_ModelName", modelname, 128);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - SKIN \x0732CD32%s\x07FFFFFF CLASS \x0732CD32%s\x07FFFFFF ID \x0732CD32%d", modelname, name, Ent);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity!");
	}

	//Return:
	return Plugin_Handled;
}

public Action:Command_Create(Client,Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return Plugin_Handled;
	}

	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Useage: - sm_create <Model>");

		PrintToConsole(Client, "|RP| - Usage: Useage sm_create <Model>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:modelname[255];

	//Initulize:
	GetCmdArg(1, modelname, sizeof(modelname));

	PrecacheModel(modelname, true);

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
	new Ent = CreateEntityByName("prop_physics_override");

	DispatchKeyValue(Ent, "physdamagescale", "0.0");

	DispatchKeyValue(Ent, "model", modelname);

	DispatchSpawn(Ent);

	//Teleport:
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);   

	//Return:
	return Plugin_Handled;
}

public Action:Command_Delete(Client, args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Declare
		decl String:ClassName[32];

		//Is Valid:
		GetEdictClassname(Ent, ClassName, 32);

		//Is Prop:
		if(StrContains(ClassName, "prop", false) != -1)
		{

			//Remove:
			AcceptEntityInput(Ent, "Kill");

			//Initulize:
			SetPropIndex((GetPropIndex() - 1));
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);
		}	
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity!");	
	}

	//Return:
	return Plugin_Handled;
	
}

public Action:Command_GetAnglesBetween(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Angles[3];

	//Initulize:
	GetAngleBetweenEntities(Client, Ent, Angles);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - [Entity: %d] [Angles] %f %f %f", Ent, Angles[0], Angles[1], Angles[2]);

	//Return:
	return Plugin_Handled;
}

public Action:Command_SetAngles(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Ent < GetMaxClients())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot change angles on a person!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Xaxis[5], String:Yaxis[5], String:Zaxis[5];

	//Initulize:
	GetCmdArg(1, Xaxis, sizeof(Xaxis));

	GetCmdArg(2, Yaxis, sizeof(Yaxis));

	GetCmdArg(3, Zaxis, sizeof(Zaxis));

	//Declare:
	new Float:Angles[3], Float:Angles2[3];

	Angles[0] = StringToFloat(Xaxis);

	Angles[1] = StringToFloat(Yaxis);

	Angles[2] = StringToFloat(Zaxis);

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles2);

	//Teleport:
	TeleportEntity(Ent, NULL_VECTOR, Angles, NULL_VECTOR);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - [Entity: %d] [Angles] %f %f %f", Ent, Angles2[0], Angles2[1], Angles2[2]);

	//Return:
	return Plugin_Handled;
}

public Action:Command_AddAngles(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(Ent < GetMaxClients())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot change angles on a person!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Xaxis[5], String:Yaxis[5], String:Zaxis[5];

	//Initulize:
	GetCmdArg(1, Xaxis, sizeof(Xaxis));

	GetCmdArg(2, Yaxis, sizeof(Yaxis));

	GetCmdArg(3, Zaxis, sizeof(Zaxis));

	//Declare:
	decl Var1, Var2, Var3;

	//Initulize:
	Var1 = 0;

	Var2 = 0;

	Var3 = 0;

	Var1 = StringToInt(Xaxis);

	Var2 = StringToInt(Yaxis);

	Var3 = StringToInt(Zaxis);

	//Declare:
	new Float:Angles2[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles2);

	Angles2[0] += Var1;

	Angles2[1] += Var2;

	Angles2[2] += Var3;

	//Teleport:
	TeleportEntity(Ent, NULL_VECTOR, Angles2, NULL_VECTOR);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - [Entity: %d] [Angles] %f %f %f", Ent, Angles2[0], Angles2[1], Angles2[2]);

	//Return:
	return Plugin_Handled;
}

public Action:Command_Freezeit(Client,args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Declare
		decl String:ClassName[32];

		//Is Valid:
		GetEdictClassname(Ent, ClassName, 32);

		//Is Prop:
		if(StrContains(ClassName, "prop", false) != -1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Entity Frozen!");

			//Accept:
			AcceptEntityInput(Ent, "disablemotion", Ent);

			//Set Move:
			SetEntityMoveType(Ent, MOVETYPE_CUSTOM);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);	
		}	
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity!");	
	}

	//Return:
	return Plugin_Handled;
	
}

public Action:Command_UnFreezeit(Client,args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Declare
		decl String:ClassName[32];

		//Is Valid:
		GetEdictClassname(Ent, ClassName, 32);

		//Is Prop:
		if(StrContains(ClassName, "prop", false) != -1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Entity Unfrozen!");

			//Accept:
			AcceptEntityInput(Ent, "enablemotion", Ent);

			//Set Move:      
			SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is a wrong prop!", ClassName);	
		}	
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity!");	
	}

	//Return:
	return Plugin_Handled;
	
}

public Action:Command_WalkThru(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	if(Args == 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Useage: - sm_walkthru <Group>");

		PrintToConsole(Client, "|RP| - Usage: Useage sm_walkthru <Group>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new OldGroup = GetEntProp(Ent, Prop_Data, "m_CollisionGroup");

	//Print:
	CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - Old Collision: %d", OldGroup);

	//Check:
	if(Ent > GetMaxClients())
	{

		//Declare:
		decl String:level[255];

		//Initulize:
		GetCmdArg(1, level, sizeof(level));

		//Send:
		SetEntProp(Ent, Prop_Data, "m_CollisionGroup", StringToInt(level));	
	}

	//Return:
	return Plugin_Handled;
}

public Action:Command_SetSkin(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(!IsValidEdict(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You must look at an entity!");

		//Return:
		return Plugin_Handled;
	}

	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Useage: - sm_setskin <skin number>");

		PrintToConsole(Client, "|RP| - Usage: Useage sm_walkthru <Skin number>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new OldSkin = GetEntProp(Ent, Prop_Send, "m_nSkin");

	//Print:
	CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - Old Skin: %i", OldSkin);

	//Check:
	if(Ent > GetMaxClients())
	{

		//Declare:
		decl String:level[255];

		//Initulize:
		GetCmdArg(1, level, sizeof(level));

		//Send:
		SetEntProp(Ent, Prop_Send, "m_nSkin", StringToInt(level));	
	}

	//Return:
	return Plugin_Handled;
}
