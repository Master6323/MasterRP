//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hl2dmfixes_included_
  #endinput
#endif
#define _rp_hl2dmfixes_included_

static Float:g_fBlockTime[MAXPLAYERS + 1];
static bool:g_bHasCrossbow[MAXPLAYERS + 1];

//Set Team Play:
IntHL2MP()
{

	//Declare:
	new Ent = -1;

	//Switch:
	while ((Ent = FindEntityByClassname(Ent, "hl2mp_gamerules")) != -1)
	{

		//Set Ent Data:
		SetEntData(Ent, FindSendPropInfo("CHL2MPGameRulesProxy", "m_bTeamPlayEnabled"), 1, 1, true);
	}

	// Hooks:
	AddTempEntHook("Shotgun Shot", EventFireBullets);
}

initMapFix()
{

	//Declare:
	decl String:ClassName[32];

	//Loop:
	for(new Ent = 1; Ent < 2047; Ent++)
	{

		//Save:
		SetWeaponInfo(Ent, "null");

		//Valid:
		if(Ent > GetMaxClients() && IsValidEdict(Ent))
		{

			//Get Entity Info:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Roleplay Map:
			if(StrContains(ClassName, "weapon_", false) == 0)
			{

				//Kill:
				AcceptEntityInput(Ent, "kill");

				//Initulize:
				SetPropSpawnedTimer(Ent, -1);
			}

			//Is Func Door:
			if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Touch Hook:
				SDKHook(Ent, SDKHook_StartTouch, OnDoorStartTouch);

				SDKHook(Ent, SDKHook_Touch, OnDoorStartTouch);
			}
		}
	}
}

//On Door Touch:
public OnDoorStartTouch(Ent, OtherEnt)
{

	//Declare:
	decl String:ClassName[64];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Is Grenade:
	if(StrContains(ClassName, "grenade") != -1)
	{

		//Kill:
		AcceptEntityInput(OtherEnt, "Kill");
	}
}

//Fix:
public Action:HL2dmFix(Client, &Buttons, &impulse, Float:vel[3], Float:angles[3], &Weapon)
{

	//Check:
	if(GetThirdPersonView(Client))
	{

		//Initulize:
		//Buttons &= ~IN_DUCK;

		//Initulize:
		//Buttons &= ~IN_JUMP;
	}

	// Detecting a crossbow shot.
	if((Buttons & IN_ATTACK) && g_bHasCrossbow[Client])
	{

		//Declare:
		new iWeapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

		//Check:
		if (IsValidEdict(iWeapon) && GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack") < GetGameTime())
		{

			//Initulize:
			g_fBlockTime[Client] = GetGameTime() + 0.1;
		}
	}
	
	// Don't let the player crouch if they are in the process of standing up.
	if((Buttons & IN_DUCK) && GetEntProp(Client, Prop_Send, "m_bDucked", 1) && GetEntProp(Client, Prop_Send, "m_bDucking", 1))
	{

		//Initulize:
		Buttons ^= IN_DUCK;
	}
	
	// Only allow sprint if the player is alive.
	if((Buttons & IN_SPEED) && !IsPlayerAlive(Client))
	{

		//Initulize:
		Buttons ^= IN_SPEED;
	}
	
	// Block flashlight/weapon toggle after a bullet has fired.
	if((impulse == 51) || (impulse == 100 && g_fBlockTime[Client] > GetGameTime()))
	{

		//Initulize:
		impulse = 0;
	}

	//Check:
	if(Weapon && IsValidEdict(Weapon) && g_fBlockTime[Client] > GetGameTime())
	{

		//Declare:
		decl String:ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		if(StrEqual(ClassName, "weapon_physcannon"))
		{

			//Initulize:
			Weapon = 0;
		}
	}

	//Is Alive:
	if(IsProtected(Client))
	{

		//Button Preventsion:
		Buttons &= ~IN_ATTACK;

		//Button Preventsion:
		Buttons &= ~IN_ATTACK2;
	}

	//Initulize:
	new CurrentWeapon = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");

	if(CurrentWeapon != -1)
	{

		//Declare:
		decl String:ClassName[32];

		//Initulize:
		GetEdictClassname(CurrentWeapon, ClassName, sizeof(ClassName));

		//Check:
		if(!strcmp(ClassName, "weapon_shotgun") && (Buttons & IN_ATTACK2) == IN_ATTACK2)
		{

			//Initulize:
			Buttons |= IN_ATTACK;
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action:EventFireBullets(const String:te_name[], const Players[], numClients, Float:delay)
{

	//Declare:
	new Ent = TE_ReadNum("m_iPlayer");

	//Check:
	if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
	{

		//Initulize:
		g_fBlockTime[Ent] = GetGameTime() + 0.1;
	}

	//Check:
	if(Ent > GetMaxClients())
	{

		//Loop:
		for(new i = 1; i <= GetMaxClients(); i++)
		{

			//Check:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Is In Line Of Sight!
				if(IsTargetInLineOfSight(Ent, i))
				{

					//SDKHooks Forward:
					SDKHooks_TakeDamage(i, Ent, Ent, 15.0, DMG_BUCKSHOT);
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action:OnClientWeaponCanSwitchTo(Client, Weapon)
{

	//Check:
	if(IsValidEdict(Weapon))
	{

		//Declare
		decl String:ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		//Check:
		if (g_fBlockTime[Client] > GetGameTime() && StrEqual(ClassName, "weapon_physcannon"))
		{

			//Return:
			return Plugin_Handled;
		}
	}

	//Return:
	return Plugin_Continue;
}

public OnClientWeaponSwitchPost(Client, Weapon)
{

	//Check:
	if(IsValidEdict(Weapon))
	{

		//Declare
		decl String:ClassName[32];

		//Initulize:
		GetEdictClassname(Weapon, ClassName, sizeof(ClassName));

		//Check:
		if(StrEqual(ClassName, "weapon_crossbow"))
		{

			//Initulize:
			g_bHasCrossbow[Client] = true;
		}
	}

	//Initulize:
	g_bHasCrossbow[Client] = false;
}

public Action:OnClientVeicleDamage(Client, &attacker, &inflictor, &Float:damage, &damageType)
{

	if(damageType & DMG_VEHICLE)
	{

		//Declare:
		decl String:ClassName[30];

		//Initulize:
		GetEdictClassname(inflictor, ClassName, sizeof(ClassName));

		//Is Vehicle:
		if (StrEqual("prop_vehicle_driveable", ClassName, false))
		{

			//Declare
			new Driver = GetEntPropEnt(inflictor, Prop_Send, "m_hPlayer");

			//Check:
			if (Driver != -1)
			{

				//Initulize:
				damage *= 2.0;
				
				attacker = Driver;
			}
		}
	}
}