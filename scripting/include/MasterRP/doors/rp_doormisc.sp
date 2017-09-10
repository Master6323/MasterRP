//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_doormisc_included_
  #endinput
#endif
#define _rp_doormisc_included_

static pressedE[MAXPLAYERS + 1] = {0,...};
static BlockE[MAXPLAYERS + 1] = {0,...};
static UnBlockE[MAXPLAYERS + 1] = {0,...};

public Action:OnClientCheckDoorSpam(Client, Ent)
{

	//Has Client Toggled door:
	if(Client > 0 && Client <= GetMaxClients() && IsInDistance(Client, Ent))
	{

		//Last Pressed:
		if(GetLastPressedE(Client) > (GetGameTime() - 3.0))
		{

			//Initialize:
        	        pressedE[Client]++;
		}

		//Override
		else
		{

			//Initialize:
			pressedE[Client] = 0;
		}

		//Initialize:
		SetLastPressedE(Client, GetGameTime());

		//Last Warning:
		if(pressedE[Client] == 10)
		{

			//Initialize:
			BlockE[Client] = 1;

			//Print
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040WARNING\x07FFFFFF| - You can't use anything for the next 10sec!");
		}

		//Door Blocking Warnings:
		else if(pressedE[Client] == 5)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF |\x07FF4040WARNING\x07FFFFFF| - Stop blocking the door!.");
		}
	}
}

public Action:UnLockUse(Handle:Timer, any:Client)
{

	//Connected:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Initialize:
		BlockE[Client] = 0;

		pressedE[Client] = 0;

		SetLastPressedE(Client, 0.0);	

		UnBlockE[Client] = 0;
	}

	//Return:
	return Plugin_Handled;	
}

public Action:OnClientKnockPropDoor(Ent)
{

	//Declare:
	new Float:Origin[3]; decl String:Sound[128]; new Random = GetRandomInt(2,3);

	//Format:
	Format(Sound, sizeof(Sound), "physics/wood/wood_crate_impact_hard%i.wav", Random);

	//Initulize:
	GetEntPropVector(Ent, Prop_Data, "m_vecVelocity", Origin);

	//Play Sound:
	EmitAmbientSound(Sound, Origin, Ent, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN);
}


public GetPressedE(Client)
{

	//Return:
	return pressedE[Client];
}

public SetPressedE(Client, Result)
{

	//Initulize:
	pressedE[Client] = Result;
}

public GetBlockE(Client)
{

	//Return:
	return BlockE[Client];
}

public SetBlockE(Client, Result)
{

	//Initulize:
	BlockE[Client] = Result;
}

public GetUnBlockE(Client)
{

	//Return:
	return UnBlockE[Client];
}

public SetUnBlockE(Client, Result)
{

	//Initulize:
	UnBlockE[Client] = Result;
}

