//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_sql_included_
  #endinput
#endif
#define _rp_sql_included_

//Definitions:
#define SQLVERSION		"1.05.00"

//Database Sql:
static Handle:hDataBase = INVALID_HANDLE;

public Action:PluginInfo_Sql(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Global SQL Multi-Plugin Handle!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", SQLVERSION);
}

//Setup Sql Connection:
initSQL()
{

	//find Configeration:
	if(SQL_CheckConfig("RoleplayDB"))
	{

		//Print:
	     	PrintToServer("|DataBase| : Initial (CONNECTED)");

		//Sql Connect:
		SQL_TConnect(DBConnect, "RoleplayDB");
	}

	//Override:
	else
	{
#if defined DEBUG
		//Logging:
		LogError("|DataBase| : Invalid Configeration.");
#endif
	}
}

public DBConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
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
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, "SET NAMES \"UTF8\"");

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

public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Is Error:
	if(hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Log Message:
		LogError("RP_Core] SQLErrorCheckCallback: Query failed! %s", error);
#endif
	}
}

//Create Database:
public Handle:GetGlobalSQL()
{

	//Return:
	return hDataBase;
}
