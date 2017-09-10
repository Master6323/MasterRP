//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_jobsetup_included_
  #endinput
#endif
#define _rp_jobsetup_included_

//Roleplay Core:
static String:JobSetupPath[256];

//Misc:
static String:GlobalModel[MAXPLAYERS + 1][255];

public Action:PluginInfo_JobSetup(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "KV Job Defaults!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initJobSetup()
{

	//Job Setup DB:
	BuildPath(Path_SM, JobSetupPath, 256, "data/roleplay/jobs_setup.txt");
	if(FileExists(JobSetupPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", JobSetupPath);
}

public Action:SetupRoleplayJob(Client)
{

	//Handle:
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");

	//Load:
	FileToKeyValues(Vault, JobSetupPath);

	//Declare:
	decl String:Id[255], String:JobId[32], String:Buffer[255], Health, Suit;

	//Format:
	Format(JobId, sizeof(JobId), "%s", GetJob(Client));

	for(new X = 0; X < 15; X++)
	{

		//Convert:
		IntToString(X, Id, 255);

		//Load:
		LoadString(Vault, JobId, Id, "null", Buffer);

		//Is Valid:
		if(!StrEqual(Buffer, "null", false))	
		{

			//Give Weapon:
			GiveClientWeapon(Client, Buffer);
		}
	}

	//Get Value
	Health = LoadInteger(Vault, JobId, "health", -1);

	//Get Value
	Suit = LoadInteger(Vault, JobId, "suit", -1);

	//Valid Health:
	if(Health != -1)
	{

		//Set Prop:
		SetEntProp(Client, Prop_Data, "m_iHealth", Health);

		SetEntProp(Client, Prop_Data, "m_iMaxHealth", Health);
	}

	//Valid Suit:
	if(Suit != -1)
	{

		//Set Armor:
		SetEntityArmor(Client, Suit);
	}

	//Load:
	LoadString(Vault, JobId, "Model", "null", Buffer);

	//Not Map:
	if(!StrEqual(Buffer, "null"))
	{

		//Set Model:
		SetModel(Client, Buffer);
	}
}

public Action:initRandomModel(Client)
{

	//Declare:
	decl String:Buffer[255];

	//Declare:
	new Random = GetRandomInt(1, 2);

	//Mail:
	if(Random == 1)
	{

		//Initulize:
		Random = GetRandomInt(1, 7);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group01/male_0%i.mdl", Random);
	}

	//Mail:
	if(Random == 2)
	{

		//Initulize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(Buffer, sizeof(Buffer), "models/Humans/Group01/female_0%i.mdl", Random);
	}

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Buffer);
}

public SetModel(Client, String:Str[255])
{

	//Format:
	Format(GlobalModel[Client], sizeof(GlobalModel[]), "%s", Str);

	//Is PreCached:
	if(!IsModelPrecached(GlobalModel[Client]))
	{

		//PreCache:
		PrecacheModel(GlobalModel[Client]);
	}

	//Set Client Model:
	SetEntityModel(Client,  GlobalModel[Client]);

	//Declare:
	decl String:query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Model = '%s' WHERE STEAMID = %i;", Str, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

String:GetModel(Client)
{

	//return:
	return GlobalModel[Client];
}
