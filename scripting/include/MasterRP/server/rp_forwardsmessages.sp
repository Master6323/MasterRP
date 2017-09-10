//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_forwardsmessages_included_
  #endinput
#endif
#define _rp_forwardsmessages_included_

public Action:PluginInfo_ForwardsMessages(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Game Messages!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

//Event Connect:
public Action:OnClientConnectMessage(Client)
{

	//Declare:
	decl String:auth[32];

	//Initialize:
	GetClientAuthString(Client, auth, sizeof(auth));

	//Masters root:
	if(SteamIdToInt(Client) == 30027290)
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF the magnificent modder! ", Client);
	}

	//Is Admin:
	else if(IsAdmin(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) enterd the city ({olive}ADMIN\x07FFFFFF).", Client, auth);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) enterd the city", Client, auth);
	}
}

//Event Disconnect:
public Action:OnClientDisconnectMessage(Client)
{

	//Declare:
	decl String:auth[32];

	//Initialize:
	GetClientAuthString(Client, auth, sizeof(auth));

	//Is Admin:
	if(IsAdmin(Client))
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) left the city ({olive}ADMIN\x07FFFFFF).", Client, auth);
	}

	//Override:
	else
	{

		//Print:
		CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF \x0732CD32%N\x07FFFFFF (\x0732CD32%s\x07FFFFFF) left the city", Client, auth);
	}
}

//Event Name:
public Action:OnClientName(Client, String:NewName[32], String:OldName[32])
{

	//Connected:
	if(Client > 0 && IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Anti Spam
		if(!StrEqual(NewName, OldName))
		{

			//Is Admin:
			if(IsAdmin(Client))
			{

				//Print:
				CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Admin {olive}%s\x07FFFFFF changed there name to {olive}%s\x07FFFFFF.", OldName, NewName);
			}

			//Override:
			else
			{

				//Print:
				CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Player \x0732CD32%s\x07FFFFFF changed there name to \x0732CD32%s\x07FFFFFF.", OldName, NewName);
			}

			//Declare:
			decl String:query[255], String:ClientName[32];

			//Remove Harmfull Strings:
			SQL_EscapeString(GetGlobalSQL(), NewName, ClientName, sizeof(ClientName));

			//Format:
			Format(query, sizeof(query), "UPDATE Player SET NAME = '%s' WHERE STEAMID = %i;", ClientName, SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}

//Event Server Cvar Change:
public Action:OnCvarChange(String:CvarName[255], String:CvarValue[255])
{

	//Print:
	CPrintToChatAll("\x07FF4040|RP|\x07FFFFFF - Server Cvar '\x0732CD32%s\x07FFFFFF' changed to \x0732CD32%s\x07FFFFFF.", CvarName, CvarValue);
}
