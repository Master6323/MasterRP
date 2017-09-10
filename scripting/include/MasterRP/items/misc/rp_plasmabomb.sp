//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_plasmabomb_included_
  #endinput
#endif
#define _rp_plasmabomb_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Define:
#define MAXITEMSPAWN		10

//PlasmaBomb:
static PlasmaBombUse[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlasmaBombEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PlasmaBombExplode[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

static String:PlasmaBombModel[256] = "models/props_junk/cardboard_box004a.mdl";

public Action:PluginInfo_PlasmaBomb(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "PlasmaBomb!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPlasmaBomb()
{

	//Commands:
	RegAdminCmd("sm_testplasmabomb", Command_TestPlasmaBomb, ADMFLAG_ROOT, "<Id> <Time> - Creates a PlasmaBomb");
}

public initDefaultPlasmaBomb(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PlasmaBombEnt[Client][X] = -1;

		PlasmaBombExplode[Client][X] = 0;

		PlasmaBombUse[Client][X] = 0;
	}
}

public bool:IsValidPlasmaBomb(Ent)
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
				if(PlasmaBombEnt[i][X] == Ent)
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

public HasClientPlasmaBomb(Client, Id)
{

	//Is Valid:
	if(PlasmaBombEnt[Client][Id] > 0)
	{

		//Return:
		return PlasmaBombEnt[Client][Id];
	}

	//Return:
	return -1;
}

public GetPlasmaBombUse(Client, Id)
{

	//Return:
	return PlasmaBombUse[Client][Id];
}

public GetPlasmaBombExplode(Client, Id)
{

	//Return:
	return PlasmaBombExplode[Client][Id];
}

public Action:OnPlasmaBombUse(Client, Ent)
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
						if(PlasmaBombEnt[i][X] == Ent)
						{


							//Is Valid:
							if(PlasmaBombUse[i][X] == 0 && PlasmaBombExplode[i][X] == 0 && Client == i)
							{

								//Initulize:
								PlasmaBombExplode[i][X] = 30;

								PlasmaBombUse[i][X] = 1;

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - You have just armed your PlasmaBomb. it will explode in \x0732CD3230\x07FFFFFF seconds!");
							}

							//Is Valid:
							else if(PlasmaBombUse[i][X] == 1)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - This PlasmaBomb is going to explode in %i Sec", PlasmaBombExplode[i][X]);
							}

							//Override:
							else	
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - You can't use this explosive PlasmaBomb!");
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
			CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use PlasmaBomb!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}


public Action:initPlasmaBombTime()
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
				if(IsValidEdict(PlasmaBombEnt[i][X]))
				{

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(PlasmaBombEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Enabled:
					if(PlasmaBombUse[i][X] == 1)
					{

						//Initulize:
						PlasmaBombExplode[i][X] -=1;

						//Explode:
						if(PlasmaBombExplode[i][X] == 0)
						{

							//Temp Ent:
							TE_SetupExplosion(EntOrigin, Explode(), 5.0, 1, 0, 600, 5000);

							//Send:
							TE_SendToAll();

							//Emit Sound:
							EmitAmbientSound("ambient/explosions/explode_5.wav", EntOrigin, SNDLEVEL_RAIDSIREN);

							//Declare:
							new Effect = CreateEnvAr2Explosion(PlasmaBombEnt[i][X], "null", "sprites/plasmaember.vmt");

							SetEntAttatchedEffect(PlasmaBombEnt[i][X], 0, Effect);

							//Initulize Effects:
							Effect = CreateLight(PlasmaBombEnt[i][X], 1, 200, 200, 255, "null");

							SetEntAttatchedEffect(PlasmaBombEnt[i][X], 1, Effect);

							//Set Bomb Color:
							SetEntityRenderColor(PlasmaBombEnt[i][X], 50, 50, 255, 255);
						}
					}

					//Check:
					if(PlasmaBombExplode[i][X] < 0)
					{

						//Declare:
						new Effect = GetEntAttatchedEffect(PlasmaBombEnt[i][X], 0);

						//Check:
						if(IsValidEdict(Effect))
						{

							//Spark:
							AcceptEntityInput(Effect, "Explode");

							//Create Damage:
							ExplosionDamage(i, PlasmaBombEnt[i][X], EntOrigin, DMG_RADIATION);
						}
					}

					//Remove After 30 Seconds!
					if(PlasmaBombExplode[i][X] == -30)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 30, X);

						//Explode:
						RemovePlasmaBomb(i, X, false);
					}

					//Show CrimeHud:
					ShowPlasmaBombToAll(EntOrigin, i, X);
				}
			}
		}
	}
}

public Action:PlasmaBombHud(Client, Ent)
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
				if(PlasmaBombEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Bomb Already Armed:
					if(PlasmaBombExplode[i][X] > 0 && PlasmaBombExplode[i][X] <= 30)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "PlasmaBomb:\nPlasmaBomb will explode in\n(%i) Seconds", PlasmaBombExplode[i][X]);
					}

					//Override:
					else
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "PlasmaBomb:\nThis PlasmaBomb belongs to:\n%N!", i);
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
public Action:ShowPlasmaBombToAll(Float:PlasmaBombOrigin[3], Client, X)
{

	//Declare:
	new Float:ClientOrigin[3];

	//Initialize:
	GetEntPropVector(Client, Prop_Send, "m_vecOrigin", ClientOrigin);

	//Initialize:
	new Float:Dist = GetVectorDistance(ClientOrigin, PlasmaBombOrigin);

	//In Distance:
	if(Dist <= 800)
	{

		//Initulize:
		PlasmaBombOrigin[2] += 1.0;

		//Declare:
		new ColorPlasmaBomb[4] = {255, 50, 50, 250};

		//Check:
		if(PlasmaBombExplode[Client][X] > 20 && PlasmaBombExplode[Client][X] < 30)
		{

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", PlasmaBombOrigin, PlasmaBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		if(PlasmaBombExplode[Client][X] > 10 && PlasmaBombExplode[Client][X] < 21)
		{

			//Initulize:
			ColorPlasmaBomb[0] = 150;
			ColorPlasmaBomb[1] = 150;
			ColorPlasmaBomb[2] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", PlasmaBombOrigin, PlasmaBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Check:
		else if(PlasmaBombExplode[Client][X] > 0 && PlasmaBombExplode[Client][X] < 11)
		{

			//Initulize:
			ColorPlasmaBomb[0] = 50;
			ColorPlasmaBomb[1] = 50;
			ColorPlasmaBomb[2] = 255;

			//Emit:
			EmitAmbientSound("buttons/lightswitch2.wav", PlasmaBombOrigin, PlasmaBombEnt[Client][X], SNDLEVEL_NORMAL);
		}

		//Show To Client:
		TE_SetupBeamRingPoint(PlasmaBombOrigin, 1.0, 100.0, Laser(), Sprite(), 0, 10, 0.7, 5.0, 0.5, ColorPlasmaBomb, 10, 0);

		//End Temp:
		TE_SendToAll();
	}
}

public Action:RemovePlasmaBomb(Client, X, bool:Explode)
{

	//Can Explode:
	if(Explode)
	{

		//Explode:
		CreateExplosion(Client, PlasmaBombEnt[Client][X]);
	}

	//Initulize:
	PlasmaBombUse[Client][X] = 0;

	PlasmaBombExplode[Client][X] = 0;

	//Check:
	if(IsValidAttachedEffect(PlasmaBombEnt[Client][X]))
	{

		//Remove:
		RemoveAttachedEffect(PlasmaBombEnt[Client][X]);
	}

	//Accept:
	AcceptEntityInput(PlasmaBombEnt[Client][X], "kill");

	//Inituze:
	PlasmaBombEnt[Client][X] = -1;
}

public bool:CreatePlasmaBomb(Client, Id, Time, Value, Float:Position[3], Float:Angle[3], bool:Connected)
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
		InsertSpawnedItem(Client, 30, Id, Time, 0, 0, "", Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - You have just spawned a PlasmaBomb!");
	}

	//Initulize:
	PlasmaBombUse[Client][Id] = Time;

	PlasmaBombExplode[Client][Id] = 0;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	DispatchKeyValue(Ent, "model", PlasmaBombModel);

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PlasmaBombEnt[Client][Id] = Ent;

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
public Action:Command_TestPlasmaBomb(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testplasmabomb <Id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32]; new Id;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	Id = StringToInt(sId);

	if(PlasmaBombEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money PlasmaBomb with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid PlasmaBomb %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreatePlasmaBomb
	CreatePlasmaBomb(Client, Id, 0, 0, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsPlasmaBombUse(Client, ItemId)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
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
			Ent = HasClientPlasmaBomb(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn PlasmaBomb:
				if(CreatePlasmaBomb(Client, Y, 0, 0, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-PlasmaBomb|\x07FFFFFF - You already have too many Fire Bombs, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}