//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_shield_included_
  #endinput
#endif
#define _rp_shield_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Shield:
static ShieldTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static ShieldEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static ShieldHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:ShieldModel[256] = "models/Combine_Helicopter/helicopter_bomb01.mdl";

public Action:PluginInfo_Shield(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Shield!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initShield()
{

	//Commands:
	RegAdminCmd("sm_testshield", Command_TestShield, ADMFLAG_ROOT, "<Id> <Time> - Creates a Shield");
}

public initDefaultShield(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		ShieldEnt[Client][X] = -1;

		ShieldHealth[Client][X] = 0;

		ShieldTime[Client][X] = 0;
	}
}

public bool:IsValidShield(Ent)
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
				if(ShieldEnt[i][X] == Ent)
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

public HasClientShield(Client, Id)
{

	//Is Valid:
	if(ShieldEnt[Client][Id] > 0)
	{

		//Return:
		return ShieldEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetShieldTime(Client, Id)
{

	//Return:
	return ShieldTime[Client][Id];
}

public GetShieldValue(Client, Id)
{

	//Return:
	return ShieldHealth[Client][Id];
}

public Action:OnShieldUse(Client, Ent)
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
						if(ShieldEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 10, X);

								//Remove:
								RemoveShield(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Shield|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Shield!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 500));

								//Set Menu State:
								BankState(Client, 500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You have just destroyed a Shield. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else
							{
								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You cannot use a Shield");
	
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
			CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Shield!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initShieldTime()
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
				if(IsValidEdict(ShieldEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(ShieldEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Check:
					if(ShieldTime[i][X] > 0)
					{

						//Initulize:
						ShieldTime[i][X] -= 1;

					}

					//Remove Check:
					if(ShieldTime[i][X] == 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 10, X);

						//Remove:
						RemoveShield(i, X);
					}

					//Show CrimeHud:
					ShowItemToAll(EntOrigin);
				}
			}
		}
	}
}

public Action:ShieldHud(Client, Ent)
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
				if(ShieldEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Shield:\nEnds in %i Sec\nHealth: %i", ShieldTime[i][X], ShieldHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveShield(Client, X)
{

	//Initulize:
	ShieldTime[Client][X] = 0;

	ShieldHealth[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(ShieldEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(ShieldEnt[Client][X]);
	}

	//Accept:
	EntityDissolve(ShieldEnt[Client][X], 3);

	//Inituze:
	ShieldEnt[Client][X] = -1;
}

public bool:CreateShield(Client, Id, Time, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Unable to spawn Shield due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 10, Id, Time, 0, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You have just spawned a Shield!");
	}

	//Initulize:
	ShieldTime[Client][Id] = Time;

	ShieldHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", ShieldModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	ShieldEnt[Client][Id] = Ent;

	//Initulize Effects:
	new Effect = CreatePointTesla(Ent, "null", "120 120 255");

	SetEntAttatchedEffect(Ent, 0, Effect);

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientShield);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestShield(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testshield <Id> <Time> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sTime[32], String:sHealth[32]; new Id, Time, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sTime, sizeof(sTime));

	//Initialize:
	GetCmdArg(3, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Time = StringToInt(sTime);

	Health = StringToInt(sTime);

	if(ShieldEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Shield with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Shield %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Shield:
	CreateShield(Client, Id, Time, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsShieldUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientShield(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateShield
				if(CreateShield(Client, Y, 1800, StringToInt(GetItemVar(ItemId)), Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Shield|\x07FFFFFF - You already have too many Shield Plants, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

public Action:OnClientShieldDamage(Client, Float:Damage)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ShieldEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ShieldEnt[Client][X]))
			{

				//Initulize:
				if(Damage > 0.0) ShieldHealth[Client][X] -= RoundFloat(Damage);

				//Declare:
				new TempEnt = GetEntAttatchedEffect(ShieldEnt[Client][X], 0);

				//Check & Is Alive::
				if(IsValidEdict(TempEnt))
				{

					//Accept:
					AcceptEntityInput(TempEnt, "TurnOn");

					AcceptEntityInput(TempEnt, "DoSpark");
				}

				//Check:
				if(ShieldHealth[Client][X] < 1)
				{

					//Remove From DB:
					RemoveSpawnedItem(Client, 10, X);

					//Remove:
					RemoveShield(Client, X);
				}

				//stop:
				break;
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientShield(Ent, &Client, &inflictor, &Float:Damage, &damageType)
{

	//Check:
	if(Client > 0 && Client <= GetMaxClients() && IsClientConnected(Client))
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(ShieldEnt[Client][X] == Ent)
			{

				//Initulize:
				if(Damage > 0.0) ShieldHealth[Client][X] -= RoundFloat(Damage);

				//Declare:
				new TempEnt = GetEntAttatchedEffect(ShieldEnt[Client][X], 0);

				//Check & Is Alive::
				if(IsValidEdict(TempEnt))
				{

					//Accept:
					AcceptEntityInput(TempEnt, "TurnOn");

					AcceptEntityInput(TempEnt, "DoSpark");
				}

				//Check:
				if(ShieldHealth[Client][X] < 1)
				{

					//Remove From DB:
					RemoveSpawnedItem(Client, 10, X);

					//Remove:
					RemoveShield(Client, X);
				}

				//stop:
				break;
			}
		}
	}

	//Return:
	return Plugin_Continue;
}

public bool:IsShieldInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(ShieldEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, ShieldEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}