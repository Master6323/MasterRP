//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_crime_included_
  #endinput
#endif
#define _rp_crime_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

#define BOUNTYCRIME 		20
#define BOUNTYSTART 		20000

//Crime system:
static Crime[MAXPLAYERS + 1] = {0,...};
static Bounty[MAXPLAYERS + 1] = {0,...};
static bool:AutoBounty[MAXPLAYERS + 1] = {false,...};

public Action:PluginInfo_Crime(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Crime System!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initCrime()
{

	//Player Stats Manangement:
	RegAdminCmd("sm_crime", CommandCrime, ADMFLAG_SLAY, "<Name> <Crime #> - Sets crime");
}

public Action:initCrimeTimer(Client)
{

	//Enough Crime:
	if(Crime[Client] > BOUNTYSTART && !IsCop(Client))
	{

		//Declare:
		new CrimeToBounty = (Crime[Client] / BOUNTYCRIME);

		//Bounty:
		if(Bounty[Client] < CrimeToBounty)
		{

			//Add Bounty:
			AddBounty(Client, CrimeToBounty);

			//Initialize:
			AutoBounty[Client] = true;
		}
	}

	//Enough Crime For Bounty:
	else if(Crime[Client] <= BOUNTYSTART && AutoBounty[Client])
	{

		//Add Bounty:
 		AddBounty(Client, 0);
	}

	//Has Crime:
	if(Crime[Client] > 0)
	{

		//Initialize:
		Crime[Client] -= GetRandomInt(1, 4);
	}
}

public Action:AddBounty(Client, SetBounty)
{

	//Setup Hud:
	SetHudTextParams(-1.0, 0.015, 5.0, 250, 250, 250, 200, 0, 6.0, 0.1, 0.2);

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(IsClientConnected(i) && IsClientInGame(i) && i != Client)
		{

			//Enouth Bounty: 
			if(SetBounty != 0)
			{

				//Show Hud Text:
				ShowHudText(i, 4, "%N now has a bounty of €%i on his head", Client, SetBounty);
			}
		}
	}

	//Override:
	if(SetBounty != 0)
	{

		//Show Hud Text:
		ShowHudText(Client, 4, "A bounty of €%i is set on your head! If you die you'll go to jail!", SetBounty);
	}

	//Initialize:
	Bounty[Client] = SetBounty;
}

public Action:OnClientDiedCheckBounty(Client, Attacker)
{

	//Is Actual Player:
	if(Attacker != Client && Attacker != 0 && Attacker > 0 && Attacker < GetMaxClients())
	{

		//Has Bounty:
		if(GetBounty(Client) > 0)
		{    

			//Setup Hud:
			SetHudTextParams(-1.0, 0.015, 5.0, 250, 250, 250, 200, 0, 6.0, 0.1, 0.2);

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{ 

					//Show Hud Text:
					ShowHudText(i, 4, "%N Bounty Has Been Caught!!!", Client);
				}
			}

			//Declare:
			new AddCash = 0;

			//Is Cop:
			if(IsCop(Attacker))
			{

				//Initialize:
	            		AddCash = GetBounty(Client) / 3;
			}

			//Override:
			else
			{

				//Initialize:
	            		AddCash = GetBounty(Client);
			}

			//Cuff Client:
			Cuff(Client);

			//Get Jail Time:
			CalculateJail(Client);

			//Set Menu State:
			CashState(Attacker, AddCash);

			//Initialize:
            		SetCash(Attacker, (GetCash(Client) + AddCash));

			SetCrime(Client, 0);

			SetBounty(Client, 0);

			//Initialize:
			AutoBounty[Client] = false;
		}
	}
}

//Crime:
public Action:CommandCrime(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_crime <Name> <Crime #>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32], String:ClientName[32],String:Name[32],String:Amount[32];
	new iAmount, Player;

	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	GetCmdArg(2, Amount, sizeof(Amount));

	//Initialize:
	iAmount = StringToInt(Amount);
	
	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientConnected(i)) continue;

		//Initialize:
		GetClientName(i, Name, sizeof(Name));

		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = i;
	}
	
	//Invalid Name:
	if(Player == -1)
	{

		//Print:
		PrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client \x0732CD32%s", PlayerName);

		//Return:
		return Plugin_Handled;
	}

	//Action:
	SetCrime(Player, iAmount);

	//Is Valid:
	if(Crime[Client] > 500) SetClientScore(Client, RoundToNearest(Crime[Client] / 1000.0));

	//Initialize:
	GetClientName(Player, Name, sizeof(Name));

	GetClientName(Client, ClientName, sizeof(ClientName));

	//Print:
	CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set \x0732CD32%s\x07FFFFFF's crime to \x0732CD32%s", Name, Amount);

	//Not Client:
	if(Client != Player)
	{

		//Print:
		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF set your crime to \x0732CD32%s", ClientName, Amount);
	}

#if defined DEBUG
	//Logging:
	LogMessage("\"%L\" set the crime of \"%L\" to %i", Client, Player, iAmount);
#endif
	//Return:
	return Plugin_Handled;
}

stock GetCrime(Client)
{

	//Return:
	return Crime[Client];
}

stock SetCrime(Client, Amount)
{

	//Initulize:
	Crime[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Crime = %i WHERE STEAMID = %i;", Crime[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

stock GetBounty(Client)
{

	//Return:
	return Bounty[Client];
}

stock SetBounty(Client, Amount)
{

	//Initulize:
	Bounty[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Bounty = %i WHERE STEAMID = %i;", Bounty[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}