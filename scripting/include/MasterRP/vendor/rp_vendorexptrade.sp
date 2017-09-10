//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorexptrade_included_
  #endinput
#endif
#define _rp_vendorexptrade_included_

//Job Experience Menu:
public Action:ExperienceMenu(Client)
{

	//Declare:
	decl String:FormatTitle[50];

	//Format:
	Format(FormatTitle, 50, "Job Experience (%i)", GetJobExperience(Client));

	//Handle:
	new Handle:Menu = CreateMenu(HandleJobExp);

	//Menu Title:
	SetMenuTitle(Menu, FormatTitle);

	//Add Menu Item:
	AddMenuItem(Menu, "0", "Trade Job Exp");

	AddMenuItem(Menu, "1", "View Exchange Rate");

	AddMenuItem(Menu, "2", "Buy Items...");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//Custom Job Items:
public Action:JobItemsMenu(Client)
{

	//Handle:
	new Handle:Menu = CreateMenu(HandleJobExpBuy); new bool:ShowMenu = false;

	//Loop:
	for(new X = 0; X < 400; X++)
	{

		//Selected Group:
		if(GetItemGroup(X) == 14)
		{

			//No Item
			if(GetItemAmount(Client, X) == 0)
			{

				//Declare:
				decl String:ActionItemId[255],String:MenuItemName[32],String:ItemId[255];

				//Declare:
        	      		new Price = (GetItemCost(X) / 1000);

				//Format:
				Format(MenuItemName, 32, "[%iK] %s", Price, GetItemName(X));

				//Convert:
				IntToString(X, ItemId, 255);

				//Format:
				Format(ActionItemId, 255, "%s 0", ItemId);

						//Add Menu Item:
				AddMenuItem(Menu, ActionItemId, MenuItemName);

				//Initialize:
				ShowMenu = true;
			}
		}
	}

	//Show:
	if(ShowMenu == true)
	{

		//Declare:
		decl String:Title[255];

		//Format:
		Format(Title, 255, "This menu allows you to buy\nspecial items with the job\nexperience you've earned\nYou have %i Experience", GetJobExperience(Client));

		//Menu Title:
		SetMenuTitle(Menu, Title);

		//Max Menu Buttons:
		SetMenuPagination(Menu, 7);

		//Show Menu:
		DisplayMenu(Menu, Client, 30);
	}

	//Override:
	else
	{

		//Close:
		CloseHandle(Menu);
	}
}

//Trade Experience Menu:
public Action:TradeExperienceMenu(Client)
{

	//Declare:
	decl String:AllBank[32], String:bAllBank[32];

	//Format:
	Format(AllBank, 32, "All (%i)", GetJobExperience(Client));

	Format(bAllBank, 32, "%i", GetJobExperience(Client));

	//Handle:
	new Handle:Menu = CreateMenu(HandleTraderEx);

	//Menu Title:
	SetMenuTitle(Menu, "How Much to Trade:");

	//Menu Button:
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

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Show Menu:
	DisplayMenu(Menu, Client, 20);
}

//BankMenu Handle:
public HandleJobExp(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Declare:
		new Result = StringToInt(info);

		//Button Selected:
		if(Result == 0)
		{

			//Show Menu:
			TradeExperienceMenu(Client);
		}

		//Button Selected:
		if(Result == 1)
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - \x0732CD321.0XP\x07FFFFFF|€\x0732CD32%0.1f\x07FFFFFF Exchange Rate For Money.", 5.0);
		}

		//Button Selected:
		if(Result == 2)
		{

			//Show Menu:
			JobItemsMenu(Client);
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

public HandleTraderEx(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
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
		if((GetJobExperience(Client) - Amount > 0) && GetJobExperience(Client) != 0)
		{

			//Initialize:
			new TradedXp = RoundToNearest(Amount*5.0);

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You have traded \x0732CD32%i\x07FFFFFF xp for \x0732CD32€%i", Amount , TradedXp);

			//Initialize:
			SetBank(Client, (GetBank(Client) + TradedXp));

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) - Amount));

			//Set Menu State:
			BankState(Client, TradedXp);

			//Play Sound:
			EmitSoundToClient(Client, "roleplay/cashregister.wav", SOUND_FROM_PLAYER, 5);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You don't have that much experience.");
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

public HandleJobExpBuy(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Declare:
		decl String:info[32];

		//Get Menu Info:
		GetMenuItem(Menu, Parameter, info, sizeof(info));

		//Initialize:
		new ItemId = StringToInt(info);

		new SItemCost = GetItemCost(ItemId);

		//Has Enoug Money
		if(GetJobExperience(Client) >= SItemCost)
		{

			//Initialize:
			SetJobExperience(Client, (GetJobExperience(Client) - SItemCost));

			//Save:
			SaveItem(Client, ItemId, (GetItemAmount(Client, ItemId) + 1));

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You purchase \x0732CD32%s\x07FFFFFF for \x0732CD32€%%i\x07FFFFFF Job Experience.", GetItemName(ItemId), SItemCost);
		}

		//Override:
		else
		{

			//Print:
			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF You don't have enough Job Experience for this item");
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
