//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_items_included_
  #endinput
#endif
#define _rp_items_included_

//Euro - € dont remove this!
//€ = �

#define MAXITEMS		400

static String:BuyPath[256];

//Items:
static ItemGroup[MAXITEMS + 1] = {0,...};
static Item[MAXPLAYERS + 1][MAXITEMS + 1];
static ItemCost[MAXITEMS + 1] = {0,...};
static String:ItemName[MAXITEMS + 1][255];
static ItemAction[MAXITEMS + 1] = {0,...};
static String:ItemVar[MAXITEMS + 1][255];

//Misc:
static ItemAmount[2047][MAXITEMS + 1];
static IsGiving[MAXPLAYERS + 1] = {0,...};
static SelectedItem[MAXPLAYERS + 1] = {0,...};
static TargetMenu[MAXPLAYERS + 1] = {0,...};
static Float:lastspawn[MAXPLAYERS + 1] = {0.0,...};
static Float:RaffleTime[MAXPLAYERS + 1] = {0.0,...};
static ItemDetector[MAXPLAYERS + 1] = {0,...};
static Float:PoliceJammerTime[MAXPLAYERS + 1] = {0.0,...};
static Float:PoliceScannerTime[MAXPLAYERS + 1] = {0.0,...};
static Float:BountyJammerTime[MAXPLAYERS + 1] = {0.0,...};
static Float:EnergyTime[MAXPLAYERS + 1] = {0.0,...};

//CustomItems:
static DrugTick[MAXPLAYERS + 1] = {0,...};
static DrugHealth[MAXPLAYERS + 1] = {0,...};
static Float:LockTime[MAXPLAYERS + 1] = {0.0,...};
static Float:HackTime[MAXPLAYERS + 1] = {0.0,...};
static Float:SawTime[MAXPLAYERS + 1] = {0.0,...};

//PropMod:
static String:furnwho[2047][32];

initItems()
{

	//Commands:
	RegConsoleCmd("sm_items", Command_items);

	RegConsoleCmd("sm_jailpass", Command_JailPass);

	//Buy DB:
	BuildPath(Path_SM, BuyPath, 256, "data/roleplay/Buy.txt");
	if(FileExists(BuyPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", BuyPath);

	//Timer
	CreateTimer(0.2, CreateSQLdbitems);
}

public Action:DefaultItems(Client)
{

	DrugTick[Client] = -1;

	DrugHealth[Client] = 0;

	ItemDetector[Client] = 0;

	IsGiving[Client] = 0;

	SelectedItem[Client] = 0;

	TargetMenu[Client] = -1;

	lastspawn[Client] = GetGameTime();

	RaffleTime[Client] = GetGameTime();

	LockTime[Client] = GetGameTime();

	HackTime[Client] = GetGameTime();

	SawTime[Client] = GetGameTime();

	PoliceJammerTime[Client] = GetGameTime();

	PoliceScannerTime[Client] = GetGameTime();

	EnergyTime[Client] = GetGameTime();
}

public Action:PluginInfo_Items(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Items!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V5.66.24");
}

//Create SQLite Database:
public Action:CreateSQLdbitems(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Items`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL, `ItemId` int(11) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Amount` int(11) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadItems(Handle:Timer, any:Client)
{

	//Print:
	PrintToConsole(Client, "|RP| Loading player Items...");

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Items` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadItemsCallBack, query, conuserid);
}

public T_LoadItemsCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_items] T_LoadItemsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| player has no items!");

			//Return:
			return;
		}

		//Declare:
		new ItemId = 0; new Amount = 0;

		//Database Row Loading INTEGER:
		while (SQL_FetchRow(hndl))
		{

			//Initialize:
			ItemId = SQL_FetchInt(hndl, 1);

			Amount = SQL_FetchInt(hndl, 2);

			//Initulize:
			Item[Client][ItemId] = Amount;

			if(Item[Client][ItemId] == 0)
			{

				//Declare:
				decl String:query[255];

				//Format:
				Format(query, sizeof(query), "DELETE FROM `Items` WHERE STEAMID = %i AND ItemId = %i;", SteamIdToInt(Client), ItemId);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query, data);
			}
		}

		//Print:
		PrintToConsole(Client, "|RP| player Items loaded.");
	}
}

public GetItemAmount(Client, ItemId)
{

	//Return:
	return Item[Client][ItemId];
}

public SetItemAmount(Client, ItemId, Amount)
{

	//Initulize:
	Item[Client][ItemId] = Amount;
}

public Action:SaveItem(Client, ItemId, Amount)
{

	//Check:
	if(IsLoaded(Client))
	{

		//Initulize:
		Item[Client][ItemId] = Amount;

		//Declare:
		decl String:query[255];

		if(Amount == 0)
		{

			//Format:
			Format(query, sizeof(query), "DELETE FROM `Items` WHERE STEAMID = %i AND ItemId = %i;", SteamIdToInt(Client), ItemId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Override:
		else
		{

			//Format:
			Format(query, sizeof(query), "SELECT * FROM `Items` WHERE STEAMID = %i AND ItemId = %i;", SteamIdToInt(Client), ItemId);

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
					Format(query, sizeof(query), "UPDATE Items SET Amount = %i WHERE STEAMID = %i AND ItemId = %i;", Amount, SteamIdToInt(Client), ItemId);
				}

				//Override:
				else
				{

					//Format:
					Format(query, sizeof(query), "INSERT INTO Items (`STEAMID`,`ItemId`,`Amount`) VALUES (%i,%i,%i);", SteamIdToInt(Client), ItemId, Amount);
				}

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
			}

			//Close:
			CloseHandle(hDatabase);
		}
	}
}

public Action:Command_items(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Zombie:
	if(StrEqual(GetJob(Client), "Zombie"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are a \x0732CD32Zombie\x07FFFFFF you can't use any items!");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:velocity[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecBaseVelocity", velocity);

	//Is Client Moving:
	if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You may not do this while moving.");

		//Return:
		return Plugin_Handled;
	}

	//Not Cuffed:
	if(!IsCuffed(Client))
	{

		//Not Cuffed:
		if(!GetIsCritical(Client))
		{

			//Handle:
			new Handle:Menu = CreateMenu(HandleInventory);

			//Menu Title:
			SetMenuTitle(Menu, "Choose A Menu:\n\nJob: %s\nBank: €%i\nCash: €%i", GetJob(Client), GetCash(Client), GetBank(Client));

			//Menu Button:
			AddMenuItem(Menu, "0", "Show Inventory");

			AddMenuItem(Menu, "1", "Drop Cash");

			//AddMenuItem(Menu, "2", "Drop Weapon");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
		}

		//Override:
		else
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You are too weak to use your items!");
		}

		//Return:
		return Plugin_Handled;
	}

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use any item while you are cuffed!");

	//Return:
	return Plugin_Handled;
}

public Action:Command_JailPass(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - this command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new bool:HasItem = false;

	//Loop:
	for(new X = 0; X < MAXITEMS; X++)
	{

		//Has Items:
		if(ItemAction[X] == 41)
		{

			//No Item
			if(Item[Client][X] > 0)
			{

				//Initulize:
				HasItem = true;

				//Stop:
				break;
			}
		}
	}

	//Check:
	if(!HasItem)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry, you dont have a free pass.");

		//Return:
		return Plugin_Handled;
	}

	//Is Cuffed:
	if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Can't use a 'Jail Free Pass' whilst not in jail!");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have used a 'Free jail pass' card!");

	//Free Client:
	AutoFree(Client);

	//Return:
	return Plugin_Handled;
}
//PlayerMenu Handle:
public HandleInventory(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && !IsCuffed(Client) && !GetIsCritical(Client))
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

				//Show Menu:
				Inventory(Client);

				//Initialize:
				IsGiving[Client] = false;
			}

			//Button Selected:
			if(Result == 1)
			{

				//Show Menu:
				DrawDropCashMenu(Client);
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

//Items:
Action:Inventory(Client)
{

	//Connected:
	if(Client < 1 || !IsClientConnected(Client) || !IsClientInGame(Client))
	{

		//Return:
		return Plugin_Handled;
	}

	//Handle:
	new Handle:Menu = CreateMenu(HandleSortItems);

	//Initialize:
	new MenuDisplay = false;

	//Declare:
	new ItemActionAmount = 0;

	//Declare:
	new MenuShow[15] = {0,...};

	//Loop:
	for(new X = 0; X < MAXITEMS; X++)
	{

		//Has Items:
		if(Item[Client][X] > 0)
		{

			//Initialize:
			MenuDisplay = true;

			//Old Items
			if(ItemGroup[X] == 0 && MenuShow[0] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "0", "Old Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[0] = 1;
			}

			//Weapons
			if(ItemGroup[X] == 1 && MenuShow[1] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "1", "Weapons");

				//Initialize:
				ItemActionAmount++;

				MenuShow[1] = 1;
			}

			//Illegal Items:
			if(ItemGroup[X] == 2 && MenuShow[2] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "2", "Illegal Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[2] = 1;
			}

			//Food Drink Energy:
			if(ItemGroup[X] == 3 && MenuShow[3] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "3", "Food Drink Energy");

				//Initialize:
				ItemActionAmount++;

				MenuShow[3] = 1;
			}

			//Lockpick/DoorHack:
			if(ItemGroup[X] == 4 && MenuShow[4] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "4", "Lockpick/DoorHack");

				//Initialize:
				ItemActionAmount++;

				MenuShow[4] = 1;
			}

			//Furniture:
			if(ItemGroup[X] == 5 && MenuShow[5] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "5", "Furniture");

				//Initialize:
				ItemActionAmount++;

				MenuShow[5] = 1;
			}

			//Health Kits:
			if(ItemGroup[X] == 6 && MenuShow[6] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "6", "Health Kits");

				//Initialize:
				ItemActionAmount++;

				MenuShow[6] = 1;
			}

			//Other Items:
			if(ItemGroup[X] == 7 && MenuShow[7] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "7", "Other Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[7] = 1;
			}

			//Models and Hats:
			if(ItemGroup[X] == 8 && MenuShow[8] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "8", "Models and Hats");

				//Initialize:
				ItemActionAmount++;

				MenuShow[8] = 1;
			}

			//Drugs and Alcohol:
			if(ItemGroup[X] == 9 && MenuShow[9] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "9", "Drugs and Alcohol");

				//Initialize:
				ItemActionAmount++;

				MenuShow[9] = 1;
			}

			//Misc Items:
			if(ItemGroup[X] == 10 && MenuShow[10] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "10", "Misc Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[10] = 1;
			}

			//Door Items:
			if(ItemGroup[X] == 11 && MenuShow[11] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "11", "Door Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[11] = 1;
			}

			//Police Items:
			if(ItemGroup[X] == 12 && MenuShow[12] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "12", "Police Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[12] = 1;
			}

			//Police Items:
			if(ItemGroup[X] == 14 && MenuShow[14] != 1)
			{

				//Add Menu Item:
				AddMenuItem(Menu, "14", "Job Items");

				//Initialize:
				ItemActionAmount++;

				MenuShow[14] = 1;
			}
		}
	}

	//Show Menu:
	if(MenuDisplay)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Menu Title:
		SetMenuTitle(Menu, "My Inventory:\n\nYou can Toggle some items\nwhen using the inventory\nor settings menu.");

		//Max Menu Buttons:
		SetMenuPagination(Menu, 7);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);
	}

	//Override:
	else
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have any items!");

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return Plugin_Continue;
}

//Item Handle:
public HandleSortItems(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info); new bool:ShowMenu = false;

		//Handle:
		Menu = CreateMenu(HandleItems);

		//Loop:
		for(new X = 0; X < MAXITEMS; X++)
		{

			//Has Items:
			if(Item[Client][X] > 0)
			{

				//Selected Group:
				if(ItemGroup[X] == Result)
				{

					//Declare:
					decl String:ActionItemId[255], String:MenuItemName[32], String:ItemId[255];

					//Format:
					Format(MenuItemName, 32, "[x%i] %s", Item[Client][X], ItemName[X]);

					//Convert:
					IntToString(X, ItemId, 255);

					//Format:
					Format(ActionItemId, 255, "%s", ItemId);

					//Add Menu Item:
					AddMenuItem(Menu, ActionItemId, MenuItemName);

					//Initialize:
					ShowMenu = true;
				}
			}
		}

		//Show:
		if(ShowMenu == true)
		{

			//Print:
			OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

			//Menu Title:
			SetMenuTitle(Menu, "My Inventory:\n\nYou can Toggle some items\nwhen using the inventory\nor settings menu.");

			//Max Menu Buttons:
			SetMenuPagination(Menu, 7);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Override:
		else
		{

			//Close:
			CloseHandle(Menu);
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
public HandleItems(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Cuffed:
		if(IsCuffed(Client) || GetIsCritical(Client))
		{

			//Return:
			return true;
		}

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Initialize:
		SelectedItem[Client] = Result;

		//Is Giving:
		if(!IsGiving[Client])
		{

			//Show Menu:
			DrawItemMenu(Client);
		}

		//Override:
		else
		{

			//Show Menu:
			DrawGiveItemMenu(Client, TargetMenu[Client]);
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

public Action:DrawItemMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandlePrompt);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Would you like to use\nthis item or drop this item?\n\n%s", ItemName[SelectedItem[Client]]);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "0", "Use");

	//Menu Button:
	AddMenuItem(Menu, "1", "Drop");

	//Menu Button:
	AddMenuItem(Menu, "2", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Item|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}


//Handle Prompting:
public HandlePrompt(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected:
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client) && !IsCuffed(Client) && !GetIsCritical(Client))
		{

			//Declare:
			decl String:info[64];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Result = StringToInt(info);

			//Declare:
			new ItemId = SelectedItem[Client];

			//Button Selected:
			if(Result == 0)
			{

				//Use Item:
				UseItem(Client, ItemId, 1);
			}

			//Button Selected:
			else if(Result == 1)
			{

				//Show Menu:
				DropItemMenu(Client);
			}

			//Button Selected:
			else if(Result == 2)
			{

				//Show Menu:
				Inventory(Client);
			}

		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are cuffed, you are unable to use your inventory while cuffed.");
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

public Action:DropItemMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleDropItem);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "How many items would you\nlike to drop?\n\nItem\n%s", ItemName[SelectedItem[Client]]);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "0", "0");

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

	//Menu Button:
	AddMenuItem(Menu, "2", "2");

	//Menu Button:
	AddMenuItem(Menu, "5", "5");

	//Menu Button:
	AddMenuItem(Menu, "10", "10");

	//Menu Button:
	AddMenuItem(Menu, "25", "25");

	//Menu Button:
	AddMenuItem(Menu, "50", "50");

	//Menu Button:
	AddMenuItem(Menu, "123456789", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Item|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Drop Menu Handle:
public HandleDropItem(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32], Float:Position[3];

		new Float:Angles[3] = {0.0, 0.0, 0.0};

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Is Valid:
		if(Amount == 123456789)
		{

			//Show Menu:
			DrawItemMenu(Client);
		}

		//Override:
		else
		{

			//Declare:
			new ItemId = SelectedItem[Client];

			//Enough Items:
			if(Item[Client][SelectedItem[Client]] - Amount >= 0 && Amount > 0)
			{

				//Is Disabled:
				if(lastspawn[Client] > (GetGameTime() - 4))
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wait some seconds and try it again.");
				}

				//EntCheck:
				if(GetPropIndex() > 1900)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());
				}

				//Override:
				else
				{

					//Initialize:
					lastspawn[Client] = GetGameTime();

					GetClientAbsOrigin(Client, Position);

					//Declare:
					new Ent = CreateEntityByName("prop_physics_override");

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/Items/BoxMRounds.mdl");

					//Initialize:
					Position[2] += 10.0;

					//Spawn:
					DispatchSpawn(Ent);

					//Initialize:
					Angles[1] = GetRandomFloat(0.0, 360.0);

					//Declare:
					new Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

					//Is Valid:
					if(IsValidEntity(Ent))
					{

						//Set Data:
						SetEntData(Ent, Collision, 1, 1, true);
					}

					//Teleport:
					TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

					//Button Selected:
					if(Parameter == 0)
					{

						//Initialize:
						Amount = Item[Client][ItemId];
					}

					//Initialize:
					ItemAmount[Ent][ItemId] = Amount;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drop \x0732CD32%i\x07FFFFFF x \x0732CD32%s", Amount, ItemName[ItemId]);

					//Initialize:
					Item[Client][ItemId] -= Amount;

					//Save:
					SaveItem(Client, ItemId, Item[Client][ItemId]);

					//Initulize:
					SetPropSpawnedTimer(Ent, 0);

					SetPropIndex((GetPropIndex() + 1));
#if defined DEBUG
					//Declare:
					decl String:SteamId[32];

					GetClientAuthString(Client, SteamId, 32);

					//Logging:
					LogMessage("%N <%s> droped %i %s", Client, SteamId, Amount, ItemName[ItemId]);
#endif
					//Show Menu:
					DropItemMenu(Client);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32%i\x07FFFFFF x \x0732CD32%s", Amount, ItemName[ItemId]);
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

public Action:DrawGiveItemMenu(Client, Player)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleGive);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "How many items would you\nlike to give: %N\n\n %s", Player, ItemName[SelectedItem[Client]]);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "0", "0");

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

	//Menu Button:
	AddMenuItem(Menu, "2", "2");

	//Menu Button:
	AddMenuItem(Menu, "5", "5");

	//Menu Button:
	AddMenuItem(Menu, "10", "10");

	//Menu Button:
	AddMenuItem(Menu, "25", "25");

	//Menu Button:
	AddMenuItem(Menu, "50", "50");

	//Menu Button:
	AddMenuItem(Menu, "123456789", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Item|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}
//Job Menu Handle:
public HandleGive(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Is Valid:
		if(Amount == 123456789)
		{

			//Show Menu:
			Inventory(Client);
		}

		//Override:
		else
		{

			//Declare:
			new Ent = TargetMenu[Client];

			//In Distance:
			if(IsInDistance(Client, Ent))
			{

				//Connected:
				if(IsClientConnected(Ent) && IsClientInGame(Ent) && !IsCuffed(Client) && !GetIsCritical(Client)) 
				{

					new ItemId = SelectedItem[Client];

					//Enough Items:
					if(Item[Client][ItemId] - Amount >= 0)
					{

						//Declare:
						decl String:ClientName[32], String:PlayerName[32];

						//Initialize:
						GetClientName(Client, ClientName, sizeof(ClientName));

						GetClientName(Ent, PlayerName, sizeof(PlayerName));

						//Handle Items:
						Item[Client][ItemId] -= Amount;

						Item[Ent][ItemId] += Amount;

						//Save:
						SaveItem(Ent, ItemId, Item[Ent][ItemId]);

						SaveItem(Client, ItemId, Item[Client][ItemId]);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You give \x0732CD32%s %i\x07FFFFFF x \x0732CD32%s", PlayerName, Amount, ItemName[ItemId]);

						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You recieve \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF from \x0732CD32%s", Amount, ItemName[ItemId], ClientName);
#if defined DEBUG
						//Declare:
						decl String:SteamId[32], String:SteamId2[32];

						//Initialize:
						GetClientAuthString(Client, SteamId, 32);

						GetClientAuthString(Ent, SteamId2, 32);

						//Loggng:
						LogMessage("%s <%s> gave %s <%s> %i %s", ClientName, SteamId, PlayerName, SteamId2, Amount, ItemName[ItemId]);
#endif
						//Initialize:
						IsGiving[Client] = true;

						//Show Menu:
						Inventory(Client);
					}

					//Override:
					else
					{

						//Close:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have \x0732CD32%i\x07FFFFFF x \x0732CD32%s", Amount, ItemName[ItemId]);
					}
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't talk to this NPC/Player anymore, because you too far away");
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

public Action:UseItem(Client, ItemId, Amount)
{

	//Declare:
	new Float:velocity[3];

	//Initulize:
	GetEntPropVector(Client, Prop_Send, "m_vecBaseVelocity", velocity);

	//Is Client Moving:
	if(velocity[0] != 0.0 || velocity[1] != 0.0 || velocity[2] != 0.0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You may not do this while moving.");

		//Return:
		return Plugin_Handled;
	}

	//Is Sleeping:
	if(IsSleeping(Client) != -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use items whilst sleeping!");

		//Return:
		return Plugin_Handled;
	}

	//Is In Time::
	if(lastspawn[Client] > (GetGameTime() - 4))
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Itembinding is not allowed here!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	lastspawn[Client] = GetGameTime();

	//Declare:
	decl String:SteamId[32];

	//Initialize:
	GetClientAuthString(Client, SteamId, sizeof(SteamId));

	//Loop:
	for(new X = 0; X < Amount; X++)
	{

		//Is Client:
		if(IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client) && !IsCuffed(Client) && !GetIsCritical(Client))
		{

			//Is Client:
			if(!IsCuffed(Client) && !GetIsCritical(Client))
			{

				//Can Use:
				if(Item[Client][ItemId] - Amount > -1)
				{

					//Item Selected: Weapon
					if(ItemAction[ItemId] == 1)
					{

						//Has Client Got Same Weapon As Item:
						if(HasClientWeapon(Client, ItemVar[ItemId], false) == -1 && !IsAmmo(ItemVar[ItemId]))
						{

							//Give Weapon:
							GiveClientWeapon(Client, ItemVar[ItemId]);

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_pistol"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_pistol", 150, 200);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_357"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_357", 12, 24);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_smg1"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_smg1", 250, 300);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_shotgun"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_shotgun", 20, 50);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_frag"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_frag", 3, 5);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_slam"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_slam", 2, 5);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_rpg"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_rpg", 3, 10);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_crossbow"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_crossbow", 5, 10);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_ar2"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_ar2", 120, 150);
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_annabelle"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_annabelle", 36, 48);
							}

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use \x0732CD32%s\x07FFFFFF.", ItemName[ItemId]);

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Override:
						else if(IsAmmo(ItemVar[ItemId]) || StrEqual(ItemVar[ItemId], "weapon_slam") || StrEqual(ItemVar[ItemId], "weapon_frag"))
						{

							//Declare:
							new Used = 0;

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_pistol_large"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_pistol", 150, 200);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_357_large"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_357", 12, 24);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_smg1_large"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_smg1", 250, 300);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_box_buckshot"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_shotgun", 20, 50);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_frag"))
							{
	
								//Add Ammo:
								AddAmmo(Client, "weapon_frag", 3, 5);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "weapon_slam"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_slam", 2, 5);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_rpg_round"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_rpg", 3, 10);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_crossbow"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_crossbow", 3, 10);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_ar2_large"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_ar2", 60, 150);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_ar2_altfire"))
							{

								//Add Ammo:
								//AddClip2Ammo(Client, "weapon_ar2", 2, 6);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_ammo_annabelle"))
							{

								//Add Ammo:
								AddAmmo(Client, "weapon_annabelle", 36, 48);

								//Initulize:
								Used = 1;
							}

							//Weapon Check:
							if(StrEqual(ItemVar[ItemId], "item_healthkit"))
							{

								//Initialize:
								new ClientHp = GetClientHealth(Client);

								//Has Full HP
								if(ClientHp < 100)
								{

									//To Much Health:
									if((ClientHp + 25) > 100)
									{

										//Set Client Health:
										SetEntityHealth(Client, 100);
									}

									//Override:
									else
									{

										//Set Client Health:
										SetEntityHealth(Client, (ClientHp + 25));
									}

									//Initulize:
									Used = 1;
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use anymore \x0732CD32%s\x07FFFFFF as your hp is already full", ItemName[ItemId]);
								}
							}

							//Check Print:
							if(Used == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use \x0732CD32%s\x07FFFFFF.", ItemName[ItemId]);

								//Initialize:
								Item[Client][ItemId]--;

								//Save Item If Used:
								SaveItem(Client, ItemId, Item[Client][ItemId]);
							}

							//Check Print:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use \x0732CD32%s\x07FFFFFF.", ItemName[ItemId]);
							}
						}

						//Override:
						else
						{
								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already own a \x0732CD32%s\x07FFFFFF.", ItemVar[ItemId]);
						}

						//Stop:
						break;
					}

					//Alchohal:
					else if(ItemAction[ItemId] == 2)
					{


						//On Drugs:
						if(DrugTick[Client] == -1)
						{

							//Declare:
							new Roll = GetRandomInt(1, 3);

							//Selected:
							if(Roll == 1)
							{

								//Command:
								CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye.vmt");
							}

							//Selected:
							if(Roll == 2)
							{

								//Command:
								CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye2.vmt");
							}

							//Selected:
							if(Roll == 3)
							{

								//Command:
								CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye3.vmt");
							}

							//Initulize:
							DrugTick[Client] = 120;

							//Shake:
							ShakeClient(Client, 300.0, (10.0 * StringToFloat(ItemVar[ItemId])));

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have drank \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Spawn:
							SpawnGarbage(Client, 3);

						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already on drugs!");
						}

						//Stop:
						break;
					}

					//Drugs:
					else if(ItemAction[ItemId] == 3)
					{

						//Is Cop:
						if(IsCop(Client))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Cops can't use any illegal items.");
						}

						//On Drugs:
						else if(DrugTick[Client] == -1 && DrugHealth[Client] == 0)
						{

							//Declare:
							new Var = StringToInt(ItemVar[ItemId]);

							//Initulize:
							DrugTick[Client] = 120;

							SetCrime(Client, (GetCrime(Client) + 600));

							//Command:
							CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

							//Set Speed:
							SetEntitySpeed(Client, 1.2);

							//Declare:
							new ClientHealth = GetClientHealth(Client);

							//Kush:
							if(Var == 1)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 25);

								//Initulize:
								DrugHealth[Client] = 25;
							}

							//Ice:
							if(Var == 2)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 35);

								//Initulize:
								DrugHealth[Client] = 35;
							}

							//Skunk:
							if(Var == 3)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 45);

								//Initulize:
								DrugHealth[Client] = 45;
							}

							//Cheese:
							if(Var == 4)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 50);

								//Initulize:
								DrugHealth[Client] = 50;
							}

							//While Widdow:
							if(Var == 5)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 70);

								//Initulize:
								DrugHealth[Client] = 70;
							}

							//Canabis Oil:
							if(Var == 6)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 100);

								//Initulize:
								DrugHealth[Client] = 70;
							}

							//Wax:
							if(Var == 7)
							{

								//Set Health:
								SetEntityHealth(Client, ClientHealth + 200);

								//Initulize:
								DrugHealth[Client] = 70;
							}

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just smoked a joint of \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already on drugs!");
						}

						//Stop:
						break;
					}

					//Food:
					else if(ItemAction[ItemId] == 4)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Initialize:
						new ClientHp = GetEntHealth(Client);

						new MaxHealth = GetEntMaxHealth(Client);

						new Float:Hunger = GetHunger(Client);

						//Enough Hunger:
						if(Hunger < 100.0 || ClientHp < MaxHealth)
						{

							//Enough Hunger:
							if(Hunger != 100.0)
							{

								//To Much Hunger:
								if(Hunger + float(Var) > 100.0)
								{

									//Initialize:
									Hunger = 100.0;
								}

								//Override:
								else
								{

									//Initialize:
									Hunger += float(Var);
								}
							}

							//Enough Hunger:
							if(ClientHp < MaxHealth)
							{

								//To Much Health:
								if((ClientHp + (Var / 2)) > MaxHealth)
								{

									//Set Client Health;
									SetEntityHealth(Client, MaxHealth);
								}

								//Override:
								else
								{

									//Set Client Health:
									SetEntityHealth(Client, (ClientHp + (Var / 2)));
								}
							}

							//Enough Hunger:
							if(ClientHp < MaxHealth && Hunger < 100.0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You eat \x0732CD32%s\x07FFFFFF and gained +\x0732CD32%i\x07FFFFFF Hunger as well as \x0732CD32%i\x07FFFFFFHp!", ItemName[ItemId], Var, (Var / 2));
							}

							//Enough Hunger:
							else if(ClientHp < MaxHealth && Hunger == 100.0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You eat \x0732CD32%s\x07FFFFFF and gained \x0732CD32%i\x07FFFFFFHp!", ItemName[ItemId], (Var / 2));
							}

							//Enough Hunger:
							else if(ClientHp == MaxHealth && Hunger < 100.0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You eat \x0732CD32%s\x07FFFFFF and gained +\x0732CD32%i\x07FFFFFF Hunger!", ItemName[ItemId], Var);
							}

							//Enough Hunger:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You eat \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);
							}

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Spawn:
							SpawnGarbage(Client, 1);

							//Stop:
							break;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot eat right now, your health is full!");

							//Stop:
							break;
						}
					}

					//Lock pick:
					else if(ItemAction[ItemId] == 5)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Valid:
						if(LockTime[Client] <= (GetGameTime() - (60 * Var)))
						{

							//Declare:
							new DoorEnt = GetClientAimTarget(Client, false);

							//Is Valid:
							if(DoorEnt > 1)
							{

								//Declare:
								decl String:ClassName[255];

								//Initialize:
								GetEdictClassname(DoorEnt, ClassName, 255);

								//Is Combine:
								if(!IsCop(Client))
								{

									//Is Prop Door:
									if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
									{

										//Not Admin Door:
										if(!GetDoorLocked(DoorEnt))
										{

											//No Locks:
											if(GetDoorLocks(DoorEnt) < 1)
											{

												//Accept:
												AcceptEntityInput(DoorEnt, "Unlock", Client);

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", ItemName[ItemId]);

												//Initialize:
												LockTime[Client] = GetGameTime();

												SetCrime(Client, (GetCrime(Client) + 600));

											}

											//Override:
											else
											{

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
											}
										}

										//Override:
										else
										{

											//Print:
											CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
										}
									}

									//Is Func Door:
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
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", ItemName[ItemId]);
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item can only be used by looking at a player or a door!");
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Var);
						}

						//Stop:
						break;
					}

					//Doorhack:
					else if(ItemAction[ItemId] == 6)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Valid:
						if(HackTime[Client] <= (GetGameTime() - (60 * Var)))
						{

							//Declare:
							new DoorEnt = GetClientAimTarget(Client, false);

							//Is Valid:
							if(DoorEnt > 1)
							{

								//Is Combine:
								if(!IsCop(Client))
								{

									//Declare:
									decl String:ClassName[255];

									//Initialize:
									GetEdictClassname(DoorEnt, ClassName, 255);

									//Func:
									if(StrEqual(ClassName, "func_door"))
									{

										//Not Admin Door:
										if(!GetDoorLocked(DoorEnt))
										{

											//No Locks:
											if(GetDoorLocks(DoorEnt) < 1)
											{

												//Accept:
												AcceptEntityInput(DoorEnt, "Unlock", Client);

												AcceptEntityInput(DoorEnt, "Toggle", Client);

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You use {olive}%s\x07FFFFFF to open this door.", ItemName[ItemId]);

												//Initialize:
												HackTime[Client] = GetGameTime();

												SetCrime(Client, (GetCrime(Client) + 1000));
											}

											//Override:
											else
											{

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door has some additional locks!");
											}
										}

										//Override:
										else
										{

											//Print:
											CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Door is not unlockable.");
										}
									}

									//Is Func Door:
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
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", ItemName[ItemId]);
								}

		            				}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This item can only be used by looking at a door!");
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i minutes", Var);
						}

						//Stop:
						break;
					}

					//Furni:
					else if(ItemAction[ItemId] == 7)
					{

						//EntCheck:
						if(CheckMapEntityCount() > 2047)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());

							//Stop:
							break;
						}

						//Override:
						else
						{

							//Declare:
							new Float:ClientOrigin[3],Float:FurnitureOrigin[3],Float:EyeAngles[3],Ent;

							//Initialize:
							GetClientAbsOrigin(Client, ClientOrigin);

							GetClientEyeAngles(Client, EyeAngles);

							//Initialize:
							FurnitureOrigin[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

							FurnitureOrigin[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

							FurnitureOrigin[2] = (ClientOrigin[2] + 100);

							//Is Mattress:
							if(StrContains(ItemVar[ItemId], "models/props_c17/furnituremattress001a.mdl", false) != -1)
							{

								//Initialize:
								Ent = CreateEntityByName("prop_ragdoll");
							}

							//Override:
							else
							{

								//Initialize:
								Ent = CreateEntityByName("prop_physics_override");
							}

							//Is PreCached:
							if(!IsModelPrecached(ItemVar[ItemId]))
							{

								//PreCache:
								PrecacheModel(ItemVar[ItemId]);
							}

							//Dispatch:
							DispatchKeyValue(Ent, "physdamagescale", "0.0");

							DispatchKeyValue(Ent, "model", ItemVar[ItemId]);

							//Spawn:
							DispatchSpawn(Ent);

							//Teleport:
							TeleportEntity(Ent, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);

							if(StrEqual(ItemVar[ItemId], "models/props_interiors/furniture_lamp01a.mdl"))
								CreateLight(Ent, 1, 248, 253, 38, "null");

							//Initialize:
							furnwho[Ent] = SteamId;

							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You spawn a \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);

						}

						//Stop:
						break;
					}

					//Heal Player:
					else if(ItemAction[ItemId] == 8)
					{

						//Declare:
						new Player = GetClientAimTarget(Client, true);

						//Is Actual Entity:
						if(Player > 0 && Player <= GetMaxClients() && IsClientConnected(Player) && IsClientInGame(Player))
						{

							//Declare:
							new PlayerHP = GetEntMaxHealth(Player);

							new MaxHealth = GetEntMaxHealth(Player);

							//Is Valid:
							if(PlayerHP < MaxHealth)
							{

								//Declare:
								new Var = StringToInt(ItemVar[ItemId]);

								//Enough Health:
								if((PlayerHP + Var) > MaxHealth)
								{

									//Set Ent Health:
									SetEntityHealth(Player, MaxHealth);
								}

								//Override:
								else
								{

									//Set Ent Health:
									SetEntityHealth(Player, (PlayerHP + Var));
								}

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You heal \x0732CD32%i\x07FFFFFF% of \x0732CD32%N\x07FFFFFF Health.", Var, Player);

								CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has Healed \x0732CD32%i\x07FFFFFF of your health.", Client, Var);

								//Initialize:
								Item[Client][ItemId]--;

								//Save Item If Used:
								SaveItem(Client, ItemId, Item[Client][ItemId]);
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has already got \x0732CD32100\x07FFFFFF health, you cannot heal them anymore.", Player);

								//Stop:
								break;
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No player selected, look at a player, then use the item again");

							//Stop:
							break;
						}
					}

					//Cuff Saw:
					else if(ItemAction[ItemId] == 9)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Valid:
						if(SawTime[Client] <= (GetGameTime() - (60 * Var)))
						{

							//Declare:
							new Player = GetClientAimTarget(Client, true);

							//Is Actual Entity:
							if(Player > 0)
							{

								//Connected:
								if(IsClientConnected(Player) && IsClientInGame(Player))
								{

									//Is Combine:
									if(!IsCop(Client))
									{

										//Is Client Cuffed:
										if(IsCuffed(Player))
										{

											//Valid:
											if(SawTime[Player] <= (GetGameTime() - 20))
											{

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used a \x0732CD32%s\x07FFFFFF to uncuff \x0732CD32%N\x07FFFFFF hands!", ItemName[ItemId], Player);

												CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF used a \x0732CD32%s\x07FFFFFF to uncuff your hands!", Client, ItemName[ItemId]);

												//Uncuff Player:
												UnCuff(Player);

												//Initialize:
												SawTime[Client] = GetGameTime();
											}

											//Override:
											else
											{

												//Print:
												CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF This player has been cuffed to recently");
											}
										}

										//Override:
										else
										{

											//Print:
											CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is not cuffed, selected a cuffed player to use this item.", Player);
										}
									}

									//Override:
									else
									{

										//Print:
										CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use \x0732CD32%s\x07FFFFFF while you are cop!", ItemName[ItemId]);
									}
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No player selected, look at a player, then use the item again.");
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", Var);
						}

						//Stop:
						break;
					}

					//Raffle Tickets:
					if(ItemAction[ItemId] == 10)
					{

						//Buffer:
						if(RaffleTime[Client] <= (GetGameTime() - 300))
						{

							//Declare:
							new Winamount = 0;

							//Initialize:
							new Var = StringToInt(ItemVar[ItemId]);

							//Random:
							new random = GetRandomInt(1, 300);

							if(random > 1 && random <= 200)
							{

								//Initialize:
								Winamount = 0;
							}

							if(random > 200 && random <= 250)
							{

								//Initialize:
								Winamount = Var;
							}

							if(random > 250 && random <= 280)
							{

								//Initialize:
								Winamount = Var * 5;
							}

							if(random > 280 && random <= 295)
							{

								//Initialize:
								Winamount = Var * 25;
							}

							if(random > 295 && random <= 300)
							{

								//Initialize:
								Winamount = Var * 100;
							}

							//Has Won:
							if(Winamount > 0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP - Raffle|\x07FFFFFF You won \x0732CD32%i\x07FFFFFF€.",Winamount);

								//Set Menu State:
								CashState(Client, Winamount);

								//Initulize:
								SetCash(Client, (GetCash(Client) + Winamount));
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP - Raffle|\x07FFFFFF You draw a blank.");
							}

							//Initulize:
							RaffleTime[Client] = GetGameTime();

							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Is Valid  Amouint
							if(Winamount >= 5000)
							{

								//Print:
								CPrintToChatAll("\x07FF4040|RP - Raffle|\x07FFFFFF - The Player \x0732CD32%N\x07FFFFFF hit the jackpot and won \x0732CD32€%i\x07FFFFFF with a \x07FFFFFF€%i\x0732CD32 ticket", Client, Winamount, (10 * Var));        
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this once every \x0732CD32%i\x07FFFFFF minutes.", 10);
						}

						//Stop:
						break;
					}

					//Add Lock:
					else if(ItemAction[ItemId] == 11)
					{

						//Declare:
						new DoorEnt = GetClientAimTarget(Client, false);

						//Is Door:
						if(IsValidEdict(DoorEnt))
						{

							//Declare:
							decl String:ClassName[255];

							//Initialize:
							GetEdictClassname(DoorEnt, ClassName, 255);

							//Is Door:
							if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
							{

								//Declare:
								new Var = StringToInt(ItemVar[ItemId]);

								//Valid Locks:
								if((GetDoorLocks(DoorEnt) + Var) > 0)
								{

									//Initialize:
									SetDoorLocks(DoorEnt, (GetDoorLocks(DoorEnt) + Var));

									Item[Client][ItemId]--;

									//Save Item If Used:
									SaveItem(Client, ItemId, Item[Client][ItemId]);

									//Print:
									CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - Added lock (\x0732CD32%i\x07FFFFFF) to the door",Var);
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - Invalid amount of door locks.");
								}
							}

							//Override:
							else
							{

								//Print:
                		    				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No door selected. Look at a door, then use this item again.");
        		        			}
						}

						//Stop:
						break;
	 	           		}

					//Rem Lock:
					else if(ItemAction[ItemId] == 12)
					{

						//Declare:
						new DoorEnt = GetClientAimTarget(Client, false);

						//Is Door:
						if(IsValidEdict(DoorEnt))
						{

							//Declare:
							decl String:ClassName[255];

							//Initialize:
							GetEdictClassname(DoorEnt, ClassName, 255);

							//Is Door:
							if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
							{

								//Declare:
								new Var = StringToInt(ItemVar[ItemId]);

								//Valid Locks:
								if((GetDoorLocks(DoorEnt) - Var) >= 0 && GetDoorLocks(DoorEnt) != 0)
								{

									//Initialize:
									SetDoorLocks(DoorEnt, GetDoorLocks(DoorEnt) - Var);

									Item[Client][ItemId]--;

									//Save Item If Used:
									SaveItem(Client, ItemId, Item[Client][ItemId]);

									//Print:
									CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - you have destroyed (\x0732CD32%i\x07FFFFFF) locks on this door", Var);
								}

								//Valid Locks:
								if((GetDoorLocks(DoorEnt) - Var) <= 0 && GetDoorLocks(DoorEnt) != 0)
								{

									//Initialize:
									SetDoorLocks(DoorEnt, 0);

									Item[Client][ItemId]--;

									//Save Item If Used:
									SaveItem(Client, ItemId, Item[Client][ItemId]);

									//Print:
									CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - you have destroyed (\x0732CD32%i\x07FFFFFF) locks on this door", Var);
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client,"\x07FF4040|RP|\x07FFFFFF - Invalid amount of door locks.");
								}
							}

							//Override:
							else
							{

								//Print:
                		    				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid entity!");
        		        			}
						}

						//Stop:
						break;
 	           			}

					//Set Model:
					else if(ItemAction[ItemId] == 13)
					{

						//Set:
						SetModel(Client, ItemVar[ItemId]);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You model has been set to \x0732CD32%i\x07FFFFFF.", ItemVar[ItemId]);

						//Stop:
						break;
					}

					//Health Bipass
					else if(ItemAction[ItemId] == 14)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Set Health:
						SetEntityHealth(Client, (Var));

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used \x0732CD32%s\x07FFFFFF for \x0732CD32+%ihp.", ItemName[ItemId], Var);

						//Initialize:
						Item[Client][ItemId]--;

						//Save Item If Used:
						SaveItem(Client, ItemId, Item[Client][ItemId]);

						//Stop:
						break;
					}

					//Invisable Cloak:
					else if(ItemAction[ItemId] == 15)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Set Client Render:
						SetEntityRenderMode(Client, RENDER_TRANSCOLOR);

						//Set Client Color:
						SetEntityRenderColor(Client, 255, 255, 255, Var);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have used a invisable cloak.");

						//Loop:
						for(new i = 0, weapon; i < 47; i += 4)
						{

							//Initialize:
							weapon = GetEntDataEnt2(Client, GetWeaponOffset() + i);

							//Is Valid Weapon:
							if(weapon > -1)
							{

								//Set Weapon Render:
								SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);

								//Set Weapon Color
								SetEntityRenderColor(weapon, 255, 255, 255, Var);
							}
						}

						//Initialize:
						Item[Client][ItemId]--;

						//Save Item If Used:
						SaveItem(Client, ItemId, Item[Client][ItemId]);

						//Stop:
						break;
					}

					//Cop Search Warrant:
					else if(ItemAction[ItemId] == 16)
					{

						//Initialize:
						new DoorEnt = GetClientAimTarget(Client, false);

						//Is Door:
						if(IsValidEdict(DoorEnt))
						{

							//Is Cop:
							if(IsCop(Client) || IsAdmin(Client))
							{

								//Declare:
								decl String:ClassName[255];
	
								//Initialize:
								GetEdictClassname(DoorEnt, ClassName, 255);

								//Is Valid Door:
								if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
								{

									//Declare:
									new Var = StringToInt(ItemVar[ItemId]); new bool:Result = false;

									//To many Locks:
									if(GetDoorLocks(DoorEnt) <= Var)
									{

										//Declare:
										decl Float:Vec[3];

										//Initialize:
										GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Vec);

										//Loop:
										for(new i = 1; i <= GetMaxClients(); i ++)
										{

											//Connected:
											if(IsClientConnected(i) && IsClientInGame(i))
											{


												//Declare:
												decl Float:EntOrigin[3];

												//Initialize:
												GetEntPropVector(i, Prop_Send, "m_vecOrigin", EntOrigin);

												//Declare:
												new Float:Dist = GetVectorDistance(Vec, EntOrigin);

												//In Distance:
												if(Dist <= 850 && GetCrime(i) > 3000)
												{

													//Initulize:
													Result = true;
												}

											}
										}

										//Check:
										if(Result == true)
										{

											//Accept:
											AcceptEntityInput(DoorEnt, "Unlock", Client);

											//Is Cop Door:
											if(StrEqual(ClassName, "func_door"))
											{

												//Accept:
												AcceptEntityInput(DoorEnt, "Toggle", Client);
											}

											//Print:
											CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF pulled out a Search Warrant!", Client);

											//Declare:
											decl String:FormatSound[128];

											//Format:
											Format(FormatSound, sizeof(FormatSound), "buttons/button8.wav");

											//Is Precached:
											if(IsSoundPrecached(FormatSound))
											{

												//Precache:
												PrecacheSound(FormatSound);
											}

											//Emit Sound:
											EmitAmbientSound(FormatSound, Vec, Client, SNDLEVEL_RAIDSIREN);

											//Initialize:
											Item[Client][ItemId]--;

											//Save Item If Used:
											SaveItem(Client, ItemId, Item[Client][ItemId]);
										}

										//Override:
										else
										{

											//Print:
											CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is no one with crime in this area!");
										}
									}

									//Override:
									else
									{

										//Print:
										CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This door to many locks for this search warrant.");
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No door selected. Look at a door, then use this item again.");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - search warrants are only useable for the police.");
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No door selected. Look at a door, then use this item again.");
						}

						//Stop:
						break;
					}

					//SuperSpeed:
					else if(ItemAction[ItemId] == 17)
					{

						//Is Sleeping:
						if(IsSleeping(Client) != -1)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use items whilst sleeping!");

							//Stop:
							break;
						}

						//Override:
						else
						{

							//Declare:
							new Float:Var = StringToFloat(ItemVar[ItemId]);

							//Set Client Speed:
							SetEntitySpeed(Client, Var);

							//Timer:
							CreateTimer((Var*25), backspeed, Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You use for \x0732CD32%.1f\x07FFFFFF seconds \x0732CD32%fX\x07FFFFFF Speed\x0732CD32.", Var, (Var*25));

							//Loop:
							for(new i = 1; i <= GetMaxClients(); i++)
							{

								//Connected:
								if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N has just used a \x0732CD32%f\x07FFFFFF speed multiplier", Client, Var);             
								}
							}

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Stop:
						break;
					}

					//Food:
					if(ItemAction[ItemId] == 18)
					{

						//Declare:
						new Var = RoundFloat(StringToFloat(ItemVar[ItemId]));

						//Initialize:
						new ClientHp = GetClientHealth(Client);

						//Enough Hunger:
						if(GetHunger(Client) < 100.0 || ClientHp < 100)
						{

							//Enough Hunger:
							if(GetHunger(Client) != 100.0)
							{

								//To Much Hunger:
								if(GetHunger(Client) + float(Var) > 100.0)
								{

									//Initialize:
									SetHunger(Client, 100.0);
								}

								//Override:
								else
								{

									//Initialize:
									SetHunger(Client, (GetHunger(Client) + float(Var)));
								}
							}

							//Enough Hunger:
							if(ClientHp < 100)
							{

								//To Much Health:
								if((ClientHp + (Var / 2)) > 100)
								{

									//Set Client Health;
									SetEntityHealth(Client, 100);
								}

								//Override:
								else
								{

									//Set Client Health:
									SetEntityHealth(Client, (ClientHp + (Var / 2)));
								}
							}

							//Enough Hunger:
							if(ClientHp < 100 && GetHunger(Client) < 100)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drank \x0732CD32%s\x07FFFFFF and gained +\x0732CD32%i\x07FFFFFF Hunger as well as \x0732CD32%i\x07FFFFFFHp!", ItemName[ItemId], Var, (Var / 2));
							}

							//Enough Hunger:
							else if(ClientHp < 100 && GetHunger(Client) == 100)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drank \x0732CD32%s\x07FFFFFF and gained \x0732CD32%i\x07FFFFFFHp!", ItemName[ItemId], (Var / 2));
							}

							//Enough Hunger:
							else if(ClientHp == 100 && GetHunger(Client) < 100)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drank \x0732CD32%s\x07FFFFFF and gained +\x0732CD32%i\x07FFFFFF Hunger!", ItemName[ItemId], Var);
							}

							//Enough Hunger:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drank \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);
							}

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Spawn:
							SpawnGarbage(Client, 2);

							//Stop:
							break;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot drink right now, you're full");

							//Stop:
							break;
						}
					}

					//Energy Drink:
					if(ItemAction[ItemId] == 19)
					{

						//Declare:
						new Var = RoundFloat(StringToFloat(ItemVar[ItemId]));

						//Initialize:
						new ClientHp = GetClientHealth(Client);

						//Enough Hunger:
						if(ClientHp < 100)
						{

							//To Much Health:
							if((ClientHp + (Var / 2)) > 100)
							{

								//Set Client Health;
								SetEntityHealth(Client, 100);
							}

							//Override:
							else
							{

								//Set Client Health:
								SetEntityHealth(Client, (ClientHp + (Var / 2)));
							}

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You drank a \x0732CD32%s\x07FFFFFF and and gained +\x0732CD32%i\x07FFFFFF Health!", ItemName[ItemId], Var);

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot drink right now, you're Health is full");

							//Stop:
							break;
						}
					}

					//Suit Battery:
					else if(ItemAction[ItemId] == 20)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Enough Suit:
						if(GetClientArmor(Client) != 100)
						{

							//Enough Suit:
							if(GetClientArmor(Client) + Var < 100)
							{

								//Set Armor:
								SetEntityArmor(Client, GetClientArmor(Client) + Var); 
							}

							//Override:
							else
							{

								//Set Armor:
								SetEntityArmor(Client, 100);
							}

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used a suit \x0732CD32%i\x07FFFFFF Battery Pack.", Var);

							//Initialize:
							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your suit is now at maximum (100 suit)!");

							//Stop:
							break;
						}
					}

					//Drugs:
					else if(ItemAction[ItemId] == 21)
					{

						//Handle Drug Plant:
						OnItemsPlantUse(Client, ItemId);

						//Stop:
						break;
					}

					//Printers:
					else if(ItemAction[ItemId] == 22)
					{

						//Handle Money Printer:
						OnItemsPrinterUse(Client, ItemId);

						//Stop:
						break;
					}

					//Meth:
					else if(ItemAction[ItemId] == 23)
					{

						//Handle Meth Kitchen:
						OnItemsMethUse(Client, ItemId);

						//Stop:
						break;
					}

					//Pills:
					else if(ItemAction[ItemId] == 24)
					{

						//HandlePills Kitchen:
						OnItemsPillsUse(Client, ItemId);

						//Stop:
						break;
					}

					//Cocain:
					else if(ItemAction[ItemId] == 25)
					{

						//Handle Cocain Kitchen:
						OnItemsCocainUse(Client, ItemId);

						//Stop:
						break;
					}

					//Rice:
					else if(ItemAction[ItemId] == 26)
					{

						//Handle Rice Plant:
						OnItemsRiceUse(Client, ItemId);

						//Stop:
						break;
					}

					//Bomb:
					else if(ItemAction[ItemId] == 27)
					{

						//Handle Bomb:
						OnItemsBombUse(Client, ItemId);

						//Stop:
						break;
					}

					//Microwave:
					else if(ItemAction[ItemId] == 28)
					{

						//Handle Bomb:
						OnItemsMicrowaveUse(Client, ItemId);

						//Stop:
						break;
					}

					//GunLab:
					else if(ItemAction[ItemId] == 29)
					{

						//Handle Bomb:
						OnItemsGunLabUse(Client, ItemId);

						//Stop:
						break;
					}

					//Shield:
					else if(ItemAction[ItemId] == 30)
					{

						//Handle Bomb:
						OnItemsShieldUse(Client, ItemId);

						//Stop:
						break;
					}

					//FireBomb:
					else if(ItemAction[ItemId] == 31)
					{

						//Handle Bomb:
						OnItemsFireBombUse(Client, ItemId);

						//Stop:
						break;
					}

					//Hats:
					else if(ItemAction[ItemId] == 32)
					{


						//Create Hat:
						CreateHat(Client, ItemVar[ItemId]);

						//Save Hat:
						SaveHatModel(Client, ItemVar[ItemId]);

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your new hat is a \x0732CD32%s!", ItemName[ItemId]);

						//Stop:
						break;
					}

					//Crime Depo:
					else if(ItemAction[ItemId] == 33)
					{

						//Is Cop:
						if(IsCop(Client))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Cops can't use any illegal items.");

							//Stop:
							break;
						}

						if(GetCrime(Client) - StringToInt(ItemVar[ItemId]) > 0)
						{

							//Initulize:
							SetCrime(Client, (GetCrime(Client) - StringToInt(ItemVar[ItemId])));

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have used a \x0732CD32%s!", ItemName[ItemId]);
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't jave any Crime!");

							//Stop:
							break;
						}
					}

					//Money Detector:
					else if(ItemAction[ItemId] == 34)
					{

						//Is Activated:
						if(ItemDetector[Client] == 2)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - DeActivate your \x0732CD32Item Detector\x07FFFFFF!");
						}

						//Is Activated:
						else if(ItemDetector[Client] == 0)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Activated your \x0732CD32Money Detector\x07FFFFFF!");

							//Initulize:
							ItemDetector[Client] = 1;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Deactivated your \x0732CD32Money Detector\x07FFFFFF!");

							//Initulize:
							ItemDetector[Client] = 0;
						}

						//Stop:
						break;
					}

					//Item Detector:
					else if(ItemAction[ItemId] == 35)
					{

						//Is Activated:
						if(ItemDetector[Client] == 1)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - DeActivate your \x0732CD32Money Detector\x07FFFFFF!");
						}

						//Is Activated:
						else if(ItemDetector[Client] == 0)
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Activated your \x0732CD32Item Detector\x07FFFFFF!");

							//Initulize:
							ItemDetector[Client] = 2;
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Deactivated your \x0732CD32Item Detector\x07FFFFFF!");

							//Initulize:
							ItemDetector[Client] = 0;
						}

						//Stop:
						break;
					}

					//Police Jammer:
					else if(ItemAction[ItemId] == 36)
					{

						//Already has Jammer Check:
						if(PoliceJammerTime[Client] > GetGameTime())
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already useda Police Jammer.");
						}

						//Override:
						else
						{

							//Declare:
							new Var = StringToInt(ItemVar[ItemId]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Initializing Police Jammer for %i minutes.", Var);

							//Initulize:
							PoliceJammerTime[Client] = GetGameTime() + (60*Var);

							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Stop:
						break;
					}

					//Police Scanner:
					else if(ItemAction[ItemId] == 37)
					{

						//Already has Jammer Check:
						if(PoliceScannerTime[Client] > GetGameTime())
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already useda Police Scanner.");
						}

						//Override:
						else
						{

							//Declare:
							new Var = StringToInt(ItemVar[ItemId]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Initializing Police Detector.", Var);

							//Initulize:
							PoliceScannerTime[Client] = GetGameTime() + (60*Var);

							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Stop:
						break;
					}

					//Bounty Jammer:
					else if(ItemAction[ItemId] == 38)
					{

						//Already has Jammer Check:
						if(BountyJammerTime[Client] > GetGameTime())
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already used a Bounty Jammer.");
						}

						//Override:
						else
						{

							//Declare:
							new Var = StringToInt(ItemVar[ItemId]);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Initializing Bounty Jammer.", Var);

							//Initulize:
							BountyJammerTime[Client] = GetGameTime() + (60*Var);

							Item[Client][ItemId]--;

							//Save Item If Used:
							SaveItem(Client, ItemId, Item[Client][ItemId]);
						}

						//Stop:
						break;
					}

					//Water:
					else if(ItemAction[ItemId] == 39)
					{

						//Declare:
						new Float:Var = StringToFloat(ItemVar[ItemId]);

						//Declare:
						new Ent = GetClientAimTarget(Client, false);
	
						//Is Valid:
						if(Ent > 1)
						{

							//Valid Check:
							if(IsValidPlant(Ent))
							{

								//Check and Loop:
								if(IsInDistance(Client, Ent)) for(new i = 1; i <= GetMaxClients(); i++)
								{

									//Connected:
									if(IsClientConnected(i) && IsClientInGame(i))
									{

										//Loop:
										for(new Y = 1; Y <= 10; Y++)
										{

											//Initulize:
											new Ent2 = HasClientPlant(i, Y);

											//Check:
											if(Ent == Ent2)
											{

												//Has Enough Water:
												if(GetPlantWaterLevel(i, Y) + Var > 100.0)
												{

													//Initulize:
													SetPlantWaterLevel(Client, Y, 100.0);
												}

												//Override
												else
												{

													//Initulize:
													SetPlantWaterLevel(Client, Y, (GetPlantWaterLevel(i, Y) + Var));
												}

												//Check:
												if(i != Client)
												{

													//Print:
													CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have watered %.2f, %N Plant!", Var, i);
												}

												//Override:
												else
												{

													//Print:
													CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have watered %.2f of this Plant!", Var);
												}

												//Save Item If Used:
												SaveItem(Client, ItemId, Item[Client][ItemId]);

												//Initialize:
												Item[Client][ItemId]--;

												//Stop:
												break;
											}
										}
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are too far away from the Drug Plant!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Drug Plant!");
							}
						}
					}

					//JiHad:
					else if(ItemAction[ItemId] == 40)
					{

						//Is Cop:
						if(IsCop(Client))
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Cops can't use \x0732CD32Security PvP's\x07FFFFFF!.");

							//Stop:
							break;
						}

						//Override:
						else
						{

							//Initulize:
							Item[Client][ItemId] -= 1;

							//Declare:
							new Float:Origin[3];

							//Initulize:
							GetEntPropVector(Client, Prop_Send, "m_vecOrigin", Origin);

							//Emit:
							EmitAmbientSound("play music/jihad.wav", Origin, Client, SNDLEVEL_NORMAL);

							//Timer:
							CreateTimer(3.05, ExplodeTimer, Client);

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You used a JIHAD BOMB!!!!!! and will explode in \x0732CD323.5\x07FFFFFF seconds");

							//Stop:
							break;
						}
					}

					//Jail Pass:
					else if(ItemAction[ItemId] == 41)
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use this item when you are in jail!");

						//Stop:
						break;
					}

					//Energy Drinks:
					else if(ItemAction[ItemId] == 42)
					{

						//Valid:
						if(EnergyTime[Client] <= (GetGameTime() - 600))
						{

							//Declare:
							new Var = StringToInt(ItemVar[ItemId]);

							//Enough Hunger:
							if(GetEnergy(Client) < 100 && Var < 100)
							{

								//Initialize:
								EnergyTime[Client] = GetGameTime();

								//To Much Hunger:
								if(GetEnergy(Client) + Var < 100)
								{

									//Initialize:
									SetEnergy(Client, (GetEnergy(Client) + Var));
								}

								//Override:
								else
								{

									//Initialize:
									SetEnergy(Client, 100);
								}

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just used a \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);

								//Initialize:
								Item[Client][ItemId]--;

								//Spawn:
								SpawnGarbage(Client, 3);

								//Stop:
								break;
							}

							//Boost!
							else if(Var > 100)
							{
	
								//Check
								if(GetEnergy(Client) <= 100)
								{

									//Initialize:
									EnergyTime[Client] = GetGameTime();

									//Initialize:
									SetEnergy(Client, (GetEnergy(Client) + Var));

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have just used a \x0732CD32%s\x07FFFFFF!", ItemName[ItemId]);

									//Initialize:
									Item[Client][ItemId]--;

									//Spawn:
									new Trash = SpawnGarbage(Client, 3);

									//Set Color!
									SetEntityRenderColor(Trash, 255, 50, 50, 255);

									//Stop:
									break;
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only use \x0732CD32%s\x07FFFFFF at a time!", ItemName[ItemId]);

									//Stop:
									break;
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot Use this item because your energy is full!");

								//Stop:
								break;
							}
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can't spam this item!.");

							//Stop:
							break;
						}
					}

					//Job Items:
					else if(ItemAction[ItemId] == 43)
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You can only drop or trade these items!");

						//Stop:
						break;
					}

					//Generator Fuel:
					else if(ItemAction[ItemId] == 44)
					{

						//Declare:
						new Float:Var = StringToFloat(ItemVar[ItemId]);

						//Declare:
						new Ent = GetClientAimTarget(Client, false);
	
						//Is Valid:
						if(Ent > 1)
						{

							//Valid Check:
							if(IsValidGenerator(Ent))
							{

								//Check and Loop:
								if(IsInDistance(Client, Ent)) for(new i = 1; i <= GetMaxClients(); i++)
								{

									//Connected:
									if(IsClientConnected(i) && IsClientInGame(i))
									{

										//Loop:
										for(new Y = 1; Y <= 10; Y++)
										{

											//Initulize:
											new Ent2 = HasClientGenerator(i, Y);

											//Check:
											if(Ent == Ent2)
											{

												//Declare:
												new Level = GetGeneratorLevel(i, Y);

												//Check:
												if(GetGeneratorFuel(i, Y) < float(Level * 250))
												{

													//Has Enough Water:
													if(GetGeneratorFuel(i, Y) + Var > float(Level * 250))
													{

														//Initulize:
														SetGeneratorFuel(i, Y, float(Level * 250));
													}

													//Override
													else
													{

														//Initulize:
														SetGeneratorFuel(i, Y, (GetGeneratorFuel(i, Y) + Var));
													}

													//Check:
													if(i != Client)
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Refueled %.2L, Of %N Generator!", Var, i);
													}

													//Override:
													else
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have Refueled %.2fL of this Generator!", Var);
													}

													//Initialize:
													Item[Client][ItemId]--;

													//Save Item If Used:
													SaveItem(Client, ItemId, Item[Client][ItemId]);
												}

												//Override:
												else
												{

													//Print:
													CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This Generator is already full of fuel!", Var);
												}

												//Stop:
												break;
											}
										}
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are too far away from the Generator!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Generator!");
							}
						}
					}

					//Generator:
					else if(ItemAction[ItemId] == 45)
					{

						//Handle Bomb:
						OnItemsGeneratorUse(Client, ItemId);

						//Stop:
						break;
					}

					//BitCoin Mine:
					else if(ItemAction[ItemId] == 46)
					{

						//Handle Bomb:
						OnItemsBitCoinMineUse(Client, ItemId);

						//Stop:
						break;
					}

					//Printer Paper:
					else if(ItemAction[ItemId] == 47)
					{

						//Declare:
						new Var = StringToInt(ItemVar[ItemId]);

						//Declare:
						new Ent = GetClientAimTarget(Client, false);
	
						//Is Valid:
						if(Ent > 1)
						{

							//Valid Check:
							if(IsValidPrinter(Ent))
							{

								//Check and Loop:
								if(IsInDistance(Client, Ent)) for(new i = 1; i <= GetMaxClients(); i++)
								{

									//Connected:
									if(IsClientConnected(i) && IsClientInGame(i))
									{

										//Loop:
										for(new Y = 1; Y <= 10; Y++)
										{

											//Initulize:
											new Ent2 = HasClientPrinter(i, Y);

											//Check:
											if(Ent == Ent2)
											{

												//Declare:
												new Level = GetPrinterLevel(i, Y);

												//Check:
												if(GetPrinterPaper(i, Y) < (Level * 5000))
												{

													//Has Enough Water:
													if((GetPrinterPaper(i, Y) + Var) > (Level * 5000))
													{

														//Initulize:
														SetPrinterPaper(i, Y, (Level * 5000));
													}

													//Override
													else
													{

														//Initulize:
														SetPrinterPaper(i, Y, (GetPrinterPaper(i, Y) + Var));
													}

													//Check:
													if(i != Client)
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have inserted if Sheets of paper to %N Printer!", Var, i);
													}

													//Override:
													else
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have inserted %i Sheets of paper to your Printer!", Var);
													}

													//Initialize:
													Item[Client][ItemId]--;

													//Save Item If Used:
													SaveItem(Client, ItemId, Item[Client][ItemId]);
												}

												//Override:
												else
												{

													//Print:
													CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This Printer is already full of paper!", Var);
												}

												//Stop:
												break;
											}
										}
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are too far away from the printer!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Printer!");
							}
						}

						//Stop:
						break;
					}

					//Printer Ink:
					else if(ItemAction[ItemId] == 48)
					{

						//Declare:
						new Float:Var = StringToFloat(ItemVar[ItemId]);

						//Declare:
						new Ent = GetClientAimTarget(Client, false);
	
						//Is Valid:
						if(Ent > 1)
						{

							//Valid Check:
							if(IsValidPrinter(Ent))
							{

								//Check and Loop:
								if(IsInDistance(Client, Ent)) for(new i = 1; i <= GetMaxClients(); i++)
								{

									//Connected:
									if(IsClientConnected(i) && IsClientInGame(i))
									{

										//Loop:
										for(new Y = 1; Y <= 10; Y++)
										{

											//Initulize:
											new Ent2 = HasClientPrinter(i, Y);

											//Check:
											if(Ent == Ent2)
											{

												//Declare:
												new Level = GetPrinterLevel(i, Y);

												//Check:
												if(GetPrinterInk(i, Y) < float(Level * 200))
												{

													//Has Too Much Ink:
													if((GetPrinterInk(i, Y) + Var) > float(Level * 200))
													{

														//Initulize:
														SetPrinterInk(i, Y, float(Level * 250));
													}

													//Override
													else
													{

														//Initulize:
														SetPrinterInk(i, Y, (GetPrinterInk(i, Y) + Var));
													}

													//Check:
													if(i != Client)
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have inserted %0.2mL of Ink to %N Printer!", RoundFloat(Var), i);
													}

													//Override:
													else
													{

														//Print:
														CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have inserted %0.2mL of Ink to your Printer!", Var);
													}

													//Initialize:
													Item[Client][ItemId]--;

													//Save Item If Used:
													SaveItem(Client, ItemId, Item[Client][ItemId]);
												}

												//Override:
												else
												{

													//Print:
													CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This Printer is already full of paper!", Var);
												}

												//Stop:
												break;
											}
										}
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are too far away from the printer!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Printer!");
							}
						}

						//Stop:
						break;
					}

					//Propane Tank:
					else if(ItemAction[ItemId] == 49)
					{

						//Handle Bomb:
						OnItemsPropaneTankUse(Client, ItemId);

						//Stop:
						break;
					}

					//Phosphoru Tank:
					else if(ItemAction[ItemId] == 50)
					{

						//Handle Bomb:
						OnItemsPhosphoruTankUse(Client, ItemId);

						//Stop:
						break;
					}

					//Sodium Tub:
					else if(ItemAction[ItemId] == 51)
					{

						//Handle Bomb:
						OnItemsSodiumTubUse(Client, ItemId);

						//Stop:
						break;
					}

					//HcAcid Tub:
					else if(ItemAction[ItemId] == 52)
					{

						//Handle Bomb:
						OnItemsHcAcidTubUse(Client, ItemId);

						//Stop:
						break;
					}

					//Acetone Can:
					else if(ItemAction[ItemId] == 53)
					{

						//Handle Bomb:
						OnItemsAcetoneCanUse(Client, ItemId);

						//Stop:
						break;
					}

					//Drug Seeds:
					else if(ItemAction[ItemId] == 54)
					{

						//Handle Bomb:
						OnItemsSeedsUse(Client, ItemId);

						//Stop:
						break;
					}

					//Drug Lamp:
					else if(ItemAction[ItemId] == 55)
					{

						//Handle Bomb:
						OnItemsLampUse(Client, ItemId);

						//Stop:
						break;
					}

					//Erythroxylum:
					else if(ItemAction[ItemId] == 56)
					{

						//Handle Bomb:
						OnItemsErythroxylumUse(Client, ItemId);

						//Stop:
						break;
					}

					//Benzocaine:
					else if(ItemAction[ItemId] == 57)
					{

						//Handle Bomb:
						OnItemsBenzocaineUse(Client, ItemId);

						//Stop:
						break;
					}


					//Battery:
					else if(ItemAction[ItemId] == 58)
					{

						//Handle Bomb:
						OnItemsBatteryUse(Client, ItemId);

						//Stop:
						break;
					}

					//Save Item If Used:
					SaveItem(Client, ItemId, Item[Client][ItemId]);
				}
			}
		}
	}

	//Return:
	return Plugin_Handled;
}

//Vendor Menus:
public Action:PlayerBuyMenu(Client)
{

	//Handle:
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");

	//Find:
	FileToKeyValues(Vault, BuyPath);

	//Declare:
	decl String:JobId[32], String:Key[255], String:ReferenceString[255];

	//Handle:
	new Handle:Menu = CreateMenu(HandleBuyItems);

	//Declare:
	new Ent = TargetMenu[Client];

	//Declare:
	decl String:DisplayItem[64];

	//Loop:
	for(new X = 1; X < 25; X++) if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
	{

		//Convert:
		IntToString(X, Key, sizeof(Key));

		//Format:
		Format(JobId, sizeof(JobId), "%s", GetJob(Ent));

		//Load:
		LoadString(Vault, JobId, Key, "Null", ReferenceString);

		//Check:
		if(!StrEqual(ReferenceString, "Null"))
		{

			//Declare:
			new ItemId, Price;

			//Initulize:
			ItemId = StringToInt(ReferenceString);

			//Is Trader:
			if(StrContains(GetJob(Ent), "Trader", false) != -1)
			{

				//Initulize:
				Price = RoundFloat(ItemCost[ItemId] / 1.4);
			}

			//Override:
			else
			{

				//Initulize:
				Price = RoundFloat(ItemCost[ItemId] / 1.2);
			}

			//Format:
			Format(DisplayItem, 64, "[€%i] %s", Price, GetItemName(ItemId));

			//Menu Buttons:
			AddMenuItem(Menu, ReferenceString, DisplayItem);
		}
	}

	//Title:
	SetMenuTitle(Menu, "Hello, do you want to buy\nsome items for your inventory?");

	//Max Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);
}

//PlayerMenu Handle:
public HandleBuyItems(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			decl String:info[64];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Ent = TargetMenu[Client];

			//Connected:
			if(Ent > 0 && Client != Ent && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//To Far Away:
				if(IsInDistance(Client, Ent))
				{

					//Initialize:
					new ItemId = StringToInt(info);

					//Enough stamina:
					if(GetEnergy(Ent) >= 15)
					{

						//Declare:
						new CCash;

						//Is Trader:
						if(StrContains(GetJob(Ent), "Trader", false) != -1)
						{

							//Initulize:
							CCash = RoundFloat(ItemCost[ItemId] / 1.4);
						}

						//Override:
						else
						{

							//Initulize:
							CCash = RoundFloat(ItemCost[ItemId] / 1.2);
						}

						//Enough Cash:
						if(GetCash(Client) > CCash)
						{

							if(CCash >= 20000)
							{

								//Initialize:
								SetJobExperience(Ent, (GetJobExperience(Ent) + 10));
							}

							else if(CCash >= 5000)
							{

								//Initialize:
								SetJobExperience(Ent, (GetJobExperience(Ent) + 5));
							}

							else if(CCash >= 1000)
							{

								//Initialize:
								SetJobExperience(Ent, (GetJobExperience(Ent) + 2));
							}

							//Initialize:
							Item[Client][ItemId] += 1;

							//Save Item:
							SaveItem(Client, ItemId, Item[Client][ItemId]);

							//Declare:
							new ECash;

							//Is Trader:
							if(StrContains(GetJob(Ent), "Trader", false) != -1)
							{

								//Initulize:
								ECash = RoundToNearest(ItemCost[ItemId]/4.0);
							}

							//Override:
							else
							{

								//Initulize:
								ECash = RoundToNearest(ItemCost[ItemId]/5.0);
							}

							//Initialize:
							SetCash(Ent, (GetCash(Ent) + ECash));

							SetCash(Client, (GetCash(Client) - CCash));

							//Initialize:
							SetEnergy(Ent, (GetEnergy(Ent) - 15));

							//Print:
							CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has bought a \x0732CD32%s\x07FFFFFF, You made €\x0732CD32%i\x07FFFFFF!", Client, ItemName[ItemId], ECash);

							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You bought a \x0732CD32%s\x07FFFFFF from \x0732CD32%N\x07FFFFFF for €\x0732CD32%i\x07FFFFFF!", ItemName[ItemId], Ent, CCash);

							//Play Sound:
							EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
						}

						//Override:
						else
						{

							//Print:
							CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have enough Cash for this item (Item Price \x0732CD32%i\x07FFFFFF).", CCash);
						}
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This player doesnt have enough Energy.");

						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF tryed to buy an item but you dont have enough Energy.", Client);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are to far away from this player, move clooser..");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
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

//DrugTick:
public Action:OnDrugTick(Client)
{

	//Initialize:
	new CHP = GetClientHealth(Client);

	//On Drugs:
	if(CHP > 100 && DrugTick[Client] != -1 && DrugHealth[Client] != 0 && !IsCop(Client))
	{

		//Enough Health:
		if((CHP - 1) < 100)
		{

			//Set Ent Health:
			SetEntityHealth(Client, 100);
		}

		//Override:
		else
		{

			//Set Ent Health:
			SetEntityHealth(Client, (CHP - 1));
		}

		//Initulize:
		DrugHealth[Client] -= 1;
	}

	//Off Drugs
	if(DrugTick[Client] == 0)
	{

		//Timer:
		CreateTimer(1.0, backspeed, Client);

		//Initulize:
		DrugTick[Client] = -1;

		DrugHealth[Client] = 0;

		//Clear:
		CheatCommand(Client, "r_screenoverlay", "0");
	}
}

//Stop Speed:
public Action:backspeed(Handle:Timer, any:Client)
{

	//Connected:
	if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
	{

		//Set Client Speed:
		SetEntitySpeed(Client, 1.0);
	}
}

public Action:ExplodeTimer(Handle:Timer, any:Client) 
{

	//Is Client:
	if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client) && IsPlayerAlive(Client) && !IsCuffed(Client))
	{

		//Slay Client:
		ForcePlayerSuicide(Client);

		//Explode:
		CreateExplosion(Client, Client);
	}
}

public Action:OnClientPickUpItem(Client, Ent)
{

	//Loop:
	for(new X = 0; X < MAXITEMS; X++) if(ItemAmount[Ent][X] > 0)
	{

		//Remove Ent:
		AcceptEntityInput(Ent, "Kill", Client);

		//Exchange:
		Item[Client][X] += ItemAmount[Ent][X];

		//Save:
		SaveItem(Client, X, Item[Client][X]);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You pick up \x0732CD32%i\x07FFFFFF x \x0732CD32%s\x07FFFFFF!", ItemAmount[Ent][X], ItemName[X]);

		//Initialize:
		ItemAmount[Ent][X] = 0;

		//Initulize:
		SetPropSpawnedTimer(Ent, -1);

		SetPropIndex((GetPropIndex() - 1));
#if defined DEBUG
		//Declare:
		decl String:SteamId[32];
	
		//Initialize:
		GetClientAuthString(Client, SteamId, sizeof(SteamId));

		//Loggng:
		LogMessage("%N <%s> picked x%i amount of %s", Client, SteamId, ItemAmount[Ent][X], ItemName[X]);
#endif

		//Stop:
		break;
	}
}

public bool:IsValidDroppedItem(Ent)
{

	//Loop:
	for(new X = 0; X < MAXITEMS; X++) if(ItemAmount[Ent][X] > 0)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}
public GetDrugTick(Client)
{

	//Return:
	return DrugTick[Client];
}

public Action:ResetDrugs(Client)
{

	//Initulize:	
	DrugTick[Client] = -1;

	DrugHealth[Client] = -1;
}

public SetDrugTick(Client, Amount)
{

	//Initulize:	
	DrugTick[Client] = Amount;
}

public GetDrugHealth(Client)
{

	//Return:
	return DrugHealth[Client];
}

public SetDrugHealth(Client, Amount)
{

	//Initulize:	
	DrugHealth[Client] = Amount;
}

public GetItemGroup(ItemId)
{

	//Return:
	return ItemGroup[ItemId];
}

public SetItemGroup(ItemId, Amount)
{

	//Initulize:
	ItemGroup[ItemId] = Amount;
}
public GetItemCost(ItemId)
{

	//Return:
	return ItemCost[ItemId];
}

public SetItemCost(ItemId, Amount)
{

	//Initulize:
	ItemCost[ItemId] = Amount;
}

String:GetItemName(ItemId)
{

	//return:
	return ItemName[ItemId];
}

public SetItemName(ItemId, String:Str[])
{

	//Format:
	Format(ItemName[ItemId], sizeof(ItemName[]), "%s", Str);
}

public GetItemAction(ItemId)
{

	//Return:
	return ItemAction[ItemId];
}

public SetItemAction(ItemId, Amount)
{

	//Initulize:
	ItemAction[ItemId] = Amount;
}

public GetIsGiving(Client)
{

	//Return:
	return IsGiving[Client];
}

public SetIsGiving(Client, Result)
{

	//Initulize:
	IsGiving[Client] = Result;
}

public GetSelectedItem(Client)
{

	//Return:
	return SelectedItem[Client];
}

public SetSelectedItem(Client, Result)
{

	//Initulize:
	SelectedItem[Client] = Result;
}

String:GetItemVar(ItemId)
{

	//return:
	return ItemVar[ItemId];
}

public SetItemVar(ItemId, String:Str[])
{

	//Format:
	Format(ItemVar[ItemId], sizeof(ItemVar[]), "%s", Str);
}

public GetDroppedItemValue(Ent, ItemId)
{

	//Return:
	return ItemAmount[Ent][ItemId];
}

public SetDroppedItemValue(Ent, ItemId, Amount)
{

	//Initulize:
	ItemAmount[Ent][ItemId] = Amount;
}

public GetItemDetector(Client)
{

	//Return:
	return ItemDetector[Client];
}

public Float:GetPoliceJammerTime(Client)
{

	//Return:
	return PoliceJammerTime[Client];
}

public Float:GetPoliceScannerTime(Client)
{

	//Return:
	return PoliceScannerTime[Client];
}


public Float:GetBountyJammerTime(Client)
{

	//Return:
	return BountyJammerTime[Client];
}