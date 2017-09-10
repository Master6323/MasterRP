//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_spawnprotect_included_
  #endinput
#endif
#define _rp_spawnprotect_included_

//Is Spawnable:
static bool:ShouldCollide[MAXPLAYERS + 1] = {false,...};
static Handle:ShowProtect[MAXPLAYERS + 1] = {INVALID_HANDLE,...};
static bool:HasGodMode[MAXPLAYERS + 1] = {false,...};
static bool:HasSpawnProtect[MAXPLAYERS + 1] = {false,...};
static Float:ProtectionTimer[MAXPLAYERS + 1] = {0.0,...};

//On Client Collide:
public Action:OnClientShouldCollide(Ent, OtherEnt, &bool:result)
{

	//PlayerCheck:
	if(ShouldCollide[Ent])
	{

		//Initulize:
		result = false;

		//Return:
		return Plugin_Changed;
	}

	//Return:
	return Plugin_Continue;
}

public StartSpawnProtect(Client)
{

	//Has Crime:
	if(!IsCuffed(Client) && GetSpawnProtectTime() != 0)
	{

		//Initulize:
		ProtectionTimer[Client] = float(GetSpawnProtectTime());

		//Handle:
		ShowProtect[Client] = CreateTimer(0.1, ProtectTimer, Client, TIMER_REPEAT);

		//Protect:
		SpawnProtect(Client, 1);
	}
}

public RemoveProtectTimer(Client)
{

	//Is Valid:
	if(ShowProtect[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(ShowProtect[Client]);

		//Handle:
		ShowProtect[Client] = INVALID_HANDLE;
	}

	//Alive:
	if(IsPlayerAlive(Client))
	{

		//Protect:
		SpawnProtect(Client, 0);
	}
}

public Action:ProtectTimer(Handle:timer, any:Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Is Valid:
		if(ProtectionTimer[Client] > 0.0)
		{

			//Initulize:
			ProtectionTimer[Client] -= 0.1;

			if(ProtectionTimer[Client] > 0.1)
			{

				//Print:
				PrintCenterText(Client, "%s: %.1f", "Spawn Protection", ProtectionTimer[Client] / 2.0);
			}

			//Override:
			else
			{

				//Print:
				PrintCenterText(Client, "%s: 0.0", "Spawn Protection");
			}
		}

		//Override:
		else
		{

			//Protect:
			SpawnProtect(Client, 0);
		}

		//Return:
		return Plugin_Continue;
	}

	//Is Valid:
	if(ShowProtect[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(ShowProtect[Client]);

		//Handle:
		ShowProtect[Client] = INVALID_HANDLE;
	}

	//Return:
	return Plugin_Handled;
}

//Set Protection:
stock SpawnProtect(Client, X)
{

	//Override:
	if(X == 0)
	{

		//Protection:
		HasSpawnProtect[Client] = false; HasGodMode[Client] = false; ShouldCollide[Client] = false;

		// CAN NOT PASS THRU ie: Players can jump on each other
		SetEntData(Client, GetCollisionOffset(), 5, 4, true);

		//Set Colour:
		SetEntityRenderColor(Client);

		//Set Render:
		SetEntityRenderMode(Client, RENDER_NORMAL);

		//Set Render Ex:
		SetEntityRenderFx(Client, RENDERFX_NONE);

		//Kill Timer:
		if(ShowProtect[Client] != INVALID_HANDLE)
		{

			//Kill:
			KillTimer(ShowProtect[Client]);
		}

		//Handle:
		ShowProtect[Client] = INVALID_HANDLE;
	}

	//Protect:
	else if(X == 1)
	{

		//Protection:
		HasSpawnProtect[Client] = true; HasGodMode[Client] = true; ShouldCollide[Client] = true;

		// Noblock active ie: Players can walk thru each other
		SetEntData(Client, GetCollisionOffset(), 2, 4, true);

		//Is Combine:
		if(IsCop(Client)) SetEntityRenderColor(Client, 50, 50 ,255 , 128);

		//Is Admin:
		else if(IsAdmin(Client)) SetEntityRenderColor(Client, 255, 255 ,50 , 128);

		//Is Player:
		else SetEntityRenderColor(Client, 255, 50 ,50 , 128);

		//Set Render:
		SetEntityRenderMode(Client, RENDER_TRANSCOLOR);

		//Set Render Ex:
		SetEntityRenderFx(Client, RENDERFX_DISTORT);
	}
}

public GetGodMode(Client)
{

	//Return:
	return HasGodMode[Client];
}

public IsProtected(Client)
{

	//Return:
	return HasSpawnProtect[Client];
}
