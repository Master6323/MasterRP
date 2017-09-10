//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/* Double-include prevention */
#if defined _rp_stock_included_
  #endinput
#endif
#define _rp_stock_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//Variable:
static Float:GameTime[MAXPLAYERS + 1] = {0.0,...};
static bool:CommandOverride[MAXPLAYERS + 1] = {false,...};
static Float:lastKilled[MAXPLAYERS + 1] = {0.0,...};
static Float:LastPressedE[MAXPLAYERS + 1] = {0.0,...};
static Float:LastPressedSH[MAXPLAYERS + 1] = {0.0,...};
static bool:Prospective[MAXPLAYERS + 1] = {false,...};

static ClientFrom;
static WaterCache;
static LaserCache;
static SpriteCache;
static ExplodeCache1;
static ExplodeCache2;
static SmokeCache1;
static SmokeCache2;
static GlowBlueCache;

static CollisionOffset;
static WeaponOffset;

static UserMsg:FadeID;
static UserMsg:ShakeID;


static Handle:mp_forcecamera;

public Action:PluginInfo_Stock(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Roleplay Stocks and CMD Blocker!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initStock()
{

	//Chat Hooks:
	HookUserMessage(GetUserMessageId("SayText2"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("SayText"), UserMessageHook, true);

	HookUserMessage(GetUserMessageId("TextMsg"), UserMessageHook, true);

	//Init Convor:
	mp_forcecamera = FindConVar("mp_forcecamera");

	//Command Listener:
	AddCommandListener(DisableCommand, "cl_playermodel");

	AddCommandListener(DisableCommand, "cl_spec_mode");

	AddCommandListener(DisableCommand, "spectate");

	AddCommandListener(DisableCommand, "jointeam");

	AddCommandListener(DisableCommand, "cl_class");

	AddCommandListener(DisableCommand, "cl_team");

	AddCommandListener(DisableCommand, "explode");

	AddCommandListener(HandleKill, "kill");

	AddCommandListener(HandleCommand, "attack");

	AddCommandListener(HandleCommand, "speed");

	AddCommandListener(HandleCommand, "use");

	RegConsoleCmd("sm_firstperson", Command_FirstPerson);

	RegConsoleCmd("sm_thirdperson", Command_ThirdPerson);

	//User Messages:
	FadeID = GetUserMessageId("Fade");

	ShakeID = GetUserMessageId("Shake");
}

initStockCache()
{

	//Precache Material:
	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt", true);

	SpriteCache = PrecacheModel("materials/sprites/halo01.vmt", true);

	ExplodeCache1 = PrecacheModel("sprites/sprite_fire01.vmt", true);

	ExplodeCache2 = PrecacheModel("materials/sprites/sprite_fire01.vmt");

	SmokeCache1 = PrecacheModel("materials/effects/fire_cloud1.vmt",true);

	SmokeCache2 = PrecacheModel("materials/effects/fire_cloud2.vmt",true);

	GlowBlueCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	WaterCache = PrecacheModel("materials/sprites/blueglow2.vmt", true);

	//Find Offsets:
	WeaponOffset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");

	CollisionOffset = FindSendPropInfo("CBasePlayer", "m_CollisionGroup");
}

public OverflowMessage(Client, const String:Contents[255])
{

	//Is In Time:
	if(GameTime[Client] <= (GetGameTime() - 5))
	{

		//Print:
		CPrintToChat(Client, Contents);

		//Initialize:
		GameTime[Client] = GetGameTime();
	}
}

public bool:IsAdmin(client)
{

	//Declare:
	new AdminId:adminId = GetUserAdmin(client);

	//Is Valid Admin:
	if (adminId == INVALID_ADMIN_ID)
	{

		//Return:
		return false;
	}

	//Return:
	return GetAdminFlag(adminId, Admin_Generic);
}

public bool:IsInDistance(Ent1, Ent2)
{

	//Declare:
	decl Float:ClientOrigin[3], Float:EntOrigin[3];

	//Initialize:
	GetEntPropVector(Ent1, Prop_Send, "m_vecOrigin", ClientOrigin);

	GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", EntOrigin);

	//Declare:
	new Float:Dist = GetVectorDistance(ClientOrigin, EntOrigin);

	//In Distance:
	if(Dist <= 150)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public PrintEscapeText(Client, String:text[2048], any:...)
{

	//Declare:
	decl String:message[1024];

	//Format:
	VFormat(message, sizeof(message), text, 3);

	//Handle:
	new Handle:kv = CreateKeyValues("Message", "Title", message);

	//Set Color:
	KvSetColor(kv, "color", 50, 250, 50, 255);

	//Set Number:
	KvSetNum(kv, "level", 1);

	//Set Float:
	KvSetFloat(kv, "time", 1.5);

	//Show Menu:
	CreateDialog(Client, kv, DialogType_Text);

	//Close:
	CloseHandle(kv);
}

//Covert To String:
public SteamIdToInt(Client)
{

	//Declare:
	decl String:SteamId[32];

	//Initulize:
	GetClientAuthString(Client, SteamId, 32);

	//Declare:
	decl String:subinfo[3][16];

	//Explode:
	ExplodeString(SteamId, ":", subinfo, sizeof(subinfo), sizeof(subinfo[]));

	//Initulize:
	new Int = StringToInt(subinfo[2], 10);

	if(StrEqual(subinfo[1], "1"))
	{

		//Initulize:
		Int *= -1;
	}

	//Return:
	return Int;
}

//Return Money:
String:IntToMoney(Intiger)
{

	//Declare:
	new slen, Pointer, String:IntStr[32], bool:negative;

	//Declare:
	decl String:Result[128];

	//Initulize:
	negative = Intiger < 0;

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Intiger *= -1;
	}

	//Convert:
	IntToString(Intiger, IntStr, sizeof(IntStr));

	//Initulize:
	slen = strlen(IntStr);
	Intiger = slen % 3;

	//Is Valid:
	if(Intiger == 0)
	{

		//Initulize:
		Intiger = 3;
	}

	//Format:
	Format(Result, Intiger + 1, "%s", IntStr);

	//Initulize:
	slen -= Intiger;
	Pointer = Intiger + 1;

	//Loop:
	for(new i = Intiger; i <= slen ; i += 3)
	{

		//Initulize:
		Pointer += 4;

		//Format:
		Format(Result, Pointer, "%s,%s",Result, IntStr[i]);
	}

	//Is Valid:
	if(negative)
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬-%s", Result);
	}

	//Override:
	else
	{

		//Initulize:
		Format(Result, sizeof(Result), "â‚¬%s", Result);
	}

	//Return:
	return Result;
}

//Bipass Cheats:
public CheatCommand(Client, const String:command[], const String:arguments[])
{

	//Define:
	new admindata = GetUserFlagBits(Client);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, ADMFLAG_ROOT);

	//Define:
	new flags = GetCommandFlags(command);

	//Set Client Flags:
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);

	//Command:
	ClientCommand(Client, "\"%s\" \"%s\"", command, arguments);

	//Set Client Flags:
	SetCommandFlags(command, flags);

	//Set Client Flag Bits:
	SetUserFlagBits(Client, admindata);
}

public Action:DisableCommand(Client, const String:Command[], Argc)
{

	//Is Override:
	if(CommandOverride[Client] == true)
	{

		//Return::
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

public Action:UserMessageHook(UserMsg:MsgId, Handle:hBitBuffer, const iPlayers[], iNumPlayers, bool:bReliable, bool:bInit)
{

	//Get Info:
	BfReadByte(hBitBuffer);

	BfReadByte(hBitBuffer);

	//Declare:
	decl String:strMessage[1024];

	//Read UserMessage
	BfReadString(hBitBuffer, strMessage, sizeof(strMessage));

	//Check:
	if(StrContains(strMessage, "before trying to switch", false) != -1)
	{

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

public Action:HandleKill(Client, const String:Command[], Argc)
{

	//Is In Time::
	if(lastKilled[Client] < (GetGameTime() - 60))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you will die in 10 seconds!");

		//Timer:
		CreateTimer(10.0, KillPlayer, Client);

		//Initulize:
		lastKilled[Client] = GetGameTime();
	}

	//Override:
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot use this command too often!");
	}

	//Return:
	return Plugin_Handled;
}

//Spawn Timer:
public Action:KillPlayer(Handle:Timer, any:Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Slay Client:
		ForcePlayerSuicide(Client);
	}
}

public Action:HandleCommand(Client, const String:Command[], Argc)
{

	//Is Valid:
	if(!IsCuffed(Client))
	{

		//Return::
		return Plugin_Continue;
	}

	//Return:
	return Plugin_Handled;
}

public CheckMapEntityCount()
{

	//Declare:
	new Amount = 0;

	//Loop:
	for(new i = 0; i <= 2047; i++)
	{

		//Is Valid:
		if(IsValidEdict(i) || IsValidEntity(i) || i == 0)
		{

			//Initialize:
			Amount++;
		}
	}

	//Return:
	return Amount;
}

public bool:TraceEntityFilterPlayer(Entity, ContentsMask)
{

	//Return:
	return Entity != ClientFrom;
}

public bool:TraceEntityFilterEntity(Entity, ContentsMask, any:Data)
{

	//Return:
	return Entity > 0 && Entity != ClientFrom && Data != Entity;
}

public bool:TraceEntityFilterWall(Entity, ContentsMask)
{

	//Return:
	return !Entity;
}

public bool:LookingAtWall(Client)
{

	//Declare:
	decl Float:Origin[3], Float:Angles[3], Float:EndPos[3];

	//Initialize:
	GetClientEyePosition(Client, Origin);

	GetClientEyeAngles(Client, Angles);

	//Declare:
	decl Float:dist1;
	dist1 = 0.0;
	decl Float:dist2;
	dist2 = 0.0;

	ClientFrom = Client;

	//Handle:
	new Handle:Trace1 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterEntity, Client);

	//Is Tracer
	if(TR_DidHit(Trace1))
	{
		TR_GetEndPosition(EndPos, Trace1);

			//Initialize:
		dist1 = GetVectorDistance(Origin, EndPos);
	}
	else
	{
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace1);

	//Handle:
	new Handle:Trace2 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterWall);
   	 	
	//Is Tracer
	if(TR_DidHit(Trace2))
	{
		TR_GetEndPosition(EndPos, Trace2);

		//Initialize:
		dist2 = GetVectorDistance(Origin, EndPos);
	}

	//Override:
	else
	{

		//Initialize:
		dist2 = -1.0;
	}

	//Close:
	CloseHandle(Trace2);

	ClientFrom = -1;

	//Initialize:
	if(dist1 >= dist2)
	{

		//Return:
		return true;
	}

	//Return:
	return false;
}

public bool:IsTargetInLineOfSight(Subject, Target)
{

	//Declare:
	decl Float:Position[3], Float:TargetPos[3], Float:EndPos[3];

	//Initulize:
	GetEntPropVector(Subject, Prop_Send, "m_vecOrigin", Position);
	GetEntPropVector(Target, Prop_Send, "m_vecOrigin", TargetPos);

	Position[2] + 20.0;
	TargetPos[2] + 20.0;

	ClientFrom = Subject;

	//Declare:
	decl Float:dist1;
	dist1 = 0.0;

	//Set Up Trace:
	new Handle:Trace = TR_TraceRayFilterEx(Position, TargetPos, MASK_SHOT, RayType_EndPoint, TraceEntityFilterEntity, Target);

	//Is Tracer
	if(TR_DidHit(Trace))
	{
		TR_GetEndPosition(EndPos, Trace);

		//Initialize:
		dist1 = GetVectorDistance(TargetPos, EndPos);
	}
	else
	{
		dist1 = -1.0;
	}

	//Close:
	CloseHandle(Trace);

	ClientFrom = -1;

	//PrintToServer("|RP| - dist1 = %f dist2 = %f", dist1, dist2);

	//Initialize:
	if(dist1 > 0)
	{

		//Return:
		return false;
	}

	//Return:
	return true;
}

public Action:GetCollisionPoint(Client, Float:Pos[3])
{

	//Declare:
	decl Float:vOrigin[3], Float:vAngles[3];

	//Initulize:
	GetClientEyePosition(Client, vOrigin);

	GetClientEyeAngles(Client, vAngles);

	ClientFrom = Client;

	//Handle:
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);

	//Hit Target:
	if(TR_DidHit(trace))
	{

		//Get Ent:
		TR_GetEndPosition(Pos, trace);

		//Close:
		CloseHandle(trace);

		//Return:
		return;
	}

	//Close:
	CloseHandle(trace);
}

public GetAngleBetweenEntities(Ent, OtherEnt, Float:Angles[3])
{

	//Declare:
	new Float:Origin[3], Float:OtherOrigin[3], Float:Buffer[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Loop:
	for(new X = 0; X <= 2; X++)
	{

		//Initulize:
		Buffer[X] = FloatSub(Origin[X], OtherOrigin[X]);
	}

	//Normal:
	NormalizeVector(Buffer, Buffer);

	//Get Angles:
	GetVectorAngles(Buffer, Angles);
}


public GetPullBetweenEntities(Ent, OtherEnt, Float:Scale, Float:Pull[3])
{

	//Declare:
	new Float:Origin[3], Float:OtherOrigin[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

	GetEntPropVector(OtherEnt, Prop_Send, "m_vecOrigin", OtherOrigin);

	//Caclulate:
	Pull[0] = (FloatMul(Scale, (FloatSub(Origin[0], OtherOrigin[0]))));
    	Pull[1] = (FloatMul(Scale, (FloatSub(Origin[1], OtherOrigin[1]))));
    	Pull[2] = -25.0;
}

public GetPushBetweenEntities(Ent, Float:Scale, Float:Push[3])
{

	//Declare:
	new Float:EyeAngles[3];

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", EyeAngles);

	//Caclulate:
	Push[0] = (FloatMul(Scale, Cosine(DegToRad(EyeAngles[1]))));

    	Push[1] = (FloatMul(Scale, Sine(DegToRad(EyeAngles[1]))));

    	Push[2] = (FloatMul((Scale / 10.0), Sine(DegToRad(EyeAngles[0]))));
}

public LoadString(Handle:Vault, const String:Key[32], const String:SaveKey[255], const String:DefaultValue[255], String:Reference[255])
{

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	KvGetString(Vault, SaveKey, Reference, 255, DefaultValue);

	//Restart KV:
	KvRewind(Vault);
}

public SaveString(Handle:Vault, const String:Key[32], const String:SaveKey[255], const String:Variable[255])
{

	//Skip:
	KvJumpToKey(Vault, Key, true);

	//Set KV:
	KvSetString(Vault, SaveKey, Variable);

	//Restart KV:
	KvRewind(Vault);
}

public LoadInteger(Handle:Vault, const String:Key[32], const String:SaveKey[255], DefaultValue)
{

	//Declare:
	decl Variable;

	//Skip:
	KvJumpToKey(Vault, Key, false);

	//Get KV:
	Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	//Restart KV:
	KvRewind(Vault);

	//Return:
	return Variable;
}

public Action:PerformBlind(Client, amount)
{

	//Declare
	new SendClient[2];

	SendClient[0] = Client;

	//Handle:
	new Handle:message = StartMessageEx(FadeID, SendClient, 1);

	//Write Handle:
	BfWriteShort(message, 9000);

	BfWriteShort(message, 9000);

	//Check:
	if (amount == 0)
	{

		//Out and Stayout
		BfWriteShort(message, (0x0001 | 0x0010));
	}

	//Override:
	else
	{

		//Out and Stayout
		BfWriteShort(message, (0x0002 | 0x0008));
	}

	//Write Handle:
	BfWriteByte(message, 0);

	BfWriteByte(message, 0);

	BfWriteByte(message, 0);

	//Alpha
	BfWriteByte(message, amount);

	//Cloose:
	EndMessage();
}

public Action:PerformUnBlind(Client)
{

	//Declare
	new SendClient[2];

	SendClient[0] = Client;

	//Handle:
	new Handle:message = StartMessageEx(FadeID, SendClient, 1);

	//Write Handle:
	BfWriteShort(message, 15);

	BfWriteShort(message, 0);

	//Out and Stayout
	BfWriteShort(message, (0x0001 | 0x0010));

	//Write Handle:
	BfWriteByte(message, 0);

	BfWriteByte(message, 0);

	BfWriteByte(message, 0);

	//Alpha
	BfWriteByte(message, 0);

	//Cloose:
	EndMessage();
}

//shake effect
public Action:ShakeClient(Client, Float:Length, Float:Severity)
{

	//Conntected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		new SendClient[2];
		SendClient[0] = Client;

		//Handle:
		new Handle:ViewMessage = StartMessageEx(ShakeID, SendClient, 1);

		//Write Handle:
		BfWriteByte(ViewMessage, 0);

		BfWriteFloat(ViewMessage, Severity);

		BfWriteFloat(ViewMessage, 10.0);

		BfWriteFloat(ViewMessage, Length);

		//Close:
		EndMessage();
	}
}
public Float:GetBlastDamage(Float:Dist)
{

	//Declare:
	new Float:Damage = 0.0;

	//Get Damage:
	if(Dist >= 0.0 <= 25.0) Damage = 250.0;
	if(Dist >= 26.0 <= 50.0) Damage = 200.0;
	if(Dist >= 51.0 <= 75.0) Damage = 175.0;
	if(Dist >= 76.0 <= 100.0) Damage = 122.0;
	if(Dist >= 101.0 <= 150.0) Damage = 71.0;
	if(Dist >= 151.0 <= 200.0) Damage = 45.0;
	if(Dist >= 201.0 <= 250.0) Damage = 10.0;

	//Return:
	return Damage;
}

//Show Player Hud
public Action:ResetClientOverlay(Client)
{

	//Command:
	CheatCommand(Client, "r_screenoverlay", "0");
}

public GetCollisionOffset()
{

	//Return:
	return CollisionOffset;
}

public GetWeaponOffset()
{

	//Return:
	return WeaponOffset;
}

public HideHud(Client, Type)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Send, "m_iHideHUD", Type);
}

public SetEntityArmor(Client, Armor)
{

	//Initialize:
	SetEntProp(Client, Prop_Data, "m_ArmorValue", Armor, 4);
}

public GetClientScore(Client)
{

	//Return:
	return GetEntProp(Client, Prop_Data, "m_iFrags");
}

public SetClientScore(Client, Score)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iFrags", Score);
}

public SetClientDeath(Client, Death)
{

	//Set Prop Data:
	SetEntProp(Client, Prop_Data, "m_iDeaths", Death); 
}

public GetEntHealth(Ent)
{

	//Return:
	return GetEntProp(Ent, Prop_Data, "m_iHealth");
}

public SetEntHealth(Ent, Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iHealth", Health);
}

public GetEntMaxHealth(Ent)
{

	//Return:
	return GetEntProp(Ent, Prop_Data, "m_iMaxHealth");
}

public SetEntMaxHealth(Ent, Health)
{

	//Return:
	SetEntProp(Ent, Prop_Data, "m_iMaxHealth", Health);
}

stock SetEntitySpeed(Client, Float:fSpeed)
{

	//Set Prop Data:
	SetEntPropFloat(Client, Prop_Data, "m_flLaggedMovementValue", fSpeed);	
}

stock GetClientTeamEx(Client)
{

	//Get Client Team:
	new m_iTeamNum = FindSendPropOffs("CBasePlayer", "m_iTeamNum");

	//Return:
	return m_iTeamNum;
}

stock ChangeClientTeamEx(Client, Team)
{

	//Get Client Team:
	new m_iTeamNum = FindSendPropOffs("CBasePlayer", "m_iTeamNum");

	//Set Prop Data:
	SetEntData(Client, m_iTeamNum, Team);
}

String:ServerMap()
{

	//Declare:
	decl String:Map[64];

	//Initialize:
	GetCurrentMap(Map, sizeof(Map));

	//Return
	return Map;
}

public Float:GetLastPressedE(Client)
{

	//Return:
	return LastPressedE[Client];
}

public SetLastPressedE(Client, Float:Time)
{

	//Initulize:
	LastPressedE[Client] = Time;
}

public Float:GetLastPressedSH(Client)
{

	//Return:
	return LastPressedE[Client];
}

public SetLastPressedSH(Client, Float:Time)
{

	//Initulize:
	LastPressedSH[Client] = Time;
}

//Cache Natives:
public Laser()
{

	//Return:
	return LaserCache;
}

public Sprite()
{

	//Return:
	return SpriteCache;
}
public Explode()
{

	//Return:
	return ExplodeCache1;
}

public ExplodeNew()
{

	//Return:
	return ExplodeCache2;
}

public Smoke()
{

	//Return:
	return SmokeCache1;
}

public SmokeNew()
{

	//Return:
	return SmokeCache2;
}

public GlowBlue()
{

	//Return:
	return GlowBlueCache;
}

public Water()
{

	//Return:
	return WaterCache;
}

public GetObserverMode(Client)
{

	//Return:
	return GetEntProp(Client, Prop_Send, "m_iObserverMode");
}

public GetObserverTarget(Client)
{

	//Return:
	return GetEntProp(Client, Prop_Send, "m_hObserverTarget");
}

public Action:Command_FirstPerson(Client, Args)
{

	//Check:
	if(Prospective[Client])
	{

		//Initulize:
		Prospective[Client] = false;

		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", -1);

		SetEntProp(Client, Prop_Send, "m_iObserverMode", 0);

		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 1);

		SetEntProp(Client, Prop_Send, "m_iFOV", 90);


		//Declare:
		decl String:valor[6];


		//Get String:
		GetConVarString(mp_forcecamera, valor, 6);


		//Set String:
		SendConVarValue(Client, mp_forcecamera, valor);
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already in FirstPerson Mode!");
	}

	//Return:
	return Plugin_Handled;
}

public Action:Command_ThirdPerson(Client, Args)
{

	//Check:
	if(!Prospective[Client])
	{

		//Initulize:
		Prospective[Client] = true;

		SetEntPropEnt(Client, Prop_Send, "m_hObserverTarget", Client);
 
		SetEntProp(Client, Prop_Send, "m_iObserverMode", 5);

		SetEntProp(Client, Prop_Send, "m_bDrawViewmodel", 0);

		SetEntProp(Client, Prop_Send, "m_iFOV", 120);

		SendConVarValue(Client, mp_forcecamera, "1");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are already in ThirdPerson Mode!");
	}

	//Return:
	return Plugin_Handled;
}

public bool:GetThirdPersonView(Client)
{

	//Return:
	return Prospective[Client];
}

public bool:intTobool(i)
{

	if(i == 1) return true;
	else return false;
}

public boolToint(bool:i)
{

	if(i) return 1;
	else return 0;
}
public TE_SetupGaussExplosion(const Float:vecOrigin[3], type, Float:direction[3])
{
	

 	TE_Start("GaussExplosion");

	TE_WriteFloat("m_vecOrigin[0]", vecOrigin[0]);

	TE_WriteFloat("m_vecOrigin[1]", vecOrigin[1]);

	TE_WriteFloat("m_vecOrigin[2]", vecOrigin[2]);

	TE_WriteNum("m_nType", type);

	TE_WriteVector("m_vecDirection", direction);

}
/*
public Action testmessage(client, args)
{
	decl String:arg1[64];
	char arg2[64];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	int ent = CreateEntityByName("game_text");
	DispatchKeyValue(ent, "channel", "1");
	DispatchKeyValue(ent, "color", "255 255 255");
	DispatchKeyValue(ent, "color2", "0 0 0");
	DispatchKeyValue(ent, "effect", "0");
	DispatchKeyValue(ent, "fadein", "1.5");
	DispatchKeyValue(ent, "fadeout", "0.5");
	DispatchKeyValue(ent, "fxtime", "0.25"); 		
	DispatchKeyValue(ent, "holdtime", "5.0");
	DispatchKeyValue(ent, "message", "this is a test message\nThis is a new line test");
	DispatchKeyValue(ent, "spawnflags", "0"); 	
	DispatchKeyValue(ent, "x", arg1);
	DispatchKeyValue(ent, "y", arg2); 		
	DispatchSpawn(ent);
	SetVariantString("!activator");
	AcceptEntityInput(ent,"display",client);
	return Plugin_Handled;
}


	new entity = CreateEntityByName("env_spritetrail");
	DispatchKeyValueVector(entity, "origin", vOrigin);
	DispatchKeyValue(entity, "spritename", "sprites/laser.vmt");
	DispatchKeyValue(entity, "rendermode", "5");
	DispatchKeyValue(entity, "renderamt", "255");
	DispatchKeyValueFloat(entity, "lifetime", g_fCvarLife);
	DispatchKeyValue(entity, "rendercolor", sTemp);
	DispatchKeyValueFloat(entity, "startwidth", "5.0");
	DispatchKeyValueFloat(entity, "endwidth", "5.0");
	DispatchSpawn(entity);

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", target);
	AcceptEntityInput(entity, "ShowSprite");
float newp[3];
float rotation[4][4];
SetupMatrix(180.0, vec, rotation, back);
MultiplyMatrix(nright, rotation, newp);

//----------------------------------

stock void MultiplyMatrix(float input[3], float rotation[4][4], float output[3])
{
    float input2[4];
    input2[0] = input[0];
    input2[1] = input[1];
    input2[2] = input[2];
    input2[3] = 1.0;
    
    float output2[4];
    for(int i = 0 ; i < 4 ; i++)
    {
        for(int j = 0 ; j < 4 ; j++)
        {
            output2[i] += rotation[i][j] * input2[j];
        }
    }
    
    output[0] = output2[0];
    output[1] = output2[1];
    output[2] = output2[2];
}

stock void SetupMatrix(float angle, float vector[3], float rotation[4][4], float point[3])
{
    float L = (vector[0] * vector[0] + vector[1] * vector[1] + vector[2] * vector[2]);
    //angle = angle * M_PI / 180.0;
    float u2 = vector[0] * vector[0];
    float v2 = vector[1] * vector[1];
    float w2 = vector[2] * vector[2];
    
    PrintToChatAll("Debug(): L = %.1f", L);
    
    rotation[0][0] = (u2 + (v2 + w2) * Cosine(angle)) / L;
    rotation[0][1] = (vector[0] * vector[1] * (1 - Cosine(angle)) - vector[2] * SquareRoot(L) * Sine(angle)) / L;
    rotation[0][2] = (vector[0] * vector[2] * (1 - Cosine(angle)) + vector[1] * SquareRoot(L) * Sine(angle)) / L;
    //rotation[0][3] = 0.0;
    rotation[0][3] = ((point[0] * (v2 + w2) - vector[0] * (point[1] * vector[1] + point[2] * vector[2])) * (1 - Cosine(angle)) + (point[1] * vector[2] - point[2] * vector[1]) * SquareRoot(L) * Sine(angle)) / L;
    
    rotation[1][0] = (vector[0] * vector[1] * (1 - Cosine(angle)) + vector[2] * SquareRoot(L) * Sine(angle)) / L;
    rotation[1][1] = (v2 + (u2 + w2) * Cosine(angle)) / L;
    rotation[1][2] = (vector[1] * vector[2] * (1 - Cosine(angle)) - vector[0] * SquareRoot(L) * Sine(angle)) / L;
    //rotation[1][3] = 0.0;
    rotation[1][3] = ((point[1] * (u2 + w2) - vector[1] * (point[0] * vector[0] + point[2] * vector[2])) * (1 - Cosine(angle)) + (point[2] * vector[0] - point[0] * vector[2]) * SquareRoot(L) * Sine(angle)) / L;
    
    rotation[2][0] = (vector[0] * vector[2] * (1 - Cosine(angle)) - vector[1] * SquareRoot(L) * Sine(angle)) / L;
    rotation[2][1] = (vector[1] * vector[2] * (1 - Cosine(angle)) + vector[0] * SquareRoot(L) * Sine(angle)) / L;
    rotation[2][2] = (w2 + (u2 + v2) * Cosine(angle)) / L;
    //rotation[2][3] = 0.0;
    rotation[2][3] = ((point[2] * (u2 + v2) - vector[2] * (point[0] * vector[0] + point[1] * vector[1])) * (1 - Cosine(angle)) + (point[0] * vector[1] - point[1] * vector[0]) * SquareRoot(L) * Sine(angle)) / L;
    
    rotation[3][0] = 0.0;
    rotation[3][1] = 0.0;
    rotation[3][2] = 0.0;
    rotation[3][3] = 1.0;
}

AnglesToUV(Float:vOut[3], const Float:vAngles[3]) 
{ 
    vOut[0] = Cosine(vAngles[1] * FLOAT_PI / 180.0) * Cosine(vAngles[0] * FLOAT_PI / 180.0); 
    vOut[1] = Sine(vAngles[1] * FLOAT_PI / 180.0) * Cosine(vAngles[0] * FLOAT_PI / 180.0); 
    vOut[2] = -Sine(vAngles[0] * FLOAT_PI / 180.0); 
}

void TE_SetupGaussExplosion(const float vecOrigin[3], int type, float direction[3]){	
 	TE_Start("GaussExplosion");
	TE_WriteFloat("m_vecOrigin[0]", vecOrigin[0]);
	TE_WriteFloat("m_vecOrigin[1]", vecOrigin[1]);
	TE_WriteFloat("m_vecOrigin[2]", vecOrigin[2]);
	TE_WriteNum("m_nType", type);
	TE_WriteVector("m_vecDirection", direction);
}

#define SF_SENTRY_UPGRADABLE  (1<<4)

int existingFlags = GetEntProp(ent, Prop_Data, "m_spawnflags");
SetEntProp(ent, Prop_Data, "m_spawnflags", existingFlags | SF_SENTRY_UPGRADABLE);  
*/