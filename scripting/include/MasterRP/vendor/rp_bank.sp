//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_bank_included_
  #endinput
#endif
#define _rp_bank_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//€ = �

//Hud Handles
static Handle:CashTimer[MAXPLAYERS + 1] = {INVALID_HANDLE,...};
static Handle:BankTimer[MAXPLAYERS + 1] = {INVALID_HANDLE,...};

//Money System:
static Bank[MAXPLAYERS + 1] = {0,...};
static Cash[MAXPLAYERS + 1] = {0,...};

//Menu System:
static TargetMenu[MAXPLAYERS + 1] = {0,...};

//Menu Effect:
static String:AddedBank[MAXPLAYERS + 1][32];
static String:AddedCash[MAXPLAYERS + 1][32];

public Action:PluginInfo_Bank(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "SQL Banking Sytem");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initBank()
{

	//Commands
	RegAdminCmd("sm_setbank", Command_setBank, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Bank of the Client");

	RegAdminCmd("sm_setcash", Command_setCash, ADMFLAG_ROOT, "- <Name> <Amount> - Sets the Cash of the Client");

	//Precache:
	PrecacheSound("roleplay/cashregister.wav");
}

public Action:DrawBankMenu(Client, Ent)
{

	//Is In Time:
	if((GetLastPressedE(Client) > (GetGameTime() - 1.5)) && Cash[Client] > 0)
	{

		//Declare:
		new Amount = Cash[Client];

		//Initialize:
		SetBank(Client, (Bank[Client] + Amount));

		SetCash(Client, 0);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have deposited \x0732CD32%s\x07FFFFFF on the bank!", IntToMoney(Amount));

		//Set Menu State:
		BankState(Client, Amount);

		//Play Sound:
		EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

		//Initulize:
		SetLastPressedE(Client, 0.0);
	}

	//Override:
	if(Cash[Client] != 0)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'use'\x07FFFFFF to quick deposit %s!", IntToMoney(Cash[Client]));

		//Initulize:
		SetLastPressedE(Client, GetGameTime());
	}

	else
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
	}

	//Handle:
	new Handle:Menu = CreateMenu(HandleBank);

	//Declare:
	new Salary;

	//Is Cop:
	if(IsCop(Client) || IsAdmin(Client))
	{

		//Initulize::
		Salary = ((GetJobSalary(Client) * 2));
	}

	//Override:
	else
	{

		//Initulize::
		Salary = ((GetJobSalary(Client) * 2));
	}

	//Declare:
	decl String:title[512]; Format(title, sizeof(title), "Select an option:\n\nBank: €%i\nCash: €%i\nJobSalary: €%i\n\n This menu allows you to manage all\n your money as well as store money\n in your bank account:", Bank[Client], Cash[Client], Salary);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "1", "Withdraw Cash");

	//Menu Button:
	AddMenuItem(Menu, "2", "Deposit Cash");

	//Menu Button:
	AddMenuItem(Menu, "3", "Transfer To Player");

	//Menu Button:
	AddMenuItem(Menu, "4", "Top Players");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Initulize:
	TargetMenu[Client] = Ent;
}

//BankMenu Handle:
public HandleBank(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			DrawWithdrawMenu(Client);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			DrawDepositMenu(Client);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Show Menu:
			DrawTransactMenu(Client);
		}

		//Button Selected:
		if(Result == 4)
		{

			//Show Menu:
			DrawTopMenu(Client);
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

public Action:DrawWithdrawMenu(Client)
{

	//Declare:
	decl String:display[32], String:info[32];

	//Convert:
	IntToString(Bank[Client], info, sizeof(info));

	//Handle:
	new Handle:Menu = CreateMenu(Withdrawl);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Select an amount to withdraw:\n\nThis menu allows you to select\n an amount to withdrawl from\n the bank:\n\nYou have €%i to withdraw", Bank[Client]);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Bank[Client]);

	//Menu Button:
	AddMenuItem(Menu, info, display);

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

	//Menu Button:
	AddMenuItem(Menu, "2", "2");

	//Menu Button:
	AddMenuItem(Menu, "5", "5");

	//Menu Button:
	AddMenuItem(Menu, "10", "10");

	//Menu Button:
	AddMenuItem(Menu, "25", "25");

	//Menu Button:
	AddMenuItem(Menu, "50", "50");

	//Menu Button:
	AddMenuItem(Menu, "100", "100");

	//Menu Button:
	AddMenuItem(Menu, "250", "250");

	//Menu Button:
	AddMenuItem(Menu, "500", "500");

	//Menu Button:
	AddMenuItem(Menu, "1000", "1000");

	//Menu Button:
	AddMenuItem(Menu, "2500", "2500");

	//Menu Button:
	AddMenuItem(Menu, "5000", "5000");

	//Menu Button:
	AddMenuItem(Menu, "10000", "10000");

	//Menu Button:
	AddMenuItem(Menu, "100000", "100000");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public Action:DrawDepositMenu(Client)
{

	//Declare:
	decl String:display[32], String:info[32];

	//Convert:
	IntToString(Cash[Client], info, sizeof(info));

	//Handle:
	new Handle:Menu = CreateMenu(Deposits);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Select an amount to Deposit:\n\nThis menu allows you to select\n an amount to deposit into\n the bank:\n\nYou have €%i to deposit", Cash[Client]);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Cash[Client]);

	//Menu Button:
	AddMenuItem(Menu, info, display);

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

	//Menu Button:
	AddMenuItem(Menu, "2", "2");

	//Menu Button:
	AddMenuItem(Menu, "5", "5");

	//Menu Button:
	AddMenuItem(Menu, "10", "10");

	//Menu Button:
	AddMenuItem(Menu, "25", "25");

	//Menu Button:
	AddMenuItem(Menu, "50", "50");

	//Menu Button:
	AddMenuItem(Menu, "100", "100");

	//Menu Button:
	AddMenuItem(Menu, "250", "250");

	//Menu Button:
	AddMenuItem(Menu, "500", "500");

	//Menu Button:
	AddMenuItem(Menu, "1000", "1000");

	//Menu Button:
	AddMenuItem(Menu, "2500", "2500");

	//Menu Button:
	AddMenuItem(Menu, "5000", "5000");

	//Menu Button:
	AddMenuItem(Menu, "10000", "10000");

	//Menu Button:
	AddMenuItem(Menu, "100000", "100000");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public Action:DrawTransactMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleTransfer);

	//Menu Title:
	SetMenuTitle(Menu, "Transfer cash?\n\n Remember when transfering\n Cash through the bank\n has a 10 percent\n Intrest rate:");

	//Declare:
	decl String:name[65], String:ID[25];

	//Loop:
	for (new i = 1; i <= GetMaxClients(); i++)
	{

		//Connected:
		if(!IsClientInGame(i))
		{

			//Initialize:
			continue;
		}

		//Initialize:
		GetClientName(i, name, sizeof(name));

		//Convert:
		IntToString(i, ID, sizeof(ID));

		//Menu Button:
		AddMenuItem(Menu, ID, name);
	}

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);
}

public Action:DrawTransactCashMenu(Client)
{

	//Declare:
	decl String:AllBank[32],String:bAllBank[32];

	//Format:
	Format(AllBank, 32, "All (€%i)", Bank[Client]);

	Format(bAllBank, 32, "%i", Bank[Client]);

	//Handle:
	new Handle:Menu = CreateMenu(HandleTransferDeposit);

	//Title:
	SetMenuTitle(Menu, "How Much To Transfer:\nTransfer Rate: €10/€9");

	//Menu Buttons:
	AddMenuItem(Menu, bAllBank, AllBank);

	AddMenuItem(Menu, "1", "1");

	AddMenuItem(Menu, "5", "5");

	AddMenuItem(Menu, "10", "10");

	AddMenuItem(Menu, "20", "20");

	AddMenuItem(Menu, "50", "50");

	AddMenuItem(Menu, "100", "100");

	AddMenuItem(Menu, "200", "200");

	AddMenuItem(Menu, "500", "500");

	AddMenuItem(Menu, "1000", "1000");

	AddMenuItem(Menu, "5000", "5000");

	AddMenuItem(Menu, "10000", "10000");

	AddMenuItem(Menu, "50000", "50000");

	AddMenuItem(Menu, "100000", "100000");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);
}
public Action:DrawTopMenu(Client)
{
	//Handle:
	new Handle:Menu = CreateMenu(HandleTopMenu);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "This menu allows you to see\nthe top stats/rank for all players!");

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "1", "Richest Player");

	//Menu Button:
	AddMenuItem(Menu, "2", "Most Wanted");

	//Menu Button:
	AddMenuItem(Menu, "3", "Most Online");

	//Menu Button:
	AddMenuItem(Menu, "4", "Highest Wages");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

public Deposits(Handle:Menu, MenuAction:HandleAction, Client, Parameter) 
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, TargetMenu[Client]))
		{

			//Declare:
			decl String:info[32];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Amount = StringToInt(info);

			//Can Transact:
			if(!(GetCash(Client) - Amount < 0 || GetBank(Client) + Amount < 0) && GetCash(Client) != 0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) - Amount));

				SetBank(Client, (GetBank(Client) + Amount));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have deposited \x0732CD32€%i\x07FFFFFF on the bank!", Amount);

				//Set Menu State:
				CashState(Client, Amount);

				BankState(Client, Amount);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);

				//Show Menu:
				DrawDepositMenu(Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much Cash with you!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC/Player anymore, because you too far away");
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}
public Withdrawl(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, TargetMenu[Client]))
		{

			//Declare:
			decl String:info[32];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:				
			new Amount = StringToInt(info);

			//Can Transact:
			if(!(Cash[Client] + Amount < 0 || Bank[Client] - Amount < 0) && Bank[Client] !=0)
			{

				//Initialize:
				SetCash(Client, (GetCash(Client) + Amount));

				SetBank(Client, (GetBank(Client) - Amount));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You have withdrawn \x0732CD32€%i\x07FFFFFF from the bank!", Amount);

				//Set Menu State:
				CashState(Client, Amount);

				BankState(Client, Amount);

				//Show Menu:
				DrawWithdrawMenu(Client);

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much cash on your bank.");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC anymore, because you too far away!");
		}			
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

public HandleTransfer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Declare:
		new Player = StringToInt(info);

		//Is Actual Player:
		if(Player > 0 && Client != Player && IsClientConnected(Player) && IsClientInGame(Player))
		{

			//Initialize:
			TargetMenu[Client] = Player;

			//Show Menu:
			DrawTransactCashMenu(Client);
		}

		//Override:
		else
		{
			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - This Player is unavailable or disconnected");
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

public HandleTransferDeposit(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//In Distance:
		if(IsInDistance(Client, TargetMenu[Client]))
		{

			//Declare:
			decl String:info[32];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Declare:
			new Amount = StringToInt(info);

			new Ent = TargetMenu[Client];

			//Connected:
			if(Ent > 0 && Client != Ent && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Has Enough Cash:
				if(Bank[Client] - Amount > 0 && Bank[Client] != 0 && Amount > 0)
				{

					//Declare:
					new NewAmount = RoundFloat(float(Amount)*0.90);

					//Initialize:
					SetBank(Client, (GetBank(Client) - Amount));

					SetBank(Ent, (GetBank(Ent) + NewAmount));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You just put \x0732CD32€%i\x07FFFFFF (\x0732CD32-€%i intrest\x07FFFFFF) in \x0732CD32%N\x07FFFFFF bank.", Amount, NewAmount, Ent);

					CPrintToChat(Ent, "\x07FF4040|RP-Bank|\x07FFFFFF - \x0732CD32%N\x07FFFFFF just put \x0732CD32€%i\x07FFFFFF (\x0732CD32-€%i intrest\x07FFFFFF) into your bank.", Client, Amount, NewAmount);

					//Set Menu State:
					BankState(Client, Amount);

					BankState(Ent, (Amount + Amount-(Amount/10)));

					//Draw Menu:
					DrawTransactMenu(Client);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);	
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You cannot target this player!");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - You can't talk to this NPC anymore, because you too far away!");
		}	
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

//PlayerMenu Handle:
public HandleTopMenu(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			decl String:info[64];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info));

			//Initialize:
			new Result = StringToInt(info);

			//Button Selected:
			if(Result == 1)
			{

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Bank, Cash FROM `Player` ORDER BY Bank + Cash DESC LIMIT 15;");

				//Declare:
				new conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopBank, query, conuserid);
			}

			//Button Selected:
			if(Result == 2)
			{

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Crime FROM `Player` ORDER BY Crime DESC LIMIT 15;");

				//Declare:
				new conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopCriminals, query, conuserid);
			}

			//Button Selected:
			if(Result == 3)
			{

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Rase FROM `Player` ORDER BY Rase DESC LIMIT 15;");

				//Declare:
				new conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopOnline, query, conuserid);
			}

			//Button Selected:
			if(Result == 4)
			{

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, JobSalary FROM `Player` ORDER BY JobSalary DESC LIMIT 15;");

				//Declare:
				new conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(GetGlobalSQL(), T_SQLLoadRPTopWages, query, conuserid);
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}

public T_SQLLoadRPTopBank(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Top] T_SQLLoadRPWinners: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		decl String:FormatMessage[2048], PlayerCash[15], PlayerBank[15], String:PlayerName[15][32];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Top Bank:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerCash[i] = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			PlayerBank[i] = SQL_FetchInt(hndl, 2);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%s)\n", PlayerName[i], IntToMoney(PlayerBank[i] + PlayerCash[i]));

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public T_SQLLoadRPTopCriminals(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Top] T_SQLLoadRPTopCriminals: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		decl String:FormatMessage[2048], PlayerCrime[15], String:PlayerName[15][32];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Most Wanted Players:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerCrime[i] = SQL_FetchInt(hndl, 1);

			//Check:
			if(PlayerCrime[i] > 0)
			{

				//Format:
				len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], RoundFloat(float(PlayerCrime[i]) / 1000));
			}

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public T_SQLLoadRPTopOnline(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Top] T_SQLLoadRPTopOnline: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		decl String:FormatMessage[2048], PlayerOnline[15], String:PlayerName[15][32];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Most Online Players:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerOnline[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], RoundFloat(float(PlayerOnline[i]) / 60));

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

public T_SQLLoadRPTopWages(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{
#if defined DEBUG
		//Logging:
		LogError("[rp_Core_Top] T_SQLLoadRPTopOnline: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Declare:
		decl String:FormatMessage[2048], PlayerSalary[15], String:PlayerName[15][32];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Highest Waged player:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, PlayerName[i], 32);

			//Database Field Loading Intiger:
			PlayerSalary[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (%i)\n", PlayerName[i], PlayerSalary[i]);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}

stock BankState(Client, Amount = 0)
{

	//Is Negative:
	if(Amount < 0)
	{

		//Format:
		Format(AddedBank[Client], sizeof(AddedBank[]), " - %s", IntToMoney(Amount));
	}

	//Is Negative:
	else
	{

		//Format:
		Format(AddedBank[Client], sizeof(AddedBank[]), " + %s", IntToMoney(Amount));
	}

	if(BankTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(BankTimer[Client]);

		//Initialize:
		BankTimer[Client] = INVALID_HANDLE;
	}

	//Timer:
	BankTimer[Client] = CreateTimer(3.0, RefreshBankState, Client);
}

stock CashState(Client, Amount = 0)
{

	//Is Negative:
	if(Amount < 0)
	{

		//Format:
		Format(AddedCash[Client], sizeof(AddedCash[]), " - %s", IntToMoney(Amount));
	}

	//Is Negative:
	else
	{

		//Format:
		Format(AddedCash[Client], sizeof(AddedCash[]), " + %s", IntToMoney(Amount));
	}

	//Check:
	if(CashTimer[Client] != INVALID_HANDLE)
	{

		//Kill:
		KillTimer(CashTimer[Client]);

		//Initialize:
		CashTimer[Client] = INVALID_HANDLE;
	}

	//Timer:
	CashTimer[Client] = CreateTimer(3.0, RefreshCashState, Client);
}

//Timer:
public Action:RefreshBankState(Handle:Timer, any:Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Initialize:
		AddedBank[Client] = "";
	}

	//Initialize:
	BankTimer[Client] = INVALID_HANDLE;
}

//Timer:
public Action:RefreshCashState(Handle:Timer, any:Client)
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Initialize:
		AddedCash[Client] = "";
	}

	//Initialize:
	CashTimer[Client] = INVALID_HANDLE;
}

stock String:GetCashState(Client)
{

	//Return:
	return AddedCash[Client];
}

stock String:GetBankState(Client)
{

	//Return:
	return AddedBank[Client];
}

stock GetBank(Client)
{

	//Return:
	return Bank[Client];
}

stock SetBank(Client, Amount)
{

	//Initulize:
	Bank[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", Bank[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

stock GetCash(Client)
{

	//Return:
	return Cash[Client];
}

stock SetCash(Client, Amount)
{

	//Initulize:
	Cash[Client] = Amount;

	//Check:
	if(IsLoaded(Client))
	{

		//Declare:
		decl String:query[255];

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", Cash[Client], SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}
}

public Action:Command_setCash(Client,Args)
{

	//Declare:
	new Player;

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_setcash <USER> <Cash>");

		//Return:
		return Plugin_Handled;      
	}

	//Is Valid:
	if(Args == 2)
	{

		//Declare:
		decl String:PlayerName[32], String:Name[32], String:Muny[32];
		new Munny = 0; 

		//Initialize:
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));

		//Initialize:
		Munny = StringToInt(Muny);  

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
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client %s", PlayerName);

			//Return:
			return Plugin_Handled;
		}

		//Is Console:
		if(Client == 0)
		{

			//Initialize:
			Name = "Console";
		}
		else
		{

			//Initialize:
			GetClientName(Client, Name, sizeof(Name));
		}

		//Initialize:
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Initialize:
		SetCash(Player, Munny);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the Cash for \x0732CD32%s\x07FFFFFF to \x0732CD32€%i", PlayerName,Munny);

		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your Cash has been set to \x0732CD32€%i\x07FFFFFF by \x0732CD32%s", Munny, Name);
#if defined DEBUG
		//Logging:
		LogMessage("\"%s\" set %s's Cash to \"€%i\"", Name, PlayerName, Munny); 
#endif
	}

	//Return:
	return Plugin_Handled; 
}

public Action:Command_setBank(Client,Args)
{

	//Declare:
	new Player;

	//Is Valid:
	if(Args < 2)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Wrong Parameter. Usage: sm_setbank <USER> <Cash>");

		//Return:
		return Plugin_Handled;      
	}

	//Is Valid:
	if(Args == 2)
	{

		//Declare:
		decl String:PlayerName[32], String:Name[32], String:Muny[32];
		new Munny = 0; 

		//Initialize:
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));

		//Initialize:
		Munny = StringToInt(Muny);  

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
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Could not find client %s", PlayerName);

			//Return:
			return Plugin_Handled;
		}

		//Is Console:
		if(Client == 0)
		{

			//Initialize:
			Name = "Console";
		}
		else
		{

			//Initialize:
			GetClientName(Client, Name, sizeof(Name));
		}

		//Initialize:
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Initialize:
		SetBank(Player, Munny);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Set the Bank for \x0732CD32%s\x07FFFFFF to \x0732CD32€%i", PlayerName,Munny);

		CPrintToChat(Player, "\x07FF4040|RP|\x07FFFFFF - Your Bank has been set to \x0732CD32€%i\x07FFFFFF by \x0732CD32%s", Munny, Name);
#if defined DEBUG
		//Logging:
		LogMessage("\"%s\" set %s's bank to \"€%i\"", Name, PlayerName, Munny); 
#endif
	}

	//Return:
	return Plugin_Handled; 
}

public Action:DrawDropCashMenu(Client)
{

	//Declare:
	decl String:display[32], String:info[32];

	//Convert:
	IntToString(Cash[Client], info, sizeof(info));

	//Handle:
	new Handle:Menu = CreateMenu(HandleDropMoney);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Select an amount of cash\nthat you would like to drop.");

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", Cash[Client]);

	//Menu Button:
	AddMenuItem(Menu, info, display);

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

	//Menu Button:
	AddMenuItem(Menu, "2", "2");

	//Menu Button:
	AddMenuItem(Menu, "5", "5");

	//Menu Button:
	AddMenuItem(Menu, "10", "10");

	//Menu Button:
	AddMenuItem(Menu, "25", "25");

	//Menu Button:
	AddMenuItem(Menu, "50", "50");

	//Menu Button:
	AddMenuItem(Menu, "100", "100");

	//Menu Button:
	AddMenuItem(Menu, "250", "250");

	//Menu Button:
	AddMenuItem(Menu, "500", "500");

	//Menu Button:
	AddMenuItem(Menu, "1000", "1000");

	//Menu Button:
	AddMenuItem(Menu, "2500", "2500");

	//Menu Button:
	AddMenuItem(Menu, "5000", "5000");

	//Menu Button:
	AddMenuItem(Menu, "10000", "10000");

	//Menu Button:
	AddMenuItem(Menu, "100000", "100000");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Bank|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public HandleDropMoney(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Can Drop:
			if(IsPlayerAlive(Client) && !IsCuffed(Client) && !GetIsCritical(Client))
			{

				//Declare:
				decl String:info[64];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, sizeof(info));

				//Declare:
				new Amount = StringToInt(info);

				//Can Transact:
				if(!(Cash[Client] - Amount < 0) && Cash[Client] != 0)
				{

					//EntCheck:
					if(CheckMapEntityCount() > 2047)
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention %i", CheckMapEntityCount());
					}

					//Declare:
					new Float:Position[3];

					decl String:Model[64];

					//Initialize:
					Model = "models/props_c17/briefcase001a.mdl";

					SetCash(Client, (GetCash(Client) - Amount));

					//Is Precached:
					if(!IsModelPrecached(Model))
					{

						//Precache:
						PrecacheModel(Model);
					}

					//Declare:
					new Ent = CreateEntityByName("prop_physics_override");

					//Declare:
					decl Collision;

					//Is Ent
					if(IsValidEntity(Ent))
					{

						//Values:
						DispatchKeyValue(Ent, "model", Model);

						//Spawn:
						DispatchSpawn(Ent);

						//Initialize:
						GetClientAbsOrigin(Client, Position);

						//Set Origin:
						Position[2] += 10.0;

						//Declare:
						Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");

						//Set End Data:
						SetEntData(Ent, Collision, 1, 1, true);

						//Teleport:
		   			 	TeleportEntity(Ent, Position, NULL_VECTOR, NULL_VECTOR);

						//Initialize:
						SetDroppedMoneyValue(Ent, Amount);
#if defined DEBUG
						//Declare:
						decl String:SteamId[255];

						GetClientAuthString(Client, SteamId, sizeof(SteamId));

						//Loggng:
						LogMessage("%N <%s> Dropped €%i", Client, SteamId, Amount);
#endif
						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have dropped \x0732CD32€%i\x07FFFFFF.", Amount);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you do not have enough cash.");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are not allowed to drop cash.");
			}
		}
	}

	//Selected:
	else if(HandleAction == MenuAction_End)
	{

		//Close:
		CloseHandle(Menu);
	}

	//Return:
	return true;
}
