//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_player_included_
  #endinput
#endif
#define _rp_player_included_

//Set Client Loaded State:
static bool:Loaded[MAXPLAYERS + 1] = {false,...};

public Action:PluginInfo_Player(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Player Stats!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPlayer()
{

	//Commands:
	RegConsoleCmd("sm_rprank", Command_Rank);

	//Timer:
	CreateTimer(0.2, CreateSQLdbplayer);
}

//Create Database:
public Action:CreateSQLdbplayer(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[5120];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Player`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY, `NAME` varchar(32) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `LASTONTIME` float(10) NULL, `Cash` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Bank` int(12) NULL, `Job` varchar(32) NOT NULL DEFAULT 'Citizen',");

	len += Format(query[len], sizeof(query)-len, " `JobSalary` int(5) NOT NULL DEFAULT 4, `Crime` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Jail` int(12) NULL, `MaxJail` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Rase` int(12) NULL, `Donator` int(5) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Load:
public Action:DBLoad(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Player WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadCallback, query, conuserid);
}

public T_DBLoadCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Player] T_DBLoadCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Check:
		if(IsClientInGame(Client))
		{

			//CPrint:
			PrintToConsole(Client, "|RP| Loading player stats...");
		}

		//CPrint:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - Loading... please wait until we received your data...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Insert Player Stats:
			InsertPlayer(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:JobBuffer[255];

			//Database Field Loading INTEGER:
			SetCash(Client, SQL_FetchInt(hndl, 3));

			//Database Field Loading INTEGER:
			SetBank(Client, SQL_FetchInt(hndl, 4));

			//Database Field Loading String:
			SQL_FetchString(hndl, 5, JobBuffer, sizeof(JobBuffer));

			//Copy String From Buffer:
			SetJob(Client, JobBuffer);

			//Copy String From Buffer:
			SetOrgJob(Client, JobBuffer);

			//Database Field Loading INTEGER:
			SetJobSalary(Client, SQL_FetchInt(hndl, 6));

			//Database Field Loading INTEGER:
			SetCrime(Client, SQL_FetchInt(hndl, 7));

			//Database Field Loading INTEGER:
			SetJailTime(Client, SQL_FetchInt(hndl, 8));

			//Database Field Loading INTEGER:
			SetMaxJailTime(Client, SQL_FetchInt(hndl, 9));

			//Database Field Loading INTEGER:
			SetNextJobRase(Client, SQL_FetchInt(hndl, 10));

			//Database Field Loading INTEGER:
			SetDonator(Client, SQL_FetchInt(hndl, 11));

			//CPrint:
			PrintToConsole(Client, "|RP| Player stats loaded.");

			//Load Job System Stats:
			DBLoadJobs(Client);
		}

		//Timer:
		CreateTimer(1.0, SetClientLoadedState, Client);
	}

}

//Create Database:
public Action:SetClientLoadedState(Handle:Timer, any:Client)
{

	//Return:
	if(IsClientConnected(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - Loaded successful, have fun \x0732CD32\"%N\x0732CD32\"\x07FFFFFF!", Client);

		//Initulize:
		Loaded[Client] = true;

		if(!IsCop(Client) && (IsAdmin(Client) || GetDonator(Client) > 0)) 
		{

			//Initulize VIP
			ChangeClientTeamEx(Client, 3);
			ChangeClientTeam(Client, 3);
			ChangeClientTeamEx(Client, 1);
		}

		//Is Client Cop:
		else if(IsCop(Client))
		{

			//Initulize:
			ChangeClientTeamEx(Client, 2);
			ChangeClientTeam(Client, 2);
		}

		//Override:
		else
		{
			//Initulize:
			ChangeClientTeamEx(Client, 3);
			ChangeClientTeam(Client, 3);
		}

		//Is Cuffed:
		if(IsCuffed(Client))
		{

			//Cuff:
			Cuff(Client);

			//Jail:
			JailClient(Client, Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been sent to jail!");
		}

		//Override
		else
		{

			//Load Last Stats:
			DBLoadLastStats(Client);

			//Setup Client:
			SetupRoleplayJob(Client);
		}
	}
}

public Action:InsertPlayer(Client)
{

	//Declare:
	decl String:ClientName[255], String:buffer[255], String:CNameBuffer[255];

	//Initialize:
	GetClientName(Client, ClientName, sizeof(ClientName));

	//Remove Harmfull Strings:
	SQL_EscapeString(GetGlobalSQL(), ClientName, CNameBuffer, sizeof(CNameBuffer));

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Player (`NAME`,`STEAMID`,`LASTONTIME`) VALUES ('%s',%i,%i);", ClientName, SteamIdToInt(Client), GetTime());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - New Player: \x0732CD32%N\x07FFFFFF.", Client);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player stats.");
}

//Save:
public Action:DBSave(Client)
{

	//Connected:
	if(IsClientConnected(Client))
	{

		//Declare:
		decl String:ClientName[32], String:query[3072], String:CNameBuffer[32];

		//Initialize:
		GetClientName(Client, ClientName, sizeof(ClientName));

		//Remove Harmfull Strings:
		SQL_EscapeString(GetGlobalSQL(), ClientName, CNameBuffer, sizeof(CNameBuffer));

		//Declare:
		new len = 0;

		//Sql Strings:
		len += Format(query[len], sizeof(query)-len, "UPDATE Player SET NAME = '%s',", CNameBuffer);

		len += Format(query[len], sizeof(query)-len, "LASTONTIME = %f,", GetTime());

		len += Format(query[len], sizeof(query)-len, "Crime = %i,", GetCrime(Client));

		len += Format(query[len], sizeof(query)-len, "Jail = %i,", GetJailTime(Client));

		len += Format(query[len], sizeof(query)-len, "MaxJail = %i,", GetMaxJailTime(Client));

		len += Format(query[len], sizeof(query)-len, "Rase = %i WHERE STEAMID = %i;", GetNextJobRase(Client), SteamIdToInt(Client));

		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public Action:Command_Rank(Client, args)
{

	//Is Valid:
	if(args != 1)
	{

		//Show:
		PlayerRank(Client);

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
	if (Player == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No matching client found!");

		//Return:
		return Plugin_Handled;
	}

	//Show:
	PlayerRank(Player);

	//Return:
	return Plugin_Handled;
}

PlayerRank(Client)
{

	//Declare:
	new iwages, idays, ihours, imins;

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%N\x07FFFFFF is a \x0732CD32%s\x07FFFFFF.", Client, GetJob(Client), iwages);

	//Has Days:
	if(GetNextJobRase(Client) > 60*24)
	{

		//Initialize:
		idays = GetNextJobRase(Client)/(60*24);
	}

	//Initialize:
	ihours = (GetNextJobRase(Client) / 60);

	imins = (GetNextJobRase(Client) % 60);

	//Has Days:
	if(idays != 0)
	{

		//Initialize:
		new iHoursEx = ihours - (idays * 24);

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - They have been here since \x0732CD32%i\x07FFFFFF days, \x0732CD32%i\x07FFFFFF hours and \x0732CD32%i\x07FFFFFF minutes.", idays, iHoursEx, imins);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - They have been here since \x0732CD32%i\x07FFFFFF hours and \x0732CD32%i\x07FFFFFF minutes Online.", ihours, imins);
	}

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Has also %s", IntToMoney(GetCash(Client) + GetBank(Client)));

	//Return:
	return true;
}

public bool:IsLoaded(Client)
{

	//Return:
	return Loaded[Client];
}

public SetIsLoaded(Client, bool:Result)
{

	//Initulize:
	Loaded[Client] = Result;
}
