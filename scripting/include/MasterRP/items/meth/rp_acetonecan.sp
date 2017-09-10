//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_acetonecan_included_
  #endinput
#endif
#define _rp_acetonecan_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//AcetoneCan:
static AcetoneCanEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:AcetoneCanGrams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static AcetoneCanHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:AcetoneCanModel[256] = "models/winningrook/gtav/meth/acetone/acetone.mdl";

initAcetoneCan()
{

	//Commands:
	RegAdminCmd("sm_testacetonecan", Command_TestAcetoneCan, ADMFLAG_ROOT, "<Id> <Time> - Creates a AcetoneCan");
}

public initDefaultAcetoneCan(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		AcetoneCanEnt[Client][X] = -1;

		AcetoneCanHealth[Client][X] = 0;

		AcetoneCanGrams[Client][X] = 0.0;
	}
}

public bool:IsValidAcetoneCan(Ent)
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
				if(AcetoneCanEnt[i][X] == Ent)
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

public GetAcetoneCanIdFromEnt(Ent)
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
				if(AcetoneCanEnt[i][X] == Ent)
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

public HasClientAcetoneCan(Client, Id)
{

	//Is Valid:
	if(AcetoneCanEnt[Client][Id] > 0)
	{

		//Return:
		return AcetoneCanEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetAcetoneCanHealth(Client, Id)
{

	//Return:
	return AcetoneCanHealth[Client][Id];
}

public SetAcetoneCanHealth(Client, Id, Amount)
{

	//Initulize:
	AcetoneCanHealth[Client][Id] = Amount;
}

public Float:GetAcetoneCanGrams(Client, Id)
{

	//Return:
	return AcetoneCanGrams[Client][Id];
}

public SetAcetoneCanGrams(Client, Id, Float:Amount)
{

	//Initulize:
	AcetoneCanGrams[Client][Id] = Amount;
}

public Action:initAcetoneCanTime()
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
				if(IsValidEdict(AcetoneCanEnt[i][X]))
				{

					//Check:
					if(AcetoneCanHealth[i][X] <= 0 || AcetoneCanGrams[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 18, X);

						//Remove:
						RemoveAcetoneCan(i, X);
					}
				}
			}
		}
	}
}

public Action:AcetoneCanHud(Client, Ent)
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
				if(AcetoneCanEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nAcetone: %0.2fg\nHealth: %i", AcetoneCanGrams[i][X], AcetoneCanHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveAcetoneCan(Client, X)
{

	//Initulize:
	AcetoneCanHealth[Client][X] = 0;

	AcetoneCanGrams[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(AcetoneCanEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(AcetoneCanEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(AcetoneCanEnt[Client][X], "kill");

	//Inituze:
	AcetoneCanEnt[Client][X] = -1;
}

public bool:CreateAcetoneCan(Client, Id, Float:Grams, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - Unable to spawn Acetone Can due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Grams);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 18, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You have just spawned a Acetone Can!");
	}

	//Initulize:
	AcetoneCanGrams[Client][Id] = Grams;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	AcetoneCanHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", AcetoneCanModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	AcetoneCanEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientAcetoneCan);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[Client][Id] / 2), (AcetoneCanHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestAcetoneCan(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testacetonecan <Id> <Grams> <Health>");

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

	if(AcetoneCanEnt[Client][Id] > 0)
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

	//Create AcetoneCan:
	CreateAcetoneCan(Client, Id, Grams, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsAcetoneCanUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientAcetoneCan(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Grams = 50.0;

				//CreateAcetoneCan
				if(CreateAcetoneCan(Client, Y, Grams, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-AcetoneCan|\x07FFFFFF - You already have too many Acetone Can, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientAcetoneCan(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(AcetoneCanEnt[i][X] == Ent)
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
							if(AcetoneCanHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								AcetoneCanHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								AcetoneCanHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[i][X] / 2), (AcetoneCanHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientAcetoneCan(AcetoneCanEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientAcetoneCan(AcetoneCanEnt[i][X], Damage, Ent2);
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

public Action:DamageClientAcetoneCan(Ent, &Float:Damage, &Attacker)
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
				if(AcetoneCanEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) AcetoneCanHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (AcetoneCanHealth[i][X] / 2), (AcetoneCanHealth[i][X] / 2), 255);

					//Check:
					if(AcetoneCanHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 18, X);

						//Remove:
						RemoveAcetoneCan(i, X);
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

public bool:IsAcetoneCanInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(AcetoneCanEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, AcetoneCanEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}