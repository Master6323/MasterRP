//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

/** Double-include prevention */
#if defined _rp_attachedeffects_included_
  #endinput
#endif
#define _rp_attachedeffects_included_

#define MAXEFFECTS 		10

static ElecticEffectEnt[2047][MAXEFFECTS + 1];

public ResetEffects()
{

	//Loop:
	for(new X = 0; X < 2047; X++) for(new Y = 0; Y <= MAXEFFECTS; Y++)
	{

		ElecticEffectEnt[X][Y] = -1;
	}
}

public GetEntAttatchedEffect(Ent, Slot)
{

	//Return:
	return ElecticEffectEnt[Ent][Slot];
}

public SetEntAttatchedEffect(Ent, Slot, AttachedEnt)
{

	//Initulize:
	ElecticEffectEnt[Ent][Slot] = AttachedEnt;
}

public IsValidAttachedEffect(Ent)
{

	//Loop:
	for(new Y = 0; Y <= MAXEFFECTS; Y++)
	{

		if(ElecticEffectEnt[Ent][Y] > 0)
		{

			//Return:
			return true;
		}
	}

	//Return:
	return false;
}

public Action:RemoveAttachedEffect(Ent)
{

	//Loop:
	for(new Y = 0; Y <= MAXEFFECTS; Y++)
	{

		if(IsValidEdict(ElecticEffectEnt[Ent][Y]))
		{

			//Accept:
			AcceptEntityInput(ElecticEffectEnt[Ent][Y], "Kill");
		}

		//Initulize:
		ElecticEffectEnt[Ent][Y] = -1;
	}
}

public FindAttachedPropFromEnt(Ent)
{

	//Loop:
	for(new X = 0; X < 2047; X++) for(new Y = 0; Y <= MAXEFFECTS; Y++)
	{

		//Checl:
		if(ElecticEffectEnt[X][Y] == Ent)
		{

			//Return:
			return X;
		}
	}

	//Return:
	return -1;
}
