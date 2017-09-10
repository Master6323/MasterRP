//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_hats_included_
  #endinput
#endif
#define _rp_hats_included_

//Hats:
static PlayerHat[MAXPLAYERS + 1] = {-1,...};
static String:HatModel[MAXPLAYERS + 1][255];

initHats()
{

	//Commands:
	RegConsoleCmd("sm_hatmenu", Command_HatMenu);

	//Loop:
	for(new i = 1; i <= GetMaxClients(); i++)
	{

		//Initulize:
		PlayerHat[i] = -1;

		HatModel[i] = "null";
	}
}

public Action:OnClientDiedThrowPhysHat(Client, Ent)
{

	//Is Valid:
	if(IsValidEntity(Ent))
	{

		//Declare:
		decl String:ModelName[128];

		//Initialize:
		GetEntPropString(Ent, Prop_Data, "m_ModelName", ModelName, 128);

		//Declare:
		new Float:Origin[3];

		//Get Prop Data:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Origin);

		//Declare:
		new Float:Angels[3];

		//Initulize:
		GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angels);

		//Declare:
		new Float:velocity[3];

		//Initulize:
		GetEntPropVector(Client, Prop_Send, "m_vecBaseVelocity", velocity);

		//Declare:
		new Ent2 = CreateEntityByName("prop_physics_override");

		//Is Ent
		if(IsValidEntity(Ent2))
		{

			//Values:
			DispatchKeyValue(Ent2, "model", ModelName);

			//Spawn:
			DispatchSpawn(Ent2);

			//Declare:
			new Collision = GetEntSendPropOffs(Ent2, "m_CollisionGroup");

			//Set End Data:
			SetEntData(Ent2, Collision, 1, 1, true);

			//Teleport:
		   	TeleportEntity(Ent2, Origin, Angels, velocity);
		}

		//Accept Entity Input:
		AcceptEntityInput(Ent, "Kill");
	}

	//Initulize:
	SetPlayerHatEnt(Client, -1);
}

//Spawn Timer:
public Action:RemovePlayerHatAfterDeath(Handle:Timer, any:Ent)
{

	//Is Valid:
	if(IsValidEdict(Ent))
	{

		//Accept Entity Input:
		AcceptEntityInput(Ent, "Kill");

	}
}

public CreateHat(Client, String:Model[255])
{

	//Is Valid:
	if(IsValidEdict(GetPlayerHatEnt(Client)))
	{

		//Accept Entity Input:
		AcceptEntityInput(GetPlayerHatEnt(Client), "Kill");
	}

	//Declare:
	new iModel = CreateEntityByName("prop_dynamic_override");
	//prop_dynamic_ornament

	//Is Valid:
	if(IsValidEdict(iModel))
	{

		//Is PreCached:
		if(!IsModelPrecached(Model)) PrecacheModel(Model);

		//Dispatch:
		DispatchKeyValue(iModel, "model", Model);

		DispatchKeyValue(iModel, "solid", "0");

		//Set Owner
		SetEntPropEnt(iModel, Prop_Send, "m_hOwnerEntity", Client);

		//Spawn:
		DispatchSpawn(iModel);

		//Declare:
		decl String:Name[32];

		//Format:
		Format(Name, sizeof(Name), "PlayerHat_%i", Client);

		//Dispatch:
		DispatchKeyValue(iModel, "targetname", Name);

		//Accept:
		AcceptEntityInput(iModel, "TurnOn", Client, Client, 0);

		//Declare:
		decl Float:Pos[3], Float:Offset[3], Float:Angle[3];

		//Initulize:
		GetEntPropVector(iModel, Prop_Send, "m_vecOrigin", Pos);

		//Get Data:
		GetHatOffset(Offset, Angle, Model);

		//Match:
		Pos[2] += Offset[2];
		Pos[0] += Offset[0];
		Pos[1] += Offset[1];

		//Teleport:
		TeleportEntity(iModel, Pos, Angle, NULL_VECTOR);

		//SDKHOOK:
		SDKHook(iModel, SDKHook_SetTransmit, OnShouldDisplay);

		//Initulize:
		SetPlayerHatEnt(Client, iModel);

		//Set String:
		SetVariantString("!activator");

		//Accept:
		AcceptEntityInput(iModel, "SetParent", Client, iModel, 0);

		//Attach:
		SetVariantString("Eyes");

		//Accept:
		AcceptEntityInput(iModel, "SetParentAttachment", iModel , iModel, 0);

		//Return:
		return iModel;
	}

	//Return:
	return -1;
}

public Action:GetHatOffset(Float:Offset[3], Float:Angle[3], String:Model[255])
{

	//Match:
	Angle[2] = 0.0;
	Angle[0] = 0.0;
	Angle[1] = 0.0;

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/sawblade001a.mdl"))
	{

		//Match:
		Offset[2] = 3.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_combine/combine_mine01.mdl"))
	{

		//Match:
		Offset[2] = 2.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_c17/tv_monitor01.mdl"))
	{

		//Match:
		Offset[2] = 1.0;
		Offset[0] = -5.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_c17/lampshade001a.mdl"))
	{

		//Match:
		Offset[2] = 1.0;
		Offset[0] = -4.5;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/headcrabclassic.mdl"))
	{

		//Match:
		Offset[2] = 3.0;
		Offset[0] = 2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/monitor01a.mdl"))
	{

		//Match:
		Offset[2] = 2.0;
		Offset[0] = 1.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/trafficcone001a.mdl"))
	{

		//Match:
		Offset[2] = 14.0;
		Offset[0] = -4.5;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/gmod_tower/headcrabhat.mdl"))
	{

		//Match:
		Offset[2] = 5.5;
		Offset[0] = -3.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_junk/watermelon01.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/bewaredog.mdl"))
	{

		//Match:
		Offset[2] = -7.0;
		Offset[0] = -4.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/props_lab/labpart.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = 0.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/barneyhelmet_faceplate.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = -2.0;
		Offset[1] = 0.0;
	}

	//Set Offset:
	if(StrEqual(Model, "models/barneyhelmet.mdl"))
	{

		//Match:
		Offset[2] = 0.0;
		Offset[0] = -2.0;
		Offset[1] = 0.0;
	}
}

public Action:Command_HatMenu(Client, Args)
{

	//Is Colsole:
	if(Client == 0)
	{

		//Print:
		PrintToServer("|RP| - This command can only be used ingame.");

		//Return:
		return Plugin_Handled;
	}

	//Is Colsole:
	if(!IsAdmin(Client) && GetDonator(Client) == 0)
	{

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF - Sorry but you dont have access to this menu!");

		//Return:
		return Plugin_Handled;
	}

	//Show Menu:
	DrawHatMenu(Client);

	//Return:
	return Plugin_Handled;
}

public Action:DrawHatMenu(Client)
{

	//Declare:
	decl String:display[32];

	//Handle:
	new Handle:Menu = CreateMenu(HandleHatMenu);

	//Menu Title:
	SetMenuTitle(Menu, "What had would you like to put on?");

	//Format:
	Format(display, sizeof(display), "Sawblade");

	//Menu Button:
	AddMenuItem(Menu, "models/props_junk/sawblade001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Combine Mine");

	//Menu Button:
	AddMenuItem(Menu, "models/props_combine/combine_mine01.mdl", display);

	//Format:
	Format(display, sizeof(display), "TV Monitor");

	//Menu Button:
	AddMenuItem(Menu, "models/props_c17/tv_monitor01.mdl", display);

	//Format:
	Format(display, sizeof(display), "lamp Shade");

	//Menu Button:
	AddMenuItem(Menu, "models/props_c17/lampshade001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "HeadCrab");

	//Menu Button:
	AddMenuItem(Menu, "models/headcrabclassic.mdl", display);

	//Format:
	Format(display, sizeof(display), "Monitor");

	//Menu Button:
	AddMenuItem(Menu, "models/props_lab/monitor01a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Traffic cone");

	//Menu Button:
	AddMenuItem(Menu, "models/props_junk/trafficcone001a.mdl", display);

	//Format:
	Format(display, sizeof(display), "Water melon");

	//Menu Button:
	AddMenuItem(Menu, "models/props_junk/watermelon01.mdl", display);

	//Format:
	Format(display, sizeof(display), "Beware of dog");

	//Menu Button:
	AddMenuItem(Menu, "models/props_lab/bewaredog.mdl", display);

	//Format:
	Format(display, sizeof(display), "Lab Part");

	//Menu Button:
	AddMenuItem(Menu, "models/props_lab/labpart.mdl", display);

	//Format:
	Format(display, sizeof(display), "Police Hat");

	//Menu Button:
	AddMenuItem(Menu, "models/barneyhelmet_faceplate.mdl", display);

	//Format:
	Format(display, sizeof(display), "Barney Hat");

	//Menu Button:
	AddMenuItem(Menu, "models/barneyhelmet.mdl", display);

	//Set Exit Button:
	SetMenuExitButton(Menu, false);

	//Set Menu Buttons:
	SetMenuPagination(Menu, 7);

	//Show Menu:
	DisplayMenu(Menu, Client, 30);

	//Print:
	OverflowMessage(Client, "\x07FF4040|RP-Hat|\x07FFFFFF - Press \x0732CD32'escape'\x07FFFFFF for a menu!");
}

//PlayerMenu Handle:
public HandleHatMenu(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{

	//Selected:
	if(HandleAction == MenuAction_Select)
	{

		//Connected
		if(Client > 0 && IsClientInGame(Client) && IsClientConnected(Client))
		{

			//Declare:
			decl String:info[255], String:display[255];

			//Get Menu Info:
			GetMenuItem(Menu, Parameter, info, sizeof(info), _, display, sizeof(display));

			//Set Model:
			if(StrEqual(info, HatModel[Client]))
			{

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - This hat is already on your head!");
			}

			//Override:
			else
			{

				//Save In DB:
				SaveHatModel(Client, info);

				//Create Hat:
				CreateHat(Client, info);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - Your new hat is a \x0732CD32%s!", display);
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

public Action:OnShouldDisplay(ent, Client)
{

	//Connected:
	if(ent > 0 && IsValidEdict(ent) && IsClientConnected(Client) && IsClientInGame(Client))
	{

		if(GetObserverMode(Client) == 5)
			return Plugin_Continue;

		if(GetObserverMode(Client) == 4 && GetObserverTarget(Client) >= 0)
				if(ent == PlayerHat[GetObserverTarget(Client)])
					return Plugin_Handled;

		if(ent == PlayerHat[Client])
			return Plugin_Handled;
	}

	//Return:
	return Plugin_Continue;
}

public Action:SaveHatModel(Client, String:info[255])
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "%s", info);

	//Declare:
	decl String:query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", info, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

String:GetHatModel(Client)
{

	//Return:
	return HatModel[Client];
}

public Action:SetHatModel(Client, String:info[255])
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "%s", info);

	//Declare:
	decl String:query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", info, SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}


public Action:RemoveHatModel(Client)
{

	//Format:
	Format(HatModel[Client], sizeof(HatModel[]), "null");

	//Declare:
	decl String:query[512];

	//Sql Strings:
	Format(query, sizeof(query), "UPDATE LastStats SET Hat = '%s' WHERE STEAMID = %i;", "null", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public GetPlayerHatEnt(Client)
{

	//Return:
	return PlayerHat[Client];
}

public SetPlayerHatEnt(Client, Ent)
{

	//Initulize:
	PlayerHat[Client] = Ent;
}
