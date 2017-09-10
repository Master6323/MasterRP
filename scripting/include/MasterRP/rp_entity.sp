//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_entity_included_
  #endinput
#endif
#define _rp_entity_included_

public EntityDissolve(Ent, Type)
{

	//Declare:
	new Dissolver = CreateEntityByName("env_entity_dissolver");

	//Check:
	if(Dissolver > 0)
	{

		//declare:
		decl String:TargetName[32], String:sType[32];

		//Format:
		Format(TargetName, sizeof(TargetName), "dis_%i", Ent);

		Format(sType, sizeof(sType), "%i", Type);

		//Dispatch:
		DispatchKeyValue(Ent, "targetname", TargetName);

		DispatchKeyValue(Dissolver, "dissolvetype", sType);

		DispatchKeyValue(Dissolver, "target", TargetName);

		//Accept:
		AcceptEntityInput(Dissolver, "Dissolve");

		AcceptEntityInput(Dissolver, "kill");
	}
}

public CreatePointTesla(Ent, String:Attachment[], String:Color[64])
{

	//Declare:
	new Tesla = CreateEntityByName("point_tesla");

	//Check:
	if(IsValidEdict(Tesla))
	{

		//Dispatch:
		DispatchKeyValue(Tesla, "m_flRadius", "100.0");

		DispatchKeyValue(Tesla, "m_SoundName", "DoSpark");

		DispatchKeyValue(Tesla, "beamcount_min", "10");

		DispatchKeyValue(Tesla, "beamcount_max", "20");

		DispatchKeyValue(Tesla, "texture", "sprites/physbeam.vmt");

		DispatchKeyValue(Tesla, "m_Color", Color);

		DispatchKeyValue(Tesla, "thick_min", "3.0");

		DispatchKeyValue(Tesla, "thick_max", "6.0");

		DispatchKeyValue(Tesla, "lifetime_min", "0.3");

		DispatchKeyValue(Tesla, "lifetime_max", "0.3");

		DispatchKeyValue(Tesla, "interval_min", "0.1");

		DispatchKeyValue(Tesla, "interval_max", "0.2");

		//Set Owner
		SetEntPropEnt(Tesla, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Tesla);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Tesla, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Tesla, "SetParent", Ent, Tesla, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Tesla, "SetParentAttachment", Tesla , Tesla, 0);
		}

		//Spark:
		AcceptEntityInput(Tesla, "DoSpark");

		//Return:
		return Tesla;
	}

	//Return:
	return -1;
}

//Decal:
public CreateEnvBlood(Client, Float:Direction[3], Float:Time)
{

	//Declare:
	decl Blood;
	decl String:Angles[128];

	//Format:
	Format(Angles, 128, "%f %f %f", Direction[0], Direction[1], Direction[2]);

	//Blood:
	Blood = CreateEntityByName("env_blood");

	//Create:
	if(IsValidEdict(Blood))
	{

		//Spawn:
		DispatchSpawn(Blood);

		//Properties:
		DispatchKeyValue(Blood, "color", "0");

		DispatchKeyValue(Blood, "amount", "1000");

		DispatchKeyValue(Blood, "spraydir", Angles);

		DispatchKeyValue(Blood, "spawnflags", "12");

		//Save & Send:
		CreateTimer(Time, RemoveBlood, Blood);

		//Accept:
		AcceptEntityInput(Blood, "EmitBlood", Client);

		//Return:
		return Blood;
	}

	//Return:
	return -1;
}

public Action:RemoveBlood(Handle:Timer, any:Ent)
{

	//Check:
	if(IsValidEdict(Ent))
	{

		//Accept:
		AcceptEntityInput(Ent, "kill");
	}
}

public CreateEnvFire(Ent, String:Attachment[], String:Health[12], String:Size[12], String:Attack[12], String:Type[12])
{

	//Declare:
	new Fire = CreateEntityByName("env_fire");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire , Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}

public CreateEnvFireTrail(Ent, String:Attachment[], String:Health[12], String:Size[12], String:Attack[12], String:Type[12])
{

	//Declare:
	new Fire = CreateEntityByName("env_fire_trail");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		DispatchKeyValue(Fire, "spawnflags", "1");

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire , Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}

public CreateFireSmoke(Ent, String:Attachment[], String:Health[12], String:Size[12], String:Attack[12], String:Type[12])
{

	//Declare:
	new Fire = CreateEntityByName("_firesmoke");

	//Check:
	if(IsValidEdict(Fire) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Fire, "health", Health);

		DispatchKeyValue(Fire, "firesize", Size);

		DispatchKeyValue(Fire, "fireattack", Attack);

		DispatchKeyValue(Fire, "firetype", Type);

		DispatchKeyValue(Fire, "ignitionpoint", "0");

		DispatchKeyValue(Fire, "damagescale", "0");

		//Spawn
		DispatchSpawn(Fire);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Fire, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Fire, "SetParent", Ent, Fire, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Fire, "SetParentAttachment", Fire , Fire, 0);
		}

		//Accept:
		AcceptEntityInput(Fire, "enable");

		AcceptEntityInput(Fire, "startfire");

		//Return:
		return Fire;
	}

	//Return:
	return -1;
}

public CreateProp(Float:Origin[3], Float:Angles[3], String:Model[255], bool:WalkThru, bool:Stuck, bool:IndexTimer)
{

	//Initialize:
	new Ent = CreateEntityByName("prop_physics_override");

	//Check:
	if(IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(Ent, "model", "models/props_junk/trashdumpster02.mdl");

		//Spawn:
		DispatchSpawn(Ent);

		//Send:
		TeleportEntity(Ent, Origin, Angles, NULL_VECTOR);

		//Send:
		SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);

		//Check:
		if(WalkThru)
		{

			//Debris:
			new Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

			//Send:
			SetEntData(Ent, Collision, 1, 1, true);
		}

		//Check:
		if(Stuck)
		{

			//Accept:
			AcceptEntityInput(Ent, "disablemotion", Ent);
		}

		//Check:
		if(IndexTimer)
		{

			//Initulize:
			SetPropSpawnedTimer(Ent, 0);
		}

		//Initulize:
		SetPropIndex((GetPropIndex() + 1));

		//Return:
		return Ent;
	}

	//Return:
	return -1;
}

public CreateEnvSmokeStack(Ent, String:Attachment[], String:Material[255], String:Color[32], String:BaseSpread[12], String:SpreadSpeed[12], String:Speed[12], String:StartSize[12], String:EndSize[12], String:Rate[12], String:JetLength[12], String:Twist[12])
{

	//Declare:
	new SmokeStack = CreateEntityByName("env_smokestack");

	//Check:
	if(IsValidEdict(SmokeStack) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(SmokeStack, "smokematerial", Material);

		DispatchKeyValue(SmokeStack, "rendercolor", Color);

		DispatchKeyValue(SmokeStack, "InitialState", "0");

		DispatchKeyValue(SmokeStack, "BaseSpread", BaseSpread);

		DispatchKeyValue(SmokeStack, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(SmokeStack, "Speed", Speed);

		DispatchKeyValue(SmokeStack, "StartSize", StartSize);

		DispatchKeyValue(SmokeStack, "EndSize", EndSize);

		DispatchKeyValue(SmokeStack, "Rate", Rate);

		DispatchKeyValue(SmokeStack, "JetLength", JetLength);

		DispatchKeyValue(SmokeStack, "twist", Twist);

		//Spawn
		DispatchSpawn(SmokeStack);

		//Accept:
		AcceptEntityInput(Ent, "turnon");

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SmokeStack, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SmokeStack, "SetParent", Ent, SmokeStack, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SmokeStack, "SetParentAttachment", SmokeStack, SmokeStack, 0);
		}

		//Accept:
		AcceptEntityInput(SmokeStack, "enable");

		//Return:
		return SmokeStack;
	}

	//Return:
	return -1;
}

//CreateEnvSmokeTrail(Ent, String:Attachment[], "materials/effects/fire_cloud1.vmt", "20.0", "10.0", "50.0", "5", "3", "50", "100", "0", "255 50 50", "5");
public CreateEnvSmokeTrail(Ent, String:Attachment[], String:Material[255], String:BaseSpread[12], String:SpreadSpeed[12], String:Speed[12], String:StartSize[12], String:EndSize[12], String:Rate[12], String:JetLength[12], String:Twist[12], String:Color[32], String:Transparency[12])
{

	//Declare:
	new SmokeTrail = CreateEntityByName("env_smoketrail");

	//Check:
	if(IsValidEdict(SmokeTrail) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(SmokeTrail, "SmokeMaterial", Material);

		DispatchKeyValue(SmokeTrail, "InitialState", "1");

		DispatchKeyValue(SmokeTrail, "BaseSpread", BaseSpread);

		DispatchKeyValue(SmokeTrail, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(SmokeTrail, "Speed", Speed);

		DispatchKeyValue(SmokeTrail, "StartSize", StartSize);

		DispatchKeyValue(SmokeTrail, "EndSize", EndSize);

		DispatchKeyValue(SmokeTrail, "Rate", Rate);

		DispatchKeyValue(SmokeTrail, "JetLength", JetLength);

		DispatchKeyValue(SmokeTrail, "twist", Twist);

		//DispatchKeyValue(SmokeTrail, "RenderColor", Color);

		DispatchKeyValue(SmokeTrail, "StartColor", Color);

		DispatchKeyValue(SmokeTrail, "Renderfx", Transparency);

		//Spawn
		DispatchSpawn(SmokeTrail);

		//Accept:
		AcceptEntityInput(Ent, "TurnOn");

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(SmokeTrail, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(SmokeTrail, "SetParent", Ent, SmokeTrail, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(SmokeTrail, "SetParentAttachment", SmokeTrail, SmokeTrail, 0);
		}

		//Accept:
		AcceptEntityInput(SmokeTrail, "enable");

		//Return:
		return SmokeTrail;
	}

	//Return:
	return -1;
}

public CreateEnvSplash(Ent, String:Attachment[], String:SplashScale[12])
{

	//Declare:
	new Splash = CreateEntityByName("env_splash");

	//Check:
	if(IsValidEdict(Splash))
	{

		//Dispatch:
		DispatchKeyValue(Splash, "Scale", SplashScale); // Float

		//Set Owner
		SetEntPropEnt(Splash, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Splash);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Splash, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Splash, "SetParent", Ent, Splash, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Splash, "SetParentAttachment", Splash, Splash, 0);
		}

		//Spark:
		AcceptEntityInput(Splash, "Splash");

		//Return:
		return Splash;
	}

	//Return:
	return -1;
}

public CreateEnvSteam(Ent, String:Attachment[], String:Color[32], String:Translucency[12], String:Type[12], String:SpreadSpeed[12], String:Speed[12], String:StartSize[12], String:EndSize[12], String:Rate[12], String:JetLength[12], String:Spin[12])
{

	//Declare:
	new Steam = CreateEntityByName("env_steam");

	//Check:
	if(IsValidEdict(Steam))
	{

		//Dispatch:
		DispatchKeyValue(Steam, "RenderColor", Color);

		DispatchKeyValue(Steam, "RenderAmt", Translucency);

		DispatchKeyValue(Steam, "InitialState", "1");

		DispatchKeyValue(Steam, "Type", Type);

		DispatchKeyValue(Steam, "SpreadSpeed", SpreadSpeed);

		DispatchKeyValue(Steam, "Speed", Speed);

		DispatchKeyValue(Steam, "StartSize", StartSize);

		DispatchKeyValue(Steam, "EndSize", EndSize);

		DispatchKeyValue(Steam, "Rate", Rate);

		DispatchKeyValue(Steam, "JetLength", JetLength);

		DispatchKeyValue(Steam, "Spin", Spin);

		//Set Owner
		SetEntPropEnt(Steam, Prop_Send, "m_hOwnerEntity", Ent);

		//Spawn:
		DispatchSpawn(Steam);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Steam, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Steam, "SetParent", Ent, Steam, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Steam, "SetParentAttachment", Steam, Steam, 0);
		}

		//Spark:
		AcceptEntityInput(Steam, "TurnOn");

		//Return:
		return Steam;
	}

	//Return:
	return -1;
}

public CreateEnvAr2Explosion(Ent, String:Attachment[], String:Material[255])
{

	//Declare:
	new Ar2Explosion = CreateEntityByName("env_ar2explosion");

	//Check:
	if(IsValidEdict(Ar2Explosion) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(Ar2Explosion, "Material", Material);

		//Spawn
		DispatchSpawn(Ar2Explosion);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(Ar2Explosion, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(Ar2Explosion, "SetParent", Ent, Ar2Explosion, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(Ar2Explosion, "SetParentAttachment", Ar2Explosion, Ar2Explosion, 0);
		}

		//Accept:
		AcceptEntityInput(Ar2Explosion, "explode");

		//Return:
		return Ar2Explosion;
	}

	//Return:
	return -1;
}

public CreateEnvAlyxEmp(Ent, String:Attachment[], String:Type[12], String:TargetName[255])
{

	//Declare:
	new AlyxEmp = CreateEntityByName("env_alyxemp");

	//Check:
	if(IsValidEdict(AlyxEmp) && IsValidEdict(Ent))
	{

		//Accept:
		DispatchKeyValue(AlyxEmp, "Type", Type);

		DispatchKeyValue(AlyxEmp, "SetTargetEnt", TargetName);

		//Spawn
		DispatchSpawn(AlyxEmp);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(AlyxEmp, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(AlyxEmp, "SetParent", Ent, AlyxEmp, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(AlyxEmp, "SetParentAttachment", AlyxEmp, AlyxEmp, 0);
		}

		//Set String:
		SetVariantString(TargetName);

		//Accept:
		AcceptEntityInput(AlyxEmp, "SetTargetEnt");

		//Accept:
		AcceptEntityInput(AlyxEmp, "startdischarge");

		//Return:
		return AlyxEmp;
	}

	//Return:
	return -1;
}

public CreateEnvLightGlow(Ent, String:Attachment[], String:Color[32], String:VerticalGlowSize[12], String:HorizontalGlowSize[12], String:MinDist[12], String:MaxDist[12], String:OuterMaxDist[12], String:GlowProxySize[12])
{

	//Declare:
	new LightGlow = CreateEntityByName("env_lightglow");

	//Check:
	if(IsValidEdict(LightGlow) && IsValidEdict(Ent))
	{

		//Dispatch:
		DispatchKeyValue(LightGlow, "RenderColor", Color);

		DispatchKeyValue(LightGlow, "VerticalGlowSize", VerticalGlowSize);

		DispatchKeyValue(LightGlow, "HorizontalGlowSize", HorizontalGlowSize);

		DispatchKeyValue(LightGlow, "MinDist", MinDist);

		DispatchKeyValue(LightGlow, "MaxDist", MaxDist);

		DispatchKeyValue(LightGlow, "OuterMaxDist", OuterMaxDist);

		DispatchKeyValue(LightGlow, "GlowProxySize", GlowProxySize);

		//Spawn:
		DispatchSpawn(LightGlow);

		//Declare:
		decl Float:Position[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		//Teleport:
		TeleportEntity(LightGlow, Position, NULL_VECTOR, NULL_VECTOR);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(LightGlow, "SetParent", Ent, LightGlow, 0);

		//Check:
		if(!StrEqual(Attachment, "null"))
		{

			//Attach:
			SetVariantString(Attachment);

			//Accept:
			AcceptEntityInput(LightGlow, "SetParentAttachment", LightGlow, LightGlow, 0);
		}

		//Return:
		return LightGlow;
	}

	//Return:
	return -1;
}

public Action:CreateExplosion(Ent, Ent2)
{

	//Declare:
	decl Float:Origin[3];

	//Get Prop Data:
	GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", Origin);

	//Temp Ent:
	TE_SetupExplosion(Origin, Smoke(), 10.0, 1, 0, 100, 5000);

	//Send:
	TE_SendToAll();

	//Temp Ent:
	TE_SetupExplosion(Origin, Explode(), 5.0, 1, 0, 600, 5000);

	//Send:
	TE_SendToAll();

	//Emit Sound:
	EmitAmbientSound("ambient/explosions/explode_5.wav", Origin, SNDLEVEL_RAIDSIREN);

	//CreateDamage:
	ExplosionDamage(Ent, Ent2, Origin, DMG_SHOCK);
}

public Action:ExplosionDamage(Ent, Ent2, Float:Origin[3], DamageType)
{

	Origin[2] += 5.0;

	//Declare:
	decl Float:AllEntOrigin[3]; new Float:Damage = 0.0;

	//Loop:
	for (new i = 1; i < 2047; i++)
	{

		//Connected:
		if(i > 0 && i <= GetMaxClients() && IsClientConnected(i) && IsClientInGame(i))
		{

			//Initulize:
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

			AllEntOrigin[2] += 15.0;
 
			//Declare:
			new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

			//In Distance:
			if(Dist <= 225 && IsTargetInLineOfSight(Ent2, i))
			{

				//Initulize:
				Damage = GetBlastDamage(Dist);

				//Has Shield Near By:
				if(IsShieldInDistance(i))
				{

					//Shield Forward:
					OnClientShieldDamage(i, Damage);
				}

				//Override:
				else
				{

					//SDKHooks Forward:
					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DamageType);
				}
			}
		}

		if(i > GetMaxClients() && i != Ent2 && IsValidEdict(i))
		{

			//Valid Check:
			if(!IsValidNpc(i) && IsValidDymamicNpc(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DamageType);
				}
			}

			//ValidCheck:
			if(IsValidGenerator(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientGenerator(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidBitCoinMine(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBitCoinMine(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidPrinter(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPrinter(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidBattery(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBattery(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidMeth(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientMeth(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidPropaneTank(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPropaneTank(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidPhosphoruTank(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPhosphoruTank(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidSodiumTub(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSodiumTub(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidHcAcidTub(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientHcAcidTub(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidPlant(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPlant(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidSeeds(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSeeds(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidLamp(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientLamp(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidBong(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBong(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidCocain(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientCocain(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidErythroxylum(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientErythroxylum(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidBenzocaine(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientBenzocaine(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidPills(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientPills(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidToulene(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientToulene(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidSAcidTub(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientSAcidTub(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidAmmonia(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					DamageClientAmmonia(i, Damage, Ent);
				}
			}

			//ValidCheck:
			if(IsValidShield(i))
			{

				//Initulize:
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", AllEntOrigin);

				//Declare:
				new Float:Dist = GetVectorDistance(Origin, AllEntOrigin);

				//In Distance:
				if(Dist <= 250 && IsTargetInLineOfSight(Ent2, i))
				{

					//Initulize:
					Damage = GetBlastDamage(Dist);

					SDKHooks_TakeDamage(i, Ent, Ent2, Damage, DMG_SHOCK);
				}
			}
		}
	}
}

/*
		new ent2 = CreateEntityByName("point_hurt");
		DispatchKeyValue(ent2, "origin", OriginString);
		DispatchKeyValue(ent2, "damageradius", "95");
		DispatchKeyValue(ent2, "damage", "5");
		DispatchKeyValue(ent2, "damagedelay", "0.5");
		DispatchKeyValue(ent2, "damagetype", "8");
		DispatchSpawn(ent2);
		AcceptEntityInput(ent2, "turnon");
		//TeleportEntity(ent2, BombOrigin, NULL_VECTOR, NULL_VECTOR);


void createMolotovEffect(int index, int client, float origin[3])
{

	static int thrown = 0;

	int particles = CreateEntityByName("info_particle_system");

	if(particles != -1)
{
		DispatchKeyValue(particles, "effect_name", "env_fire_small_coverage_smoke");

		

		int gibs = GetArrayCell(gunThrowMoloGibs, index);

		float life = GetArrayCell(gunThrowMoloGibsLife, index);

		float burnout = GetArrayCell(gunThrowMoloGibsBurnout, index);

		float velocity = GetArrayCell(gunThrowMoloGibsVelocity, index);

		float variation = GetArrayCell(gunThrowMoloGibsMaxVariation, index);

		

		for (new i = 0; i < gibs; i++)
		{

			int gib = CreateEntityByName("prop_physics");

			if(gib != -1)
`			{

				char glass[64], name[32], cpoint[9];

				Format(name, sizeof(name), "customguns_throw_molo_gib%d", ++thrown);

				Format(glass, sizeof(glass), "models/props_junk/garbage_glassbottle003a_chunk0%d.mdl", GetRandomInt(1, 3));

				Format(cpoint, sizeof(cpoint), "cpoint%d", i+1);

				DispatchKeyValue(particles, cpoint, name);


				float direction[3];

				direction[0] = ((GetURandomFloat()-0.5)* 2 * velocity) * (GetURandomFloat() * variation);

				direction[1] = ((GetURandomFloat()-0.5)* 2 * velocity) * (GetURandomFloat() * variation);

				direction[2] = ((GetURandomFloat()-0.5)* 2 * velocity) * (GetURandomFloat() * variation);

 				

				float angVel[3];

				angVel[0] = GetRandomFloat( -100.0, -600.0 );

				angVel[1] = GetRandomFloat( -100.0, -600.0 );

				angVel[2] = GetRandomFloat( -100.0, -600.0 );

				

				DispatchKeyValue(gib, "targetname", name);

 				DispatchKeyValue(gib, "model", glass);


				DispatchSpawn(gib);

				disablePickup(gib);

				

				// Make this non solid to player but still trigger touch

				

				SetEntPropEnt(gib, Prop_Data, "m_hOwnerEntity", client);

				SetEntProp(gib, Prop_Send, "m_usSolidFlags", FSOLID_TRIGGER);

				SetEntProp(gib, Prop_Data, "m_CollisionGroup", COLLISION_GROUP_DEBRIS_TRIGGER);

				

				// Give it better radius for burning things

				

				SetEntProp(gib, Prop_Send, "m_nSolidType", SOLID_BBOX, 1);

				SetMinMaxSize(gib, Float:{-50.0, -50.0, -50.0}, Float:{50.0, 50.0, 50.0});

				

				TeleportEntity(gib, origin, NULL_VECTOR, direction);

				SetEntPropVector(gib, Prop_Data, "m_vecAbsVelocity", Float:0.0,0.0,0.0});

				SetEntPropVector(gib, Prop_Data, "m_vecAngVelocity", angVel);

				SDKHook(gib, SDKHook_TouchPost, BurnTouch);


				CreateTimer(life, makeDisappear, EntIndexToEntRef(gib), TIMER_FLAG_NO_MAPCHANGE);

				CreateTimer(burnout+1.0, stopBurnTouch, EntIndexToEntRef(gib), TIMER_FLAG_NO_MAPCHANGE);

			}

		}


		DispatchSpawn(particles);

		ActivateEntity(particles);

		TeleportEntity(particles, origin, NULL_VECTOR, NULL_VECTOR);

		

		int entref = EntIndexToEntRef(particles);

		CreateTimer(0.2, startFire, entref, TIMER_FLAG_NO_MAPCHANGE);

		CreateTimer(burnout+0.2, stopBurningSound, entref, TIMER_FLAG_NO_MAPCHANGE);

		CreateTimer(burnout+0.2, delayedKill, entref, TIMER_FLAG_NO_MAPCHANGE);

	}
}
*/