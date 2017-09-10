//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_gunlab_included_
  #endinput
#endif
#define _rp_gunlab_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//GunLab:
static GunLabTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static GunLabEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static GunLabUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:GunLabModel[256] = "models/props_c17/TrapPropeller_Engine.mdl";

public Action:PluginInfo_GunLab(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "GunLab!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initGunLab()
{

	//Commands:
	RegAdminCmd("sm_testgunlab", Command_TestGunLab, ADMFLAG_ROOT, "<Id> <Time> - Creates a GunLab");
}

public initDefaultGunLab(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		GunLabEnt[Client][X] = -1;

		GunLabUse[Client][X] = 0;

		GunLabTime[Client][X] = 0;
	}
}

public bool:IsValidGunLab(Ent)
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
				if(GunLabEnt[i][X] == Ent)
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

public HasClientGunLab(Client, Id)
{

	//Is Valid:
	if(GunLabEnt[Client][Id] > 0)
	{

		//Return:
		return GunLabEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetGunLabTime(Client, Id)
{

	//Return:
	return GunLabTime[Client][Id];
}

public GetGunLabUse(Client, Id)
{

	//Return:
	return GunLabUse[Client][Id];
}

public Action:OnGunLabUse(Client, Ent)
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
						if(GunLabEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 8, X);

								//Remove:
								RemoveGunLab(i, X);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-GunLab|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Gun Lab!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - You have just destroyed a Gun Lab. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - Gun lab is working!");
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
			CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Gun Lab!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initGunLabTime()
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
				if(IsValidEdict(GunLabEnt[i][X]))
				{

					//Check:
					CheckGeneratorToGunLab(i, X);

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(GunLabEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

//Check to see if the generator is in distance
public Action:CheckGeneratorToGunLab(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidGenerator(X) && IsInDistance(GunLabEnt[Client][Y], X))
			{

				//Is Valid:
				if((StrContains(GetJob(Client), "GunLab Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || GetDonator(Client) > 0 || IsAdmin(Client)))
				{

					//Declare:
					new Id = GetGeneratorIdFromEnt(X);

					//Check:
					if(GetGeneratorEnergy(Client, Id) - 0.25 > 0)
					{

						//Initulize:
						SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.25));

						//Declare:
						new Float:EntOrigin[3];

						//Initialize:
						GetEntPropVector(GunLabEnt[Client][Y], Prop_Send, "m_vecOrigin", EntOrigin);

						//Check:
						if(GunLabTime[Client][Y] > 0)
						{

							//Initulize:
							GunLabTime[Client][Y] -= 1;

							//Initulize:
							GunLabUse[Client][Y] -= 1;

							//Is Valid:
							if(GunLabUse[Client][Y] == 0)
							{

								//Initulize:
								GunLabUse[Client][Y] += 75;

								//Spawn Weapon:
								GunLabSpawnWeapon(Client, GunLabEnt[Client][Y], -1);

								//Initulize:
								SetCrime(Client, (GetCrime(Client) + GetRandomInt(200, 400)));
							}

							//Declare:
							new TempEnt = GetEntAttatchedEffect(GunLabEnt[Client][Y], 0);

							//Check:
							if(IsValidEdict(TempEnt))
							{

								//Accept:
								AcceptEntityInput(TempEnt, "TurnOn");

								AcceptEntityInput(TempEnt, "DoSpark");
							}
						}

						if(GunLabTime[Client][Y] == 0)
						{

							//Remove From DB:
							RemoveSpawnedItem(Client, 8, Y);

							//Remove:
							RemoveGunLab(Client, Y);
						}
					}
				}

				//Stop:
				break;
			}
		}
	}
}

public Action:GunLabHud(Client, Ent)
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
				if(GunLabEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Format:
					Format(FormatMessage, sizeof(FormatMessage), "GunLab:\nEnds in %i Sec\nWeapon Spawns in %i", GunLabTime[i][X], GunLabUse[i][X]);

					//Setup Hud:
					SetHudTextParams(-1.0, -0.805, 0.5, GetEntityHudColor(Client, 0), GetEntityHudColor(Client, 1), GetEntityHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

					//Show Hud Text:
					ShowHudText(Client, 1, FormatMessage);
				}
			}
		}
	}
}

public Action:RemoveGunLab(Client, X)
{

	//Initulize:
	GunLabTime[Client][X] = 0;

	GunLabUse[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(GunLabEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(GunLabEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(GunLabEnt[Client][X], "kill");

	//Inituze:
	GunLabEnt[Client][X] = -1;
}

public bool:CreateGunLab(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - Unable to spawn Gun Lab due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 8, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - You have just spawned a GunLab!");
	}

	//Initulize:
	GunLabTime[Client][Id] = Time;

	GunLabUse[Client][Id] = 75;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", GunLabModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	GunLabEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Initulize Effects:
	new Effect = CreatePointTesla(Ent, "null", "255 120 51");

	SetEntAttatchedEffect(Ent, 0, Effect);

	if(Time > 1200)
		SetEntityRenderColor(Ent, 250, 250, 50, 255);

	//Is Valid:
	if(StrContains(GetJob(Client), "GunLab Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestGunLab(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testGunLab <Id> <Time>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sTime[32]; new Id, Time;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sTime, sizeof(sTime));

	Id = StringToInt(sId);

	Time = StringToInt(sTime);

	if(GunLabEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money GunLab with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid GunLab %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateGunLab
	CreateGunLab(Client, Id, Time, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsGunLabUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - Cops can't use any illegal items.");
	}

	//Override:
	else
	{

		//Declare:
		new MaxSlots = 1;

		//Valid Job:
		if(StrContains(GetJob(Client), "Drug Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 1;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "Crime Lord", false) != -1)
		{

			//Initulize:
			MaxSlots = 2;
		}

		//Valid Job:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Initulize:
			MaxSlots = 3;
		}

		//Valid Job:
		if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Initulize:
			MaxSlots = 5;
		}

		//Add Extra Slots:
		MaxSlots += GetItemAmount(Client, 305);

		//Check:
		if(MaxSlots > MAXITEMSPAWN)
		{

			//Initulize:
			MaxSlots = MAXITEMSPAWN;
		}
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
			Ent = HasClientGunLab(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn GunLab:
				if(CreateGunLab(Client, Y, StringToInt(GetItemVar(ItemId)), 0, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-GunLab|\x07FFFFFF - You already have too many Printers, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}
