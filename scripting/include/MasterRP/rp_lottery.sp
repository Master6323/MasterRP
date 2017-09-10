
//Lottery:
static LotteryCheck = 0;
static LotteryTickets = 0;

		//Initialize:
		IsQuery = true;

		//Declare:
		decl String:query[255];

		//Initulize:
		LotteryCheck += 1;

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = Ticker + 1;");

		//Not Created Tables:
		SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

		//24 hours:
		if(LotteryCheck > 720)
		{

			//Sql Strings:
			Format(query, sizeof(query), "SELECT Tickets FROM LotteryData;");

			//Not Created Tables:
			SQL_TQuery(hDataBase, T_LoadLotteryIntCallBack, query);
		}

		//Initialize:
		IsQuery = false;


				//Load:
				LoadString(Vault, "6", NPCId, "Null", Props);

				//Is NPC:
				if(StrContains(Props, "Null", false) == -1)
				{

					//Loop:
					ExplodeString(Props, " ", Buffer, 5, 32);

					//Get Origin:
					GetClientAbsOrigin(Client, ClientOrigin);

					//Initialize:
					Origin[0] = StringToFloat(Buffer[1]);

					Origin[1] = StringToFloat(Buffer[2]);

					Origin[2] = StringToFloat(Buffer[3]);

					//Get Dist:
					Dist = GetVectorDistance(ClientOrigin, Origin);

					//In Distance:
					if(Dist <= 100)
					{

						//Show Menu:
						VendorMenuLottery(Client);

						//Initialize:
						MenuTarget[Client] = Ent;

						//Close:
						CloseHandle(Vault);

						//Return:
						return Plugin_Handled;
					}
				}


public Action:VendorMenuLottery(Client)
{
	//Handle:
	new Handle:Menu = CreateMenu(HandleLotteryMenu);

	//Declare:
	decl String:title[256]; Format(title, sizeof(title), "Would you like to buy a\nlottery ticket? or view\nprevious lottery winners?");

	//Menu Title:
	SetMenuTitle(Menu, title);

	//Menu Button:
	AddMenuItem(Menu, "0", "View Winners");

	//Menu Button:
	AddMenuItem(Menu, "1", "[€500] Lottery Ticket");

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}


//PlayerMenu Handle:
public HandleLotteryMenu(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
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
			if(Result == 0)
			{

				//Declare:
				decl String:query[255];

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME, Amount FROM `LotteryWinners` ASP LIMIT 15;");

				//Declare:
				new conuserid = GetClientUserId(Client);

				//Not Created Tables:
				SQL_TQuery(hDataBase, SQLLoadRPWinners, query, conuserid);

				//CPrint:
				PrintToConsole(Client, "|RP| Loading Lottery Winners.");
			}

			//Button Selected:
			if(Result == 1)
			{

				//Enough Cash:
				if(Cash[Client] >= 500)
				{

					//Initulize:
					Cash[Client] -= 500;

					//Set Menu State:
					CashState(Client, 500, true);

					//Initialize:
					IsQuery = true;

					//Declare:
					decl String:query[255];

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE Player SET Cash = %i WHERE STEAMID = %i;", Cash[Client], SteamIdToInt(Client));

					//Not Created Tables:
					if(IsLoaded[Client])
					{
						SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
					}

					//Initulize:
					LotteryTickets += 1;

					//Sql String:
					Format(query, sizeof(query), "INSERT INTO Lottery (`Tickets`,`STEAMID`) VALUES (%i,%i);", LotteryTickets, SteamIdToInt(Client));

					//Not Created Tables:
					SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

					//Sql Strings:
					Format(query, sizeof(query), "UPDATE LotteryData SET Tickets = %i;", LotteryTickets);

					//Not Created Tables:
					SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

					//Initialize:
					IsQuery = false;

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - You have been entered into the RP lottery!");
				}

				//Override:
				else
				{

					//Print:
					CPrintToChat(Client, "\x07FF4040|RP-Lottery|\x07FFFFFF - You dont have enougn cash to be entered into the RP Lottery!");
				}
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

public SQLLoadRPWinners(Handle:owner, Handle:hndl, const String:error[], any:data)
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

		//Logging:
		LogError("[rp_Core_Lottery] SQLLoadRPWinners: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		decl String:FormatMessage[2048], AmountWon[15], String:WinnerName[15][32];

		//Declare:
		new len = 0; new i = 0;

		//Format:
		len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   Lottery Winners:\n\n");

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, WinnerName[i], 32);

			//Database Field Loading Intiger:
			AmountWon[i] = SQL_FetchInt(hndl, 1);

			//Format:
			len += Format(FormatMessage[len], sizeof(FormatMessage)-len, "   %s  (€%i)\n", WinnerName[i], AmountWon[i]);

			//Initulize:
			i++;
		}

		//Print Message:
		CreateMenuTextBox(Client, 0, 30, 250, 250, 250, 250, FormatMessage);
	}
}


public T_LoadLotteryIntCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_LoadLotteryIntCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{


		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			new AmountWon = RoundFloat((SQL_FetchInt(hndl, 0)*500)/10.0);

			//Check Glitch:
			if(AmountWon < 0 || AmountWon < 25000) AmountWon = 5000;

			//Declare:
			decl String:query[255];

			//Sql Strings:
			Format(query, sizeof(query), "SELECT * FROM `Lottery` ORDER BY RANDOM() LIMIT 1;");

			//Not Created Tables:
			SQL_TQuery(hDataBase, T_LoadLotteryWinsCallBack, query, AmountWon);
		}
	}
}

public T_LoadLotteryWinsCallBack(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_LoadLotteryWinsCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:query[255];

			//Declare:
			new SteamId = SQL_FetchInt(hndl, 1); new FoundPlayer;

			//Loop:
			for(new i = 1; i <= GetMaxClients(); i ++)
			{

				//Connected:
				if(IsClientConnected(i) && IsClientInGame(i))
				{

					//Is Valid:
					if(SteamId == SteamIdToInt(i))
					{

						//Initulize:
						FoundPlayer = 1;

						Bank[i] += data;

						//Set Menu State:
						BankState(i, data, false);

						//Initialize:
						IsQuery = true;

						//Sql Strings:
						Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", Bank[i], SteamIdToInt(i));

						//Not Created Tables:
						if (IsLoaded[i])
						{
							SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
						}

						//Declare:
						decl String:ClientName[255], String:CNameBuffer[255];

						//Initialize:
						GetClientName(i, ClientName, sizeof(ClientName));

						//Remove Harmfull Strings:
						SQL_EscapeString(hDataBase, ClientName, CNameBuffer, sizeof(CNameBuffer));

						//Sql String:
						Format(query, sizeof(query), "INSERT INTO LotteryWinners (`NAME`,`STEAMID`,`Amount`,`Collected`) VALUES ('%s',%i,%i,1);", CNameBuffer, SteamIdToInt(i), data);

						//Not Created Tables:
						SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

						//Initialize:
						IsQuery = false;

						//Print:
						CPrintToChat(i, "\x07FF4040|RP|\x07FFFFFF - Congratulations you have won the lottery!");

						//Print:
						CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - \x0732CD32%s\x07FFFFFF Has won the lottery! €\x0732CD32%i\x07FFFFFF rewarded!", ClientName, data);

						//Initulize:
						LotteryCheck = 0;

						LotteryTickets += 0;

						//Sql Strings:
						Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = 0, Tickets = 0;");

						//Not Created Tables:
						SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

						//Sql Strings:
						Format(query, sizeof(query), "DELETE FROM Lottery;");

						//Not Created Tables:
						SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
					}
				}
			}

			//Save in DB:
			if(FoundPlayer != 1)
			{

				//Handle:
				new Handle:DataPack = CreateDataPack();

				//Write
				WritePackCell(DataPack, SteamId);

				WritePackCell(DataPack, data);

				//Sql Strings:
				Format(query, sizeof(query), "SELECT NAME FROM `Player` Where STEAMID = %i;", SteamId);

				//Not Created Tables:
				SQL_TQuery(hDataBase, T_LoadLotterySaveWinnerCallBack, query, DataPack);
			}
		}
	}
}

public T_LoadLotterySaveWinnerCallBack(Handle:owner, Handle:hndl, const String:error[], any:DataPack)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_LoadLotterySaveWinnerCallBack: Query failed! %s", error);
	}

	//Override:
	else 
	{


		//Database Row Loading INTEGER:
		if(SQL_FetchRow(hndl))
		{

			//Declare:
			decl String:ClientName[255];

			//Database Field Loading String:
			SQL_FetchString(hndl, 0, ClientName, sizeof(ClientName));

			//Read:
			ResetPack(DataPack);

			//Declare:
			new AmountWon, SteamId;

			//Initulize:
			SteamId = ReadPackCell(DataPack);

			AmountWon = ReadPackCell(DataPack);

			//Declare:
			decl String:query[255];

			//Sql String:
			Format(query, sizeof(query), "INSERT INTO LotteryWinners (`NAME`,`STEAMID`,`Amount`,`Collected`) VALUES ('%s',%i,%i,0);", ClientName, SteamId, AmountWon);

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

			//Print:
			CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - \x0732CD32%s\x07FFFFFF Has won the lottery! €\x0732CD32%i\x07FFFFFF rewarded!", ClientName, AmountWon);

			//Initulize:
			LotteryCheck = 0;

			LotteryTickets = 0;

			//Sql Strings:
			Format(query, sizeof(query), "UPDATE LotteryData SET Ticker = 0, Tickets = 0;");

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);

			//Sql Strings:
			Format(query, sizeof(query), "DELETE FROM Lottery;");

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
		}
	}
}

public T_DBLoadLotteryDataCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_LotteryData] T_DBLoadLotteryDataCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Declare:
			decl String:buffer[255];

			//Sql String:
			Format(buffer, sizeof(buffer), "INSERT INTO LotteryData (`Ticker`, `Tickets`) VALUES (0,0);");

			//Not Created Tables:
			SQL_TQuery(hDataBase, SQLErrorCheckCallback, buffer);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Database Field Loading INTEGER:
			LotteryCheck = SQL_FetchInt(hndl, 0);

			//Database Field Loading INTEGER:
			LotteryTickets = SQL_FetchInt(hndl, 1);
		}
	}
}



		//Declare:
		decl String:query[255];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `Lottery` WHERE STEAMID = %i;", SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(hDataBase, T_DBLoadLotteryCallback, query, data);


public T_DBLoadLotteryCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Initialize:
		IsQuery = false;

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_DBLoadLotteryCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Declare:
		decl String:query[255];

		//Format:
		Format(query, sizeof(query), "SELECT * FROM `Achievements` WHERE STEAMID = %i;", SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(hDataBase, T_DBLoadAchievementsCallback, query, data);

		//Print:
		PrintToConsole(Client, "|RP| Loading Lottery Tickets...");

		//Format:
		Format(query, sizeof(query), "SELECT Amount, Collected FROM `LotteryWinners` WHERE STEAMID = %i;", SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(hDataBase, T_DBLoadLotteryCheckCallback, query, data);

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| No Lottery Tickets Found.");
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| Lottery Tickets Found.");
		}
	}
}

public T_DBLoadLotteryCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{

	//Declare:
	new Client;

	//Is Client:
	if((Client = GetClientOfUserId(data)) == 0)
	{

		//Initialize:
		IsQuery = false;

		//Return:
		return;
	}

	//Invalid Query:
	if (hndl == INVALID_HANDLE)
	{

		//Logging:
		LogError("[rp_Core_Lottery] T_DBLoadLotteryCheckCallback: Query failed! %s", error);
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Checking Lottery Data...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| You haven't won the lottery!");
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{

			//Declare:
			new Collected = SQL_FetchInt(hndl, 1);

			//Is Valid:
			if(Collected == 0)
			{

				//Declare:
				new Winnings = SQL_FetchInt(hndl, 0);

				//Initulize:
				Bank[Client] += Winnings;

				//Declare:
				decl String:query[512];

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE LotteryWinners SET Collected = 1 WHERE STEAMID = %i;", SteamIdToInt(Client));

				//Not Created Tables:
				if(IsLoaded[Client])
				{
					SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
				}

				//Sql Strings:
				Format(query, sizeof(query), "UPDATE Player SET Bank = %i WHERE STEAMID = %i;", Bank[Client], SteamIdToInt(Client));

				//Not Created Tables:
				if(IsLoaded[Client])
				{
					SQL_TQuery(hDataBase, SQLErrorCheckCallback, query);
				}

				//Initialize:
				IsQuery = false;

				//CPrint:
				CPrintToChatAll("\x07FF4040|RP - Lottery|\x07FFFFFF |\x07FF4040ATTENTION\x07FFFFFF| - %N Has won the lottery! they reseaved \x0732CD32%i\x07FFFFFF!", Client, Winnings);
			}

			//Override:
			else
			{

				//Print:
				PrintToConsole(Client, "|RP| Winnings already collected!");
			}
		}
	}
}


