//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_benzocaine_included_
  #endinput
#endif
#define _rp_benzocaine_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Benzocaine:
static BenzocaineEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:BenzocaineGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static BenzocaineHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:BenzocaineModel[256] = "models/props_lab/jar01a.mdl";

initBenzocaine()
{

	//Commands:
	RegAdminCmd("sm_testbenzocaine", Command_TestBenzocaine, ADMFLAG_ROOT, "<Id> <Time> - Creates a Benzocaine");
}

public initDefaultBenzocaine(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BenzocaineEnt[Client][X] = -1;

		BenzocaineHealth[Client][X] = 0;

		BenzocaineGrams[Client][X] = 0.0;
	}
}

public bool:IsValidBenzocaine(Ent)
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
				if(BenzocaineEnt[i][X] == Ent)
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

public GetBenzocaineIdFromEnt(Ent)
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
				if(BenzocaineEnt[i][X] == Ent)
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

public HasClientBenzocaine(Client, Id)
{

	//Is Valid:
	if(BenzocaineEnt[Client][Id] > 0)
	{

		//Return:
		return BenzocaineEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetBenzocaineHealth(Client, Id)
{

	//Return:
	return BenzocaineHealth[Client][Id];
}

public SetBenzocaineHealth(Client, Id, Amount)
{

	//Initulize:
	BenzocaineHealth[Client][Id] = Amount;
}

public Float:GetBenzocaineGrams(Client, Id)
{

	//Return:
	return BenzocaineGrams[Client][Id];
}

public SetBenzocaineGrams(Client, Id, Float:Amount)
{

	//Initulize:
	BenzocaineGrams[Client][Id] = Amount;
}

public Action:initBenzocaineTime()
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
				if(IsValidEdict(BenzocaineEnt[i][X]))
				{

					//Check:
					if(BenzocaineHealth[i][X] <= 0 || BenzocaineGrams[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 22, X);

						//Remove:
						RemoveBenzocaine(i, X);
					}
				}
			}
		}
	}
}

public Action:BenzocaineHud(Client, Ent)
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
				if(BenzocaineEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Bottle:\nBenzocaine: %0.2fg\nHealth: %i", BenzocaineGrams[i][X], BenzocaineHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveBenzocaine(Client, X)
{

	//Initulize:
	BenzocaineHealth[Client][X] = 0;

	BenzocaineGrams[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(BenzocaineEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BenzocaineEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(BenzocaineEnt[Client][X], "kill");

	//Inituze:
	BenzocaineEnt[Client][X] = -1;
}

public bool:CreateBenzocaine(Client, Id, Float:Grams, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Benzocaine|\x07FFFFFF - Unable to spawn Benzocaine due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Grams);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 22, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Benzocaine|\x07FFFFFF - You have just spawned a Benzocaine!");
	}

	//Initulize:
	BenzocaineGrams[Client][Id] = Grams;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BenzocaineHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BenzocaineModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BenzocaineEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBenzocaine);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BenzocaineHealth[Client][Id] / 2), (BenzocaineHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestBenzocaine(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testBenzocaine <Id> <Grams> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sGrams[32], String:sHealth[32]; new Id, Float:Grams, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sGrams, sizeof(sGrams));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Grams = StringToFloat(sGrams);

	Health = StringToInt(sHealth);

	if(BenzocaineEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Benzocaine with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Benzocaine %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Benzocaine:
	CreateBenzocaine(Client, Id, Grams, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsBenzocaineUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Benzocaine|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Benzocaine|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientBenzocaine(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Grams = 1500.0;

				//CreateBenzocaine
				if(CreateBenzocaine(Client, Y, Grams, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Benzocaine|\x07FFFFFF - You already have too many Benzocaine, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientBenzocaine(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BenzocaineEnt[i][X] == Ent)
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
							if(BenzocaineHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BenzocaineHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BenzocaineHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BenzocaineHealth[i][X] / 2), (BenzocaineHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBenzocaine(BenzocaineEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBenzocaine(BenzocaineEnt[i][X], Damage, Ent2);
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

public Action:DamageClientBenzocaine(Ent, &Float:Damage, &Attacker)
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
				if(BenzocaineEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BenzocaineHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BenzocaineHealth[i][X] / 2), (BenzocaineHealth[i][X] / 2), 255);

					//Check:
					if(BenzocaineHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 22, X);

						//Remove:
						RemoveBenzocaine(i, X);
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

public bool:IsBenzocaineInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BenzocaineEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BenzocaineEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}