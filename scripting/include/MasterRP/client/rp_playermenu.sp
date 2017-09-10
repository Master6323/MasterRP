//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_playermenu_included_
  #endinput
#endif
#define _rp_playermenu_included_

//Euro - � dont remove this!
//€ = �

static TargetMenu[MAXPLAYERS + 1] = {-1,...};
static Float:JobCooldown[MAXPLAYERS + 1] = {0.0,...};

public Action:DrawPlayerMenu(Client, Player)
{

	//Initulize:
	TargetMenu[Client] = Player;

	//Handle:
	new Handle:Menu = CreateMenu(HandlePlayer);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Choose an option:\n\n%N", Player);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "0", "Give a Gift");

	//Menu Button:
	AddMenuItem(Menu, "1", "Your Actons");

	//Menu Button:
	AddMenuItem(Menu, "2", "Use Player");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Action|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public HandlePlayer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		new Ent = TargetMenu[Client];

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Declare:
		decl String:PlayerName[24];

		//Button Selected:
		if(Result == 0)
		{

			//Connected:
			if(IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Show Give Menu:
				DrawPlayerGive(Client, Ent);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player");
			}
		}

		//Button Selected:
		else if(Result == 1)
		{

			//Connected:
			if(IsClientConnected(Ent) && IsClientInGame(Ent))
			{

			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player");
			}
		}

		//Button Selected:
		else if(Result == 2)
		{

			//Handle:
			Menu = CreateMenu(HandlePlayerBuy);

			//Initialize:
			GetClientName(Ent, PlayerName, sizeof(PlayerName));

			//Menu Title:
			SetMenuTitle(Menu, "Select a button: (%s)", PlayerName);

			//Teacher:
			if(StrEqual(GetJob(Ent), "Principal", false) || IsAdmin(Ent))
			{

				//Menu Button:
				//AddMenuItem(Menu, "2", "Learn...");
			}

			//Teacher:
			if(StrEqual(GetJob(Ent), "Bank Administrative Officer", false) || IsAdmin(Ent))
			{

				//Menu Button:
				AddMenuItem(Menu, "3", "Deopsit Cash...");

				//Menu Button:
				AddMenuItem(Menu, "4", "Transfer To Player...");
			}

			//Override
			else
			{
				//Menu Button:
				AddMenuItem(Menu, "0", "Buy Items...");
			}

			//Menu Button:
			AddMenuItem(Menu, "1", "Back");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Client, 30);
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

public Action:DrawPlayerGive(Client, Player)
{

	//Declare:
	decl String:PlayerName[64];

	//Initialize:
	GetClientName(Player, PlayerName, sizeof(PlayerName));

	//Handle:
	new Handle:Menu = CreateMenu(HandleGivePlayer);

	//Menu Title:
	SetMenuTitle(Menu, "Select a button: (%s)", PlayerName);

	//Menu Button:
	AddMenuItem(Menu, "", "Give Cash");

	AddMenuItem(Menu, "", "Give Item");

	AddMenuItem(Menu, "", "Back");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);
}

//PlayerMenu Handle:
public HandleGivePlayer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Button Selected:
		if(Parameter == 0)
		{

			//Draw Menu:
			DrawGiveCashMenu(Client, TargetMenu[Client]);
		}

		//Button Selected:
		if(Parameter == 1)
		{

			//Initialize:
			SetIsGiving(Client, true);

			//Draw Menu:
			Inventory(Client);
		}

		//Button Selected:
		if(Parameter == 2)
		{

			//Show Menu:
			DrawPlayerMenu(Client, TargetMenu[Client]);
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

public Action:DrawGiveCashMenu(Client, Player)
{

	//Declare:
	decl String:display[32], String:info[32];

	//Convert:
	IntToString(GetCash(Client), info, sizeof(info));

	//Handle:
	new Handle:Menu = CreateMenu(HandleGiveCash);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "How much cash would you like\nto give %N?", Player);

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Format:
	Format(display, sizeof(display), "All (€%i)", GetCash(Client));

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

public HandleGiveCash(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		new Ent = TargetMenu[Client];

		//Connected:
		if(Ent > 0 && Client != Ent && IsClientConnected(Ent) && IsClientInGame(Ent))
		{


			//To Far Away:
			if(IsInDistance(Client, Ent))
			{

				//Declare:
				decl String:info[32];

				//Get Menu Info:
				GetMenuItem(Menu, Parameter, info, sizeof(info));	

				//Initialize:				
				new Amount = StringToInt(info);

				//Has Enough Cash:
				if(GetCash(Client) - Amount >= 0 && GetCash(Client) != 0)
				{

					//Initialize:
					SetCash(Client, (GetCash(Client) - Amount));

		            		SetCash(Ent, (GetCash(Ent) + Amount));

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You gave \x0732CD32€%i\x07FFFFFF to \x0732CD32%N", Amount, Ent);

					CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You recieve \x0732CD32€%i\x07FFFFFF from \x0732CD32%N", Amount, Client);

					//Set Menu State:
					CashState(Client, Amount);

					CashState(Ent, Amount);

					//Draw Menu:
					DrawGiveCashMenu(Client, Ent);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are to far away from this player, move clooser..");
			}
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
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

public Action:DrawHandleMenu(Client, Player)
{

	//Declare:
	decl String:PlayerName[64];

	//Initialize:
	GetClientName(Player, PlayerName, sizeof(PlayerName));

	//Handle:
	new Handle:Menu = CreateMenu(HandleYourActions);

	//Is Combine and Player Is Cuffed:
	if(IsCop(Client) || IsAdmin(Client))
	{

		//Is Cuffed
		if(IsCuffed(Player))
		{

			//Menu Button:
			AddMenuItem(Menu, "0", "Jail");

			//Menu Button:
			AddMenuItem(Menu, "1", "Catch");

			//Menu Button:
			AddMenuItem(Menu, "2", "Offer Bail");

			//Menu Button:
			AddMenuItem(Menu, "3", "Force Feed");

			//Menu Button:
			AddMenuItem(Menu, "4", "Release Player");

			//Menu Button:
			AddMenuItem(Menu, "5", "Search Player");

			//Check If player is in jail!
			if(IsClientInJail(Player))
			{

				//Menu Button:
				AddMenuItem(Menu, "10", "Send to Execut");

				//Menu Button:
				AddMenuItem(Menu, "11", "Send to Fire Pit");

				//Menu Button:
				AddMenuItem(Menu, "7", "VIP Jail");
			}
		}

		//Is Medic:
		if(StrContains(GetJob(Client), "Medic", false) != -1 || IsAdmin(Client))
		{

			//Menu Button:
			AddMenuItem(Menu, "6 100", "Heal Player");
		}
	}

	//Is Medic:
	if(StrContains(GetJob(Client), "Brain Surgeon", false) != -1)
	{

		//Menu Button:
		AddMenuItem(Menu, "6 60", "Heal");
	}
/*
	//Is Lord:
	if(StrContains(GetJob(Client), "Mafia Boss", false) != -1 || StrContains(GetJob(Client), "Crime Lord", false) != -1)
	{

		//Menu Button:
		AddMenuItem(Menu, "8", "Drug Lord");
	}
*/
	//Menu Button:
	AddMenuItem(Menu, "9", "Back");

	//Menu Title:
	SetMenuTitle(Menu, "Select a button: (%s)", PlayerName);

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);
}

//PlayerMenu Handle:
public HandleYourActions(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[64], String:Buffer[2][64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Explode:
		ExplodeString(info, " ", Buffer, 2, 64);

		//Initialize:
		new Result = StringToInt(Buffer[0]);

		//Declare:
		new Ent = TargetMenu[Client];

		//Button Selected:
		if(Result == 0 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Jail Player:
			JailClient(Ent, Client);
		}

		//Button Selected:
		if(Result == 1 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Not Grabbed:
			if(GetGrabbed(Client) == -1)
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You Grabbed \x0732CD32%N\x07FFFFFF.", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Grabbed you.", Client);

				//Initialize:
				SetGrabbed(Client, Ent);

				//Timer:
				CreateTimer(0.1, Pusher, Client);

				//Set Speed:
				SetEntitySpeed(Ent, 1.0);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You let go \x0732CD32%N\x07FFFFFF.", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF let you go.", Client);

				//Initialize:
				SetGrabbed(Client, -1);

				//Set Speed:
				SetEntitySpeed(Ent, 0.4);
			}
		}

		//Button Selected:
		if(Result == 2 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Initulize::
			TargetMenu[Ent] = Client;

			//Handle:
			Menu = CreateMenu(HandlePlayerBribe);

			//Title:
			SetMenuTitle(Menu, "%N\nHas gave you the option\nof offering a brite\nto release you from jail\n\nYour Answer...", Client);

			//Menu Button:
			AddMenuItem(Menu, "100", "€100");

			AddMenuItem(Menu, "250", "€250");

			AddMenuItem(Menu, "500", "€500");

			AddMenuItem(Menu, "1000", "€1000");

			AddMenuItem(Menu, "0", "no I wont pay");

			//Set Exit Button:
			SetMenuExitButton(Menu, false);

			//Show Menu:
			DisplayMenu(Menu, Ent, 30);

			//Print:
			CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have offered a bail to \x0732CD32%N\x07FFFFFF!", Ent);
		}

		//Button Selected:
		if(Result == 3 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Declare:
			decl String:PlayerName[32];

			//Initialize:
			GetClientName(Ent, PlayerName, 32);

			//Enough Hunger:
			if(GetHunger(Ent) < 100.0)
			{

				//Declare:
				decl String:ClientName[32];

				//Initialize:
				GetClientName(Client, ClientName, 32);

				//Enough Hunger:
				if(GetHunger(Ent) >= 80.0)
				{

					//Initialize:
					SetHunger(Ent, 100.0);
				}

				//Override:
				else
				{

					//Initialize:
					SetHunger(Ent, (GetHunger(Ent) + 15.0));
				}

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You forced feaded \x0732CD32%s\x07FFFFFF.", PlayerName);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF forced feaded you.", ClientName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF is full, you cannot feed him anymore.", PlayerName);
			}
		}

		//Button Selected:
		if(Result == 5 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent) == true)
		{

			//Has Harvest:
			if(GetHarvest(Ent) > 0 || GetMeth(Ent) > 0 || GetPills(Ent) > 0 || GetResources(Ent) > 0 || GetCocain(Ent) > 0)
			{

				//Declare:
				new AddCash = GetHarvest(Ent) + GetMeth(Ent) + (GetPills(Ent) * 5) + GetResources(Ent) + (GetCocain(Ent) * 10);

				//Initulize:
				SetHarvest(Ent, 0);

				SetMeth(Ent, 0);

				SetCocain(Ent, 0);

				SetPills(Ent, 0);

				SetResources(Ent, 0);

				SetBank(Client, (GetBank(Client) + AddCash));

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Has Drugs on them! €\x0732CD32%i\01 reward!", Ent, AddCash);

				//Print:
				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You have been busted for drugs!");

				//Play Sound:
				EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF Hasn't got any Drugs on them.", Ent);

				//Print:
				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - You have been searched but nothing was found!");
			}
		}

		//Button Selected:
		if(Result == 4 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has released you from jail.", Ent);

			CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - you have released \x0732CD32%N\x07FFFFFF from jail.", Client);

			//Free Player:
			AutoFree(Ent);
		}

		//Button Selected:
		if(Result == 6)
		{

			//Initialize:
			new ClientHealHP = StringToInt(Buffer[1]);

			//Declare:
			new ClientHP = GetClientHealth(Ent);

			//Is In Time:
			if(JobCooldown[Client] < (GetGameTime() - 30))
			{

				//Healing Rage:
  				if(ClientHP < 100 && !(ClientHP > 100))
				{

					//Has Energy:
					if(GetEnergy(Client) >= 15)
					{

						//In Critical:
						if(ClientHP <= 20)
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 10));
						}

						//Low HP:
						if(ClientHP <= 60 && ClientHP > 20)
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 5));
						}

						//Override:
						else
						{

							//Initialize:
							SetJobExperience(Client, (GetJobExperience(Client) + 3));
						}

						//Initulize:
						SetEnergy(Client, (GetEnergy(Client) - 15));

						//To Much Health:
						if(ClientHP + ClientHealHP > 100)
						{

							//Set Health:
							SetEntityHealth(Ent, 100);
						}

						//Override:
						else
						{

							//Set Health:
							SetEntityHealth(Ent, (ClientHP + ClientHealHP));
						}

						//Initulize:
						JobCooldown[Client] = GetGameTime();

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have healed \x0732CD32%N\x07FFFFFF for \x0732CD32%i\x07FFFFFFHP.", Ent, ClientHealHP);

						CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has healed you for +\x0732CD32%i\x07FFFFFFHP.", Client, ClientHealHP);
					}

					//Override:
					else
					{

						//Print:
						CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You dont have enough energy to heal \x0732CD32%N\x07FFFFFF.", Ent);
					}
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF already has perfect health.", Ent);
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have done this job too recently!");
			}
		}

		//Button Selected:
		if(Result == 10 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Sent Client To Execute:
			Execute(Ent, Client);
		}

		//Button Selected:
		if(Result == 11 && (IsCop(Client) || IsAdmin(Client)) && IsCuffed(Ent))
		{

			//Sent Client To FirePit:
			FirePit(Ent, Client);
		}

		//Button Selected:
		if(Result == 9)
		{

			//Show Menu:
			DrawPlayerMenu(Client, Ent);
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
public HandlePlayerBribe(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
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

		//Declare:
		new Ent = TargetMenu[Client];

		//Button Selected:
		if(Result != 0)
		{

			//Connected:
			if(Ent > 0 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Has Enough Cash:
				if(GetBank(Client) >= Result)
				{

					//Initulize:
					SetBank(Client, (GetBank(Client) - Result));

					SetBank(Ent, (GetBank(Ent) + Result));

					//Set Menu State:
					BankState(Client, Result);

					BankState(Ent, Result);

					//Uncuff Client:
					AutoFree(Ent);

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You are released from jail!");

					CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has took your offer of \x0732CD32€%i\x07FFFFFF!", Client, Result);

					//Play Sound:
					EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much Cash with you!");
				}
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
			}
		}

		//Override
		else
		{

			//Connected:
			if(Ent == -1 && IsClientConnected(Ent) && IsClientInGame(Ent))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - you have turned down \x0732CD32%N\x07FFFFFF's offer!", Ent);

				CPrintToChat(Ent, "\x07FF4040|RP|\x07FFFFFF - \x0732CD32%N\x07FFFFFF has turned down your offer!", Client);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot target this player.");
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

//PlayerMenu Handle:
public HandleUsePlayer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
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
			DrawPlayerMenu(Client, TargetMenu[Client]);
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
public HandlePlayerBuy(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		new Ent = TargetMenu[Client];

		//Declare:
		decl String:info[64];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Show Menu:
			PlayerBuyMenu(Client);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Show Menu:
			DrawPlayerMenu(Client, Ent);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			//DrawHelpMenu(Client);
		}

		//Button Selected:
		if(Result == 3)
		{

			//Show Menu:
			DrawDepositMenu(Client);
		}

		//Button Selected:
		if(Result == 4)
		{

			//Show Menu:
			DrawTransactMenu(Client);
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
