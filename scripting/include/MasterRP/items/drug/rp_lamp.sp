//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_lamp_included_
  #endinput
#endif
#define _rp_lamp_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Lamp:
static LampEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static LampHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static bool:IsLampOn[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:LampModel[256] = "models/props_interiors/furniture_lamp01a.mdl";

static String:CombineLampModel[256] = "models/props_combine/combine_light001a.mdl";

initLamp()
{

	//Commands:
	RegAdminCmd("sm_testLamp", Command_TestLamp, ADMFLAG_ROOT, "<Id> <Time> - Creates a Lamp");
}

public initDefaultLamp(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		LampEnt[Client][X] = -1;

		LampHealth[Client][X] = 0;
	}
}

public bool:IsValidLamp(Ent)
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
				if(LampEnt[i][X] == Ent)
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

public GetLampIdFromEnt(Ent)
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
				if(LampEnt[i][X] == Ent)
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

public GetLampOwnerFromEnt(Ent)
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
				if(LampEnt[i][X] == Ent)
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

public HasClientLamp(Client, Id)
{

	//Is Valid:
	if(LampEnt[Client][Id] > 0)
	{

		//Return:
		return LampEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetLampHealth(Client, Id)
{

	//Return:
	return LampHealth[Client][Id];
}

public SetLampHealth(Client, Id, Amount)
{

	//Initulize:
	LampHealth[Client][Id] = Amount;
}

public bool:GetIsLampOn(Client, Id)
{

	//Return:
	return IsLampOn[Client][Id];
}

public SetSLampOn(Client, Id, bool:Result)
{

	//Initulize:
	IsLampOn[Client][Id] = Result;
}

public Action:OnLampUse(Client, Ent)
{

	//In Distance:
	if(IsInDistance(Client, Ent))
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
					if(LampEnt[i][X] == Ent)
					{

						//Check:
						if(IsLampOn[i][X])
						{

							//Initulize:
							IsLampOn[i][X] = false;

							//Accept:
							AcceptEntityInput(GetLightEnt(LampEnt[i][X]), "TurnOff");
						}

						//Override:
						else
						{

							//Initulize:
							IsLampOn[i][X] = true;

							//Accept:
							AcceptEntityInput(GetLightEnt(LampEnt[i][X]), "TurnOn");
						}

						//Emit Sound:
						EmitSoundToClient(Client, "buttons/lightswitch2.wav");
					}
				}
			}
		}
	}
}

public Action:initLampTime()
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
				if(IsValidEdict(LampEnt[i][X]))
				{

					//Check:
					if(LampHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 20, X);

						//Remove:
						RemoveLamp(i, X);
					}
				}
			}
		}
	}
}

public Action:LampHud(Client, Ent)
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
				if(LampEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Lamp:\nHealth: %i", LampHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveLamp(Client, X)
{

	//Initulize:
	LampHealth[Client][X] = 0;

	//Check:
	if(IsValidLight(LampEnt[Client][X]))
	{

		//Remove:
		RemoveLight(LampEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(LampEnt[Client][X], "kill");

	//Inituze:
	LampEnt[Client][X] = -1;
}

public bool:CreateLamp(Client, Id, Type, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Lamp|\x07FFFFFF - Unable to spawn Acetone Can due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 20, Id, 0, Type, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Lamp|\x07FFFFFF - You have just spawned a Lamp!");
	}

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	LampHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	//Check:
	if(Type == 1)
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", LampModel);
	}

	//Override:
	else
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", CombineLampModel);
	}

	//Spawn:
	DispatchSpawn(Ent);

	//Initulize:
	LampEnt[Client][Id] = Ent;

	IsLampOn[Client][Id] = true;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientLamp);

	//Check:
	if(Type == 1)
	{

		//Light Source:
		CreateLight(Ent, 1, 248, 253, 38, "null");
	}

	//Override:
	else
	{

		//Light Source:
		CreateLight(Ent, 1, 10, 38, 253, "null");
	}

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (LampHealth[Client][Id] / 2), (LampHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestLamp(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testlamp <Id> <Type 0-1> <Health>");

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

	if(LampEnt[Client][Id] > 0)
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

	//Create Lamp:
	CreateLamp(Client, Id, Type, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsLampUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Lamp|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Lamp|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientLamp(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateLamp
				if(CreateLamp(Client, Y, StringToInt(GetItemVar(ItemId)), 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Lamp|\x07FFFFFF - You already have too many Acetone Can, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientLamp(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(LampEnt[i][X] == Ent)
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
							if(LampHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								LampHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								LampHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (LampHealth[i][X] / 2), (LampHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientLamp(LampEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientLamp(LampEnt[i][X], Damage, Ent2);
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

public Action:DamageClientLamp(Ent, &Float:Damage, &Attacker)
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
				if(LampEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) LampHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (LampHealth[i][X] / 2), (LampHealth[i][X] / 2), 255);

					//Check:
					if(LampHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 20, X);

						//Remove:
						RemoveLamp(i, X);
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

public bool:IsLampInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(LampEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, LampEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}