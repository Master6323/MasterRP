//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).
///////////////////////////////////////////////////////////////////////////////
///////////////////////// Masters Car Mod v1.0.01 /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

/** Double-include prevention */
#if defined _rp_carmod_included_
  #endinput
#endif
#define _rp_carmod_included_

static Float:CurrentEyeAngle[MAXPLAYERS + 1][3];

initCarMod()
{

	//Beta
	RegAdminCmd("sm_cartest", CommandCarsTest, ADMFLAG_ROOT, "test");

	//Beta
	RegAdminCmd("sm_exitcar", Command_ExitCars, ADMFLAG_ROOT, "test");
}

public Action:OnClientPreThinkVehicleViewFix(Client)
{

	//Declare:
	new WasInVehicle[MAXPLAYERS + 1] = {0,...};

	new InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle == -1)
	{

		//Is Valid:
		if(WasInVehicle[Client] != 0)
		{

			//Is Valid:
			if(IsValidEdict(WasInVehicle[Client]))
			{

				//Initulize:
				SendConVarValue(Client, FindConVar("sv_Client_predict"), "1");

				//Set Ent:
				SetEntProp(WasInVehicle[Client], Prop_Send, "m_iTeamNum", 0);
			}

			//Initulize:
			WasInVehicle[Client] = 0;
		}

		//Return:
		return;
	}
	
	// "m_bEnterAnimOn" is the culprit for vehicles controlling all players views.
	// this is the earliest it can be changed, also stops vehicle starting..
	if(GetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn") == 1)
	{

		//Initulize:
		WasInVehicle[Client] = InVehicle;

		//Declare:
		new Float:FaceFront[3] = {0.0, 90.0, 0.0};

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, FaceFront, NULL_VECTOR);

		//Set Ent:
		SetEntProp(InVehicle, Prop_Send, "m_bEnterAnimOn", 0);
		
		// stick the player in the correct view position if they're stuck in and enter animation.
		SetEntProp(InVehicle, Prop_Send, "m_nSequence", 0);
		
		// set the vehicles team so team mates can't destroy it.
		new DriverTeam = GetEntProp(Client, Prop_Send, "m_iTeamNum");
		SetEntProp(InVehicle, Prop_Send, "m_iTeamNum", DriverTeam);

		//Accept:
		AcceptEntityInput(InVehicle, "Lock");

		//Loop:
		for(new players = 1; players <= MaxClients; players++) 
		{

			//Is Valid:
			if(IsClientInGame(players) && IsPlayerAlive(players))
			{

				//Not Player:
				if(players != Client)
				{

					//Teleport:
					TeleportEntity(players, NULL_VECTOR, CurrentEyeAngle[players], NULL_VECTOR);
				}
			}
		}

		//Initulize:
		SendConVarValue(Client, FindConVar("sv_Client_predict"), "0");
	}

	//Override:
	else
	{

		//Accept:
		AcceptEntityInput(InVehicle, "TurnOn");
	}

	if(GetThirdPersonView(Client))
	{

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, CurrentEyeAngle[Client], NULL_VECTOR);
	}
}

public Action:OnVehicleUse(Client)
{

	//Declare:
	new InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle != -1)
	{

		//Declare:
		new Ent = GetClientAimTarget(Client, false);

		//Check:
		if(IsValidEdict(Ent) && Ent == InVehicle)
		{

			//Declare:
			new String:ClassName[30];

			//Initulize:
			GetEdictClassname(Ent, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual("prop_vehicle_driveable", ClassName, false) || StrEqual("prop_vehicle_prisoner_pod", ClassName, false))
			{

				//Exit
				ExitVehicle(Client, InVehicle, 0);
			}
		}
	}

}

ExitVehicle(client, vehicle, force=0)
{

	//Declare:
	new Float:ExitPoint[3];

	//Force:
	if (!force)
	{

		// check left.
		if (!IsExitClear(client, vehicle, 90.0, ExitPoint))
		{

			// check right.
			if (!IsExitClear(client, vehicle, -90.0, ExitPoint))
			{

				// check front.
				if (!IsExitClear(client, vehicle, 0.0, ExitPoint))
				{

					// check back.
					if (!IsExitClear(client, vehicle, 180.0, ExitPoint))
					{

						// check above the vehicle.
						new Float:ClientEye[3];

						//Initulize:
						GetClientEyePosition(client, ClientEye);

						//Declare:
						new Float:ClientMinHull[3];

						new Float:ClientMaxHull[3];

						//Initulize:
						GetEntPropVector(client, Prop_Send, "m_vecMins", ClientMinHull);

						GetEntPropVector(client, Prop_Send, "m_vecMaxs", ClientMaxHull);

						//Declare:
						new Float:TraceEnd[3];

						//Initulize:
						TraceEnd = ClientEye;
						TraceEnd[2] += 500.0;

						//Trace:
						TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, client);

						//Declare:
						new Float:CollisionPoint[3];

						//Check:
						if (TR_DidHit())
						{

							//Get Ent Position:
							TR_GetEndPosition(CollisionPoint);
						}

						//Override:
						else
						{

							//Initulize:
							CollisionPoint = TraceEnd;
						}

						//Trace
						TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

						//Declare:
						new Float:VehicleEdge[3];

						//En:
						TR_GetEndPosition(VehicleEdge);
						
						new Float:ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

						//Check:
						if (ClearDistance >= 100.0)
						{
							ExitPoint = VehicleEdge;
							ExitPoint[2] += 100.0;
							
							if (TR_PointOutsideWorld(ExitPoint))
							{
								CPrintToChat(client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF No safe exit point found!!!!!");
								return;
							}
						}
						else
						{
							CPrintToChat(client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF No safe exit point found!!!!!");
							return;
						}
					}
				}
			}
		}
	}
	else
	{
		GetClientAbsOrigin(client, ExitPoint);
	}
	
	AcceptEntityInput(client, "ClearParent");
	
	SetEntPropEnt(client, Prop_Send, "m_hVehicle", -1);
	
	SetEntPropEnt(vehicle, Prop_Send, "m_hPlayer", -1);
	
	SetEntityMoveType(client, MOVETYPE_WALK);
	
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
	
	new hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
	
	new EntEffects = GetEntProp(client, Prop_Send, "m_fEffects");
	EntEffects &= ~32;
	SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);

	//Declare:
	new String:ClassName[30];

	//Initulize:
	GetEdictClassname(vehicle, ClassName, sizeof(ClassName));

	//Is Valid:
	if(StrEqual("prop_vehicle_driveable", ClassName, false))
	{

		SetEntProp(vehicle, Prop_Send, "m_nSpeed", 0);
		SetEntPropFloat(vehicle, Prop_Send, "m_flThrottle", 0.0);
	}

	new Float:ExitAng[3];
	
	GetEntPropVector(vehicle, Prop_Data, "m_angRotation", ExitAng);
	ExitAng[0] = 0.0;
	ExitAng[1] += 90.0;
	ExitAng[2] = 0.0;

	TeleportEntity(client, ExitPoint, ExitAng, NULL_VECTOR);
}

// checks if 100 units away from the edge of the Vehicle in the given direction is clear.
bool:IsExitClear(Client, Vehicle, Float:direction, Float:exitpoint[3])
{

	//Declare:
	new Float:ClientEye[3], Float:VehicleAngle[3], Float:ClientMinHull[3], Float:ClientMaxHull[3], Float:DirectionVec[3];

	//Initulize:
	GetClientEyePosition(Client, ClientEye);

	GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", VehicleAngle);

	GetEntPropVector(Client, Prop_Send, "m_vecMins", ClientMinHull);

	GetEntPropVector(Client, Prop_Send, "m_vecMaxs", ClientMaxHull);

	//Math:
	VehicleAngle[0] = 0.0;
	VehicleAngle[2] = 0.0;
	VehicleAngle[1] += direction;
	
	//Initulize:
	GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);

	//Scale:
	ScaleVector(DirectionVec, -500.0);

	//Declare:
	new Float:TraceEnd[3], Float:CollisionPoint[3], Float:VehicleEdge[3];

	//Add:
	AddVectors(ClientEye, DirectionVec, TraceEnd);

	//Trace:
	TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, Client);

	//Found End:
	if(TR_DidHit())
	{

		//Get End Point:
		TR_GetEndPosition(CollisionPoint);
	}

	//Override:
	else
	{

		//Initulize:
		CollisionPoint = TraceEnd;
	}

	//Trace:
	TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);

	//Get End Point:
	TR_GetEndPosition(VehicleEdge);

	//Declare:
	new Float:ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);

	//Is Valid:
	if(ClearDistance >= 100.0)
	{

		//Math:
		MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
		NormalizeVector(DirectionVec, DirectionVec);
		ScaleVector(DirectionVec, 100.0);
		AddVectors(VehicleEdge, DirectionVec, exitpoint);

		//Can Spawn:
		if(TR_PointOutsideWorld(exitpoint))
		{

			//Return:
			return false;
		}

		//Override:
		else
		{

			//Return:
			return true;
		}
	}

	//Override:
	else
	{

		//Return:
		return false;
	}
}

public bool:DontHitClientOrVehicle(entity, contentsMask, any:data)
{

	//Declare:
	new InVehicle = GetEntPropEnt(data, Prop_Send, "m_hVehicle");

	//Return:
	return ((entity != data) && (entity != InVehicle));
}

public bool:RayDontHitClient(entity, contentsMask, any:data)
{
	return (entity != data);
}

public SpawnVehicle(Client, Float:spawnorigin[3], Float:spawnangles[3], skin, client, const String:Model[], const String:Script[], type)
{

	new VehicleIndex = CreateEntityByName("prop_vehicle_driveable");
	if (VehicleIndex == -1)
	{
		PrintToServer("|RP-vehicleMod|: could not create vehicle entity");
		return;
	}
	
	new String:TargetName[10];
	Format(TargetName, sizeof(TargetName), "%i",VehicleIndex);
	DispatchKeyValue(VehicleIndex, "targetname", TargetName);
	
	DispatchKeyValue(VehicleIndex, "model", Model);
	DispatchKeyValue(VehicleIndex, "vehiclescript", Script);
	
	SetEntProp(VehicleIndex, Prop_Send, "m_nSolidType", 6);
	
	if (skin == -1)
	{
		skin = 1;
	}
	
	SetEntProp(VehicleIndex, Prop_Send, "m_nSkin", skin);
	
	if (type == 1)
	{
		SetEntProp(VehicleIndex, Prop_Data, "m_nVehicleType", 8);
	}
	
	DispatchSpawn(VehicleIndex);
	ActivateEntity(VehicleIndex);
	
	// stops the vehicle rolling back when it is spawned.
	SetEntProp(VehicleIndex, Prop_Data, "m_nNextThinkTick", -1);
	SetEntProp(VehicleIndex, Prop_Data, "m_bHasGun", 0);

	// anti flip, not 100% effective.
	new PhysIndex = CreateEntityByName("phys_ragdollconstraint");
	
	if (PhysIndex == -1)
	{
		AcceptEntityInput(VehicleIndex, "Kill");
		
		PrintToServer("|RP-vehicleMod|: could not create anti flip entity");
		return;
	}
	
	DispatchKeyValue(PhysIndex, "spawnflags", "2");
	DispatchKeyValue(PhysIndex, "ymin", "-50.0");
	DispatchKeyValue(PhysIndex, "ymax", "50.0");
	DispatchKeyValue(PhysIndex, "zmin", "-180.0");
	DispatchKeyValue(PhysIndex, "zmax", "180.0");
	DispatchKeyValue(PhysIndex, "xmin", "-50.0");
	DispatchKeyValue(PhysIndex, "xmax", "50.0");
	
	DispatchKeyValue(PhysIndex, "attach1", TargetName);
	
	DispatchSpawn(PhysIndex);
	ActivateEntity(PhysIndex);
	
	SetVariantString(TargetName);
	AcceptEntityInput(PhysIndex, "SetParent");
	
	TeleportEntity(PhysIndex, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);

	// check if theres space to spawn the vehicle.
	new Float:MinHull[3];
	new Float:MaxHull[3];
	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMins", MinHull);
	GetEntPropVector(VehicleIndex, Prop_Send, "m_vecMaxs", MaxHull);
	
	new Float:temp;
	
	temp = MinHull[0];
	MinHull[0] = MinHull[1];
	MinHull[1] = temp;
	
	temp = MaxHull[0];
	MaxHull[0] = MaxHull[1];
	MaxHull[1] = temp;
	
	if (client == 0)
	{
		TR_TraceHull(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID);
	}
	else
	{
		TR_TraceHullFilter(spawnorigin, spawnorigin, MinHull, MaxHull, MASK_SOLID, RayDontHitClient, client);
	}
	
	if (TR_DidHit())
	{
		AcceptEntityInput(VehicleIndex, "Kill");
		
		PrintToServer("|RP-vehicleMod|: spawn coordinates not clear");
		return;
	}
	
	TeleportEntity(VehicleIndex, spawnorigin, spawnangles, NULL_VECTOR);

	SetEntProp(VehicleIndex, Prop_Data, "m_takedamage", 0);

	// force players in.
	if (client != 0)
	{
		AcceptEntityInput(VehicleIndex, "use", client);
	}

	AcceptEntityInput(VehicleIndex, "TurnOn", client);
}

//Create NPC:
public Action:CommandCarsTest(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	new Float:EyeAng[3], Float:SpawnOrigin[3], Float:Origin[3];

	//Initulize:
	GetClientEyeAngles(Client, EyeAng);

	//Initulize:
	GetClientEyePosition(Client, Origin);

	//Initialize:
	SpawnOrigin[0] = (Origin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAng[1])))));

	SpawnOrigin[1] = (Origin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAng[1])))));

	SpawnOrigin[2] = (Origin[2] + 100);

	SpawnVehicle(Client, SpawnOrigin, EyeAng, 1, 0, "models/blodia/buggy.mdl", "scripts/vehicles/buggy_edit.txt", 0);
	//SpawnVehicle(Client, SpawnOrigin, SpawnAngles, 1, Client, "models/supra.mdl", "scripts/vehicles/supra.txt", 0);

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF - You have spawned a test jeep");

	//Return:
	return Plugin_Handled;
}

//Create NPC:
public Action:Command_ExitCars(Client, Args)
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
	new InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");

	//Is In Car:
	if(InVehicle != -1)
	{

		//Exit
		ExitVehicle(Client, InVehicle, 0);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-VehicleMod|\x07FFFFFF - You have exited the car");
	}

	//Return:
	return Plugin_Handled;
}