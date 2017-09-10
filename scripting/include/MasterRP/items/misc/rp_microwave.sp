//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_microwave_included_
  #endinput
#endif
#define _rp_microwave_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//Microwave:
static MicrowaveTime[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static MicrowaveEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static MicrowaveUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:MicrowaveModel[256] = "models/props_lab/monitor01b.mdl";

public Action:PluginInfo_Microwave(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Microwave!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initMicrowave()
{

	//Commands:
	RegAdminCmd("sm_testmicrowave", Command_TestMicrowave, ADMFLAG_ROOT, "<Id> <Time> - Creates a Microwave");
}

public initDefaultMicrowave(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		MicrowaveEnt[Client][X] = -1;

		MicrowaveUse[Client][X] = 0;

		MicrowaveTime[Client][X] = 0;
	}
}

public bool:IsValidMicrowave(Ent)
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
				if(MicrowaveEnt[i][X] == Ent)
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

public HasClientMicrowave(Client, Id)
{

	//Is Valid:
	if(MicrowaveEnt[Client][Id] > 0)
	{

		//Return:
		return MicrowaveEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetMicrowaveTime(Client, Id)
{

	//Return:
	return MicrowaveTime[Client][Id];
}

public GetMicrowaveValue(Client, Id)
{

	//Return:
	return MicrowaveUse[Client][Id];
}

public Action:OnMicrowaveUse(Client, Ent)
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
						if(MicrowaveEnt[i][X] == Ent)
						{

							//Check:
							if(MicrowaveUse[i][X] == 0)
							{

								//Check:
								if(GetHunger(Client) < 100)
								{

									//Initulize:
									MicrowaveUse[i][X] = 75;

									//Declare:
									new Float:Earns = GetRandomFloat(10.0, 20.0);

									if(GetHunger(Client) + Earns < 100)
									{


										//Initulize:
										SetHunger(Client, (GetHunger(Client) + Earns));
									}

									//Is Client Own:
									if(Client == i)
									{

										//Print:
										CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - You have used this microwave and gained \x0732CD32%.0f\x07FFFFFF Hunger!", Earns);
									}

									//Override:
									else
									{

										//Print:
										CPrintToChat(i, "\x07FF4040|RP-Microwave|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has Used your Microwave!", Client);

										CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - You have used \x0732CD32%N\x07FFFFFF Microwave!", i);
									}
								}

								//Override:
								else
								{

									//Print:
									CPrintToChat(i, "\x07FF4040|RP-Microwave|\x07FFFFFF - You are already Full!", Client);
								}
							}

							//Is Valid:
							else if(MicrowaveTime[i][X] == 0)
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 9, X);

								//Remove:
								RemoveMicrowave(i, X);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - Microwave not ready to harvest. (\x0732CD32%i\x07FFFFFF) Seconds left!", MicrowaveUse[i][X]);
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
			CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Microwave!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public Action:initMicrowaveTime()
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
				if(IsValidEdict(MicrowaveEnt[i][X]))
				{

					//Is Valid:
					if((StrContains(GetJob(i), "Microwave Technician", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i)))
					{

						//Check:
						if(MicrowaveTime[i][X] > 1)
						{

							//Initulize:
							MicrowaveTime[i][X] -= 1;

							//Check:
							if(MicrowaveUse[i][X] >= 0)
							{

								//Initulize:
								MicrowaveUse[i][X] -= 1;
							}
						}

						//Override:
						else
						{

							//Remove From DB:
							RemoveSpawnedItem(i, 9, X);

							//Remove:
							RemoveMicrowave(i, X);
						}
					}

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(MicrowaveEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Show CrimeHud:
					ShowItemToAll(EntOrigin);
				}
			}
		}
	}
}

public Action:MicrowaveHud(Client, Ent)
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
				if(MicrowaveEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Is Microwave Finished:
					if(MicrowaveTime[i][X] == 0)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Microwave:\nFood has been Cooked!\nLeft (%i Sec)", MicrowaveTime[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Microwave:\nCooking Food in %i Sec\nLeft (%i Sec)", MicrowaveUse[i][X], MicrowaveTime[i][X]);
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

public Action:RemoveMicrowave(Client, X)
{

	//Initulize:
	MicrowaveTime[Client][X] = 0;

	MicrowaveUse[Client][X] = 0;

	//Accept:
	AcceptEntityInput(MicrowaveEnt[Client][X], "kill");

	//Inituze:
	MicrowaveEnt[Client][X] = -1;
}

public bool:CreateMicrowave(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
			CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - Unable to spawn Microwave due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 9, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - You have just spawned a Microwave!");
	}

	//Initulize:
	MicrowaveTime[Client][Id] = Time;

	MicrowaveUse[Client][Id] = 150;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", MicrowaveModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	MicrowaveEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

	if(Time > 1200)
		SetEntityRenderColor(Ent, 250, 250, 50, 255);

	//Is Valid:
	if(StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "God Father", false) != -1 || IsAdmin(Client))
	{

		//Initialize:
		SetJobExperience(Client, (GetJobExperience(Client) + 5));
	}

	//Return:
	return true;
}


//Create Garbage Zone:
public Action:Command_TestMicrowave(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testmicrowave <Id> <Time>");

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

	if(MicrowaveEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money Microwave with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Microwave %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateMicrowave
	CreateMicrowave(Client, Id, Time, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsMicrowaveUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientMicrowave(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Microwave:
				if(CreateMicrowave(Client, Y, StringToInt(GetItemVar(ItemId)), 0, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Microwave|\x07FFFFFF - You already have too many Microwave, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}
