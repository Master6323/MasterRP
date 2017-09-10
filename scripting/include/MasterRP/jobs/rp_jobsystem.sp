//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobsystem_included_
  #endinput
#endif
#define _rp_jobsystem_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Defines:
#define SALARY_TIME 		120
#define DEFAULTJOB 		"Citizan"

//Job system:
static JobExperience[MAXPLAYERS + 1] = {0,...};
static Energy[MAXPLAYERS + 1] = {0,...};
static NextJobRase[MAXPLAYERS + 1] = {0,...}; //loaded from rp_player.sp
static JobSalary[MAXPLAYERS + 1] = {4,...}; //loaded from rp_player.sp

//Job Strings:
static String:Job[MAXPLAYERS + 1][255];
static String:OrgJob[MAXPLAYERS + 1][255];

//Job system:
static CopExperience[MAXPLAYERS + 1] = {0,...};
static CopCuffs[MAXPLAYERS + 1] = {0,...};
static CopMinutes[MAXPLAYERS + 1] = {0,...};

//Hunger:
static Float:Hunger[MAXPLAYERS + 1] = {100.0,...};

//Map Manager:
static SalaryCheck = SALARY_TIME;

public Action:PluginInfo_JobSystem(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Dynamic Job System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initJobSytem()
{

	//Commands
	RegAdminCmd("sm_setjobsalary", Command_setJobSalary, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Job Salary of the Client");

	RegAdminCmd("sm_sethunger", Command_SetHunger, ADMFLAG_SLAY, "<Name> <Hunger #> - Sets Hunger");
	//Timer:
	CreateTimer(0.4, CreateSQLdbDynamicJobs);
}

//Create Database:
public Action:CreateSQLdbDynamicJobs(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[2560];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `Jobs`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL PRIMARY KEY, `CopMinutes` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `CopCuffs` int(12) NULL, `CopExperience` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Experience` int(12) NOT NULL DEFAULT 0, `Energy` int(12) NOT NULL DEFAULT 100,");

	len += Format(query[len], sizeof(query)-len, " `Hunger` float(12) NOT NULL DEFAULT '100.0', `Harvest` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Meth` int(12) NOT NULL DEFAULT 0, `Pills` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Cocain` int(12) NOT NULL DEFAULT 0, `Rice` int(12) NOT NULL DEFAULT 0,");

	len += Format(query[len], sizeof(query)-len, " `Resources` int(12) NOT NULL DEFAULT 0);");

	//Thread Query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action:DBLoadJobs(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `Jobs` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_LoadJobsCallBack, query, conuserid);
}

public T_LoadJobsCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Jobs] T_LoadJobsCallBack: Query failed! %s", error);
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
			InsertJobs(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			CopMinutes[Client] = SQL_FetchInt(hndl, 1);

			//Database Field Loading INTEGER:
			CopCuffs[Client] = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			CopExperience[Client] = SQL_FetchInt(hndl, 3);

			//Database Field Loading INTEGER:
			JobExperience[Client] = SQL_FetchInt(hndl, 4);

			//Database Field Loading INTEGER:
			Energy[Client] = SQL_FetchInt(hndl, 5);

			//Database Field Loading FLOAT:
			Hunger[Client] = SQL_FetchFloat(hndl, 6);

			//Print:
			PrintToConsole(Client, "|RP| player Job system loaded.");
		}
	}
}

public Action:InsertJobs(Client)
{

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO Jobs (`STEAMID`) VALUES (%i);", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Jobs.");
}

public Action:SetDefaultJob(Client)
{

	//Format:
	//Format(Job[Client], sizeof(Job[]), "%s", DEFAULTJOB);

	//Format(OrgJob[Client], sizeof(OrgJob[]), "%s", DEFAULTJOB);

	Job[Client] = DEFAULTJOB;

	OrgJob[Client] = DEFAULTJOB;

	JobSalary[Client] = 4;

	NextJobRase[Client] = 0;
}

public Action:initSalaryTimer()
{

	//Initialize:
	SalaryCheck -= 1;

	//Is Job Salary Due:
	if(SalaryCheck == 1 || SalaryCheck == 60)
	{

		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(IsClientConnected(Client) && IsClientInGame(Client))
			{

				//Initulize:
				SetCash(Client, (GetCash(Client) + GetJobSalary(Client)));

				//Set Menu State:
				CashState(Client, GetJobSalary(Client));

				//Initialize:
				SetNextJobRase(Client, (GetNextJobRase(Client) + 1));

				//Wages:
				if(NextJobRase[Client] >= Pow(float(GetJobSalary(Client)), 3.0))
				{

					//Add:
					SetJobSalary(Client, (GetJobSalary(Client) + 1));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - You have recieved a raise for spending a total of \x0732CD32%i\x0732CD32\x07FFFFFF minutes in the server\x0732CD32\x07FFFFFF.", NextJobRase[Client]);
				}

				//Take Hunger:
				initHunger(Client);

				//Save:
				DBSave(Client);

				//Save Spawned Items:
				SaveSpawnedItemForward(Client, false);

				//Update Last Stats:
				UpdateLastStats(Client);

				//Recover Energy:
				initEnergy(Client);

				//Remove Drug
				initDrugTick(Client);
			}
		}

		//Special NPC Events
		InitNpcEvents();

		//Clean Map Entities:
		initPropSpawnedTime();
	}

	//Check Timer:
	if(SalaryCheck < 1)
	{

		//Spawn Server Trash:
		initGarbage();

		//Initialize:
		SalaryCheck = SALARY_TIME;
	}
}

public Action:initHunger(Client)
{

	//Is Client Cuffed:
	if(!IsCuffed(Client) && IsHungerDisabled() == 0)
	{

		//Declare
		new Float:Amount = GetHunger(Client);

		//Less Hunger:
		if(IsSleeping(Client) > 0.0)
		{

			//Initialize:
			SetHunger(Client, (Amount - GetRandomFloat(0.05, 0.20)));
		}

		//Override:
		else
		{

			//Initialize:
			SetHunger(Client, (Amount - GetRandomFloat(0.40, 0.70)));
		}

		//No Hunger:
		if(Amount <= 0.0)
		{

			//Slay Client:
			ForcePlayerSuicide(Client);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You starved to death!");

			//Initialize:
			SetHunger(Client, 35.0);

			//Has Cash:
			if(GetBank(Client) - 50 > 0)
			{

				//Bank State:
				BankState(Client, -50);

				//Initialize:
				SetBank(Client, (GetBank(Client) - 50));
			}
		}
	}
}

public Action:Command_setJobSalary(Client,Args)
{

	//Declare:
	new Player;

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_setjobSalary <USER> <Salary>");

		//Return:
		return Plugin_Handled;      
	}

	//Is Valid:
	if(Args == 2)
	{

		//Declare:
		decl String:PlayerName[32], String:Name[32], String:Muny[32];
		new Munny = 0; 

		//Initialize:
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));

		//Initialize:
		Munny = StringToInt(Muny);  

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
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client %s", PlayerName);

			//Return:
			return Plugin_Handled;
		}

		//Is Console:
		if(Client == 0)
		{

			//Initialize:
			Name = "Console";
		}
		else
		{

			//Initialize:
			GetClientName(Client, Name, sizeof(Name));
		}

		//Initialize:
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Initialize:
		SetJobSalary(Player, Munny);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the JobSalary for \x0732CD32%s\x07FFFFFF to \x0732CD32â‚¬%i", PlayerName, Munny);

		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your JobSalary has been set to \x0732CD32â‚¬%i\x07FFFFFF by \x0732CD32%s", Munny, Name);
#if defined DEBUG
		//Logging:
		LogMessage("\"%s\" set %s's JobSalary to \"€%i\"", Name, PlayerName, Munny); 
#endif
	}

	//Return:
	return Plugin_Handled; 
}

public Action:Command_SetHunger(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_sethunger <Name> <Hunger #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32], String:ClientName[32],String:Name[32],String:Amount[32];
	new Float:iAmount, Player;

	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	GetCmdArg(2, Amount, sizeof(Amount));

	//Initialize:
	iAmount = StringToFloat(Amount);
	
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

	//Action:
	SetHunger(Player, iAmount);

	//Initialize:
	GetClientName(Player, Name, sizeof(Name));

	GetClientName(Client, ClientName, sizeof(ClientName));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%s\x07FFFFFF's hunger to \x0732CD32%s", Name, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF set your hunger to \x0732CD32%s", ClientName, Amount);
	}

#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the hunger of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

//Return Wages:
public GetCopWages(Client)
{

	//Initulize:
	new int = CopMinutes[Client] / 600;

	//Is Valid:
	if(int < 3)
	{

		//Initulize:
		int = 3;
	}

	//Initulize:
	new Addedint = CopCuffs[Client] / 200;

	//Is Valid:
	if(Addedint < 2)
	{

		//Initulize:
		Addedint = 2;
	}

	//Initulize:
	int += Addedint;

	//Return:
	return int;
}
public GetSalaryCheck()
{

	//Return:
	return SalaryCheck;
}

public GetEnergy(Client)
{

	//Return:
	return Energy[Client];
}

public SetEnergy(Client, Amount)
{

	//Initulize:
	Energy[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Energy = %i WHERE STEAMID = %i;", Energy[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetNextJobRase(Client)
{

	//Return:
	return NextJobRase[Client];
}

public SetNextJobRase(Client, Amount)
{

	//Initulize:
	NextJobRase[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Rase = %i WHERE STEAMID = %i;", NextJobRase[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetJobSalary(Client)
{

	//Return:
	return JobSalary[Client];
}

public SetJobSalary(Client, Amount)
{

	//Initulize:
	JobSalary[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET JobSalary = %i WHERE STEAMID = %i;", JobSalary[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetJobExperience(Client)
{

	//Return:
	return JobExperience[Client];
}

public SetJobExperience(Client, Amount)
{

	//Initulize:
	JobExperience[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Experience = %i WHERE STEAMID = %i;", JobExperience[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public SetJob(Client, String:Str[255])
{

	//Format:
	Format(Job[Client], sizeof(Job[]), "%s", Str);
}

String:GetJob(Client)
{

	//return:
	return Job[Client];
}

public SetOrgJob(Client, String:Str[255])
{

	//Format:
	Format(OrgJob[Client], sizeof(OrgJob[]), "%s", Str);

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Job = '%s' WHERE STEAMID = %i;", OrgJob[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

String:GetOrgJob(Client)
{

	//return:
	return OrgJob[Client];
}

//Cop or Admin Check:
public bool:IsCop(Client)
{

	//Connected:
	if(Client < 1 || !IsClientConnected(Client) || !IsClientInGame(Client))
	{

		//Return:
		return false;
	}

	//Is Police:
	if(StrContains(GetJob(Client), "Police", false) != -1)
	{

		//Return:
		return true;
	}

	//Is Swat:
	if(StrContains(GetJob(Client), "SWAT", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

//Cop or Admin Check:
public bool:IsCopOrgJob(Client)
{

	//Connected:
	if(Client < 1 || !IsClientConnected(Client) || !IsClientInGame(Client))
	{

		//Return:
		return false;
	}

	//Is Police:
	if(StrContains(GetOrgJob(Client), "Police", false) != -1)
 	{

		//Return:
		return true;
	}

	//Is Swat:
	if(StrContains(GetOrgJob(Client), "SWAT", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public Float:GetHunger(Client)
{

	//Return:
	return Hunger[Client];
}

public SetHunger(Client, Float:Amount)
{

	//Initulize:
	Hunger[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Jobs SET Hunger = %f WHERE STEAMID = %i;", Hunger[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

String:GetHungerString(Client)
{

	//Declare:
	decl String:ShowHunger[32] = "null"; new Float:Amount = GetHunger(Client);

	//Not Hungry:
	if(Amount > 100.0)
	{

		//Initialize:
		ShowHunger = "Very Full";

		//Return:
		return ShowHunger;
	}

	//Not Hungry:
	if(Amount >= 70.0)
	{

		//Initialize:
		ShowHunger = "Not Hungry";
	}

	//A Little Hungry:
	else if(Amount >= 60.0)
	{

		//Initialize:
		ShowHunger = "A Little Hungry";

		//Return:
		return ShowHunger;
	}

	//Fairly Hungry:
	else if(Amount >= 45.0)
	{

		//Initialize:
		ShowHunger = "Fairly Hungry";

		//Return:
		return ShowHunger;
	}

	//Very Hungry:
	else if(Amount >= 30.0)
	{

		//Initialize:
		ShowHunger = "Very Hungry";

		//Return:
		return ShowHunger;
	}

	//Starving:
	else if(Amount >= 10.0)
	{

		//Initialize:
		ShowHunger = "Starving";

		//Return:
		return ShowHunger;
	}

	//Dieing of Hunger:
	else if(Amount < 10.0)
	{

		//Initialize:
		ShowHunger = "Dieing of Hunger";

		//Return:
		return ShowHunger;
	}

	//Return:
	return ShowHunger;
}

public GetCopCuffs(Client)
{

	//Return:
	return CopCuffs[Client];
}

public SetCopCuffs(Client, Amount)
{

	//Initulize:
	CopCuffs[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE job SET CopCuffs = %i WHERE STEAMID = %i;", CopCuffs[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetCopMinutes(Client)
{

	//Return:
	return CopMinutes[Client];
}

public SetCopMinutes(Client, Amount)
{

	//Initulize:
	CopMinutes[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET CopMinutes = %i WHERE STEAMID = %i;", CopMinutes[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public GetCopExperience(Client)
{

	//Return:
	return CopExperience[Client];
}

public SetCopExperience(Client, Amount)
{

	//Initulize:
	CopExperience[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET CopExperience = %i WHERE STEAMID = %i;", CopExperience[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public Action:initEnergy(Client)
{

	//Full Energy:
	if(GetEnergy(Client) < 100)
	{

		//Too Much Energy:
		if(GetEnergy(Client) + 25 > 100)
		{

			//Initulize:
			SetEnergy(Client, 100);
		}

		//Override:
		else
		{

			//Initulize:
			SetEnergy(Client, (GetEnergy(Client) + 25));
		}
	}
}

public initDrugTick(Client)
{

	//Check:
	if(GetDrugTick(Client) == 1)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Timer:
		CreateTimer(0.0, backspeed, Client);
	}

	//Check:
	if(GetDrugTick(Client) > 0)
	{

		//Initulize:
		SetDrugTick(Client, (GetDrugTick(Client) - 1));
	}

	//Declare:
	new Random = GetRandomInt(1, 5);

	//Check:
	if(Random == 1)
	{

		//Check:
		if(GetDrugHealth(Client) > 1)
		{

			//Initulize:
			SetDrugHealth(Client, (GetDrugHealth(Client) - 1));
		}
	}
}