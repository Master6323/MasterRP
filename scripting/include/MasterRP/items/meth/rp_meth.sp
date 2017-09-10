//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_meth_included_
  #endinput
#endif
#define _rp_meth_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Meth:
static MethEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:Grams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static MethHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:MethModel[256] = "models/srcocainelab/portablestove.mdl";

public Action:PluginInfo_Meth(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Meth!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initMeths()
{

	//Commands:
	RegAdminCmd("sm_testmeth", Command_TestMeth, ADMFLAG_ROOT, "<Id> <Time> - Creates a Meth");
}

public initDefaultMeths(Client)
{
	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		MethEnt[Client][X] = -1;

		MethHealth[Client][X] = -1;

		Grams[Client][X] = 0.0;
	}
}

public bool:IsValidMeth(Ent)
{

	//Declare:
	new bool:Result = false;

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(new X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(MethEnt[i][X] == Ent)
				{

					//Initulize:
					Result = true;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public HasClientMeth(Client, Id)
{

	//Is Valid:
	if(MethEnt[Client][Id] > 0)
	{

		//Return:
		return MethEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetMethHealth(Client, Id)
{

	//Return:
	return MethHealth[Client][Id];
}

public Float:GetMethGrams(Client, Id)
{

	//Return:
	return Grams[Client][Id];
}

public Action:OnMethUse(Client, Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
	{

		//Is In Time:
		if(GetLastPressedE(Client) > (GetGameTime() - 1.5))
		{

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Loop:
					for(new X = 1; X < MAXITEMSPAWN; X++)
					{

						//Is Valid:
						if(MethEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 3, X);

								//Remove:
								RemoveMeth(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Meth|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Kitchen!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You have just destroyed a Kitchen. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(Grams[i][X] > 0.0)
							{
	
								//Declare:
								new Float:Earns = Grams[i][X];

								//Initulize:
								SetMeth(Client, RoundFloat(float(GetMeth(Client)) + Earns));

								Grams[i][X] = 0.0;
	
								//Is Client Own:
								if(Client == i)
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You have collected €\x0732CD32%0.2f\x07FFFFFF from your Kitchen!", Earns);
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Meth|\x07FFFFFF - %N has stolen from your Kitchen!", Client);

									CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You have Stolen €\x0732CD32%0.2f\x07FFFFFF from this Kitchen!", Earns);
								}	
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - Kitchen Hasn't cooked up any meth yet!");
							}
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Kitchen!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initMethTime()
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(new X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(IsValidEdict(MethEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(MethEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Valid:
					if((StrContains(GetJob(i), "Meth Technician", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)))
					{

						//Check:
						CheckMethItemsToMethKitchen(i, X, EntOrigin);
					}

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

public Action:MethHud(Client, Ent)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(new X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(MethEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Meth:\nGrams (%0.2fg)\nHealth: %i", Grams[i][X], MethHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveMeth(Client, X)
{

	//Initulize:
	Grams[Client][X] = 0.0;

	MethHealth[Client][X] = 0;

	//Accept:
	AcceptEntityInput(MethEnt[Client][X], "kill");

	//Inituze:
	MethEnt[Client][X] = -1;
}

public bool:CreateMeth(Client, Id, Float:Value, Health, Float:Position[3], Float:Angle[3], bool:Connected)
{

	//Check:
	if(Connected == false)
	{

		//Declare:
		new Float:ClientOrigin[3], Float:EyeAngles[3];

		//Initialize:
		GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

		//Initialize:
  		GetClientEyeAngles(Client, EyeAngles);

		//Initialize:
		Position[0] = (ClientOrigin[0] + (FloatMul(50.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(50.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 100);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - Unable to spawn Kitchen due to outside of world");

			//Return:
			return false;
		}

		//Declare
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Value);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 3, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You have just spawned a Meth Kitchen!");
	}

	//Initulize:
	MethHealth[Client][Id] = Health;

	Grams[Client][Id] = Value;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", MethModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

	//Initulize:
	MethEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientMeth);

	//Is Valid:
	if(StrContains(GetJob(Client), "Meth Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestMeth(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//No Valid Charictors:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testmeth <Id> <grams>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sGrams[32]; new Id, Float:Grams1;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sGrams, sizeof(sGrams));

	Id = StringToInt(sId);

	Grams1 = StringToFloat(sGrams);

	if(MethEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Meth with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Meth %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateMeth
	CreateMeth(Client, Id, Grams1, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsMethUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		new MaxSlots = 1;

		//Valid Job:
		if(StrContains(GetJob(Client), "Drug Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 1;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 2;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Initulize:
			MaxSlots = 3;
		}

		//Valid Job:
		if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Initulize:
			MaxSlots = 5;
		}

		//Add Extra Slots:
		MaxSlots += GetItemAmount(Client, 301);

		//Check:
		if(MaxSlots > GetItemAmount(Client, 301))
		{

			//Initulize:
			MaxSlots = MAXITEMSPAWN;
		}

		//Declare:
		new Float:ClientOrigin[3], Float:EyeAngles[3];

		//Initulize:
		GetClientAbsOrigin(Client, ClientOrigin);

		GetClientEyeAngles(Client, EyeAngles);

		//Declare:
		new Ent = -1; new Float:Position[3];

		//Loop:
		for(new Y = 1; Y <= MaxSlots; Y++)
		{

			//Initulize:
			Ent = HasClientMeth(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Meth:
				if(CreateMeth(Client, Y, 0.0, 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + StringToInt(GetItemVar(ItemId))));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Meth|\x07FFFFFF - You already have too many Meth Kitchens, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Check to see if the Required Items is in distance
public Action:CheckMethItemsToMethKitchen(Client, Y, Float:EntOrigin[3])
{

	//Declare:
	new Propane = CheckPropaneTankDistanceToMethLab(Client, Y);

	new Phosphoru = CheckPhosphoruTankDistanceToMethLab(Client, Y);

	new Acetone = CheckAcetoneCanDistanceToMethLab(Client, Y);

	new Acid = CheckHcAcidTubDistanceToMethLab(Client, Y);

	new Sodium = CheckSodiumTubDistanceToMethLab(Client, Y);

	//Check:
	if(Propane > 0 && Phosphoru > 0 && Acetone > 0 && Acid > 0 && Sodium > 0)
	{

		//Declare:
		new Id = GetPropaneTankIdFromEnt(Propane);

		new Float:UsedFuel = GetRandomFloat(0.5, 0.4);

		SetPropaneTankFuel(Client, Id, (GetPropaneTankFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetPhosphoruTankIdFromEnt(Phosphoru);

		UsedFuel = GetRandomFloat(0.01, 0.009);

		SetPhosphoruTankFuel(Client, Id, (GetPhosphoruTankFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetAcetoneCanIdFromEnt(Acetone);

		new Float:UsedGrams = GetRandomFloat(0.05, 0.01);

		SetAcetoneCanGrams(Client, Id, (GetAcetoneCanGrams(Client, Id) - UsedGrams));

		//Declare:
		Id = GetSodiumTubIdFromEnt(Sodium);

		UsedGrams = GetRandomFloat(0.1, 0.05);

		SetSodiumTubGrams(Client, Id, (GetSodiumTubGrams(Client, Id) - UsedGrams));

		//Declare:
		Id = GetHcAcidTubIdFromEnt(Acid);

		UsedGrams = GetRandomFloat(1.5, 1.2);

		SetHcAcidTubFuel(Client, Id, (GetHcAcidTubFuel(Client, Id) - UsedGrams));

		//Declare:
		new Random = GetRandomInt(1, 3);

		//Valid:
		if(Random == 1)
		{

			//Initulize:
			new Float:AddGrams = GetRandomFloat(2.0, 4.0);

			//Initulize:
			Grams[Client][Y] += AddGrams;
		}

		//EntCheck:
		if(CheckMapEntityCount() < 2000)
		{

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, Smoke(), 3.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, Smoke(), 3.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, SmokeNew(), 2.0, 30);

			//Send:
			TE_SendToAll();

			//Temp Ent:
			TE_SetupSmoke(EntOrigin, SmokeNew(), 2.0, 30);

			//Send:
			TE_SendToAll();
		}
	}
}



//Check to see if the Propane Tank is in distance
public CheckPropaneTankDistanceToMethLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidPropaneTank(X) && IsInDistance(MethEnt[Client][Y], X))
			{

				//Return:
				return X;
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the generator is in distance
public CheckPhosphoruTankDistanceToMethLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidPhosphoruTank(X) && IsInDistance(MethEnt[Client][Y], X))
			{

				//Return:
				return X;
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the Acetone Can is in distance
public CheckAcetoneCanDistanceToMethLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidAcetoneCan(X) && IsInDistance(MethEnt[Client][Y], X))
			{

				//Return:
				return X;
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the HcAcid Tub is in distance
public CheckHcAcidTubDistanceToMethLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidHcAcidTub(X) && IsInDistance(MethEnt[Client][Y], X))
			{

				//Return:
				return X;
			}
		}
	}

	//Return:
	return -1;
}

//Check to see if the HcAcid Tub is in distance
public CheckSodiumTubDistanceToMethLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidSodiumTub(X) && IsInDistance(MethEnt[Client][Y], X))
			{

				//Return:
				return X;
			}
		}
	}

	//Return:
	return -1;
}

//Event Damage:
public Action:OnDamageClientMeth(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(MethEnt[i][X] == Ent)
			{

				//Check:
				if(Ent2 > 0 && Ent2 <= GetMaxClients() && IsClientConnected(Ent2))
				{

					//Check:
					if(Ent2 == i)
					{

						//Declare:
						decl String:WeaponName[32];

						//Initulize;
						GetClientWeapon(Ent2, WeaponName, sizeof(WeaponName));

						//Is Crowbar:
						if(StrContains(WeaponName, "weapon_crowbar", false) == 0)
						{

							//Initulize:
							if(MethHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								MethHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								MethHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (MethHealth[i][X] / 2), (MethHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientMeth(MethEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientMeth(MethEnt[i][X], Damage, Ent2);
					}
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public Action:DamageClientMeth(Ent, &Float:Damage, &Attacker)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//Loop:
			for(new X = 1; X < MAXITEMSPAWN; X++)
			{

				//Is Valid:
				if(MethEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) MethHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (MethHealth[i][X] / 2), (MethHealth[i][X] / 2), 255);

					//Check:
					if(MethHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 3, X);

						//Remove:
						RemoveMeth(i, X);
					}

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool:IsMethInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(MethEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, MethEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}