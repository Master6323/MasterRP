//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_erythroxylum_included_
  #endinput
#endif
#define _rp_erythroxylum_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Erythroxylum:
static ErythroxylumEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:ErythroxylumFuel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static ErythroxylumHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:ErythroxylumModel[256] = "models/props_junk/glassjug01.mdl";

initErythroxylum()
{

	//Commands:
	RegAdminCmd("sm_testerythroxylum", Command_TestErythroxylum, ADMFLAG_ROOT, "<Id> <Time> - Creates a Erythroxylum");
}

public initDefaultErythroxylum(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		ErythroxylumEnt[Client][X] = -1;

		ErythroxylumHealth[Client][X] = 0;

		ErythroxylumFuel[Client][X] = 0.0;
	}
}

public bool:IsValidErythroxylum(Ent)
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
				if(ErythroxylumEnt[i][X] == Ent)
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

public GetErythroxylumIdFromEnt(Ent)
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
				if(ErythroxylumEnt[i][X] == Ent)
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

public HasClientErythroxylum(Client, Id)
{

	//Is Valid:
	if(ErythroxylumEnt[Client][Id] > 0)
	{

		//Return:
		return ErythroxylumEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetErythroxylumHealth(Client, Id)
{

	//Return:
	return ErythroxylumHealth[Client][Id];
}

public SetErythroxylumHealth(Client, Id, Amount)
{

	//Initulize:
	ErythroxylumHealth[Client][Id] = Amount;
}

public Float:GetErythroxylumFuel(Client, Id)
{

	//Return:
	return ErythroxylumFuel[Client][Id];
}

public SetErythroxylumFuel(Client, Id, Float:Amount)
{

	//Initulize:
	ErythroxylumFuel[Client][Id] = Amount;
}

public Action:initErythroxylumTime()
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
				if(IsValidEdict(ErythroxylumEnt[i][X]))
				{

					//Check:
					if(ErythroxylumHealth[i][X] <= 0 || ErythroxylumFuel[i][X] <= 0.0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 21, X);

						//Remove:
						RemoveErythroxylum(i, X);
					}
				}
			}
		}
	}
}

public Action:ErythroxylumHud(Client, Ent)
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
				if(ErythroxylumEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Bottle:\nErythroxylum Solution: %0.2fmL\nHealth: %i", ErythroxylumFuel[i][X], ErythroxylumHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveErythroxylum(Client, X)
{

	//Initulize:
	ErythroxylumHealth[Client][X] = 0;

	ErythroxylumFuel[Client][X] = 0.0;

	//Check:
	if(IsValidAttachedEffect(ErythroxylumEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(ErythroxylumEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(ErythroxylumEnt[Client][X], "kill");

	//Inituze:
	ErythroxylumEnt[Client][X] = -1;
}

public bool:CreateErythroxylum(Client, Id, Float:Fuel, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - Unable to spawn Erythroxylum due to outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f", Fuel);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 21, Id, 0, 0, Health, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You have just spawned a Erythroxylum!");
	}

	//Initulize:
	ErythroxylumFuel[Client][Id] = Fuel;

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	ErythroxylumHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", ErythroxylumModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	ErythroxylumEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientErythroxylum);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[Client][Id] / 2), (ErythroxylumHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestErythroxylum(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testerythroxylum <Id> <Fuel> <Health>");

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

	if(ErythroxylumEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Erythroxylum with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Erythroxylum %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Erythroxylum:
	CreateErythroxylum(Client, Id, Fuel, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsErythroxylumUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientErythroxylum(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Declare:
				new Float:Fuel = 1500.0;

				//CreateErythroxylum
				if(CreateErythroxylum(Client, Y, Fuel, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Erythroxylum|\x07FFFFFF - You already have too many Erythroxylum, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientErythroxylum(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(ErythroxylumEnt[i][X] == Ent)
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
							if(ErythroxylumHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								ErythroxylumHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								ErythroxylumHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[i][X] / 2), (ErythroxylumHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientErythroxylum(ErythroxylumEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientErythroxylum(ErythroxylumEnt[i][X], Damage, Ent2);
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

public Action:DamageClientErythroxylum(Ent, &Float:Damage, &Attacker)
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
				if(ErythroxylumEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) ErythroxylumHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (ErythroxylumHealth[i][X] / 2), (ErythroxylumHealth[i][X] / 2), 255);

					//Check:
					if(ErythroxylumHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 21, X);

						//Remove:
						RemoveErythroxylum(i, X);
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

public bool:IsErythroxylumInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ErythroxylumEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ErythroxylumEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}