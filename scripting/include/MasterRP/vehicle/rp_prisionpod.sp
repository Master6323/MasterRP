//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).
///////////////////////////////////////////////////////////////////////////////
///////////////////////// Masters Car Mod v1.0.01 /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_prisionpod_included_
  #endinput
#endif
#define _rp_prisionpod_included_

initPrisionPod()
{

	//Command:
    	RegAdminCmd("sm_createprisionpod", Command_PrisionPod, ADMFLAG_SLAY, "Creates an Entity");
}

public Action:Command_PrisionPod(Client,Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command is disabled v.i console.");

		//Return:
		return Plugin_Handled;
	}

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:ClientOrigin[3], Float:Origin[3], Float:EyeAngles[3];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	Origin[0] = (ClientOrigin[0] + (FloatMul(150.0, Cosine(DegToRad(EyeAngles[1])))));

	Origin[1] = (ClientOrigin[1] + (FloatMul(150.0, Sine(DegToRad(EyeAngles[1])))));

	Origin[2] = (ClientOrigin[2] + 100);

	EyeAngles[0] = 0.0;

	EyeAngles[1] = 0.0;

	EyeAngles[2] = 0.0;

	//Declare:
	new Ent = CreateEntityByName("prop_vehicle_prisoner_pod");


	//Dispatch:
	DispatchKeyValue(Ent, "physdamagescale", "1.0");


	DispatchKeyValue(Ent, "model", "models/props_combine/breenpod_inner.mdl");


	DispatchKeyValue(Ent, "vehiclescript", "scripts/vehicles/prisoner_pod.txt");


	//Spawn
	DispatchSpawn(Ent);


	//Teleport:
	TeleportEntity(Ent, Origin, NULL_VECTOR, NULL_VECTOR);

	//Set Physics:
	SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);   

	//Return:
	return Plugin_Handled;
}
