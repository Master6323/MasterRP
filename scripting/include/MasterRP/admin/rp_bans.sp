//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bans_included_
  #endinput
#endif
#define _rp_bans_included_

//Database Sql:
static Handle:hDataBase = INVALID_HANDLE;

//BanTimer
static GameTime;

//Global Variables:
new BanTarget[MAXPLAYERS + 1];
new BanTargetTime[MAXPLAYERS + 1];

public Action:PluginInfo_Bans(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Bans!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "1.00.00");
}

//Add Unban menu with everyones steamid and name
//Add extra commands to alter player ban, sm_increaseban <steamnumberid> <time in total>
//Add sm_changebanreason
//add command to see player steamnumberid
//add another table to ban players ip adress

//Add Gag and Ungag
//Add Mute and Unmute

//Initation:
initBans()
{

	//Print Server If Plugin Start:
	PrintToConsole(0, "|RolePlay| Bans Successfully Loaded (v%s)!", PLUGINVERSION);

	//Server Version:
	CreateConVar("sm_roleplay_version_Bans", PLUGINVERSION, "show the version of the roleplaying mod", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);

	//Start SQL Connection:
	InitSQLBans();

	GameTime = GetTime();

	RegAdminCmd("sm_ban", Command_Ban, ADMFLAG_BAN, "sm_ban <Name> <Length> <Reason>");

	RegAdminCmd("sm_addban", Command_AddBan, ADMFLAG_BAN, "sm_addban <SteaamNumberId>");

	RegAdminCmd("sm_unban", Command_UnBan, ADMFLAG_BAN, "sm_ban <SteaamNumberId>");

	RegAdminCmd("sm_banlist", Command_BanList, ADMFLAG_SLAY, "sm_ban <SteaamNumberId>");

	RegAdminCmd("sm_banmenu", Command_BanMenu, ADMFLAG_SLAY, "sm_banmenu");

	RegAdminCmd("sm_status", Command_Status, ADMFLAG_SLAY, "sm_banmenu");

	//Bans:
	CreateTimer(0.2, CreateSQLdbBansTable);
}

//On Config:
public OnBansExecuted()
{

	//Declare:
	decl String:filename[200];

	//Build:
	BuildPath(Path_SM, filename, sizeof(filename), "plugins/basebans.smx");

	//Check:
	if(FileExists(filename))
	{

		//Declare:
		decl String:newfilename[200];

		//Build:
		BuildPath(Path_SM, newfilename, sizeof(newfilename), "plugins/disabled/basebans.smx");

		//Command:
		ServerCommand("sm plugins unload basebans");

		//Check:
		if(FileExists(newfilename))
		{

			//Delete:
			DeleteFile(newfilename);
		}

		//Rename:
		RenameFile(newfilename, filename);

		//Print:
		PrintToConsole(0,"|RP-Bans| - plugins/basebans.smx was unloaded and moved to plugins/disabled/basebans.smx");
	}
}

//On Client sent SteamId To Server:
public OnClientAuthorized(Client, const String:auth[])
{

	//Initialize:
	BanTarget[Client] = -1;

	BanTargetTime[Client] = -1;

	//Do not check bots nor check player with lan steamid.
	if(auth[0] != 'B' && auth[9] != 'L' && hDataBase != INVALID_HANDLE)
	{

		//Load:
		DBLoadBans(Client);
	}

	//Return:
	return true; 
}

//Setup Sql Connection:
InitSQLBans()
{

	//find Configeration:
	if(SQL_CheckConfig("RoleplayDB_Bans"))
	{

		//Print:
	     	PrintToServer("|Bans| : Initial (CONNECTED)");

		//Sql Connect:
		SQL_TConnect(DBConnectBans, "RoleplayDB_Bans");
	}

	//Override:
	else
	{
#if defined DEBUG
		//Logging:
		LogError("|Bans| : %s", "Invalid Configeration.");
#endif
	}
}

public DBConnectBans(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Is Valid Handle:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("|DataBase| : %s", error);
#endif
		//Return:
		return false;
	}

	//Override:
	else
	{

		//Copy Handle:
		hDataBase = hndl;

		//Declare:
		decl String:SQLDriver[32];

		new bool:iSqlite = true;

		//Read SQL Driver
		SQL_ReadDriver(hndl, SQLDriver, sizeof(SQLDriver));

		//MYSQL
		if(strcmp(SQLDriver, "mysql", false)==0)
		{

			//Thread Query:
			SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, "SET NAMES \"UTF8\"");

			//Initulize:
			iSqlite = false;
		}

		//Is Sqlite:
		if(iSqlite)
		{

			//Print:
			PrintToServer("|DataBase| Connected to SQLite Database. Version %s", SQLVERSION);
		}

		//Override:
		else
		{

			//Print:
			PrintToServer("|DataBase| Connected to MySQL Database I.e External Config. Version %s.", SQLVERSION);
		}
	}

	//Return:
	return true;
}

//Load:
DBLoadBans(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(hDataBase, T_DBLoadBansCallback, query, conuserid);
}

public T_DBLoadBansCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Bans_Player] T_DBLoadCallback: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			new banlength = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			new timeofban = SQL_FetchInt(hndl, 3);

			//Initialize:
			GameTime = GetTime();

			//decl
			if(timeofban + banlength > GameTime)
			{

			}

			//Kick Player:
			else
			{

				//Declare:
				decl String:Reason[255];

				//Database Field Loading String:
				SQL_FetchString(hndl, 4, Reason, sizeof(Reason));

				//Kick Player
				KickClient(Client, "You have banned from this server\nReason: %s", Reason);
			}
		}
	}

}

//Create Database:
public Action:CreateSQLdbBansTable(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Player`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) PRIMARY KEY, `NAME` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `lENGTH` int(12) NULL, `POINTOFBAN` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `REASON` `NAME` varchar(64) NOT NULL);");

	//Thread query:
	SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, query);
}

public Action:Command_Ban(Client, Args)
{


	//No Valid Charictors:
	if(Args < 3 || Args > 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_ban <Name> <Length> <Reason>");

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
		PrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SteamId[32], String:Length[32], String:Reason[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	GetCmdArg(2, Length, sizeof(Length));

	GetCmdArg(3, Reason, sizeof(Reason));

	//Declare:
	decl String:buffer[512];

	//Initialize:
	GameTime = GetTime();

	//Format:
	Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'%s',%i,%i,'%s');", SteamIdToInt(Player), Name, StringToInt(Length), GameTime, Reason);

	//Override:
	//Not Created Tables:
	SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%N\x07FFFFFF has been banned from this server!", Player);

	//Log:
	LogAction(Client, Player, "\"%L\" banned \"%L\" (minutes \"%d\") (reason \"%s\")", Client, Player, Length, Reason);

	//Return:
	return Plugin_Handled;
}

public Action:Command_AddBan(Client, Args)
{

	//No Valid Charictors:
	if(Args != 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_addban <SteamNumberId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SteamId[32], String:Length[32], String:Reason[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	GetCmdArg(2, Length, sizeof(Length));

	GetCmdArg(3, Reason, sizeof(Reason));

	//Declare:
	decl String:buffer[512];

	//Initialize:
	GameTime = GetTime();

	//Format:
	Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'Name Not Available',%i,%i,'%s');", StringToInt(SteamId), StringToInt(Length), GameTime, Reason);

	//Override:
	//Not Created Tables:
	SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%i\x07FFFFFF SteamNumberId has been added to the server!", SteamId);

	//Log:
	LogAction(Client, Client, "\"%L\" added ban (minutes \"%d\") (reason \"%s\")", Client, Length, Reason);

	//Return:
	return Plugin_Handled;
}

public Action:Command_UnBan(Client, Args)
{

	//No Valid Charictors:
	if(Args > 1 && Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Usage: sm_unban <SteamNumberId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:SteamId[32], String:query[255];

	//Initialize:
	GetCmdArg(1, SteamId, sizeof(SteamId));

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", StringToInt(SteamId));

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		new conuserid = GetClientUserId(Client);

		//Not Created Tables:
		SQL_TQuery(hDataBase, T_UnBanCallback, query, conuserid);
	}

	//Override:
	else
	{

		//Not Created Tables:
		SQL_TQuery(hDataBase, T_UnBanCallback, query, 12345678);
	}

	//Return:
	return Plugin_Handled;
}

public T_UnBanCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Not Server:
	if(data != 12345678)
	{

		//Is Client:
		if((Client = GetClientOfUserId(data)) == 0)
		{

			//Return:
			return;
		}
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Bans] T_UnBanCallback: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			if(data != 12345678)
				CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Invalid SteamId Found In SQL Ban List!");
			else
				PrintToConsole(Client, "|RP-Bans| - Invalid SteamId Found In SQL Ban List!");

			//Return:
			return;
		}

		//Declare:
		new SteamId, String:Name[32], String:buffer[255];

		//Override:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SteamId = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Name, 32);

			//Sql String:
			Format(buffer, sizeof(buffer), "DELETE FROM Player WHERE STEAMID = %i;", SteamId);

			//Print:
			if(data != 12345678)
				CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32%s\x07FFFFFF has been unbanned from the server!", Name);
			else
				PrintToConsole(Client, "|RP-Bans| - %s has been unbanned from the server!", Name);

			//Override:
			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, buffer);

			//Log:
			LogAction(Client, Client, "\"%L\" Unbanned (Name \"%s\")", Client, Name);
		}
	}
}

public Action:Command_BanList(Client, Args)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Print:
	PrintToConsole(Client, "Thumper List:");

	//Declare:
	decl String:query[512];

	//Forat:
	Format(query, sizeof(query), "SELECT * FROM Player;");

	//Not Created Tables:
	SQL_TQuery(hDataBase, T_DBPrintBannedPlayers, query, conuserid);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Press \x0732CD32'Escape'\x07FFFFFF For a menu!");

	//Return:
	return Plugin_Handled;
}

public T_DBPrintBannedPlayers(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Bans] T_DBPrintBannedPlayers: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - There are no players on the SQL Ban list!");

			//Return:
			return;
		}

		//Declare:
		decl String:FormatMessage[2048], Length, BannedPlayer, String:Name[32], String:Reason[255];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Roleplay SQL Ban List:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			BannedPlayer = SQL_FetchInt(hndl, 0);

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Name, 32);

			//Database Field Loading Intiger:
			Length = SQL_FetchInt(hndl, 2);

			//Database Field Loading String:
			SQL_FetchString(hndl, 4, Reason, 32);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " %s Steamid (%i) Reason: %s Length: %i\n", Name, BannedPlayer, Reason, Length);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);

	}
}

public Action:Command_BanMenu(Client, Args)
{
	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP-Bans| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	DisplayBanMenu(Client);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - Press \x0732CD32'Escape'\x07FFFFFF For a menu!");

	//Return:
	return Plugin_Handled;
}

Action:DisplayBanMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandlePlayerBanMenu);

	//Menu Title:
	SetMenuTitle(Menu, "Who would you like to Ban?");

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

	//Allow Back Track:
	SetMenuExitBackButton(Menu, false);

	//Set Exit Button:
	SetMenuExitButton(Menu, true);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);

}

//PlayerMenu Handle:
public HandlePlayerBanMenu(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, 255);

		//Initialize:
		new Player = StringToInt(info);

		if(Client == Player)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - You cannot ban yourself!");
		}

		//Override:
		else
		{

			BanTarget[Client] = Player;

			//Show Menu:
			DisplayBanTimeMenu(Client);
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

Action:DisplayBanTimeMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandlePlayerBanTime);

	//Declare:
	decl String:Title[255];

	//Format:
	Format(Title, sizeof(Title), "How long would you like to ban %N for?", BanTarget[Client]);

	//Menu Title:
	SetMenuTitle(Menu, Title);

	//Menu Button:
	AddMenuItem(Menu, "0", "Permanent");

	AddMenuItem(Menu, "10", "10 Minutes");

	AddMenuItem(Menu, "30", "30 Minutes");

	AddMenuItem(Menu, "60", "1 Hour");

	AddMenuItem(Menu, "240", "4 Hours");

	AddMenuItem(Menu, "1440", "1 Day");

	AddMenuItem(Menu, "10080", "1 Week");

	AddMenuItem(Menu, "69", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, true);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);
}

//PlayerMenu Handle:
public HandlePlayerBanTime(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[255];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, 255);

		//Initialize:
		new Time = StringToInt(info);

		if(Time == 69)
		{

			//Show Menu:
			DisplayBanMenu(Client);

			//Close:
			CloseHandle(Menu);
		}

		//Override:
		else
		{

			//Initialize:
			BanTargetTime[Client] = Time;

			//Show Menu:
			DisplayBanReasonMenu(Client);
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

Action:DisplayBanReasonMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandlePlayerBanReason);

	//Declare:
	decl String:Title[255];

	//Format:
	Format(Title, sizeof(Title), "What Reason Does %N have to be banned\nTime:%i", BanTarget[Client], BanTargetTime[Client]);

	//Menu Title:
	SetMenuTitle(Menu, Title);

	//Allow Back Track:
	SetMenuExitBackButton(Menu, true);

	//Menu Button:
	AddMenuItem(Menu, "Abusive", "Abusive");

	AddMenuItem(Menu, "Racism", "Racism");

	AddMenuItem(Menu, "General cheating/exploits", "General cheating/exploits");

	AddMenuItem(Menu, "Wallhack", "Wallhack");

	AddMenuItem(Menu, "Aimbot", "Aimbot");

	AddMenuItem(Menu, "Speedhacking", "Speedhacking");

	AddMenuItem(Menu, "Mic spamming", "Mic spamming");

	AddMenuItem(Menu, "Admin disrespect", "Admin disrespect");

	AddMenuItem(Menu, "Camping", "Camping");

	AddMenuItem(Menu, "Team killing", "Team killing");

	AddMenuItem(Menu, "Unacceptable Spray", "Unacceptable Spray");

	AddMenuItem(Menu, "Breaking Server Rules", "Breaking Server Rules");

	AddMenuItem(Menu, "Other", "Other");

	AddMenuItem(Menu, "69", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, true);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);
}

//PlayerMenu Handle:
public HandlePlayerBanReason(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:buffer[512], String:Reason[255];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, Reason, 255);

		//Initialize:
		new Result = StringToInt(Reason);

		if(Result == 69)
		{

			//Show Menu:
			DisplayBanTimeMenu(Client);

			//Close:
			CloseHandle(Menu);
		}

		//Override
		else
		{
			//Initialize:
			GameTime = GetTime();

			//Format:
			Format(buffer, sizeof(buffer), "INSERT INTO Player (`STEAMID`,`NAME`,`LENGTH`,`POINTOFBAN`,`REASON`) VALUES (%i,'%N',%i,%i,'%s');", SteamIdToInt(BanTarget[Client]), BanTarget[Client], BanTargetTime[Client], GameTime, Reason);

			//Override:
			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLBansErrorCheckCallback, buffer);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bans|\x07FFFFFF - \x0732CD32#%N\x07FFFFFF has been banned from this server!", BanTarget[Client]);

			//Log:
			LogAction(Client, BanTarget[Client], "\"%L\" banned \"%L\" (minutes \"%d\") (reason \"%s\")", Client, BanTarget[Client], BanTargetTime[Client], Reason);

			//Kick Player
			KickClient(BanTarget[Client], "You have banned from this server\nReason: %s", Reason);
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

public Action:Command_Status(Client, Args)
{

	//Is Colsole:
	if(Client != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Return:
		return Plugin_Handled;
	}

	//Loop:
	for (new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

		//Print:
		PrintToConsole(Client, "|RP-Bans| - %N SteamNumberId (%i)!", i, SteamIdToInt(i));
	}

	//Return:
	return Plugin_Handled;
}

public SQLBansErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Is Error:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("RP_Core] SQLBansErrorCheckCallback: Query failed! %s", error);
#endif
	}
}