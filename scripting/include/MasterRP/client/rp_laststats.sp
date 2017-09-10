//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_laststats_included_
  #endinput
#endif
#define _rp_laststats_included_

initLastStats()
{

	//Timer:
	CreateTimer(0.2, CreateSQLdbLastStats);
}

//Create Database:
public Action:CreateSQLdbLastStats(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `LastStats`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` init(11) NOT NULL, `LastPosition` varchar(64) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Health` int(5) NULL, `Armor` int(5) NOT NULL,");

	len += Format(query[len], sizeof(query)-len, " `Model` varchar(128) NULL, `Hat` varchar(128) NULL);");

	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public Action:DBLoadLastStats(Client)
{

	//Declare:
	decl String:query[255];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `LastStats` WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadLastStats, query, conuserid);
}

public T_DBLoadLastStats(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_settings] T_DBLoadPosition: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading player Last Stats...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Add Player To DB:
			InsertLastStats(Client);
		}

		//Database Row Loading INTEGER:
		else if(SQL_FetchRow(hndl))
		{


			//Declare:
			decl String:Dump[255], String:Buffer[6][32]; new Float:LastPosition[3];

			//Database Field Loading String:
			SQL_FetchString(hndl, 1, Dump, sizeof(Dump));

			//Convert:
			ExplodeString(Dump, "^", Buffer, 3, 32);

			//Loop:
			for(new X = 0; X <= 2; X++)
			{

				//Initulize:
				LastPosition[X] = StringToFloat(Buffer[X]);
			}

			//Teleport:
    			TeleportEntity(Client, LastPosition, NULL_VECTOR, NULL_VECTOR);

			//Database Field Loading INTEGER:
			new Health = SQL_FetchInt(hndl, 2);

			//Database Field Loading INTEGER:
			new Armor = SQL_FetchInt(hndl, 3);

			//Set Health:
			SetEntityHealth(Client, Health);

			//Set Armor:
			SetEntityArmor(Client, Armor);

			//Database Field Loading String:
			//SQL_FetchString(hndl, 4, Dump, sizeof(Dump));

			//Database Field Loading String:
			SQL_FetchString(hndl, 5, Dump, sizeof(Dump));

			//Set Hat:
			SetHatModel(Client, Dump);

			//Added Spawn Effect:
			InitSpawnEffect(Client);

			//Check:
			if(!StrEqual(GetHatModel(Client), "null"))
			{

				//Create Hat:
				CreateHat(Client, GetHatModel(Client));
			}

			//Masters root:
			if(SteamIdToInt(Client) == 30027290)
			{

				//Added Effect:
				new Effect = CreateLight(Client, 1, 255, 255, 120, "null");

				SetEntAttatchedEffect(Client, 9, Effect);

				Effect = CreateFireSmoke(Client, "Eyes", "200", "700", "0", "Natural");

				SetEntAttatchedEffect(Client, 8, Effect);

				Effect = CreateEnvSmokeTrail(Client, "null", "materials/effects/fire_cloud1.vmt", "200.0", "100.0", "50.0", "50", "30", "50", "100", "0", "255 50 50", "5");

				SetEntAttatchedEffect(Client, 7, Effect);
			}

			//Declare:
			new Ent = HasClientWeapon(Client, "weapon_physcannon", 0);

			//Check:
			if(Ent > 0)
			{

				//Declare:
				decl String:ClassName[32];

				//Get Entity Info:
				GetEdictClassname(Ent, ClassName, sizeof(ClassName));

				//Valid Check:
				if(StrContains(ClassName, "weapon_physcannon", false) != -1)
				{

					//Add Extra Slots:
					if(GetItemAmount(Client, 306) > 0)
					{

						//Set Color:
						SetEntityRenderColor(Ent, 100, 100, 255, 255);

						SetEntityRenderMode(Ent, RENDER_GLOW);
					}
				}

				//Print:
				PrintToConsole(Client, "|RP| Player Last Stats Loaded");
			}
		}
	}
}

public Action:InsertLastStats(Client)
{

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "INSERT INTO LastStats (`STEAMID`,`LastPosition`,`Health`,`Armor`,`Model`,`Hat`) VALUES (%i,'%s',100,0,'%s','%s');", SteamIdToInt(Client), "0.0^0.0^0.0", "null", "null");

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);

	//CPrint:
	PrintToConsole(Client, "|RP| Created new player Last Stats.");

	//Respawn to prevent non spawn:
	InitSpawnPos(Client, 1);
}

public Action:UpdateLastStats(Client)
{

	//Spam Check:
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{

		//Declare:
		new Float:Position[3];

		//Initialize:
		GetClientAbsOrigin(Client, Position);

		//Declare:
		decl String:FormatOrg[255], String:query[255];

		//Format:
		Format(FormatOrg, sizeof(FormatOrg), "%f^%f^%f", Position[0], Position[1], Position[2]);

		//Format:
		Format(query, sizeof(query), "UPDATE LastStats SET LastPosition = '%s' WHERE STEAMID = %i;", FormatOrg, SteamIdToInt(Client));

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Is Alive:
		if(IsPlayerAlive(Client))
		{

			//Format:
			Format(query, sizeof(query), "UPDATE LastStats SET Health = %i, Armor = %i WHERE STEAMID = %i;", GetClientHealth(Client), GetClientArmor(Client), SteamIdToInt(Client));

			//Not Created Tables:
			SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
		}
	}
}