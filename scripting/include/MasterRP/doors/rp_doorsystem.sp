//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doorsysten_included_
  #endinput
#endif
#define _rp_doorsystem_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

static MainOwner[2047] = {0,...};
static bool:HasKey[2047][MAXPLAYERS + 1];

static TargetMenu[MAXPLAYERS + 1] = {0,...};

initDoorSystem()
{

	//Commands:
	RegAdminCmd("sm_setdoorowner", Command_SetDoorOwner, ADMFLAG_SLAY, "- <Name> - Give a player ownership of a door.");

	RegAdminCmd("sm_removedoorowner", Command_RemoveDoorOwner, ADMFLAG_SLAY, "- <Name> - removed a players ownership of a door.");

	RegAdminCmd("sm_listdoorkeys", Command_ListDoorKeys, ADMFLAG_SLAY, "- <No Args> - List the All Door keys stored in db.");

	//Beta
	RegAdminCmd("sm_wipedoorKeys", Command_WipeDoorkeys, ADMFLAG_ROOT, "");

	RegAdminCmd("sm_resetdoorowner", Command_ResetDoorOwner, ADMFLAG_ROOT, "");

	//Player Commands:
	RegConsoleCmd("sm_buydoor", Command_Buydoor);

	RegConsoleCmd("sm_selldoor", Command_Selldoor);

	RegConsoleCmd("sm_givekey", Command_GiveKey);

	RegConsoleCmd("sm_takekey", Command_TakeKey);

	RegConsoleCmd("sm_door", Command_Door);

	RegConsoleCmd("sm_doorname", Command_DoorName);

	RegConsoleCmd("sm_doordesc", Command_DoorDesc);

	RegConsoleCmd("sm_doormenu", Command_DoorMenu);

	RegConsoleCmd("sm_doormenu", Command_DoorMenu);

	RegConsoleCmd("sm_peak", Command_Peak);

	//Timer:
	CreateTimer(0.2, CreateSQLdbDoorKeys);
}

//Create Database:
public Action:CreateSQLdbDoorKeys(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `DoorSystem`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `STEAMID` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `DoorId` int(12) NULL, `MainOwner` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Load:
public Action:LoadDoorMainOwners(Handle:Timer)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMainOwnerCallback, query);
}

//Load:
public Action:DBLoadKeys(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s' AND STEAMID = %i;", ServerMap(), SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadKeysCallback, query, conuserid);
}

public T_DBLoadKeysCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Player] T_DBLoadKeysCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading player Door Keys...");
		}

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| You dont own any keys to doors!");
		}

		//Declare:
		new DoorId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			DoorId = SQL_FetchInt(hndl, 2);

			//Initulize:
			HasKey[DoorId][Client] = true;
		}

		//CPrint:
		PrintToConsole(Client, "|RP| Your door keys have loaded!");
	}
}

public T_DBLoadMainOwnerCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Player] T_DBLoadMainOwnerCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Door Owners Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new DoorId, SteamId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Fetch SQL Data:
			SteamId = SQL_FetchInt(hndl, 1);

			//Check:
			if(SteamId > 0)
			{

				//Fetch SQL Data:
				DoorId = SQL_FetchInt(hndl, 2);

				//Initulize:
				MainOwner[DoorId] = SteamId;
			}
		}

		//Print:
		PrintToServer("|RP| - Door Owners Loaded!");
	}
}

//Reset Player Keys after Disconnect:
public ResetKeys(Client)
{

	//Loop:
	for(new DoorId = 0; DoorId < 2047; DoorId++)
	{

		//Initulize:
		HasKey[DoorId][Client] = false;
	}
}

//Reset Player Keys after Disconnect:
public DBResetDoorKeys(DoorId)
{

	//Declare:
	decl String:query[512];

	//Loop:
	for(new Client = 0; Client <= GetMaxClients(); Client++)
	{

		//Initulize:
		HasKey[DoorId][Client] = false;

		//Sql String:
		Format(query, sizeof(query), "DELETE FROM DoorKeys WHERE DoorId = %i AND Map = '%s';", DoorId, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

//List Spawns:
public Action:Command_ListDoorKeys(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Door Key List: %s", ServerMap());

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintDoorKeys, query, conuserid);

	//Return:
	return Plugin_Handled;
}

//Say Sounds menu:
public Action:Command_WipeDoorkeys(Client, Args)
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
		Format(query, sizeof(query), "DELETE FROM DoorKeys WHERE DoorId = %i AND Map = '%s';", X, ServerMap());

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintDoorKeys(Handle:owner, Handle:hndl, const String:error[], any:data)
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
			PrintToConsole(Client, "%i: (SteamId:%i)", DoorId, Price);
		}
	}
}

public T_DBLoadDoorSteamId(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBLoadDoorSteamId: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SteamId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 1);

			//Declare:
			decl String:query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", ServerMap(), SteamId);

			//Declare:
			new conuserid = GetClientUserId(Client);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBPrintNameFromSteamId, query, conuserid);
		}
	}
}

public T_DBPrintNameFromSteamId(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Player] T_DBPrintNameFromSteamId: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:Buffer[255]; new SteamId;

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Buffer, sizeof(Buffer));

			//Print:
			PrintToConsole(Client, "%s (SteamId:%i)", Buffer, SteamId);
		}
	}
}

//Allows an admin to give a ownership of a door to a player
public Action:Command_SetDoorOwner(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_setdoorowner <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door Already has an owner!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "INSERT INTO DoorSystem (`Map`,`DoorId`,`Steamid`,`MainOwner`) VALUES ('%s',%i,%i,%i);", ServerMap(), Ent, SteamIdToInt(Player), SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initulize:
	HasKey[Ent][Player] = true;

	MainOwner[Ent] = SteamIdToInt(Player);

	//SetDoor:
	SetDoorBuyable(Ent, false);

	//Sql Strings:
	Format(query, sizeof(query), "%N", Client);

	//Reset Door Notice:
	SetNoticeName(Ent, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have give ownership of this door \x0732CD32%i\x07FFFFFF to\x0732CD32%N\x07FFFFFF!", Ent, Player);

	//Return:
	return Plugin_Handled;
}

//Remove players ownership if connected!
public Action:Command_RemoveDoorOwner(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_removedoorowner <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(MainOwner[Ent] != SteamIdToInt(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have ownership of this door!", Player);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	HasKey[Ent][Player] = false;

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i And STEAMID = %i;", ServerMap(), Ent, SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - Your ownership for door \x0732CD32#%i\x07FFFFFF! has been removed!", Ent);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have taken \x0732CD32%N\x07FFFFFF ownership for door \x0732CD32#%i\x07FFFFFF!", Player, Ent);

	//Return:
	return Plugin_Handled;
}

//Removes ownership of a door if player disconnected
public Action:Command_ResetDoorOwner(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has no owner!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	DBResetDoorKeys(Ent);

	MainOwner[Ent] = 0;

	//SetDoor:
	SetDoorBuyable(Ent, true);

	//Reset Door Notice:
	RemoveNotice(Ent);

	RemoveNoticeName(Ent);

	RemoveNoticeDesc(Ent);

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		if(GetMainDoorId(X) == Ent)
		{

			//Reset Door Notice:
			RemoveNotice(Ent);

			RemoveNoticeName(Ent);

			RemoveNoticeDesc(Ent);
		}
	}

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF This door has been Reset!");

	//Return:
	return Plugin_Handled;
}

//allows player to buy a door
public Action:Command_Buydoor(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door is already bought!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Has Money:
	if(GetBank(Client) >= Price)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "INSERT INTO DoorSystem (`Map`,`DoorId`,`Steamid`,`MainOwner`) VALUES ('%s',%i,%i,%i);", ServerMap(), Ent, SteamIdToInt(Client), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Initulize:
		HasKey[Ent][Client] = true;

		MainOwner[Ent] = SteamIdToInt(Client);

		//SetDoor:
		SetDoorBuyable(Ent, false);

		//Sql Strings:
		Format(query, sizeof(query), "%N", Client);

		//Reset Door Notice:
		SetNoticeName(Ent, query);

		//Initulize:
		SetBank(Client, (GetBank(Client) - Price));

		//Set Menu State:
		BankState(Client, Price);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You bought this door successful for \x0732CD32%s\x07FFFFFF!", IntToMoney(Price));
	}

	//Override:
	else
	{

		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to purchase this door.");

	}

	//Return:
	return Plugin_Handled;
}

//allows player to Sell a door
public Action:Command_Selldoor(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(IsDoorBuyable(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has no owner!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Price = GetDoorPrice(Ent);

	//Is Valid:
	if(Price == 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled!");

		//Return:
		return Plugin_Handled;
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	new SellPrice = RoundToFloor(Price * 0.9);

	DBResetDoorKeys(Ent);

	MainOwner[Ent] = 0;

	//SetDoor:
	SetDoorBuyable(Ent, true);

	//Initulize:
	SetBank(Client, (GetBank(Client) + SellPrice));

	//Set Menu State:
	BankState(Client, Price);

	//Reset Door Notice:
	RemoveNotice(Ent);

	RemoveNoticeName(Ent);

	RemoveNoticeDesc(Ent);

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		if(GetMainDoorId(X) == Ent)
		{

			//Reset Door Notice:
			RemoveNotice(Ent);

			RemoveNoticeName(Ent);

			RemoveNoticeDesc(Ent);
		}
	}

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF This door has been sold succesful for \x0732CD32%s\x07FFFFFF!", IntToMoney(SellPrice));

	//Return:
	return Plugin_Handled;
}

//allows player to Give a key to another player
public Action:Command_GiveKey(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_givekey <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	if(MainOwner[Ent] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Has Money:
	if(GetBank(Client) >= 2000)
	{

		//Initulize:
		HasKey[Ent][Player] = true;

		//Initulize:
		SetBank(Client, (GetBank(Client) - 2000));

		//Set Menu State:
		BankState(Client, -2000);

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "INSERT INTO DoorSystem (`Map`,`DoorId`,`STEAMID`,`MainOwner`) VALUES ('%s',%i,%i,%i);", ServerMap(), Ent, SteamIdToInt(Player), 0);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - %N has gave you a key to his door for \x0732CD32€2000\x07FFFFFF!", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have gave a key to \x0732CD32%N\x07FFFFFF for \x0732CD32€2000\x07FFFFFF!", Player);
	}

	//Override:
	else
	{
		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to give a key to \x0732CD32%N.", Player);
	}

	//Return:
	return Plugin_Handled;
}

//allows player to take away a key from another player
public Action:Command_TakeKey(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(!IsClientAuthorized(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - SteamID Error!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
    	if(Args != 1)
    	{

		//Print:
        	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Wrong Parameter. Usage: sm_takekey <NAME>");

		//Return:
        	return Plugin_Handled;      
    	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1 && Player == Client)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Door|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(MainOwner[Ent] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Has Money:
	if(GetBank(Client) < 1000)
	{

		//Return:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have enough money to take a key from \x0732CD32%N.", Player);

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	HasKey[Ent][Player] = false;

	//Set Menu State:
	BankState(Client, -1000);

	//Initulize:
	SetBank(Client, (GetBank(Client) - 1000));

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "DELETE FROM DoorSystem WHERE Map = '%s' AND DoorId = %i And STEAMID = %i;", ServerMap(), Ent, SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Player, "\x07FF4040|RP-Door|\x07FFFFFF - %N has taken your key to his door for \x0732CD32€1000\x07FFFFFF!", Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have taken a key from \x0732CD32%N\x07FFFFFF for \x0732CD32€1000\x07FFFFFF!", Player);

	//Return:
	return Plugin_Handled;
}

//Load door owner and who owns a key to the door!
public Action:Command_Door(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	new Ent = GetClientAimTarget(Client, false);

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && !LookingAtWall(Client) && IsValidEdict(Ent))
	{

		//Is Door:
		if(IsValidDoor(Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - See console for output.");

			//Print:
			PrintToConsole(Client, "DoorID: = #%i", Ent);

			//Declare:
			decl String:query[512];

			//Format:
			Format(query, sizeof(query), "SELECT * FROM DoorSystem WHERE Map = '%s' AND DoorId = %i;", ServerMap(), Ent);

			//Declare:
			new conuserid = GetClientUserId(Client);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), T_DBLoadDoorSteamId, query, conuserid);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - See console for output.");

			//Print:
			PrintToConsole(Client, "EnityID: = #%i", Ent);
		}
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Entity");
	}

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action:Command_DoorName(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_doorname <text>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[255];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client) || MainOwner[GetMainDoorId(Ent)] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	SetNoticeName(Ent, Arg);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%i\x07FFFFFF on #%i!", Arg, Ent);

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action:Command_DoorDesc(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_noticedesc <text>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[255];

	//Initialize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Owner Check:
	if(MainOwner[Ent] != SteamIdToInt(Client) || MainOwner[GetMainDoorId(Ent)] != SteamIdToInt(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Sorry, but you are not the owner of this door!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	SetNoticeDesc(Ent, Arg);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%i\x07FFFFFF on #%i!", Arg, Ent);

	//Return:
	return Plugin_Handled;
}

//Door Manage Menu!
public Action:Command_DoorMenu(Client,args)
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
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - No door selected.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ClassName[32];

	//Initialize:
	GetEdictClassname(Ent, ClassName, sizeof(ClassName));

	//Valid Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door.");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	TargetMenu[Client] = Ent;

	//Declare:
	decl String:Buffer[256];

	//Format:
	Format(Buffer, sizeof(Buffer), "Choose an option for this door:\n\nDoor ID: #%i\nDoor Price: €%i\nSell Price: €%i\nLocks #%i", Ent, GetDoorPrice(Ent), RoundToFloor(GetDoorPrice(Ent)*0.9), GetDoorLocked(Ent));

	//Buyable:
	if(GetDoorPrice(Ent) != 0)
	{

		//Declare:
		new Handle:Menu;

		//Is Owner:
		if(MainOwner[Ent] == SteamIdToInt(Client))
		{

			//Handle:
			Menu = CreateMenu(HandleOwnDoor);

			//Title:
			SetMenuTitle(Menu, Buffer);

			//Menu Button:
			AddMenuItem(Menu, "0", "Manage Door");

			AddMenuItem(Menu, "1", "Manage Keys");

			AddMenuItem(Menu, "2", "Manage Locks");

			AddMenuItem(Menu, "3", "View Online Owners");
		}

		//Override:
		else
		{

			//Handle:
			Menu = CreateMenu(HandleBuydoor);

			//Title:
			SetMenuTitle(Menu, Buffer);

			//Owns Key:
			if(HasKey[Ent][Client] == true)
			{

				//Menu Button:
				AddMenuItem(Menu, "0", "Key Info");
			}

			//Override:
			if(IsDoorBuyable(Ent))
			{

				//Menu Button:
				AddMenuItem(Menu, "1", "Buy Door");
			}

			AddMenuItem(Menu, "3", "View Locks");

			AddMenuItem(Menu, "4", "View Door Price");
		}

		//Set Exit Button:
		SetMenuExitButton(Menu, false);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Door has Parent
	else if(MainOwner[GetMainDoorId(Ent)] == SteamIdToInt(Client))
	{

		//Handle:
		new Handle:Menu = CreateMenu(HandleOwnDoor);

		//Title:
		SetMenuTitle(Menu, Buffer);

		//Menu Button:
		AddMenuItem(Menu, "0", "Manage Door");

		AddMenuItem(Menu, "2", "Manage Locks");

		//Set Exit Button:
		SetMenuExitButton(Menu, false);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has been disabled.");
	}

	//Return:
	return Plugin_Handled;
}

//Item Handle:
public HandleOwnDoor(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Initialize:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[64];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, sizeof(info));

				//Initialize:
				new Result = StringToInt(info);

				//Button Selected:
				if(Result == 0)
				{

					//Handle:
					Menu = CreateMenu(HandleManageDoor);

					//Title:
					SetMenuTitle(Menu, "Choose an option for your door:");

					//Menu Button:
					AddMenuItem(Menu, "", "Sell Door");

					AddMenuItem(Menu, "", "Update Name");

					AddMenuItem(Menu, "", "View Door Price");

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Show Menu:
					DisplayMenu(Menu, Client, 30);
				}

				//Button Selected:
				if(Result == 1)
				{

					//Handle:
					Menu = CreateMenu(HandleManageKeys);

					//Title:
					SetMenuTitle(Menu, "Choose an option for your door:");

					//Menu Button:
					AddMenuItem(Menu, "", "Give Key");

					AddMenuItem(Menu, "", "Take Key");

					AddMenuItem(Menu, "", "Key Info");

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Show Menu:
					DisplayMenu(Menu, Client, 30);
				}

				//Button Selected:
				if(Result == 2)
				{

					//Handle:
					Menu = CreateMenu(HandleManageLocks);

					//Title:
					SetMenuTitle(Menu, "Choose an option for your door:");

					//Menu Button:
					AddMenuItem(Menu, "0", "Add Locks");

					AddMenuItem(Menu, "1", "View Locks");

					AddMenuItem(Menu, "2", "Remove Lock");

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Show Menu:
					DisplayMenu(Menu, Client, 30);
				}

				//Button Selected:
				if(Result == 3)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF DoorID: = #%i", Ent);

					//Print:
					PrintToConsole(Client, "DoorID: = #%i",Ent);

					//Loop:
					for(new i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i))
						{

							if(MainOwner[Ent] == SteamIdToInt(i))
							{

								//Print:
								PrintToConsole(Client, "Door Owner: %N", i);
							}
						}
					}

					//Loop:
					for(new i = 1; i <= GetMaxClients(); i++)
					{

						//Connected
						if(IsClientConnected(i))
						{

							if(HasKey[Ent][i] == true && MainOwner[Ent] == SteamIdToInt(i))
							{

								//Print:
								PrintToConsole(Client, "Owns Key: %N", i);
							}
						}
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//Item Handle:
public HandleManageDoor(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Button Selected:
				if(Parameter == 0)
				{

					//Command:
					ClientCommand(Client, "sm_selldoor");
				}

				//Button Selected:
				if(Parameter == 1)
				{

					//Declare:
					decl String:ClientName[255];

					//Initialize:
					GetClientName(Client, ClientName, sizeof(ClientName));

					//Initulize:
					SetNoticeName(Ent, ClientName);

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have updated this Door Name");
				}

				//Button Selected:
				if(Parameter == 2)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - this door is \x0732CD32€%i\x07FFFFFF to buy.", GetDoorPrice(Ent));
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//Item Handle:
public HandleManageKeys(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Button Selected:
				if(Parameter == 0)
				{

					//Handle:
					Menu = CreateMenu(HandleManageGivekey);

					//Menu Title:
					SetMenuTitle(Menu, "Give a key to?");

					//Loop:
					for (new i = 1; i <= GetMaxClients(); i++)
					{

						//Connected:
						if(!IsClientInGame(i))
						{

							//Initialize:
							continue;
						}

						//Declare:
						decl String:name[65], String:ID[25];

						//Initialize:
						GetClientName(i, name, sizeof(name));

						//Convert:
						IntToString(i, ID, sizeof(ID));

						//Menu Button:
						AddMenuItem(Menu, ID, name);
					}

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Set Menu Buttons:
					SetMenuPagination(Menu, 7);

					//Show Menu:
					DisplayMenu(Menu, Client, 20);
				}

				//Button Selected:
				if(Parameter == 1)
				{

					//Handle:
					Menu = CreateMenu(HandleManageTakekey);

					//Menu Title:
					SetMenuTitle(Menu, "Take key to?");

					//Loop:
					for (new i = 1; i <= GetMaxClients(); i++)
					{

						//Connected:
						if(!IsClientInGame(i))
						{

							//Initialize:
							continue;
						}

						//Declare:
						decl String:name[65], String:ID[25];

						//Initialize:
						GetClientName(i, name, sizeof(name));

						//Convert:
						IntToString(i, ID, sizeof(ID));

						//Menu Button:
						AddMenuItem(Menu, ID, name);
					}

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Set Menu Buttons:
					SetMenuPagination(Menu, 7);

					//Show Menu:
					DisplayMenu(Menu, Client, 20);
				}

				//Button Selected:
				if(Parameter == 2)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Keys cost \x0732CD32€%i\x07FFFFFF for each key, you have a maxinun of \x0732CD325\x07FFFFFF keys.", 5000);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//PlayerMenu Handle:
public HandleManageGivekey(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[255];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, 255);

				//Initialize:
				new Player = StringToInt(info);

				//Declare:
				decl String:PlayerName[32];

				//Initialize:
				GetClientName(Player, PlayerName, sizeof(PlayerName));

				//Command:
				ClientCommand(Client, "sm_givekey \"%s\"", PlayerName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//PlayerMenu Handle:
public HandleManageTakekey(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[255];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, 255);

				//Initialize:
				new Player = StringToInt(info);

				//Declare:
				decl String:PlayerName[32];

				//Initialize:
				GetClientName(Player, PlayerName, sizeof(PlayerName));

				//Command:
				ClientCommand(Client, "sm_givekey \"%s\"", PlayerName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//Item Handle:
public HandleManageLocks(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[64];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, sizeof(info));

				//Initialize:
				new Result = StringToInt(info);

				//Button Selected:
				if(Result == 0)
				{

					//Handle:
					Menu = CreateMenu(HandleDoorAddLocks);

					//Title:
					SetMenuTitle(Menu, "Your door has %i Locks", GetDoorLocks(Ent));

					//Menu Buttons:
					AddMenuItem(Menu, "1", "1");

					AddMenuItem(Menu, "5", "5");

					AddMenuItem(Menu, "10", "10");

					AddMenuItem(Menu, "20", "20");

					AddMenuItem(Menu, "50", "50");

					AddMenuItem(Menu, "100", "100");

					//Set Exit Button:
					SetMenuExitButton(Menu, false);

					//Show Menu:
					DisplayMenu(Menu, Client, 20);
				}

				//Button Selected:
				if(Result == 1)
				{


					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Your door has \x0732CD32%i\x07FFFFFF Locks", GetDoorLocks(Ent)); 
				}

				//Button Selected:
				if(Result == 2)
				{

					//Declare:
					new Amount = GetDoorLocks(Ent);

					//Enough Locks:
					if(Amount > 0)
					{

						//Initulize:
						SetCash(Client, (GetCash(Client) + (Amount * 800)));

						SetDoorLocks(Ent, 0);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you have removed %i locks for %s", Amount, IntToMoney((Amount * 800)));
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you cannot take anymore locks of this door.");
					}

				}

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//PlayerMenu Handle:
public HandleDoorAddLocks(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new Ent = TargetMenu[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Can Transact:
		if(!(GetBank(Client) + (Amount * 1000) < 0 || GetBank(Client) - (Amount * 1000) < 0) && GetBank(Client) !=0)
		{

			//Initialize:
			SetDoorLocks(Ent, (GetDoorLocks(Ent) + Amount));

			SetBank(Client, (GetBank(Client) - (Amount * 1000)));		

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have added %i \x0732CD32Locks\x07FFFFFF to your door!", Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You don't have \x0732CD32%i\x07FFFFFF Locks!", Amount);
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

//Item Handle:
public HandleBuydoor(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[64];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, sizeof(info));

				//Initialize:
				new Result = StringToInt(info);

				//Button Selected:
				if(Result == 1)
				{

					//Command:
					ClientCommand(Client, "sm_buydoor");
				}

				//Button Selected:
				if(Result == 0 && HasKey[Ent][Client] == true)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Keys cost \x0732CD32€%i\x07FFFFFF for each key, you have a maxinun of \x0732CD325\x07FFFFFF keys.", 5000);
				}

				//Button Selected:
				if(Result == 3)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - This door has \x0732CD32%i\x07FFFFFF Locks", GetDoorLocks(Ent)); 
				}

				//Button Selected:
				if(Result == 4)
				{

					//Pring:
					CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - this door is \x0732CD32€%i\x07FFFFFF to buy.", GetDoorPrice(Ent)); 
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - you are to far away from your door.");
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

//Notice:
public Action:Command_Peak(Client, Args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client,false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid entity!");

		//Return:
		return Plugin_Handled;
	}

	//Is Door:
	if(!IsValidDoor(Ent))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Not a valid door!");

		//Return:
		return Plugin_Handled;
	}

	//Player Owners Door:
	if(GetMainDoorOwner(Ent) == SteamIdToInt(Client) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Peak for 5 seconds!");

		//Set Client Render:
		SetEntityRenderMode(Ent, RENDER_TRANSCOLOR);

		//Set Client Color:
		SetEntityRenderColor(Ent, 50, 255, 50, 100);

		//Timer:
		CreateTimer(5.0, ResetPeak, Ent);
	}

	//Return:
	return Plugin_Handled;
}

//Create Database:
public Action:ResetPeak(Handle:ResetPeak, any:Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Set Client Render:
		SetEntityRenderMode(Ent, RENDER_NORMAL);

		//Set Client Color:
		SetEntityRenderColor(Ent, 255, 255, 255, 255);
	}
}

//Use Handle:
public Action:OnClientDoorFuncUse(Client, Ent)
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

	//Return:
	return Plugin_Changed;
}

//Use Handle:
public Action:OnClientDoorPropShift(Client, Ent)
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
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have just Unlocked this door!");
	}

	//Is Door Locked:
	else
	{

		//Initulize:
		SetDoorLocked(Ent, true);

		//Accept:
		AcceptEntityInput(Ent, "Lock", Client);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - You have just Locked this door!");
	}

	//Return:
	return Plugin_Changed;
}

public GetMainDoorOwner(Ent)
{

	//Return:
	return MainOwner[Ent];
}

public bool:HasDoorKeys(Ent, Client)
{

	//Return:
	return HasKey[Ent][Client];
}