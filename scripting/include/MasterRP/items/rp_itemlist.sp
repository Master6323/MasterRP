//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_itemlist_included_
  #endinput
#endif
#define _rp_itemlist_included_

initItemList()
{

	//Item
	RegAdminCmd("sm_itemlist", CommandListItems, ADMFLAG_SLAY, "- Lists items from the database");

	RegAdminCmd("sm_createitem", CommandCreateItem, ADMFLAG_ROOT, "<Id 1-400> <Name> <Type> <Variable> <cost> - Creates an Item");

	RegAdminCmd("sm_removeitem", CommandRemoveItem, ADMFLAG_ROOT, "<1-400> - Removes an Item");

	RegAdminCmd("sm_updateitemgroup", CommandUpdateItemGroup, ADMFLAG_ROOT, "<1-400> - Change an items group");

	RegAdminCmd("sm_updateitemcost", CommandUpdateItemCost, ADMFLAG_ROOT, "<1-400> - Change an items Cost");

	RegAdminCmd("sm_updateitemaction", CommandUpdateItemAction, ADMFLAG_ROOT, "<1-400> - Change an items Action");

	RegAdminCmd("sm_updateitemname", CommandUpdateItemName, ADMFLAG_ROOT, "<1-400> - Change an items Name");

	RegAdminCmd("sm_updateitemvar", CommandUpdateItemVar, ADMFLAG_ROOT, "<1-400> - Change an items Var");

	//Timer:
	CreateTimer(0.4, CreateSQLdbItemList);
}

//Create Database:
public Action:CreateSQLdbItemList(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `ItemList`");

	len += Format(query[len], sizeof(query)-len, " (`ID` int(12) NULL, `COST` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `NAME` varchar(32) NULL, `ACTION` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `VAR` varchar(32) NULL, `GROUP` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadItemlist(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM ItemList;");

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadItems, query);
}

public T_DBLoadItems(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_LoadItem] T_DBLoadItems: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new ItemId; decl String:Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			ItemId = SQL_FetchInt(hndl, 0);

			//Check:
			if(ItemId > 0 && ItemId < MAXITEMS)
			{

				//Database Field Loading INTEGER:
				SetItemCost(ItemId, SQL_FetchInt(hndl, 1));

				//Database Field Loading String:
				SQL_FetchString(hndl, 2, Buffer, sizeof(Buffer));

				//Set Item Name:
				SetItemName(ItemId, Buffer);

				//Database Field Loading INTEGER:
				SetItemAction(ItemId, SQL_FetchInt(hndl, 3));

				//Database Field Loading String:
				SQL_FetchString(hndl, 4, Buffer, sizeof(Buffer));

				//Set Item Name:
				SetItemVar(ItemId, Buffer);

				//Database Field Loading INTEGER:
				SetItemGroup(ItemId, SQL_FetchInt(hndl, 5));
			}
		}
	}
}

//List Items:
public Action:CommandListItems(Client, Args)
{

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Items (%i - %i):", 1, MAXITEMS);

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Loop:
	for(new X = 0; X <= MAXITEMS; X++)
	{

		//Declare:
		decl String:query[512];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM ItemList WHERE ID = %i;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintItemList, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintItemList(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_ItemList] T_DBPrintItemList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new ItemId, Cost, ActionId, String:Name[128], String:Var[128], Group;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			ItemId = SQL_FetchInt(hndl, 0);

			//Check:
			if(ItemId > 0 && ItemId < MAXITEMS)
			{

				//Database Field Loading INTEGER:
				Cost = SQL_FetchInt(hndl, 1);

				//Database Field Loading String:
				SQL_FetchString(hndl, 2, Name, sizeof(Name));

				//Database Field Loading INTEGER:
				ActionId = SQL_FetchInt(hndl, 3);

				//Database Field Loading String:
				SQL_FetchString(hndl, 4, Var, sizeof(Var));

				//Database Field Loading INTEGER:
				Group = SQL_FetchInt(hndl, 5);

				//Print:
				PrintToConsole(Client, "%i - %s / %i / %i / %s Group %i", ItemId, Name, Cost, ActionId, Var, Group);
			}
		}
	}
}

//Create Item:
public Action:CommandCreateItem(Client, Args)
{

	//Error:
	if(Args < 6)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createitem <id> <name> <type> <variables> <cost> <Group>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:ItemId[255],String:Buffers[5][128];

	//Initialize:
	GetCmdArg(1, ItemId, sizeof(ItemId));

	GetCmdArg(2, Buffers[0], 128);

	GetCmdArg(3, Buffers[1], 128);

	GetCmdArg(4, Buffers[2], 128);

	GetCmdArg(5, Buffers[3], 128);

	GetCmdArg(6, Buffers[4], 128);

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO ItemList (`ID`,`COST`,`NAME`,`ACTION`,`VAR`,`GROUP`) VALUES (%i,%i,'%s',%i,'%s',%i);", StringToInt(ItemId), StringToInt(Buffers[3]), Buffers[0], StringToInt(Buffers[1]), Buffers[2], StringToInt(Buffers[4]));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s - %s, Type: %s @ %s, Group %s", ItemId, Buffers[0], Buffers[1], Buffers[2], Buffers[4]);

	//Return:
	return Plugin_Handled;
}

//Remove Item:
public Action:CommandRemoveItem(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removeitem <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:	
	decl String:ItemId[255];

	//Initialize:
	GetCmdArg(1, ItemId, sizeof(ItemId));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Item %s from the database", ItemId);

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "DELETE FROM ItemList WHERE ID = %i;", StringToInt(ItemId));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Return:
	return Plugin_Handled;
}

//Create Item:
public Action:CommandUpdateItemGroup(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updateitemgroup <id> <group>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Buffers[2][128];

	//Initialize:
	GetCmdArg(1, Buffers[0], 128);

	GetCmdArg(2, Buffers[1], 128);

	//Declare:
	new bool:ItemFoundfalse = false;

	//Loop:
	for(new i = 1; i < MAXITEMS; i++)
	{

		if(GetItemCost(StringToInt(Buffers[0])) > 0)
		{

			//Initialize:
			ItemFoundfalse = true;
		}
	}

	//Found Item:
	if(ItemFoundfalse == true)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ItemList SET GROUP = %i WHERE ID = %i;", StringToInt(Buffers[1]), StringToInt(Buffers[0]));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Updated Item %s to Group %s", GetItemName(StringToInt(Buffers[0])), Buffers[1]);

		//Initialize:
		SetItemGroup(StringToInt(Buffers[0]), StringToInt(Buffers[1]));
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Item Found.");
	}

	//Return:
	return Plugin_Handled;
}

//Create Item:
public Action:CommandUpdateItemCost(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updateitemcost <id> <cost>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Buffers[2][128];

	//Initialize:
	GetCmdArg(1, Buffers[0], 128);

	GetCmdArg(2, Buffers[1], 128);

	//Declare:
	new bool:ItemFoundfalse = false;

	//Loop:
	for(new i = 1; i < MAXITEMS; i++)
	{

		if(GetItemCost(StringToInt(Buffers[0])) > 0)
		{

			//Initialize:
			ItemFoundfalse = true;
		}
	}

	//Found Item:
	if(ItemFoundfalse == true)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ItemList SET COST = %i WHERE ID = %i;", StringToInt(Buffers[1]), StringToInt(Buffers[0]));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Updated Item %s to Cost %s", GetItemName(StringToInt(Buffers[0])), Buffers[1]);

		//Initialize:
		SetItemCost(StringToInt(Buffers[0]), StringToInt(Buffers[1]));
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Item Found.");
	}

	//Return:
	return Plugin_Handled;
}
//Create Item:
public Action:CommandUpdateItemAction(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updateitemaction <id> <action>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Buffers[2][128];

	//Initialize:
	GetCmdArg(1, Buffers[0], 128);

	GetCmdArg(2, Buffers[1], 128);

	//Declare:
	new bool:ItemFoundfalse = false;

	//Loop:
	for(new i = 1; i < MAXITEMS; i++)
	{

		if(GetItemCost(StringToInt(Buffers[0])) > 0)
		{

			//Initialize:
			ItemFoundfalse = true;
		}
	}

	//Found Item:
	if(ItemFoundfalse == true)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ItemList SET ACTION = %i WHERE ID = %i;", StringToInt(Buffers[1]), StringToInt(Buffers[0]));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Action %s", GetItemName(StringToInt(Buffers[0])), Buffers[1]);

		//Initialize:
		SetItemAction(StringToInt(Buffers[0]), StringToInt(Buffers[1]));
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Item Found.");
	}

	//Return:
	return Plugin_Handled;
}

//Create Item:
public Action:CommandUpdateItemName(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updateitemname <id> <name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Buffers[2][128];

	//Initialize:
	GetCmdArg(1, Buffers[0], 128);

	GetCmdArg(2, Buffers[1], 128);

	//Declare:
	new bool:ItemFoundfalse = false;

	//Loop:
	for(new i = 1; i < MAXITEMS; i++)
	{

		if(GetItemCost(StringToInt(Buffers[0])) > 0)
		{

			//Initialize:
			ItemFoundfalse = true;
		}
	}

	//Found Item:
	if(ItemFoundfalse == true)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ItemList SET NAME = '%s' WHERE ID = %i;", Buffers[1], StringToInt(Buffers[0]));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Name %s", GetItemName(StringToInt(Buffers[0])), Buffers[1]);

		//Initialize:
		SetItemName(StringToInt(Buffers[0]), Buffers[1]);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Item Found.");
	}

	//Return:
	return Plugin_Handled;
}

//Create Item:
public Action:CommandUpdateItemVar(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updateitemvar <id> <var>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Buffers[2][128];

	//Initialize:
	GetCmdArg(1, Buffers[0], 128);

	GetCmdArg(2, Buffers[1], 128);

	//Declare:
	new bool:ItemFoundfalse = false;

	//Loop:
	for(new i = 1; i < MAXITEMS; i++)
	{

		if(GetItemCost(StringToInt(Buffers[0])) > 0)
		{

			//Initialize:
			ItemFoundfalse = true;
		}
	}

	//Found Item:
	if(ItemFoundfalse == true)
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE ItemList SET VAR = %i WHERE ID = %i;", StringToInt(Buffers[1]), StringToInt(Buffers[0]));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to VAR %s", GetItemName(StringToInt(Buffers[0])), Buffers[1]);

		//Initialize:
		SetItemGroup(StringToInt(Buffers[0]), StringToInt(Buffers[1]));
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Item Found.");
	}

	//Return:
	return Plugin_Handled;
}
