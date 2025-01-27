#define ZLEVEL_BASE_CHANCE			10  //Not a strict chance, but a relative one
#define ZLEVEL_STATION_MODIFIER		0.5 //multiplier on the chance
#define ZLEVEL_SPACE_MODIFIER		1.5

//**************************************************************
//
// Map Datums
// --------------
// Each map can have its own datum now. This means no more
// hardcoded bullshit. Same for each Z-level.
//
// Should be mostly self-explanatory. Define /datum/map/active
// in your map file. See current maps for examples.
//
// Base Turf
// --------------
// Because the times are changing, even space being space
// is now considered hardcoding. So now you can have
// grass or asteroid under the station
//
//**************************************************************

/datum/map

	var/nameShort = ""
	var/nameLong = ""
	var/list/zLevels = list()
	var/zMainStation = 1
	var/zCentcomm = 2
	var/zTCommSat = 3
	var/zDerelict = 4
	var/zAsteroid = 5
	var/zDeepSpace = 6

	//Center of thunderdome admin room
	var/tDomeX = 0
	var/tDomeY = 0
	var/tDomeZ = 0

	//nanoui stuff
	var/map_dir = ""

	//Fuck the preprocessor
	var/dorf = 0
	var/linked_to_centcomm = 1

	//If 1, only spawn vaults that are exclusive to this map (other vaults aren't spawned). For more info, see code/modules/randomMaps/vault_definitions.dm
	var/only_spawn_map_exclusive_vaults = 0

	// List of package tagger locations. Due to legacy shitcode you can only append or replace ones with null, or you'll break stuff.
	var/list/default_tagger_locations = list(
		DISP_DISPOSALS,
		DISP_CARGO_BAY,
		DISP_QM_OFFICE,
		DISP_ENGINEERING,
		DISP_CE_OFFICE,
		DISP_ATMOSPHERICS,
		DISP_SECURITY,
		DISP_HOS_OFFICE,
		DISP_MEDBAY,
		DISP_CMO_OFFICE,
		DISP_CHEMISTRY,
		DISP_RESEARCH,
		DISP_RD_OFFICE,
		DISP_ROBOTICS,
		DISP_HOP_OFFICE,
		DISP_LIBRARY,
		DISP_CHAPEL,
		DISP_THEATRE,
		DISP_BAR,
		DISP_KITCHEN,
		DISP_HYDROPONICS,
		DISP_JANITOR_CLOSET,
		DISP_GENETICS,
		DISP_TELECOMMS,
		DISP_MECHANICS,
		DISP_TELESCIENCE
	)

	var/list/enabled_jobs = list()

/datum/map/New()

	. = ..()
	src.loadZLevels(src.zLevels)
	return

/datum/map/proc/loadZLevels(list/levelPaths)


	for(var/i = 1 to levelPaths.len)
		var/path = levelPaths[i]
		addZLevel(new path, i)

/datum/map/proc/addZLevel(datum/zLevel/level, z_to_use = 0)


	if(!istype(level))
		warning("ERROR: addZLevel received [level ? "a bad level of type [ispath(level) ? "[level]" : "[level.type]" ]" : "no level at all!"]")
		return
	if(!level.base_turf)
		level.base_turf = /turf/space
	if(z_to_use > zLevels.len)
		zLevels.len = z_to_use
	zLevels[z_to_use] = level
	if(!level.movementJammed)
		accessable_z_levels += list("[z_to_use]" = level.movementChance)

var/global/list/accessable_z_levels = list()

//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//Generated by the map datum on roundstart - and added to during the round
//This comment is a memorial to balance bickering from a long-gone TGstation - Errorage and Urist


////////////////////////////////////////////////////////////////

/datum/zLevel

	var/name = ""
	var/teleJammed = 0
	var/movementJammed = 0 //Prevents you from accessing the zlevel by drifting
	var/movementChance = ZLEVEL_BASE_CHANCE
	var/base_turf //Our base turf, what shows under the station when destroyed. Defaults to space because it's fukken Space Station 13

////////////////////////////////

/datum/zLevel/station

	name = "station"
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_STATION_MODIFIER

/datum/zLevel/centcomm

	name = "centcomm"
	teleJammed = 1
	movementJammed = 1

/datum/zLevel/space

	name = "space"
	movementChance = ZLEVEL_BASE_CHANCE * ZLEVEL_SPACE_MODIFIER

/datum/zLevel/mining

	name = "mining"

//Currently experimental, contains nothing worthy of interest
/datum/zLevel/desert

	name = "desert"
	teleJammed = 1
	movementJammed = 1
	base_turf = /turf/unsimulated/beach/sand

// Debug ///////////////////////////////////////////////////////

/*
/mob/verb/getCurMapData()
	to_chat(src, "\nCurrent map data:")
	to_chat(src, "* Short name: [map.nameShort]")
	to_chat(src, "* Long name: [map.nameLong]")
	to_chat(src, "* [map.zLevels.len] Z-levels: [map.zLevels]")
	for(var/datum/zLevel/level in map.zLevels)
		to_chat(src, "  * [level.name], Telejammed : [level.teleJammed], Movejammed : [level.movementJammed]")
	to_chat(src, "* Main station Z: [map.zMainStation]")
	to_chat(src, "* Centcomm Z: [map.zCentcomm]")
	to_chat(src, "* Thunderdome coords: ([map.tDomeX],[map.tDomeY],[map.tDomeZ])")
	to_chat(src, "* Space movement chances: [accessable_z_levels]")
	for(var/z in accessable_z_levels)
		to_chat(src, "  * [z] has chance [accessable_z_levels[z]]")
	return
*/

// Base Turf //////////////////////////////////////////////////

//Returns the lowest turf available on a given Z-level, defaults to space.

proc/get_base_turf(var/z)


	var/datum/zLevel/L = map.zLevels[z]
	return L.base_turf

proc/change_base_turf(var/choice,var/new_base_path,var/update_old_base = 0)
	if(update_old_base)
		var/count = 0
		for(var/turf/T in turfs)
			count++
			if(!(count % 50000)) sleep(world.tick_lag)
			if(T.type == get_base_turf(choice) && T.z == choice)
				T.ChangeTurf(new_base_path)
	var/datum/zLevel/L = map.zLevels[choice]
	L.base_turf = new_base_path
	for(var/obj/structure/docking_port/destination/D in all_docking_ports)
		if(D.z == choice)
			D.base_turf_type = new_base_path

/client/proc/set_base_turf()


	set category = "Debug"
	set name = "Set Base Turf"
	set desc = "Set the base turf for a z-level. Defaults to space, does not replace existing tiles."

	if(check_rights(R_DEBUG, 0))
		if(!holder)
			return
		var/choice = input("Which Z-level do you wish to set the base turf for?") as null|num
		if(!choice)
			return
		var/new_base_path = input("Please select a turf path (cancel to reset to /turf/space).") as null|anything in typesof(/turf)
		if(!new_base_path)
			new_base_path = /turf/space //Only hardcode in the whole thing, feel free to change this if somewhere in the distant future spess is deprecated
		var/update_old_base = alert(src, "Do you wish to update the old base? This will LAG.", "Update old turfs?", "Yes", "No")
		update_old_base = update_old_base == "No" ? 0 : 1
		if(update_old_base)
			message_admins("[key_name_admin(usr)] is replacing the old base turf on Z level [choice] with [get_base_turf(choice)]. This is likely to lag.")
			log_admin("[key_name_admin(usr)] has replaced the old base turf on Z level [choice] with [get_base_turf(choice)].")
		change_base_turf(choice,new_base_path,update_old_base)
		feedback_add_details("admin_verb", "BTC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		message_admins("[key_name_admin(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")
		log_admin("[key_name(usr)] has set the base turf for Z-level [choice] to [get_base_turf(choice)]. This will affect all destroyed turfs from now on.")
