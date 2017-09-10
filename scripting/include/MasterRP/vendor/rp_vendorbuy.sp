//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorbuy_included_
  #endinput
#endif
#define _rp_vendorbuy_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Misc:
static TargetMenu[MAXPLAYERS + 1] = {0,...};

public Action:PluginInfo_VendorBuy(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Npc Vendor Buy Menu!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initVendorBuy()
{

	//Commands:
	RegAdminCmd("sm_addvendoritem", Command_AddVendorItem, ADMFLAG_ROOT, "<Vendor Id> <Item Id> - Add's Item to a vendor");

	RegAdminCmd("sm_removevendoritem", Command_RemoveVendorItem, ADMFLAG_ROOT, "<Vendor Id> <Item Id> - Remove's Item from a vendor");

	RegAdminCmd("sm_viewvendorlist", Command_ViewVendorList, ADMFLAG_SLAY, "<Vendor Id> - View's vendors sql item db");

	//Timer:
	CreateTimer(0.2, CreateSQLdbVendorBuy);
}

//Create Database:
public Action:CreateSQLdbVendorBuy(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `VendorBuy`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `NpcId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemId` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Vendor Menus:
public Action:VendorMenuBuy(Client, VendorId, Ent)
{

	//Has Crime
	if(GetBounty(Client) > 5000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Vendors will not speak with criminals!");

		//Return:
		return Plugin_Handled;
	}

	//Initulize:
	TargetMenu[Client] = Ent;

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i;", ServerMap(), VendorId);

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadVendorBuy, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public T_DBLoadVendorBuy(Handle:owner, Handle:hndl, const String:error[], any:data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVendorBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Vendor Buy Found in DB!");

			//Return:
			return;
		}

		//Handle:
		new Handle:Menu = CreateMenu(HandleBuy);

		//Declare:
		new ItemId; 

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
			decl String:DisplayItem[64];

			//Declare:
        	       	new Price = GetItemCost(ItemId);

			//Less Char
			if(Price > 9999)
			{

				//New Price
				Price = Price / 1000;

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€k%i] %s", Price, GetItemName(ItemId));
			}

			//Override:
			else
			{

				//Format:
				Format(DisplayItem, sizeof(DisplayItem), "[€%i] %s", Price, GetItemName(ItemId));
			}

			//Declare:
			decl String:Item[32];

			//Format:
			Format(Item, sizeof(Item), "%i", ItemId);

			//Menu Buttons:
			AddMenuItem(Menu, Item, DisplayItem);
		}

		//Title:
		SetMenuTitle(Menu, "Hello, do you want to buy\nsome items for your inventory?");

		//Max Menu Buttons:
		SetMenuPagination(Menu, 7);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF NPC is selling items");
	}
}

//Vendor Handle:
public HandleBuy(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Declare:
		decl String:MuchItem[255];

		//Initulize:
		SetSelectedItem(Client, StringToInt(info));

		new ItemId = GetSelectedItem(Client);

		//Handle:
		Menu = CreateMenu(HandleBuyCashOrBank);

		//Title:
		SetMenuTitle(Menu, "[%s] Select if you want to pay \n by Cash or by Card! (5% fee)", GetItemName(ItemId));

		//Format:
		Format(MuchItem, 255, "Cash [€%i]", GetItemCost(ItemId));

		//Menu Button:
		AddMenuItem(Menu, "0", MuchItem);

		//Format:
		Format(MuchItem, 255, "Bank [€%i]", RoundFloat(GetItemCost(ItemId)*1.05));

		//Menu Button:
		AddMenuItem(Menu, "1", MuchItem);

		//Set Exit Button:
		SetMenuExitButton(Menu, false);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);
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

//Vendor Handle:
public HandleBuyCashOrBank(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32]; new ItemId = GetSelectedItem(Client);

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Declare:
		new Result = StringToInt(info);

		//Declare:
		decl String:MuchItem[255], String:bMax[64];

		new ItemCost = GetItemCost(ItemId);

		if(Result == 0)
		{

			//Handle:
			Menu = CreateMenu(MoreItemMenuCash);

			//Title:
			SetMenuTitle(Menu, "[%s] Select amount:", GetItemName(ItemId));

			//Declare:
			new SaveMoney = GetCash(Client); new iMax;

			//Has Enough Money:
			if(SaveMoney == GetItemCost(ItemId))
			{

				//Initialize:
				iMax = 1;
			}

			//dont Have Enough Money:
			if(SaveMoney < GetItemCost(ItemId))
			{

				//Initialize:
				iMax = 0;
			}

			//Override:
			else
			{

				//Loop:
				for(new Max = 0;SaveMoney >= GetItemCost(ItemId); Max++)
				{

					//Initialize:
					if(SaveMoney < ItemCost) break;

					SaveMoney -= ItemCost;

					iMax = Max + 1;

					if(SaveMoney < ItemCost) break;
				}
			}

			//Format:
			Format(MuchItem, 255, "All %i x [€%i]", iMax, ItemCost * iMax);

			Format(bMax, 64, "%i", iMax);

			//Menu Button:
			AddMenuItem(Menu, bMax, MuchItem);

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", ItemCost);

			//Menu Button:
			AddMenuItem(Menu, "1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", ItemCost * 5);

			//Menu Button:
			AddMenuItem(Menu,"5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", ItemCost * 10);

			//Menu Button:
			AddMenuItem(Menu, "10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", ItemCost * 20);

			//Menu Button:
			AddMenuItem(Menu, "20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", ItemCost * 50);

			//Menu Button:
			AddMenuItem(Menu, "50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", ItemCost * 100);

			//Menu Button:
			AddMenuItem(Menu, "100", MuchItem);

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Pay By Bank!
		if(Result == 1)
		{

			//Handle:
			Menu = CreateMenu(MoreItemMenuBank);

			//Title:
			SetMenuTitle(Menu, "[%s] Select amount:", GetItemName(ItemId));

			//Format:
			Format(MuchItem, 255, "1 x [€%i]", RoundFloat(ItemCost * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "1", MuchItem);

			//Format:
			Format(MuchItem, 255, "5 x [€%i]", RoundFloat((ItemCost * 5) * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "5", MuchItem);

			//Format:
			Format(MuchItem, 255, "10 x [€%i]", RoundFloat((ItemCost * 10) * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "10", MuchItem);

			//Format:
			Format(MuchItem, 255, "20 x [€%i]", RoundFloat((ItemCost * 20) * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "20", MuchItem);

			//Format:
			Format(MuchItem, 255, "50 x [€%i]", RoundFloat((ItemCost * 50) * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "50", MuchItem);

			//Format:
			Format(MuchItem, 255, "100 x [€%i]", RoundFloat((ItemCost * 100) * 1.05));

			//Menu Button:
			AddMenuItem(Menu, "100", MuchItem);

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
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

public MoreItemMenuCash(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, TargetMenu[Client]))
		{

			//Declare:
			decl String:info[32];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Amount = StringToInt(info);

			//Declare:
			new ItemId = GetSelectedItem(Client);

			new SItemCost = (GetItemCost(ItemId) * Amount);

			//Has Enoug Money
			if(GetCash(Client) >= SItemCost && GetCash(Client) >= GetItemCost(ItemId) && GetCash(Client) != 0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) - SItemCost));

				//Set Menu State:
				CashState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF for \x0732CD32€%i\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

public MoreItemMenuBank(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, TargetMenu[Client]))
		{

			//Declare:
			decl String:info[32];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Amount = StringToInt(info);

			//Declare:
			new ItemId = GetSelectedItem(Client);

			new SItemCost = RoundFloat((GetItemCost(ItemId) * Amount) * 1.05);

			//Has Enoug Money
			if(GetBank(Client) >= SItemCost && GetBank(Client) >= GetItemCost(ItemId) && GetBank(Client) != 0)
			{

				//Initialize:
				SetBank(Client, (GetBank(Client) - SItemCost));

				//Set Menu State:
				BankState(Client, (SItemCost));

				//Initialize:
				SetItemAmount(Client, ItemId, (GetItemAmount(Client, ItemId) + Amount));

				//Save:
				SaveItem(Client, ItemId, GetItemAmount(Client, ItemId));

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", GetBank(Client), SteamIdToInt(Client));

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%i\x0732CD32\x07FFFFFF x \x0732CD32%s\x0732CD32\x07FFFFFF for \x0732CD32€%i\x0732CD32\x07FFFFFF.", Amount, GetItemName(ItemId), SItemCost);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Cash for this item");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You can't talk to this NPC anymore, because you too far away!");
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

//Add Vendor Item:
public Action:Command_AddVendorItem(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_addvendoritem <vendor id> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sVendorId[255], String:sItemId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	new VendorId = StringToInt(sVendorId);

	new ItemId = StringToInt(sItemId);

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "INSERT INTO VendorBuy (`Map`,`NpcId`,`ItemId`) VALUES ('%s',%i,%i);", ServerMap(), VendorId, ItemId);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vedndor #%s", GetItemName(ItemId), VendorId);

	//Return:
	return Plugin_Handled;
}

//Remove Vendor Item:
public Action:Command_RemoveVendorItem(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removevendoritem <npc id> <item id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sVendorId[255], String:sItemId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	GetCmdArg(2, sItemId, sizeof(sItemId));

	//Declare:
	new VendorId = StringToInt(sVendorId);

	new ItemId = StringToInt(sItemId);

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i AND ItemId = %i", ServerMap(), VendorId, ItemId);

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBSearchVendorBuy, query, conuserid);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added Item %s to Vedndor #%s", GetItemName(ItemId), VendorId);

	//Return:
	return Plugin_Handled;
}

public T_DBSearchVendorBuy(Handle:owner, Handle:hndl, const String:error[], any:data)
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
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadVendorBuy: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Failed to remove Item from the DB!");

			//Return:
			return;
		}

		//Override
		if(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			new Id = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			new ItemId = SQL_FetchInt(hndl, 2);

			//Declare:
			decl String:query[512];

			//Format:
			Format(query, sizeof(query), "DELETE FROM VendorBuy WHERE Map = '%s' AND NpcId = %i AND ItemId = %i", ServerMap(), Id, ItemId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Item %s from vendor #%s", ItemId, Id);
		}
	}
}

//List Spawns:
public Action:Command_ViewVendorList(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_viewvendorlist <npc id>");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	PrintToConsole(Client, "Vendor Buy List: %s", ServerMap());

	//Declare:
	decl String:sVendorId[255];

	//Initialize:
	GetCmdArg(1, sVendorId, sizeof(sVendorId));

	//Declare:
	new VendorId = StringToInt(sVendorId);

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM VendorBuy WHERE Map = '%s' AND NpcId = %i", ServerMap(), VendorId);

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBPrintVendorBuy, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public T_DBPrintVendorBuy(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintVendorBuy: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new ItemId;

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			ItemId = SQL_FetchInt(hndl, 2);

			//Print:
			PrintToConsole(Client, "%i: %s", ItemId, GetItemName(ItemId));
		}
	}
}