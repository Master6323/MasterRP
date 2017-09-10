//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_npcichthyosaur_included_
  #endinput
#endif
#define _rp_npcichthyosaur_included_

initNpcichthyosaur()
{

	//NPC Management:
	RegAdminCmd("sm_testichthyosaur", Command_CreateNpcIchthyosaur, ADMFLAG_ROOT, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");
}

//Create NPC:
public Action:Command_CreateNpcIchthyosaur(Client, Args)
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

	CreateNpcIchthyosaur("npc_ichthyosaur", "null", Position, Angles);

	//Return:
	return Plugin_Handled;
}

public Action:PluginInfo_NpcIchthyosaur(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Game Description Changer!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

public CreateNpcIchthyosaur(String:sNpc[], String:Model[], Float:Position[3], Float:Angles[3])
{

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Return:
		return -1;
	}

	//Declare:
	//decl String:sNpc[64];

	//Format:
	//Format(sNpc, sizeof(sNpc), "npc_%s", Npc);	

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
		SetVariantString("player D_HT");
		AcceptEntityInput(NPC, "setrelationship");

		//Return:
		return NPC;
	}

	//Return:
	return -1;
}
