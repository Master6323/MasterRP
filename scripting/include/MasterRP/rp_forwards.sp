//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_forwards_included_
  #endinput
#endif
#define _rp_forwards_included_

forward Action:OnClientTeam(Handle:Event, Client, NewTeam, OldTeam);

forward Action:OnClientSpawn(Client);

forward Action:OnClientShift(Client);

forward Action:OnClientName(Client, String:NewName[32], String:OldName[32]);

forward Action:OnClientChat(Client, Bool:IsTeamOnly, const String:Text[], maxlength);

forward Action:OnClientDied(Client, Attacker, String:ClientWeapon[32], String:PlayerWeapon[32], bool:headshot);

//MasterRP Forwards:
static Handle:ChatForward = INVALID_HANDLE;
static Handle:TeamForward = INVALID_HANDLE;
static Handle:DeathForward = INVALID_HANDLE;
static Handle:SpawnForward = INVALID_HANDLE;
static Handle:NameForward = INVALID_HANDLE;
static Handle:CvarForward = INVALID_HANDLE;

//Anti Spam:
static PrethinkBuffer[MAXPLAYERS + 1] = {0,...};

//Double - Jump:
#define MAXJUMP			1
static PrethinkJump[MAXPLAYERS + 1] = {0,...};
static Jump[MAXPLAYERS + 1] = {0,...};

//Map Running
static bool:MapRunning = false;

public Action:PluginInfo_Forwards(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Event Forwards!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Initation:
public OnPluginStart()
{

	//Print Server If Plugin Start:
	PrintToConsole(0, "|RolePlay| Core Successfully Loaded (v%s)!", PLUGINVERSION);

	//Setup Gameplay:
	IntHL2MP();

	//Setup Sql Connection:
	initSQL();

	initBans();

	//Spawn Plugin:
	initSpawn();

	initMoneySafe();

	initNoKillZone();

	initThumpers();

	initForwards();

	initRandomCrate();

	initPoliceDoors();

	initVipDoors();

	initAdminDoors();

	initJail();

	initWeaponMod();

	initBank();

	initCrime();

	initDonator();

	initLight();

	initHudTicker();

	initJobList();

	initStock();

	initGarbageZone();

	initJobSetup();

	initJobSytem();

	initPlayer();

	initTalkSounds();

	initSleeping();

	initnpc();

	initVendorBuy();

	initCvar();

	initPluginInfo();

	initPrinters();

	initPlants();

	initMeths();

	initPills();

	initCocain();

	initRice();

	initBomb();

	initGunLab();

	initMicrowave();

	initShield();

	initFireBomb();

	initGenerator();

	initBitCoinMine();

	initPropaneTank();

	initPhosphoruTank();

	initSodiumTub();

	initHcAcidTub();

	initAcetoneCan();

	initSeeds();

	initLamp();

	initErythroxylum();

	initBenzocaine();

	initBattery();

	initToulene();

	initSAcidTub();

	initAmmonia();

	initBong();

	initSmokeBomb();

	initWaterBomb();

	initPlasmaBomb();

	initItems();

	initItemList();

	initSpawnedItems();

	initNpcAntLionGuard();

	initNpcichthyosaur();

	initNpcHelicopter();

	initNpcDynamic();

	initNpcVortigaunt();

	initNpcDog();

	initNpcStrider();

	initNpcMetroPolice();

	initNpcZombie();

	initNpcPoisonZombie();

	initNpcHeadCrab();

	initNpcHeadCrabFast();

	initNpcHeadCrabBlack();

	initNpcTurretFloor();

	initNpcAdvisor();

	initNpcCrabSynth();

	initDoors();

	initDoorSystem();

	initNotice();

	initSaveDrugs();

	initLastStats();

	initHats();

	initSettings();

	initCarMod();

	initPrisionPod();

	initJeep();

	initApc();

	initProps();
}

//Initation:
public initForwards()
{

	//Handle Forwards:
	ChatForward = CreateGlobalForward("OnClientChat", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);

	TeamForward = CreateGlobalForward("OnClientTeam", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);

	DeathForward = CreateGlobalForward("OnClientDied", ET_Event, Param_Cell, Param_Cell, Param_String, Param_String, Param_Cell, Param_Cell);

	SpawnForward = CreateGlobalForward("OnClientSpawn", ET_Event, Param_Cell, Param_Cell);

	NameForward = CreateGlobalForward("OnClientName", ET_Event, Param_Cell, Param_String, Param_String, Param_Cell);

	CvarForward = CreateGlobalForward("OnCvarChange", ET_Event, Param_String, Param_String, Param_Cell);

	//Command Listener:
	AddCommandListener(CommandSay, "say_team");

	AddCommandListener(CommandSay, "say");

	//Event Hooking:
	HookEvent("player_team", EventTeam_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_death", EventDeath_Forward);

	//Event Hooking:
	HookEvent("player_changename", EventChangeName_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_spawn", Eventspawn_Forward);

	//Event Hooking:
	HookEvent("player_disconnect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("player_connect", StopEvent_Forward, EventHookMode_Pre);

	//Event Hooking:
	HookEvent("server_cvar", ServerCvarEvent_Forward, EventHookMode_Pre);

	//Loop:
	for(new Client = 1; Client <= GetMaxClients(); Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Client Hooking:
			SDKHookCallBack(Client);
		}
	}
}

//Initation:
public OnMapStart()
{

	//Initulize:
	MapRunning = true;

	//Change Team Name:
	ReplaceTeamName();

	//Precache:
	initStockCache();

	initGarbageReset();

	initMapFix();

	ResetDropped();

	ResetAllCritical();

	ResetEffects();

	ResetCopDoors();

	ResetVipDoors();

	ResetAdminDoors();

	ResetEntNotice();

	ResetSpawns();

	ResetIndexNumbAfterMapStart();

	ResetGarbage();

	initMapTrashCans();

	//Precache:
	PrecacheItems();

	//SQL Load:
	CreateTimer(0.6, LoadSpawnPoints);

	CreateTimer(0.7, LoadNoKillZone);

	CreateTimer(0.8, LoadThumper);

	CreateTimer(0.9, LoadRandomCrateZone);

	CreateTimer(1.0, LoadCopDoors);

	CreateTimer(1.1, LoadJail);

	CreateTimer(1.2, LoadGarbageZone);

	CreateTimer(1.3, LoadNpcs);

	CreateTimer(1.4, LoadItemlist);

	CreateTimer(1.5, LoadNpcSpawns);

	CreateTimer(1.6, LoadDoorMainOwners);

	CreateTimer(1.7, LoadDoorLocks);

	CreateTimer(1.8, LoadDoorPrices);

	CreateTimer(1.9, LoadNotice);

	CreateTimer(2.0, LoadNoticeName);

	CreateTimer(2.1, LoadNoticeDesc);

	CreateTimer(2.2, LoadMainDoors);

	CreateTimer(2.3, LoadMoneySafe);

	CreateTimer(2.4, LoadDoorLocked);

	CreateTimer(2.5, LoadTrashCans);

	CreateTimer(2.6, LoadRemoveMapProps);

	CreateTimer(2.7, LoadVipDoors);

	CreateTimer(2.8, LoadAdminDoors);
}

//Initation:
public OnMapEnd()
{

	//Initulize:
	MapRunning = false;
}

//Is Extension Loaded:
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{

	//Return:
	return APLRes_Success;
}

//Global Forward:
public Action:SDKHookCallBack(Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Client Hooking:
		SDKHook(Client, SDKHook_OnTakeDamage, OnClientDamage);

		//Client Hooking:
		SDKHook(Client, SDKHook_OnTakeDamagePost, OnClientDamagePost);

		//Client Hooking:
		SDKHook(Client, SDKHook_PreThinkPost, OnClientPreThinkPost);
	}
}

public OnClientPreThinkPost(Client)
{

	//Fix Client View:
	OnClientPreThinkVehicleViewFix(Client);
}
public Action:OnPlayerRunCmd(Client, &Buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{

	//Is Alive:
	if(IsPlayerAlive(Client))
	{

		//Fix Shotgun:
		HL2dmFix(Client, Buttons, impulse, vel, angles, weapon);

		//Is Client Cuffed:
		if(IsCuffed(Client) || IsSleeping(Client) > -1)
		{

			//Button Preventsion:
			Buttons &= ~IN_ATTACK;

			Buttons &= ~IN_ATTACK2;

			//Is Client Cuffed:
			if(IsSleeping(Client) > -1)
			{

				//Button Preventsion:
				Buttons &= ~IN_USE;

				Buttons &= ~IN_JUMP;

				Buttons &= ~IN_DUCK;
			}
		}

		//Is Blocking
		if(GetBlockE(Client) == 1)
		{

			//Prevent Action:
			Buttons &= ~IN_USE;

			//Can Unblock:
			if(GetUnBlockE(Client) == 0)
			{

				//Timer:
				CreateTimer(10.0, UnLockUse, Client);

				//Initialize:
				SetUnBlockE(Client, 1);
			}
		}

		//Button Used:
		else if(Buttons & IN_JUMP)
		{

			//Buffer:
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Use:
				OnClientJump(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Button Used:
		else if(Buttons & IN_USE)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Shift:
				OnClientUse(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Button Used:
		else if(Buttons & IN_SPEED)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Shift:
				OnClientShift(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Button Used:
		else if(Buttons & IN_ATTACK2)
		{

			//Buffer
			if(PrethinkBuffer[Client] == 0)
			{

				//Handle Shift:
				OnClientAttack2(Client);

				//Initialize:
				PrethinkBuffer[Client] = 1;

				//Return:
				return Plugin_Changed;
			}
		}

		//Override:
		else
		{

			//Initialize:
			PrethinkBuffer[Client] = 0;
		}

		//Return:
		return (impulse == 100 && IsCuffed(Client)) ? Plugin_Handled : Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}

//Handle Chat:
public Action:CommandSay(Client, const String:Command[], Argc)
{

	//Declare:
	decl String:Text[256];
	new bool:IsTeamOnly = false;

	//Not Police Officer:
	if(StrEqual(Command, "say_team"))
	{

		IsTeamOnly = true;
	}

	//Get Args
	GetCmdArgString(Text, sizeof(Text));

	//Strip All Quoats:
	StripQuotes(Text);

	//Trip String:
	TrimString(Text);

	//Is Admin Command:
	if(Text[0] == '/')
	{

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl Action:result;

	//Start Forward:
	Call_StartForward(ChatForward);

	//Get Users:
	Call_PushCell(Client);

	//Get Headshot:
	Call_PushCell(IsTeamOnly);

	//Get Weapon:
	Call_PushString(Text);

	//Get Users:
	Call_PushCell(sizeof(Text));

	//Finnish Forward:
	Call_Finish(_:result);

	//Return:
	return Plugin_Handled;
}

//EventDeath Farward:
public Action:EventTeam_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Declare:
	decl Action:result;

	//Start Forward:
	Call_StartForward(TeamForward);

	//Get Users:
	Call_PushCell(Event);

	Call_PushCell(GetClientOfUserId(GetEventInt(Event, "userid")));

	Call_PushCell(GetEventInt(Event, "team"));

	Call_PushCell(GetEventInt(Event, "oldteam"));

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return result;
}

//EventDeath Farward:
public Action:EventDeath_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Declare:
	decl String:Clientweapon[32], String:Playerweapon[32], Action:result;

	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));

	new Attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));

	//Start Forward:
	Call_StartForward(DeathForward);

	//Get String:
	GetEventString(Event, "weapon", Playerweapon, sizeof(Playerweapon));

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Get Client Weapon:
		GetClientWeapon(Client, Clientweapon, sizeof(Clientweapon));
	}

	//Get Users:
	Call_PushCell(Client);

	Call_PushCell(Attacker);

	//Get Weapon:
	Call_PushString(Clientweapon);

	Call_PushString(Playerweapon);

	//Get Headshot:
	Call_PushCell(GetEventInt(Event, "headshot"));

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return result;
}

//EventDeath Farward:
public Action:Eventspawn_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Declare:
	decl Action:result;

	//Initialize:
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));

	//Start Forward:
	Call_StartForward(SpawnForward);

	//Get Users:
	Call_PushCell(Client);

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return result;
}

//EventDeath Farward:
public Action:EventChangeName_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Declare:
	decl Action:result, String:NewName[32], String:OldName[32];

	//Start Forward:
	Call_StartForward(NameForward);

	//Initialize:
	GetEventString(Event, "newname", NewName, sizeof(NewName));

	GetEventString(Event, "oldname", OldName, sizeof(OldName));

	//Get Users:
	Call_PushCell(GetClientOfUserId(GetEventInt(Event, "userid")));

	//Get NewName:
	Call_PushString(NewName);

	//Get OldName:
	Call_PushString(OldName);

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return result;
}

//Event Player Disconnect:
public Action:StopEvent_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return Plugin_Handled;
}

//Event Player Disconnect:
public Action:ServerCvarEvent_Forward(Handle:Event, const String:name[], bool:dontBroadcast)
{

	//Start Forward:
	Call_StartForward(CvarForward);

	//Declare:
	decl Action:result, String:CvarName[255], String:CvarValue[255];

	//Initialize:
	GetEventString(Event, "cvarname", CvarName, sizeof(CvarName));

	GetEventString(Event, "cvarvalue", CvarValue, sizeof(CvarValue));

	//Get NewName:
	Call_PushString(CvarName);

	//Get OldName:
	Call_PushString(CvarValue);

	//Finnish Forward:
	Call_Finish(_:result);

	//Set Broadcast:
	SetEventBroadcast(Handle:Event, true);

	//Close:
	CloseHandle(Event);

	//Return:
	return result;
}

public Action:OnClientUse(Client)
{

	//Vehicle Check:
	OnVehicleUse(Client);

	//Declare:
	new Ent = GetClientAimTarget(Client, false); 

	//Not Valid Ent:
	if(Ent > 0 && IsValidEdict(Ent))
	{

		//Not Valid Ent:
		if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//Handle Player:
			DrawPlayerMenu(Client, Ent);

			//Check:
			if((IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
			{

				//Handle Grab:
				OnPlayerGrab(Client, Ent);
			}
		}

		//Declare:
		decl String:ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Is Cop With Admin Override:
		if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnCopDoorFuncUse(Client, Ent);
			}
		}

		//Is Client Owner of door or has key:
		if(GetMainDoorOwner(Ent) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnClientDoorFuncUse(Client, Ent);
			}
		}

		//Vip Doors:
		if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Door:
				OnVipDoorFuncUse(Client, Ent);
			}
		}

		//Admin Doors:
		if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
		{

			//Is Func Door:
			if(StrEqual(ClassName, "func_door"))
			{

				//Handle Crate:
				OnAdminDoorFuncUse(Client, Ent);
			}
		}

		//Is Prop Door:
		if(StrEqual(ClassName, "prop_door_rotating"))
		{

			//Check:
			OnClientCheckDoorSpam(Client, Ent);
		}

		//Prop Not Thumper:
		if(StrEqual(ClassName, "prop_Thumper"))
		{

			//Handle Thumper:
			OnThumperUse(Client, Ent);
		}

		if(IsRandomCrate(Client, Ent))
		{

			//Handle Crate:
			OnCrateUse(Client, Ent);
		}

		if(IsTrashCan(Ent))
		{

			//Handle Trash Can:
			OnTrashCanUse(Client, Ent);
		}

		if(IsValidCouch(Ent))
		{

			//Handle Couch:
			OnCouchUse(Client, Ent);
		}

		if(IsValidPrinter(Ent))
		{

			//Handle Printer:
			OnPrinterUse(Client, Ent);
		}

		if(IsValidPlant(Ent))
		{

			//Handle Plant:
			OnPlantUse(Client, Ent);
		}

		if(IsValidMeth(Ent))
		{

			//Handle Plant:
			OnMethUse(Client, Ent);
		}

		if(IsValidPills(Ent))
		{

			//Handle Plant:
			OnPillsUse(Client, Ent);
		}

		if(IsValidCocain(Ent))
		{

			//Handle Plant:
			OnCocainUse(Client, Ent);
		}

		if(IsValidRice(Ent))
		{

			//Handle Plant:
			OnRiceUse(Client, Ent);
		}

		if(IsValidBomb(Ent))
		{

			//Handle Plant:
			OnBombUse(Client, Ent);
		}

		if(IsValidGunLab(Ent))
		{

			//Handle Plant:
			OnGunLabUse(Client, Ent);
		}

		if(IsValidMicrowave(Ent))
		{

			//Handle Plant:
			OnMicrowaveUse(Client, Ent);
		}

		if(IsValidShield(Ent))
		{

			//Handle Plant:
			OnShieldUse(Client, Ent);
		}

		if(IsValidFireBomb(Ent))
		{

			//Handle Plant:
			OnFireBombUse(Client, Ent);
		}

		if(IsValidGenerator(Ent))
		{

			//Handle Plant:
			OnGeneratorUse(Client, Ent);
		}

		if(IsValidBitCoinMine(Ent))
		{

			//Handle Plant:
			OnBitCoinMineUse(Client, Ent);
		}

		if(IsValidPropaneTank(Ent))
		{

			//Handle Plant:
			OnPropaneTankUse(Client, Ent);
		}

		if(IsValidPhosphoruTank(Ent))
		{

			//Handle Phosphoru Tank:
			OnPhosphoruTankUse(Client, Ent);
		}

		if(IsValidFireBomb(Ent))
		{

			//Handle Plant:
			OnFireBombUse(Client, Ent);
		}

		if(IsValidLamp(Ent))
		{

			//Handle Light:
			OnLampUse(Client, Ent);
		}

		if(IsValidBong(Ent))
		{

			//Handle Light:
			OnBongUse(Client, Ent);
		}

		if(IsValidSmokeBomb(Ent))
		{

			//Handle Light:
			OnSmokeBombUse(Client, Ent);
		}

		if(IsValidWaterBomb(Ent))
		{

			//Handle Light:
			OnWaterBombUse(Client, Ent);
		}

		if(IsValidPlasmaBomb(Ent))
		{

			//Handle Light:
			OnPlasmaBombUse(Client, Ent);
		}

		if(IsValidWeapon(GetWeaponInfo(Ent)))
		{

			//Handle Weapon:
			OnWeaponUse(Client, Ent);
		}

		if(IsValidMoneySafe(Ent))
		{

			//Handle Money Safe:
			OnMoneySafeUse(Client, Ent);
		}

		if(IsValidNpc(Ent))
		{

			//Declare:
			new Id = GetNpcId(Ent);

			new Type = GetNpcType(Ent);

			//Empoyer NPC:
			if(Type == 0)
			{

				//Show Menu
				JobMenu(Client, 0);
			}

			//Banker NPC:
			else if(Type == 1)
			{

				//Show Menu:
				DrawBankMenu(Client, Ent);
			}

			//Vendor NPC:
			else if(Type == 2)
			{

				//Show Menu:
				VendorMenuBuy(Client, Id, Ent);
			}

			//Cop Employer NPC:
			else if(Type == 3)
			{

				//Show Menu:
				CopRankingMenu(Client);
			}

			//Drug Buyer NPC:
			else if(Type == 4)
			{

				//Show Menu:
				VendorDrugSell(Client);
			}

			//Exp Trade NPC:
			else if(Type == 5)
			{

				//Show Menu:
				ExperienceMenu(Client);
			}

			//Hardware Store NPC:
			else if(Type == 6)
			{

				//Show Menu:
			}
		}

		if(GetDroppedDrugValue(Ent) > 0)
		{

			//Handle Dropped Drug:
			OnClientPickUpWeedBag(Client, Ent);
		}

		if(GetDroppedMethValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpMeth(Client, Ent);
		}

		if(GetDroppedPillsValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpPills(Client, Ent);
		}

		if(GetDroppedCocainValue(Ent) > 0)
		{

			//Handle Dropped Meth:
			OnClientPickUpCocain(Client, Ent);
		}

		if(GetDroppedMoneyValue(Ent) > 0)
		{

			//Handle Money:
			OnClientPickUpMoney(Client, Ent);
		}

		if(IsValidDroppedItem(Ent))
		{

			//Handle Dropped Item:
			OnClientPickUpItem(Client, Ent);
		}
	}
}

public Action:OnClientShift(Client)
{

	//Declare:
	new Ent = GetClientAimTarget(Client, false); 

	//Not Valid Ent:
	if(Ent != -1 && Ent > 0 && IsValidEdict(Ent))
	{

		//Declare:
		decl String:ClassName[32];

		//Get Entity Info:
		GetEdictClassname(Ent, ClassName, sizeof(ClassName));

		//Is Admin Or Cop:
		if((IsCop(Client) || IsAdmin(Client)) && NativeIsCopDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnCopDoorPropShift(Client, Ent);
			}
		}

		//Is Client Owner of door or has key:
		if(GetMainDoorOwner(Ent) || HasDoorKeys(Ent, Client) || HasDoorKeys(GetMainDoorId(Ent), Client))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnClientDoorPropShift(Client, Ent);
			}
		}

		//Is Donator:
		if((GetDonator(Client) > 0) && NativeIsVipDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnVipDoorPropShift(Client, Ent);
			}
		}

		//Is Donator:
		if((IsAdmin(Client)) && NativeIsAdminDoor(Ent))
		{

			//Is Prop Door:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{

				//Handle Crate:
				OnAdminDoorPropShift(Client, Ent);
			}
		}

		if(IsValidMoneySafe(Ent))
		{

			//Handle Money Safe:
			OnMoneySafeRob(Client, Ent);
		}

		if(IsValidGenerator(Ent))
		{

			//Handle Plant:
			OnGeneratorShift(Client, Ent);
		}

		if(IsValidNpc(Ent))
		{

			//Declare:
			new Id = GetNpcId(Ent);

			//Declare:
			new Type = GetNpcType(Ent);

			//Empoyer NPC:
			if(Type == 1)
			{

				//Begin Bank Rob:
				BeginBankRob(Client, "Banker", 500, Id);
			}

			//Empoyer NPC:
			if(Type == 2)
			{

				//Begin Bank Rob:
				BeginVendorRob(Client, "Vendor", 400, Id);
			}
		}

	}
}

public Action:OnClientAttack2(Client)
{

	//Declare:
	decl String:ClassName[32];

	//Get Client Weapon:
	GetClientWeapon(Client, ClassName, sizeof(ClassName));

	//Is Prop Door:
	if(StrEqual(ClassName, "weapon_crowbar") || StrEqual(ClassName, "weapon_stunstick"))
	{

		//Declare:
		new Ent = GetClientAimTarget(Client, false); 

		//Not Valid Ent:
		if(Ent <= GetMaxClients() && Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
		{

			//Handle Push Player:
			OnClientPushPlayer(Client, Ent);
		}

		//Not Valid Ent:
		if(Ent > GetMaxClients() && IsValidEdict(Ent))
		{

			//Is Prop Door:
			if(IsValidDoor(Ent) && IsInDistance(Client, Ent))
			{

				//Handle Door Knock:
				OnClientKnockPropDoor(Ent);
			}
		}
	}
}

public Action:OnClientJump(Client)
{

	//Declare:
	new OnGround = GetEntityFlags(Client);

	if(OnGround & FL_ONGROUND)
	{

		//Initulize:
		PrethinkJump[Client]++;
	}

	if(PrethinkJump[Client] > 0 && !(OnGround & FL_ONGROUND) && Jump[Client] < MAXJUMP)
	{

		//Initulize:
		Jump[Client]++;

		//Declare:
		decl Float:Origin[3];

		//Initulize:
		GetEntPropVector(Client, Prop_Data, "m_vecVelocity", Origin);

		//Boost Client:
		Origin[2] = 250.0;

		//Teleport:
		TeleportEntity(Client, NULL_VECTOR, NULL_VECTOR, Origin);
	}
}

public Action:OnClientSpawn(Client)
{

	//Check:
	if(IsLoaded(Client))
	{

		//Is Cuffed:
		if(IsCuffed(Client))
		{

			//Cuff:
			Cuff(Client);

			//Jail:
			JailClient(Client, Client);
		}

		//Override:
		else
		{

			//Spawn Client:
			InitSpawnPos(Client, 1);

			//Setup Roleplay Job:
			SetupRoleplayJob(Client);
		}

		//Reset Critical:
		ResetCritical(Client);

		//Reset Overlay:
		ResetClientOverlay(Client);

		//Check:
		if(!StrEqual(GetHatModel(Client), "null"))
		{

			//Create Hat:
			CreateHat(Client, GetHatModel(Client));
		}

		//Masters root:
		if(SteamIdToInt(Client) == 30027290)
		{

			//Added Effect:
			new Effect = CreateLight(Client, 1, 255, 255, 120, "null");

			SetEntAttatchedEffect(Client, 9, Effect);
		}
	}

	//Start Protecting:
	StartSpawnProtect(Client);
}

//Event Death:
public Action:OnClientDied(Client, Attacker, String:ClientWeapon[32], String:PlayerWeapon[32], bool:headshot)
{

	//Clear Drug Tick:
	ResetDrugs(Client);

	//Check Player Bounty:
	OnClientDiedCheckBounty(Client, Attacker);

	//Hangup Phone:
	OnCliedDiedHangUp(Client);

	//Reset Critical:
	ResetCritical(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Reset Protection to prevent bugs:
	RemoveProtectTimer(Client);

	//Remove Player Hat:
	OnClientDiedThrowPhysHat(Client, GetPlayerHatEnt(Client));

	//Check:
	if(IsLoaded(Client) == true)
	{

		//Drop All Drugs:
		OnClientDropAllDrugs(Client);

		//Drop Money:
		OnClientDropMoney(Client);
	}

	//Command:
	CheatCommand(Client, "r_screenoverlay", "debug/yuv.vmt");

	//Check:
	if(IsValidAttachedEffect(Client))
	{

		//Remove:
		RemoveAttachedEffect(Client);
	}
}

//Event Damage:
public Action:OnClientDamage(Client, &attacker, &inflictor, &Float:damage, &damageType)
{

	//Forward SDKHOOK:
	OnClientVeicleDamage(Client, attacker, inflictor, damage, damageType);

	//Check:
	if(attacker > GetMaxClients() && IsValidEntity(attacker))
	{

		//Declare:
		decl String:ClassName[32];

		//Get Entity Info:
		GetEdictClassname(attacker, ClassName, sizeof(ClassName));

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_antlionguard", false) == 0)
		{

			//Forward SDKHOOK:
			OnAntLionGuardDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_helicopter", false) == 0)
		{

			//Forward SDKHOOK:
			OnHelicopterDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_vortigaunt", false) == 0)
		{

			//Forward SDKHOOK:
			OnVortigauntDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_strider", false) == 0)
		{

			//Forward SDKHOOK:
			OnStriderDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_metropolice", false) == 0)
		{

			//Forward SDKHOOK:
			OnMetroPoliceDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_zombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnZombieDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_poisonzombie", false) == 0)
		{

			//Forward SDKHOOK:
			OnPoisonZombieDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab_fast", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabFastDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_headcrab_black", false) == 0)
		{

			//Forward SDKHOOK:
			OnHeadCrabBlackDamageClient(Client, attacker, inflictor, damage, damageType);
		}

		//Is AntLion Guard:
		if(StrContains(ClassName, "npc_advisor", false) == 0)
		{

			//Forward SDKHOOK:
			OnAdvisorDamageClient(Client, attacker, inflictor, damage, damageType);
		}
	}

	//Convert if Player Has Suit:
	if(damageType == DMG_FALL || damageType == DMG_DROWN)
	{

		//Declare:
		new Float:Armor = float(GetClientArmor(Client));

		//Has No Armor:
		if(Armor == 0.0)
		{

			//Initialize:
			damage = FloatMul(damage, GetRandomFloat(0.50, 1.50));
		}

		//Has Armor:
		else if((Armor - damage) < 1 && (Armor != 0.0))
		{

			//Set Armor:
			SetEntityArmor(Client, 0);

			//Initialize:
			damage = FloatMul(damage, GetRandomFloat(0.25, 0.75));
		}

		//Has Armor With Right Damage to armor value:
		else if((Armor - damage) > 1.0)
		{

			//Set Armor:
			SetEntityArmor(Client, RoundToNearest((Armor - damage)));

			//Initialize:
			damage = FloatMul(damage, GetRandomFloat(0.25, 0.75));
		}

		//Override:
		else
		{
			//Set Armor:
			SetEntityArmor(Client, 0);
		}

		//Shake Client:
		ShakeClient(Client, 2.5, (damage/4.0));
	}

	//Is Player:
	if(attacker != Client && Client != 0 && attacker != 0 && Client > 0 && Client < MaxClients && attacker > 0 && attacker < MaxClients)
	{

		//Handle Player Cuff:
		OnClientCuffCheck(Client, attacker, damage);

		//Cop Kill:
		if(IsCop(Client) && IsCop(attacker) && IsCopKillDisabled() == 1)
		{

			//Initialize:
			damage = 0.0;
		}
	}

	//GodeMode:
	if(GetIsNokill(Client) || IsProtected(Client) || GetGodMode(Client))
	{

		//Initialize:
		damage = 0.0;

		//Change Client:
		attacker = Client;

		//Damage:
		damageType = 0;
	}

	//Is Damage Coming From Kitchen?:
	if(damageType == DMG_BURN)
	{

		//Declare:
		new Ent = FindAttachedPropFromEnt(inflictor);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Check:
			if(IsValidMeth(Ent) || IsValidPills(Ent) || IsValidCocain(Ent))
			{

				//Initialize:
				damage = 0.0;
			}

			//Override
			else
			{

				//Initialize:
				damage = GetRandomFloat(1.0, 5.0);
			}
		}
	}

	//Has Shield Near By:
	if(IsShieldInDistance(Client))
	{

		//Initialize:
		damage = 0.0;

		//Damage:
		damageType = 0;

		//Shield Forward:
		OnClientShieldDamage(Client, damage);
	}

	//Return:
	return Plugin_Changed;
}

//Event Damage:
public OnClientDamagePost(Client, attacker, inflictor, Float:damage, damagetype)
{

	//Check Ciritical:
	OnDamageCriticalCheck(Client);
}

//public OnClientPutInServer(Client)
public OnClientPostAdminCheck(Client)
{

	//LoadItems:
	CreateTimer(0.2, PreLoad, Client);

	//Set Defaults:
	OnClientConnectSetDefaults(Client);

	//SDKHooks
	HookWeaponMod(Client);

	SDKHookCallBack(Client);
}

//Create SQLite Database:
public Action:PreLoad(Handle:Timer, any:Client)
{

	//Connected:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Connect Message:
		OnClientConnectMessage(Client);

		//Load Player Stats:
		DBLoad(Client);

		//Load Door Keys;
		DBLoadKeys(Client);

		//Load Player Drugs:
		DBLoadDrugs(Client);

		//Load Spawned Items:
		DBLoadSpawnedItems(Client);

		//Load Settings:
		LoadPlayerSettings(Client);
	}

	//Connected:
	else if(IsClientConnected(Client))
	{

		//LoadItems:
		CreateTimer(0.1, PreLoad, Client);
	}
}

//Disconnect:
public OnClientDisconnect(Client)
{

	//Disconnect Message:
	OnClientDisconnectMessage(Client);

	//Fix Players:
	if(IsAdmin(Client) || GetDonator(Client) > 0) 
	{

		//Initulize:
		ChangeClientTeamEx(Client, 3);
	}

	//Save:
	DBSave(Client);

	//Disconnect Talkzone:
	initdisconnectphone(Client);

	//Remove Sleeping:
	ResetSleeping(Client);

	//Remove Sleeping:
	ResetCritical(Client);

	//SaveSpawnedItems:
	SaveSpawnedItemForward(Client, true);

	//Update Last Stats:
	UpdateLastStats(Client);
}

//Event Team:
public Action:OnClientTeam(Handle:Event, Client, NewTeam, OldTeam)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Is Bot:
		if(!IsFakeClient(Client))
		{

			//Not Cop:
			if(IsCop(Client) && NewTeam != 2)
			{

				//Set Data:
				SetEventInt(Handle:Event, "team", 2);
			}

			//Override:
			else if(NewTeam != 3)
			{

				//Set Data:
				SetEventInt(Handle:Event, "team", 3);
			}
		}

		//Initulize:
		new weapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");

		//Is Valid:
		if(IsValidEdict(weapon))
		{

			//Declare:
			decl String:ClassName[32];

			//Initulize:
			GetEdictClassname(weapon, ClassName, sizeof(ClassName));

			//Check If Player is using Glitch:
			if(StrEqual(ClassName, "weapon_physcannon") && GetEntProp(weapon, Prop_Send, "m_bActive", 1))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have been slayed due to Exploit!");

				//Kill Player:
				ForcePlayerSuicide(Client);
			}
		}
	}

	//Return:
	return Plugin_Changed;
}

//Prethink:
public OnGameFrame()
{

	//Loop:
	for(new Client = 1; Client <= MaxClients; Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Is Client Cuffed:
			if(IsCuffed(Client) || GetIsCritical(Client) || IsSleeping(Client) > 0)
			{

				//Set Suit:
				SetEntPropFloat(Client, Prop_Send, "m_flSuitPower", 0.0);

				SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);
			}

			//Declare:
			new OnGround = GetEntityFlags(Client);

			if(OnGround & FL_ONGROUND && PrethinkJump[Client] != 0)
			{

				//Initulize:
				PrethinkJump[Client] = 0;

				Jump[Client] = 0;
			}
		}
	}
}

//On Client Collide:
public Action:CH_ShouldCollide(Ent, OtherEnt, &bool:result)
{

	//PlayerCheck:
	if(Ent > 0 && Ent <= GetMaxClients() && IsClientConnected(Ent) && IsClientInGame(Ent))
	{

		//Other Player Check:
		if(OtherEnt > 0 && OtherEnt <= GetMaxClients() && IsClientConnected(OtherEnt) && IsClientInGame(OtherEnt))
		{

			//Initulize:
			OnClientShouldCollide(Ent, OtherEnt, result);
		}
	}

	//PlayerCheck:
	if(Ent > GetMaxClients() && IsValidEdict(Ent))
	{

		//Other Player Check:
		if(OtherEnt > GetMaxClients() && IsValidEdict(OtherEnt))
		{

			//Initulize:
			OnEntityShouldCollide(Ent, OtherEnt, result);
		}
	}

	//Return:
	return Plugin_Continue;
}

// remove players from Vehicles before they are destroyed or the server will crash!
public OnEntityDestroyed(Entity)
{

	//Is Valid:
	if(IsValidEdict(Entity))
	{

		//Remove Crate:
		OnCrateDestroyed(Entity);

		//Declare:
		new String:ClassName[30];

		//Initulize:
		GetEdictClassname(Entity, ClassName, sizeof(ClassName));

		//Is Valid:
		if(StrEqual("prop_Vehicle_driveable", ClassName, false))
		{

			//Declare:
			new Driver = GetEntPropEnt(Entity, Prop_Send, "m_hPlayer");

			//Has Driver:
			if(Driver != -1)
			{

				//Exit Car:
				ExitVehicle(Driver, Entity, 1);
			}
		}

		//Check:
		if(IsValidAttachedEffect(Entity))
		{

			//Remove:
			RemoveAttachedEffect(Entity);
		}
	}
}

//Entity Spawn
public OnEntityCreated(Entity, const String:ClassName[])
{

	//Is Valid
	if(StrContains(ClassName, "grenade") != -1)
	{

		//Hook Entity:
		SDKHook(Entity, SDKHook_SpawnPost, OnGrenadeSpawn);
	}

	//Is Valid
	if(StrContains(ClassName, "prop_combine_ball") != -1)
	{

		//Hook Entity:
		SDKHook(Entity, SDKHook_SpawnPost, OnCombineBallSpawn);
	}

	//Is Valid
	if(StrContains(ClassName, "gib") != -1)
	{

		//SQL Load:
		CreateTimer(10.00, RemoveGibs, Entity);
	}
}

public OnGrenadeSpawn(Ent)
{

	//Set Entity Model:
	SetEntityModel(Ent, "models/props_c17/doll01.mdl");

	//GetOwner
	new Client = GetEntPropEnt(Ent, Prop_Data, "m_hOwnerEntity");

	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		new Effect = -1;

		//Check:
		if(IsCop(Client))
		{

			//Added Effect:
			Effect = CreateLight(Ent, 1, 120, 120, 255, "null");
		}

		//Check:
		else if(GetDonator(Client) > 0 || IsAdmin(Client))
		{

			//Added Effect:
			Effect = CreateLight(Ent, 1, 255, 255, 120, "null");
		}

		//Override:
		else
		{

			//Added Effect:
			Effect = CreateLight(Ent, 1, 255, 120, 120, "null");
		}

		//Initulize:
		SetEntAttatchedEffect(Ent, 0, Effect);
	}
}

public OnCombineBallSpawn(Ent)
{

	//Added Effect:
	new Effect = CreateLight(Ent, 1, 120, 120, 255, "null");

	SetEntAttatchedEffect(Ent, 0, Effect);
}

//Spawn Timer:
public Action:RemoveGibs(Handle:Timer, any:Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > MaxClients)
	{

		//Remove:
		//RemoveEdict(Ent);

		//Dessolve:
		EntityDissolve(Ent, 1);
	}

	//Return:
	return Plugin_Continue;
}
//On Entity Collide:
public Action:OnEntityShouldCollide(Ent, OtherEnt, &bool:result)
{

	//Return:
	return Plugin_Continue;
}

public bool:IsMapRunning()
{

	//Return:
	return MapRunning;
}