//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_dropped_included_
  #endinput
#endif
#define _rp_dropped_included_

static DroppedDrugValue[2047] = {0,...};
static DroppedMethValue[2047] = {0,...};
static DroppedPillsValue[2047] = {0,...};
static DroppedCocainValue[2047] = {0,...};
static DroppedMoneyValue[2047] = {0,...};

ResetDropped()
{

	//Clean map entitys:
	for(new X = 0; X < 2047; X++)
	{

		//Initulize:
		DroppedDrugValue[X] = 0;

		DroppedMethValue[X] = 0;

		DroppedPillsValue[X] = 0;

		DroppedCocainValue[X] = 0;

		DroppedMoneyValue[X] = 0;
	}
}

public bool:CreateWeedBags(Client, Amount)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return false;
	}

	PrecacheModel("models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl", true);

	//Declare:
	decl Collision, Float:Position[3], Float:OrgPos[2];

	new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Loop:
		while(Amount > 0)
		{

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				new Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 250)
				{

					//Initulize:
					DroppedDrugValue[Ent] = 250;

					//Initulize:
					Amount -= 250;
				}

				//Override:
				else if(Amount < 250)
				{

					//Initulize:
					DroppedDrugValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Set Ent Move Type:
				SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}

	//Return:
	return true;
}

public bool:CreateDroppedPills(Client, Amount)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return false;
	}

	//Declare:
	decl Collision, Float:Position[3], Float:OrgPos[2];

	new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Loop:
		while(Amount > 0)
		{

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				new Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 50)
				{

					//Initulize:
					DroppedPillsValue[Ent] = 50;

					//Initulize:
					Amount -= 50;
				}

				//Override:
				else if(Amount < 50)
				{

					//Initulize:
					DroppedPillsValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/props_lab/jar01b.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Set Ent Move Type:
				SetEntityMoveType(Ent, MOVETYPE_VPHYSICS);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}

	//Return:
	return true;
}

public bool:CreateDroppedMeths(Client, Amount)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return false;
	}

	//Declare:
	decl Collision, Float:Position[3], Float:OrgPos[2];

	new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Loop:
		while(Amount > 0)
		{

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				new Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 200)
				{

					//Initulize:
					DroppedMethValue[Ent] = 200;

					//Initulize:
					Amount -= 200;
				}

				//Override:
				else if(Amount < 200)
				{

					//Initulize:
					DroppedMethValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/katharsmodels/contraband/metasync/blue_sky.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}

	//Return:
	return true;
}

public bool:CreateDroppedCocains(Client, Amount)
{

	//EntCheck:
	if(CheckMapEntityCount() > 2047)
	{

		//Return:
		return false;
	}

	//Declare:
	decl Collision, Float:Position[3], Float:OrgPos[2];

	new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Loop:
		while(Amount > 0)
		{

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				new Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 200)
				{

					//Initulize:
					DroppedCocainValue[Ent] = 200;

					//Initulize:
					Amount -= 200;
				}

				//Override:
				else if(Amount < 200)
				{

					//Initulize:
					DroppedCocainValue[Ent] = Amount;

					//Initulize:
					Amount = 0;
				}

				//Dispatch:
				DispatchKeyValue(Ent, "model", "models/srcocainelab/ziplockedcocaine.mdl");

				//Spawn:
				DispatchSpawn(Ent);

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			}
		}
	}

	//Return:
	return true;
}

public GetDroppedDrugValue(Ent)
{

	//Return:
	return DroppedDrugValue[Ent];
}

public GetDroppedMethValue(Ent)
{

	//Return:
	return DroppedMethValue[Ent];
}

public GetDroppedPillsValue(Ent)
{

	//Return:
	return DroppedPillsValue[Ent];
}

public GetDroppedCocainValue(Ent)
{

	//Return:
	return DroppedCocainValue[Ent];
}

public Action:OnClientPickUpWeedBag(Client, Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		new Amount = (DroppedDrugValue[Ent] / 5);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		new Amount = DroppedDrugValue[Ent];

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of weed!", Amount);
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");

	//Initulize:
	DroppedDrugValue[Ent] = 0;
}

public Action:OnClientPickUpMeth(Client, Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		new Amount = (DroppedMethValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		new Amount = DroppedMethValue[Ent];

		//Initulize:
		SetMeth(Client, (GetMeth(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of Meth!", Amount);
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");

	//Initulize:
	DroppedMethValue[Ent] = 0;
}

public Action:OnClientPickUpPills(Client, Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		new Amount = (DroppedPillsValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		new Amount = DroppedPillsValue[Ent];

		//Initulize:
		SetPills(Client, (GetPills(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%i\x07FFFFFF Pills!", Amount);
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");

	//Initulize:
	DroppedPillsValue[Ent] = 0;
}

public Action:OnClientPickUpCocain(Client, Ent)
{

	//Check:
	if(IsCop(Client))
	{

		//Delare:
		new Amount = (DroppedCocainValue[Ent] / 2);

		//Initulize:
		SetCash(Client, (GetCash(Client) + Amount));

		//Print:
		OverflowMessage(Client, "\x07FF4040|RP|\x07FFFFFF You have Destroyed Drugs!");
	}

	//Override:
	else
	{

		//Delare:
		new Amount = DroppedCocainValue[Ent];

		//Initulize:
		SetCocain(Client, (GetCocain(Client) + Amount));

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP-Drugs|\x07FFFFFF you have just picked up \x0732CD32%ig\x07FFFFFF of Cocain!", Amount);
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");

	//Initulize:
	DroppedCocainValue[Ent] = 0;
}

public Action:OnClientDropAllDrugs(Client)
{

	//Check:
	if(GetHarvest(Client) > 0)
	{

		//Declare:
		new Amount = (GetHarvest(Client) / 4);

		//Initulize:
		SetHarvest(Client, (GetHarvest(Client) - Amount));

		//Create:
		CreateWeedBags(Client, Amount);
	}

	//Check:
	if(GetMeth(Client) > 0)
	{

		//Declare:
		new Amount = (GetMeth(Client) / 4);

		//Initulize:
		SetMeth(Client, (GetMeth(Client) - Amount));

		//Create:
		CreateDroppedMeths(Client, Amount);
	}

	//Check:
	if(GetPills(Client) > 0)
	{

		//Declare:
		new Amount = (GetPills(Client) / 4);

		//Initulize:
		SetPills(Client, (GetPills(Client) - Amount));

		//Create:
		CreateDroppedPills(Client, Amount);
	}

	//Check:
	if(GetCocain(Client) > 0)
	{

		//Declare:
		new Amount = (GetCocain(Client) / 4);

		//Initulize:
		SetCocain(Client, (GetCocain(Client) - Amount));

		//Create:
		CreateDroppedCocains(Client, Amount);
	}
}
public GetDroppedMoneyValue(Ent)
{

	//Return:
	return DroppedMoneyValue[Ent];
}

public SetDroppedMoneyValue(Ent, Amount)
{

	//Initulize:
	DroppedMoneyValue[Ent] = Amount;
}

public Action:OnClientPickUpMoney(Client, Ent)
{

	//Delare:
	new Amount = DroppedMoneyValue[Ent];

	//Initulize:
	SetCash(Client, (GetCash(Client) + Amount));

	//Kill:
	AcceptEntityInput(Ent, "Kill");

	//Initulize:
	DroppedMoneyValue[Ent] = 0;

	//Initulize:
	SetPropSpawnedTimer(Ent, -1);

	SetPropIndex((GetPropIndex() - 1));
}

public bool:CreateMoneyBoxes(Client, Amount)
{

	//EntCheck:
	if(GetPropIndex() > 1900)
	{

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF - You cannot spawn enties crash provention Map Index %i Tracking Inded %i", CheckMapEntityCount(), GetPropIndex());

		//Return:
		return false;
	}

	//Declare:
	decl Collision, Float:Position[3], Float:OrgPos[2];

	new Float:Angles[3] = {0.0, 0.0, 0.0};

	//Initulize:
	GetClientAbsOrigin(Client, Position);

	//Check:
	if(!TR_PointOutsideWorld(Position))
	{

		//Initulize:
		Position[2] += 30.0;
		OrgPos[0] = Position[0];
		OrgPos[1] = Position[1];

		//Loop:
		while(Amount > 0)
		{

			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
			Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);

			//Check:
			if(!TR_PointOutsideWorld(Position))
			{

				//Initialize:
				new Ent = CreateEntityByName("prop_physics_override");

				if(Amount > 100000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 100000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");

					//Initulize:
					Amount -= 100000;

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 50000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 50000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 50000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 6);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 10000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 10000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 10000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 5);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 5000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 5000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 5000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 4);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 2000) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 2000;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 2000;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 3);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 500) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 500;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 500;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 2);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 200) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 200;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 200;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 0);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 100) //goldbar
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 100;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/john/euromoney.mdl");

					//Initulize:
					Amount -= 100;

					//Set Skin:
					SetEntProp(Ent, Prop_Send, "m_nSkin", 1);

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 25) //golcoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 25;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/goldcoin.mdl");

					//Initulize:
					Amount -= 25;

					//Spawn:
					DispatchSpawn(Ent);
				}

				else if(Amount > 10) //silvcoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 5;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");

					//Initulize:
					Amount -= 5;

					//Spawn:
					DispatchSpawn(Ent);
				}

				else //broncoin
				{

					//Initulize:
					DroppedMoneyValue[Ent] = 1;

					//Dispatch:
					DispatchKeyValue(Ent, "model", "models/money/broncoin.mdl");

					//Initulize:
					Amount -= 1;

					//Spawn:
					DispatchSpawn(Ent);
				}

				//Debris:
				Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
				SetEntData(Ent, Collision, 1, 1, true);

				//Send:
				TeleportEntity(Ent, Position, Angles, NULL_VECTOR);

				//Initulize:
				SetPropSpawnedTimer(Ent, 0);

				SetPropIndex((GetPropIndex() + 1));
			}
		}
	}

	//Return:
	return true;
}

public Action:OnClientDropMoney(Client)
{

	//Check:
	if(IsCop(Client) && IsCopDropDisabled() == 1)
	{

	}

	//Override:
	else if(GetCash(Client) > 50)
	{

		//Delare:
		new Amount = GetCash(Client) / 4;

		//Initulize:
		SetCash(Client, (GetCash(Client) - Amount));

		//Create:
		CreateMoneyBoxes(Client, Amount);

		//Print:
		CPrintToChat(Client, "\x07FF4040|RP|\x07FFFFFF you have just dropped \x0732CD32%s\x07FFFFFF!", IntToMoney(Amount));
	}
}
