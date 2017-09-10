//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bong_included_
  #endinput
#endif
#define _rp_bong_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Bong:
static BongEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static BongHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:BongModel[256] = "models/striker/nicebongstriker.mdl";

public Action:PluginInfo_Bong(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Bong!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initBong()
{

	//Commands:
	RegAdminCmd("sm_testbong", Command_TestBong, ADMFLAG_ROOT, "<Id> - Creates a Bong");
}

public initDefaultBong(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		BongEnt[Client][X] = -1;

		BongHealth[Client][X] = 0;
	}
}

public bool:IsValidBong(Ent)
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
				if(BongEnt[i][X] == Ent)
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

public GetBongIdFromEnt(Ent)
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
				if(BongEnt[i][X] == Ent)
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

public HasClientBong(Client, Id)
{

	//Is Valid:
	if(BongEnt[Client][Id] > 0)
	{

		//Return:
		return BongEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetBongHealth(Client, Id)
{

	//Return:
	return BongHealth[Client][Id];
}

public SetBongHealth(Client, Id, Amount)
{

	//Initulize:
	BongHealth[Client][Id] = Amount;
}

public Action:OnBongUse(Client, Ent)
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
						if(BongEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 27, X);

								//Remove:
								RemoveBong(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Bong|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Bong!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 500));

								//Set Menu State:
								BankState(Client, 500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just destroyed a Bong. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(GetHarvest(Client) > 10)
							{

								//Check:
								if(GetDrugTick(Client) == -1 && GetDrugHealth(Client) == 0)
								{

									//Initulize:
									SetCrime(Client, (GetCrime(Client) + 200));

									//Command:
									CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

									//Set Speed:
									SetEntitySpeed(Client, 1.2);

									//Declare:
									new ClientHealth = GetClientHealth(Client);

									//Set Health:
									SetEntityHealth(Client, ClientHealth + 50);

									//Initulize:
									SetDrugHealth(Client, 50);

									//Initulize:
									SetDrugTick(Client, 90);

									//Shake:
									ShakeClient(Client, 300.0, (10.0));

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just smoked \x0732CD3210g\x07FFFFFF worth of drugs!");
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You are already on drugs!");
								}
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You dont have any drugs to smoke!");
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
			CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Bong!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public Action:initBongTime()
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
				if(IsValidEdict(BongEnt[i][X]))
				{

					//Check:
					if(BongHealth[i][X] <= 0)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 27, X);

						//Remove:
						RemoveBong(i, X);
					}
				}
			}
		}
	}
}

public Action:BongHud(Client, Ent)
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
				if(BongEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "Bong:\nHealth: %i", BongHealth[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveBong(Client, X)
{

	//Initulize:
	BongHealth[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(BongEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(BongEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(BongEnt[Client][X], "kill");

	//Inituze:
	BongEnt[Client][X] = -1;
}

public bool:CreateBong(Client, Id, Health, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Unable to spawn Bong due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 27, Id, 0, 0, Health, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You have just spawned a Bong!");
	}

	if(Health > 500)
	{

		//Initulize:
		Health = 500;
	}

	//Initulize:
	BongHealth[Client][Id] = Health;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", BongModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	BongEnt[Client][Id] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientBong);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (BongHealth[Client][Id] / 2), (BongHealth[Client][Id] / 2), 255);

	//Return:
	return true;
}

//Create Garbage Zone:
public Action:Command_TestBong(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testBong <Id> <Health>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sHealth[32]; new Id, Health;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sHealth, sizeof(sHealth));

	Id = StringToInt(sId);

	Health = StringToInt(sHealth);

	if(BongEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Bong with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Bong %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//Create Bong:
	CreateBong(Client, Id, Health, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsBongUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientBong(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//CreateBong
				if(CreateBong(Client, Y, 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Bong|\x07FFFFFF - You already have too many Bong, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientBong(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(BongEnt[i][X] == Ent)
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
							if(BongHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								BongHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								BongHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (BongHealth[i][X] / 2), (BongHealth[i][X] / 2), 255);
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientBong(BongEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientBong(BongEnt[i][X], Damage, Ent2);
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

public Action:DamageClientBong(Ent, &Float:Damage, &Attacker)
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
				if(BongEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) BongHealth[i][X] -= RoundFloat(Damage);

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (BongHealth[i][X] / 2), (BongHealth[i][X] / 2), 255);

					//Check:
					if(BongHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 27, X);

						//Remove:
						RemoveBong(i, X);
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

public bool:IsBongInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(BongEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, BongEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}