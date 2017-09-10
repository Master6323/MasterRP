//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doorlocked_included_
  #endinput
#endif
#define _rp_doorlocked_included_

//Core Door system:
static MainDoor[2047] = {0,...};
static bool:IsBuyable[2047] = {false,...};
static bool:Locked[2047] = {false,...};
static DoorLocks[2047] = {0,...};
static DoorPrice[2047] = {0,...};
static bool:DoorOpening[2047] = {false,...};

public Action:PluginInfo_DoorLocked(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Unbreabable Doors!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initDoors()
{

	//Entity Event Hook:
	HookEntityOutput("prop_door_rotating", "OnFullyClosed", OnDoorFullyToggled);

	//Entity Event Hook:
	HookEntityOutput("prop_door_rotating", "OnFullyOpen", OnDoorFullyToggled);

	//Entity Event Hook:
	HookEntityOutput("func_door_rotating", "OnFullyOpen", OnDoorFullyToggled);

	//Entity Event Hook:
	HookEntityOutput("func_door_rotating", "OnFullyOpen", OnDoorFullyToggled);

	//Entity Event Hook:
	HookEntityOutput("func_door", "OnFullyClosed", OnDoorFullyToggled);

	//Entity Event Hook:
	HookEntityOutput("func_door", "OnFullyOpen", OnDoorFullyToggled);

	//Cop Doors:
	RegAdminCmd("sm_setlocks", Command_SetDoorLocks, ADMFLAG_ROOT, "- <1-2047> - setlocks cop door.");

	RegAdminCmd("sm_remlocks", Command_RemDoorLocks, ADMFLAG_ROOT, "- <1-2047> - Remove a default cop door.");

	RegAdminCmd("sm_listcopdoors", Command_ListDoorLocks, ADMFLAG_SLAY, "- <No Args> - List the default cop doors.");

	//Beta
	RegAdminCmd("sm_wipedoorsLocks", Command_WipeDoorLocks, ADMFLAG_ROOT, "");

	//Cop Doors:
	RegAdminCmd("sm_setdoorprice", Command_SetDoorPrice, ADMFLAG_ROOT, "- <Price> - setlocks cop door.");

	RegAdminCmd("sm_remdoorprice", Command_RemDoorPrice, ADMFLAG_ROOT, "- <Price> - Remove a default cop door.");

	RegAdminCmd("sm_listdoorprice", Command_ListDoorPrice, ADMFLAG_SLAY, "- <No Args> - List the default cop doors.");

	//Beta
	RegAdminCmd("sm_wipedoorsLocks", Command_WipeDoorPrice, ADMFLAG_ROOT, "");

	//Cop Doors:
	RegAdminCmd("sm_setmaindoor", Command_SetMainDoor, ADMFLAG_ROOT, "- <1-2047> - Main Door .");

	RegAdminCmd("sm_remmaindoor", Command_RemMainDoor, ADMFLAG_ROOT, "- <1-2047> - Main Door.");

	//Timer:
	CreateTimer(0.2, CreateSQLdbDoorLocks);

	CreateTimer(0.2, CreateSQLdbDoorPrice);

	CreateTimer(0.2, CreateSQLdbMainDoor);

	CreateTimer(0.2, CreateSQLdbDoorLocked);
}

//Create Database:
public Action:CreateSQLdbDoorLocks(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorLocks`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Locks` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadDoorLocks(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorLocks WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorLocks, query);
}

//Create Database:
public Action:CreateSQLdbDoorPrice(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorPrice`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Price` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadDoorPrices(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorPrice WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorPrice, query);
}

//Create Database:
public Action:CreateSQLdbMainDoor(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `MainDoor`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL, ,");

	len += Format(query[len], sizeof(query)-len, " `MainDoorId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Load:
public Action:LoadMainDoors(Handle:Timer)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MainDoor WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMainDoorCallback, query);
}

//Create Database:
public Action:CreateSQLdbDoorLocked(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorLocked`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Locked` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Load:
public Action:LoadDoorLocked(Handle:Timer)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorLocked WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorLockedCallback, query);
}

public T_DBLoadDoorLocks(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadDoorLocks: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Door Locks Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent, Locks;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Locks = SQL_FetchInt(hndl, 2);

			//Initulize:
			DoorLocks[Ent] = Locks;
		}

		//Print:
		PrintToServer("|RP| - Door Locks Loaded!");
	}
}

public T_DBLoadDoorPrice(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadDoorLocks: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Door Prices Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent, Price;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Price = SQL_FetchInt(hndl, 2);

			//Initulize:
			DoorPrice[Ent] = Price;

			//Declare:
			decl String:query[255];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBLoadBuyable, query, Ent);
		}

		//Print:
		PrintToServer("|RP| - Door Prices Loaded!");
	}
}

public T_DBLoadBuyable(Handle:owner, Handle:hndl, const String:error[], any:Ent)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadBuyable: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Initulize::
			IsBuyable[Ent] = true;

			//Return:
			return;
		}
	}
}

public T_DBLoadMainDoorCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Player] T_DBLoadMainDoorCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Main Doors Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new DoorId, MainDoorId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			DoorId = SQL_FetchInt(hndl, 1);

			//Fetch SQL Data:
			MainDoorId = SQL_FetchInt(hndl, 2);

			//Initulize:
			MainDoor[DoorId] = MainDoorId;
		}

		//Print:
		PrintToServer("|RP| - Main Doors Loaded!");
	}
}

public T_DBLoadDoorLockedCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadDoorLockedCallback: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Door Locked Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent, IsLocked;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			IsLocked = SQL_FetchInt(hndl, 2);

			//Initulize:
			Locked[Ent] = intTobool(IsLocked);

			//Check:
			if(IsValidEdict(Ent))
			{

				//Accept:
				AcceptEntityInput(Ent, "Lock", 0);
			}
		}

		//Print:
		PrintToServer("|RP| - Door Locks Loaded!");
	}
}

public Action:Command_SetDoorLocks(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter Usage: sm_setlocks <Locks>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Locks = StringToInt(Arg);

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1 && Locks > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(DoorLocks[Entdoor] > 0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE DoorLocks SET Locks = %i WHERE Map = '%s' AND DoorId = %i;", Locks, ServerMap(), Entdoor);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO DoorLocks (`Map`,`DoorId`,`Locks`) VALUES ('%s',%i,%i);", ServerMap(), Entdoor, Locks);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initialize:
	DoorLocks[Entdoor] = Locks;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has %i Locks set on it!", Entdoor, Locks);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemDoorLocks(Client, Args)
{

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(DoorLocks[Entdoor] == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door #%i Has No Locks!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	DoorLocks[Entdoor] = -1;

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM DoorLocks WHERE DoorId = %i AND Map = '%s';", Entdoor, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted", Entdoor);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListDoorLocks(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Door Locks List: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorId WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintDoorsLocks, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action:Command_WipeDoorLocks(Client, Args)
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
	for(new X = 1; X < 2047; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM DoorLocks WHERE DoorId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintDoorsLocks(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintDoorsLocks: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new DoorId, Locks;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			DoorId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Locks = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: Locks <%i>", DoorId, Locks);
		}
	}
}

public Action:Command_SetDoorPrice(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter Usage: sm_setprice <Price>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Price = StringToInt(Arg);

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(DoorPrice[Entdoor] > 0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE DoorPrice SET Price = %i WHERE Map = '%s' AND DoorId = %i;", Price, ServerMap(), Entdoor);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO DoorPrice (`Map`,`DoorId`,`Price`) VALUES ('%s',%i,%i);", ServerMap(), Entdoor, Price);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initialize:
	DoorPrice[Entdoor] = Price;

	//Check:
	if(GetMainDoorOwner(Entdoor) == 0)
	{

		//Initulize::
		IsBuyable[Entdoor] = true;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door \x0732CD32%s\x07FFFFFF has %i Price set on it!", Entdoor, IntToMoney(Price));

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemDoorPrice(Client, Args)
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
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(DoorPrice[Entdoor] == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door #%i Has No Price!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	DoorPrice[Entdoor] = 0;

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM DoorPrice WHERE DoorId = %i AND Map = '%s';", Entdoor, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-CopDoor|\x07FFFFFF - Door \x0732CD32#%i\x07FFFFFF has been deleted", Entdoor);

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:Command_ListDoorPrice(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Door Price List: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorId WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintDoorsPrice, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action:Command_WipeDoorPrice(Client, Args)
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
	for(new X = 1; X < 2047; X++)
	{

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM DoorPrice WHERE DoorId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintDoorsPrice(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintDoorsPrice: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new DoorId, Price;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			DoorId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Price = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: Price <%i>", DoorId, Price);
		}
	}
}

public Action:Command_SetMainDoor(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter Usage: sm_setmaindoor <doorid>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Door = StringToInt(Arg);

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor == -1 && Door < GetMaxClients())
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor) && !IsValidDoor(Door))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(MainDoor[Entdoor] > 0)
	{

		//Format:
		Format(query, sizeof(query), "UPDATE MainDoor SET MainDoorId = %i WHERE Map = '%s' AND DoorId = %i;", Door, ServerMap(), Entdoor);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO MainDoor (`Map`,`DoorId`,`MainDoorId`) VALUES ('%s',%i,%i);", ServerMap(), Entdoor, Door);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initialize:
	MainDoor[Entdoor] = Door;

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - \x0732CD32#%i\x07FFFFFF is now the main door of\x0732CD32#%i\x07FFFFFF!", Entdoor, Door);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemMainDoor(Client, Args)
{

	//Declare:
	new Entdoor = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Entdoor <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Is Door:
	if(!IsValidDoor(Entdoor))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Check:
	if(MainDoor[Entdoor] == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Door #%i Has No Main Door!", Entdoor);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	MainDoor[Entdoor] = 0;

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM MainDoor WHERE DoorId = %i AND Map = '%s';", Entdoor, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Main Door for \x0732CD32#%i\x07FFFFFF has been deleted", Entdoor);

	//Return:
	return Plugin_Handled;
}

public GetMainDoorId(Ent)
{

	//Return:
	return MainDoor[Ent];
}

public bool:GetDoorLocked(Ent)
{

	//Return:
	return Locked[Ent];
}

public SetDoorLocked(Ent, bool:Result)
{

	//Initulize:
	Locked[Ent] = Result;

	//Declare:
	decl String:query[512];

	//Check:
	if(!Result)
	{

		//Format:
		Format(query, sizeof(query), "DELETE FROM `DoorLocked` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `DoorLocked` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Declare:
		new Handle:hDatabase = SQL_Query(GetGlobalSQL(), query);

		//Is Valid Query:
		if(hDatabase)
		{

			//Format:
			Format(query, sizeof(query), "INSERT INTO DoorLocked (`Locked`,`Map`,`DoorId`) VALUES (%i,'%s',%i);", boolToint(Result), ServerMap(), Ent);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Close:
		CloseHandle(hDatabase);
	}
}

public GetDoorLocks(Ent)
{

	//Return:
	return DoorLocks[Ent];
}

public SetDoorLocks(Ent, Amount)
{

	//Initulize:
	DoorLocks[Ent] = Amount;

	//Declare:
	decl String:query[512];

	//Check:
	if(Amount == 0)
	{

		//Format:
		Format(query, sizeof(query), "DELETE FROM `DoorLocks` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `DoorLocks` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

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
				Format(query, sizeof(query), "UPDATE DoorLocks SET Amount = %i WHERE Map = '%s' AND DoorId = %i;", Amount, ServerMap(), Ent);
			}

			//Override:
			else
			{

				//Format:
				Format(query, sizeof(query), "INSERT INTO DoorLocks (`Price`,`Map`,`DoorId`) VALUES (%i,'%s',%i);", Amount, ServerMap(), Ent);
			}

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Close:
		CloseHandle(hDatabase);
	}
}

public GetDoorPrice(Ent)
{

	//Return:
	return DoorPrice[Ent];
}

public SetDoorPrice(Ent, Amount)
{

	//Initulize:
	DoorPrice[Ent] = Amount;

	//Declare:
	decl String:query[512];

	//Check:
	if(Amount == 0)
	{

		//Format:
		Format(query, sizeof(query), "DELETE FROM `DoorPrice` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `DoorPrice` WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

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
				Format(query, sizeof(query), "UPDATE DoorPrice SET Amount = %i WHERE Map = '%s' AND DoorId = %i;", Amount, ServerMap(), Ent);
			}

			//Override:
			else
			{

				//Format:
				Format(query, sizeof(query), "INSERT INTO DoorPrice (`Price`,`Map`,`DoorId`) VALUES (%i,'%s',%i);", Amount, ServerMap(), Ent);
			}

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Close:
		CloseHandle(hDatabase);
	}
}

public bool:IsDoorBuyable(Ent)
{

	//Return:
	return IsBuyable[Ent];
}

public SetDoorBuyable(Ent, bool:Result)
{

	//Initulize:
	IsBuyable[Ent] = Result;
}

public bool:IsValidDoor(Ent)
{

	//Declare:
	decl String:ClassName[32];

	//Initulize:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Is Door:
	if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public Action:DoorHud(Client, Ent)
{

	//Declare:
	decl String:FormatMessage[1024];

	//Declare:
	new len = 0;

	//Buyable:
	if(IsBuyable[Ent])
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "For Sale : %s", IntToMoney(DoorPrice[Ent]));
	}

	//Notice:
	if(!StrEqual(GetNotice(Ent), "null"))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNotice:\n%s", GetNotice(Ent));
	}

	//Notice Name:
	if(!StrEqual(GetNoticeName(Ent), "null"))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nName: %s", GetNoticeName(Ent));
	}

	//Notice:
	if(!StrEqual(GetNoticeDesc(Ent), "null"))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\n%s", GetNoticeDesc(Ent));
	}

	//Locks
	if(DoorLocks[Ent] > 0)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nLocks : %i", DoorLocks[Ent]);
	}

	if(len > 0)
	{

		//Setup Hud:
		SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

		//Show Hud Text:
		ShowHudText(Client, 1, FormatMessage);
	}
}

//Thumped Event:
public OnDoorFullyToggled(const String:Output[], Caller, Activator, Float:Delay)
{

	//Is Valid:
	if(IsValidEdict(Caller))
	{

		//Initulize:
		SetIsDoorOpening(Caller, false);
	}
}

public bool:IsDoorOpening(Ent)
{

	//Return:
	return DoorOpening[Ent];
}

public SetIsDoorOpening(Ent, bool:Result)
{

	//Initulize:
	DoorOpening[Ent] = Result;
}


