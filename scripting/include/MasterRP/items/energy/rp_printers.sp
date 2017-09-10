//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_printers_included_
  #endinput
#endif
#define _rp_printers_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

//Define:
#define MAXITEMSPAWN		10

//Printers:
static PrinterEnt[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Float:PrinterInk[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PrinterPaper[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PrinterLevel[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static PrinterHealth[MAXPLAYERS + 1][MAXITEMSPAWN + 1];
static Printed[MAXPLAYERS + 1][MAXITEMSPAWN + 1];

//static String:MasterPrinterModel[256] = "models/props_c17/consolebox01a.mdl";
//static String:PrinterModel[256] = "models/props_lab/reciever01a.mdl";

public Action:PluginInfo_Printers(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Money Printers!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initPrinters()
{

	//Commands:
	RegAdminCmd("sm_testprinter", Command_TestPrinter, ADMFLAG_ROOT, "<Id> <Time> - Creates a printer");
}

public initDefaultPrinters(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Initulize:
		PrinterEnt[Client][X] = -1;

		Printed[Client][X] = 0;

		PrinterInk[Client][X] = 0.0;

		PrinterPaper[Client][X] = 0;

		PrinterHealth[Client][X] = -1;

		PrinterLevel[Client][X] = -1;
	}
}

public bool:IsValidPrinter(Ent)
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
				if(PrinterEnt[i][X] == Ent)
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

public HasClientPrinter(Client, Id)
{

	//Is Valid:
	if(PrinterEnt[Client][Id] > 0)
	{

		//Return:
		return PrinterEnt[Client][Id];
	}

	//Return:
	return -1;
}

public Float:GetPrinterInk(Client, Id)
{

	//Return:
	return PrinterInk[Client][Id];
}

public SetPrinterInk(Client, Id, Float:Amount)
{

	//Initulize:
	PrinterInk[Client][Id] = Amount;
}

public GetPrinterPaper(Client, Id)
{

	//Return:
	return PrinterPaper[Client][Id];
}

public SetPrinterPaper(Client, Id, Amount)
{

	//Initulize:
	PrinterPaper[Client][Id] = Amount;
}

public GetPrinterMoney(Client, Id)
{

	//Return:
	return Printed[Client][Id];
}

public GetPrinterLevel(Client, Id)
{

	//Return:
	return PrinterLevel[Client][Id];
}

public GetPrinterHealth(Client, Id)
{

	//Return:
	return PrinterHealth[Client][Id];
}

public Action:OnPrinterUse(Client, Ent)
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
						if(PrinterEnt[i][X] == Ent)
						{

							//Declare:
							new Earns = Printed[i][X];

							//Is Cop:
							if(IsCop(Client))
							{

								//Remove From DB:
								RemoveSpawnedItem(i, 2, X);

								//Remove:
								RemovePrinter(i, X, true);

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Printer|\x07FFFFFF - A cop \x0732CD32%N\x07FFFFFF has just destroyed your Money Printer!", Client);

								//Initulize:
								SetBank(Client, (GetBank(Client) + 2500));

								//Set Menu State:
								BankState(Client, 2500);

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have just destroyed a Money Printer. reseaved €\x0732CD32500\x07FFFFFF!");

								//Initulize:
								SetCopExperience(Client, (GetCopExperience(Client) + 2));
							}

							//Is Valid:
							else if(Earns != 0)
							{

								//Initulize:
								Printed[i][X] = 0;

								SetCash(Client, (GetCash(Client) + Earns));

								//Set Menu State:
								CashState(Client, Earns);

								//Set Crime:
								SetCrime(Client, (GetCrime(Client) + (Earns / 2)));
							}

							//Is Client Own:
							if(Earns == 0)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have collected no money from this printer!");
							}

							//Is Client Own:
							else if(Client == i)
							{

								//Print:
								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have collected €\x0732CD32%i\x07FFFFFF from your Printer!", Earns);
							}

							//Override:
							else
							{

								//Print:
								CPrintToChat(i, "\x07FF4040|RP-Printer|\x07FFFFFF - %N has stolen Money from your Printer!", Client);

								CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have Stolen €\x0732CD32%i\x07FFFFFF from this printer!", Earns);
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
			CPrintToChat(Client, "\x07FF4040|RP-Printers|\x07FFFFFF - Press \x0732CD32<<Use>>\x07FFFFFF To Use Printer!");

			//Initulize:
			SetLastPressedE(Client, GetGameTime());
		}
	}
}

public Action:initPrintTime()
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
				if(IsValidEdict(PrinterEnt[i][X]))
				{

					//Check:
					CheckGeneratorToPrinter(i, X);

					//Declare:
					new Float:EntOrigin[3];

					//Initialize:
					GetEntPropVector(PrinterEnt[i][X], Prop_Send, "m_vecOrigin", EntOrigin);

					//Is Valid:
					if(StrContains(GetJob(i), "Counterfeiter", false) != -1 || StrContains(GetJob(i), "Crime Lord", false) != -1 || GetDonator(i) > 0 || IsAdmin(i))
					{

						//Declare:
						new Level = PrinterLevel[i][X];

						//Check:
						if(PrinterPaper[i][X] > 0 && PrinterInk[i][X] > 0.0 && Printed[i][X] < (Level * 50000))
						{

							//Declare:
							new Random = GetRandomInt(1, 5);

							//Valid:
							if(Random == 1)
							{

								//Check:
								if(PrinterInk[i][X] - float((Level) / 10) > 0.0)
								{

									//Initulize:
									PrinterInk[i][X] -= float(Level) / 10;
								}

								//Override:
								else
								{

									//Initulize:
									PrinterInk[i][X] = 0.0;
								}

								//Check:
								if(PrinterPaper[i][X] - Level > 0)
								{

									//Initulize:
									PrinterPaper[i][X] -= Level;
								}

								//Override:
								else
								{

									//Initulize:
									PrinterPaper[i][X] = 0;
								}

								//Initulize:
								Random = (5 * Level);

								Printed[i][X] += Random;
							}

							//Random Spark:
							if(Random > 1)
							{
	
								//EntCheck:
								if(CheckMapEntityCount() < 2000)
								{

									//Temp Ent:
									TE_SetupSparks(EntOrigin, NULL_VECTOR, 5, 5);

									//Send:
									TE_SendToAll();
								}
							}
						}
					}

					//Show CrimeHud:
					ShowIllegalItemToCops(EntOrigin);
				}
			}
		}
	}
}

//Check to see if the generator is in distance
public Action:CheckGeneratorToPrinter(Client, Y)
{

	//Loop:
	for(new X = 0; X < 2047; X++)
	{

		//Is Valid:
		if(IsValidEdict(X))
		{

			//Check:
			if(IsValidGenerator(X) && IsInDistance(PrinterEnt[Client][Y], X))
			{

				//Declare:
				new Id = GetGeneratorIdFromEnt(X);

				//Check:
				if(GetGeneratorEnergy(Client, Id) - 0.10 > 0)
				{

					//Initulize:
					SetGeneratorEnergy(Client, Id, (GetGeneratorEnergy(Client, Id) - 0.10));

					//Declare:
					new Level = PrinterLevel[Client][Y];

					//Check:
					if(PrinterPaper[Client][Y] > 0 && PrinterInk[Client][Y] > 0.0 && Printed[Client][Y] < (Level * 50000))
					{

						//Declare:
						new Random = GetRandomInt(1, 5);

						//Valid:
						if(Random == 1)
						{

							//Check:
							if(PrinterInk[Client][Y] - float(Level / 10) > 0.0)
							{

								//Initulize:
								PrinterInk[Client][Y] -= float(Level) / 10;
							}

							//Override:
							else
							{

								//Initulize:
								PrinterInk[Client][Y] = 0.0;
							}

							//Check:
							if(PrinterPaper[Client][Y] - Level > 0)
							{

								//Initulize:
								PrinterPaper[Client][Y] -= Level;
							}

							//Override:
							else
							{

								//Initulize:
								PrinterPaper[Client][Y] = 0;
							}

							//Initulize:
							Random = (5 * Level);

							Printed[Client][Y] += Random;
						}
					}

					//Stop:
					break;
				}
			}
		}
	}
}

public Action:PrinterHud(Client, Ent)
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
				if(PrinterEnt[i][X] == Ent)
				{

					//Declare:
					decl String:FormatMessage[512];

					//Declare:
					new Level = PrinterLevel[i][X];

					//Basic Printer:
					if(Level == 1)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Printers (Basic):\nPrinting Paper: %i Sheets\nPrinter Ink: %0.2fmL\nPrinted (€%i)\nHealth: %i", PrinterPaper[i][X], PrinterInk[i][X], Printed[i][X], PrinterHealth[i][X]);
					}

					//Advanced Printer:
					if(Level == 2)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Printers (Advanced):\nPrinting Paper: %i Sheets\nPrinter Ink: %0.2fmL\nPrinted (€%i)\nHealth: %i", PrinterPaper[i][X], PrinterInk[i][X], Printed[i][X], PrinterHealth[i][X]);
					}

					//Master Printer:
					if(Level == 3)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Printers (Master):\nPrinting Paper: %i Sheets\nPrinter Ink: %0.2fmL\nPrinted (€%i)\nHealth: %i", PrinterPaper[i][X], PrinterInk[i][X], Printed[i][X], PrinterHealth[i][X]);
					}

					//Ultimate Printer:
					if(Level == 4)
					{

						//Format:
						Format(FormatMessage, sizeof(FormatMessage), "Printers (Ultimate):\nPrinting Paper: %i Sheets\nPrinter Ink: %0.2fmL\nPrinted (€%i)\nHealth: %i", PrinterPaper[i][X], PrinterInk[i][X], Printed[i][X], PrinterHealth[i][X]);
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

public Action:RemovePrinter(Client, X, bool:Result)
{

	//Declare:
	new Float:PrinterOrigin[3];

	//Get Prop Data:
	GetEntPropVector(PrinterEnt[Client][X], Prop_Send, "m_vecOrigin", PrinterOrigin);

	//EntCheck:
	if(CheckMapEntityCount() < 2047 && Result)
	{

		//Temp Ent:
		TE_SetupSparks(PrinterOrigin, NULL_VECTOR, 5, 5);

		//Send:
		TE_SendToAll();

		//Temp Ent:
		TE_SetupExplosion(PrinterOrigin, Explode(), 5.0, 1, 0, 600, 5000);

		//Send:
		TE_SendToAll();
	}

	//Emit Sound:
	//EmitAmbientSound("ambient/explosions/explode_5.wav", PrinterOrigin, SNDLEVEL_RAIDSIREN);

	//Initulize:
	PrinterPaper[Client][X] = 0;

	PrinterInk[Client][X] = 0.0;

	PrinterHealth[Client][X] = 0;

	PrinterLevel[Client][X] = 0;

	Printed[Client][X] = 0;

	//Accept:
	AcceptEntityInput(PrinterEnt[Client][X], "kill");

	//Inituze:
	PrinterEnt[Client][X] = -1;
}

public bool:CreatePrinter(Client, X, Value, Float:Ink, Paper, Level, Health, Float:Position[3], Float:Angle[3], bool:Connected)
{

	//Check
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
			CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - Unable to spawn Printer outside of world");

			//Return:
			return false;
		}

		//Declare:
		decl String:AddedData[64];

		//Format:
		Format(AddedData, sizeof(AddedData), "%f^%i", Ink, Health);

		//Add Spawned Item to DB:
		InsertSpawnedItem(Client, 2, X, Value, Paper, Level, AddedData, Position, Angle);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You have just spawned a Money Printer!");
	}

	//Initulize:
	Printed[Client][X] = Value;

	PrinterPaper[Client][X] = Paper;

	PrinterInk[Client][X] = Ink;

	PrinterHealth[Client][X] = Health;

	PrinterLevel[Client][X] = Level;

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Dispatch:
	DispatchKeyValue(Ent, "solid", "0");

	if(Level <= 2)
		DispatchKeyValue(Ent, "model", "models/props_lab/reciever01a.mdl");
	else
		DispatchKeyValue(Ent, "model", "models/props_c17/consolebox01a.mdl");

	//Spawn:
	DispatchSpawn(Ent);

	//TelePort:
	TeleportEntity(Ent, Position, Angle, NULL_VECTOR);

	//Initulize:
	PrinterEnt[Client][X] = Ent;

	//Damage Hook:
	SDKHook(Ent, SDKHook_OnTakeDamage, OnDamageClientPrinter);

	//Set Weapon Color
	SetEntityRenderColor(Ent, 255, (PrinterHealth[Client][X] / 2), (PrinterHealth[Client][X] / 2), 255);

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
public Action:Command_TestPrinter(Client, Args)
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
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_testprinter <Id> <Money> <Level>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:sId[32], String:sValue[32], String:sLevel[32]; new Id, Value, Level;

	//Initialize:
	GetCmdArg(1, sId, sizeof(sId));

	//Initialize:
	GetCmdArg(2, sValue, sizeof(sValue));

	GetCmdArg(3, sLevel, sizeof(sLevel));

	Id = StringToInt(sId);

	Value = StringToInt(sValue);

	Level = StringToInt(sLevel);

	if(PrinterEnt[Client][Id] > 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have already created a money printer with #%i!", Id);

		//Return:
		return Plugin_Handled;
	}

	if(Id < 1 && Id > MAXITEMSPAWN)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid Printer %s", sId);

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	new Float:Pos[3], Float:Ang[3];

	//CreatePrinter
	CreatePrinter(Client, Id, Value, float(Level * 125), (Level * 1250), Level, 500, Pos, Ang, false);

	//Return:
	return Plugin_Handled;
}

public Action:OnItemsPrinterUse(Client, ItemId)
{

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());
	}

	//Is Cop:
	else if(IsCop(Client))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - Cops can't use any illegal items.");
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
		MaxSlots += GetItemAmount(Client, 304);

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
			Ent = HasClientPrinter(Client, Y);

			//Check:
			if(!IsValidEdict(Ent))
			{

				//Spawn Printer:
				if(CreatePrinter(Client, Y, 0, (StringToFloat(GetItemVar(ItemId)) * 125), (StringToInt(GetItemVar(ItemId)) * 1250), StringToInt(GetItemVar(ItemId)), 500, Position, EyeAngles, false))
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
					CPrintToChat(Client, "\x07FF4040|RP-Printer|\x07FFFFFF - You already have too many Printers, (\x0732CD32%i\x07FFFFFF) Max!", MaxSlots);
				}
			}
		}
	}
}

//Event Damage:
public Action:OnDamageClientPrinter(Ent, &Ent2, &inflictor, &Float:Damage, &damageType)
{

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Loop:
		for(new X = 1; X < MAXITEMSPAWN; X++)
		{

			//Is Valid:
			if(PrinterEnt[i][X] == Ent)
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
							if(PrinterHealth[i][X] + RoundFloat(Damage / 2) > 500)
							{

								//Initulize:
								PrinterHealth[i][X] = 500;
							}

							//Override:
							else
							{

								//Initulize:
								PrinterHealth[i][X] += RoundFloat(Damage / 2);
							}

							//Set Weapon Color
							SetEntityRenderColor(Ent, 255, (PrinterHealth[i][X] / 2), (PrinterHealth[i][X] / 2), 255);

							//Check:
							if(PrinterHealth[i][X] > 100)
							{

								//Declare:
								new TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

								//Check:
								if(IsValidEdict(TempEnt))
								{

									//Kill:
									AcceptEntityInput(TempEnt, "kill");

									//Initulize:
									SetEntAttatchedEffect(TempEnt, 1, -1);
								}
							}
						}

						//Override:
						else
						{

							//Initulize:
							DamageClientPrinter(PrinterEnt[i][X], Damage, Ent2);
						}
					}

					//Override:
					else
					{

						//Initulize:
						DamageClientPrinter(PrinterEnt[i][X], Damage, Ent2);
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

public Action:DamageClientPrinter(Ent, &Float:Damage, &Attacker)
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
				if(PrinterEnt[i][X] == Ent)
				{

					//Initulize:
					if(Damage > 0.0) PrinterHealth[i][X] -= RoundFloat(Damage);

					//Check:
					if(PrinterHealth[i][X] > 0 && PrinterHealth[i][X] <= 100)
					{

						//Declare:
						new TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

						//Check:
						if(!IsValidEdict(TempEnt) && PrinterEnt[i][X] != -1)
						{

							//Explode:
							CreateExplosion(Attacker, PrinterEnt[i][X]);

							//Check:
							if(PrinterEnt[i][X] > 0)
							{

								//Initulize Effects:
								new Effect = CreateEnvFire(PrinterEnt[i][X], "null", "200", "700", "0", "Natural");

								SetEntAttatchedEffect(PrinterEnt[i][X], 1, Effect);
							}
						}
					}

					//Check:
					if(PrinterHealth[i][X] > 100)
					{

						//Declare:
						new TempEnt = GetEntAttatchedEffect(PrinterEnt[i][X], 1);

						//Check:
						if(IsValidEdict(TempEnt))
						{

							//Kill:
							AcceptEntityInput(TempEnt, "kill");

							//Initulize:
							SetEntAttatchedEffect(TempEnt, 1, -1);
						}
					}

					//Set Weapon Color
					SetEntityRenderColor(Ent, 255, (PrinterHealth[i][X] / 2), (PrinterHealth[i][X] / 2), 255);

					//Check:
					if(PrinterHealth[i][X] < 1)
					{

						//Remove From DB:
						RemoveSpawnedItem(i, 2, X);

						//Remove:
						RemovePrinter(i, X, true);
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

public bool:IsPrinterInDistance(Client)
{

	//Loop:
	for(new X = 1; X < MAXITEMSPAWN; X++)
	{

		//Is Valid:
		if(IsValidEdict(PrinterEnt[Client][X]))
		{

			//In Distance:
			if(IsInDistance(Client, PrinterEnt[Client][X]))
			{

				//Return:
				return true;
			}
		}
	}

	//Return:
	return false;
}

