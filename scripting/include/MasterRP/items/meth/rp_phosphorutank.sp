//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_phosphorutank_included_
  #endinput
#endif
#define _rp_phosphorutank_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//PhosphoruTank:
static PhosphoruTankEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:PhosphoruTankFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PhosphoruTankHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static bool:PhosphoruTankIsRunning[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:PhosphoruTankModel[256] = "models/winningrook/gtav/meth/phosphoru/phosphoru.mdl";

public Action:PluginInfo_PhosphoruTank(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "PhosphoruTank!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPhosphoruTank()
{

	//Commands:
	RegAdminCmd("sm_testphosphorutank", Command_TestPhosphoruTank, ADMFLAG_ROOT, "<Id> <Time> - Creates a PhosphoruTank");
}

public initDefaultPhosphoruTank(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PhosphoruTankEnt[Client][X] = -1;

		PhosphoruTankHealth[Client][X] = 0;

		PhosphoruTankFuel[Client][X] = 0.0;

		PhosphoruTankIsRunning[Client][X] = false;
	}
}

public bool:IsValidPhosphoruTank(Ent)
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
				if(PhosphoruTankEnt[i][X] == Ent)
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

public GetPhosphoruTankIdFromEnt(Ent)
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
				if(PhosphoruTankEnt[i][X] == Ent)
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

public HasClientPhosphoruTank(Client, Id)
{

	//Is Valid:
	if(PhosphoruTankEnt[Client][Id] > 0)
	{

		//Return:
		return PhosphoruTankEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetPhosphoruTankHealth(Client, Id)
{

	//Return:
	return PhosphoruTankHealth[Client][Id];
}

public SetPhosphoruTankHealth(Client, Id, Amount)
{

	//Initulize:
	PhosphoruTankHealth[Client][Id] = Amount;
}

public Float:GetPhosphoruTankFuel(Client, Id)
{

	//Return:
	return PhosphoruTankFuel[Client][Id];
}

public SetPhosphoruTankFuel(Client, Id, Float:Amount)
{

	//Initulize:
	PhosphoruTankFuel[Client][Id] = Amount;
}

public Action:OnPhosphoruTankUse(Client, Ent)
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
						if(PhosphoruTankEnt[i][X] == Ent)
						{

							//Check:
							if(PhosphoruTankIsRunning[i][X])
							{

								//Initulize:
								PhosphoruTankIsRunning[i][X] = false;
							}

							//Override:
							else
							{

								//Initulize:
								PhosphoruTankIsRunning[i][X] = true;
							}

							//Emit Sound:
							EmitSoundToClient(Client, "buttons/lightswitch2.wav");
						}
					}
				}
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Phosphoru Tank!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public Action:initPhosphoruTankTime()
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
				if(IsValidEdict(PhosphoruTankEnt[i][X]))
				{

					//Check:
					if(PhosphoruTankHealth[i][X] > 0 && PhosphoruTankHealth[i][X] <= 100)
					{

						//Declare:
						new Float:EntOrigin[3];

						//Initulize:
						GetEntPropVector(PhosphoruTankEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

						//CreateDamage:
						ExplosionDamage(i, PhosphoruTankEnt[i][X], EntOrigin, DMG_BURN);

						//Declare:
						new Random = GetRandomInt(1, 5);

						//Check:
						if(Random <= 2)
						{

							//Initulize:
							PhosphoruTankHealth[i][X] -= Random;
						}
					}

					//Check:
					if(PhosphoruTankHealth[i][X] <= 0 || PhosphoruTankFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 15, X);

						//Remove:
						RemovePhosphoruTank(i, X, true);
					}

					//Check:
					if(PhosphoruTankHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 15, X);

						//Remove:
						RemovePhosphoruTank(i, X, false);
					}
				}
			}
		}
	}
}

public Action:PhosphoruTankHud(Client, Ent)
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
				if(PhosphoruTankEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tank:\nPhosphoru Acid: %0.2fL\nHealth: %i", PhosphoruTankFuel[i][X], PhosphoruTankHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemovePhosphoruTank(Client, X, bool:Result)
{

	//Initulize:
	PhosphoruTankHealth[Client][X] = 0;

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result)
	{

		//Declare:
		new Float:PhosphoruTankOrigin[3];

		//Get Prop Data:
		GetEntPropVector(PhosphoruTankEnt[Client][X], Prop_Send, "m_vecOrigin", PhosphoruTankOrigin);

		//Temp Ent:
		TE_SetupSparks(PhosphoruTankOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(PhosphoruTankOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Check:
	if(IsValidAttachedEffect(PhosphoruTankEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(PhosphoruTankEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(PhosphoruTankEnt[Client][X], "kill");

	//Inituze:
	PhosphoruTankEnt[Client][X] = -1;
}

public bool:CreatePhosphoruTank(Client, Id, Float:Fuel, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - Unable to spawn PhosphoruTank due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 15, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - You have just spawned a PhosphoruTank!");
	}

	//Initulize:
	PhosphoruTankFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	PhosphoruTankHealth[Client][Id] = Health;

	PhosphoruTankIsRunning[Client][Id] = true;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", PhosphoruTankModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PhosphoruTankEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPhosphoruTank);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (PhosphoruTankHealth[Client][Id] / 2), (PhosphoruTankHealth[Client][Id] / 2), 255);

	//Check:
	if(PhosphoruTankHealth[Client][Id] > 0 && PhosphoruTankHealth[Client][Id] <= 100)
	{

		//Initulize Effects:
		new Effect = CreateEnvFire(PhosphoruTankEnt[Client][Id], "null", "200", "700", "0", "Natural");

		SetEntAttatchedEffect(PhosphoruTankEnt[Client][Id], 1, Effect);
	}

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestPhosphoruTank(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testPhosphorutank <Id> <Fuel> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sFuel[32], String:sHealth[32]; new Id, Float:Fuel, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sFuel, sizeof(sFuel));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Fuel = StringToFloat(sFuel);

	Health = StringToInt(sHealth);

	if(PhosphoruTankEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money PhosphoruTank with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid PhosphoruTank %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create PhosphoruTank:
	CreatePhosphoruTank(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsPhosphoruTankUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientPhosphoruTank(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Fuel = 80.0;

				//CreatePhosphoruTank
				if(CreatePhosphoruTank(Client, Y, Fuel, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-PhosphoruTank|\x07FFFFFF - You already have too many PhosphoruTank, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientPhosphoruTank(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PhosphoruTankEnt[i][X] == Ent)
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
							if(PhosphoruTankHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PhosphoruTankHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PhosphoruTankHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PhosphoruTankHealth[i][X] / 2), (PhosphoruTankHealth[i][X] / 2), 255);

							//Check:
							if(PhosphoruTankHealth[i][X] > 100)
							{

								//Declare:
								new TempEnt = GetEntAttatchedEffect(PhosphoruTankEnt[i][X], 1);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Kill:
									AcceptEntityInput(TempEnt, "kill");

									//Initulize:
									SetEntAttatchedEffect(TempEnt, 1, -1);
								}
							}
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPhosphoruTank(PhosphoruTankEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPhosphoruTank(PhosphoruTankEnt[i][X], Damage, Ent2);
					}
				}

				//Check:
				if(PhosphoruTankHealth[i][X] > 100)
				{

					//Declare:
					new TempEnt = GetEntAttatchedEffect(PhosphoruTankEnt[i][X], 1);

					//Check:
					if(IsValidEdict(TempEnt))
					{

						//Kill:
						AcceptEntityInput(TempEnt, "kill");

						//Initulize:
						SetEntAttatchedEffect(TempEnt, 1, -1);
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

public Action:DamageClientPhosphoruTank(Ent, &Float:Damage, &Attacker)
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
				if(PhosphoruTankEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PhosphoruTankHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(PhosphoruTankHealth[i][X] > 0 && PhosphoruTankHealth[i][X] <= 100)
					{

						//Declare:
						new TempEnt = GetEntAttatchedEffect(PhosphoruTankEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt))
						{

							//Explode:
							CreateExplosion(Attacker, PhosphoruTankEnt[i][X]);

							//Check:
							if(PhosphoruTankEnt[i][X] > 0 )
							{

								//Initulize Effects:
								new Effect = CreateEnvFire(PhosphoruTankEnt[i][X], "null", "200", "700", "0", "Natural");

								SetEntAttatchedEffect(PhosphoruTankEnt[i][X], 1, Effect);
							}
						}
					}

					//Check:
					if(PhosphoruTankHealth[i][X] > 100)
					{

						//Declare:
						new TempEnt = GetEntAttatchedEffect(PhosphoruTankEnt[i][X], 1);

						//Check:
						if(IsValidEdict(TempEnt))
						{

							//Kill:
							AcceptEntityInput(TempEnt, "kill");

							//Initulize:
							SetEntAttatchedEffect(TempEnt, 1, -1);
						}
					}

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PhosphoruTankHealth[i][X] / 2), (PhosphoruTankHealth[i][X] / 2), 255);

					//Check:
					if(PhosphoruTankHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 15, X);

						//Remove:
						RemovePhosphoruTank(i, X, true);
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

public bool:IsPhosphoruTankInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PhosphoruTankEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PhosphoruTankEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}