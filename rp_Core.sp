//This script has been Licenced by Master(D) under http://creativecommons.org/licenses/by-nc-nd/3.0/
//All Rights of this script is the owner of Master(D).

//Includes:
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <collisionhook>
#include <colors>

//Terminate:
#pragma semicolon		1
#pragma compress		0

//Server Includes:
#include "MasterRP/server/rp_cvar.sp"
#include "MasterRP/server/rp_forwardsmessages.sp"
#include "MasterRP/server/rp_gamename.sp"
#include "MasterRP/server/rp_hl2dmfixes.sp"
#include "MasterRP/server/rp_init.sp"
#include "MasterRP/server/rp_spawns.sp"
#include "MasterRP/server/rp_sql.sp"
#include "MasterRP/server/rp_talkzone.sp"
#include "MasterRP/server/rp_talksounds.sp"
#include "MasterRP/server/rp_teamfix.sp"
#include "MasterRP/server/rp_teamname.sp"
#include "MasterRP/server/rp_weaponmod.sp"

//Vendor Includes:
#include "MasterRP/vendor/rp_npc.sp"
#include "MasterRP/vendor/rp_bank.sp"
#include "MasterRP/vendor/rp_bankrobbing.sp"
#include "MasterRP/vendor/rp_vendorbuy.sp"
#include "MasterRP/vendor/rp_vendordrugs.sp"
#include "MasterRP/vendor/rp_vendorrobbing.sp"
#include "MasterRP/vendor/rp_vendorexptrade.sp"
#include "MasterRP/vendor/rp_vendorhardware.sp"

//jobs Includes:
#include "MasterRP/jobs/rp_cratezone.sp"
#include "MasterRP/jobs/rp_garbagezone.sp"
#include "MasterRP/jobs/rp_joblist.sp"
#include "MasterRP/jobs/rp_jobsetup.sp"
#include "MasterRP/jobs/rp_jobsystem.sp"
#include "MasterRP/jobs/rp_thumpers.sp"
#include "MasterRP/jobs/rp_copranking.sp"
#include "MasterRP/jobs/rp_jail.sp"
#include "MasterRP/jobs/rp_crime.sp"

//Roleplay Includes:
#include "MasterRP/rp_forwards.sp"
#include "MasterRP/rp_nokillzone.sp"
#include "MasterRP/rp_stock.sp"
#include "MasterRP/rp_light.sp"
#include "MasterRP/rp_sleeping.sp"
#include "MasterRP/rp_plugininfo.sp"
#include "MasterRP/rp_notice.sp"
#include "MasterRP/rp_spawnprotect.sp"
#include "MasterRP/rp_entity.sp"
#include "MasterRP/rp_moneysafe.sp"
#include "MasterRP/rp_propmanagment.sp"
#include "MasterRP/rp_props.sp"

//Vehicle Indludes:
#include "MasterRP/vehicle/rp_prisionpod.sp"
#include "MasterRP/vehicle/rp_carmod.sp"
#include "MasterRP/vehicle/rp_jeep.sp"
#include "MasterRP/vehicle/rp_apc.sp"

//Masters Admin Includes:
#include "MasterRP/admin/rp_bans.sp"

//Client Includes:
#include "MasterRP/client/rp_laststats.sp"
#include "MasterRP/client/rp_tracers.sp"
#include "MasterRP/client/rp_playermenu.sp"
#include "MasterRP/client/rp_hats.sp"
#include "MasterRP/client/rp_defaults.sp"
#include "MasterRP/client/rp_hud.sp"
#include "MasterRP/client/rp_player.sp"
#include "MasterRP/client/rp_iscritical.sp"
#include "MasterRP/client/rp_donator.sp"
#include "MasterRP/client/rp_settings.sp"

//Custom npcs Includes:
#include "MasterRP/npcs/rp_npcdynamic.sp"
#include "MasterRP/npcs/rp_npcevent.sp"
#include "MasterRP/npcs/rp_npcantlionguard.sp"
#include "MasterRP/npcs/rp_npcichthyosaur.sp"
#include "MasterRP/npcs/rp_npchelicopter.sp"
#include "MasterRP/npcs/rp_npcvortigaunt.sp"
#include "MasterRP/npcs/rp_npcdog.sp"
#include "MasterRP/npcs/rp_npcstrider.sp"
#include "MasterRP/npcs/rp_npcmetropolice.sp"
#include "MasterRP/npcs/rp_npczombie.sp"
#include "MasterRP/npcs/rp_npcpoisonzombie.sp"
#include "MasterRP/npcs/rp_npcheadcrab.sp"
#include "MasterRP/npcs/rp_npcheadcrabfast.sp"
#include "MasterRP/npcs/rp_npcheadcrabblack.sp"
#include "MasterRP/npcs/rp_npcturretfloor.sp"
#include "MasterRP/npcs/rp_npcadvisor.sp"
#include "MasterRP/npcs/rp_npccrabsynth.sp"
#include "MasterRP/npcs/rp_attachedeffects.sp"

//Door System:
#include "MasterRP/doors/rp_admindoors.sp"
#include "MasterRP/doors/rp_doorsystem.sp"
#include "MasterRP/doors/rp_doorlocked.sp"
#include "MasterRP/doors/rp_copdoors.sp"
#include "MasterRP/doors/rp_doormisc.sp"
#include "MasterRP/doors/rp_vipdoors.sp"

//Core Item System:
#include "MasterRP/items/rp_items.sp"
#include "MasterRP/items/rp_itemlist.sp"

//Spawnable Items:
#include "MasterRP/items/rp_dropped.sp"
#include "MasterRP/items/rp_savespawneditems.sp"
#include "MasterRP/items/rp_savedrugs.sp"

//General Items:
#include "MasterRP/items/misc/rp_propanetank.sp"
#include "MasterRP/items/misc/rp_rice.sp"
#include "MasterRP/items/misc/rp_bomb.sp"
#include "MasterRP/items/misc/rp_microwave.sp"
#include "MasterRP/items/misc/rp_shield.sp"
#include "MasterRP/items/misc/rp_firebomb.sp"
#include "MasterRP/items/misc/rp_smokebomb.sp"
#include "MasterRP/items/misc/rp_waterbomb.sp"
#include "MasterRP/items/misc/rp_plasmabomb.sp"

//Energy Items:
#include "MasterRP/items/energy/rp_generator.sp"
#include "MasterRP/items/energy/rp_battery.sp"
#include "MasterRP/items/energy/rp_printers.sp"
#include "MasterRP/items/energy/rp_bitcoinmine.sp"
#include "MasterRP/items/energy/rp_gunlab.sp"

//Drug Plant Items:
#include "MasterRP/items/drug/rp_lamp.sp"
#include "MasterRP/items/drug/rp_harvest.sp"
#include "MasterRP/items/drug/rp_harvestseeds.sp"
#include "MasterRP/items/drug/rp_bong.sp"

//Meth Items:
#include "MasterRP/items/meth/rp_meth.sp"
#include "MasterRP/items/meth/rp_phosphorutank.sp"
#include "MasterRP/items/meth/rp_sodiumtub.sp"
#include "MasterRP/items/meth/rp_hcacidtub.sp"
#include "MasterRP/items/meth/rp_acetonecan.sp"

//Pills Items:
#include "MasterRP/items/pills/rp_pills.sp"
#include "MasterRP/items/pills/rp_toulene.sp"
#include "MasterRP/items/pills/rp_sacidtub.sp"
#include "MasterRP/items/pills/rp_ammonia.sp"

//Cocain Items:
#include "MasterRP/items/cocain/rp_cocain.sp"
#include "MasterRP/items/cocain/rp_erythroxylum.sp"
#include "MasterRP/items/cocain/rp_benzocaine.sp"
