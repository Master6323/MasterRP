//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_plugininfo_included_
  #endinput
#endif
#define _rp_plugininfo_included_

//Definitions:
#define MAINVERSION		"3.03.24"

//Plugin Info:
public Plugin:myinfo =
{
	name = "Official Roleplay FrameWork",
	author = "Master(D)",
	description = "Main Plugin",
	version = MAINVERSION,
	url = ""
};

String:MainVersion()
{

	//Declare:
	decl String:info[64];

	//Format:
	Format(info, sizeof(info), "%s", MAINVERSION);

	//Return:
	return info;
}

initPluginInfo()
{

	//Command Listener:
	RegConsoleCmd("sm_plugininfo", Command_PluginInfo);
}

public Action:Command_PluginInfo(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Is Console:
		if(Client == 0)
		{

			//Print:
			PrintToConsole(Client, "|RP| - Usage: sm_plugininfo <Page #>");
		}

		//Override:
		else
		{

			//Print:
			PrintToConsole(Client, "|RP| - Usage: sm_plugininfo <Page #>");

			CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Usage: sm_plugininfo <Page #>");
		}

		//Return:
		return Plugin_Handled;
	}

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToConsole(0, "|RP| - Main Plugin Version v%s", MainVersion());
	}

	//Override:
	else
	{

		//Print:
		PrintToConsole(Client, "|RP| - Main Plugin Version v%s", MainVersion());

		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Main Plugin Version v%s", MainVersion());
	}

	//Declare:
	decl String:ArgStr[32]; new Page = -1;

	//Initialize:
	GetCmdArg(1, ArgStr, sizeof(ArgStr));

	//Initialize:
	Page = StringToInt(ArgStr);

	if(Page == 1)
	{

		//Print:
		PluginInfo_Bank(Client);

		PluginInfo_CopDoors(Client);

		PluginInfo_CrateZones(Client);

		PluginInfo_Crime(Client);

		PluginInfo_Cvar(Client);

		PluginInfo_Donator(Client);

		PluginInfo_DoorLocked(Client);

		PluginInfo_Forwards(Client);

		PluginInfo_ForwardsMessages(Client);

		PluginInfo_GameName(Client);
	}

	if(Page == 2)
	{

		//Print:
		PluginInfo_GarbageZone(Client);

		PluginInfo_Hud(Client);

		PluginInfo_init(Client);

		PluginInfo_IsCritical(Client);

		PluginInfo_Items(Client);

		PluginInfo_Jail(Client);

		PluginInfo_JobList(Client);

		PluginInfo_JobSetup(Client);

		PluginInfo_JobSystem(Client);

		PluginInfo_Light(Client);
	}

	if(Page == 3)
	{

		//Print:
		//PluginInfo_MoneySafe(Client);

		PluginInfo_NoKillZone(Client);

		PluginInfo_Npcs(Client);

		PluginInfo_Player(Client);

		PluginInfo_Printers(Client);

		PluginInfo_Settings(Client);

		PluginInfo_Sleeping(Client);

		PluginInfo_Spawns(Client);

		PluginInfo_Sql(Client);

		PluginInfo_Stock(Client);
	}

	if(Page == 4)
	{

		//Print:
		PluginInfo_TalkSounds(Client);

		PluginInfo_TalkZone(Client);

		PluginInfo_TeamFix(Client);

		PluginInfo_TeamName(Client);

		PluginInfo_Thumpers(Client);

		PluginInfo_VendorBuy(Client);

		PluginInfo_WeaponMod(Client);

		PluginInfo_Bans(Client);
	}

	//Return:
	return Plugin_Handled;
}
