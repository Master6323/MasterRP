//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_savedruggs_included_
  #endinput
#endif
#define _rp_savedruggs_included_

static Harvest[MAXPLAYERS + 1] = {0,...};
static Meth[MAXPLAYERS + 1] = {0,...};
static Pills[MAXPLAYERS + 1] = {0,...};
static Cocain[MAXPLAYERS + 1] = {0,...};
static Rice[MAXPLAYERS + 1] = {0,...};
static Resources[MAXPLAYERS + 1] = {0,...};
static Float:BTC[MAXPLAYERS + 1] = {0.0,...};

initSaveDrugs()
{

	//Timer:
	CreateTimer(0.2, CreateSQLdbDynamicDrugs);
}

public Action:initDefaultPlayerDrugs(Client)
{

	//Initulize:
	Harvest[Client] = 0;

	Meth[Client] = 0;

	Pills[Client] = 0;

	Cocain[Client] = 0;

	Rice[Client] = 0;

	Resources[Client] = 0;

	BTC[Client] = 0.0;
}

//Create Database:
public Action:CreateSQLdbDynamicDrugs(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[2560];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Drugs`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY, `Harvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Meth` int(12) NOT NULL DEFAULT 0, `Pills` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Cocain` int(12) NOT NULL DEFAULT 0, `Rice` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Resources` int(12) NOT NULL DEFAULT 0, `BitCoin` float(12) NOT NULL DEFAULT 0.0);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action:DBLoadDrugs(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Drugs` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadDrugsCallBack, query, conuserid);
}

public T_LoadDrugsCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Jobs] T_LoadDrugsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player Job system...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			InsertDrugs(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			Harvest[Client] = SQL_FetchInt(hndl, 1);

			//Database Field Loading INTEGER:
			Meth[Client] = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			Pills[Client] = SQL_FetchInt(hndl, 3);

			//Database Field Loading INTEGER:
			Cocain[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			Rice[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading INTEGER:
			Resources[Client] = SQL_FetchInt(hndl, 6);

			//Database Field Loading INTEGER:
			BTC[Client] = SQL_FetchFloat(hndl, 7);

			//Print:
			PrintToConsole(Client, "|RP| player Job system loaded.");
		}
	}
}

public Action:InsertDrugs(Client)
{

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Drugs (`STEAMID`) VALUES (%i);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Drugs.");
}

public GetHarvest(Client)
{

	//Return:
	return Harvest[Client];
}

public SetHarvest(Client, Amount)
{

	//Initulize:
	Harvest[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Harvest = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetMeth(Client)
{

	//Return:
	return Meth[Client];
}

public SetMeth(Client, Amount)
{

	//Initulize:
	Meth[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Meth = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetPills(Client)
{

	//Return:
	return Pills[Client];
}

public SetPills(Client, Amount)
{

	//Initulize:
	Pills[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Pills = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetCocain(Client)
{

	//Return:
	return Cocain[Client];
}

public SetCocain(Client, Amount)
{

	//Initulize:
	Cocain[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Cocain = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetRice(Client)
{

	//Return:
	return Rice[Client];
}

public SetRice(Client, Amount)
{

	//Initulize:
	Rice[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Rice = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetResources(Client)
{

	//Return:
	return Resources[Client];
}

public SetResources(Client, Amount)
{

	//Initulize:
	Resources[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET Resources = %i WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}
public Float:GetBitCoin(Client)
{

	//Return:
	return BTC[Client];
}

public SetBitCoin(Client, Float:Amount)
{

	//Initulize:
	BTC[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Drugs SET BitCoin = %f WHERE STEAMID = %i;", Amount, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}