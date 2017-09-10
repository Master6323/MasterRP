//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_firebomb_included_
  #endinput
#endif
#define _rp_firebomb_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//FireBomb:
static FireBombUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static FireBombEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static FireBombExplode[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:FireBombModel[256] = "models/props_junk/cardboard_box004a.mdl";

public Action:PluginInfo_FireBomb(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "FireBomb!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initFireBomb()
{

	//Commands:
	RegAdminCmd("sm_testfirebomb", Command_TestFireBomb, ADMFLAG_ROOT, "<Id> <Time> - Creates a FireBomb");
}

public initDefaultFireBomb(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		FireBombEnt[Client][X] = -1;

		FireBombExplode[Client][X] = 0;

		FireBombUse[Client][X] = 0;
	}
}

public bool:IsValidFireBomb(Ent)
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
				if(FireBombEnt[i][X] == Ent)
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

public HasClientFireBomb(Client, Id)
{

	//Is Valid:
	if(FireBombEnt[Client][Id] > 0)
	{

		//Return:
		return FireBombEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetFireBombUse(Client, Id)
{

	//Return:
	return FireBombUse[Client][Id];
}

public GetFireBombExplode(Client, Id)
{

	//Return:
	return FireBombExplode[Client][Id];
}

public Action:OnFireBombUse(Client, Ent)
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
						if(FireBombEnt[i][X] == Ent)
						{

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(Client, 11, X);

								//Remove:
								RemoveFireBomb(i, X, false);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-FireBomb|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your FireBomb!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You have just destroyed a FireBomb. reseaved â‚¬\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(FireBombUse[i][X] == 0 && FireBombExplode[i][X] == 0 && Client == i)
							{

								//Initulize:
								FireBombExplode[i][X] = 30;

								FireBombUse[i][X] = 1;

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You have just armed your FireBomb. it will explode in \x0732CD3230\x07FFFFFF seconds!");
							}

							//Is Valid:
							else if(FireBombUse[i][X] == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - This FireBomb is going to explode in %i Sec", FireBombExplode[i][X]);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You can't use this explosive FireBomb!");
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
			CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use FireBomb!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initFireBombTime()
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
				if(IsValidEdict(FireBombEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(FireBombEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Enabled:
					if(FireBombUse[i][X] == 1)
					{

						//Initulize:
						FireBombExplode[i][X] -=1;

						//Explode:
						if(FireBombExplode[i][X] == 0)
						{

							//Explode:
							CreateExplosion(FireBombEnt[i][X], FireBombEnt[i][X]);

							//Initulize Effects:
							new Effect = CreateEnvFire(FireBombEnt[i][X], "null", "200", "700", "0", "Natural");

							SetEntAttatchedEffect(FireBombEnt[i][X], 0, Effect);

							//Initulize Effects:
							Effect = CreateLight(FireBombEnt[i][X], 1, 255, 120, 120, "null");

							SetEntAttatchedEffect(FireBombEnt[i][X], 1, Effect);

							//Set Bomb Color:
							SetEntityRenderColor(FireBombEnt[i][X], 255, 50, 50, 255);
						}
					}

					//Check!
					if(FireBombExplode[i][X] < 0)
					{

						//CreateDamage:
						ExplosionDamage(i, FireBombEnt[i][X], EntOrigin, DMG_BURN);
					}

					//Remove After 2 Minutes!
					if(FireBombExplode[i][X] == -30)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 11, X);

						//Explode:
						RemoveFireBomb(i, X, false);
					}

					//Show CrimeHud:
					ShowFireBombToAll(EntOrigin, i, X);
				}
			}
		}
	}
}

public Action:FireBombHud(Client, Ent)
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
				if(FireBombEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Bomb Already Armed:
					if(FireBombExplode[i][X] > 0 && FireBombExplode[i][X] <= 30)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "FireBomb:\nFireBomb will explode in\n(%i) Seconds", FireBombExplode[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "FireBomb:\nThis Firebomb belongs to:\n%N!", i);
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
public Action:ShowFireBombToAll(Float:FireBombOrigin[3], Client, X)
{

	//Declare:
	new Float:ClientOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	//Initialize:
	new Float:Dist = GetVectorDistance(ClientOrigin, FireBombOrigin);

	//In Distance:
	if(Dist <= 800)
	{

		//Initulize:
		FireBombOrigin[2] += 1.0;

		//Declare:
		new ColorFireBomb[4] = {50, 250, 50, 250};

		//Check:
		if(FireBombExplode[Client][X] > 20 && FireBombExplode[Client][X] < 30)
		{

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", FireBombOrigin, FireBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		if(FireBombExplode[Client][X] > 10 && FireBombExplode[Client][X] < 21)
		{

			//Initulize:
			ColorFireBomb[0] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", FireBombOrigin, FireBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		else if(FireBombExplode[Client][X] > 0 && FireBombExplode[Client][X] < 11)
		{

			//Initulize:
			ColorFireBomb[0] = 255;
			ColorFireBomb[1] = 50;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", FireBombOrigin, FireBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Show To Client:
		TE_SetupBeamRingPoint(FireBombOrigin, 1.0, 100.0, Laser(), Sprite(), 0, 10, 0.7, 5.0, 0.5, ColorFireBomb, 10, 0);

		//End Temp:
		TE_SendToAll();
	}
}

public Action:RemoveFireBomb(Client, X, bool:Explode)
{

	//Can Explode:
	if(Explode)
	{

		//Explode:
		CreateExplosion(Client, FireBombEnt[Client][X]);
	}

	//Initulize:
	FireBombUse[Client][X] = 0;

	FireBombExplode[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(FireBombEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(FireBombEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(FireBombEnt[Client][X], "kill");

	//Inituze:
	FireBombEnt[Client][X] = -1;
}

public bool:CreateFireBomb(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
		InsertSpawnedItem(Client, 11, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You have just spawned a FireBomb!");
	}

	//Initulize:
	FireBombUse[Client][Id] = Time;

	FireBombExplode[Client][Id] = 0;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", FireBombModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	FireBombEnt[Client][Id] = Ent;

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
public Action:Command_TestFireBomb(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testfirebomb <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32]; new Id;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(FireBombEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money FireBomb with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid FireBomb %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreateFireBomb
	CreateFireBomb(Client, Id, 0, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsFireBombUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - Cops can't use any illegal items.");
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
			Ent = HasClientFireBomb(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn FireBomb:
				if(CreateFireBomb(Client, Y, 0, 0, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-FireBomb|\x07FFFFFF - You already have too many Fire Bombs, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}