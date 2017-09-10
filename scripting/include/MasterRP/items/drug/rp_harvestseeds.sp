//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_harvestseeds_included_
  #endinput
#endif
#define _rp_harvestseeds_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Seeds:
static SeedsEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static SeedsType[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static SeedsHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:SeedsModel[256] = "models/katharsmodels/contraband/zak_wiet/zak_seed.mdl";

initSeeds()
{

	//Commands:
	RegAdminCmd("sm_testseeds", Command_TestSeeds, ADMFLAG_ROOT, "<Id> - Creates a Seeds");
}

public initDefaultSeeds(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		SeedsEnt[Client][X] = -1;

		SeedsHealth[Client][X] = 0;

		SeedsType[Client][X] = 0;
	}
}

public bool:IsValidSeeds(Ent)
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
				if(SeedsEnt[i][X] == Ent)
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

public GetSeedsIdFromEnt(Ent)
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
				if(SeedsEnt[i][X] == Ent)
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

public GetSeedsOwnerFromEnt(Ent)
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
				if(SeedsEnt[i][X] == Ent)
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

public HasClientSeeds(Client, Id)
{

	//Is Valid:
	if(SeedsEnt[Client][Id] > 0)
	{

		//Return:
		return SeedsEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetSeedsHealth(Client, Id)
{

	//Return:
	return SeedsHealth[Client][Id];
}

public SetSeedsHealth(Client, Id, Amount)
{

	//Initulize:
	SeedsHealth[Client][Id] = Amount;
}

public GetSeedsType(Client, Id)
{

	//Return:
	return SeedsType[Client][Id];
}

public SetSeedsFuel(Client, Id, Amount)
{

	//Initulize:
	SeedsType[Client][Id] = Amount;
}

public Action:initSeedsTime()
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
				if(IsValidEdict(SeedsEnt[i][X]))
				{

					//Check:
					if(SeedsHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 19, X);

						//Remove:
						RemoveSeeds(i, X);
					}
				}
			}
		}
	}
}

public Action:SeedsHud(Client, Ent)
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
				if(SeedsEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Normal Seeds:
					if(SeedsType[i][X] == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Drug Seeds:\nHealth: %i", SeedsHealth[i][X]);
					}

					//GMO Seeds
					if(SeedsType[i][X] == 2)
					{

						//Format:

						Format(FormatMessage, sizeof(FormatMessage), "GMO Drug Seeds:\nHealth: %i", SeedsHealth[i][X]);
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

public Action:RemoveSeeds(Client, X)
{

	//Initulize:
	SeedsHealth[Client][X] = 0;

	SeedsType[Client][X] = 0;

	//Accept:
	AcceptEntityInput(SeedsEnt[Client][X], "kill");

	//Inituze:
	SeedsEnt[Client][X] = -1;
}

public bool:CreateSeeds(Client, Id, Type, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - Unable to spawn Seeds due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 19, Id, 0, Type, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You have just spawned a Seeds!");
	}

	//Initulize:
	SeedsType[Client][Id] = Type;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	SeedsHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", SeedsModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	SeedsEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientSeeds);

	//Touch Hook:
	SDKHook(Ent, SDKHook_StartTouch, OnSeedsStartTouch);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (SeedsHealth[Client][Id] / 2), (SeedsHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestSeeds(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testSeeds <Id> <type> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sType[32], String:sHealth[32]; new Id, Type, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sType, sizeof(sType));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Type = StringToInt(sType);

	Health = StringToInt(sHealth);

	if(SeedsEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Seeds with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Seeds %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Seeds:
	CreateSeeds(Client, Id, Type, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsSeedsUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		new MaxSlots = 1;

		//Declare:
		new Var = StringToInt(GetItemVar(ItemId));

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
			Ent = HasClientSeeds(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateSeeds
				if(CreateSeeds(Client, Y, Var, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Seeds|\x07FFFFFF - You already have too many Seeds, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientSeeds(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(SeedsEnt[i][X] == Ent)
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
							if(SeedsHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								SeedsHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								SeedsHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (SeedsHealth[i][X] / 2), (SeedsHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientSeeds(SeedsEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientSeeds(SeedsEnt[i][X], Damage, Ent2);
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

public Action:DamageClientSeeds(Ent, &Float:Damage, &Attacker)
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
				if(SeedsEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) SeedsHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (SeedsHealth[i][X] / 2), (SeedsHealth[i][X] / 2), 255);

					//Check:
					if(SeedsHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveSeeds(i, X);
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

public bool:IsSeedsInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(SeedsEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, SeedsEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

//On Entity Touch:
public OnSeedsStartTouch(Ent, OtherEnt)
{

	//Valid Drug Plant:
	if(IsValidPlant(OtherEnt))
	{

		//Declare:
		new Client = GetPlantOwnerFromEnt(OtherEnt);

		new Id = GetPlantIdFromEnt(OtherEnt);

		//Check:
		if(GetIsPlanted(Client, Id) == 0)
		{

			//Declare:
			new Client2 = GetSeedsOwnerFromEnt(Ent);

			new Id2 = GetSeedsIdFromEnt(Ent);

			//Initulize:
			SetIsPlanted(Client, Id, 1);

			SetPlantTime(Client, Id, 800);

			SetPlantType(Client, Id, SeedsType[Client2][Id2]);

			//Remove From DB:
			RemoveSpawnedItem(Client2, 19, Id2);

			//Remove:
			RemoveSeeds(Client2, Id2);

			//Set Crime:
			SetCrime(Client, (GetCrime(Client) + 1000));
		}
	}
}