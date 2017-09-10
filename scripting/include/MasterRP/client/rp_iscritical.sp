//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_critical_included_
  #endinput
#endif
#define _rp_critical_included_

static bool:IsCritical[2047] = {false,...};

public Action:PluginInfo_IsCritical(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Critical Hit!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Show Player Hud
public Action:ClientCriticalOverride(Client)
{

	//Initialize:
	new CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP > 20 && IsCritical[Client])
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "0");

		//Initulize:
		IsCritical[Client] = false;
	}
}

//Event Damage:
public Action:OnDamageCriticalCheck(Client)
{

	//Initialize:
	new CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20)
	{

		//Command:
		CheatCommand(Client, "r_screenoverlay", "effects/tp_eyefx/tpeye.vmt");

		//Initulize:
		IsCritical[Client] = true;
	}
}

//Health Manage:
public Action:IsCriticalHealth(Client)
{

	//Initialize:
	new CHP = GetClientHealth(Client);

	//Is Already Critical:
	if(CHP <= 20)
	{

		//Declare:
		decl Float:Angles[3];

		//Initialize:
		GetClientEyeAngles(Client, Angles);

		//Effect:
		CreateEnvBlood(Client, Angles, 1.0);

		//Check:
		if(CHP - 2 > 1)
		{

			//Play Hurt SOUND:
			OnClientHurtSound(Client);

			//Set Client Health:
			SetEntityHealth(Client, (CHP - 2));
		}

		//Override:
		else
		{

			//Slay Client:
			ForcePlayerSuicide(Client);
		}
	}

	//Is Already Critical:
	if(CHP > 20 && CHP < 100)
	{

		//Enough Health:
		if((CHP + 1) > 100)
		{

			//Set Ent Health:
			SetEntityHealth(Client, 100);
		}

		//Override:
		else
		{

			//Set Ent Health:
			SetEntityHealth(Client, (CHP + 1));
		}
	}
}

public bool:GetIsCritical(Client)
{

	//Return:
	return IsCritical[Client];
}

public SetIsCritical(Client, bool:Result)
{

	//Inituluize:
	IsCritical[Client] = Result;
}

public ResetCritical(Client)
{

	IsCritical[Client] = false;
}

ResetAllCritical()
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Inituluize:
		IsCritical[X] = false;
	}
}