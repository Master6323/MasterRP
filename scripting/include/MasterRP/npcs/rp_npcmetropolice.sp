//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcmetropolice_included_
  #endinput
#endif
#define _rp_npcmetropolice_included_

public Action:PluginInfo_NpcMetroPolice(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "MetroPolice NPC!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initNpcMetroPolice()
{

	//NPC Beta:
	RegAdminCmd("sm_testmetropolice", Command_CreateNpcMetroPolice, ADMFLAG_ROOT, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");

	//Entity Event Hook:
	HookEntityOutput("npc_metropolice", "OnDeath", OnMetroPoliceDied);
}

//Event Damage:
public Action:OnMetroPoliceDamageClient(Client, &attacker, &inflictor, &Float:damage, &damageType)
{

	//Initialize:
	damage = GetRandomFloat(25.0, 35.0);

	damageType = DMG_DISSOLVE;
}

//Event Damage:
public Action:OnClientDamageMetroPolice(Ent, &Client, &inflictor, &Float:damage, &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Initulize:
		AddDamage(Client, damage);
	}

	//Declare:
	decl String:Classname[64];

	//Initialize:
	GetEdictClassname(Client, Classname, sizeof(Classname));

	if(!StrEqual(Classname, "npc_antlionguard"))
	{
		//Initulize:
		damageType = DMG_DISSOLVE;
	}

	//Return:
	return Plugin_Changed;
}

//Ant Lion Died Event:
public OnMetroPoliceDied(const String:Output[], Caller, Activator, Float:Delay)
{

	//Is Valid:
	if(IsValidEdict(Activator))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has took out the MetroPolice!", Activator);
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

	SetNpcsOnMap((GetNpcsOnMap() - 1));
}

//Create NPC:
public Action:Command_CreateNpcMetroPolice(Client, Args)
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

	CreateNpcMetroPolice("null", Position, Angles, 200);

	//Return:
	return Plugin_Handled;
}

public CreateNpcMetroPolice(String:Model[], Float:Position[3], Float:Angles[3], Health)
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Initialize:
	new NPC = CreateEntityByName("npc_MetroPolice");

	//Is Valid:
	if(NPC > 0)
	{

		DispatchKeyValue(NPC, "name", "npc_MetroPolice");

		DispatchKeyValue(NPC, "weapons", "SMG1");

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
		SetVariantString("npc_antlionguard D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Set Prop:
		SetEntProp(NPC, Prop_Data, "m_iHealth", Health);

		//Damage Hook:
		SDKHook(NPC, SDKHook_OnTakeDamage, OnClientDamageMetroPolice);

		//Initulize:
		SetNpcsOnMap((GetNpcsOnMap() + 1));

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
