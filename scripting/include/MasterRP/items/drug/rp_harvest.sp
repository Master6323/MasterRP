//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_Plant_included_
  #endinput
#endif
#define _rp_Plant_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10
#define MAXPLANTDIED		1200

//Plant:
static PlantTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlantEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:Grams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlantOverGrownTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:PlantWater[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static IsPlanted[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlantType[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlantHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:PlantModel[256] = "models/pot/pot.mdl";

public Action:PluginInfo_Plant(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Plant!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPlants()
{

	//Commands:
	RegAdminCmd("sm_testplant", Command_TestPlant, ADMFLAG_ROOT, "<Id> <Time> - Creates a Plant");
}
public initDefaultPlants(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PlantEnt[Client][X] = -1;

		Grams[Client][X] = 0.0;

		PlantTime[Client][X] = 0;

		PlantOverGrownTime[Client][X] = 0;

		PlantWater[Client][X] = 0.0;

		IsPlanted[Client][X] = 0;

		PlantType[Client][X] = 0;

		PlantHealth[Client][X] = 0;
	}
}

public bool:IsValidPlant(Ent)
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
				if(PlantEnt[i][X] == Ent)
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

public GetPlantIdFromEnt(Ent)
{

	//Declare:
	new Result = -1;

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
				if(PlantEnt[i][X] == Ent)
				{

					//Initulize:
					Result = X;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}
public GetPlantOwnerFromEnt(Ent)
{

	//Declare:
	new Result = -1;

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
				if(PlantEnt[i][X] == Ent)
				{

					//Initulize:
					Result = i;

					//Stop:
					break;
				}
			}
		}
	}

	//Return:
	return Result;
}

public HasClientPlant(Client, Id)
{

	//Is Valid:
	if(PlantEnt[Client][Id] > 0)
	{

		//Return:
		return PlantEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetPlantTime(Client, Id)
{

	//Return:
	return PlantTime[Client][Id];
}

public SetPlantTime(Client, Id, Amount)
{

	//Return:
	PlantTime[Client][Id] = Amount;
}

public Float:GetPlantGrams(Client, Id)
{

	//Return:
	return Grams[Client][Id];
}

public SetPlantGrams(Client, Id, Float:Amount)
{

	//Initulize:
	Grams[Client][Id] = Amount;
}

public Float:GetPlantWaterLevel(Client, Id)
{

	//Return:
	return PlantWater[Client][Id];
}

public SetPlantWaterLevel(Client, Id, Float:Amount)
{

	//Initulize:
	PlantWater[Client][Id] = Amount;
}

public GetPlantHealth(Client, Id)
{

	//Return:
	return PlantHealth[Client][Id];
}

public SetPlantHealth(Client, Id, Amount)
{

	//Initulize:
	return PlantHealth[Client][Id];
}

public GetIsPlanted(Client, Id)
{

	//Return:
	return IsPlanted[Client][Id];
}

public SetIsPlanted(Client, Id, Amount)
{

	//Initulize:
	IsPlanted[Client][Id] = Amount;
}

public GetPlantType(Client, Id)
{

	//Return:
	return PlantType[Client][Id];
}

public SetPlantType(Client, Id, Amount)
{

	//Initulize:
	return PlantType[Client][Id];
}

public Action:OnPlantUse(Client, Ent)
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
						if(PlantEnt[i][X] == Ent)
						{


							//Check:
							if(IsPlanted[i][X] == 1)
							{

								//Is Cop:
								if(IsCop(Client))
								{

									//Remove From DB:
									RemoveSpawnedItem(i, 1, X);

									//Remove:
									RemovePlant(i, X);

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Plant|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Drug Plant!", Client);

									//Initulize:
									SetBank(Client, (GetBank(Client) + 2500));

									//Set Menu State:
									BankState(Client, 2500);

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You have just destroyed a Drug Plant. reseaved €\x0732CD32500\x07FFFFFF!");

									//Initulize:
									SetCopExperience(Client, (GetCopExperience(Client) + 2));
								}

								//Is Valid:
								else if(PlantTime[i][X] == 1)
								{
	
									//Declare:
									new Earns = RoundFloat(Grams[i][X]);

									//Initulize:
									SetHarvest(Client, (GetHarvest(Client) + Earns));

									//Is Client Own:
									if(Client == i)
									{

										//Print:
										CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You have collected \x0732CD32%0.2fg\x07FFFFFF Grams from your Plant!", Grams[i][X]);
									}

									//Override:
									else
									{

										//Print:
										CPrintToChat(i, "\x07FF4040|RP-Plant|\x07FFFFFF - %N has stolen your Plant!", Client);

										CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You have Stolen €\x0732CD32%0.2fg\x07FFFFFF from this Plant!", Grams[i][X]);
									}

									//Remove From DB:
									RemoveSpawnedItem(i, 1, X);

									//Remove:
									RemovePlant(i, X);
								}

								//Override:
								else	
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - Plant not ready to harvest. (\x0732CD32%i\x07FFFFFF) Seconds left!", PlantTime[i][X]);
								}
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Drug|\x07FFFFFF - There are no seeds in this pot to grow!");
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
			CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Plant!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public Action:initPlantTime()
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
				if(IsValidEdict(PlantEnt[i][X]))
				{

					//Check:
					CheckPlantToLamp(i, X);

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(PlantEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Valid:
					if((StrContains(GetJob(i), "Drug Lord", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)))
					{

						//Check:
						if(IsPlanted[i][X] == 1)
						{

							//Is Valid:
							if(PlantTime[i][X] > 1)
							{

								//Initulize:
								PlantTime[i][X] -= 1;

								//Grow:
								if(PlantTime[i][X] == 700)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage2.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 600)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage3.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 500)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage4.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 400)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage5.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 300)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage6.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 200)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage7.mdl");
								}

								//Grow:
								if(PlantTime[i][X] == 100)
								{

									//Set Entity Model:
									SetEntityModel(PlantEnt[i][X],  "models/pot/pot_stage8.mdl");
								}

								//Declare:
								new Random = GetRandomInt(1, 3);

								//Valid:
								if(Random == 1)
								{

									//Initulize:
									new Float:AddedGrams = GetRandomFloat(2.0, (4.0 + (float(PlantType[i][X]) / 2)) + (float(PlantType[i][X]) / 5));

									//Max Drugs:
									if(Grams[i][X] + AddedGrams <= 2000.0 && PlantWater[i][X] > 0.0)
									{

										//Initulize:
										Grams[i][X] += AddedGrams;

										//Check:
										if(PlantWater[i][X] > 0.0)
										{

											//Initulize:
											PlantWater[i][X] -= (AddedGrams / 10.0);

											//Check:
											if(PlantWater[i][X] < 0.0) PlantWater[i][X] = 0.0;
										}
									}
								}
							}

							//Is Plant Fully Grown:
							if(PlantTime[i][X] == 1)
							{

								//Initulize:
								PlantOverGrownTime[i][X] += 1;

								//Dying effect:
								if(PlantOverGrownTime[i][X] == (MAXPLANTDIED / 2))
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Plant|\x07FFFFFF - Your Drug Plants are dying!");
								}

								//Dying effect:
								if(PlantOverGrownTime[i][X] > (MAXPLANTDIED / 2))
								{

									//Declare:
									new Random = GetRandomInt(1, 4);

									//Check:
									if(Random == 1)
									{

										//Initulize:
										Grams[i][X] -= 1.0;
									}
								}

								//Check:
								if(PlantOverGrownTime[i][X] >= MAXPLANTDIED)
								{
	
									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Plant|\x07FFFFFF - Your Plant has died and you lost €\x0732CD32%ig\x07FFFFFF!", Grams[i][X]);

									//Remove From DB:
									RemoveSpawnedItem(i, 1, X);

									//Remove:
									RemovePlant(i, X);
								}
							}
						}

						//Show CrimeHud:
						ShowIllegalItemToCops(EntOrigin);
					}
				}
			}
		}
	}
}

//Check to see if the Lamp is in distance
public Action:CheckPlantToLamp(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidLamp(X) && IsInDistance(PlantEnt[Client][Y], X))
			{

				//Declare:
				new i = GetLampOwnerFromEnt(X);

				new Id = GetLampIdFromEnt(X);		

				//Check:
				if(IsPlanted[Client][Y] == 1 && GetIsLampOn(i, Id))
				{

					//Is Valid:
					if(PlantTime[Client][Y] > 1)
					{

						//Declare:
						new Random = GetRandomInt(1, 6);

						//Valid:
						if(Random == 1)
						{

							//Initulize:
							new Float:AddedGrams = GetRandomFloat(2.0, (4.0 + (float(PlantType[Client][Y]) / 2)) + (float(PlantType[Client][Y]) / 5));

							//Max Drugs:
							if(Grams[Client][Y] + AddedGrams <= 2000.0 && PlantWater[Client][Y] > 0.0)
							{

								//Initulize:
								Grams[Client][Y] += AddedGrams;

								//Check:
								if(PlantWater[Client][Y] > 0.0)
								{

									//Initulize:
									PlantWater[Client][Y] -= (AddedGrams / 10.0);

									//Check:
									if(PlantWater[Client][Y] < 0.0) PlantWater[Client][Y] = 0.0;
								}

								//Stop:
								break;
							}
						}
					}
				}
			}
		}
	}
}
public Action:PlantHud(Client, Ent)
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
				if(PlantEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Is Plant Ready:
					if(IsPlanted[i][X] == 0)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Plant:\nHas no seed to grow anything!\nHealth: %i", PlantHealth[i][X]);
					}

					//Is Plant Ready:
					else if(PlantTime[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Plant:\nIs Now ready to Harvest\nGrams (%0.2fg)\nHealth: %i", Grams[i][X], PlantHealth[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Plant:\nFinishes Growing in %i Sec\nPlant Wanter: %.2f Percent\nGrams (%0.2fg)\nHealth: %i", PlantTime[i][X], PlantWater[i][X], Grams[i][X], PlantHealth[i][X]);
					}

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemovePlant(Client, X)
{

	//Initulize:
	PlantTime[Client][X] = 0;

	Grams[Client][X] = 0.0;

	PlantOverGrownTime[Client][X] = 0;

	PlantWater[Client][X] = 0.0;

	IsPlanted[Client][X] = 0;

	PlantType[Client][X] = 0;

	PlantHealth[Client][X] = 0;


	//Accept:
	AcceptEntityInput(PlantEnt[Client][X], "kill");

	//Inituze:
	PlantEnt[Client][X] = -1;
}

public bool:CreatePlant(Client, Id, Time, Float:Value, Float:Water, Planted, Type, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - Unable to spawn Drug Plant due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f^%f^%i", Water, Value, Health);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 1, Id, Time, Planted, Type, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You have just spawned a Money Plant!");
	}

	//Initulize:
	PlantTime[Client][Id] = Time;

	Grams[Client][Id] = Value;

	PlantWater[Client][Id] = Water;

	PlantOverGrownTime[Client][Id] = 0;

	IsPlanted[Client][Id] = Planted;

	PlantType[Client][Id] = Type;

	PlantHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", PlantModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PlantEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPlant);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (PlantHealth[Client][Id] / 2), (PlantHealth[Client][Id] / 2), 255);

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestPlant(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - Usage: sm_testplant <Id> <Time> <Planted>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sTime[32], String:sPlanted[32]; new Id, Time, Planted;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sTime, sizeof(sTime));

	//Initialize:
	GetCmdArg(3, sPlanted, sizeof(sPlanted));

	Id = StringToInt(sId);

	Time = StringToInt(sTime);

	Planted = StringToInt(sPlanted);

	if(PlantEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You have already created a money Plant with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - Invalid Plant %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreatePlant
	CreatePlant(Client, Id, Time, 0.0, 100.0, Planted, 1, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsPlantUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - Cops can't use any illegal items.");
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
		MaxSlots += GetItemAmount(Client, 300);

		//Check:
		if(MaxSlots > MAXITEMSPAWN)
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
			Ent = HasClientPlant(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Plant:
				if(CreatePlant(Client, Y, 0, 0.0, 100.0, 0, 0, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Plant|\x07FFFFFF - You already have too many Printers, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}
//Event Damage:
public Action:OnDamageClientPlant(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PlantEnt[i][X] == Ent)
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
							if(PlantHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PlantHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PlantHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PlantHealth[i][X] / 2), (PlantHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPlant(PlantEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPlant(PlantEnt[i][X], Damage, Ent2);
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

public Action:DamageClientPlant(Ent, &Float:Damage, &Attacker)
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
				if(PlantEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PlantHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PlantHealth[i][X] / 2), (PlantHealth[i][X] / 2), 255);

					//Check:
					if(PlantHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 1, X);

						//Remove:
						RemovePlant(i, X);
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
