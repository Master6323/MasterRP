//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_talkzone_included_
  #endinput
#endif
#define _rp_talkzone_included_

//Phones:
static Connected[MAXPLAYERS + 1] = {0,...};
static bool:Answered[MAXPLAYERS + 1] = {false,...};
static TimeOut[MAXPLAYERS + 1] = {0,...};

public Action:PluginInfo_TalkZone(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Roleplay Chat System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.31.72");
}

public initdisconnectphone(Client)
{
	//Connected:
	if(Connected[Client] != 0)
	{

		//Initialize:
		new Player = Connected[Client];

		if(IsClientConnected(Player) && IsClientInGame(Player))
		{

			//Print:
			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - You have lost service, phone conversation aborted");
		}

		//Send:
		Connected[Client] = 0;

		Answered[Client] = false;

		Connected[Player] = 0;

		Answered[Player] = false;
	}
}

//Event Death:
public Action:OnClientChat(Client, Bool:IsTeamOnly, const String:Text[], maxlength)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Check:
		if(CheckStringSound(Client, Text))
		{

			//Return:
			return Plugin_Handled;
		}

		//Declare:
		decl String:Color[32] = "{yellow}";

		//Valid Check:
		if(IsCop(Client))
		{

			//Format:
			Format(Color, sizeof(Color), "{blue}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Root Admin", false) != -1)
		{

			//Format Dark Green:
			Format(Color, sizeof(Color), "{darkseagreen}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Brain Surgeon", false) != -1)
		{

			//Format Medium Blue:
			Format(Color, sizeof(Color), "{lightblue}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Mafia", false) != -1 || StrContains(GetJob(Client), "Bounty Hunter", false) != -1 || StrContains(GetJob(Client), "Mafia Boss", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1 || StrContains(GetJob(Client), "Dubble Agent", false) != -1)
		{

			//Format gray:
			Format(Color, sizeof(Color), "{orange}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Gun Lord", false) != -1 || StrContains(GetJob(Client), "Explosive Expert", false) != -1)
		{

			//Format light green:
			Format(Color, sizeof(Color), "\x0732CD32");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Crack Baby", false) != -1 || StrContains(GetJob(Client), "Drug", false) != -1)
		{

			//Format red:
			Format(Color, sizeof(Color), "\x07FF4040");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Master Chef", false) != -1)
		{

			//Format Light Blue:
			Format(Color, sizeof(Color), "{lightpink}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Street Sweeper", false) != -1)
		{

			//Format Medium Green:
			Format(Color, sizeof(Color), "{gold}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Official", false) != -1 || StrContains(GetJob(Client), "Mayor", false) != -1)
		{

			//Format medium Dark Green:
			Format(Color, sizeof(Color), "{royalblue}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "bank", false) != -1)
		{

			//Format Blue:
			Format(Color, sizeof(Color), "{whitesmoke}");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "God Father", false) != -1)
		{

			//Format yellow:
			Format(Color, sizeof(Color), "\x07FFFFFF");
		}

		//Valid Check:
		if(StrContains(GetJob(Client), "Trader", false) != -1)
		{

			//Format Blue:
			Format(Color, sizeof(Color), "{lightcyan}");
		}

		//Valid Check:
		if(StrContains(Color, "null", false) != -1)
		{

			//Format:
			Format(Color, sizeof(Color), "\x07FF4040");
		}

		//Replace:
		CReplaceColorCodes(Color);

		//Declare:
		decl String:FormatMessage[1024];

		//Declare:
		new len = 0;

		//Team Only:
		if(IsTeamOnly)
		{

			//Connected:
			if(Connected[Client] != 0)
			{

				//On Phone:
				if(Answered[Client])
				{

					//Print:
					PrintSilentChat(Client, Connected[Client], "PHONE", Text, Color);

					//Return:
					return Plugin_Handled;
				}
			}

			//Override:
			else
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\x0720B2AA(TEAM)");

				//Is Alive:
				if(!IsPlayerAlive(Client))
				{

					//Format:
					len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " \x0732CD32*DEAD*");
				}

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " %s%N\x01: %s", Color, Client, Text);

				//Loop:
				for(new i = 1; i <= GetMaxClients(); i++)
				{

					//Connected:
					if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(Client) == GetClientTeam(i))
					{

						//Print:
						CPrintToChat(i, "%s", FormatMessage);
					}

					//Return:
					return Plugin_Handled;
				}
			}
		}

		//Override
		else
		{

			//Is Donator:
			if(GetDonator(Client) != 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\x079370D8(VIP)");
			}

			//Override
			else
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "\x0720B2AA(OOC)");
			}

			//Is Alive:
			if(!IsPlayerAlive(Client))
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " \x0732CD32*DEAD*");
			}

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, " %s%N\x01: %s", Color, Client, Text);

			//Print:
			CPrintToChatAll("%s", FormatMessage);
		}
	}

	//Is Console:
	if(Client == 0)
	{

		//Print:
		CPrintToChatAll("\x0720B2AA(SERVER) \x079EC34FConsole\x07FFFFFF: %s", Text);

		//Return:
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

//Event Death:
public Action:OnCliedDiedHangUp(Client)
{

	//Hangup:
	if(Connected[Client] != 0) HangUp(Client);
}

public Action:SetTalkZoneDefStats(Client)
{

	//Initialize:
	Connected[Client] = 0;

	Answered[Client] = false;

	TimeOut[Client] = 0;
}

//Calling:
stock Call(Client, Player)
{

	//World:
	if(Client != 0 && Player != 0)
	{

		//Bot Enabled:
		if(GetCallEnable(Player))
		{

			//Not Connected:
			if(Connected[Player] == 0)
			{

				//Has Enough Cash:
				if(GetBank(Client) > 25)
				{

					//Has Enough Cash:
					if(GetBank(Player) > 25)
					{

						//Initialize:
						Connected[Client] = Player;

						Connected[Player] = Client;

						//Send:
						RecieveCall(Player, Client);

						//Initialize:
						TimeOut[Client] = 40;

						//Timer:
						CreateTimer(1.0, TimeOutCall, Client);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF does not have enough money to answer the call!", Player);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have enough money to call \x0732CD32%N\x07FFFFFF!", Player);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is already on the phone", Player);
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has disabled the Phone", Player);
		}
	}
}

//Recieve:
stock RecieveCall(Client, Player)
{

	//Is Enabled:
	if(GetRingEnable(Client))
	{

		//Sound:
		EmitSoundToClient(Client, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);
	}

	//Is Enabled:
	if(GetRingEnable(Player))
	{

		//Sound:
		EmitSoundToClient(Player, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);
	}

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF is calling you, type !answer to talk to hum.", Player);

	//Send:
	TimeOut[Client] = 40;

	//Timer:
	CreateTimer(1.0, TimeOutRecieve, Client);
}

//Answer:
stock Answer(Client)
{

	//Connected:
	if(!Answered[Client] && Connected[Client] != 0)
	{

		//Initialize:
		new Player = Connected[Client];

		//Has Enough Cash:
		if(GetBank(Client) > 25)
		{

			//Initulize:
			SetBank(Client, (GetBank(Client) - 25));

			SetBank(Player, (GetBank(Client) - 25));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have answered your call from \x0732CD32%N\x07FFFFFF!", Player);

			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has answered their phone!", Client);

			//Send:
			Answered[Client] = true;

			Answered[Player] = true;

			//Is Enabled:
			if(GetRingEnable(Client))
			{

				//Sound:
				StopSound(Client, 5, "roleplay/ring.wav");
			}

			//Is Enabled:
			if(GetRingEnable(Player))
			{

				//Sound:
				StopSound(Player, 5, "roleplay/ring.wav");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You do not have enough money to answer the phone to \x0732CD32%N\x07FFFFFF!", Player);

			CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF does not have enough money to answer the phone!", Client);

			//Send:
			Connected[Client] = 0;

			Answered[Client] = false;

			Connected[Player] = 0;

			Answered[Player] = false;
		}
	}

	//Overrride:
	else if(Answered[Client])
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You already answered the phone");
	}

	//Override:
	else
	{
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - No one is calling you!");
	}
}

//Hang Up:
stock HangUp(Client)
{

	//Connected:
	if(Connected[Client] != 0)
	{

		//Declare:
		new Player = Connected[Client];

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You hang up on \x0732CD32%N\x07FFFFFF!", Player);
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF hung up on you!", Client);

		//Send:
		Connected[Client] = 0;

		Answered[Client] = false;

		Connected[Player] = 0;

		Answered[Player] = false;

		//Sound:
		StopSound(Client, 5, "roleplay/ring.wav");

		//Sound:
		StopSound(Player, 5, "roleplay/ring.wav");
	}

	//Override
	else
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not on the phone");
	}
}

//Time Out (Calling):
public Action:TimeOutCall(Handle:Timer, any:Client)
{

	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Initialize:
		new Player = Connected[Client];

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF failed to answer their phone!", Player);

		//End Connection:
		Answered[Client] = false;

		Connected[Client] = 0;	
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutCall, Client);
	}
}

//Time Out (Recieve):
public Action:TimeOutRecieve(Handle:Timer, any:Client)
{

	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your phone has stopped ringing!");

		//Is Enabled:
		if(GetRingEnable(Client))
		{

			//Sound:
			StopSound(Client, 5, "roleplay/ring.wav");
		}

		//End Connection:
		Answered[Client] = false;

		Connected[Client] = 0;
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutRecieve, Client);
	}
}

//Silent:
stock PrintSilentChat(Client, Player, String:Message[32], const String:Text[], const String:Color[])
{

	//Print:
	CPrintToChat(Player, "{lightseagreen}(%s) %s%N : \x07FFFFFF%s", Message, Color, Client, Text);

	CPrintToChat(Client, "{lightseagreen}(%s) %s%N : \x07FFFFFF%s", Message, Color, Client, Text);
}

public Action:Command_Answer(Client, args)
{

	//Anwer Call:
	Answer(Client);

	//Return:
	return Plugin_Handled;
}

public Action:Command_Hangup(Client, args)
{

	//Hang up Call:
	HangUp(Client);

	//Return:
	return Plugin_Handled;
}

public Action:Command_Call(Client, args)
{

	//Is Valid:
	if(args < 1)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_call <Name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));
	
	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Could not find client \x0732CD32%s", arg1);

		//Return:
		return Plugin_Handled;
	}

	//Yourself:
	if(Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You cannot call yourself");

		//Return:
		return Plugin_Handled;
	}

	//Dead:
	if(!IsPlayerAlive(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Cannot call a dead player");

		//Return:
		return Plugin_Handled;
	}

	//Call:
	Call(Client, Player);
	
	//Return:
	return Plugin_Handled; 
}

public Action:Command_Sms(Client, args)
{

	//Is Valid:
	if(args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_sms <name> <message>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:arg1[32];

	//Initialize:
	GetCmdArg(1, arg1, sizeof(arg1));

	//Deckare:
	new Player = FindTarget(Client, arg1);

	//Valid Player:
	if (Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Could not find client \x0732CD32%s", arg1);

		//Return:
		return Plugin_Handled;
	}

	//Yourself:
	if(Player == Client)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You cannot sms yourself!");

		//Return:
		return Plugin_Handled;
	}

	//Dead:
	if(!IsPlayerAlive(Player))
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF Cannot sms a dead player!");

		//Return:
		return Plugin_Handled;
	}

	//Enough Money:
	if(GetBank(Client) < 5)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You dont have enough money to SMS, Cost 5!");

		//Return:
		return Plugin_Handled;
	}

	//Initialize:
	SetBank(Client, (GetBank(Client) - 5));

	//Declare:
	decl String:Text[255];

	//Get Args
	GetCmdArgString(Text, sizeof(Text));

	//Strip All Quoats:
	StripQuotes(Text);

	//Trip String:
	TrimString(Text);

	//Print:
	PrintSilentChat(Client, Player, "SMS", Text, "\x0732CD32");

	//Return:
	return Plugin_Handled; 
}
