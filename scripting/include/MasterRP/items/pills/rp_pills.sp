//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_pills_included_
  #endinput
#endif
#define _rp_pills_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Pills:
static PillsEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:Grams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PillsHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:PillsModel[256] = "models/srcocainelab/portablestove.mdl";

public Action:PluginInfo_Pills(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Pills!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPills()
{

	//Commands:
	RegAdminCmd("sm_testpills", Command_TestPills, ADMFLAG_ROOT, "<Id> <Time> - Creates a Pills");
}

public initDefaultPills(Client)
{
	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PillsEnt[Client][X] = -1;

		PillsHealth[Client][X] = -1;

		Grams[Client][X] = 0.0;
	}
}

public bool:IsValidPills(Ent)
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
				if(PillsEnt[i][X] == Ent)
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

public HasClientPills(Client, Id)
{

	//Is Valid:
	if(PillsEnt[Client][Id] > 0)
	{

		//Return:
		return PillsEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetPillsHealth(Client, Id)
{

	//Return:
	return PillsHealth[Client][Id];
}

public Float:GetPillsGrams(Client, Id)
{

	//Return:
	return Grams[Client][Id];
}

public Action:OnPillsUse(Client, Ent)
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
						if(PillsEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 3, X);

								//Remove:
								RemovePills(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Pills|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Kitchen!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have just destroyed a Kitchen. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(Grams[i][X] > 0.0)
							{
	
								//Declare:
								new Float:Earns = Grams[i][X];

								//Initulize:
								SetPills(Client, RoundFloat(float(GetPills(Client)) + Earns));

								Grams[i][X] = 0.0;
	
								//Is Client Own:
								if(Client == i)
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have collected €\x0732CD32%0.2f\x07FFFFFF from your Kitchen!", Earns);
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Pills|\x07FFFFFF - %N has stolen from your Kitchen!", Client);

									CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have Stolen €\x0732CD32%0.2f\x07FFFFFF from this Kitchen!", Earns);
								}	
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Kitchen Hasn't cooked up any Pills yet!");
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
			CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Kitchen!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initPillsTime()
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
				if(IsValidEdict(PillsEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(PillsEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Valid:
					if((StrContains(GetJob(i), "Pills Technician", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)))
					{

						//Check:
						CheckPillsItemsToPillsKitchen(i, X, EntOrigin);
					}

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

public Action:PillsHud(Client, Ent)
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
				if(PillsEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Pills:\nGrams (%0.2fg)\nHealth: %i", Grams[i][X], PillsHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemovePills(Client, X)
{

	//Initulize:
	Grams[Client][X] = 0.0;

	PillsHealth[Client][X] = 0;

	//Accept:
	AcceptEntityInput(PillsEnt[Client][X], "kill");

	//Inituze:
	PillsEnt[Client][X] = -1;
}

public bool:CreatePills(Client, Id, Float:Value, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Unable to spawn Kitchen due to outside of world");

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
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You have just spawned a Pills Kitchen!");
	}

	//Initulize:
	PillsHealth[Client][Id] = Health;

	Grams[Client][Id] = Value;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", PillsModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

	//Initulize:
	PillsEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPills);

	//Is Valid:
	if(StrContains(GetJob(Client), "Pills Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestPills(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testpills <Id> <grams>");

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

	if(PillsEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Pills with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Pills %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreatePills
	CreatePills(Client, Id, Grams1, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsPillsUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientPills(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Pills:
				if(CreatePills(Client, Y, 0.0, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Pills|\x07FFFFFF - You already have too many Pills Kitchens, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Check to see if the Required Items is in distance
public Action:CheckPillsItemsToPillsKitchen(Client, Y, Float:EntOrigin[3])
{

	//Declare:
	new Propane = CheckPropaneTankDistanceToPillsLab(Client, Y);

	new Ammonia = CheckAmmoniaDistanceToPillsLab(Client, Y);

	new SAcidTub = CheckSAcidTubDistanceToPillsLab(Client, Y);

	new Toulene = CheckTouleneDistanceToPillsLab(Client, Y);

	//Check:
	if(Propane > 0 && Ammonia > 0 && SAcidTub > 0 && Toulene > 0)
	{

		//Declare:
		new Id = GetPropaneTankIdFromEnt(Propane);

		new Float:UsedFuel = GetRandomFloat(0.5, 0.4);

		SetPropaneTankFuel(Client, Id, (GetPropaneTankFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetAmmoniaIdFromEnt(Ammonia);

		new Float:UsedGrams = GetRandomFloat(0.5, 0.4);

		SetAmmoniaGrams(Client, Id, (GetAmmoniaGrams(Client, Id) - UsedGrams));

		//Declare:
		Id = GetSAcidTubIdFromEnt(SAcidTub);

		UsedFuel = GetRandomFloat(0.01, 0.009);

		SetSAcidTubFuel(Client, Id, (GetSAcidTubFuel(Client, Id) - UsedFuel));

		//Declare:
		Id = GetTouleneIdFromEnt(Toulene);

		UsedFuel = GetRandomFloat(0.1, 0.05);

		SetTouleneFuel(Client, Id, (GetTouleneFuel(Client, Id) - UsedFuel));

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
public CheckPropaneTankDistanceToPillsLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidPropaneTank(X) && IsInDistance(PillsEnt[Client][Y], X))
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
public CheckAmmoniaDistanceToPillsLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidAmmonia(X) && IsInDistance(PillsEnt[Client][Y], X))
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
public CheckSAcidTubDistanceToPillsLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidSAcidTub(X) && IsInDistance(PillsEnt[Client][Y], X))
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
public CheckTouleneDistanceToPillsLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidToulene(X) && IsInDistance(PillsEnt[Client][Y], X))
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
public Action:OnDamageClientPills(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PillsEnt[i][X] == Ent)
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
							if(PillsHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PillsHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PillsHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PillsHealth[i][X] / 2), (PillsHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPills(PillsEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPills(PillsEnt[i][X], Damage, Ent2);
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

public Action:DamageClientPills(Ent, &Float:Damage, &Attacker)
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
				if(PillsEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PillsHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PillsHealth[i][X] / 2), (PillsHealth[i][X] / 2), 255);

					//Check:
					if(PillsHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 3, X);

						//Remove:
						RemovePills(i, X);
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

public bool:IsPillsInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PillsEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PillsEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}