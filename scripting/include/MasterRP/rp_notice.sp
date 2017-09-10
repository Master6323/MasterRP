//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_notice_included_
  #endinput
#endif
#define _rp_notice_included_

static String:Notice[2047][255];
static String:NoticeName[2047][255];
static String:NoticeDesc[2047][255];

initNotice()
{

	//Clean map entitys:
	for(new X = 0; X < 2047; X++)
	{

		//Initialize:
		Notice[X] = "null";

		NoticeName[X] = "null";

		NoticeDesc[X] = "null";

	}

	//Commands:
	RegAdminCmd("sm_setnotice", Command_Notice, ADMFLAG_SLAY, "<text> - Sets the main notice of this enity");

	RegAdminCmd("sm_removenotice", Command_RemNotice, ADMFLAG_SLAY, " - remove the main notice of this entity");

	RegAdminCmd("sm_setnoticename", Command_NoticeName, ADMFLAG_SLAY, "<text> - Sets the notice name of this entity");

	RegAdminCmd("sm_removenoticename", Command_RemNoticeName, ADMFLAG_SLAY, " - remove the notice name of this entity");

	RegAdminCmd("sm_setnoticedesc", Command_NoticeDesc, ADMFLAG_SLAY, "<text> - Sets the notice desc of this entity");

	RegAdminCmd("sm_removenoticedesc", Command_RemNoticeDesc, ADMFLAG_SLAY, "<ent> <Name> - Sets the notice desc of this entity");

	//Timer:
	CreateTimer(0.2, CreateSQLdbNotice);

	CreateTimer(0.2, CreateSQLdbNoticeName);

	CreateTimer(0.2, CreateSQLdbNoticeDesc);
}

ResetEntNotice()
{

	//Clean map entitys:
	for(new X = 0; X < 2047; X++)
	{

		//Initialize:
		Notice[X] = "null";

		NoticeName[X] = "null";

		NoticeDesc[X] = "null";

	}
}

//Create Database:
public Action:CreateSQLdbNotice(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Notice`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Name` varchar(255) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}
//Create Database:
public Action:CreateSQLdbNoticeName(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NoticeName`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Name` varchar(255) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}
//Create Database:
public Action:CreateSQLdbNoticeDesc(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `NoticeDesc`");

	len += Format(query[len], sizeof(query)-len, " (`Map` varchar(32) NOT NULL, `DoorId` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Name` varchar(255) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadNotice(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM Notice WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNotice, query);
}

//Create Database:
public Action:LoadNoticeName(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NoticeName WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNoticeName, query);
}

//Create Database:
public Action:LoadNoticeDesc(Handle:Timer)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM NoticeDesc WHERE Map = '%s';", ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadNoticeDesc, query);
}

public T_DBLoadNotice(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNotice: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Notices Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Notice[Ent], sizeof(Notice[]));

		}

		//Print:
		PrintToServer("|RP| - Notice Loaded!");
	}
}

public T_DBLoadNoticeName(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNoticeName: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Notice Names Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, NoticeName[Ent], sizeof(NoticeName[]));
		}

		//Print:
		PrintToServer("|RP| - Notice Name Loaded!");
	}
}

public T_DBLoadNoticeDesc(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadNoticeDesc: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No Notice Desc Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new Ent;

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Ent = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, NoticeDesc[Ent], sizeof(NoticeDesc[]));

		}

		//Print:
		PrintToServer("|RP| - Notice Desc Loaded!");
	}
}

//Notice:
public Action:Command_Notice(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_notice <text>");

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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Entity.");

		//Return:
		return Plugin_Handled;	
	}

	//Initulize:
	SetNotice(Ent, Arg);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%i\x07FFFFFF on #%i!", Arg, Ent);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemNotice(Client, Args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Entity.");

		//Return:
		return Plugin_Handled;	
	}

	//Spawn Already Created:
	if(StrEqual(Notice[Ent], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Door #%i Has Name!", Ent);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	RemoveNotice(Ent);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Notice \x0732CD32#%i\x07FFFFFF has been deleted from database", Ent);

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action:Command_NoticeName(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Usage: sm_noticename <text>");

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
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Entity.");

		//Return:
		return Plugin_Handled;	
	}

	//Initulize:
	SetNoticeName(Ent, Arg);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%s\x07FFFFFF on #%i!", Arg, Ent);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemNoticeName(Client, Args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Spawn Already Created:
	if(StrEqual(NoticeName[Ent], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Door #%i Has Name!", Ent);

		//Return:
		return Plugin_Handled;	
	}

	//Initialize:
	RemoveNoticeName(Ent);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Notice Name \x0732CD32#%i\x07FFFFFF has been deleted from database", Ent);

	//Return:
	return Plugin_Handled;
}

//Notice:
public Action:Command_NoticeDesc(Client, Args)
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

	//Initulize:
	SetNoticeDesc(Ent, Arg);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - You have Set \x0732CD32#%s\x07FFFFFF on #%i!", Arg, Ent);

	//Return:
	return Plugin_Handled;
}

public Action:Command_RemNoticeDesc(Client, Args)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false);

	//Is Valid Entity:
	if(Ent <= 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Door|\x07FFFFFF - Invalid Door.");

		//Return:
		return Plugin_Handled;	
	}

	//Spawn Already Created:
	if(StrEqual(NoticeDesc[Ent], "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Door #%i Has No Price!", Ent);

		//Return:
		return Plugin_Handled;	
	}

	//Initulize:
	RemoveNoticeDesc(Ent);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-Notice|\x07FFFFFF - Notice Description \x0732CD32#%i\x07FFFFFF has been deleted from database", Ent);

	//Return:
	return Plugin_Handled;
}

String:GetNotice(Ent)
{

	//Return:
	return Notice[Ent];
}

public SetNotice(Ent, String:Str[255])
{

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(!StrEqual(Notice[Ent], "null"))
	{

		//Format:
		Format(query, sizeof(query), "UPDATE Notice SET Name = %s WHERE Map = '%s' AND DoorId = %i;", Str, ServerMap(), Ent);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO Notice (`Map`,`DoorId`,`Name`) VALUES ('%s',%i,'%s');", ServerMap(), Ent, Str);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initulize:
	Notice[Ent] = Str;
}

public RemoveNotice(Ent)
{

	//Initialize:
	Notice[Ent] = "null";

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM Notice WHERE DoorId = %i AND Map = '%s';", Ent, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

String:GetNoticeName(Ent)
{

	//Return:
	return NoticeName[Ent];
}

public SetNoticeName(Ent, String:Str[255])
{

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(!StrEqual(NoticeName[Ent], "null"))
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NoticeName SET NoticeEnt = %s WHERE Map = '%s' AND DoorId = %i;", Str, ServerMap(), Ent);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NoticeName (`Map`,`DoorId`,`Name`) VALUES ('%s',%i,'%s');", ServerMap(), Ent, Str);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initulize:
	NoticeName[Ent] = Str;
}

public RemoveNoticeName(Ent)
{

	//Initialize:
	NoticeName[Ent] = "null";

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NoticeName WHERE DoorId = %i AND Map = '%s';", Ent, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

String:GetNoticeDesc(Ent)
{

	//Return:
	return NoticeDesc[Ent];
}

public SetNoticeDesc(Ent, String:Str[255])
{

	//Declare:
	decl String:query[512];

	//Spawn Already Created:
	if(!StrEqual(NoticeDesc[Ent], "null"))
	{

		//Format:
		Format(query, sizeof(query), "UPDATE NoticeDesc SET Name = %s WHERE Map = '%s' AND DoorId = %i;", Str, ServerMap(), Ent);
	}

	//Override:
	else
	{

		//Format:
		Format(query, sizeof(query), "INSERT INTO NoticeDesc (`Map`,`DoorId`,`Name`) VALUES ('%s',%i,'%s');", ServerMap(), Ent, Str);
	}

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

	//Initulize:
	NoticeDesc[Ent] = Str;
}

public RemoveNoticeDesc(Ent)
{

	//Initialize:
	NoticeDesc[Ent] = "null";

	//Declare:
	decl String:query[512];

	//Sql String:
	Format(query, sizeof(query), "DELETE FROM NoticeDesc WHERE DoorId = %i AND Map = '%s';", Ent, ServerMap());

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}
