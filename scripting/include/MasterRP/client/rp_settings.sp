//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_settings_included_
  #endinput
#endif
#define _rp_settings_included_

//Job system:
static bool:CallEnable[MAXPLAYERS + 1] = {true,...};
static bool:RingEnable[MAXPLAYERS + 1] = {true,...};
static PingOn[MAXPLAYERS + 1] = {1,...};
static TrashTracer[MAXPLAYERS + 1] = {1,...};
static MoreHud[MAXPLAYERS + 1] = {1,...};

//Hud System
static ClientHudColor[MAXPLAYERS + 1][3];
static PlayerHudColor[MAXPLAYERS + 1][3];
static EntityHudColor[MAXPLAYERS + 1][3];
static HudEnable[MAXPLAYERS + 1] = {1,...};
static HudInfo[MAXPLAYERS + 1] = {1,...};

//Crime System:
static CrimeTracer[MAXPLAYERS + 1] = {1,...};
static BountyTracer[MAXPLAYERS + 1] = {1,...};

initSettings()
{

	//Commands:
	RegConsoleCmd("sm_settings", Command_Settings);

	//Timer:
	CreateTimer(0.2, CreateSQLdbsettings);
}

//Create Database:
public Action:CreateSQLdbsettings(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[5120];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Settings`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) PRIMARY KEY,");

	len += Format(query[len], sizeof(query)-len, " `ClientHud` varchar(16) NOT NULL DEFAULT '50 120 255',");

	len += Format(query[len], sizeof(query)-len, " `PlayerHud` varchar(16) NOT NULL DEFAULT '50 255 120',");

	len += Format(query[len], sizeof(query)-len, " `EntityHud` varchar(16) NOT NULL DEFAULT '50 255 120',");

	len += Format(query[len], sizeof(query)-len, " `CrimeTracer` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `MoreHud` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `HudEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `HudInfo` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `CallEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `RingEnable` int(12) NOT NULL DEFAULT 1,");

	len += Format(query[len], sizeof(query)-len, " `DrugPing` int(5) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `TrashTracer` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `BountyTracer` int(12) NOT NULL DEFAULT 0);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action:LoadPlayerSettings(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Settings` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSettingsCallback, query, conuserid);
}

public InsertSettings(Client)
{

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Settings (`STEAMID`,`ClientHud`,`PlayerHud`,`CrimeTracer`,`MoreHud`,`HudEnable`,`HudInfo`,`CallEnable`,`RingEnable`,`DrugPing`,`TrashTracer`,`BountyTracer`) VALUES (%i,'120 120 255', '120 120 255', 1, 1, 1, 1, 1, 1, 0, 0, 1);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player settings.");
}

public T_DBLoadSettingsCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_settings] T_DBLoadSettingsCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player settings...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Insert Player:
			InsertSettings(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:Buffer[64], String:Dump[3][64];

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				ClientHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				PlayerHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 3, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, " ", Dump, 3, 64);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				EntityHudColor[Client][X] = StringToInt(Dump[X]);
			}

			//Database Field Loading INTEGER:
			CrimeTracer[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			MoreHud[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading INTEGER:
			HudEnable[Client] = SQL_FetchInt(hndl, 6);

			//Database Field Loading INTEGER:
			HudInfo[Client] = SQL_FetchInt(hndl, 7);

			//Database Field Loading INTEGER:
			CallEnable[Client] = intTobool(SQL_FetchInt(hndl, 8));

			//Database Field Loading INTEGER:
			RingEnable[Client] = intTobool(SQL_FetchInt(hndl, 9));

			//Database Field Loading INTEGER:
			PingOn[Client] = SQL_FetchInt(hndl, 10);

			//Database Field Loading INTEGER:
			TrashTracer[Client] = SQL_FetchInt(hndl, 11);

			//Database Field Loading INTEGER:
			BountyTracer[Client] = SQL_FetchInt(hndl, 12);

			//Print:
			PrintToConsole(Client, "|RP| player settings loaded.");
		}
	}
}

public Action:Command_Settings(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Handle:
	new Handle:Menu = CreateMenu(HandleSettings);

	//Title:
	SetMenuTitle(Menu, "You can change your settings\n of a variation of properties\n\nSome settings will not be avaiable\ndue to you don't have the item\n or you do not have permissions.");

	//Menu Button:
	AddMenuItem(Menu, "0", "Hud");

	AddMenuItem(Menu, "1", "Tracers");

	AddMenuItem(Menu, "2", "Phone");

	AddMenuItem(Menu, "3", "Model");

	AddMenuItem(Menu, "4", "Hats");

	AddMenuItem(Menu, "5", "Drug Ping");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Return:
	return Plugin_Handled;
}

//Item Handle:
public HandleSettings(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
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
			Menu = CreateMenu(HandleHud);

			//Title:
			SetMenuTitle(Menu, "you can change the properties\nof the main hud and all the\nnotice colours of the hud:");

			//Declare:
			decl String:State[128];

			//Format:
			Format(State, sizeof(State), "Hud is %s", HudEnable[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "0", State);

			//Format:
			Format(State, sizeof(State), "More Hud is %s", MoreHud[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "1", State);

			//Format:
			Format(State, sizeof(State), "Hud Info is %s", HudInfo[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "2", State);

			//Menu Button:
			AddMenuItem(Menu, "3", "Change Hud color");

			AddMenuItem(Menu, "4", "Change Player Color");

			AddMenuItem(Menu, "5", "Change Entity Color");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Handle:
			Menu = CreateMenu(HandleTracer);

			//Title:
			SetMenuTitle(Menu, "Here you can change the settings of\nyour tracers and items:");

			//Declare:
			decl String:State[128];

			//Format:
			Format(State, sizeof(State), "Crime tracer is %s", CrimeTracer[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "0", State);

			//Format:
			Format(State, sizeof(State), "Bounty tracer is %s", BountyTracer[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "1", State);

			//Format:
			Format(State, sizeof(State), "Trash tracer is %s", TrashTracer[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "2", State);

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Handle:
			Menu = CreateMenu(HandlePhone);

			//Title:
			SetMenuTitle(Menu, "Here you can change the settings of\nyour game phone:");

			//Declare:
			decl String:State[128];

			//Format:
			Format(State, sizeof(State), "Phone is %s", CallEnable[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "0", State);

			//Format:
			Format(State, sizeof(State), "Phone Ring is %s", RingEnable[Client] ? "on" : "off");

			//Menu Button:
			AddMenuItem(Menu, "1", State);

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Handle:
			Menu = CreateMenu(HandleModelMenu);

			//Menu Title:
			SetMenuTitle(Menu, "Here you can change your\nplayer model:");

			//Is Donator:
			if(GetDonator(Client) == 1)
			{

				//Menu Button:
				AddMenuItem(Menu, "1", "Student Skins");
			}

			//Is Donator:
			if(GetDonator(Client) == 2)
			{

				//Menu Button:
				AddMenuItem(Menu, "2", "Special Skins");
			}

			//Is Admin:
			if(IsAdmin(Client))
			{

				//Menu Button:
				AddMenuItem(Menu, "3", "Admin Models");
			}

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		if(Result == 4)
		{

			//Valid Job:
			if(IsAdmin(Client) || GetDonator(Client) > 0)
			{

				//Show Menu:
				DrawHatMenu(Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have access this this menu!");
			}
		}

		//Button Selected:
		if(Result == 5)
		{

			//Valid Job:
			if(PingOn[Client] == 0)
			{

				//Initulize:
				PingOn[Client] = 1;
			}

			//Override:
			else
			{

				//Initulize:
				PingOn[Client] = 0;
			}

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET DrugPing = %i WHERE STEAMID = %i;", PingOn[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have toggled Drug Ping Detector!");
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
public HandleHud(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
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

			//Is Valid:
			if(HudEnable[Client] == 0)
			{

				//Set Phone Status:
				HudEnable[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				HudEnable[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Hud has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET HudEnable = %i WHERE STEAMID = %i;", HudEnable[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(MoreHud[Client] == 0)
			{

				//Set Phone Status:
				MoreHud[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				MoreHud[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - More Hud has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET MoreHud = %i WHERE STEAMID = %i;", MoreHud[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Valid:
			if(HudInfo[Client] == 0)
			{

				//Set Phone Status:
				HudInfo[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				HudInfo[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Hud has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET HudInfo = %i WHERE STEAMID = %i;", HudEnable[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Handle:
			Menu = CreateMenu(HandleColourChange);

			//Title:
			SetMenuTitle(Menu, "Change main hud colour:");

			//Menu Button:
			AddMenuItem(Menu, "0 50 120 250", "Blue");

			AddMenuItem(Menu, "0 250 220 10", "Yellow");

			AddMenuItem(Menu, "0 250 50 50", "Red");

			AddMenuItem(Menu, "0 50 250 50", "Green");

			AddMenuItem(Menu, "0 250 250 250", "White");

			AddMenuItem(Menu, "0 240 25 140", "Pink");

			AddMenuItem(Menu, "0 181 5 250", "Purple");

			AddMenuItem(Menu, "0 250 130 10", "Orange");

			AddMenuItem(Menu, "0 50 250 250", "Light blue");

			AddMenuItem(Menu, "0 135 220 40", "Light Green");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		else if(Result == 4)
		{

			//Handle:
			Menu = CreateMenu(HandleColourChange);

			//Title:
			SetMenuTitle(Menu, "Change Player hud colour:");

			//Menu Button:
			AddMenuItem(Menu, "1 50 50 250", "Blue");

			AddMenuItem(Menu, "1 250 220 10", "Yellow");

			AddMenuItem(Menu, "1 250 50 50", "Red");

			AddMenuItem(Menu, "1 50 250 50", "Green");

			AddMenuItem(Menu, "1 250 250 250", "White");

			AddMenuItem(Menu, "1 240 25 140", "Pink");

			AddMenuItem(Menu, "1 181 5 250", "Purple");

			AddMenuItem(Menu, "1 250 130 10", "Orange");

			AddMenuItem(Menu, "1 50 250 250", "Light blue");

			AddMenuItem(Menu, "1 135 220 250", "Light Green");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
		}

		//Button Selected:
		else if(Result == 5)
		{

			//Handle:
			Menu = CreateMenu(HandleColourChange);

			//Title:
			SetMenuTitle(Menu, "Change Entity hud colour:");

			//Menu Button:
			AddMenuItem(Menu, "2 50 50 250", "Blue");

			AddMenuItem(Menu, "2 250 220 10", "Yellow");

			AddMenuItem(Menu, "2 250 50 50", "Red");

			AddMenuItem(Menu, "2 50 250 50", "Green");

			AddMenuItem(Menu, "2 250 250 250", "White");

			AddMenuItem(Menu, "2 240 25 140", "Pink");

			AddMenuItem(Menu, "2 181 5 250", "Purple");

			AddMenuItem(Menu, "2 250 130 10", "Orange");

			AddMenuItem(Menu, "2 50 250 250", "Light blue");

			AddMenuItem(Menu, "2 135 220 250", "Light Green");

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

//Item Handle:
public HandleColourChange(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:query[512], String:info[64], String:buffer[4][64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Explode:
		ExplodeString(info, " ", buffer, 4, sizeof(buffer));

		//Declare:
		new HudType = RoundFloat(StringToFloat(buffer[0]));

		if(HudType == 0)
		{

			//Change Hud Color:
			ClientHudColor[Client][0] = StringToInt(buffer[1]);

			ClientHudColor[Client][1] = StringToInt(buffer[2]);

			ClientHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET ClientHud = '%i %i %i' WHERE STEAMID = %i", ClientHudColor[Client][0], ClientHudColor[Client][1], ClientHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		if(HudType == 1)
		{

			//Change Hud Color:
			PlayerHudColor[Client][0] = StringToInt(buffer[1]);

			PlayerHudColor[Client][1] = StringToInt(buffer[2]);

			PlayerHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query,sizeof(query), "UPDATE Settings SET PlayerHud = '%i %i %i' WHERE STEAMID = %i", PlayerHudColor[Client][0], PlayerHudColor[Client][1], PlayerHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		if(HudType == 2)
		{

			//Change Hud Color:
			EntityHudColor[Client][0] = StringToInt(buffer[1]);

			EntityHudColor[Client][1] = StringToInt(buffer[2]);

			EntityHudColor[Client][2] = StringToInt(buffer[3]);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have changed your hud color to (\x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF, \x0732CD32%s\x07FFFFFF)", buffer[1], buffer[2], buffer[3]);

			//Sql Strings:
			Format(query,sizeof(query), "UPDATE Settings SET EntityHud = '%i %i %i' WHERE STEAMID = %i", EntityHudColor[Client][0], EntityHudColor[Client][1], EntityHudColor[Client][2], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
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
public HandleTracer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
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

			//Is Valid:
			if(CrimeTracer[Client] == 0)
			{

				//Set Phone Status:
				CrimeTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				CrimeTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Crime tracer has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET CrimeTracer = %i WHERE STEAMID = %i;", CrimeTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(BountyTracer[Client] == 0)
			{

				//Set Phone Status:
				BountyTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				BountyTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Bounty tracer has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET BountyTracer = %i WHERE STEAMID = %i;", BountyTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Valid:
			if(TrashTracer[Client] == 0)
			{

				//Set Phone Status:
				TrashTracer[Client] = 1;
			}

			//Override:
			else
			{
				//Set Phone Status:
				TrashTracer[Client] = 0;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - trash tracer has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET TrashTracer = %i WHERE STEAMID = %i;", TrashTracer[Client], SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
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
public HandlePhone(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
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

			//Is Valid:
			if(!CallEnable[Client])
			{

				//Set Phone Status:
				CallEnable[Client] = true;
			}

			//Override:
			else
			{
				//Set Phone Status:
				CallEnable[Client] = false;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Phone has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET CallEnable = %i WHERE STEAMID = %i;", boolToint(CallEnable[Client]), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Is Valid:
			if(!RingEnable[Client])
			{

				//Set Phone Status:
				RingEnable[Client] = true;
			}

			//Override:
			else
			{
				//Set Phone Status:
				RingEnable[Client] = false;
			}

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Phone Ring has been toggled.");

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE Settings SET RingEnable = %i WHERE STEAMID = %i;", boolToint(RingEnable[Client]), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
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

//Menu Handle:
public HandleModelMenu(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
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

			//Is Donator:
			if(GetDonator(Client) == 1)
			{

				//Handle:
				Menu = CreateMenu(HandleModel);

				//Menu Title:
				SetMenuTitle(Menu, "Pick A Model to Change to:");

				 //Menu Button:
				AddMenuItem(Menu, "models/alyx.mdl", "Alyx");

				AddMenuItem(Menu, "models/barney.mdl", "Barney");

				AddMenuItem(Menu, "models/eli.mdl", "Eli");

				AddMenuItem(Menu, "models/kleiner.mdl", "Kleiner");

				AddMenuItem(Menu, "models/monk.mdl", "Monk");

				AddMenuItem(Menu, "models/mossman.mdl", "Mossman");

				//Set Exit Button:
				SetMenuExitButton(Menu, false);

				//Show Menu:
				DisplayMenu(Menu, Client, 30);

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
			}
		}

		//Button Selected:
		if(Result == 2)
		{

			//Is Donator:
			if(GetDonator(Client) == 2)
			{

				//Handle:
				Menu = CreateMenu(HandleModel);

				//Menu Title:
				SetMenuTitle(Menu, "Pick A Model to Change to:");

				 //Menu Button:
				AddMenuItem(Menu, "models/alyx.mdl", "Alyx");

				AddMenuItem(Menu, "models/barney.mdl", "Barney");

				AddMenuItem(Menu, "models/eli.mdl", "Eli");

				AddMenuItem(Menu, "models/kleiner.mdl", "Kleiner");

				AddMenuItem(Menu, "models/monk.mdl", "Monk");

				AddMenuItem(Menu, "models/mossman.mdl", "Mossman");

				AddMenuItem(Menu, "models/combine_soldier_prisonguard.mdl", "Prison Guard");

				AddMenuItem(Menu, "models/combine_soldier.mdl", "Soldier");

				AddMenuItem(Menu, "models/combine_super_soldier.mdl", "Super Soldier");

				//Set Exit Button:
				SetMenuExitButton(Menu, false);

				//Show Menu:
				DisplayMenu(Menu, Client, 30);

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
			}
		}

		//Button Selected:
		if(Result == 3)
		{

			//Is Valid:
			if(IsAdmin(Client))
			{

				//Handle:
				Menu = CreateMenu(HandleModel);

				//Menu Title:
				SetMenuTitle(Menu, "Pick A Model to Change to:");

				 //Menu Button:
				AddMenuItem(Menu, "models/alyx.mdl", "Alyx");

				AddMenuItem(Menu, "models/barney.mdl", "Barney");

				AddMenuItem(Menu, "models/eli.mdl", "Eli");

				AddMenuItem(Menu, "models/gman.mdl", "Gman");

				AddMenuItem(Menu, "models/kleiner.mdl", "Kleiner");

				AddMenuItem(Menu, "models/monk.mdl", "Monk");

				AddMenuItem(Menu, "models/mossman.mdl", "Mossman");

				AddMenuItem(Menu, "models/headcrabblack.mdl", "Facehugger");

				AddMenuItem(Menu, "models/police.mdl", "Police");

				AddMenuItem(Menu, "models/combine_soldier_prisonguard.mdl", "Prison Guard");

				AddMenuItem(Menu, "models/combine_soldier.mdl", "Soldier");

				AddMenuItem(Menu, "models/combine_super_soldier.mdl", "Super Soldier");

				//Set Exit Button:
				SetMenuExitButton(Menu, false);

				//Show Menu:
				DisplayMenu(Menu, Client, 30);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have access to this Menu");
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

//Model Menu Handle:
public HandleModel(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
		{

			//Declare:
			decl String:info[255], String:display[255], String:Model[128];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info), _, display, sizeof(display));

			//Get Model:
			GetClientModel(Client, Model, sizeof(Model));

			//Is Valid:
			if(!StrEqual(Model, info, false) && !IsCop(Client))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your Model has Changed tp %s.", display);

				//Declare:
				SetModel(Client, info);
			}

			//Is Police:
			else if(IsCop(Client))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are a cop you cannot change your skin");
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already have this skin on");
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
public Action:PluginInfo_Settings(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Player Settings!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

public Action:SetTalkZone(Client)
{

	//Initialize:
	CallEnable[Client] = true;

	RingEnable[Client] = true;

	MoreHud[Client] = 1;
}

public bool:GetCallEnable(Client)
{

	//Return:
	return CallEnable[Client];
}

public SetCallEnable(Client, bool:Result)
{

	//Initulize:
	CallEnable[Client] = Result;
}

public bool:GetRingEnable(Client)
{

	//Return:
	return RingEnable[Client];
}

public SetRingEnable(Client, bool:Result)
{

	//Initulize:
	RingEnable[Client] = Result;
}

public GetMoreHud(Client)
{

	//Return:
	return MoreHud[Client];
}

public GetHudInfo(Client)
{

	//Return:
	return HudInfo[Client];
}

public GetPing(Client)
{

	//Return:
	return PingOn[Client];
}

public GetTrashTracer(Client)
{

	//Return:
	return TrashTracer[Client];
}

public GetCrimeTracer(Client)
{

	//Return:
	return CrimeTracer[Client];
}

public GetBountyTracer(Client)
{

	//Return:
	return BountyTracer[Client];
}

public SetMoreHud(Client, Amount)
{

	//Initulize:
	MoreHud[Client] = Amount;
}

public GetClientHudColor(Client, Id)
{

	//Return:
	return ClientHudColor[Client][Id];
}

public GetPlayerHudColor(Client, Id)
{

	//Return:
	return PlayerHudColor[Client][Id];
}

public GetEntityHudColor(Client, Id)
{

	//Return:
	return EntityHudColor[Client][Id];
}


initHudColor(Client)
{

	//Loop:
	for(new X = 0; X < 3; X++)
	{

		//Initulize:
		ClientHudColor[Client][X] = 255;

		PlayerHudColor[Client][X] = 255;

		EntityHudColor[Client][X] = 255;
	}
}
