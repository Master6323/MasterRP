//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_copranking_included_
  #endinput
#endif
#define _rp_copranking_included_

public Action:CopRankingMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleJobCop);

	//Menu Title:
	SetMenuTitle(Menu, "Select a button:\n\nCop Cuffs: %i\nCop Minutes: %i", GetCopCuffs(Client), GetCopMinutes(Client));

	//Add Menu Item:
	AddMenuItem(Menu, "0", "Change Your Job!");

	AddMenuItem(Menu, "1", "Sell Goods!");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);
}

//BankMenu Handle:
public HandleJobCop(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));	

		//Initialize:				
		new Result = StringToInt(info);

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

		//Button Selected:
		if(Result == 0)
		{

			//Not Cop:
			if(IsCop(Client))
			{

				//Handle:
				Menu = CreateMenu(HandleCopEmployer);

				//Menu Title:
				SetMenuTitle(Menu, "Select a Police Job:\nCop Experience: %i\nCorporal (500)\nSergeant (2500)\nLieutenant (7500)\nCaptain (17500)\nMajor (34000)\nLt. Colonel (59000)", GetCopExperience(Client));

				//Menu Button:
				AddMenuItem(Menu, "0", "Police Private");

				AddMenuItem(Menu, "500", "Police Corporal");

				AddMenuItem(Menu, "2500", "Police Sergeant");

				AddMenuItem(Menu, "7500", "Police Lieutenant");

				AddMenuItem(Menu, "17500", "Police Captain");

				AddMenuItem(Menu, "34000", "Police Major");

				AddMenuItem(Menu, "59000", "Police Lt. Colonel");

				//AddMenuItem(Menu, "82000", "SWAT");

				//AddMenuItem(Menu, "104000", "SWAT Leader");

				//AddMenuItem(Menu, "28500", "General of the Army");

				//Set Exit Button:
				SetMenuExitButton(Menu, false);

				//Show Menu
				DisplayMenu(Menu, Client, 30);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You need to be a cop in order to use this!");
			}
		}

		//Button Selected:
		if(Result == 1)
		{

			//Declare:
			new OldHarvest = GetResources(Client) + GetRice(Client);

			//Is In Time:
			if(OldHarvest > 0)
			{

				//Initulize:
				new AddCash = (GetResources(Client) * 5) + (GetRice(Client) * 4);

				SetCash(Client, (GetCash(Client) + AddCash));

				//Set Menu State:
				CashState(Client, AddCash);

				//Initulize:
				SetRice(Client, 0);

				SetResources(Client, 0);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You have sold \x0732CD32%i\x07FFFFFF Grams and made \x0732CD32€%i\x07FFFFFF!", OldHarvest, AddCash);
			}

			//Override:
			else
			{


				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - you dont have anything to quick sell!");
			}
		}

		//Button Selected:
		if(Result == 2)
		{

			//Draw Menu:
			DrawCopTradeExpMenu(Client);
		}

		//Return:
		return true;
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

public HandleCopEmployer(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Is Cop:
		if(IsCop(Client))
		{

			//Declare:
			decl String:info[64], String:display[255];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info), _, display, sizeof(display));

			//Check:
			if(GetCopExperience(Client) >= StringToInt(info))
			{

				//Format:
				SetJob(Client, display);

				SetOrgJob(Client, display);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You job is now \x0732CD32%s\x07FFFFFF.", display);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Cop|\x07FFFFFF - You need \x0732CD32%i\x07FFFFFF Cop experience for this job.", StringToInt(info));
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

public Action:DrawCopTradeExpMenu(Client)
{

	//Declare:
	decl String:display[32], String:info[32];

	//Convert:
	IntToString(GetCopExperience(Client), info, sizeof(info));

	//Handle:
	new Handle:Menu = CreateMenu(HandleCopTradeExp);

	//Menu Title:
	SetMenuTitle(Menu, "Select a button:\nCop Experience: %i\nCop Cuffs: %i\nCop Minutes: %i\n\n\nExchange Rate €15|1 CopEXP", GetCopExperience(Client), GetCopCuffs(Client), GetCopMinutes(Client));

	//Format:
	Format(display, sizeof(display), "All (€%i)", GetCopExperience(Client));

	//Menu Button:
	AddMenuItem(Menu, info, display);

	//Menu Button:
	AddMenuItem(Menu, "1", "1");

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
}

public HandleCopTradeExp(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[64];

		//Get Menu Info::
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new Amount = StringToInt(info);

		//Is Valid:
		if(GetCopExperience(Client) - Amount > 0 && GetCopExperience(Client) != 0)
		{

			//Initialize:
			new TradedXp = RoundToNearest(Amount*15.0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have traded \x0732CD32%i\x07FFFFFF xp for \x0732CD32€%i", Amount , TradedXp);

			//Initialize:
			SetBank(Client, (GetBank(Client) + TradedXp));

			SetCopExperience(Client, (GetCopExperience(Client) - Amount));

			//Set Menu State:
			BankState(Client, TradedXp);

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much cop experience.");
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
