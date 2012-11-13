/*
  Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
  Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>

  This file is part of Call of Duty 4 Promod.

  Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
  Terms of license can be found in LICENSE.md document bundled with the project.
*/

init()
{
	precacheItem( "ak47_mp" );
	precacheItem( "ak47_silencer_mp" );
	precacheItem( "ak74u_mp" );
	precacheItem( "ak74u_silencer_mp" );
	precacheItem( "beretta_mp" );
	precacheItem( "beretta_silencer_mp" );
	precacheItem( "colt45_mp" );
	precacheItem( "colt45_silencer_mp" );
	precacheItem( "deserteagle_mp" );
	precacheItem( "deserteaglegold_mp" );
	precacheItem( "frag_grenade_mp" );
	precacheItem( "frag_grenade_short_mp" );
	precacheItem( "g3_mp" );
	precacheItem( "g3_silencer_mp" );
	precacheItem( "g36c_mp" );
	precacheItem( "g36c_silencer_mp" );
	precacheItem( "m4_mp" );
	precacheItem( "m4_silencer_mp" );
	precacheItem( "m14_mp" );
	precacheItem( "m14_silencer_mp" );
	precacheItem( "m16_mp" );
	precacheItem( "m16_silencer_mp" );
	precacheItem( "m40a3_mp" );
	precacheItem( "m1014_mp" );
	precacheItem( "mp5_mp" );
	precacheItem( "mp5_silencer_mp" );
	precacheItem( "mp44_mp" );
	precacheItem( "remington700_mp" );
	precacheItem( "usp_mp" );
	precacheItem( "usp_silencer_mp" );
	precacheItem( "uzi_mp" );
	precacheItem( "uzi_silencer_mp" );
	precacheItem( "winchester1200_mp" );
	precacheItem( "smoke_grenade_mp" );
	precacheItem( "flash_grenade_mp" );
	precacheItem( "destructible_car" );
	precacheShellShock( "default" );
	thread maps\mp\_flashgrenades::main();
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		self.hasDoneCombat = false;
		self thread watchWeaponUsage();
		self thread watchGrenadeUsage();
	}
}

dropWeaponForDeath( attacker )
{
	weapon = self getCurrentWeapon();

	if ( !isDefined( weapon ) || !self hasWeapon( weapon ) )
		return;

	if( isPrimaryWeapon( weapon ) )
	{
		switch ( level.primary_weapon_array[weapon] )
		{
			case "weapon_assault":
				if ( !getDvarInt( "class_assault_allowdrop" ) )
					return;
				break;
			case "weapon_smg":
				if ( !getDvarInt( "class_specops_allowdrop" ) )
					return;
				break;
			case "weapon_sniper":
				if ( !getDvarInt( "class_sniper_allowdrop" ) )
					return;
				break;
			case "weapon_shotgun":
				if ( !getDvarInt( "class_demolitions_allowdrop" ) )
					return;
				break;
			default:
				return;
		}
	}
	else if ( WeaponClass( weapon ) != "pistol" )
		return false;

	clipAmmo = self GetWeaponAmmoClip( weapon );

	if ( !clipAmmo )
		return;

	stockAmmo = self GetWeaponAmmoStock( weapon );
	stockMax = WeaponMaxAmmo( weapon );
	if ( stockAmmo > stockMax )
		stockAmmo = stockMax;

	item = self dropItem( weapon );

	item ItemWeaponSetAmmo( clipAmmo, stockAmmo );

	if( !isDefined(game["PROMOD_MATCH_MODE"]) || game["PROMOD_MATCH_MODE"] != "match" || (game["PROMOD_MATCH_MODE"] == "match" && level.gametype != "sd") || game["promod_do_readyup"] )
		item thread deletePickupAfterAWhile();
}

deletePickupAfterAWhile()
{
	self endon("death");

	wait 180;

	if ( !isDefined( self ) )
		return;

	self delete();
}

watchWeaponUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon ( "game_ended" );
	level endon ( "grace_period_ending" );

	for ( ;; )
	{
		self waittill ( "begin_firing" );
		self.hasDoneCombat = true;
	}
}

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );

	self.throwingGrenade = false;

	for(;;)
	{
		self waittill ( "grenade_pullback", weaponName );

		self.hasDoneCombat = true;
		self.throwingGrenade = true;
		self beginGrenadeTracking();
	}
}

beginGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );

	self waittill ( "grenade_fire", grenade, weaponName );

	if ( weaponName == "frag_grenade_mp" || weaponName == "frag_grenade_short_mp" )
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();

	self.throwingGrenade = false;
}

onWeaponDamage( eInflictor, sWeapon, meansOfDeath, damage )
{
	self endon ( "death" );
	self endon ( "disconnect" );

	maps\mp\gametypes\_shellshock::shellshockOnDamage( meansOfDeath, damage );
}

isPrimaryWeapon( weaponname )
{
	return isdefined( level.primary_weapon_array[weaponname] );
}