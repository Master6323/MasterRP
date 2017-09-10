//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_waterbomb_included_
  #endinput
#endif
#define _rp_waterbomb_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//WaterBomb:
static WaterBombUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static WaterBombEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static WaterBombExplode[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:WaterBombModel[256] = "models/props_junk/cardboard_box004a.mdl";

public Action:PluginInfo_WaterBomb(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "WaterBomb!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initWaterBomb()
{

	//Commands:
	RegAdminCmd("sm_testwaterbomb", Command_TestWaterBomb, ADMFLAG_ROOT, "<Id> <Time> - Creates a WaterBomb");
}

public initDefaultWaterBomb(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		WaterBombEnt[Client][X] = -1;

		WaterBombExplode[Client][X] = 0;

		WaterBombUse[Client][X] = 0;
	}
}

public bool:IsValidWaterBomb(Ent)
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
				if(WaterBombEnt[i][X] == Ent)
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

public HasClientWaterBomb(Client, Id)
{

	//Is Valid:
	if(WaterBombEnt[Client][Id] > 0)
	{

		//Return:
		return WaterBombEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetWaterBombUse(Client, Id)
{

	//Return:
	return WaterBombUse[Client][Id];
}

public GetWaterBombExplode(Client, Id)
{

	//Return:
	return WaterBombExplode[Client][Id];
}

public Action:OnWaterBombUse(Client, Ent)
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
						if(WaterBombEnt[i][X] == Ent)
						{


							//Is Valid:
							if(WaterBombUse[i][X] == 0 && WaterBombExplode[i][X] == 0 && Client == i)
							{

								//Initulize:
								WaterBombExplode[i][X] = 30;

								WaterBombUse[i][X] = 1;

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - You have just armed your WaterBomb. it will explode in \x0732CD3230\x07FFFFFF seconds!");
							}

							//Is Valid:
							else if(WaterBombUse[i][X] == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - This WaterBomb is going to explode in %i Sec", WaterBombExplode[i][X]);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - You can't use this explosive WaterBomb!");
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
			CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use WaterBomb!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initWaterBombTime()
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
				if(IsValidEdict(WaterBombEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(WaterBombEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Enabled:
					if(WaterBombUse[i][X] == 1)
					{

						//Initulize:
						WaterBombExplode[i][X] -=1;

						//Explode:
						if(WaterBombExplode[i][X] == 0)
						{

							//Temp Ent:
							TE_SetupExplosion(EntOrigin, Explode(), 5.0, 1, 0, 600, 5000);

							//Send:
							TE_SendToAll();

							//Emit Sound:
							EmitAmbientSound("ambient/explosions/explode_5.wav", EntOrigin, SNDLEVEL_RAIDSIREN);

							//Declare:
							new Effect = CreateEnvSplash(WaterBombEnt[i][X], "null", "50.0");

							SetEntAttatchedEffect(WaterBombEnt[i][X], 0, Effect);

							//Initulize Effects:
							Effect = CreateLight(WaterBombEnt[i][X], 1, 120, 120, 255, "null");

							SetEntAttatchedEffect(WaterBombEnt[i][X], 1, Effect);

							//Set Bomb Color:
							SetEntityRenderColor(WaterBombEnt[i][X], 50, 50, 255, 255);
						}
					}

					//Check:
					if(WaterBombExplode[i][X] < 0)
					{

						//Declare:
						new Effect = GetEntAttatchedEffect(WaterBombEnt[i][X], 0);

						//Check:
						if(IsValidEdict(Effect))
						{

							//Spark:
							AcceptEntityInput(Effect, "Splash");

							//Create Damage:
							ExplosionDamage(i, WaterBombEnt[i][X], EntOrigin, DMG_DROWN);
						}
					}

					//Remove After 30 Seconds!
					if(WaterBombExplode[i][X] == -30)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 29, X);

						//Explode:
						RemoveWaterBomb(i, X, false);
					}

					//Show CrimeHud:
					ShowWaterBombToAll(EntOrigin, i, X);
				}
			}
		}
	}
}

public Action:WaterBombHud(Client, Ent)
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
				if(WaterBombEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Bomb Already Armed:
					if(WaterBombExplode[i][X] > 0 && WaterBombExplode[i][X] <= 30)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "WaterBomb:\nWaterBomb will explode in\n(%i) Seconds", WaterBombExplode[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "WaterBomb:\nThis WaterBomb belongs to:\n%N!", i);
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

//Crime Hud:
public Action:ShowWaterBombToAll(Float:WaterBombOrigin[3], Client, X)
{

	//Declare:
	new Float:ClientOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	//Initialize:
	new Float:Dist = GetVectorDistance(ClientOrigin, WaterBombOrigin);

	//In Distance:
	if(Dist <= 800)
	{

		//Initulize:
		WaterBombOrigin[2] += 1.0;

		//Declare:
		new ColorWaterBomb[4] = {255, 50, 50, 250};

		//Check:
		if(WaterBombExplode[Client][X] > 20 && WaterBombExplode[Client][X] < 30)
		{

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", WaterBombOrigin, WaterBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		if(WaterBombExplode[Client][X] > 10 && WaterBombExplode[Client][X] < 21)
		{

			//Initulize:
			ColorWaterBomb[0] = 150;
			ColorWaterBomb[1] = 150;
			ColorWaterBomb[2] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", WaterBombOrigin, WaterBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		else if(WaterBombExplode[Client][X] > 0 && WaterBombExplode[Client][X] < 11)
		{

			//Initulize:
			ColorWaterBomb[0] = 50;
			ColorWaterBomb[1] = 50;
			ColorWaterBomb[2] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", WaterBombOrigin, WaterBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Show To Client:
		TE_SetupBeamRingPoint(WaterBombOrigin, 1.0, 100.0, Laser(), Sprite(), 0, 10, 0.7, 5.0, 0.5, ColorWaterBomb, 10, 0);

		//End Temp:
		TE_SendToAll();
	}
}

public Action:RemoveWaterBomb(Client, X, bool:Explode)
{

	//Can Explode:
	if(Explode)
	{

		//Explode:
		CreateExplosion(Client, WaterBombEnt[Client][X]);
	}

	//Initulize:
	WaterBombUse[Client][X] = 0;

	WaterBombExplode[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(WaterBombEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(WaterBombEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(WaterBombEnt[Client][X], "kill");

	//Inituze:
	WaterBombEnt[Client][X] = -1;
}

public bool:CreateWaterBomb(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
		if(TR_PointOutsideWorld(ClientOrigin))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bomb|\x07FFFFFF - Unable to spawn Bomb due to outside of world");

			//Return:
			return false;
		}

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 29, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - You have just spawned a WaterBomb!");
	}

	//Initulize:
	WaterBombUse[Client][Id] = Time;

	WaterBombExplode[Client][Id] = 0;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", WaterBombModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	WaterBombEnt[Client][Id] = Ent;

	//Set Prop:
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

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
public Action:Command_TestWaterBomb(Client, Args)
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
	if(Args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testWaterBomb <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32]; new Id;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(WaterBombEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money WaterBomb with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid WaterBomb %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateWaterBomb
	CreateWaterBomb(Client, Id, 0, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsWaterBombUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
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
			Ent = HasClientWaterBomb(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn WaterBomb:
				if(CreateWaterBomb(Client, Y, 0, 0, Position, EyeAngles, false))
				{

					//Save:
					SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) - 1));

					//Initulize:
					SetCrime(Client, (GetCrime(Client) + 500));
				}
			}

			//Override:
			else
			{

				//Too Many:
				if(Y == MaxSlots)
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-WaterBomb|\x07FFFFFF - You already have too many Fire Bombs, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}