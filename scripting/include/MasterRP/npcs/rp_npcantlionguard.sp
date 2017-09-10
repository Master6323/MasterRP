//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcantlionguard_included_
  #endinput
#endif
#define _rp_npcantlionguard_included_

//Eplode Sound:
static String:Sound[255] = "ambient/levels/labs/electric_explosion5.wav";

public Action:PluginInfo_NpcAntLionGuard(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Custom AntLion Guard NPC!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initNpcAntLionGuard()
{

	//NPC Beta:
	RegAdminCmd("sm_testantlionguard", Command_CreateNpcAntLionGuard, ADMFLAG_ROOT, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");

	//Entity Event Hook:
	HookEntityOutput("npc_antlionguard", "OnDeath", OnAntLionGuardDied);

	//Precache:
	PrecacheSound(Sound);
}

//Event Damage:
public Action:OnAntLionGuardDamageClient(Client, &attacker, &inflictor, &Float:damage, &damageType)
{

	//Initialize:
	damage = GetRandomFloat(75.0, 200.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action:OnDamageAntLionGuard(Ent, &Client, &inflictor, &Float:damage, &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Initialize:
	damageType = DMG_DISSOLVE;

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public OnAntLionGuardDied(const String:Output[], Caller, Activator, Float:Delay)
{

	//Is Valid:
	if(IsValidEdict(Activator) && Activator > 0 && Activator <= GetMaxClients())
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has Killed the AntLion Guard!", Activator);
	}

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(i > 0 && IsClientConnected(i) && IsClientInGame(i))
		{

			//Declare:
			new Amount = RoundFloat(GetDamage(i) * 5);

			//Check:
			if(Amount > 0)
			{

				//DamageCheck
				if(Amount > 10000) Amount = GetRandomInt(9500, 15000);

				//Initulize:
				SetBank(i, (GetBank(i) + Amount));

				//Bank State:
				BankState(i, Amount);

				//Print:
				CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - You have been rewarded %s!", IntToMoney(Amount));

				//Initulize:
				SetDamage(i, 0.0);
			}
		}
	}

	//Check:
	if(IsValidAttachedEffect(Caller))
	{

		//Remove:
		RemoveAttachedEffect(Caller);
	}

	//Check:
	if(IsValidLight(Caller))
	{

		//Remove Light:
		RemoveLight(Caller);
	}

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action:Command_CreateNpcAntLionGuard(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Position[3]; new Float:Angles[3] = {0.0,...};

	//Initulize:
	GetCollisionPoint(Client, Position);

	CreateNpcAntLionGuard("null", Position, Angles, 10000, 1);

	//Return:
	return Plugin_Handled;
}

public CreateNpcAntLionGuard(String:Model[], Float:Position[3], Float:Angles[3], Health, Custom)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	new NPC = CreateEntityByName("npc_antlionguard");

	//Is Valid:
	if(NPC > 0)
	{

		//Dispatch
		DispatchKeyValue(NPC, "spawnflags", "512");
		//DispatchKeyValue(NPC, "cavern breed", "1");

		DispatchKeyValue(NPC, "name", "npc_antlionguard");

		//Spawn & Send:
		DispatchSpawn(NPC);

		if(!StrEqual(Model, "null"))
		{

			//Set Model
        		SetEntityModel(NPC, Model);
		}

		//Teleport:
		TeleportEntity(NPC, Position, Angles, NULL_VECTOR);

		//Set Hate Status
		SetVariantString("player D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_vortigaunt D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_advisor D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Hate Status
		SetVariantString("npc_clawscanner D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//AcceptEntityInput(NPC, "EnableBark");

		//SetEntProp(NPC, Prop_Data, "m_bCavernBreed", 1);

		//SetEntProp(NPC, Prop_Data, "m_bInCavern", 1);

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		SetEntProp(NPC, Prop_Data, "m_iMaxHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnDamageAntLionGuard);

		//Initulizse:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Check:
		if(Custom == 1)
		{

			//Initulize Effects:
			new Effect = CreatePointTesla(NPC, "0", "51 120 255");

			SetEntAttatchedEffect(NPC, 0, Effect);

			Effect = CreatePointTesla(NPC, "1", "51 120 255");

			SetEntAttatchedEffect(NPC, 1, Effect);

			//Set Ent Color:
			SetEntityRenderColor(NPC, 51, 120, 255, 255);

			//Initulize:
			SetIsCritical(NPC, true);

			//Timer:
			CreateTimer(0.5, InitCritical, NPC, TIMER_REPEAT);

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "0");

			SetEntAttatchedEffect(NPC, 2, Effect);

			//Added Effect:
			Effect = CreateLight(NPC, 1, 51, 120, 255, "1");

			SetEntAttatchedEffect(NPC, 3, Effect);
		}

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}

public Action:InitCritical(Handle:Timer, any:Ent)
{

	//Check & Is Alive::
	if(!IsValidEdict(Ent) || (GetEntHealth(Ent) <= 0))
	{

		//Kill:
		KillTimer(Timer);

		//Initulize:
		Timer = INVALID_HANDLE;
	}

	//Override:
	else
	{

		//Declare:
		new TempEnt = GetEntAttatchedEffect(Ent, 0);

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");

		//Timer:
		CreateTimer(0.25, DelayEffect, Ent);

		//Declare:
		new Float:ClientOrigin[3], Float:Origin[3]; new Float:Damage = 0.0;

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

		//Loop:
		for (new i = 1; i <= GetMaxClients(); i++)
		{

			//Connected:
			if(IsClientConnected(i) && IsClientInGame(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", ClientOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, ClientOrigin);

				//In Distance:
				if(Dist <= 225 && IsTargetInLineOfSight(Ent, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					//Has Shield Near By:
					if(IsShieldInDistance(i))
					{

						//Shield Forward:
						OnClientShieldDamage(i, Damage);
					}

					//Override:
					else
					{

						//Check:
						if(GetClientHealth(i) - RoundFloat(Damage) <= 0)
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE);
						}

						//Override:
						else
						{

							//Damage Client:
							SDKHooks_TakeDamage(i, Ent, Ent, Damage, DMG_DISSOLVE & DMG_PREVENT_PHYSICS_FORCE);
						}
					}
				}
			}
		}

		//Declare:
		new Random = GetRandomInt(1, 25);

		//Check:
		if(Random == 1)
		{

			//Create Special Effect:
			CreateAntLionBomb(Ent, Origin);
		}
	}
}


public Action:DelayEffect(Handle:Timer, any:Ent)
{

	//Declare:
	new TempEnt = GetEntAttatchedEffect(Ent, 1);

	//Check & Is Alive::
	if(IsValidEdict(TempEnt))
	{

		//Accept:
		AcceptEntityInput(TempEnt, "TurnOn");

		AcceptEntityInput(TempEnt, "DoSpark");
	}
}

public Action:CreateAntLionBomb(Ent, Float:Origin[3])
{

	//Initulize:
	Origin[2] += 30;

	//Temp Ent Setup:
	TE_SetupGlowSprite(Origin, GlowBlue(), 5.0, 10.0, 100);

	//Send To All Clients:
	TE_SendToAll();

	//Emit:
	EmitAmbientSound(Sound, Origin, Ent, SNDLEVEL_NORMAL);

	//Declare:
	new EntHealth = GetEntHealth(Ent);

	new MaxHealth = GetEntMaxHealth(Ent);

	//Check:
	if(GetEntHealth(Ent) != GetEntMaxHealth(Ent))
	{

		if(EntHealth + 100 < MaxHealth)
		{

			//Set Health:
			SetEntHealth(Ent, (EntHealth + 100));
		}

		//Override:
		else
		{

			//Set Health:
			SetEntHealth(Ent, GetEntMaxHealth(Ent));
		}
	}
}
