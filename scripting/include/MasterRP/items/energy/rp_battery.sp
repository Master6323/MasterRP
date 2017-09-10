//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_Battery_included_
  #endinput
#endif
#define _rp_Battery_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Battery:
static BatteryEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:BatteryEnergy[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static BatteryHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:BatteryModel[256] = "models/Items/car_battery01.mdl";

initBattery()
{

	//Commands:
	RegAdminCmd("sm_testbattery", Command_TestBattery, ADMFLAG_ROOT, "<Id> <Time> - Creates a Battery");
}

public initDefaultBattery(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BatteryEnt[Client][X] = -1;

		BatteryHealth[Client][X] = 0;

		BatteryEnergy[Client][X] = 0.0;
	}
}

public bool:IsValidBattery(Ent)
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
				if(BatteryEnt[i][X] == Ent)
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

public GetBatteryIdFromEnt(Ent)
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
				if(BatteryEnt[i][X] == Ent)
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
public GetBatteryOwnerFromEnt(Ent)
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
				if(BatteryEnt[i][X] == Ent)
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

public HasClientBattery(Client, Id)
{

	//Is Valid:
	if(BatteryEnt[Client][Id] > 0)
	{

		//Return:
		return BatteryEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetBatteryHealth(Client, Id)
{

	//Return:
	return BatteryHealth[Client][Id];
}

public SetBatteryHealth(Client, Id, Amount)
{

	//Initulize:
	BatteryHealth[Client][Id] = Amount;
}

public Float:GetBatteryEnergy(Client, Id)
{

	//Return:
	return BatteryEnergy[Client][Id];
}

public SetBatteryEnergy(Client, Id, Float:Amount)
{

	//Initulize:
	BatteryEnergy[Client][Id] = Amount;
}

public Action:initBatteryTime()
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
				if(IsValidEdict(BatteryEnt[i][X]))
				{

					//Check:
					CheckGeneratorToBattery(i, X);

					//Check:
					if(BatteryHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 23, X);

						//Remove:
						RemoveBattery(i, X, true);
					}
				}
			}
		}
	}
}

//Check to see if the generator is in distance
public Action:CheckGeneratorToBattery(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidGenerator(X) && IsInDistance(BatteryEnt[Client][Y], X))
			{

				//Declare:
				new Id = GetGeneratorIdFromEnt(X);

				//Check:
				if(GetGeneratorEnergy(Client, Id) - 0.10 > 0)
				{

					//Initulize:
					SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.05));

					//Check:
					if(BatteryEnergy[Client][Y] < 500)
					{

						//Declare:
						new Float:AddEnergy = GetRandomFloat(0.25, 0.35);

						//Initulize:
						SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - AddEnergy));

						BatteryEnergy[Client][Y] += AddEnergy;

						//Check:
						if(AddEnergy > 500)
						{

							//Initulize:
							BatteryEnergy[Client][Y] = 500.0;
						}
					}

					//Stop:
					break;
				}
			}
		}
	}
}

public Action:BatteryHud(Client, Ent)
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
				if(BatteryEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Battery:\nEnergy: %0.2fWz\nHealth: %i", BatteryEnergy[i][X], BatteryHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveBattery(Client, X, bool:Result)
{

	//Initulize:
	BatteryHealth[Client][X] = 0;

	BatteryEnergy[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(BatteryEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BatteryEnt[Client][X]);
	}

	//Check:
	if(Result == true)
	{

		//Explode:
		CreateExplosion(Client, BatteryEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(BatteryEnt[Client][X], "kill");

	//Inituze:
	BatteryEnt[Client][X] = -1;
}

public bool:CreateBattery(Client, Id, Float:Energy, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
		Position[0] = (ClientOrigin[0] + (FloatMul(100.0, Cosine(DegToRad(EyeAngles[1])))));

		Position[1] = (ClientOrigin[1] + (FloatMul(100.0, Sine(DegToRad(EyeAngles[1])))));

		Position[2] = (ClientOrigin[2] + 100);

		Angle = EyeAngles;

		//Check:
		if(TR_PointOutsideWorld(Position))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - Unable to spawn Acetone Can due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Energy);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 23, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You have just spawned a Acetone Can!");
	}

	//Initulize:
	BatteryEnergy[Client][Id] = Energy;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BatteryHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BatteryModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BatteryEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBattery);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BatteryHealth[Client][Id] / 2), (BatteryHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestBattery(Client, Args)
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
	if(Args < 3)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testBattery <Id> <Energy> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sEnergy[32], String:sHealth[32]; new Id, Float:Energy, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sEnergy, sizeof(sEnergy));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Energy = StringToFloat(sEnergy);

	Health = StringToInt(sHealth);

	if(BatteryEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Acetone Can with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Acetone Can %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Battery:
	CreateBattery(Client, Id, Energy, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsBatteryUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		new MaxSlots = 1;

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
			Ent = HasClientBattery(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Energy = 0.0;

				//CreateBattery
				if(CreateBattery(Client, Y, Energy, 500, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You already have too many Acetone Can, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientBattery(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BatteryEnt[i][X] == Ent)
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
							if(BatteryHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BatteryHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BatteryHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BatteryHealth[i][X] / 2), (BatteryHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBattery(BatteryEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBattery(BatteryEnt[i][X], Damage, Ent2);
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

public Action:DamageClientBattery(Ent, &Float:Damage, &Attacker)
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
				if(BatteryEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BatteryHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BatteryHealth[i][X] / 2), (BatteryHealth[i][X] / 2), 255);

					//Check:
					if(BatteryHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 23, X);

						//Remove:
						RemoveBattery(i, X, true);
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

public bool:IsBatteryInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BatteryEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BatteryEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}