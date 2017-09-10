//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_propmanagment_included_
  #endinput
#endif
#define _rp_propmanagment_included_

#define MAXINDEX		2047
#define MAXSPAWNEDTIME		30

static PropNumbIndex = 0;
static PropSpawnedTime[MAXINDEX] = {-1,...};

ResetIndexNumbAfterMapStart()
{

	//Initulize:
	PropNumbIndex = CheckMapEntityCount();

	//Loop:
	for(new X = 1; X < MAXINDEX; X++)
	{

		//Initulize:
		PropSpawnedTime[X] = -1;
	}
}

initPropSpawnedTime()
{

	//Loop:
	for(new X = 1; X < MAXINDEX; X++)
	{

		//Check:
		if(PropSpawnedTime[X] > 0)
		{

			//Initulize:
			PropSpawnedTime[X] += 1;

			//Check:
			if(PropSpawnedTime[X] >= MAXSPAWNEDTIME)
			{

				//Remove Prop:
				RemoveProp(X);
			}
		}
	}
}

public Action:RemoveProp(Ent)
{

	//Is Weapon:
	if(!StrEqual(GetWeaponInfo(Ent), "null"))
	{

		//Initulize:
		SetWeaponInfo(Ent, "null");		
	}

	//is Garbage:
	if(IsValidGarbage(Ent))
	{

		//Initlize:
		SetGarbage(Ent, 0);

		SetGarbageOnMap(GetGarbageOnMap() - 1);
	}

	//Is Money:
	if(GetDroppedMoneyValue(Ent))
	{

		//Initulize:
		SetDroppedMoneyValue(Ent, 0);
	}

	//Loop Items:
	for(new X = 1; X <= 400; X++)
	{

		//Check:
		if(GetDroppedItemValue(Ent, X) > 0)
		{

			//Initulize:
			SetDroppedItemValue(Ent, X, 0);
		}
	}

	//Kill:
	AcceptEntityInput(Ent, "Kill");
}

public GetPropSpawnedTimer(Ent)
{

	//Return:
	return PropSpawnedTime[Ent];
}

public SetPropSpawnedTimer(Ent, Value)
{

	//Initulize:
	PropSpawnedTime[Ent] = Value;
}

public GetPropIndex()
{

	//Return:
	return PropNumbIndex;
}

public SetPropIndex(Value)
{

	//Initulize:
	PropNumbIndex = Value;
}