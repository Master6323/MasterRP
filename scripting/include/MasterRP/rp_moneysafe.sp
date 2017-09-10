//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_moneysafe_included_
  #endinput
#endif
#define _rp_moneysafe_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = €

#define	MAXSAFES		32

//Useable Item Models!
//static String:MoneySafeModel[256] = "models/ice_dragon/grey_medium_safe.mdl";
static String:MoneySafeModel[256] = "models/dragon/black_safe.mdl";

//Money Safe MAXSAFES
static SafeEnt[MAXSAFES + 1];
static SafeMoney[MAXSAFES + 1];
static SafeLocks[MAXSAFES + 1];
static SafeOwner[MAXSAFES + 1];
static BankOwnedSafe[MAXSAFES + 1];
static String:SafeName[MAXSAFES + 1][255];
static SafeRobId[MAXPLAYERS + 1];
static SafeRob[MAXSAFES + 1];
static SafeHarvest[MAXSAFES + 1];
static SafeMeth[MAXSAFES + 1];
static SafePills[MAXSAFES + 1];
static SafeCocain[MAXSAFES + 1];

static RobCash[MAXPLAYERS + 1] = {0,...};
static Float:RobOrigin[MAXPLAYERS + 1][3];
static MenuTarget[MAXPLAYERS + 1] = {0,...};

public Action:PluginInfo_MoneySafe(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Advanced SQL MoneySafe!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V2.62.82");
}

initMoneySafe()
{

	//Money Safes
	RegAdminCmd("sm_createmoneysafe", CommandCreateMoneySafe, ADMFLAG_ROOT, "<id> - Creates a spawn point");

	RegAdminCmd("sm_removemoneysafe", CommandRemoveMoneySafe, ADMFLAG_ROOT, "<id> - Removes a spawn point");

	RegAdminCmd("sm_listmoneysafe", CommandListMoneySafe, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updatesafeposition", CommandUpdateSafePosition, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_updatesafemap", CommandUpdateSafeMap, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafemoney", CommandSetSafeMoney, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafeowner", CommandSetSafeOwner, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_takesafeowner", CommandTakeSafeOwner, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafesteamid", CommandSetSafeSteamId, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafelocks", CommandSetSafeLocks, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafename", CommandSetSafeName, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setbankowned", CommandSetBankOwned, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_viewsafeowner", CommandViewSafeOwner, ADMFLAG_SLAY, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafeharvest", CommandSetSafeHarvest, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafemeth", CommandSetSafeMeth, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafecocain", CommandSetSafeCocain, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	RegAdminCmd("sm_setsafepills", CommandSetSafePills, ADMFLAG_ROOT, "- Lists all the Spawnss in the database");

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Initialize:
		SafeRob[X] = 600;
	}

	//Loop:
	for(new i = 0; i < GetMaxClients(); i++)
	{

		//Initulize:
		SafeRobId[i] = -1;
	}

	//Timers:
	CreateTimer(0.2, CreateSQLdbMoneySafe);

}
//Create Database:
public Action:CreateSQLdbMoneySafe(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `MoneySafe`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `SafeId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(32) NOT NULL, `Angles` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeMoney` int(11) NOT NULL,  `SafeLocks` int(11) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeOwner` int(11) NOT NULL, `BankOwnedSafe` int(5) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeName` varchar(255) NULL, `SafeHarvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeMeth` varchar(255) NULL, `SafePills` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `SafeCocain` int(12) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

}

//Create Database:
public Action:LoadMoneySafe(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM MoneySafe WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadMoneySafe, query);
}

public T_DBLoadMoneySafe(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadMoneySafe: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Money Safes Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new X, Money, Locks, Owner, BankOwned, SafeH, SafeM, SafeP, SafeC; decl String:Buffer[32];

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, Buffer, 32);

			//Weapon Check:
			if(StrEqual(Buffer, ServerMap()))
			{

				//Database Field Loading String:
				SQL_FetchString(hndl, 2, Buffer, 32);

				//Database Field Loading Intiger:
				X = SQL_FetchInt(hndl, 1);

				//Declare:
				decl String:Dump[3][32]; new Float:Position[3], Float:Angles[3];

				//Convert:
				ExplodeString(Buffer, "^", Dump, 3, 32);

				//Loop:
				for(new Y = 0; Y <= 2; Y++)
				{

					//Initulize:
					Position[Y] = StringToFloat(Dump[Y]);
				}

				//Database Field Loading String:
				SQL_FetchString(hndl, 3, Buffer, 32);

				//Convert:
				ExplodeString(Buffer, "^", Dump, 3, 32);

				//Loop:
				for(new Y = 0; Y <= 2; Y++)
				{

					//Initulize:
					Angles[Y] = StringToFloat(Dump[Y]);
				}

				//Database Field Loading Intiger:
				Money = SQL_FetchInt(hndl, 4);

				//Database Field Loading Intiger:
				Locks = SQL_FetchInt(hndl, 5);

				//Database Field Loading Intiger:
				Owner = SQL_FetchInt(hndl, 6);

				//Database Field Loading Intiger:
				BankOwned = SQL_FetchInt(hndl, 7);

				//Database Field Loading String:
				SQL_FetchString(hndl, 8, Buffer, 32);

				//Database Field Loading Intiger:
				SafeH = SQL_FetchInt(hndl, 9);

				//Database Field Loading Intiger:
				SafeM = SQL_FetchInt(hndl, 10);

				//Database Field Loading Intiger:
				SafeP = SQL_FetchInt(hndl, 11);

				//Database Field Loading Intiger:
				SafeC = SQL_FetchInt(hndl, 12);

				//Create Thumper:
				CreatePropMoneySafe(Position, Angles, X, Money, Locks, Owner, BankOwned, Buffer, SafeH, SafeM, SafeP, SafeC);
			}
		}

		//Print:
		PrintToServer("|RP| - Money Safe Found!");
	}
}

public Action:BeginRobberySafe(Handle:Timer, any:Client)
{

	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client)) return Plugin_Handled;

	//Cleared:
	if(RobCash[Client] < 1 || !IsPlayerAlive(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF Stopped robbing a Money Safe!", Client);

		//Initulize::
		RobCash[Client] = 0;

		SafeRobId[Client] = -1;

		//Kill:
		KillTimer(Timer);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Dist, Float:ClientOrigin[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	Dist = GetVectorDistance(RobOrigin[Client], ClientOrigin);
	
	//Too Far Away:
	if(Dist >= 250)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		RobCash[Client] = 0;

		SafeRobId[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Random;

	//Is Valid:
	if(StrContains(GetJob(Client), "Street Thug", false) != -1 || StrContains(GetJob(Client), "Root Admin", false) != -1)
	{

		//Initulize:
		Random = GetRandomInt(5, 10);
	}

	//Override:
	else
	{

		//Initulize:
		Random = GetRandomInt(2, 5);
	}

	//Declare:
	new X = SafeRobId[Client];

	//Cleared:
	if(SafeMoney[X] - Random > 0)
	{

		//Initulize:
		RobCash[Client] -= Random;

		SafeMoney[X] -= Random;

		//Initialize:
		SetCash(Client, (GetCash(Client) + Random));

		//Initialize:
		SetCrime(Client, (GetCrime(Client) + (Random * Random)));

		//Set Menu State:
		CashState(Client, Random);

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", GetCash(Client), SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMoney[X], SafeOwner[X], ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is getting away!", Client);

		//Initulize::
		RobCash[Client] = 0;

		SafeRobId[Client] = -1;

		//Kill:
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Handled;
}

//Use Handle:
public bool:IsValidSafe(Ent)
{

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action:BeginSafeRob(Client, SafeCash, X)
{

	//Is In Time:
	if(GetLastPressedE(Client) < (GetGameTime() - 1.5))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Press \x0732CD32<<Shift>>\x07FFFFFF Again to rob the Money Safe!");

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	//Cuffed:
	else if(IsCuffed(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are cuffed you can't rob this money safe!");

		//Return:
		return Plugin_Continue;
	}

	//Is Robbing:
	else if(RobCash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You are already robbing!");

		//Return:
		return Plugin_Continue;
	}

	//Ready:
	else if(SafeRob[X] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This \x0732CD32Money Safe\x07FFFFFF has been robbed too recently, (\x0732CD32%i\x07FFFFFF) Seconds left!", SafeRob[X]);

		//Return:
		return Plugin_Continue;
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - Prevent crime, do not start it!");

		//Return:
		return Plugin_Continue;
	}

	//Override:
	else
	{

		//Save:
		SafeRob[X] = 600;

		//Start:
		RobCash[Client] = SafeCash;

		SafeRobId[Client] = X;

		//Add Crime:
		SetCrime(Client, (GetCrime(Client) + 150));

		//Print:
		CPrintToChatAll("\x07FF4040|RP-Rob|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is robbing a \x0732CD32Money Safe\x07FFFFFF!", Client);

		//Timer:
		CreateTimer(1.0, BeginRobberySafe, Client, TIMER_REPEAT);
	}

	//Return:
	return Plugin_Continue;
}

public iRobTimer()
{

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Check
		if(SafeRob[X] != 0) SafeRob[X] -= 1;
	}
}
public Action:DrawMoneySafeMenu(Client, X)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleMoneySafe);

	//Title:
	SetMenuTitle(Menu, "Your safe Balence is €%i\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeMoney[X], SafeHarvest[X], SafeMeth[X], SafeCocain[X], SafePills[X]);

	//Menu Button:
	AddMenuItem(Menu, "0", "Deposit Cash");

	//Menu Button:
	AddMenuItem(Menu, "1", "Withdraw Cash");

	//Menu Button:
	AddMenuItem(Menu, "4", "Store Drugs");

	//Menu Button:
	AddMenuItem(Menu, "2", "Update Name");

	//Menu Button:
	AddMenuItem(Menu, "3", "Add Locks");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);

	//Initulize:
	MenuTarget[Client] = X;

	//Override:
	if(GetCash(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32<<ESC>>\x07FFFFFF for a menu!");
	}
}

//PlayerMenu Handle:
public HandleMoneySafe(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new X = MenuTarget[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Declare:
			decl String:AllBank[32],String:bAllBank[32];

			//Format:
			Format(AllBank, 32, "All (€%i)", GetCash(Client));

			Format(bAllBank, 32, "%i", GetCash(Client));

			//Handle:
			Menu = CreateMenu(HandleMoneySafeDeposit);

			//Title:
			SetMenuTitle(Menu, "Your safe Balence is €%i\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeMoney[X], SafeHarvest[X], SafeMeth[X], SafeCocain[X], SafePills[X]);

			//Menu Buttons:
			AddMenuItem(Menu, bAllBank, AllBank);

			AddMenuItem(Menu, "1", "1");

			AddMenuItem(Menu, "5", "5");

			AddMenuItem(Menu, "10", "10");

			AddMenuItem(Menu, "20", "20");

			AddMenuItem(Menu, "50", "50");

			AddMenuItem(Menu, "100", "100");

			AddMenuItem(Menu, "200", "200");

			AddMenuItem(Menu, "500", "500");

			AddMenuItem(Menu, "1000", "1000");

			AddMenuItem(Menu, "5000", "5000");

			AddMenuItem(Menu, "10000", "10000");

			AddMenuItem(Menu, "50000", "50000");

			AddMenuItem(Menu, "100000", "100000");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 20);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Declare:
			decl String:AllBank[32],String:bAllBank[32];

			//Format:
			Format(AllBank, 32, "All (€%i)", SafeMoney[X]);

			Format(bAllBank, 32, "%i", SafeMoney[X]);

			//Handle:
			Menu = CreateMenu(HandleMoneySafeWithdraw);

			//Title:
			SetMenuTitle(Menu, "Your safe Balence is €%i\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeMoney[X], SafeHarvest[X], SafeMeth[X], SafeCocain[X], SafePills[X]);

			//Menu Buttons:
			AddMenuItem(Menu, bAllBank, AllBank);

			AddMenuItem(Menu, "1", "1");

			AddMenuItem(Menu, "5", "5");

			AddMenuItem(Menu, "10", "10");

			AddMenuItem(Menu, "20", "20");

			AddMenuItem(Menu, "50", "50");

			AddMenuItem(Menu, "100", "100");

			AddMenuItem(Menu, "200", "200");

			AddMenuItem(Menu, "500", "500");

			AddMenuItem(Menu, "1000", "1000");

			AddMenuItem(Menu, "5000", "5000");

			AddMenuItem(Menu, "10000", "10000");

			AddMenuItem(Menu, "50000", "50000");

			AddMenuItem(Menu, "100000", "100000");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 20);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Declare:
			decl String:query[255], String:ClientName[255], String:CNameBuffer[255];

			//Initialize:
			GetClientName(Client, ClientName, sizeof(ClientName));

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), ClientName, CNameBuffer, sizeof(CNameBuffer));

			//Copy String From Buffer:
			strcopy(SafeName[X], sizeof(SafeName[]), ClientName);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeName = '%s' WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeName[X], SteamIdToInt(Client), ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You have updated your MoneySafe name!");
		}

		//Button Selected:
		if(Result == 3)
		{
/*
			//Declare:
			decl String:AllLocks[32],String:bAllLocks[32];

			//Format:
			//Format(AllLocks, 32, "All (%i)", Item[Client][58]);

			//Format(bAllLocks, 32, "%i", Item[Client][58]);

			//Handle:
			Menu = CreateMenu(HandleMoneySafeAddLocks);

			//Title:
			SetMenuTitle(Menu, "Your safe Balence is €%i\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig\nyou can only add (1) Lock items", SafeMoney[X], SafeHarvest[X], SafeMeth[X], SafeCocain[X], SafePills[X]);

			//Menu Buttons:
			AddMenuItem(Menu, bAllLocks, AllLocks);

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
*/
		}

		//Button Selected:
		if(Result == 4)
		{

			//Handle:
			Menu = CreateMenu(HandleMoneySafeDrugs);

			//Title:
			SetMenuTitle(Menu, "Your safe Balence is €%i\nHarvest: %ig\nMeth: %ig\nCocain: %ig\nPills: %ig", SafeMoney[X], SafeHarvest[X], SafeMeth[X], SafeCocain[X], SafePills[X]);

			//Menu Buttons:
			AddMenuItem(Menu, "1", "Take Drugs");

			AddMenuItem(Menu, "2", "Store Drugs in safe");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 20);
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
public HandleMoneySafeDrugs(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new X = MenuTarget[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Button Selected Take Drugs:
		if(Result == 1)
		{

			//Has Harvest:
			if(SafeHarvest[X] > 0 || SafeMeth[X] > 0 || SafeCocain[X] > 0 || SafePills[X] > 0)
			{

				//Initulize:
				SetHarvest(Client, (GetHarvest(Client) + SafeHarvest[X]));

				SetMeth(Client, (GetMeth(Client) + SafeMeth[X]));

				SetPills(Client, (GetPills(Client) + SafePills[X]));

				SetCocain(Client, (GetCocain(Client) + SafeCocain[X]));

				//Declare:
				decl String:query[255];

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have taken \x0732CD32%i\x07FFFFFF Grams in your \x0732CD32Money Safe\x07FFFFFF!", (GetHarvest(Client) + GetMeth(Client) + GetPills(Client) + GetCocain(Client)));

				//Initulize:
				SafeHarvest[X] = 0;

				SafeMeth[X] = 0;

				SafeCocain[X] = 0;

				SafePills[X] = 0;

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = 0, SafeMeth = 0, SafeCocain = 0, SafePills = 0 WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SteamIdToInt(Client), ServerMap(), X);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You do not have any Drugs in your money safe!");
			}
		}

		//Button Selected Store Drugs:
		if(Result == 2)
		{

			//Has Harvest:
			if(GetHarvest(Client) > 0 || GetMeth(Client) > 0  || GetCocain(Client) > 0 || GetPills(Client) > 0)
			{

				//Initulize:
				SafeHarvest[X] += GetHarvest(Client);

				SafeMeth[X] += GetMeth(Client);

				SafePills[X] += GetPills(Client);

				SafeCocain[X] += GetCocain(Client);

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = %i, SafeMeth = %i, SafePills = %i, SafeCocain = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeHarvest[X], SafeMeth[X], SafePills[X], SafeCocain[X], SteamIdToInt(Client), ServerMap(), X);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You have put \x0732CD32%i\x07FFFFFF Grams in your \x0732CD32Money Safe\x07FFFFFF!", (GetHarvest(Client) + GetMeth(Client) + GetPills(Client) + GetCocain(Client)));

				//Initulize:
				SetHarvest(Client, 0);

				SetMeth(Client, 0);

				SetPills(Client, 0);

				SetCocain(Client, 0);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - You do not have any Drugs harvested!");
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
public HandleMoneySafeDeposit(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new X = MenuTarget[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Check Is Server Owned:
		if(GetCash(Client) - Amount >= 0)
		{

			//Initialize:
			SafeMoney[X] += Amount;

			SetCash(Client, (GetCash(Client) - Amount));

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMoney[X], SteamIdToInt(Client), ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You have deposited \x0732CD32€%i\x07FFFFFF into your moneysafe", Amount);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You cannot deposit this amount!");
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
public HandleMoneySafeWithdraw(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new X = MenuTarget[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Check Is Server Owned:
		if((SafeMoney[X] - Amount >= 0))
		{				

			//Initialize:
			SafeMoney[X] -= Amount;

			SetCash(Client, (GetCash(Client) + Amount));

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMoney[X], SteamIdToInt(Client), ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You have Withdrawed \x0732CD32€%i\x07FFFFFF from your moneysafe!!", Amount);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You cannot Withdraw this amount!");
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
/*
//PlayerMenu Handle:
public HandleMoneySafeAddLocks(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255]; new X = MenuTarget[Client];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info); new ItemId = 58;

		//Check Is Server Owned:
		if((Item[Client][ItemId] - Amount >= 0) && Amount != 0)
		{

			//Initialize:
			Item[Client][ItemId] -= Amount;

			SafeLocks[X] += Amount;

			//Save:
			SaveItem(Client, ItemId, Item[Client][ItemId]);

			//Initialize:
			IsQuery = true;

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeLocks = %i WHERE SafeOwner = %i AND SafeId = %i;", SafeLocks[X], SteamIdToInt(Client), X);

			//Not Created Tables:
			if(IsLoaded[Client])
			{
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
			}

			//Initialize:
			IsQuery = false;

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You have added %i \x0732CD32Locks\x07FFFFFF to your money safe!", Amount);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You don't have %i \x0732CD32Locks\x07FFFFFF!", Amount);
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
*/
//Create Thumper:
public Action:CommandCreateMoneySafe(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createmoneysafe <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3], Float:Angles[3]; decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientAbsAngles(Client, Angles);

	//Declare:
	decl String:buffer[512], String:Position[32], String:Ang[32];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Spawn Already Created:
	if(SafeEnt[StringToInt(SpawnId)] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - There is already a money safe created with this id %i");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Declare:
		new Random = GetRandomInt(100000,999999);

		//Format:
		Format(buffer, sizeof(buffer), "INSERT INTO MoneySafe (`Map`,`SafeId`,`Position`,`Angles`,`SafeOwner`,`SafeMoney`,`SafeLocks`,`BankOwnedSafe`,`SafeName`,`SafeOwner`) VALUES ('%s',%i,'%s','%s',0,0,0,0,'null', %i);", ServerMap(), StringToInt(SpawnId), Position, Ang, Random);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Created Money Safe \x0732CD32#%s\x07FFFFFF <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Return:
	return Plugin_Handled;
}

//Remove Thumper:
public Action:CommandRemoveMoneySafe(Client, Args)
{

	//No Valid Charictors:
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removemoneysafe <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM MoneySafe WHERE SafeOwner = %i  AND Map = '%s';", SafeOwner[X], ServerMap);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed Money Safe (OWNERID #\x0732CD32%s\x07FFFFFF)", SafeOwner[X]);

			SafeOwner[X] = -1;

			SafeMoney[X] = -1;

			SafeLocks[X] = -1;

			SafeRob[X] = -1;

			SafeName[X] = "null";

			SafeEnt[X] = -1;

			//Kill:
			AcceptEntityInput(Ent, "kill");
		}
	}

	//Return:
	return Plugin_Handled;
}

//List Spawns:
public Action:CommandListMoneySafe(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "MoneySafe List:");

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM MoneySafe WHERE Map = '%s' AND SafeId = %i;", ServerMap(), X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintMoneySafe, query, conuserid);
	}

	//Return:
	return Plugin_Handled;
}

//Create Thumper:
public Action:CommandUpdateSafePosition(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updatesafeposition <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3], Float:Angles[3]; decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientAbsAngles(Client, Angles);

	//Declare:
	decl String:buffer[512], String:Position[32], String:Ang[32];

	//Sql String:
	Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

	//Sql String:
	Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

	//Spawn Already Created:
	if(SafeEnt[StringToInt(SpawnId)] > 0)
	{

		//Format:
		Format(buffer, sizeof(buffer), "UPDATE MoneySafe SET Position = '%s', Angles = '%s' WHERE SafeOwner = %i, Map = '%s' AND SafeId = %i;", Position, Ang, SafeOwner[StringToInt(SpawnId)], ServerMap(), StringToInt(SpawnId));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Money Safe \x0732CD32#%s\x07FFFFFF Updated Position <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

		//Return:
		return Plugin_Handled;
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Money safe to update position");
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandUpdateSafeMap(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_updatesafemap <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SpawnId[32];

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * MoneySafe WHERE SafeId = %i;", ServerMap(), StringToInt(SpawnId));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_SQLLoadSafeID, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeName(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafename <name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32];

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Declare:
			decl String:CNameBuffer[32];

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), Arg, CNameBuffer, sizeof(CNameBuffer));

			//Copy String From Buffer:
			strcopy(SafeName[X], sizeof(SafeName[]), CNameBuffer);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeName = '%s' WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeName[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set '\x0732CD32%s\x07FFFFFF' name on this money safe", SafeName[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeMoney(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafemoney <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeMoney[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMoney[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32€%i\x07FFFFFF balence on this money safe", SafeMoney[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeLocks(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafelocks <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeLocks[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeLocks = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeLocks[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32%i\x07FFFFFF Locks on this money safe", SafeLocks[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeOwner(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafeowner <Name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32], String:Name[32];
	new Player;

	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientConnected(i)) continue;

		//Initialize:
		GetClientName(i, Name, sizeof(Name));

		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = i; break;
	}
	
	//Invalid Name:
	if(Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SteamIdToInt(Player), SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Initialize:
			SafeOwner[X] = SteamIdToInt(Player);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have give \x0732CD32%N\x07FFFFFF ownership to money safe #%i", Player, X);

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has give you ownership to money safe #%i", Client, X);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandTakeSafeOwner(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_takesafeowner <Name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32], String:Name[32];
	new Player;

	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientConnected(i)) continue;

		//Initialize:
		GetClientName(i, Name, sizeof(Name));

		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = i; 
	}
	
	//Invalid Name:
	if(Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Has Ownership Already:
			if(SteamIdToInt(Player) == SafeOwner[X])
			{

				//Random:
				new Random = GetRandomInt(100000, 999999);

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", Random, SafeOwner[X], ServerMap(), X);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

				//Initialize:
				SafeOwner[X] = Random;

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have taken \x0732CD32%N\x07FFFFFF ownership to money safe #%i", Player, X);

				//Print:
				CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has taken ownership to money safe #%i", Client, X);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF doesn't have ownership to money safe #%i", Player, X);
			}
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeSteamId(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafesteamid <SteamId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SteamId[32];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeOwner = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", StringToInt(SteamId), SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Initialize:
			SafeOwner[X] = StringToInt(SteamId);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have set \x0732CD32%s\x07FFFFFF steamid ownership to money safe #%i", SteamId, X);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetBankOwned(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setbankowned <0 - 1>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			BankOwnedSafe[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET BankOwnedSafe = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", BankOwnedSafe[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set the bankers ownership \x0732CD32%i", BankOwnedSafe[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandViewSafeOwner(Client,Args)
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
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Player = -1;

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%i\x07FFFFFF Steamid #%i SafeId", SafeOwner[X], X);

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SafeOwner[X] == SteamIdToInt(i))
					{

						//Initialize:
						Player = i;
					}
				}
			}

		}
	}

	//Found Player Online:
	if(Player != -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has ownership over this safe", Player);
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeHarvest(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafeharvest <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeHarvest = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeHarvest[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32%i\x07FFFFFFg of Harvest on this money safe", SafeHarvest[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeMeth(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafemeth <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeHarvest[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMeth = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMeth[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32%i\x07FFFFFFg of Meth on this money safe", SafeMeth[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafeCocain(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafecocain <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafeCocain[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafeCocain = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeCocain[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32%i\x07FFFFFFg of Harvest on this money safe", SafeCocain[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public Action:CommandSetSafePills(Client,Args)
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
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - sm_setsafepills <amount>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid:
	if(Ent == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Entity");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:Arg[32]; new Amount = 0; 

	//Initulize:
	GetCmdArg(1, Arg, sizeof(Arg));

	//Convert:
	Amount = StringToInt(Arg);

	//Declare:
	decl String:query[512];

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent)
		{

			//Initialize:
			SafePills[X] = Amount;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE MoneySafe SET SafePills = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafePills[X], SafeOwner[X], ServerMap(), X);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have set \x0732CD32%i\x07FFFFFFg of Harvest on this money safe", SafePills[X]);
		}
	}

	//Return:
	return Plugin_Handled;
}

public T_DBPrintMoneySafe(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintMoneySafe: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SpawnId, Owner, String:Buffer[32];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 32);

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 6);

			//Print:
			PrintToConsole(Client, "%i: <%s> SteamNumberId (%i)", SpawnId, Buffer, Owner);
		}
	}
}

public T_SQLLoadSafeID(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Top] T_SQLLoadRPTopOnline: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "|RP| - Invalid Money safe");

			//Return:
			return;
		}

		//Declare:
		new SpawnId, Owner, Float:ClientOrigin[3], Float:Angles[3]; decl String:query[512];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			Owner = SQL_FetchInt(hndl, 6);

			//Initialize:
			GetClientAbsOrigin(Client, ClientOrigin);

			GetClientAbsAngles(Client, Angles);

			//Declare:
			decl String:Position[64], String:Ang[64];

			//Sql String:
			Format(Position, sizeof(Position), "%f^%f^%f", ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);

			//Sql String:
			Format(Ang, sizeof(Ang), "%f^%f^%f", Angles[0], Angles[1], Angles[2]);

			//Format:
			Format(query, sizeof(query), "UPDATE MoneySafe SET Position = '%s', Angles = '%s' Map = '%s' WHERE SafeOwner = %i AND SafeId = %i;", Position, Ang, ServerMap(), Owner, SpawnId);

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Money Safe \x0732CD32#%I\x07FFFFFF Updated Map <\x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF, \x0732CD32%f\x07FFFFFF>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
		}

	}
}

public CreatePropMoneySafe(Float:Pos[3], Float:Ang[3], X, Money, Locks, Owner, BankOwned, String:Name[], SafeH, SafeM, SafeP, SafeC)
{

	//Initulize::
	new Ent = CreateEntityByName("Prop_Physics_override");

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", MoneySafeModel);

		//Declare:
		decl String:Spawn[255];

		//Format:
		Format(Spawn, sizeof(Spawn), "%f %f %f", Pos[0], Pos[1], Pos[2]);

		//Dispatch:
		DispatchKeyValue(Ent, "origin", Spawn);

		//Format:
		Format(Spawn, sizeof(Spawn), "%f %f %f", Ang[0], Ang[1], Ang[2]);

		//Dispatch:
		DispatchKeyValue(Ent, "angles", Spawn);

		//Spawn:
		DispatchSpawn(Ent);

		//Initulize:
		Pos[2] += 16;

		//Teleport:
		TeleportEntity(Ent, Pos, Ang, NULL_VECTOR);

		//Set Damage:
		SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

		//Accept:
		AcceptEntityInput(Ent, "disablemotion", Ent);

		//Initulize:
		SafeEnt[X] = Ent;

		SafeMoney[X] = Money;

		SafeLocks[X] = Locks;

		SafeOwner[X] = Owner;

		BankOwnedSafe[X] = BankOwned;

		SafeHarvest[X] = SafeH;

		SafeMeth[X] = SafeM;

		SafePills[X] = SafeP;

		SafeCocain[X] = SafeC;

		//Copy String From Buffer:
		strcopy(SafeName[X], sizeof(SafeName[]), Name);
	}
}
public bool:IsValidMoneySafe(Ent)
{

	//Loop:
	for(new X = 0; X <= MAXSAFES; X++)
	{

		//Check
		if(SafeEnt[X] == Ent)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action:OnMoneySafeRob(Client, Ent)
{

	//Not Valid Ent:
	if(!LookingAtWall(Client))
	{

		//Loop:
		for(new X = 0; X <= MAXSAFES; X++)
		{

			//Check
			if(SafeEnt[X] == Ent && IsInDistance(Client, Ent))
			{

				//Check Locks:
				if(SafeLocks[X] == 0)
				{

					//Check Owner:
					if(SteamIdToInt(Client) != SafeOwner[X])
					{

						//Is Duo Sprint:
						if(GetLastPressedE(Client) > (GetGameTime() - 3.0))
						{

							//Declare:
							new Float:Origin[3];

							//Ent Origin:
							GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

							//Initialize:
							RobOrigin[Client] = Origin;

							//Rob:
							BeginSafeRob(Client, 500, X);
						}

						//Override:
						else
						{

							//Print:
							OverflowMessage(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You have to press 1 more times to rob this Money Safe!");

							//Initialize:
							SetLastPressedE(Client, GetGameTime());
						}
					}

					//Override:
					else
					{

						//Print:
						OverflowMessage(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - You can't rob your own money safe!");
					}
				}

				//Override:
				else
				{

					//Print:
					OverflowMessage(Client, "\x07FF4040|RP-Rob|\x07FFFFFF - This Safe has Added Locks!");

					//Initialize:
					SetLastPressedSH(Client, GetGameTime());
				}
			}
		}
	}
}

public Action:OnMoneySafeUse(Client, Ent)
{

	//Loop:
	for(new X = 0; X < MAXSAFES; X++)
	{

		//Is Valid:
		if(SafeEnt[X] == Ent && IsInDistance(Client, Ent))
		{

			//Check
			if(SafeOwner[X] == SteamIdToInt(Client))
			{

				//Is In Time:
				if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && GetCash(Client) > 0)
				{

					//Declare:
					new Amount = GetCash(Client);

					//Initialize:
					SafeMoney[X] += Amount;

					SetCash(Client, 0);

					//Declare:
					decl String:query[255];

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE MoneySafe SET SafeMoney = %i WHERE SafeOwner = %i AND Map = '%s' AND SafeId = %i;", SafeMoney[X], SteamIdToInt(Client), ServerMap(), X);

					//Not Created Tables:
					SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - You have deposited \x0732CD32€%i\x07FFFFFF into your moneysafe", Amount);
				}

				//Override:
				else if(GetCash(Client) > 0)
				{


					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-MoneySafe|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF to quick deposit %s!", IntToMoney(GetCash(Client)));

					//Initulize:
					SetLastPressedE(Client, GetGameTime());
				}

				//Draw Menu:
				DrawMoneySafeMenu(Client, X);
			}

			//Override
			else
			{

				//Print:
				OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - You can't use this money safe!");
			}
		}
	}
}

public Action:MoneySafeHud(Client, Ent)
{

	//Declare:
	decl String:FormatMessage[255]; new len = 0;

	//Clear Buffers:
	for(new X = 0; X <= MAXSAFES; X++)
	{

		//Check
		if(SafeEnt[X] == Ent)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "Money Safe:\nName: %s\nMoney: %s\nLocks: %i", SafeName[X], IntToMoney(SafeMoney[X]), SafeLocks[X]);

			//Is Server Bank:
			if(BankOwnedSafe[X] == 1)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nServer Owns Bank!");
			}

			//Setup Hud:
			SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

			//Show Hud Text:
			ShowHudText(Client, 1, FormatMessage);
		}
	}
}
