//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hcacidtub_included_
  #endinput
#endif
#define _rp_hcacidtub_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//HcAcidTub:
static HcAcidTubEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:HcAcidTubFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static HcAcidTubHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:HcAcidTubModel[256] = "models/winningrook/gtav/meth/hcacid/hcacid.mdl";

initHcAcidTub()
{

	//Commands:
	RegAdminCmd("sm_testhcacidtub", Command_TestHcAcidTub, ADMFLAG_ROOT, "<Id> <Time> - Creates a HcAcidTub");
}

public initDefaultHcAcidTub(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		HcAcidTubEnt[Client][X] = -1;

		HcAcidTubHealth[Client][X] = 0;

		HcAcidTubFuel[Client][X] = 0.0;
	}
}

public bool:IsValidHcAcidTub(Ent)
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
				if(HcAcidTubEnt[i][X] == Ent)
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

public GetHcAcidTubIdFromEnt(Ent)
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
				if(HcAcidTubEnt[i][X] == Ent)
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

public HasClientHcAcidTub(Client, Id)
{

	//Is Valid:
	if(HcAcidTubEnt[Client][Id] > 0)
	{

		//Return:
		return HcAcidTubEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetHcAcidTubHealth(Client, Id)
{

	//Return:
	return HcAcidTubHealth[Client][Id];
}

public SetHcAcidTubHealth(Client, Id, Amount)
{

	//Initulize:
	HcAcidTubHealth[Client][Id] = Amount;
}

public Float:GetHcAcidTubFuel(Client, Id)
{

	//Return:
	return HcAcidTubFuel[Client][Id];
}

public SetHcAcidTubFuel(Client, Id, Float:Amount)
{

	//Initulize:
	HcAcidTubFuel[Client][Id] = Amount;
}

public Action:initHcAcidTubTime()
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
				if(IsValidEdict(HcAcidTubEnt[i][X]))
				{

					//Check:
					if(HcAcidTubHealth[i][X] <= 0 || HcAcidTubFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveHcAcidTub(i, X);
					}
				}
			}
		}
	}
}

public Action:HcAcidTubHud(Client, Ent)
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
				if(HcAcidTubEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Tub:\nBismoth Acid: %0.2fmL\nHealth: %i", HcAcidTubFuel[i][X], HcAcidTubHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveHcAcidTub(Client, X)
{

	//Initulize:
	HcAcidTubHealth[Client][X] = 0;

	HcAcidTubFuel[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(HcAcidTubEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(HcAcidTubEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(HcAcidTubEnt[Client][X], "kill");

	//Inituze:
	HcAcidTubEnt[Client][X] = -1;
}

public bool:CreateHcAcidTub(Client, Id, Float:Fuel, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - Unable to spawn HcAcidTub due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 17, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You have just spawned a HcAcidTub!");
	}

	//Initulize:
	HcAcidTubFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	HcAcidTubHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", HcAcidTubModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	HcAcidTubEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientHcAcidTub);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[Client][Id] / 2), (HcAcidTubHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestHcAcidTub(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testHcAcidTub <Id> <Fuel> <Health>");

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

	if(HcAcidTubEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money HcAcidTub with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid HcAcidTub %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create HcAcidTub:
	CreateHcAcidTub(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsHcAcidTubUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientHcAcidTub(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Fuel = 1500.0;

				//CreateHcAcidTub
				if(CreateHcAcidTub(Client, Y, Fuel, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-HcAcidTub|\x07FFFFFF - You already have too many HcAcidTub, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientHcAcidTub(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(HcAcidTubEnt[i][X] == Ent)
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
							if(HcAcidTubHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								HcAcidTubHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								HcAcidTubHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[i][X] / 2), (HcAcidTubHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientHcAcidTub(HcAcidTubEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientHcAcidTub(HcAcidTubEnt[i][X], Damage, Ent2);
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

public Action:DamageClientHcAcidTub(Ent, &Float:Damage, &Attacker)
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
				if(HcAcidTubEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) HcAcidTubHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (HcAcidTubHealth[i][X] / 2), (HcAcidTubHealth[i][X] / 2), 255);

					//Check:
					if(HcAcidTubHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 17, X);

						//Remove:
						RemoveHcAcidTub(i, X);
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

public bool:IsHcAcidTubInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(HcAcidTubEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, HcAcidTubEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}