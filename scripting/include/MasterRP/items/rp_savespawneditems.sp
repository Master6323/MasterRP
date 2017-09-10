//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_savespawneditems_included_
  #endinput
#endif
#define _rp_savespawneditems_included_

#define MAXSPAWNEDITEMS		10

initSpawnedItems()
{

	//Timer:
	CreateTimer(4.0, CreateSQLdbSpawnedItems);
}

PrecacheItems()
{

	//PreCache Model:
	PrecacheModel("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");

	PrecacheModel("models/katharsmodels/contraband/metasync/blue_sky.mdl");

	PrecacheModel("models/srcocainelab/ziplockedcocaine.mdl");

	PrecacheModel("models/cocn.mdl");

	PrecacheModel("models/props_trainstation/payphone001a.mdl");

	PrecacheModel("models/props_lab/cactus.mdl");

	PrecacheModel("models/money/broncoin.mdl");

	PrecacheModel("models/money/silvcoin.mdl");

	PrecacheModel("models/money/goldcoin.mdl");

	PrecacheModel("models/money/note3.mdl");

	PrecacheModel("models/money/note2.mdl");

	PrecacheModel("models/money/note1.mdl");

	PrecacheModel("models/money/goldbar.mdl");

	PrecacheModel("models/props_c17/consolebox01a.mdl");

	PrecacheModel("models/props_lab/reciever01a.mdl");

	PrecacheModel("models/props_lab/monitor01b.mdl");

	PrecacheModel("models/props_c17/doll01.mdl");

	PrecacheModel("models/pot/pot.mdl");

	PrecacheModel("models/pot/pot_stage2.mdl");

	PrecacheModel("models/pot/pot_stage3.mdl");

	PrecacheModel("models/pot/pot_stage4.mdl");

	PrecacheModel("models/pot/pot_stage5.mdl");

	PrecacheModel("models/pot/pot_stage6.mdl");

	PrecacheModel("models/pot/pot_stage7.mdl");

	PrecacheModel("models/pot/pot_stage8.mdl");

	PrecacheModel("models/props_citizen_tech/firetrap_propanecanister01a.mdl");

	PrecacheModel("models/props_industrial/gascanister02.mdl");

	PrecacheModel("models/props_industrial/gascanister01.mdl");

	PrecacheModel("models/john/euromoney.mdl");

	PrecacheModel("models/winningrook/gtav/meth/acetone/acetone.mdl");

	PrecacheModel("models/winningrook/gtav/meth/ammonia/ammonia.mdl");

	PrecacheModel("models/winningrook/gtav/meth/hcacid/hcacid.mdl");

	PrecacheModel("models/winningrook/gtav/meth/lithium_battery/lithium_battery.mdl");

	PrecacheModel("models/winningrook/gtav/meth/phosphoru/phosphoru.mdl");

	PrecacheModel("models/winningrook/gtav/meth/sacid/sacid.mdl");

	PrecacheModel("models/winningrook/gtav/meth/sodium/sodium.mdl");

	PrecacheModel("models/winningrook/gtav/meth/toulene/toulene.mdl");

	PrecacheModel("models/props_interiors/furniture_lamp01a.mdl");

	PrecacheModel("models/props_combine/combine_light001a.mdl");

	PrecacheModel("models/props_junk/glassjug01.mdl");

	PrecacheModel("models/generator/generator_base.mdl");

	PrecacheModel("models/azok30_compresseur_air/azok30_compresseur_air.mdl");

	PrecacheModel("models/props_lab/jar01a.mdl");

	PrecacheModel("models/props_lab/jar01b.mdl");

	PrecacheModel("models/striker/nicebongstriker.mdl");

	PrecacheModel("models/advisor.mdl");

	PrecacheModel("models/advisor_ragdoll.mdl");

	PrecacheModel("models/synth.mdl");

	PrecacheModel("models/props_combine/breenpod_inner.mdl");

	PrecacheModel("models/blodia/buggy.mdl");

	PrecacheModel("models/buggy.mdl");

	PrecacheModel("models/combine_apc.mdl");

	//PreCache Sound:
	PrecacheSound("buttons/lightswitch2.wav");

	PrecacheSound("npc/turret_floor/ping.wav");

	PrecacheSound("music/jihad.wav");

	PrecacheSound("buttons/button2.wav");

	PrecacheSound("buttons/button3.wav");

	PrecacheSound("ambient/machines/engine1.wav");

	PrecacheSound("ambient/explosions/explode_5.wav");

}

//Create Database:
public Action:CreateSQLdbSpawnedItems(Handle:Timer)
{

	//Declare:
	new len = 0;
	decl String:query[512];

	//Sql String:
	len += Format(query[len], sizeof(query)-len, "CREATE TABLE IF NOT EXISTS `SpawnedItems`");

	len += Format(query[len], sizeof(query)-len, " (`STEAMID` int(11) NULL, `ItemType` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemId` int(12) NULL, `ItemTime` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `ItemValue` int(12) NULL, `IsSpecialItem` int(12) NULL,");

	len += Format(query[len], sizeof(query)-len, " `AddedData` varchar(64) NULL,");

	len += Format(query[len], sizeof(query)-len, " `Position` varchar(64) NULL, `Angle` varchar(64) NULL);");


	//Thread query:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
}

public DBLoadSpawnedItems(Client)
{
	//Declare:
	decl String:query[255];

	//Declare:
	new conuserid = GetClientUserId(Client);

	//Format:
	Format(query, sizeof(query), "SELECT * FROM SpawnedItems WHERE STEAMID = %i;", SteamIdToInt(Client));

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), T_DBLoadSpawnedItems, query, conuserid);
}

public T_DBLoadSpawnedItems(Handle:owner, Handle:hndl, const String:error[], any:data)
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
		LogError("[rp_Core_Player] T_DBLoadSpawnedItems: Query failed! %s", error);
#endif
	}

	//Override:
	else 
	{

		//Print:
		PrintToConsole(Client, "|RP| Loading Spawned Items...");

		//Not Player:
		if(!SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| No Spawned Items Detected!");
		}

		//Not Player:
		if(SQL_GetRowCount(hndl))
		{

			//Print:
			PrintToConsole(Client, "|RP| Spawned Items Detected!");
		}


		//Declare:
		new SpawnId, Type, ItemTime, ItemValue, IsSpecialItem, Float:Position[3], Float:Angle[3]; decl String:Buffer[64], String:AddedItemData[64], String:Dump[3][64];

		//Database Row Loading INTEGER:
		while(SQL_FetchRow(hndl))
		{

			//Database Field Loading Intiger:
			Type = SQL_FetchInt(hndl, 1);

			//Database Field Loading Intiger:
			SpawnId = SQL_FetchInt(hndl, 2);

			//Database Field Loading Intiger:
			ItemTime = SQL_FetchInt(hndl, 3);

			//Database Field Loading Intiger:
			ItemValue = SQL_FetchInt(hndl, 4);

			//Database Field Loading Intiger:
			IsSpecialItem = SQL_FetchInt(hndl, 5);

			//Database Field Loading String:
			SQL_FetchString(hndl, 6, AddedItemData, 64);

			//Database Field Loading String:
			SQL_FetchString(hndl, 7, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 3, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Position[Y] = StringToFloat(Dump[Y]);
			}

			//Database Field Loading String:
			SQL_FetchString(hndl, 8, Buffer, 64);

			//Convert:
			ExplodeString(Buffer, "^", Dump, 4, 64);

			//Loop:
			for(new Y = 0; Y <= 2; Y++)
			{

				//Initulize:
				Angle[Y] = StringToFloat(Dump[Y]);
			}

			//Initulize:
			Position[2] += 5;

			//Check:
			if(Type == 1)
			{

				//Convert:
				ExplodeString(AddedItemData, "^", Dump, 3, 64);

				//Initulize:
				new Float:WaterLevel = StringToFloat(Dump[0]);

				new Float:Grams = StringToFloat(Dump[1]);

				new Health = StringToInt(Dump[2]);

				//Spawn Drug Plant:
				CreatePlant(Client, SpawnId, ItemTime, Grams, WaterLevel, ItemValue, IsSpecialItem, Health, Position, Angle, true);
			}

			//Check:
			else if(Type == 2)
			{

				//Convert:
				ExplodeString(AddedItemData, "^", Dump, 2, 64);

				//Initulize:
				new Float:Ink = StringToFloat(Dump[0]);

				new Health = StringToInt(Dump[1]);

				//Spawn Printer:
				CreatePrinter(Client, SpawnId, ItemTime, Ink, ItemValue, IsSpecialItem, Health, Position, Angle, true);
			}

			//Check:
			else if(Type == 3)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Meth Kitchen:
				CreateMeth(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 4)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Pills Kitchen:
				CreatePills(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 5)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Meth Kitchen:
				CreateCocain(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 6)
			{

				//Spawn Rice Plant:
				CreateRice(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 7)
			{

				//Spawn Bomb:
				CreateBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 8)
			{

				//Spawn Gun Lab:
				CreateGunLab(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 9)
			{

				//Spawn Gun Lab:
				CreateMicrowave(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 10)
			{

				//Spawn Shield:
				CreateShield(Client, SpawnId, ItemTime, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 11)
			{

				//Spawn Microwave:
				CreateFireBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 12)
			{

				//Declare:
				new Float:Energy = float(ItemTime);

				new Float:Fuel = float(ItemValue);

				//Initulize:
				new Level = StringToInt(AddedItemData);

				//Spawn Generator:
				CreateGenerator(Client, SpawnId, Energy, Fuel, Level, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 13)
			{

				//Initulize:
				new Float:Coin = StringToFloat(AddedItemData);

				//Spawn BitCoin Mine:
				CreateBitCoinMine(Client, SpawnId, Coin, ItemValue, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 14)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn Propane Tank:
				CreatePropaneTank(Client, SpawnId, Fuel, ItemValue, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 15)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn Phosphoru Tank:
				CreatePhosphoruTank(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 16)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Sodium Tub Tank:
				CreateSodiumTub(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 17)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn HcAcid Tub Tank:
				CreateHcAcidTub(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 18)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Acetone Can:
				CreateAcetoneCan(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 19)
			{

				//Spawn Seeds:
				CreateSeeds(Client, SpawnId, ItemValue, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 20)
			{

				//Spawn Lamp:
				CreateLamp(Client, SpawnId, ItemValue, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 21)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn Erythroxylum:
				CreateErythroxylum(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 22)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn Benzocaine:
				CreateBenzocaine(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 23)
			{

				//Initulize:
				new Float:Energy = StringToFloat(AddedItemData);

				//Spawn Battery:
				CreateBattery(Client, SpawnId, Energy, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 24)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn Toulene:
				CreateToulene(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 25)
			{

				//Initulize:
				new Float:Fuel = StringToFloat(AddedItemData);

				//Spawn SAcidTub:
				CreateSAcidTub(Client, SpawnId, Fuel, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 26)
			{

				//Initulize:
				new Float:Grams = StringToFloat(AddedItemData);

				//Spawn SAcidTub:
				CreateAmmonia(Client, SpawnId, Grams, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 27)
			{

				//Spawn Bong:
				CreateBong(Client, SpawnId, IsSpecialItem, Position, Angle, true);
			}

			//Check:
			else if(Type == 28)
			{

				//Spawn Smoke Bomb:
				CreateSmokeBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 29)
			{

				//Spawn Smoke Bomb:
				CreateSmokeBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Check:
			else if(Type == 30)
			{

				//Spawn Smoke Bomb:
				CreateSmokeBomb(Client, SpawnId, ItemTime, ItemValue, Position, Angle, true);
			}

			//Override
			else
			{

				//Print:
				PrintToConsole(Client, "|RP| - Failed To spawn Item, Id - %i Type - %i", SpawnId, Type);
			} 
		}
	}
}

public InsertSpawnedItem(Client, Type, Id, Time, Value, Special, String:AddedData[], Float:Position[3], Float:Angle[3])
{

	//Declare:
	decl String:query[512];

	//Format:
	Format(query, sizeof(query), "SELECT * FROM `SpawnedItems` WHERE STEAMID = %i AND ItemType = %i AND ItemId = %i;", SteamIdToInt(Client), Id, Type);

	//Declare:
	new Handle:hDatabase = SQL_Query(GetGlobalSQL(), query);

	//Is Valid Query:
	if(hDatabase)
	{

		//Declare:
		decl String:Pos[64], String:Ang[64];

		//Sql String:
		Format(Pos, sizeof(Pos), "%f^%f^%f", Position[0], Position[1], Position[2]);

		//Sql String:
		Format(Ang, sizeof(Ang), "%f^%f^%f", Angle[0], Angle[1], Angle[2]);

		//Restart SQL:
		SQL_Rewind(hDatabase);

		//Declare:
		new bool:fetch = SQL_FetchRow(hDatabase);

		//Already Inserted:
		if(fetch)
		{

			//Format:
			Format(query, sizeof(query), "UPDATE SpawnedItems SET ItemTime = %i, ItemValue = %i, IsSpecialItem = %i, AddedData = '%s', Position = '%s', Angle = '%s' WHERE STEAMID = %i AND ItemId = %i AND ItemType = %i;", Time, Value, Special, AddedData, Pos, Ang, SteamIdToInt(Client), Id, Type);
		}

		//Override:
		else
		{

			//Format:
			Format(query, sizeof(query), "INSERT INTO SpawnedItems (`STEAMID`,`ItemType`,`ItemId`,`ItemTime`,`ItemValue`,`IsSpecialItem`,`AddedData`,`Position`,`Angle`) VALUES (%i,%i,%i,%i,%i,%i,'%s','%s','%s');", SteamIdToInt(Client), Type, Id, Time, Value, Special, AddedData, Pos, Ang);
		}

		//Not Created Tables:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);
	}

	//Close:
	CloseHandle(hDatabase);
}
public RemoveSpawnedItem(Client, Type, Id)
{

	//Declare:
	decl String:buffer[255];

	//Sql String:
	Format(buffer, sizeof(buffer), "DELETE FROM SpawnedItems WHERE STEAMID = %i AND ItemType = %i AND ItemId = %i;", SteamIdToInt(Client), Type, Id);

	//Not Created Tables:
	SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, buffer);
}

public SaveSpawnedItemForward(Client, bool:Disconnect)
{

	//Declare:
	new Ent = 1;

	//Loop:
	for(new X = 1; X <= MAXSPAWNEDITEMS; X++)
	{

		//Initulize:
		Ent = HasClientPlant(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f^%f^%i", GetPlantWaterLevel(Client, X), GetPlantGrams(Client, X), GetPlantHealth(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 1, X, GetPlantTime(Client, X), GetIsPlanted(Client, X), GetPlantType(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPrinter(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f^%i", GetPrinterInk(Client, X), GetPrinterHealth(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 2, X, GetPrinterMoney(Client, X), GetPrinterPaper(Client, X), GetPrinterLevel(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientMeth(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetMethGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 3, X, 0, 0, GetMethHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPills(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPillsGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 4, X, 0, 0, GetPillsHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientCocain(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetCocainGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 5, X, 0, 0, GetCocainHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientRice(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 6, X, GetRiceTime(Client, X), GetRiceValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 7, X, GetBombUse(Client, X), GetBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientGunLab(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 8, X, GetGunLabTime(Client, X), GetGunLabUse(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientMicrowave(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 9, X, GetMicrowaveTime(Client, X), GetMicrowaveValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientShield(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 10, X, GetShieldTime(Client, X), GetShieldValue(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientFireBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 11, X, GetFireBombUse(Client, X), GetFireBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientGenerator(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{
			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%i", GetGeneratorLevel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 12, X, RoundFloat(GetGeneratorEnergy(Client, X)), RoundFloat(GetGeneratorFuel(Client, X)), GetGeneratorHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBitCoinMine(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBitCoinMine(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 13, X, 0, GetBitCoinMineLevel(Client, X), GetGeneratorHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPropaneTank(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPropaneTankFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 14, X, 0, GetPropaneTankLevel(Client, X), GetPropaneTankHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientPhosphoruTank(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetPhosphoruTankFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 15, X, 0, 0, GetPhosphoruTankHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientSodiumTub(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetSodiumTubGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 16, X, 0, 0, GetSodiumTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientHcAcidTub(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetHcAcidTubFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 17, X, 0, 0, GetHcAcidTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAcetoneCan(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetAcetoneCanGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 18, X, 0, 0, GetAcetoneCanHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAcetoneCan(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 19, X, 0, GetSeedsType(Client, X), GetSeedsHealth(Client, X), "");
		}

		//Initulize:
		Ent = HasClientLamp(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 20, X, 0, 0, GetLampHealth(Client, X), "");
		}

		//Initulize:
		Ent = HasClientErythroxylum(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetErythroxylumFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 21, X, 0, 0, GetErythroxylumHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBenzocaine(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBenzocaineGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 22, X, 0, 0, GetBenzocaineHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBattery(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetBatteryEnergy(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 23, X, 0, 0, GetBatteryHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientToulene(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetTouleneFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 24, X, 0, 0, GetTouleneHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientToulene(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetSAcidTubFuel(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 25, X, 0, 0, GetSAcidTubHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientAmmonia(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Declare:
			new String:AddedData[64];

			//Format:
			Format(AddedData, sizeof(AddedData), "%f", GetAmmoniaGrams(Client, X));

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 26, X, 0, 0, GetAmmoniaHealth(Client, X), AddedData);
		}

		//Initulize:
		Ent = HasClientBong(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 27, X, 0, 0, GetBongHealth(Client, X), "");
		}

		//Initulize:
		Ent = HasClientSmokeBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 28, X, GetSmokeBombUse(Client, X), GetSmokeBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientWaterBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 29, X, GetWaterBombUse(Client, X), GetWaterBombExplode(Client, X), 0, "");
		}

		//Initulize:
		Ent = HasClientPlasmaBomb(Client, X);

		//Check:
		if(IsValidEdict(Ent))
		{

			//Update:
			UpdateSpawnedItem(Client, Ent, Disconnect, 30, X, GetPlasmaBombUse(Client, X), GetPlasmaBombExplode(Client, X), 0, "");
		}
	}
}

//Saves the Ownership of an Item
public UpdateSpawnedItem(Client, Ent, bool:Disconnect, Type, Id, Time, Value, ExtraValue, String:AddedData[])
{

	//Connected:
	if(IsClientConnected(Client))
	{

		//Declare:
		decl String:query[512], String:Pos[64], String:Ang[64]; new Float:Position[3], Float:Angle[3];

		//Get Prop Data:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);

		GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angle);

		//Sql String:
		Format(Pos, sizeof(Pos), "%f^%f^%f", Position[0], Position[1], Position[2]);

		Format(Ang, sizeof(Ang), "%f^%f^%f", Angle[0], Angle[1], Angle[2]);

		//Sql Strings:
		Format(query, sizeof(query), "UPDATE SpawnedItems SET ItemTime = %i, ItemValue = %i, IsSpecialItem = %i, AddedData = '%s', Position = '%s', Angle = '%s' WHERE STEAMID = %i AND ItemId = %i AND ItemType = %i;", Time, Value, ExtraValue, AddedData, Pos, Ang, SteamIdToInt(Client), Id, Type);

		//Send Query:
		SQL_TQuery(GetGlobalSQL(), SQLErrorCheckCallback, query);

		//Remove if Disconnected:
		if(Disconnect == true)
		{

			//Check:
			switch(Type)
			{

				//Check:
				case 1:
				{

					//Remove:
					RemovePlant(Client, Id);
				}

				//Check:
				case 2:
				{

					//Remove:
					RemovePrinter(Client, Id, false);
				}

				//Check:
				case 3:
				{

					//Remove:
					RemoveMeth(Client, Id);
				}

				//Check:
				case 4:
				{

					//Remove:
					RemovePills(Client, Id);
				}

				//Check:
				case 5:
				{

					//Remove:
					RemoveCocain(Client, Id);
				}

				//Check:
				case 6:
				{

					//Remove:
					RemoveRice(Client, Id);
				}

				//Check:
				case 7:
				{

					//Remove:
					RemoveBomb(Client, Id, false);
				}

				//Check:
				case 8:
				{

					//Remove:
					RemoveGunLab(Client, Id);
				}

				//Check:
				case 9:
				{

					//Remove:
					RemoveMicrowave(Client, Id);
				}

				//Check:
				case 10:
				{

					//Remove:
					RemoveShield(Client, Id);
				}

				//Check:
				case 11:
				{

					//Remove:
					RemoveFireBomb(Client, Id, false);
				}

				//Check:
				case 12:
				{

					//Remove:
					RemoveGenerator(Client, Id, false);
				}

				//Check:
				case 13:
				{

					//Remove:
					RemoveBitCoinMine(Client, Id, false);
				}

				//Check:
				case 14:
				{

					//Remove:
					RemovePropaneTank(Client, Id, false);
				}

				//Check:
				case 15:
				{

					//Remove:
					RemovePhosphoruTank(Client, Id, false);
				}

				//Check:
				case 16:
				{

					//Remove:
					RemoveSodiumTub(Client, Id);
				}

				//Check:
				case 17:
				{

					//Remove:
					RemoveHcAcidTub(Client, Id);
				}

				//Check:
				case 18:
				{

					//Remove:
					RemoveAcetoneCan(Client, Id);
				}

				//Check:
				case 19:
				{

					//Remove:
					RemoveSeeds(Client, Id);
				}

				//Check:
				case 20:
				{

					//Remove:
					RemoveLamp(Client, Id);
				}

				//Check:
				case 21:
				{

					//Remove:
					RemoveErythroxylum(Client, Id);
				}

				//Check:
				case 22:
				{

					//Remove:
					RemoveBenzocaine(Client, Id);
				}

				//Check:
				case 23:
				{

					//Remove:
					RemoveBattery(Client, Id, false);
				}

				//Check:
				case 24:
				{

					//Remove:
					RemoveToulene(Client, Id);
				}

				//Check:
				case 25:
				{

					//Remove:
					RemoveSAcidTub(Client, Id);
				}

				//Check:
				case 26:
				{

					//Remove:
					RemoveAmmonia(Client, Id);
				}

				//Check:
				case 27:
				{

					//Remove:
					RemoveBong(Client, Id);
				}

				//Check:
				case 28:
				{

					//Remove:
					RemoveSmokeBomb(Client, Id, false);
				}

				//Check:
				case 29:
				{

					//Remove:
					RemoveWaterBomb(Client, Id, false);
				}

				//Check:
				case 30:
				{

					//Remove:
					RemovePlasmaBomb(Client, Id, false);
				}
			}
		}
	}

	//Return:
	return true;
}