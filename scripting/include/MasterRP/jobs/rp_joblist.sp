//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_joblist_included_
  #endinput
#endif
#define _rp_joblist_included_

//Defines
#define	MAXJOBS			30

static String:JobList[2][MAXJOBS][255];

public Action:PluginInfo_JobList(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL JobList and Job Employer!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initJobList()
{
	//Commands:
	RegAdminCmd("sm_createjob", CommandCreateJob, ADMFLAG_ROOT, "<Id> <Job> <0|1> - Creates a job (public|admin)");

	RegAdminCmd("sm_removejob", CommandRemoveJob, ADMFLAG_ROOT, "<Id> <0|1> - Removes a job from the database (public|admin)");

	RegAdminCmd("sm_joblist", CommandListJobs, ADMFLAG_SLAY, "Lists jobs from the database");

	RegAdminCmd("sm_employ", CommandEmploy, ADMFLAG_ROOT, "<Name> <Id> - Employs admin-only jobs");

	RegConsoleCmd("sm_jobs", Command_JobMenu);

	RegConsoleCmd("sm_jobmenu", Command_JobMenu);

	//Timer:
	CreateTimer(0.2, CreateSQLdbJobList);

	CreateTimer(0.4, LoadJobList);
}

//Create Database:
public Action:CreateSQLdbJobList(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[5120];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `JobList`");

	len += Format(query[len], sizeof(query)-len, " (`Id` int(11) NULL, `Type` int(11) NULL, `JobName` varchar(32) NULL);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

//Create Database:
public Action:LoadJobList(Handle:Timer)
{

	//Clear Buffers:
	for(new X = 0; X < 2; X++) for(new Y = 0; Y < MAXJOBS; Y++)
	{

		//Initialize:
		JobList[X][Y] = "Null";
	}

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM JobList;");

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadJobList, query);
}

public T_DBLoadJobList(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Spawns] T_DBLoadJobList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToServer("|RP| - No JobList Found in DB!");

			//Return:
			return;
		}

		//Declare:
		new SpawnId, Type, String:Buffer[64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Copy String From Buffer:
			strcopy(JobList[Type][SpawnId], 255, Buffer);
		}

		//Print:
		PrintToServer("|RP| - JobList Loaded!");
	}
}

//Create Job:
public Action:CommandCreateJob(Client, Args)
{

	//Is Valid:
	if(Args < 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_createjob <Id> <Job> <(0/1) (1 = Private)>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:JobId[255],String:JobName[255],String:sFlag[32],Flag, iJobId;

	//Initialize:
	GetCmdArg(1, JobId, 255);

	GetCmdArg(2, JobName, 255);

	GetCmdArg(3, sFlag, sizeof(sFlag));

	//Declare:
	decl String:Buffer[512];

	//Convert:
	StringToIntEx(sFlag, Flag);

	StringToIntEx(JobId, iJobId);

	//Is Valid:
	if(iJobId < 1 && iJobId > MAXJOBS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Id must be above 0 or below %i", MAXJOBS);

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Flag < 0 || Flag > 1)
	{

		//Return:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Flag must be 0 or 1");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	if(!StrEqual(JobList[Flag][iJobId], "Null"))
	{

		//Format:
		Format(Buffer, sizeof(Buffer), "UPDATE JobList SET JobName = '%s' WHERE Id = %i AND Type = %i;", JobName, iJobId, Flag);
	}

	//Override:
	else
	{

		//Format:
		Format(Buffer, sizeof(Buffer), "INSERT INTO JobList (`JobName`,`Id`,`Type`) VALUES ('%s',%i,%i);", JobName, iJobId, Flag);
	}

	//Copy String From Buffer:
	strcopy(JobList[Flag][iJobId], 255, JobName);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, Buffer);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Added job \x0732CD32%s\x07FFFFFF - '\x0732CD32%s\x07FFFFFF (\x0732CD32%s\x07FFFFFF)' into the database", JobId, JobName, sFlag);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" added job %s", Client, JobName);
#endif
	//Return:
	return Plugin_Handled;
}

//Remove Job:
public Action:CommandRemoveJob(Client, Args)
{

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_removejob <Id> <(0/1) (1 = Private)>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:JobId[255], String:sFlag[32], Flag, iJobId;

	//Initialize:
	GetCmdArg(1, JobId, 255);

	GetCmdArg(2, sFlag, sizeof(sFlag));

	//Convert:
	StringToIntEx(sFlag, Flag);

	StringToIntEx(JobId, iJobId);

	//Is Valid:
	if(iJobId < 1 && iJobId > MAXJOBS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Id must be above 0 or below %i", MAXJOBS);

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(Flag < 0 || Flag  > 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Flag must be 0 or 1");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	if(StrEqual(JobList[Flag][iJobId], "Null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Failed to remove job \x0732CD32%s\x07FFFFFF (\x0732CD32%s\x07FFFFFF) from the database", JobId, sFlag);
	}

	//Override:
	else
	{

		//Declare:
		decl String:buffer[255];

		//Sql String:
		Format(buffer, sizeof(buffer), "DELETE FROM JobList WHERE Id = %i AND Type = %i;", iJobId, Flag);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Removed job %s (%s) from the database", JobId, sFlag);
	}

#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" removed job %s", Client, JobId);
#endif
	//Return:
	return Plugin_Handled;
}

//List Jobs:
public Action:CommandListJobs(Client, Args)
{	

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Declare:
	decl String:query[512];

	//Print:
	PrintToConsole(Client, "Job List:");

	//Loop:
	for(new X = 0; X < MAXJOBS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM JobList WHERE Id = %i AND Type = 0;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintJobList, query, conuserid);
	}

	//Timer:
	CreateTimer(0.3, TimerPrivateJobList, Client);

	//Return:
	return Plugin_Handled;
}

public Action:TimerPrivateJobList(Handle:Timer, any:Client)
{

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Declare:
	decl String:query[512];

	//Print:
	PrintToConsole(Client, "\nPrivate Job List:");

	//Loop:
	for(new X = 0; X < MAXJOBS; X++)
	{

		//Format:
		Format(query, sizeof(query), "SELECT * FROM JobList WHERE Id = %i AND Type = 1;", X);

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), T_DBPrintJobList, query, conuserid);
	}
}

//Employ:
public Action:CommandEmploy(Client, Args)
{

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_employ <name> <id> <type>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32],String:ClientName[32],String:Name[32];

	new Player = -1;

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientConnected(i)) continue;

		//Initialize:
		GetClientName(i, Name, sizeof(Name));

		//Is Valid:
		if(StrContains(Name, PlayerName, false) != -1)
		{

			//Initialize:
			Player = i;
		}
	}

	//Is Valid:
	if(Player == -1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:JobId[255],iJobId,String:JobTypeEx[32], iJobType;

	//Initialize:
	GetCmdArg(2, JobId, sizeof(JobId));

	//Convert:
	StringToIntEx(JobId, iJobId);

	//Initialize:
	GetCmdArg(3, JobTypeEx, sizeof(JobTypeEx));

	//Convert:
	StringToIntEx(JobTypeEx, iJobType);

	//Initialize:
	GetClientName(Client, ClientName, sizeof(ClientName));

	GetClientName(Player, Name, sizeof(Name));

	//Is Valid:
	if(iJobId < 1 && iJobId > MAXJOBS)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Id must be above 0 or below %i", MAXJOBS);

		//Return:
		return Plugin_Handled;
	}

	//Is Valid:
	if(iJobType < 0 || iJobType  > 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Flag must be 0 or 1");

		//Return:
		return Plugin_Handled;
	}

	//Override:
	if(StrEqual(JobList[iJobType][iJobId], "Null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Job");

		//Return:
		return Plugin_Handled;
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%s\x07FFFFFF's job to \x0732CD32%s", Name, JobList[iJobType][iJobId]);

	CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF set your job to \x0732CD32%s", ClientName, JobList[iJobType][iJobId]);

	//Copy String From Buffer:
	SetJob(Player, JobList[iJobType][iJobId]);

	//Copy String From Buffer:
	SetOrgJob(Player, JobList[iJobType][iJobId]);

	//Setup Client:
	SetupRoleplayJob(Client);

	//Declare:
	decl String:query[255];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE Player SET Job = '%s' WHERE STEAMID = %i;", JobList[iJobType][iJobId], SteamIdToInt(Player));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the job of \"%L\" to %s", Client, Player, GetJob(Player));
#endif
	//Return:
	return Plugin_Handled;
}

public T_DBPrintJobList(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBPrintJobList: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		new SpawnId, Type, String:Buffer[32];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 0);

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 1);

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 32);

			//Print:
			PrintToConsole(Client, "%i: %i %s", SpawnId, Type, Buffer);
		}
	}
}

//allows player to view Job Menu
public Action:Command_JobMenu(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	JobMenu(Client, 0);

	//Return:
	return Plugin_Handled;
}

//Vendor Menus:
public Action:JobMenu(Client, Type)
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM JobList WHERE Type = %i;", Type);

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadJobMenu, query, conuserid);

	//Return:
	return Plugin_Handled;
}

public T_DBLoadJobMenu(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Spawns] T_DBLoadDynamicJobList: Query failed! %s", error);
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
		new Handle:Menu = CreateMenu(HandleJobDynamic);

		//Declare:
		decl String:Buffer[64]; 

		//Override
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 2, Buffer, 64);

			//Menu Button:
			AddMenuItem(Menu, Buffer, Buffer);
		}

		//Title:
		SetMenuTitle(Menu, "Select a job:");

		//Max Menu Buttons:
		SetMenuPagination(Menu, 7);

		//Set Exit Button:
		SetMenuExitButton(Menu, false);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}
}

//Job Menu Handle:
public HandleJobDynamic(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Not Allowed To Change Job:
		if(IsCop(Client) || StrContains(GetJob(Client), "ASSHOLE", false) != -1 || IsAdmin(Client))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not allowed to change your job!");

			//Return:
			return false;
		}

		//Override:
		else
		{

			//Declare:
			decl String:info[255];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Teacher:
			if(!StrEqual(GetJob(Client), "Off Duty Cop", false) && !IsCopOrgJob(Client))
			{

				//Initialize:
				SetOrgJob(Client, info);

				//Initialize:
				SetJob(Client, info);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're job is now \x0732CD32%s\x07FFFFFF.", info);
			}

			//Override
			else
			{

				//Initialize:
				SetJob(Client, info);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You're temp job is now \x0732CD32%s\x07FFFFFF.", info);
			}

			//Mail Man
			if(StrContains(info, "Mail Man", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - to collect the mail you must find the mail man npc.");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - once you've found the npc, collect the mail and go to where the pointer is.");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - when you have found the npc, press >>SHIFT<< twice to deliver the mail.");
			}

			//Food Seller
			if(StrContains(info, "Master Chef", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - to sell food, players must buy food from you");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - you gain money from selling food!");
			}

			//Meth Technician
			if(StrContains(info, "Meth Technician", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - Buy the item called 'Meth Lab' and use it");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - wait for the timer to end and harvest them!");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - once you've harvested the Meth find the drug npc!");
				CPrintToChat(Client, "\x07FF40404:\x07FFFFFF - cash in all your harvest to gain money.");
				CPrintToChat(Client, "\x07FF40405:\x07FFFFFF - just remember, cops and people can destroy/steal your drugs.");
			}
			//Pill Technician
			if(StrContains(info, "Pill Technician", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - Buy the item called 'Pill Lab' and use it");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - wait for the timer to end and harvest them!");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - once you've harvested the Pill find the drug npc!");
				CPrintToChat(Client, "\x07FF40404:\x07FFFFFF - cash in all your harvest to gain money.");
				CPrintToChat(Client, "\x07FF40405:\x07FFFFFF - just remember, cops and people can destroy/steal your drugs.");
			}

			//Cocain Dealer
			if(StrContains(info, "Cocain Dealer", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - Buy the item called 'Cocain Lab' and use it");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - wait for the timer to end and harvest them!");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - once you've harvested the Pill find the drug npc!");
				CPrintToChat(Client, "\x07FF40404:\x07FFFFFF - cash in all your harvest to gain money.");
				CPrintToChat(Client, "\x07FF40405:\x07FFFFFF - just remember, cops and people can destroy/steal your drugs.");
			}

			//Drug Lord
			if(StrContains(info, "Drug Lord", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - Buy the item called 'Seeds' and plant your drugs");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - wait for the drugs to grow and harvest them!");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - once you've harvested the drugs find the drug npc!");
				CPrintToChat(Client, "\x07FF40404:\x07FFFFFF - cash in all your harvest to gain money.");
				CPrintToChat(Client, "\x07FF40405:\x07FFFFFF - just remember, cops and people can destroy/steal your drugs.");
			}

			//Drug Lord
			if(StrContains(info, "Counterfeiter", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - Buy the item called 'Money Printer'");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - wait for the printer to print money!");
				CPrintToChat(Client, "\x07FF40403:\x07FFFFFF - once the timer is up the printer will remove once you've collected!");
				CPrintToChat(Client, "\x07FF40405:\x07FFFFFF - just remember, cops and people can destroy/steal your drugs.");
			}


			//Med Student
			if(StrContains(info, "Brain Surgeon", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - go up to people with low health and press >>USE<< on them");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - to heal them, you will also gain money by doing this");
			}

			//Street Sweeper
			if(StrContains(info, "Street Sweeper", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - As a street sweeper, you have to find trash and put it into the trash can");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - once you've done this empty the trash can to gain money!");
			}

			//Hobo
			if(StrContains(info, "Street Thug", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - you will gain more money from robbing vendors and money safes");
			}

			//Trader
			if(StrContains(info, "Trader", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - As a trader, people can buy rare items from you.");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - also as a trader you will sell items lower than the normal price");
				CPrintToChat(Client, "\x07FF40402:\x07FFFFFF - plus earn money from selling the items");
			}

			//Hobo
			if(StrContains(info, "City Official", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - will receive an extra bonus on their job salary!");
			}

			//Hobo
			if(StrContains(info, "Bounty Hunter", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - will Will gain extra cash when collecting a bounty!");
			}

			//Hobo
			if(StrContains(info, "Explosive Expert", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - You sell explosive type of weapons!");
			}

			//Hobo
			if(StrContains(info, "Drinks Sales Director", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - You sell drinks!");
			}

			//Hobo
			if(StrContains(info, "Bank Administrative Officer", false) != -1)
			{
				CPrintToChat(Client, "\x07FF40401:\x07FFFFFF - People can now use you to deposit there cash!");
			}

			//Set Model:
			//SetRoleplayModel(Client);

			//Return:
			return false;
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