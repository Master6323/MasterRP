//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_init_included_
  #endinput
#endif
#define _rp_init_included_

new HudTimer = 0;

public Action:PluginInfo_init(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "init!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.05.21");
}

initHudTicker()
{

	//Draw Player Hud:
	CreateTimer(0.1, ManageClientHud, _, TIMER_REPEAT);

	//Handle:
	CreateTimer(5.0, ManageClientTeam, _, TIMER_REPEAT);
}

//ManageTeams:
public Action:ManageClientTeam(Handle:Timer)
{

	//Client Team Fix Plugin:
	OnManageClientTeam();

	//Loop:
	for(new Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Check Health
			IsCriticalHealth(Client);
		}
	}
}

//Client Hud:
public Action:ManageClientHud(Handle:Timer)
{

	//Initulize:
	HudTimer += 1;

	//Check:
	if(HudTimer == 0)
	{

		//Create Water Bomb Timer Init:
		initWaterBombTime();

		//Create Plasma Bomb Timer Init:
		initPlasmaBombTime();
	}

	//Check:
	if(HudTimer == 1)
	{

		//Create Printer Timer Init:
		initPrintTime();

		//Create Meth Timer Init:
		initMethTime();

		//Create Pills Timer Init:
		initPillsTime();
	}

	//Check:
	if(HudTimer == 2)
	{

		//Create Plant Timer Init:
		initPlantTime();

		//Create Cocain Timer Init:
		initCocainTime();

		//Create Rice Timer Init:
		initRiceTime();
	}

	//Check:
	if(HudTimer == 3)
	{

		//Create Bomb Timer Init:
		initBombTime();

		//Create Gun Lab Timer Init:
		initGunLabTime();

		//Create Battery Timer Init:
		initBatteryTime();
	}

	//Check:
	if(HudTimer == 4)
	{

		//Create Microwave Timer Init:
		initMicrowaveTime();

		//Create Shield Timer Init:
		initShieldTime();

		//Create Toulene Timer Init:
		initTouleneTime();
	}

	//Check:
	if(HudTimer == 5)
	{

		//Create Fire Bomb Timer Init:
		initFireBombTime();

		//Create Generator Timer Init:
		initGeneratorTime();

		//Create SAcidTub Timer Init:
		initSAcidTubTime();
	}

	//Check:
	if(HudTimer == 6)
	{

		//Create BitCoin Mine Timer Init:
		initBitCoinMineTime();

		//Create Propane Tank Timer Init:
		initPropaneTankTime();

		//Create Ammonia Timer Init:
		initAmmoniaTime();
	}

	//Check:
	if(HudTimer == 7)
	{

		//Create Phosphoru Tank Timer Init:
		initPhosphoruTankTime();

		//Create Sodium Tub Timer Init:
		initSodiumTubTime();

		//Create SAcid Tub Timer Init:
		initSAcidTubTime();
	}

	//Check:
	if(HudTimer == 8)
	{

		//Create HcAcid Tub Timer Init:
		initHcAcidTubTime();

		//Create Acetone Can Timer Init:
		initAcetoneCanTime();

		//Create Toulene Timer Init:
		initTouleneTime();
	}

	//Check:
	if(HudTimer == 9)
	{

		//Create Seeds Timer Init:
		initSeedsTime();

		//Create Lamp Timer Init:
		initLampTime();

		//Create Bong Timer Init:
		initBongTime();
	}

	//Check:
	if(HudTimer == 10)
	{

		//Create Erythroxylum Timer Init:
		initErythroxylumTime();

		//Create Benzocaine Timer Init:
		initBenzocaineTime();

		//Create SmokeBomb Timer Init:
		initSmokeBombTime();
	}

	//Check:
	if(HudTimer == 5 || HudTimer == 10)
	{

		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
			{

				//Declare:
				new Ent = GetClientAimTarget(Client, false);

				//Connected:
				if(Ent > GetMaxClients() + 1 && IsValidEntity(Ent) && !LookingAtWall(Client))
				{

					//Show Hud:
					ShowEntityNotice(Client, Ent);
				}

				//Override:
				if(Ent > 0 && Ent < GetMaxClients() && IsClientConnected(Ent) && !LookingAtWall(Client))
				{

					//Show Hud:
					ShowPlayerNotice(Client, Ent);
				}
			}
		}
	}

	//Second Check:
	if(HudTimer >= 10)
	{

		//Initulize:
		HudTimer = -1;

		//Init Job System Timer
		initSalaryTimer();

		//Crate Timer Init:
		initCrateTick();

		//Banking NPC Rob Timer:
		initBankRobbing();

		//Vendor NPC Rob Timer:
		initVendorRobbing();

		//Money Safe Rob Timer:
		iRobTimer();

		//Loop:
		for(new Client = 1; Client <= GetMaxClients(); Client++)
		{

			//Connected:
			if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
			{

				//Show Client Hud
				ShowClientHud(Client);

				//Draw Hud:
				ShowCrimeHud(Client);

				//Added Hud Info:
				if(GetHudInfo(Client) == 1 && IsSleeping(Client) == -1)
				{

					//Is Admin:
					if(IsAdmin(Client))
					{

						//Draw Hud:
						showAdminStats(Client);
					}

					//Is Cop:
					else if(IsCop(Client))
					{

						//Draw Hud:
						showCopStats(Client);
					}

					//Override:
					else
					{

						//Draw Hud:
						showAddedStats(Client);
					}
				}

				//Show Tracers:
				OnClientShowTracers(Client);

				//ManageNoKillZone:
				NokillZone(Client);

				//Init Jail Timer:
				IntJailTimer(Client);

				//Quick Check:
				ClientCriticalOverride(Client);

				//Init Drugs:
				OnDrugTick(Client);

				//Init Crime Removal and Bounty Check:
				initCrimeTimer(Client);
			}
		}
	}
}
