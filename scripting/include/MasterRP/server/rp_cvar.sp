//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_cvar_included_
  #endinput
#endif
#define _rp_cvar_included_

//ConVars Handles:
enum CVars
{
	Handle:CV_ROBTIME,
	Handle:CV_CRIMEBOUNTY,
	Handle:CV_COPDROP,
	Handle:CV_CUFFDAMAGE,
	Handle:CV_COPKILL,
	Handle:CV_ALLCOPUNCUFF,
	Handle:CV_PHYSDAMAGE,
	Handle:CV_PROTECT,
	Handle:CV_HUNGER,
	Handle:CV_DEPOSIT
};

//ConVars Values:
enum CVarValues
{
	ROBTIME = 1,
	CRIMEBOUNTY = 2,
	COPDROP = 3,
	CUFFDAMAGE = 4,
	COPKILL = 5,
	ALLCOPUNCUFF = 6,
	PHYSDAMAGE = 7,
	PROTECT = 8,
	HUNGER = 9,
	DEPOSIT = 10,
};

//CVar Handle:
static Handle:CVar[CVars] = {INVALID_HANDLE,...};
static CVarValue[CVarValues];

public Action:PluginInfo_Cvar(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Cvars!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initCvar()
{

	//ConVar:
	CVar[CV_CRIMEBOUNTY] = CreateConVar("sm_setbounty_start", "20000","Set crime to bounty start limitdefault (5000)");

	CVar[CV_ROBTIME] = CreateConVar("sm_robtime", "600", "Npc Robbing interval default (900)");

	CVar[CV_COPDROP] = CreateConVar("sm_disable_copdrop", "0", "disable/enableDo cops drop money on death default (0)");

	CVar[CV_CUFFDAMAGE] = CreateConVar("sm_disable_cuff_damage", "1", "disable/enable damage while a player is default (1)");

	CVar[CV_COPKILL] = CreateConVar("sm_disable_cop_kill", "0", "Disable/Enable teamkilling for cops default (0)");

	CVar[CV_ALLCOPUNCUFF] = CreateConVar("sm_disable_copcuff", "1", "disable/enable cops uncuff default (0)");

	CVar[CV_PHYSDAMAGE] = CreateConVar("sm_disable_physdamage", "1", "disable/enable physdamage from props default (1)");

	CVar[CV_PROTECT] = CreateConVar("sm_protect_time", "5.0", "set the spawn protection time default (10.0)");

	CVar[CV_HUNGER] = CreateConVar("sm_disable_hunger", "0", "Disable/Enable  default (1)");

	CVar[CV_DEPOSIT] = CreateConVar("sm_quickdepsoit", "1", "default 1");

	//ConVar Hooks:
	HookConVarChange(CVar[CV_CRIMEBOUNTY], OnConVarChange);

	HookConVarChange(CVar[CV_ROBTIME], OnConVarChange);

	HookConVarChange(CVar[CV_COPDROP], OnConVarChange);

	HookConVarChange(CVar[CV_CUFFDAMAGE], OnConVarChange);

	HookConVarChange(CVar[CV_COPKILL], OnConVarChange);

	HookConVarChange(CVar[CV_ALLCOPUNCUFF], OnConVarChange);

	HookConVarChange(CVar[CV_PHYSDAMAGE], OnConVarChange);

	HookConVarChange(CVar[CV_PROTECT], OnConVarChange);

	HookConVarChange(CVar[CV_HUNGER], OnConVarChange);

	HookConVarChange(CVar[CV_DEPOSIT], OnConVarChange);
}

public OnConfigsExecuted()
{

	//Get Values:
	CVarValue[ROBTIME] = GetConVarInt(CVar[CV_ROBTIME]);

	CVarValue[CRIMEBOUNTY] = GetConVarInt(CVar[CV_CRIMEBOUNTY]);

	CVarValue[COPDROP] = GetConVarInt(CVar[CV_COPDROP]);

	CVarValue[CUFFDAMAGE] = GetConVarInt(CVar[CV_CUFFDAMAGE]);

	CVarValue[COPKILL] = GetConVarInt(CVar[CV_COPKILL]);

	CVarValue[ALLCOPUNCUFF] = GetConVarInt(CVar[CV_ALLCOPUNCUFF]);

	CVarValue[PHYSDAMAGE] = GetConVarInt(CVar[CV_PHYSDAMAGE]);

	CVarValue[PROTECT] = GetConVarInt(CVar[CV_PROTECT]);

	CVarValue[HUNGER] = GetConVarInt(CVar[CV_HUNGER]);

	CVarValue[DEPOSIT] = GetConVarInt(CVar[CV_DEPOSIT]);

	//Bans Cfg:
	OnBansExecuted();
}

public OnConVarChange(Handle:hCVar, const String:oldValue[], const String:newValue[]) 
{

	//Check Handle:
	if(hCVar == CVar[CV_ROBTIME])
	{

		//Initulize:
		CVarValue[ROBTIME] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_CRIMEBOUNTY])
	{

		//Initulize:
		CVarValue[CRIMEBOUNTY] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_COPDROP])
	{

		//Initulize:
		CVarValue[COPDROP] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_CUFFDAMAGE])
	{

		//Initulize:
		CVarValue[CUFFDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_COPKILL])
	{

		//Initulize:
		CVarValue[COPKILL] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_ALLCOPUNCUFF])
	{

		//Initulize:
		CVarValue[ALLCOPUNCUFF] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_PHYSDAMAGE])
	{

		//Initulize:
		CVarValue[PHYSDAMAGE] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_PROTECT])
	{

		//Initulize:
		CVarValue[PROTECT] = StringToInt(newValue) * 2;
	}

	//Check Handle:
	if(hCVar == CVar[CV_HUNGER])
	{

		//Initulize:
		CVarValue[HUNGER] = StringToInt(newValue);
	}

	//Check Handle:
	if(hCVar == CVar[CV_DEPOSIT])
	{

		//Initulize:
		CVarValue[DEPOSIT] = StringToInt(newValue);
	}
}

public GetRobTime()
{

	return CVarValue[ROBTIME];
}

public GetCrimeToBounty()
{

	return CVarValue[CRIMEBOUNTY];
}

public IsCopDropDisabled()
{

	return CVarValue[COPDROP];
}

public IsCuffDamageDisabled()
{

	return CVarValue[CUFFDAMAGE];
}

public IsCopKillDisabled()
{

	return CVarValue[COPKILL];
}

public IsPhysDamageDisabled()
{

	return CVarValue[PHYSDAMAGE];
}

public IsCopUnCuffEnabled()
{

	return CVarValue[ALLCOPUNCUFF];
}


public IsHungerDisabled()
{

	return CVarValue[HUNGER];
}

public IsQuickDepositDisabled()
{

	return CVarValue[DEPOSIT];
}

public GetSpawnProtectTime()
{

	return CVarValue[PROTECT];
}