//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_vendorhardware_included_
  #endinput
#endif
#define _rp_vendorhardware_included_

//Debug
#define DEBUG
//Euro - € dont remove this!
//â‚¬ = €

//On Client Attempt To Sell Item:
public OnHardWareVendorStartTouch(Ent, OtherEnt)
{

	//Declare:
	decl String:ClassName[64];

	//Get Entity Info:
	GetEdictClassname(OtherEnt, ClassName, sizeof(ClassName));

	//Is Grenade:
	if(StrContains(ClassName, "prop_physics") != -1)
	{

		//Valid Battery:
		if(IsValidBattery(OtherEnt))
		{

			//Declare:
			new Client = GetBatteryOwnerFromEnt(OtherEnt);

			new Id = GetBatteryIdFromEnt(OtherEnt);

			//Check:
			if(GetBatteryEnergy(Client, Id) > 250.0)
			{

				//Declare:
				new AddCash = (RoundFloat(GetBatteryEnergy(Client, Id)) * 4);

				//Initulize:
				SetCash(Client, (GetCash(Client) + AddCash));

				//Remove From DB:
				RemoveSpawnedItem(Client, 23, Id);

				//Remove:
				RemoveBattery(Client, Id, false);

				//Print:
				CPrintToChat(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You have sold a battery for \x0732CD32%s\x07FFFFFF!", IntToMoney(AddCash));
			}

			//Override:
			else
			{

				//Print:
				OverflowMessage(Client, "\x07FF4040|RP-Battery|\x07FFFFFF - You can't sell this battery as it doesn't have enough charge!");
			}
		}
	}
}
