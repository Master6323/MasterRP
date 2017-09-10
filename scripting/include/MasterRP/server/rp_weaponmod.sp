//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_weaponmod_included_
  #endinput
#endif
#define _rp_weaponmod_included_

//Drop Weapon Mod:
static String:WeaponInfo[2047][32];
static WeaponEq[MAXPLAYERS + 1] = {0,...};
static WeaponOffset = -1;

public Action:PluginInfo_WeaponMod(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Roleplay Weapon System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initWeaponMod()
{

	//Find Offsets:
	WeaponOffset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
}

//Global Forward:
public Action:HookWeaponMod(Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Client Unhooking:
		SDKHook(Client, SDKHook_WeaponDrop, OnWeaponDrop);

		//Client Unhooking:
		SDKHook(Client, SDKHook_WeaponEquip, OnWeaponEquip);
	}
}

//Event Weapon Pickup:
public Action:OnWeaponDrop(Client, Ent) 
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > GetMaxClients())
	{

		//Not Cop:
		if(!IsCop(Client))
		{

			//Declare:
			decl String:ClientWeapon[32];

			//Get Entity Info:
			GetEdictClassname(Ent, ClientWeapon, sizeof(ClientWeapon));

			//Loose Weapon:
			WeaponDrop(Client, ClientWeapon, 2);
		}

		//Timer:
		RemoveWeapon(Ent);
	}

	//Return:
	return Plugin_Handled;
}

//Event Weapon Pickup:
public Action:OnWeaponEquip(Client, weapon) 
{

	//Declare:
	decl String:ClassName[32];

	//Get Entity Info:
	GetEdictClassname(weapon, ClassName, sizeof(ClassName));

	//Valid Check:
	if(StrContains(ClassName, "weapon_physcannon", false) != -1)
	{

		//Add Extra Slots:
		if(GetItemAmount(Client, 306) > 0)
		{

			//Set Color:
			SetEntityRenderColor(weapon, 100, 100, 255, 255);

			//Set Effect:
			SetEntityRenderMode(weapon, RENDER_GLOW);
		}

		//Return:
		return Plugin_Continue;
	}

	//Can Equipt:
	if(WeaponEq[Client] == 0)
	{

		//Timer:
		RemoveWeapon(weapon);

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

//Spawn Timer:
public Action:RemoveWeapon(Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent) && Ent > MaxClients)
	{

		WeaponInfo[Ent] = "null";

		//Remove Weapon:
		AcceptEntityInput(Ent, "Kill");

		//Initulize:
		SetPropSpawnedTimer(Ent, -1);

		SetPropIndex((GetPropIndex() - 1));
	}

	//Return:
	return Plugin_Continue;
}

public bool:WeaponDrop(Client, String:ClientWeapon[32], Var)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2000)
	{

		//Return:
		return false;
	}

	//Declare:
	decl Float:Position[3], String:Model[64];

	//Initialize:
	Model = "null";

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_pistol"))
	{

		//Initialize:
		Model = "models/weapons/w_pistol.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_crowbar"))
	{

		//Initialize:
		Model = "models/weapons/w_crowbar.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_stunstick"))
	{

		//Initialize:
		Model = "models/weapons/w_stunbaton.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_frag"))
	{

		//Initialize:
		Model = "models/weapons/w_grenade.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_smg1"))
	{

		//Initialize:
		Model = "models/weapons/w_smg1.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_shotgun"))
	{

		//Initialize:
		Model = "models/weapons/w_shotgun.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_crossbow"))
	{

		//Initialize:
		Model = "models/weapons/w_crossbow.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_rpg"))
	{

		//Initialize:
		Model = "models/weapons/w_rocket_launcher.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_ar2"))
	{

		//Initialize:
		Model = "models/weapons/w_irifle.mdl";
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_slam"))
	{

		//Initialize:
		Model = "models/weapons/w_slam.mdl";

		//Return to prevent spam bug: will work on this to fix hl2dm game Function caused spam in mod!
		return false;
	}

	//Is Weapon:
	if(StrEqual(ClientWeapon, "weapon_357"))
	{

		//Initialize:
		Model = "models/weapons/w_357.mdl";
	}

	if(StrEqual(Model, "null"))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Invalid weapon %s model %s", ClientWeapon, Model);

		//Return:
		return false;
	}

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return false;
	}

	//Declare:
  	decl Float:EyeAngles[3], Float:Push[3];

	//Initialize:
  	GetClientEyeAngles(Client, EyeAngles);

	//Initialize:
	GetClientAbsOrigin(Client, Position);

	//Calculate:
	Push[0] = (350.0 * Cosine(DegToRad(EyeAngles[1])));
    	Push[1] = (350.0 * Sine(DegToRad(EyeAngles[1])));
    	Push[2] = (-25.0 * Sine(DegToRad(EyeAngles[0])));
	Position[2] += 25.0;

	//Check:
	if(TR_PointOutsideWorld(Position))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Unable to drop weapon due to outside of world");
	}

	//Declare:
	new Ent = CreateEntityByName("prop_physics_override");

	//Is Ent
	if(IsValidEntity(Ent))
	{

		//Is Precached:
		if(!IsModelPrecached(Model))
		{

			//Precache:
			PrecacheModel(Model);
		}

		//Values:
		DispatchKeyValue(Ent, "model", Model);

		//Spawn:
		DispatchSpawn(Ent);

		//Declare:
		new Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

		//Set End Data:
		SetEntData(Ent, Collision, 1, 1, true);

		//Push Ent:
		if(Var == 2)
		{


			//Teleport:
		    	TeleportEntity(Ent, Position, EyeAngles, Push);
		}

		//Static Ent:
		if(Var == 1)
		{

			//Teleport:
			TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);
		}

		//Initialize:
		WeaponInfo[Ent] = ClientWeapon;

		//Init To Spawn Manage:
		SetPropSpawnedTimer(Ent, 0);

		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return true;
	}

	//Return:
	return false;
}

public bool:GunLabSpawnWeapon(Client, Ent, Random)
{

	//Declare:
	decl Float:Position[3], String:Model[64], String:Name[32];

	//Random:
	if(Random == -1) Random = GetRandomInt(1, 11);

	//Initialize:
	Model = "Null";

	//Is Weapon:
	if(Random == 1)
	{

		//Initialize:
		Model = "models/weapons/w_pistol.mdl";

		Name = "weapon_pistol";
	}

	//Is Weapon:
	if(Random == 2)
	{

		//Initialize:
		Model = "models/weapons/w_crowbar.mdl";

		Name = "Weapon_crowbar";
	}

	//Is Weapon:
	if(Random == 3)
	{

		//Initialize:
		Model = "models/weapons/w_grenade.mdl";

		Name = "weapon_frag";
	}

	//Is Weapon:
	if(Random == 4)
	{

		//Initialize:
		Model = "models/weapons/w_smg1.mdl";

		Name = "weapon_smg1";
	}

	//Is Weapon:
	if(Random == 5)
	{

		//Initialize:
		Model = "models/weapons/w_shotgun.mdl";

		Name = "weapon_shotgun";
	}

	//Is Weapon:
	if(Random == 6)
	{

		//Initialize:
		Model = "models/weapons/w_rocket_launcher.mdl";

		Name = "weapon_rpg";
	}

	//Is Weapon:
	if(Random == 7)
	{

		//Initialize:
		Model = "models/weapons/w_slam.mdl";

		Name = "weapon_slam";
	}

	//Is Weapon:
	if(Random == 8)
	{

		//Initialize:
		Model = "models/weapons/w_357.mdl";

		Name = "weapon_357";
	}

	//Is Weapon:
	if(Random == 9)
	{

		//Initialize:
		Model = "models/weapons/w_crossbow.mdl";

		Name = "weapon_crossbow";
	}

	//Is Weapon:
	if(Random == 10)
	{

		//Initialize:
		Model = "models/weapons/w_stunbaton.mdl";

		Name = "weapon_stunstick";
	}

	//Is Weapon:
	if(Random == 11)
	{

		//Initialize:
		Model = "models/weapons/w_irifle.mdl";

		Name = "weapon_ar2";
	}


	if(StrEqual(Model, "Null"))
	{

		//Return:
		return false;
	}

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return false;
	}

	//Declare:
	new Ent2 = CreateEntityByName("prop_physics_override");

	//Is Ent
	if(IsValidEntity(Ent2) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Is Precached:
		if(!IsModelPrecached(Model))
		{

			//Precache:
			PrecacheModel(Model);
		}

		//Values:
		DispatchKeyValue(Ent2, "model", Model);

		//Spawn:
		DispatchSpawn(Ent2);

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Position);

		//Set Origin:
		Position[2] += 20.0;

		//Teleport:
		TeleportEntity(Ent2, Position, NULL_VECTOR, NULL_VECTOR);

		//Initialize:
		WeaponInfo[Ent2] = Name;

		//Init To Spawn Manage:
		SetPropSpawnedTimer(Ent2, 0);

		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return true;
	}

	//Return:
	return false;
}

public Action:GiveClientWeapon(Client, const String:Weapon[])
{

	//Initulize:
	WeaponEq[Client] = 1;

	//Give Weapon:
	GivePlayerItem(Client, Weapon);

	//Initulize:
	WeaponEq[Client] = 0;
}

//Remove Weapons:
public Action:RemoveWeaponsInstant(Client)
{

	//Declare:
	new WeaponId, MaxGuns;

	//Weapons:
	MaxGuns = 64;

	//Loop:
	for(new X = 0; X < MaxGuns; X = (X + 4))
	{

		//Initialize:
		WeaponId = GetEntDataEnt2(Client, WeaponOffset + X);

		//Valid:
		if(WeaponId > GetMaxClients() && IsValidEdict(WeaponId))
		{

			//Weapon:
			RemovePlayerItem(Client, WeaponId);
			AcceptEntityInput(WeaponId, "Kill");
		}
	}

	//Give Weapon:
	GiveClientWeapon(Client, "weapon_physcannon");
}

public Action:AddAmmo(Client, const String:Name[], Amount, MaxAmmo)
{

	//Declare:
	new Ent = HasClientWeapon(Client, Name, 0);

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Declare:
		new offset_ammo = FindDataMapOffs(Client, "m_iAmmo");

		new iPrimary = GetEntProp(Ent, Prop_Data, "m_iPrimaryAmmoType");

		new iAmmo = offset_ammo + (iPrimary * 4);

		new CurrentAmmo = GetEntData(Client, iAmmo, 4);

		//Full Click
		if(iAmmo != MaxAmmo)
		{

			//Check
			if(CurrentAmmo + Amount > MaxAmmo)
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, MaxAmmo, 4, true);
			}

			//Override:
			else
			{

				//Set Ammo:
				SetEntData(Client, iAmmo, CurrentAmmo + Amount, 4, true);
			}
		}
	}
}

public bool:IsAmmo(const String:Name[])
{

	//Check:
	if(StrContains(Name, "item_", false) != -1)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public HasClientWeapon(Client, const String:WeaponName[], Value)
{

	if(Value == 1)
	{

		//Give Item:
		GiveClientWeapon(Client, WeaponName);
	}

	//Declare:
	new MaxGuns = 64;

	//Loop:
	for(new X = 0; X < MaxGuns; X = (X + 4))
	{

		//Declare:
		new WeaponId = GetEntDataEnt2(Client, GetWeaponOffset() + X);

		//Is Valid:
		if(WeaponId > 0)
		{

			//Declare:
			decl String:ClassName[32];

			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));

			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{

				//Return:
				return WeaponId;

			}
		}
	}

	//Return:
	return -1;
}


public Float:GetWeaponDamage(Client)
{

	//declare:
	new Float:Damage = 0.0;

	//Initulize:
	new CurrentWeapon = GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon");

	if(CurrentWeapon != -1)
	{

		//Declare:
		decl String:ClassName[32];

		//Initulize:
		GetEdictClassname(CurrentWeapon, ClassName, sizeof(ClassName));

		//Check:
		if(!strcmp(ClassName, "weapon_physcannon"))
		{

			//Initulize:
			Damage = 10.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_crowbar"))
		{

			//Initulize:
			Damage = 25.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_stunstick"))
		{

			//Initulize:
			Damage = 30.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_pistol"))
		{

			//Initulize:
			Damage = 15.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_357"))
		{

			//Initulize:
			Damage = 75.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_smg1"))
		{

			//Initulize:
			Damage = 15.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_ar2"))
		{

			//Initulize:
			Damage = 20.0;
		}
		//Check:
		if(!strcmp(ClassName, "weapon_shotgun"))
		{

			//Initulize:
			Damage = 60.0;
		}
		//Check:
		if(!strcmp(ClassName, "weapon_crossbow"))
		{

			//Initulize:
			Damage = 100.0;
		}
		//Check:
		if(!strcmp(ClassName, "weapon_grenade"))
		{

			//Initulize:
			Damage = 75.0;
		}

		//Check:
		if(!strcmp(ClassName, "weapon_rpg"))
		{

			//Initulize:
			Damage = 75.0;
		}
		//Check:
		if(!strcmp(ClassName, "weapon_slam"))
		{

			//Initulize:
			Damage = 75.0;
		}
	}

	//Return:
	return Damage;
}
public Action:OnWeaponUse(Client, Ent)
{

	//Declare:
	new ItemId = ConvertWeaponToItem(WeaponInfo[Ent]);

	//Valid Ent:
	if(ItemId != -1)
	{

		//Save:
		SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) + 1));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You pick up a weapon (\x0732CD32%s\x07FFFFFF)!", GetItemName(ItemId));

		//Save:
		WeaponInfo[Ent] = "null";

		//Remove Ent:
		AcceptEntityInput(Ent, "Kill", Client);

		//Initulize
		SetPropSpawnedTimer(Ent, -1);

		SetPropIndex((GetPropIndex() - 1));
	}
}

public ConvertWeaponToItem(String:Weapon[])
{

	//Declare:
	new ItemId = -1;

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_stunstick", false))
	{

		//Initialize:
		ItemId = 9;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_crowbar", false))
	{

		//Initialize:
		ItemId = 4;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_frag", false))
	{

		//Initialize:
		ItemId = 5;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_pistol", false))
	{

		//Initialize:
		ItemId = 6;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_smg1", false))
	{

		//Initialize:
		ItemId = 11;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_shotgun", false))
	{

		//Initialize:
		ItemId = 8;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_rpg", false))
	{

		//Initialize:
		ItemId = 7;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_357", false))
	{

		//Initialize:
		ItemId = 1;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_crossbow", false))
	{

		//Initialize:
		ItemId = 3;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_slam", false))
	{

		//Initialize:
		ItemId = 10;
	}

	//Is Weapon:
	if(StrEqual(Weapon, "weapon_ar2", false))
	{

		//Initialize:
		ItemId = 2;
	}

	//Return:
	return ItemId;
}

public bool:IsValidWeapon(String:WeaponName[])
{

	//Is Weapon:
	if(!StrEqual(WeaponName, "null", false))
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

String:GetWeaponInfo(Ent)
{

	//Return:
	return WeaponInfo[Ent];
}

public SetWeaponInfo(Ent, String:info[32])
{

	//Return:
	WeaponInfo[Ent] = info;
}

public Weapon()
{

	//Return:
	return WeaponOffset;
}
