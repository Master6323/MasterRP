//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hud_included_
  #endinput
#endif
#define _rp_hud_included_

//Debug
#define DEBUG
//Euro - � dont remove this!
//€ = �

public Action:PluginInfo_Hud(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Dynamic Hud!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Show Player Hud
public Action:ShowClientHud(Client)
{

	//Declare:
	decl String:FormatMessage[1024];

	//Declare:
	new len = 0;

	//Setup Hud:
	SetHudTextParams(0.005, 0.005, 1.0, GetClientHudColor(Client, 0), GetClientHudColor(Client, 1), GetClientHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

	//Format:
	len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N]\nCash: %s %s\nBank: %s %s\nJob: %s\nJob Salary: €%i in %is", Client, IntToMoney(GetCash(Client)), GetCashState(Client), IntToMoney(GetBank(Client)), GetCashState(Client), GetJob(Client), GetJobSalary(Client), GetSalaryCheck());

	//Declare
	new More = GetMoreHud(Client);

	//More Hud Enabled
	if(More == 1)
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nNext raise in %i Min", (RoundToCeil(Pow(float(GetJobSalary(Client)), 3.0)) - GetNextJobRase(Client)));

		//Is Critical:
		if(GetIsCritical(Client))
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nIn Critical Condition");
		}

		//Is Hunger Enabled:
		if(IsHungerDisabled() == 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHunger: %s", GetHungerString(Client));
		}

		//Has Harvest:
		if(GetHarvest(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nHarvest: %ig", GetHarvest(Client));
		}

		//Has Meth:
		if(GetMeth(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nMeth: %ig", GetMeth(Client));
		}

		//Has Pills:
		if(GetPills(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nPills: %ig", GetPills(Client));
		}

		//Has Cocain:
		if(GetCocain(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCocain: %ig", GetCocain(Client));
		}

		//Has Cocain:
		if(GetRice(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nRice: %ig", GetRice(Client));
		}

		//Has Resources:
		if(GetResources(Client) > 0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nResources: %ig", GetResources(Client));
		}

		//Has Resources:
		if(GetBitCoin(Client) != 0.0)
		{

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBTC: %f", GetBitCoin(Client));
		}
	}

	//Is In Jail:
	if(IsCuffed(Client))
	{

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Client), GetMaxJailTime(Client));
	}

	//Show Hud Text:
	ShowHudText(Client, 0, FormatMessage);
}

//Show Player Hud
Action:ShowPlayerNotice(Client, Player)
{

	//Declare:
	decl Float:ClientOrigin[3], Float:EntOrigin[3], String:FormatMessage[255];

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Declare:
	new len = 0;

	//Connected:
	if(Player > 0 && IsClientConnected(Player) && IsClientInGame(Player) && Player < GetMaxClients())
	{

		//Initialize:
		GetClientAbsOrigin(Player, EntOrigin);

		//Declare:
		new Float:Dist = GetVectorDistance(ClientOrigin, EntOrigin);

		//Declare:
		new PlayerHP = GetClientHealth(Player);

		//In Distance:
		if(Dist <= 350 && !(GetClientButtons(Client) & IN_SCORE))
		{

			//Setup Hud:
			SetHudTextParams(-1.0, -0.805, 1.0, GetPlayerHudColor(Client, 0), GetPlayerHudColor(Client, 1), GetPlayerHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

			//Declare:
			new Salary = GetJobSalary(Player);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% \nJob: %s\nJobSalary: €%i\nEnergy: %i", Player, PlayerHP, GetJob(Player), Salary, GetEnergy(Player));

			//Is Same Team:
			if(IsCop(Client) || IsAdmin(Client))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCash: %s\nBank: %s", IntToMoney(GetCash(Player)), IntToMoney(GetBank(Player)));

				//Is In Jail:
				if(IsCuffed(Player))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nJailtime: %i/%i", GetJailTime(Player), GetMaxJailTime(Player));
				}

				//Has Player Got Crime:
				if(GetCrime(Player) > 500)
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCrime: %i", (GetCrime(Player) / 1000));
				}
			}

			//Has Player Got Bounty:
			if(!IsCop(Client) && GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: €%i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Show Hud Text:
			ShowHudText(Client, 1, FormatMessage);
		}

		//Override
		else if((Dist > 350 && Dist < 1000))
		{

			//Setup Hud:
			SetHudTextParams(-1.0, -0.805, 1.0, GetPlayerHudColor(Client, 0), GetPlayerHudColor(Client, 1), GetPlayerHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

			//Show Hud Text:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "[%N] \nHealth: %i% ",Player, PlayerHP);

			//Has Player Got Bounty:
			if(GetBounty(Player) > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nBounty: %i", GetBounty(Player));
			}

			//IsCuffed:
			if(IsCuffed(Player))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\nCUFFED!");
			}

			//Show Hud Text:
			ShowHudText(Client, 1, FormatMessage);
		}
	}
}

//Show Player Hud
public Action:showAdminStats(Client)
{

	//Declare:
	decl String:FormatMessage[1024];

	//Setup Hud:
	SetHudTextParams(-1.0, 1.0, 1.0, GetClientHudColor(Client, 0), GetClientHudColor(Client, 1), GetClientHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "\nEnergy: %i\nCop Cuffs: %i\nCop Minutes : %i\nExperience: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client), GetJobExperience(Client));

	//Show Hud Text:
	ShowHudText(Client, 3, FormatMessage);
}

//Show Player Hud
public Action:showCopStats(Client)
{

	//Declare:
	decl String:FormatMessage[1024];

	//Setup Hud:
	SetHudTextParams(-1.0, 1.0, 1.0, GetClientHudColor(Client, 0), GetClientHudColor(Client, 1), GetClientHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "Energy\nCuffs: %i\nCop Minutes: %i", GetEnergy(Client), GetCopCuffs(Client), GetCopMinutes(Client));

	//Show Hud Text:
	ShowHudText(Client, 3, FormatMessage);
}

//Show Player Hud
public Action:showAddedStats(Client)
{

	//Declare:
	decl String:FormatMessage[1024];

	//Setup Hud:
	SetHudTextParams(-1.0, 1.0, 1.0, GetClientHudColor(Client, 0), GetClientHudColor(Client, 1), GetClientHudColor(Client, 2), 200, 0, 6.0, 0.1, 0.2);

	//Format:
	Format(FormatMessage, sizeof(FormatMessage), "\nEnergy: %i\nExperience: %i", GetEnergy(Client), GetJobExperience(Client));

	//Show Hud Text:
	ShowHudText(Client, 3, FormatMessage);
}

//Crime Hud:
public Action:ShowCrimeHud(Client)
{

	//Declare:
	decl String:Message[512];

	new ClientCount = 0;

	//Initulize:
	new len = 0;

	//Start Hud Message:
	len += Format(Message[len], sizeof(Message)-len,"\nCrime Level:");

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i ++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i))
		{

			//To Many Clients:
			if(GetCrime(i) > 500 && ClientCount < 7)
			{

				//Initialize:
				ClientCount++;

				//Has Bounty:
				if(GetBounty(i) > 0)
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (€%i)", i, GetBounty(i));
				}

				//Is Alive:
				else if(IsPlayerAlive(i) && GetCrime(i) > 500)
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (%i)", i, RoundToNearest(GetCrime(i) / 1000.0));
				}

				//Override:
				else
				{

					//Format Message:
					len += Format(Message[len], sizeof(Message) - len,"\n%N (%i) (Dead)", i, RoundToNearest(GetCrime(i) / 1000.0));
				}
			}
		}
	}

	//Has Player Got Crime/Bounty:
	if((ClientCount > 0 && GetCrime(Client) > 500) || (ClientCount > 0 && (IsCop(Client) || IsAdmin(Client))))
	{

		//Setup Hud:
		SetHudTextParams(0.950, 0.015, 1.0, 255, 50, 50, 200, 0, 6.0, 0.1, 0.2);

		//Show Hud Text:
		ShowHudText(Client, 2, "%s", Message);
	}
}

public Action:ShowEntityNotice(Client, Ent)
{

	//Is Valid Sleeping Couch:
	if(IsValidCouch(Ent))
	{

		//Show Hud:
		CouchHud(Client, Ent);
	}

	//Is Valid Money Printer:
	if(IsValidPrinter(Ent))
	{

		//Show Hud:
		PrinterHud(Client, Ent);
	}

	//Is Valid Drug Plant:
	if(IsValidPlant(Ent))
	{

		//Show Hud:
		PlantHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidMeth(Ent))
	{

		//Show Hud:
		MethHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidPills(Ent))
	{

		//Show Hud:
		PillsHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidCocain(Ent))
	{

		//Show Hud:
		CocainHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidRice(Ent))
	{

		//Show Hud:
		RiceHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidBomb(Ent))
	{

		//Show Hud:
		BombHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidGunLab(Ent))
	{

		//Show Hud:
		GunLabHud(Client, Ent);
	}

	//Is Valid Kitchen:
	if(IsValidMicrowave(Ent))
	{

		//Show Hud:
		MicrowaveHud(Client, Ent);
	}

	//Is Valid Shield:
	if(IsValidShield(Ent))
	{

		//Show Hud:
		ShieldHud(Client, Ent);
	}

	//IsFire Bomb:
	if(IsValidFireBomb(Ent))
	{

		//Show Hud:
		FireBombHud(Client, Ent);
	}

	//Is Valid dGenerator:
	if(IsValidGenerator(Ent))
	{

		//Show Hud:
		GeneratorHud(Client, Ent);
	}

	//Is Valid dGenerator:
	if(IsValidBitCoinMine(Ent))
	{

		//Show Hud:
		BitCoinMineHud(Client, Ent);
	}

	//Is Valid Propane Tank:
	if(IsValidPropaneTank(Ent))
	{

		//Show Hud:
		PropaneTankHud(Client, Ent);
	}

	//Is Valid Phosphoru Tank:
	if(IsValidPhosphoruTank(Ent))
	{

		//Show Hud:
		PhosphoruTankHud(Client, Ent);
	}

	//Is Valid Sodium Tub:
	if(IsValidSodiumTub(Ent))
	{

		//Show Hud:
		SodiumTubHud(Client, Ent);
	}

	//Is Valid HcAcid Tub:
	if(IsValidHcAcidTub(Ent))
	{

		//Show Hud:
		HcAcidTubHud(Client, Ent);
	}

	//Is Valid HcAcid Tub:
	if(IsValidAcetoneCan(Ent))
	{

		//Show Hud:
		AcetoneCanHud(Client, Ent);
	}

	//Is Valid Seeds:
	if(IsValidSeeds(Ent))
	{

		//Show Hud:
		SeedsHud(Client, Ent);
	}

	//Is Valid Lamp:
	if(IsValidLamp(Ent))
	{

		//Show Hud:
		LampHud(Client, Ent);
	}

	//Is Valid Erythroxylum:
	if(IsValidErythroxylum(Ent))
	{

		//Show Hud:
		ErythroxylumHud(Client, Ent);
	}

	//Is Valid Benzocaine:
	if(IsValidBenzocaine(Ent))
	{

		//Show Hud:
		BenzocaineHud(Client, Ent);
	}

	//Is Valid Battery:
	if(IsValidBattery(Ent))
	{

		//Show Hud:
		BatteryHud(Client, Ent);
	}

	//Is Valid Toulene:
	if(IsValidToulene(Ent))
	{

		//Show Hud:
		TouleneHud(Client, Ent);
	}

	//Is Valid SAcidTub:
	if(IsValidSAcidTub(Ent))
	{

		//Show Hud:
		SAcidTubHud(Client, Ent);
	}

	//Is Valid Ammonia:
	if(IsValidAmmonia(Ent))
	{

		//Show Hud:
		AmmoniaHud(Client, Ent);
	}

	//Is Valid Bong:
	if(IsValidBong(Ent))
	{

		//Show Hud:
		BongHud(Client, Ent);
	}

	//Is Valid Smoke Bomb:
	if(IsValidSmokeBomb(Ent))
	{

		//Show Hud:
		SmokeBombHud(Client, Ent);
	}

	//Is Valid Water Bomb:
	if(IsValidWaterBomb(Ent))
	{

		//Show Hud:
		WaterBombHud(Client, Ent);
	}

	//Is Valid Plasma Bomb:
	if(IsValidPlasmaBomb(Ent))
	{

		//Show Hud:
		PlasmaBombHud(Client, Ent);
	}

	//Is Valid Thunper:
	if(IsValidThumper(Ent))
	{

		//Show Hud:
		ThumperHud(Client, Ent);
	}

	//Is NPC Thunper:
	if(!IsValidNpc(Ent) && IsValidDymamicNpc(Ent))
	{

		//Show Hud:
		NpcHealthHud(Client, Ent);
	}

	//Valid Door:
	if(IsValidDoor(Ent))
	{

		//Show Hud:
		DoorHud(Client, Ent);
	}

	if(IsValidMoneySafe(Ent))
	{

		//ShowHud:
		MoneySafeHud(Client, Ent);
	}
}
