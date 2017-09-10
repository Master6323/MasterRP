//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcDog_included_
  #endinput
#endif
#define _rp_npcDog_included_

public Action:PluginInfo_NpcDog(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Dog NPC!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initNpcDog()
{

	//NPC Beta:
	RegAdminCmd("sm_testdog", Command_CreateNpcDog, ADMFLAG_ROOT, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");

	//Entity Event Hook:
	HookEntityOutput("npc_dog", "OnDeath", OnDogDied);
}

//Event Damage:
public Action:OnDogDamageClient(Client, &attacker, &inflictor, &Float:damage, &damageType)
{

	//Initialize:
	damage = GetRandomFloat(10.0, 15.0);
}

//Event Damage:
public Action:OnClientDamageDog(Ent, &Client, &inflictor, &Float:damage, &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public OnDogDied(const String:Output[], Caller, Activator, Float:Delay)
{

	//Is Valid:
	if(IsValidEdict(Activator))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out the Dog!", Activator);
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

	//Remove Ragdoll:
	EntityDissolve(Caller, 1);

	//Initulize:
	SetIsCritical(Caller, false);
}

//Create NPC:
public Action:Command_CreateNpcDog(Client, Args)
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
	GetClientAbsOrigin(Client, Position);

	CreateNpcDog("npc_dog", "null", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public CreateNpcDog(String:sNpc[], String:Model[], Float:Position[3], Float:Angles[3], Health)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	new NPC = CreateEntityByName(sNpc);

	//Is Valid:
	if(NPC > 0)
	{

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
		SetVariantString("player D_LI");
		AcceptEntityInput(NPC, "setrelationship");

		SetVariantString("player");
		AcceptEntityInput(NPC, "Name");

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageDog);

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
