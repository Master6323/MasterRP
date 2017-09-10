//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_talksounds_included_
  #endinput
#endif
#define _rp_talksounds_included_

static Float:CanSay[MAXPLAYERS + 1] = {0.0,...};

public Action:PluginInfo_TalkSounds(Client)
{

	//Print:
	PrintToConsole(Client, "\n|RP| - %s", "Talk Sounds!");
	PrintToConsole(Client, "Auther - %s", "Master(D)");
	PrintToConsole(Client, "Version - %s", "V1.00.00");
}

initTalkSounds()
{

	//Commands:
	RegConsoleCmd("sm_sounds", Commandsounds);
}

//Say Sounds menu:
public Action:Commandsounds(Client, Args)
{

	//Is Console:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| this command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Create Menu:
	CreateMenuTextBox(Client, 1, 60, 20, 255, 20, 250, "Hello and welcome to\nthe say sounds list!\n\n    01: get the hell out\n    02: hack\n    03: headcrab\n    04: like that\n    05: nice\n    06: oh no\n    07: the hacks\n    08: zombie\n    09: haha\n    10: laugh\n    11: quickly\n    12: knock knock\n    13: allright\n    14: too loud\n    15: me\n    16: wait a minute\n    17: sure\n    18: have fun");

	//Print;
	OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");

	//Return:
	return Plugin_Handled;
}

public bool:CheckStringSound(Client, const String:Text[])
{

	//Declare:
	decl String:Sound[256], String:Model[256]; new bool:CanPlay = false;

	//Get Prop String:
	GetEntPropString(Client, Prop_Data, "m_ModelName", Model, sizeof(Model));  

	//Get Name:
	if(StrEqual(Text, "get the hell out"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/gethellout.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/gethellout.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "hack"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/hacks01.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/hacks01.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "headcrab") || StrEqual(Text, "head crab"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/headcrabs01.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/headcrabs01.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "like that"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/likethat.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/likethat.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "nice"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/nice01.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/nice.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "oh no"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/ohno.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/ohno.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "the hacks"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/thehacks01.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/thehacks01.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "zombie"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/female01/zombies01.wav");
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/male01/zombies01.wav");
		}

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "hehe"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/eli_lab/al_laugh01.wav");

			//Initulize:
			CanPlay = true;
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/ravenholm/madlaugh04.wav");

			//Initulize:
			CanPlay = true;
		}
	}
	//Get Name:
	if(StrEqual(Text, "haha"))
	{

		//Is Female:
		if(StrContains(Model, "female", false) != -1)
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/eli_lab/al_laugh02.wav");

			//Initulize:
			CanPlay = true;
		}

		//Override:
		else
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/npc/barney/ba_laugh02.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "laugh"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/ravenholm/madlaugh03.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "quickly"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/ravenholm/monk_quicklybro.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "knock knock"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/trainyard/cit_drunk.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "allright"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/trainyard/cit_lug_allright.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "too loud"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/trainyard/cit_tooloud.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "me"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/trainyard/man_me.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "wait a minute"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/trainyard/man_waitaminute.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "sure"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/eli_lab/al_gravgun.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "hum"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/eli_lab/al_hums.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "have fun"))
	{

		//Format:
		Format(Sound, sizeof(Sound), "vo/eli_lab/al_havefun.wav");

		//Initulize:
		CanPlay = true;
	}

	//Get Name:
	if(StrEqual(Text, "gman"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/gman.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/gman_misc/gman_03.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "gman1"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/gman.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/gman_misc/gman_02.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "gman2"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/gman.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/gman_misc/gman_01.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "oh shit"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/breen.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/citadel/br_ohshit.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "well done"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/monk.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/ravenholm/firetrap_welldone.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "trubling"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/Kleiner.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/k_lab2/kl_atthecitadel01.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "dog come"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/alyx.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/eli_lab/al_dogcome.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "earned it"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/alyx.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/eli_lab/al_earnedit.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Get Name:
	if(StrEqual(Text, "give it a try"))
	{

		//Is Valid;
		if(StrEqual(Model, "models/alyx.mdl"))
		{

			//Format:
			Format(Sound, sizeof(Sound), "vo/eli_lab/al_giveittry.wav");

			//Initulize:
			CanPlay = true;
		}
	}

	//Is Valid:
	if(CanPlay)
	{

		//Declare:
		new Float:ClientOrigin[3];

		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);

		//Is Precached:
		if(IsSoundPrecached(Sound)) PrecacheSound(Sound);

		//Play Sound:
		EmitAmbientSound(Sound, ClientOrigin, Client, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN);

		//Initulize:
		CanSay[Client] = GetGameTime();

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Say|\x07FFFFFF - said a Sound!");
	}

	//Return:
	return CanPlay;
}

public Action:OnClientHurtSound(Client)
{

	//Declare:
	decl String:FormatSound[256]; new Random, Float:ClientOrigin[3];

	//Is Police:
	if(IsCop(Client))
	{

		//Initialize:
		Random = GetRandomInt(1, 4);

		//Format:
		Format(FormatSound, 128, "npc/metropolice/pain%d.wav", Random);
	}

	//Is First Class:
	if(StrContains(GetModel(Client), "combine", false) != -1)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(FormatSound, 128, "npc/combine_soldier/pain%d.wav", Random);
	}

	//Is Female:
	if(StrContains(GetModel(Client), "female", false) != -1)
	{

		//Initialize:
		Random = GetRandomInt(1, 3);

		//Format:
		Format(FormatSound, 128, "vo/npc/female01/moan0%d.wav", Random);
	}

	//Override:
	else
	{

		//Initialize:
		Random = GetRandomInt(1, 5);

		//Format:
		Format(FormatSound, 128, "vo/npc/male01/moan0%d.wav", Random);
	}

	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);

	//Is Precached:
	if(IsSoundPrecached(FormatSound))
	{

		//Precache:
		PrecacheSound(FormatSound);
	}

	//Play Sound:
	EmitAmbientSound(FormatSound, ClientOrigin, SOUND_FROM_PLAYER, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.8, SNDPITCH_NORMAL, 0.0);
}