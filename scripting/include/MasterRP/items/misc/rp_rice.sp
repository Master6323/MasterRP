//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_rice_included_
  #endinput
#endif
#define _rp_rice_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Rice:
static RiceTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static RiceEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Grams[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:RiceModel[256] = "models/props_lab/cactus.mdl";

public Action:PluginInfo_Rice(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Rice!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initRice()
{

	//Commands:
	RegAdminCmd("sm_testrice", Command_TestRice, ADMFLAG_ROOT, "<Id> <Time> - Creates a Rice");
}

public initDefaultRice(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		RiceEnt[Client][X] = -1;

		Grams[Client][X] = 0;

		RiceTime[Client][X] = 0;
	}
}

public bool:IsValidRice(Ent)
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
				if(RiceEnt[i][X] == Ent)
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

public HasClientRice(Client, Id)
{

	//Is Valid:
	if(RiceEnt[Client][Id] > 0)
	{

		//Return:
		return RiceEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetRiceTime(Client, Id)
{

	//Return:
	return RiceTime[Client][Id];
}

public GetRiceValue(Client, Id)
{

	//Return:
	return Grams[Client][Id];
}

public Action:OnRiceUse(Client, Ent)
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
						if(RiceEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You can't take rice!");
							}

							//Is Valid:
							else if(RiceTime[i][X] == 0 && Client == i)
							{
	
								//Declare:
								new Earns = Grams[i][X];

								//Initulize:
								SetRice(Client, (GetRice(Client) + Earns));

								Grams[i][X] = 0;
	
								//Remove From DB:
								RemoveSpawnedItem(i, 6, X);

								//Remove:
								RemoveRice(i, X);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You have collected â‚¬\x0732CD32%ig\x07FFFFFF from your Rice Plant!", Earns);
	
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Rice not ready to harvest. (\x0732CD32%i\x07FFFFFF) Seconds left!", RiceTime[i][X]);
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
			CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Rice!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initRiceTime()
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
				if(IsValidEdict(RiceEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(RiceEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Check:
					if(RiceTime[i][X] > 0)
					{

						//Initulize:
						RiceTime[i][X] -= 1;

						//Declare:
						new Random = GetRandomInt(1, 10);

						//Valid:
						if(Random == 1)
						{

							//Initulize:
							Random = GetRandomInt(1, 2);

							//Max Drugs:
							if(Grams[i][X] + Random < 200)
							{

								//Initulize:
								Grams[i][X] += Random;
							}
						}
					}

					//Show CrimeHud:
					ShowItemToAll(EntOrigin);
				}
			}
		}
	}
}

public Action:RiceHud(Client, Ent)
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
				if(RiceEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Is Rice Finished:
					if(RiceTime[i][X] == 0)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Rice:\nHas Finished Growing!\nGrams (%ig)", Grams[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Rice:\nFinishes Growing in %i Sec\nGrams (%ig)", RiceTime[i][X], Grams[i][X]);
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

public Action:RemoveRice(Client, X)
{

	//Initulize:
	RiceTime[Client][X] = 0;

	Grams[Client][X] = 0;

	//Accept:
	AcceptEntityInput(RiceEnt[Client][X], "kill");

	//Inituze:
	RiceEnt[Client][X] = -1;
}

public bool:CreateRice(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Unable to spawn Rice Plant due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 5, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You have just spawned a Rice Kitchen!");
	}

	//Initulize:
	RiceTime[Client][Id] = Time;

	Grams[Client][Id] = 0;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", RiceModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	RiceEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	//Is Valid:
	if(StrContains(GetJob(Client), "Rice Technician", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestRice(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testrice <Id> <Time>");

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

	if(RiceEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Rice with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Rice %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateRice
	CreateRice(Client, Id, Time, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsRiceUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientRice(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Rice:
				if(CreateRice(Client, Y, StringToInt(GetItemVar(ItemId)), 0, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Rice|\x07FFFFFF - You already have too many Rice Plants, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}