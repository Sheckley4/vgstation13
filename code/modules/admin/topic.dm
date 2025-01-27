/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		message_admins("[usr.key] has attempted to override the admin panel!")
		return

	var/client/CLIENT = usr.client
	if(href_list["makeAntag"])
		switch(href_list["makeAntag"])
			if("1")
				log_admin("[key_name(usr)] has spawned a traitor.")
				if(!src.makeTraitors())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("2")
				log_admin("[key_name(usr)] has spawned a changeling.")
				if(!src.makeChanglings())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("3")
				log_admin("[key_name(usr)] has spawned revolutionaries.")
				if(!src.makeRevs())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("4")
				log_admin("[key_name(usr)] has spawned a cultists.")
				if(!src.makeCult())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("5")
				log_admin("[key_name(usr)] has spawned a malf AI.")
				if(!src.makeMalfAImode())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("6")
				log_admin("[key_name(usr)] has spawned a wizard.")
				if(!src.makeWizard())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("7")
				log_admin("[key_name(usr)] has spawned a nuke team.")
				if(!src.makeNukeTeam())
					to_chat(usr, "<span class='warning'>Unfortunately there weren't enough candidates available.</span>")
			if("9")
				log_admin("[key_name(usr)] has spawned aliens.")
				src.makeAliens()
			if("10")
				log_admin("[key_name(usr)] has spawned a death squad.")
				if(!makeDeathsquad())
					to_chat(usr, "<span class='warning'>Unfortunately, there were no candidates available</span>")
			if("11")
				log_admin("[key_name(usr)] has spawned vox raiders.")
				if(!src.makeVoxRaiders())
					to_chat(usr, "<span class='warning'>Unfortunately, there weren't enough candidates available.</span>")

	else if("announce_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])

		log_admin("[key_name(usr)] has notified [key_name(S)] of a change to their laws.")
		message_admins("[usr.key] has notified [key_name(S)] of a change to their laws.")

		to_chat(S, "____________________________________")
		to_chat(S, "<span style=\"color:red;font-weight:bold;\">LAW CHANGE NOTICE</span>")
		if(S.laws)
			to_chat(S, "<b>Your new laws are as follows:</b>")
			S.laws.show_laws(S)
		else
			to_chat(S, "<b>Your laws are null.</b> Contact a coder immediately.")
		to_chat(S, "____________________________________")
		if(isAI(S))
			var/mob/living/silicon/ai/AI=S
			AI.notify_slaved(force_sync=1)

	else if("add_law" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		var/lawtypes = list(
			"Law Zero"= LAW_ZERO,
			"Ion"     = LAW_IONIC,
			"Core"    = LAW_INHERENT,
			"Standard"= 1
		)
		var/lawtype = input("Select a law type.","Law Type",1) as anything in lawtypes
		lawtype=lawtypes[lawtype]
		if(lawtype == null)
			return
		testing("Lawtype: [lawtype]")
		if(lawtype==1)
			lawtype=text2num(input("Enter desired law priority. (15-50)","Priority", 15) as num)
			lawtype=Clamp(lawtype,15,50)
		var/newlaw = copytext(sanitize(input(usr, "Please enter a new law for the AI.", "Freeform Law Entry", "")),1,MAX_MESSAGE_LEN)
		if(newlaw=="")
			return
		S.laws.add_law(lawtype,newlaw)

		log_admin("[key_name(usr)] has added a law to [key_name(S)]: \"[newlaw]\"")
		message_admins("[usr.key] has added a law to [key_name(S)]: \"[newlaw]\"")
		lawchanges.Add("[key_name(usr)] has added a law to [key_name(S)]: \"[newlaw]\"")

	else if("reset_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		var/lawtypes = typesof(/datum/ai_laws) - /datum/ai_laws
		var/lawtype = input("Select a lawset.","Law Type",1) as null|anything in lawtypes
		if(lawtype == null)
			return
		testing("Lawtype: [lawtype]")

		var/law_zeroth=null
		var/law_zeroth_borg=null
		if(S.laws.zeroth || S.laws.zeroth_borg)
			if(alert(src,"Do you also wish to clear law zero?","Yes","No") == "No")
				law_zeroth=S.laws.zeroth
				law_zeroth_borg=S.laws.zeroth

		S.laws = new lawtype
		S.laws.zeroth=law_zeroth
		S.laws.zeroth_borg=law_zeroth_borg

		log_admin("[key_name(usr)] has reset [key_name(S)]: [lawtype]")
		message_admins("[usr.key] has reset [key_name(S)]: [lawtype]")
		lawchanges.Add("[key_name(usr)] has reset [key_name(S)]: [lawtype]")

	else if("clear_laws" in href_list)
		var/mob/living/silicon/S = locate(href_list["mob"])
		S.laws.clear_inherent_laws()
		S.laws.clear_supplied_laws()
		S.laws.clear_ion_laws()

		if(S.laws.zeroth || S.laws.zeroth_borg)
			if(alert(src,"Do you also wish to clear law zero?","Yes","No") == "Yes")
				S.laws.set_zeroth_law("","")

		log_admin("[key_name(usr)] has purged [key_name(S)]")
		message_admins("[usr.key] has purged [key_name(S)]")
		lawchanges.Add("[key_name(usr)] has purged [key_name(S)]")

	else if(href_list["dbsearchckey"] || href_list["dbsearchadmin"])
		var/adminckey = href_list["dbsearchadmin"]
		var/playerckey = href_list["dbsearchckey"]

		DB_ban_panel(playerckey, adminckey)
		return

	else if(href_list["dbbanedit"])
		var/banedit = href_list["dbbanedit"]
		var/banid = text2num(href_list["dbbanid"])
		if(!banedit || !banid)
			return

		DB_ban_edit(banid, banedit)
		return

	else if(href_list["dbbanaddtype"])

		var/bantype = text2num(href_list["dbbanaddtype"])
		var/banckey = href_list["dbbanaddckey"]
		var/banduration = text2num(href_list["dbbaddduration"])
		var/banjob = href_list["dbbanaddjob"]
		var/banreason = href_list["dbbanreason"]

		banckey = ckey(banckey)

		switch(bantype)
			if(BANTYPE_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and duration)")
					return
				banjob = null
			if(BANTYPE_JOB_PERMA)
				if(!banckey || !banreason || !banjob)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
				banduration = null
			if(BANTYPE_JOB_TEMP)
				if(!banckey || !banreason || !banjob || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason and job)")
					return
			if(BANTYPE_APPEARANCE)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
				banjob = null
			if(BANTYPE_OOC_PERMA)
				if(!banckey || !banreason)
					to_chat(usr, "Not enough parameters (Requires ckey and reason)")
					return
				banduration = null
			if(BANTYPE_OOC_TEMP)
				if(!banckey || !banreason || !banduration)
					to_chat(usr, "Not enough parameters (Requires ckey, reason, and duration)")
					return

		var/mob/playermob

		for(var/mob/M in player_list)
			if(M.ckey == banckey)
				playermob = M
				break

		banreason = "(MANUAL BAN) "+banreason

		DB_ban_record(bantype, playermob, banduration, banreason, banjob, null, banckey)

	else if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			log_admin("[key_name(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey)	return
			if(new_ckey in admin_datums)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>")
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': No valid ckey</font>")
				return

		var/datum/admins/D = admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message","Yes","Cancel") == "Yes")
				if(!D)	return
				admin_datums -= adm_ckey
				D.disassociate()

				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")
				log_admin("[key_name(usr)] removed [adm_ckey] from the admins list")
				log_admin_rank_modification(adm_ckey, "Removed")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in (admin_ranks|"*New Rank*")
			else
				new_rank = input("Please select a rank", "New rank", null, null) as null|anything in list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*")

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						to_chat(usr, "<font color='red'>Error: Topic 'editrights': Invalid rank</font>")
						return
					if(config.admin_legacy_system)
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank]		//we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0			//add the new rank to admin_ranks
				else
					if(config.admin_legacy_system)
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank]				//we input an existing rank, use its rights

			if(D)
				D.disassociate()								//remove adminverbs and unlink from client
				D.rank = new_rank								//update the rank
				D.rights = rights								//update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = directory[adm_ckey]						//find the client with the specified ckey (if they are logged in)
			D.associate(C)											//link up with the client and add verbs

			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin("[key_name(usr)] edited the admin rank of [adm_ckey] to [new_rank]")
			log_admin_rank_modification(adm_ckey, new_rank)

		else if(task == "permissions")
			if(!D)	return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_MAXPERMISSION, i<<=1)		//that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = input("Select a permission to turn on/off", "Permission toggle", null, null) as null|anything in permissionlist
			if(!new_permission)	return
			D.rights ^= permissionlist[new_permission]

			message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin("[key_name(usr)] toggled the [new_permission] permission of [adm_ckey]")
			log_admin_permission_modification(adm_ckey, permissionlist[new_permission])

		edit_admin_permissions()

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))	return

		if( ticker.mode.name == "blob" )
			alert("You can't call the shuttle during blob!")
			return

		switch(href_list["call_shuttle"])
			if("1")
				if ((!( ticker ) || emergency_shuttle.location))
					return
				var/justification = stripped_input(usr, "Please input a reason for the shuttle call. You may leave it blank to not have one.", "Justification") as text|null
				emergency_shuttle.incall()
				captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.[justification ? " Justification : '[justification]'" : ""]")
				log_admin("[key_name(usr)] called the Emergency Shuttle")
				message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>", 1)

			if("2")
				if ((!( ticker ) || emergency_shuttle.location || emergency_shuttle.direction == 0))
					return
				switch(emergency_shuttle.direction)
					if(-1)
						emergency_shuttle.incall()
						captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
						log_admin("[key_name(usr)] called the Emergency Shuttle")
						message_admins("<span class='notice'>[key_name_admin(usr)] called the Emergency Shuttle to the station</span>", 1)
					if(1)
						emergency_shuttle.recall()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back")
						message_admins("<span class='notice'>[key_name_admin(usr)] sent the Emergency Shuttle back</span>", 1)

		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))	return

		emergency_shuttle.settimeleft( input("Enter new shuttle duration (seconds):","Edit Shuttle Timeleft", emergency_shuttle.timeleft() ) as num )
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]")
		captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited the Emergency Shuttle's timeleft to [emergency_shuttle.timeleft()]</span>", 1)
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))	return

		ticker.delay_end = !ticker.delay_end
		log_admin("[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].")
		message_admins("<span class='notice'>[key_name(usr)] [ticker.delay_end ? "delayed the round end" : "has made the round end normally"].</span>", 1)
		href_list["secretsadmin"] = "check_antagonist"

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/delmob = 0
		switch(alert("Delete old mob?","Message","Yes","No","Cancel"))
			if("Cancel")	return
			if("Yes")		delmob = 1

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")
		message_admins("<span class='notice'>[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(M)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]</span>", 1)
		var/mob/new_mob
		switch(href_list["simplemake"])
			if("observer")			new_mob = M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")			new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")				new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/queen , null, null, delmob )
			if("sentinel")			new_mob = M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")				new_mob = M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")				new_mob = M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
			if("slime")				new_mob = M.change_mob_type( /mob/living/carbon/slime , null, null, delmob )
			if("adultslime")		new_mob = M.change_mob_type( /mob/living/carbon/slime/adult , null, null, delmob )
			if("monkey")			new_mob = M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")				new_mob = M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")				new_mob = M.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
			if("runtime")			new_mob = M.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob )
			if("corgi")				new_mob = M.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
			if("ian")				new_mob = M.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob )
			if("crab")				new_mob = M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")			new_mob = M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")			new_mob = M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")		new_mob = M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmoured")	new_mob = M.change_mob_type( /mob/living/simple_animal/construct/armoured , null, null, delmob )
			if("constructbuilder")	new_mob = M.change_mob_type( /mob/living/simple_animal/construct/builder , null, null, delmob )
			if("constructwraith")	new_mob = M.change_mob_type( /mob/living/simple_animal/construct/wraith , null, null, delmob )
			if("shade")				new_mob = M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )
//		to_chat(world, "Made a [new_mob] [usr ? "usr still exists" : "usr does not exist"]")
		if(new_mob && new_mob != M)
//			to_chat(world, "[new_mob.client] vs [CLIENT] they [new_mob.client == CLIENT ? "match" : "don't match"]")
			if(new_mob.client == CLIENT)
//				to_chat(world, "setting usr to new_mob")
				usr = new_mob //We probably transformed ourselves
			show_player_panel(new_mob)


	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if(RemoveBan(banfolder))
				unbanpanel()
			else
				alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
				unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unwarn"])
		usr.client.unwarn(href_list["unwarn"])

	else if(href_list["unbane"])
		if(!check_rights(R_BAN))	return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				var/mins = 0
				if(minutes > CMinutes)
					mins = minutes - CMinutes
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",mins ? mins : 1440) as num|null
				if(!mins)	return
				mins = min(525599,mins)
				minutes = CMinutes + mins
				duration = GetExp(minutes)
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return
			if("No")
				temp = 0
				duration = "Perma"
				reason = input(usr,"Reason?","reason",reason2) as text|null
				if(!reason)	return

		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]")
		message_admins("<span class='notice'>[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [duration]</span>", 1)
		Banlist.cd = "/base/[banfolder]"
		to_chat(Banlist["reason"], reason)
		to_chat(Banlist["temp"], temp)
		to_chat(Banlist["minutes"], minutes)
		to_chat(Banlist["bannedby"], usr.ckey)
		Banlist.cd = "/base"
		feedback_inc("ban_edit",1)
		unbanpanel()

	/////////////////////////////////////new ban stuff
	else if(href_list["oocban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["oocban"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		var/oocbanned = oocban_isbanned("[M.ckey]")
		if(oocbanned)
			switch(alert("Reason: Remove OOC ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s OOC ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s OOC ban")
					feedback_inc("ban_ooc_unban", 1)
					DB_ban_unban(M.ckey, BANTYPE_OOC_PERMA)
					ooc_unban(M)
					message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s OOC ban</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>[usr.client.ckey] has removed your OOC ban.</B></BIG></span>")
		else switch(alert("OOC ban [M.ckey]?",,"Yes","No"))
			if("Yes")
				switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
					if("Yes")
						var/mins = input(usr,"How long (in minutes)?","OOC Ban time",1440) as num|null
						if(!mins)
							return
						if(mins >= 525600) mins = 525599
						var/reason = input(usr,"Reason?","reason","Shinposting") as text|null
						if(!reason)
							return
						ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
						to_chat(M, "<span class='warning'><BIG><B>You have been OOC banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
						to_chat(M, "<span class='warning'>This is a temporary ooc ban, it will be removed in [mins] minutes.</span>")
						feedback_inc("ban_ooc_tmp",1)
						DB_ban_record(BANTYPE_OOC_TEMP, M, mins, reason)
						feedback_inc("ban_ooc_tmp_mins",mins)
						if(config.banappeals)
							to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals] or consider not being a shithead in OOC</span>")
						else
							to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
						log_admin("[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
						message_admins("<span class='warning'>[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

					if("No")
						var/reason = input(usr,"Reason?","reason","Shinposting") as text|null
						if(!reason)
							return
						to_chat(M, "<span class='warning'><BIG><B>You have been ooc banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
						to_chat(M, "<span class='warning'>This is a permanent ooc ban.</span>")
						if(config.banappeals)
							to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals] or consider not being a shithead in OOC</span>")
						else
							to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
						ban_unban_log_save("[usr.client.ckey] has perma-ooc-banned [M.ckey]. - Reason: [reason] - This is a permanent ooc ban.")
						log_admin("[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis is a permanent ooc ban.")
						message_admins("<span class='warning'>[usr.client.ckey] has ooc banned [M.ckey].\nReason: [reason]\nThis is a permanent ooc ban.</span>")
						feedback_inc("ban_ooc_perma",1)
						DB_ban_record(BANTYPE_OOC_PERMA, M, -1, reason)

					if("Cancel")
						return
				ooc_ban(M)
				return
			if("No")
				return
			else
				return

	else if(href_list["appearanceban"])
		if(!check_rights(R_BAN))
			return
		var/mob/M = locate(href_list["appearanceban"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return

		var/banreason = appearance_isbanned(M)
		if(banreason)
	/*		if(!config.ban_legacy_system)
				to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
				DB_ban_panel(M.ckey)
				return	*/
			switch(alert("Reason: '[banreason]' Remove appearance ban?","Please Confirm","Yes","No"))
				if("Yes")
					ban_unban_log_save("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					log_admin("[key_name(usr)] removed [key_name(M)]'s appearance ban")
					feedback_inc("ban_appearance_unban", 1)
					DB_ban_unban(M.ckey, BANTYPE_APPEARANCE)
					appearance_unban(M)
					message_admins("<span class='notice'>[key_name_admin(usr)] removed [key_name_admin(M)]'s appearance ban</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>[usr.client.ckey] has removed your appearance ban.</B></BIG></span>")

		else switch(alert("Appearance ban [M.ckey]?",,"Yes","No", "Cancel"))
			if("Yes")
				var/reason = input(usr,"Reason?","reason","Metafriender") as text|null
				if(!reason)
					return
				ban_unban_log_save("[key_name(usr)] appearance banned [key_name(M)]. reason: [reason]")
				log_admin("[key_name(usr)] appearance banned [key_name(M)]. \nReason: [reason]")
				feedback_inc("ban_appearance",1)
				DB_ban_record(BANTYPE_APPEARANCE, M, -1, reason)
				appearance_fullban(M, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
				notes_add(M.ckey, "Appearance banned - [reason]")
				message_admins("<span class='notice'>[key_name_admin(usr)] appearance banned [key_name_admin(M)]</span>", 1)
				to_chat(M, "<span class='warning'><BIG><B>You have been appearance banned by [usr.client.ckey].</B></BIG></span>")
				to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
				to_chat(M, "<span class='warning'>Appearance ban can be lifted only upon request.</span>")
				if(config.banappeals)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
			if("No")
				return

	else if(href_list["jobban2"])
//		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban2"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(!M.ckey)	//sanity
			to_chat(usr, "This mob has no ckey")
			return
		if(!job_master)
			to_chat(usr, "Job Master has not been setup!")
			return

		var/dat = ""
		var/header = "<head><title>Job-Ban Panel: [M.name]</title></head>"
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
				      The jobban stuff looks mangled and disgusting
						      But it looks beautiful in-game
						                -Nodrak
	************************************WARNING!***********************************/
		var/counter = 0
//Regular jobs
	//Command (Blue)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr align='center' bgcolor='ccccff'><th colspan='[length(command_positions)]'><a href='?src=\ref[src];jobban3=commanddept;jobban4=\ref[M]'>Command Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in command_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 6) //So things dont get squiiiiished!
				jobs += "</tr><tr>"
				counter = 0
		jobs += "</tr></table>"

	//Security (Red)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffddf0'><th colspan='[length(security_positions)]'><a href='?src=\ref[src];jobban3=securitydept;jobban4=\ref[M]'>Security Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in security_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Engineering (Yellow)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='fff5cc'><th colspan='[length(engineering_positions)]'><a href='?src=\ref[src];jobban3=engineeringdept;jobban4=\ref[M]'>Engineering Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in engineering_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Medical (White)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeef0'><th colspan='[length(medical_positions)]'><a href='?src=\ref[src];jobban3=medicaldept;jobban4=\ref[M]'>Medical Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in medical_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Science (Purple)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='e79fff'><th colspan='[length(science_positions)]'><a href='?src=\ref[src];jobban3=sciencedept;jobban4=\ref[M]'>Science Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in science_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0
		jobs += "</tr></table>"

	//Civilian (Grey)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='dddddd'><th colspan='[length(civilian_positions)]'><a href='?src=\ref[src];jobban3=civiliandept;jobban4=\ref[M]'>Civilian Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in civilian_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		jobs += "</tr></table>"

	//Cargo (Brown)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='b3a292'><th colspan='[length(cargo_positions)]'><a href='?src=\ref[src];jobban3=cargodept;jobban4=\ref[M]'>Cargo Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in cargo_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		jobs += "</tr></table>"

	//Non-Human (Green)
		counter = 0
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccffcc'><th colspan='[length(nonhuman_positions)+1]'><a href='?src=\ref[src];jobban3=nonhumandept;jobban4=\ref[M]'>Non-human Positions</a></th></tr><tr align='center'>"
		for(var/jobPos in nonhuman_positions)
			if(!jobPos)	continue
			var/datum/job/job = job_master.GetJob(jobPos)
			if(!job) continue

			if(jobban_isbanned(M, job.title))
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
				counter++
			else
				jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=[job.title];jobban4=\ref[M]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
				counter++

			if(counter >= 5) //So things dont get squiiiiished!
				jobs += "</tr><tr align='center'>"
				counter = 0

		//pAI isn't technically a job, but it goes in here.

		if(jobban_isbanned(M, "pAI"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'><font color=red>pAI</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=pAI;jobban4=\ref[M]'>pAI</a></td>"
		if(jobban_isbanned(M, "AntagHUD"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'><font color=red>AntagHUD</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=AntagHUD;jobban4=\ref[M]'>AntagHUD</a></td>"
		jobs += "</tr></table>"

	//Antagonist (Orange)
		var/isbanned_dept = jobban_isbanned(M, "Syndicate")
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>Antagonist Positions</a></th></tr><tr align='center'>"

		//Traitor
		if(jobban_isbanned(M, "traitor") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'><font color=red>[replacetext("Traitor", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=traitor;jobban4=\ref[M]'>[replacetext("Traitor", " ", "&nbsp")]</a></td>"

		//Changeling
		if(jobban_isbanned(M, "changeling") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'><font color=red>[replacetext("Changeling", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=changeling;jobban4=\ref[M]'>[replacetext("Changeling", " ", "&nbsp")]</a></td>"

		//Nuke Operative
		if(jobban_isbanned(M, "operative") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'><font color=red>[replacetext("Nuke Operative", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=operative;jobban4=\ref[M]'>[replacetext("Nuke Operative", " ", "&nbsp")]</a></td>"

		//Revolutionary
		if(jobban_isbanned(M, "revolutionary") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'><font color=red>[replacetext("Revolutionary", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=revolutionary;jobban4=\ref[M]'>[replacetext("Revolutionary", " ", "&nbsp")]</a></td>"

		jobs += "</tr><tr align='center'>" //Breaking it up so it fits nicer on the screen every 5 entries

		//Cultist
		if(jobban_isbanned(M, "cultist") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'><font color=red>[replacetext("Cultist", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=cultist;jobban4=\ref[M]'>[replacetext("Cultist", " ", "&nbsp")]</a></td>"

		//Wizard
		if(jobban_isbanned(M, "wizard") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'><font color=red>[replacetext("Wizard", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=wizard;jobban4=\ref[M]'>[replacetext("Wizard", " ", "&nbsp")]</a></td>"

		//ERT
		if(jobban_isbanned(M, "Emergency Response Team") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Emergency Response Team;jobban4=\ref[M]'><font color=red>Emergency Response Team</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Emergency Response Team;jobban4=\ref[M]'>Emergency Response Team</a></td>"


		//Vox Raider
		if(jobban_isbanned(M, "Vox Raider") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Vox Raider;jobban4=\ref[M]'><font color=red>Vox&nbsp;Raider</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Vox Raider;jobban4=\ref[M]'>Vox&nbsp;Raider</a></td>"

/*		//Malfunctioning AI	//Removed Malf-bans because they're a pain to impliment
		if(jobban_isbanned(M, "malf AI") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'><font color=red>[replacetext("Malf AI", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=malf AI;jobban4=\ref[M]'>[replacetext("Malf AI", " ", "&nbsp")]</a></td>"

		//Alien
		if(jobban_isbanned(M, "alien candidate") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'><font color=red>[replacetext("Alien", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=alien candidate;jobban4=\ref[M]'>[replacetext("Alien", " ", "&nbsp")]</a></td>"

		//Infested Monkey
		if(jobban_isbanned(M, "infested monkey") || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'><font color=red>[replacetext("Infested Monkey", " ", "&nbsp")]</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=infested monkey;jobban4=\ref[M]'>[replacetext("Infested Monkey", " ", "&nbsp")]</a></td>"
*/

		jobs += "</tr></table>"

		//Other races  (BLUE, because I have no idea what other color to make this)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ccccff'><th colspan='1'>Other Races</th></tr><tr align='center'>"

		if(jobban_isbanned(M, "Dionaea"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'><font color=red>Dionaea</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Dionaea;jobban4=\ref[M]'>Dionaea</a></td>"

		if(jobban_isbanned(M, "Trader"))
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Trader;jobban4=\ref[M]'><font color=red>Vox&nbsp;Trader</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];jobban3=Trader;jobban4=\ref[M]'>Vox&nbsp;Trader</font></a></td>"


		jobs += "</tr></table>"


		body = "<body>[jobs]</body>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=800x490")
		return

	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["jobban4"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(M != usr)																//we can jobban ourselves
			if(M.client && M.client.holder && (M.client.holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		if(!job_master)
			to_chat(usr, "Job Master has not been setup!")
			return

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("commanddept")
				for(var/jobPos in command_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("securitydept")
				for(var/jobPos in security_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("engineeringdept")
				for(var/jobPos in engineering_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("medicaldept")
				for(var/jobPos in medical_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("sciencedept")
				for(var/jobPos in science_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("civiliandept")
				for(var/jobPos in civilian_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("cargodept")
				for(var/jobPos in cargo_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("nonhumandept")
				joblist += "pAI"
				for(var/jobPos in nonhuman_positions)
					if(!jobPos)	continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			if("misc")
				for(var/jobPos in misc_positions)
					if(!jobPos) continue
					var/datum/job/temp = job_master.GetJob(jobPos)
					if(!temp) continue
					joblist += temp.title
			else
				joblist += href_list["jobban3"]

		//Create a list of unbanned jobs within joblist
		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(M, job))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len) //at least 1 unbanned job exists in joblist so we have stuff to ban.
			switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
				if("Yes")
					if(config.ban_legacy_system)
						to_chat(usr, "<span class='warning'>Your server is using the legacy banning system, which does not support temporary job bans. Consider upgrading. Aborting ban.</span>")
						return
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
					if(!mins)
						return
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(!reason)
						return

					var/msg
					for(var/job in notbannedlist)
						ban_unban_log_save("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes. reason: [reason]")
						log_admin("[key_name(usr)] temp-jobbanned [key_name(M)] from [job] for [mins] minutes")
						feedback_inc("ban_job_tmp",1)
						DB_ban_record(BANTYPE_JOB_TEMP, M, mins, reason, job)
						feedback_add_details("ban_job_tmp","- [job]")
						jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]") //Legacy banning does not support temporary jobbans.
						if(!msg)
							msg = job
						else
							msg += ", [job]"
					notes_add(M.ckey, "Banned  from [msg] - [reason]")
					message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg] for [mins] minutes</span>", 1)
					to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
					to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
					to_chat(M, "<span class='warning'>This jobban will be lifted in [mins] minutes.</span>")
					href_list["jobban2"] = 1 // lets it fall through and refresh
					return 1
				if("No")
					var/reason = input(usr,"Reason?","Please State Reason","") as text|null
					if(reason)
						var/msg
						for(var/job in notbannedlist)
							ban_unban_log_save("[key_name(usr)] perma-jobbanned [key_name(M)] from [job]. reason: [reason]")
							log_admin("[key_name(usr)] perma-banned [key_name(M)] from [job]")
							feedback_inc("ban_job",1)
							DB_ban_record(BANTYPE_JOB_PERMA, M, -1, reason, job)
							feedback_add_details("ban_job","- [job]")
							jobban_fullban(M, job, "[reason]; By [usr.ckey] on [time2text(world.realtime)]")
							if(!msg)	msg = job
							else		msg += ", [job]"
						notes_add(M.ckey, "Banned  from [msg] - [reason]")
						message_admins("<span class='notice'>[key_name_admin(usr)] banned [key_name_admin(M)] from [msg]</span>", 1)
						to_chat(M, "<span class='warning'><BIG><B>You have been jobbanned by [usr.client.ckey] from: [msg].</B></BIG></span>")
						to_chat(M, "<span class='danger'>The reason is: [reason]</span>")
						to_chat(M, "<span class='warning'>Jobban can be lifted only upon request.</span>")
						href_list["jobban2"] = 1 // lets it fall through and refresh
						return 1
				if("Cancel")
					return

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			if(!config.ban_legacy_system)
				to_chat(usr, "Unfortunately, database based unbanning cannot be done through this panel")
				DB_ban_panel(M.ckey)
				return
			var/msg
			for(var/job in joblist)
				var/reason = jobban_isbanned(M, job)
				if(!reason) continue //skip if it isn't jobbanned anyway
				switch(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm","Yes","No"))
					if("Yes")
						ban_unban_log_save("[key_name(usr)] unjobbanned [key_name(M)] from [job]")
						log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
						DB_ban_unban(M.ckey, BANTYPE_JOB_PERMA, job)
						feedback_inc("ban_job_unban",1)
						feedback_add_details("ban_job_unban","- [job]")
						jobban_unban(M, job)
						if(!msg)	msg = job
						else		msg += ", [job]"
					else
						continue
			if(msg)
				message_admins("<span class='notice'>[key_name_admin(usr)] unbanned [key_name_admin(M)] from [msg]</span>", 1)
				to_chat(M, "<span class='warning'><BIG><B>You have been un-jobbanned by [usr.client.ckey] from [msg].</B></BIG></span>")
				href_list["jobban2"] = 1 // lets it fall through and refresh
			return 1
		return 0 //we didn't do anything!

	else if(href_list["boot2"])
		var/mob/M = locate(href_list["boot2"])
		if (ismob(M))
			if(!check_if_greater_rights_than(M.client))
				return
			to_chat(M, "<span class='warning'>You have been kicked from the server</span>")
			log_admin("[key_name(usr)] booted [key_name(M)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] booted [key_name_admin(M)].</span>", 1)
			//M.client = null
			del(M.client)
/*
	//Player Notes
	else if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				notes_show(ckey)
			if("add")
				notes_add(ckey,href_list["text"])
				notes_show(ckey)
			if("remove")
				notes_remove(ckey,text2num(href_list["from"]),text2num(href_list["to"]))
				notes_show(ckey)
*/
	else if(href_list["removejobban"])
		if(!check_rights(R_BAN))	return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?","Unjobban confirmation", "Yes", "No") == "Yes") && t) //No more misclicks! Unless you do it twice.
				log_admin("[key_name(usr)] removed [t]")
				message_admins("<span class='notice'>[key_name_admin(usr)] removed [t]</span>", 1)
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
				var/t_split = splittext(t, " - ")
				var/key = t_split[1]
				var/job = t_split[2]
				DB_ban_unban(ckey(key), BANTYPE_JOB_PERMA, job)

	else if(href_list["newban"])
		if(!check_rights(R_BAN))	return

		var/mob/M = locate(href_list["newban"])
		if(!ismob(M)) return

		// now you can! if(M.client && M.client.holder)	return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		switch(alert("Temporary Ban?",,"Yes","No", "Cancel"))
			if("Yes")
				var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num|null
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				var/reason = input(usr,"Reason?","reason","Griefer") as text|null
				if(!reason)
					return
				AddBan(M.ckey, M.computer_id, reason, usr.ckey, 1, mins)
				ban_unban_log_save("[usr.client.ckey] has banned [M.ckey]. - Reason: [reason] - This will be removed in [mins] minutes.")
				to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
				to_chat(M, "<span class='warning'>This is a temporary ban, it will be removed in [mins] minutes.</span>")
				feedback_inc("ban_tmp",1)
				DB_ban_record(BANTYPE_TEMP, M, mins, reason)
				feedback_inc("ban_tmp_mins",mins)
				if(config.banappeals)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
				message_admins("<span class='warning'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.</span>")

				del(M.client)
				//del(M)	// See no reason why to delete mob. Important stuff can be lost. And ban can be lifted before round ends.
			if("No")
				var/reason = input(usr,"Reason?","reason","Griefer") as text|null
				if(!reason)
					return
				switch(alert(usr,"IP ban?",,"Yes","No","Cancel"))
					if("Cancel")	return
					if("Yes")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0, M.lastKnownIP)
					if("No")
						AddBan(M.ckey, M.computer_id, reason, usr.ckey, 0, 0)
				var/sticky = alert(usr,"Sticky Ban [M.ckey]? Use this only if you never intend to unban the player.","Sticky Icky","Yes", "No") == "Yes"
				if(sticky)
					world.SetConfig("SYSTEM/keyban",M.ckey,"type=sticky&reason=[reason]&message=[reason]&admin=[ckey(usr.key)]")
					message_admins("[key_name_admin(usr)] has sticky banned [key_name(M)].")
					log_admin("[key_name(usr)] has sticky banned [key_name(M)].")
				to_chat(M, "<span class='warning'><BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG></span>")
				to_chat(M, "<span class='warning'>This is a permanent ban.</span>")
				if(config.banappeals)
					to_chat(M, "<span class='warning'>To try to resolve this matter head to [config.banappeals]</span>")
				else
					to_chat(M, "<span class='warning'>No ban appeals URL has been set.</span>")
				ban_unban_log_save("[usr.client.ckey] has permabanned [M.ckey]. - Reason: [reason] - This is a permanent ban.")
				log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
				message_admins("<span class='warning'>[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.</span>")
				feedback_inc("ban_perma",1)
				DB_ban_record(BANTYPE_PERMA, M, -1, reason)

				del(M.client)
				//del(M)
			if("Cancel")
				return

	else if(href_list["stickyunban"])
		if(!check_rights(R_BAN))	return
		var/key = href_list["stickyunban"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			world.SetConfig("SYSTEM/keyban",key,null)
	else if(href_list["unjobbanf"])
		if(!check_rights(R_BAN))	return

		var/banfolder = href_list["unjobbanf"]
		Banlist.cd = "/base/[banfolder]"
		var/key = Banlist["key"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBanjob(banfolder))
				unjobbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unjobbanpanel()

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["mute"])
		if(!ismob(M))	return
		if(!M.client)	return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type))	mute_type = text2num(mute_type)
		if(!isnum(mute_type))	return

		cmd_admin_mute(M, mute_type)

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>"}
		dat += {"<A href='?src=\ref[src];c_mode2=random'>Random</A><br>"}
		dat += {"Now: [master_mode]"}
		usr << browse(dat, "window=c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A href='?src=\ref[src];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A href='?src=\ref[src];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		usr << browse(dat, "window=f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if (ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		master_mode = href_list["c_mode2"]
		if((master_mode != "mixed") || alert("Do you wish to specify which game modes to be mixed?","Specify Mixed","Yes","No")=="No")
			mixed_modes = list()
			log_admin("[key_name(usr)] set the mode as [master_mode].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [master_mode].</span>", 1)
			to_chat(world, "<span class='notice'><b>The mode is now: [master_mode]</b></span>")
			Game() // updates the main game menu
			world.save_mode(master_mode)
			.(href, list("c_mode"=1))
		else
			var/list/possible = list()
			possible += mixed_allowed
			possible += "DONE"
			possible += "CANCEL"
			if(possible.len < 3)
				return alert(usr, "Not enough possible game modes.", null, null, null, null)
			var/mixed_mode_added = null
			while(possible.len >= 3)
				var/mixed_mode_add = input("Pick game modes to add to the mix. ([mixed_mode_added])", "Specify Mixed") in possible
				possible -= mixed_mode_add
				if(mixed_mode_add == "CANCEL")
					return
				else if(mixed_mode_add == "DONE")
					break
				else
					mixed_modes += mixed_mode_add
					possible -= mixed_mode_add
					if(!mixed_mode_added)
						mixed_mode_added = mixed_mode_add
					else
						mixed_mode_added = "[mixed_mode_added], [mixed_mode_add]"

			log_admin("[key_name(usr)] set the mode as [master_mode] with the following modes: [mixed_mode_added].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the mode as [master_mode] with the following modes: [mixed_mode_added].</span>", 1)
			to_chat(world, "<span class='notice'><b>The mode is now: [master_mode] ([mixed_mode_added])</b></span>")
			Game() // updates the main game menu
			world.save_mode(master_mode)
			.(href, list("c_mode"=1))

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))	return

		if(ticker && ticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]

		if((secret_force_mode != "mixed") || alert("Do you wish to specify which game modes to be mixed?","Specify Secret Mixed","Yes","No")=="No")
			mixed_modes = list()
			log_admin("[key_name(usr)] set the forced secret mode as [secret_force_mode].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode].</span>", 1)
			Game() // updates the main game menu
			.(href, list("f_secret"=1))
		else
			var/list/possible = list()
			possible += mixed_allowed
			possible += "DONE"
			possible += "CANCEL"
			if(possible.len < 3)
				return alert(usr, "Not enough possible game modes.", null, null, null, null)
			var/mixed_mode_added = null
			while(possible.len >= 3)
				var/mixed_mode_add = input("Pick game modes to add to the secret mix. ([mixed_mode_added])", "Specify Secret Mixed") in possible
				possible -= mixed_mode_add
				if(mixed_mode_add == "CANCEL")
					return
				else if(mixed_mode_add == "DONE")
					break
				else
					mixed_modes += mixed_mode_add
					possible -= mixed_mode_add
					if(!mixed_mode_added)
						mixed_mode_added = mixed_mode_add
					else
						mixed_mode_added = "[mixed_mode_added], [mixed_mode_add]"

			log_admin("[key_name(usr)] set the mode as [secret_force_mode] with the following modes: [mixed_mode_added].")
			message_admins("<span class='notice'>[key_name_admin(usr)] set the forced secret mode as [secret_force_mode] with the following modes: [mixed_mode_added].</span>", 1)
			Game() // updates the main game menu
			.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]</span>", 1)
		var/mob/M = H.monkeyize()
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(H)]")
		message_admins("<span class='notice'>[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]</span>", 1)
		var/mob/M = H.corgize()
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))	return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "this can only be used on instances of type /mob")

		var/speech = input("What will [key_name(M)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)	return
		M.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='notice'>[key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]</span>")

	else if(href_list["sendtoprison"])
		// Reworked to be useful for investigating shit.
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Warp to prison?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["sendtoprison"])

		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/turf/prison_cell = pick(prisonwarp)

		if(!prison_cell)
			return

		/*
		var/obj/structure/closet/secure_closet/brig/locker = new /obj/structure/closet/secure_closet/brig(prison_cell)
		locker.opened = 0
		locker.locked = 1

		//strip their stuff and stick it in the crate
		for(var/obj/item/I in M)
			M.u_equip(I,1)
			if(I)
				I.loc = locker
				I.layer = initial(I.layer)
				//I.dropped(M)

		M.update_icons()
		*/

		//so they black out before warping
		M.Paralyse(5)
		M.visible_message(
			"<span class=\"sinister\">You hear the sound of cell doors slamming shut, and [M.name] suddenly vanishes!</span>",
			"<span class=\"sinister\">You hear the sound of cell doors slamming shut!</span>")

		sleep(5)

		if(!M)
			return

		// TODO: play sound here.  Thinking of using Wolfenstein 3D's cell door closing sound.

		M.loc = prison_cell

		/*
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/prisoner = M
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/under/color/orange(prisoner), slot_w_uniform)
			prisoner.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(prisoner), slot_shoes)
		*/

		to_chat(M, "<span class='warning'>You have been sent to the prison station!</span>")
		log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
		message_admins("<span class='notice'>[key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.</span>", 1)

	else if(href_list["tdome1"] || href_list["tdome2"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = null
		var/team = ""

		if(href_list["tdome1"])
			team = "Green"
			M = locate(href_list["tdome1"])
		else if (href_list["tdome2"])
			team = "Red"
			M = locate(href_list["tdome2"])

		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		var/obj/item/packobelongings/pack = null

		switch(team)
			if("Green")
				pack = new /obj/item/packobelongings/green(M.loc)
				pack.x = map.tDomeX+2
			if("Red")
				pack = new /obj/item/packobelongings/red(M.loc)
				pack.x = map.tDomeX-2

		pack.z = map.tDomeZ //the players' belongings are stored there, in the Thunderdome Admin lodge.
		pack.y = map.tDomeY

		pack.name = "[M.real_name]'s belongings"

		for(var/obj/item/I in M)
			if(istype(I,/obj/item/clothing/glasses))
				var/obj/item/clothing/glasses/G = I
				if(G.prescription)
					continue
			M.u_equip(I,1)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				//I.dropped(M)
				I.loc = pack

		var/obj/item/weapon/card/id/thunderdome/ident = null

		switch(team)
			if("Green")
				ident = new /obj/item/weapon/card/id/thunderdome/green(M)
				ident.name = "[M.real_name]'s Thunderdome Green ID"
			if("Red")
				ident = new /obj/item/weapon/card/id/thunderdome/red(M)
				ident.name = "[M.real_name]'s Thunderdome Red ID"

		if(!iscarbon(M))
			qdel(ident)

		switch(team)
			if("Green")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_green/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_green(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.loc = pack
					K.uniform = JS
					K.uniform.loc = K
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.loc = pack
					K.equip_to_slot_or_del(ident, slot_r_hand)
					K.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/green(K), slot_l_hand)
					K.regenerate_icons()

			if("Red")
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(H), slot_w_uniform)
					H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
					H.equip_to_slot_or_del(ident, slot_wear_id)
					H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(H), slot_belt)
					H.regenerate_icons()
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					var/obj/item/clothing/monkeyclothes/jumpsuit_red/JS = new /obj/item/clothing/monkeyclothes/jumpsuit_red(K)
					var/obj/item/clothing/monkeyclothes/olduniform = null
					var/obj/item/clothing/monkeyclothes/oldhat = null
					if(K.uniform)
						olduniform = K.uniform
						K.uniform = null
						olduniform.loc = pack
					K.uniform = JS
					K.uniform.loc = K
					if(K.hat)
						oldhat = K.hat
						K.hat = null
						oldhat.loc = pack
					K.equip_to_slot_or_del(ident, slot_r_hand)
					K.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/thunderdome/red(K), slot_l_hand)
					K.regenerate_icons()

		if(pack.contents.len == 0)
			qdel(pack)

		switch(team)
			if("Green")
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team Green)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team Green)", 1)
				M.loc = pick(tdome1)
			if("Red")
				log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team Red)")
				message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team Red)", 1)
				M.loc = pick(tdome2)

		to_chat(M, "<span class='danger'>You have been chosen to fight for the [team] Team. [pick(\
		"The wheel of fate is turning!",\
		"Heaven or Hell!",\
		"Set Spell Card!",\
		"Hologram Summer Again!",\
		"Get ready for the next battle!",\
		"Fight for your life!",\
		)]</span>")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeadmin)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(istype(M, /mob/living/silicon/ai))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in M)
			M.u_equip(I,1)
			if(I)
				I.loc = M.loc
				I.layer = initial(I.layer)
				//I.dropped(M)

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = M
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), slot_w_uniform)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), slot_shoes)
		M.Paralyse(5)
		sleep(5)
		M.loc = pick(tdomeobserve)
		spawn(50)
			to_chat(M, "<span class='notice'>You have been sent to the Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Observer.)", 1)

	else if(href_list["revive"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(config.allow_admin_rev)
			L.revive(0)
			message_admins("<span class='warning'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>", 1)
			log_admin("[key_name(usr)] healed / revived [key_name(L)]")
		else
			to_chat(usr, "Admin Rejuvinates have been disabled")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		message_admins("<span class='warning'>Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!</span>", 1)
		log_admin("[key_name(usr)] AIized [key_name(H)]")
		var/mob/M = H.AIize()
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_alienize(H)
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_slimeize(H)
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makecluwne"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makecluwne"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_cluwneize(H)
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_robotize(H)
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makemommi"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["makemommi"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/mob/M = usr.client.cmd_admin_mommify(H)
		if(M)
			if(M.client == CLIENT) usr = M //We probably transformed ourselves
			show_player_panel(M)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))	return

		var/mob/M = locate(href_list["makeanimal"])
		if(istype(M, /mob/new_player))
			to_chat(usr, "This cannot be used on instances of type /mob/new_player")
			return

		var/mob/new_mob = usr.client.cmd_admin_animalize(M)
		if(new_mob && new_mob != M)
			if(new_mob.client == CLIENT) usr = new_mob //We probably transformed ourselves
			show_player_panel(new_mob)

	else if(href_list["togmutate"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locate(href_list["togmutate"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		var/block=text2num(href_list["block"])
		//testing("togmutate([href_list["block"]] -> [block])")
		usr.client.cmd_admin_toggle_block(H,block)
		show_player_panel(H)
		//H.regenerate_icons()

/***************** BEFORE**************

	if (href_list["l_players"])
		var/dat = "<B>Name/Real Name/Key/IP:</B><HR>"
		for(var/mob/M in world)
			var/foo = ""
			if (ismob(M) && M.client)
				if(!M.client.authenticated && !M.client.authenticating)
					foo += text("\[ <A HREF='?src=\ref[];adminauth=\ref[]'>Authorize</A> | ", src, M)
				else
					foo += text("\[ <B>Authorized</B> | ")
				if(M.start)
					if(!istype(M, /mob/living/carbon/monkey))
						foo += text("<A HREF='?src=\ref[];monkeyone=\ref[]'>Monkeyize</A> | ", src, M)
					else
						foo += text("<B>Monkeyized</B> | ")
					if(istype(M, /mob/living/silicon/ai))
						foo += text("<B>Is an AI</B> | ")
					else
						foo += text("<A HREF='?src=\ref[];makeai=\ref[]'>Make AI</A> | ", src, M)
					if(M.z != 2)
						foo += text("<A HREF='?src=\ref[];sendtoprison=\ref[]'>Prison</A> | ", src, M)
						foo += text("<A HREF='?src=\ref[];sendtomaze=\ref[]'>Maze</A> | ", src, M)
					else
						foo += text("<B>On Z = 2</B> | ")
				else
					foo += text("<B>Hasn't Entered Game</B> | ")
				foo += text("<A HREF='?src=\ref[];revive=\ref[]'>Heal/Revive</A> | ", src, M)

				foo += text("<A HREF='?src=\ref[];forcespeech=\ref[]'>Say</A> \]", src, M)
			dat += text("N: [] R: [] (K: []) (IP: []) []<BR>", M.name, M.real_name, (M.client ? M.client : "No client"), M.lastKnownIP, foo)

		usr << browse(dat, "window=players;size=900x480")

*****************AFTER******************/

// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["adminplayerobservejump"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		if(C) C.jumptomob(M)

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["cult_nextobj"])
		if(alert(usr, "Validate the current Cult objective and unlock the next one?", "Cult Cheat Code", "Yes", "No") != "Yes")
			return

		var/datum/game_mode/cult/cult_round = find_active_mode("cult")
		if(!cult_round)
			alert("Couldn't locate cult mode datum! This shouldn't ever happen, tell a coder!")
			return

		cult_round.bypass_phase()
		message_admins("Admin [key_name_admin(usr)] has unlocked the Cult's next objective.")
		log_admin("Admin [key_name_admin(usr)] has unlocked the Cult's next objective.")
		check_antagonists()

	else if(href_list["cult_mindspeak"])
		var/input = stripped_input(usr, "Communicate to all the cultists with the voice of Nar-Sie", "Voice of Nar-Sie", "")
		if(!input)
			return

		for(var/datum/mind/H in ticker.mode.cult)
			if (H.current)
				to_chat(H.current, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>[input]</span></span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><span class='danger'>Nar-Sie</span> murmurs, <span class='sinister'>[input]</span></span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Nar-Sie.")
		log_narspeak("[key_name(usr)] Voice of Nar-Sie: [input]")

	else if(href_list["cult_privatespeak"])
		var/mob/M = locate(href_list["cult_privatespeak"])
		if(!M)
			return

		var/input = stripped_input(usr, "Whisper to [M.real_name] with the voice of Nar-Sie", "Voice of Nar-Sie", "")
		if(!input)
			return

		to_chat(M, "<span class='game say'><span class='danger'>Nar-Sie</span> whispers to you, <span class='sinister'>[input]</span></span>")

		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><span class='danger'>Nar-Sie</span> whispers to [M.real_name], <span class='sinister'>[input]</span></span>")

		message_admins("Admin [key_name_admin(usr)] has talked with the Voice of Nar-Sie.")

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_ADMIN))	return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))	C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		output_ai_laws()

	else if(href_list["adminmoreinfo"])
		var/mob/M = locate(href_list["adminmoreinfo"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/location_description = ""
		var/special_role_description = ""
		var/health_description = ""
		var/gender_description = ""
		var/species_description = "Not A Human"
		var/turf/T = get_turf(M)

		//Location
		if(isturf(T))
			if(isarea(T.loc))
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
			else
				location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

		//Job + antagonist
		if(M.mind)
			special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
		else
			special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

		//Health
		if(isliving(M))
			var/mob/living/L = M
			var/status
			switch (M.stat)
				if (0) status = "Alive"
				if (1) status = "<font color='orange'><b>Unconscious</b></font>"
				if (2) status = "<font color='red'><b>Dead</b></font>"
			health_description = "Status = [status]"
			health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
		else
			health_description = "This mob type has no health to speak of."

		//Gener
		switch(M.gender)
			if(MALE,FEMALE)	gender_description = "[M.gender]"
			else			gender_description = "<font color='red'><b>[M.gender]</b></font>"

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			species_description = "[H.species ? H.species.name : "<span class='danger'><b>No Species</b></span>"]"
		to_chat(src.owner, "<b>Info about [M.name]:</b> ")
		to_chat(src.owner, "Mob type = [M.type]; Species = [species_description]; Gender = [gender_description]; Damage = [health_description];")
		to_chat(src.owner, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
		to_chat(src.owner, "Location = [location_description];")
		to_chat(src.owner, "[special_role_description]")
		to_chat(src.owner, "(<a href='?src=\ref[usr];priv_msg=\ref[M]'>PM</a>) (<A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[M]'>VV</A>) (<A HREF='?src=\ref[src];subtlemessage=\ref[M]'>SM</A>) (<A HREF='?src=\ref[src];adminplayerobservejump=\ref[M]'>JMP</A>) (<A HREF='?src=\ref[src];secretsadmin=check_antagonist'>CA</A>)")

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_l_hand )
		if(!(istype(H.l_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
			H.equip_to_slot_or_del( new /obj/item/weapon/reagent_containers/food/snacks/cookie(H), slot_r_hand )
			if(!(istype(H.r_hand,/obj/item/weapon/reagent_containers/food/snacks/cookie)))
				log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				message_admins("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
				return
			else
				H.update_inv_r_hand()//To ensure the icon appears in the HUD
		else
			H.update_inv_l_hand()
		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		message_admins("[key_name(H)] got their cookie, spawned by [key_name(src.owner)]")
		feedback_inc("admin_cookies_spawned",1)
		to_chat(H, "<span class='notice'>Your prayers have been answered!! You received the <b>best cookie</b>!</span>")

	else if(href_list["addcancer"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/living/carbon/human/H = locate(href_list["addcancer"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		if(alert(src.owner, "Are you sure you wish to inflict cancer upon [key_name(H)]?",  "Confirm Cancer?" , "Yes" , "No") != "Yes")
			return

		log_admin("[key_name(H)] was inflicted with cancer, courtesy of [key_name(src.owner)]")
		message_admins("[key_name(H)] was inflicted with cancer, courtesy of [key_name(src.owner)]")
		H.add_cancer()

	else if(href_list["BlueSpaceArtillery"])
		if(!check_rights(R_ADMIN|R_FUN))	return

		var/mob/living/M = locate(href_list["BlueSpaceArtillery"])
		if(!isliving(M))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		if(alert(src.owner, "Are you sure you wish to hit [key_name(M)] with Blue Space Artillery?",  "Confirm Firing?" , "Yes" , "No") != "Yes")
			return

		if(BSACooldown)
			to_chat(src.owner, "Standby!  Reload cycle in progress!  Gunnary crews ready in five seconds!")
			return

		BSACooldown = 1
		spawn(50)
			BSACooldown = 0

		to_chat(M, "You've been hit by bluespace artillery!")
		log_admin("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")
		message_admins("[key_name(M)] has been hit by Bluespace Artillery fired by [src.owner]")

		var/obj/effect/stop/S
		S = new /obj/effect/stop
		S.victim = M
		S.loc = M.loc
		spawn(20)
			del(S)

		var/turf/simulated/floor/T = get_turf(M)
		if(istype(T))
			if(prob(80))	T.break_tile_to_plating()
			else			T.break_tile()

		if(M.health == 1)
			M.gib()
		else
			M.adjustBruteLoss( min( 99 , (M.health - 1) )    )
			M.Stun(20)
			M.Weaken(20)
			M.stuttering = 20

	else if(href_list["CentcommReply"])
		var/mob/M = locate(href_list["CentcommReply"])
		var/receive_type
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!istype(H.ears, /obj/item/device/radio/headset))
				to_chat(usr, "The person you are trying to contact is not wearing a headset")
				return
			receive_type = "headset"
		else if(istype(M, /mob/living/silicon))
			receive_type = "official communication channel"
		if(!receive_type)
			to_chat(usr, "This mob type cannot be replied to")
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their [receive_type].","Outgoing message from Central Command", "")
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [M] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(M)]'s Centcomm message with the message [input].")
		message_admins("[src.owner] replied to [key_name(M)]'s Centcom message with: \"[input]\"")
		to_chat(M, "You hear something crackle from your [receive_type] for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows. <b>\"[input]\"</b>  Message ends.\"")

	else if(href_list["SyndicateReply"])
		var/mob/M = locate(href_list["SyndicateReply"])
		var/receive_type
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!istype(H.ears, /obj/item/device/radio/headset))
				to_chat(usr, "The person you are trying to contact is not wearing a headset")
				return
			receive_type = "headset"
		else if(istype(M, /mob/living/silicon))
			receive_type = "undetectable communications channel"
		if(!receive_type)
			to_chat(usr, "This mob type cannot be replied to")
			return

		var/input = input(src.owner, "Please enter a message to reply to [key_name(M)] via their [receive_type].","Outgoing message from The Syndicate", "")
		if(!input)	return

		to_chat(src.owner, "You sent [input] to [M] via a secure channel.")
		log_admin("[src.owner] replied to [key_name(M)]'s Syndicate message with the message [input].")
		message_admins("[src.owner] replied to [key_name(M)]'s Syndicate message with: \"[input]\"")
		to_chat(M, "You hear something crackle from your [receive_type] for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. <b>\"[input]\"</b>  Message ends.\"")

	else if(href_list["CentcommFaxView"])
		var/obj/item/weapon/paper/P = locate(href_list["CentcommFaxView"])
		var/info_2 = ""
		if(P.img)
			usr << browse_rsc(P.img.img, "tmp_photo.png")
			info_2 = "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' /><br>"
		usr << browse("<HTML><HEAD><TITLE>Centcomm Fax Message</TITLE></HEAD><BODY>[info_2][P.info][P.stamps]</BODY></HTML>", "window=Centcomm Fax Message")

	else if(href_list["CentcommFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["CentcommFaxReply"])


		var/sent = input(src.owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from Centcomm", "") as message|null
		if(!sent)	return

		var/sentname = input(src.owner, "Pick a title for the report", "Title") as text|null

		SendFax(sent, sentname, centcomm = 1)

		to_chat(src.owner, "Message reply to transmitted successfully.")
		log_admin("[key_name(src.owner)] replied to a fax message from [key_name(H)]: [sent]")
		message_admins("[key_name_admin(src.owner)] replied to a fax message from [key_name_admin(H)]", 1)


	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))	return

		if(alert(usr, "Confirm?", "Message", "Yes", "No") != "Yes")	return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["rapsheet"])
		checkSessionKey()
		// build the link
		//var/dat = "[config.vgws_base_url]/index.php/rapsheet/?s=[sessKey]"
		//if(href_list["rsckey"])
		//.	dat += "&ckey=[href_list["rsckey"]]"
//		to_chat(usr, link(dat))
		usr << link(getVGPanel("rapsheet", admin = 1, query = list("ckey" = href_list["rsckey"])))
		return

	else if(href_list["bansheet"])
		//checkSessionKey()
//		to_chat(usr, link("[config.vgws_base_url]/index.php/rapsheet/?s=[sessKey]"))
		usr << link(getVGPanel("rapsheet", admin = 1))
		return

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			to_chat(usr, "This can only be used on instances of type /mob.")
			return
		show_traitor_panel(M)

	// /vg/
	else if(href_list["set_base_laws"])
		if(!check_rights(R_FUN))
			to_chat(usr, "<span class='warning'>You don't have +FUN. Go away.</span>")
			return
		var/lawtypes = typesof(/datum/ai_laws) - /datum/ai_laws
		var/selected_law = input("Select the default lawset desired.","Lawset Selection",null) as null|anything in lawtypes
		if(!selected_law) return
		var/subject="Unknown"
		switch(href_list["set_base_laws"])
			if("ai")
				base_law_type = selected_law
				subject = "AIs and Cyborgs"
			if("mommi")
				mommi_base_law_type = selected_law
				subject = "MoMMIs"
		to_chat(usr, "<span class='notice'>New [subject] will spawn with the [selected_law] lawset.</span>")
		log_admin("[key_name(src.owner)] set the default laws of [subject] to: [selected_law]")
		message_admins("[key_name_admin(src.owner)] set the default laws of [subject] to: [selected_law]", 1)
		lawchanges.Add("[key_name_admin(src.owner)] set the default laws of [subject] to: [selected_law]")

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))	return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))	return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))	return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))	return
		return create_mob(usr)

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))	return

		if(!config.allow_admin_spawning)
			to_chat(usr, "Spawning of items is not allowed.")
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			else if(ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			else if(ispath(path, /obj/effect/bhole))
				if(!check_rights(R_FUN,0))
					removed_paths += dirty_path
					continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + jointext(removed_paths, "\n"))

		var/list/offset = splittext(href_list["offset"],",")
		var/number = Clamp(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in alldirs))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","inhand","inmarked") ))
			where = "onfloor"

		if( where == "inhand" )
			to_chat(usr, "Support for inhand not available yet. Will spawn on floor.")
			where = "onfloor"

		if ( where == "inhand" )	//Can only give when human or monkey
			if ( !( ishuman(usr) || ismonkey(usr) ) )
				to_chat(usr, "Can only spawn in hand when you're a human or a monkey.")
				where = "onfloor"
			else if ( usr.get_active_hand() )
				to_chat(usr, "Your active hand is full. Spawning on floor.")
				where = "onfloor"

		if ( where == "inmarked" )
			if ( !marked_datum )
				to_chat(usr, "You don't have any object marked. Abandoning spawn.")
				return
			else
				if ( !istype(marked_datum,/atom) )
					to_chat(usr, "The object you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return

		var/atom/target //Where the object will be spawned
		switch ( where )
			if ( "onfloor" )
				switch (href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if ( "inmarked" )
				target = marked_datum

		if(target)
			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.dir = obj_dir
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/M = O
									M.real_name = obj_name

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)] at [formatJumpTo(get_turf(usr))]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)] at [formatJumpTo(get_turf(usr))]", 1)
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)] at [formatJumpTo(get_turf(usr))]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)] at [formatJumpTo(get_turf(usr))]", 1)
					break
		return

	else if(href_list["secretsfun"])
		if(!check_rights(R_FUN))	return

		switch(href_list["secretsfun"])
			if("sec_clothes")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC")
				for(var/obj/item/clothing/under/O in world)
					del(O)
			if("sec_all_clothes")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SAC")
				for(var/obj/item/clothing/O in world)
					del(O)
			if("sec_classic1")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC1")
				for(var/obj/item/clothing/suit/fire/O in world)
					del(O)
				for(var/obj/structure/grille/O in world)
					del(O)
/*					for(var/obj/machinery/vehicle/pod/O in world)
					for(var/mob/M in src)
						M.loc = src.loc
						if (M.client)
							M.client.perspective = MOB_PERSPECTIVE
							M.client.eye = M
					del(O)*/
			if("monkey")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.monkeyize()
			if("corgi")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","M")
				for(var/mob/living/carbon/human/H in mob_list)
					spawn(0)
						H.corgize()
			if("striketeam")
				if(usr.client.strike_team())
					feedback_inc("admin_secrets_fun_used",1)
					feedback_add_details("admin_secrets_fun_used","Strike")
			if("tripleAI")
				usr.client.triple_ai()
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TriAI")
			if("gravity")
				if(!(ticker && ticker.mode))
					to_chat(usr, "Please wait until the game starts!  Not sure how it will work otherwise.")
					return
				gravity_is_on = !gravity_is_on
				for(var/area/A in areas)
					A.gravitychange(gravity_is_on,A)
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Grav")
				if(gravity_is_on)
					log_admin("[key_name(usr)] toggled gravity on.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity on.</span>", 1)
					command_alert("Gravity generators are again functioning within normal parameters. Sorry for any inconvenience.")
				else
					log_admin("[key_name(usr)] toggled gravity off.", 1)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled gravity off.</span>", 1)
					command_alert("Feedback surge detected in mass-distributions systems. Artifical gravity has been disabled whilst the system reinitializes. Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day.")
			if("wave")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Meteor")
				log_admin("[key_name(usr)] spawned a meteor wave", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] spawned a meteor wave.</span>", 1)
				new /datum/event/meteor_wave
			if("goblob")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Blob")
				log_admin("[key_name(usr)] spawned a blob", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] spawned a blob.</span>", 1)
				new /datum/event/blob

			if("aliens")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","Aliens")
				log_admin("[key_name(usr)] spawned an alien infestation", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] attempted an alien infestation</span>", 1)
				new /datum/event/alien_infestation


			if("power")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","P")
				log_admin("[key_name(usr)] made all areas powered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all areas powered</span>", 1)
				power_restore()
			if("unpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","UP")
				log_admin("[key_name(usr)] made all areas unpowered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all areas unpowered</span>", 1)
				power_failure()
			if("quickpower")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","QP")
				log_admin("[key_name(usr)] made all SMESs powered", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] made all SMESs powered</span>", 1)
				power_restore_quick()
			if("breaklink")
				log_admin("[key_name(usr)] broke the link with central command", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] broke the link with central command</span>", 1)
				unlink_from_centcomm()
			if("makelink")
				log_admin("[key_name(usr)] created a link with central command", 1)
				message_admins("<span class='notice'>[key_name_admin(usr)] created a link with central command</span>", 1)
				link_to_centcomm()
			if("activateprison")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AP")
				to_chat(world, "<span class='notice'><B>Transit signature detected.</B></span>")
				to_chat(world, "<span class='notice'><B>Incoming shuttle.</B></span>")
				/*
				var/A = locate(/area/shuttle_prison)
				for(var/atom/movable/AM as mob|obj in A)
					AM.z = 1
					AM.Move()
				*/
				message_admins("<span class='notice'>[key_name_admin(usr)] sent the prison shuttle to the station.</span>", 1)
			if("deactivateprison")
				/*
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","DP")
				var/A = locate(/area/shuttle_prison)
				for(var/atom/movable/AM as mob|obj in A)
					AM.z = 2
					AM.Move()
				*/
				message_admins("<span class='notice'>[key_name_admin(usr)] sent the prison shuttle back.</span>", 1)
			if("toggleprisonstatus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TPS")
				for(var/obj/machinery/computer/prison_shuttle/PS in machines)
					PS.allowedtocall = !(PS.allowedtocall)
					message_admins("<span class='notice'>[key_name_admin(usr)] toggled status of prison shuttle to [PS.allowedtocall].</span>", 1)
			if ("prisonwarp")
				if (!ticker)
					alert("The game hasn't started yet!", null, null, null, null, null)
					return

				feedback_inc("admin_secrets_fun_used", 1)

				feedback_add_details("admin_secrets_fun_used", "PW")

				message_admins("<span class='notice'>[key_name_admin(usr)] teleported all players to the prison station.</span>", 1)

				var/security

				for (var/mob/living/carbon/human/H in mob_list)
					if (H)
						if (H in prisonwarped) // don't warp them if they aren't ready or are already there
							continue

						security = FALSE

						H.Paralyse(5)

						var/obj/item/weapon/card/id/id = H.get_id_card()

						if(id)
							if (access_security in id.access)
								security = TRUE

						if (!security)
							// strip their stuff before they teleport into a cell :downs:
							for (var/obj/item/I in H.get_all_slots())
								H.drop_from_inventory(I)

							H.loc = pick(prisonwarp) // teleport person to cell

							H.equip_to_slot_or_del(new /obj/item/clothing/under/color/prisoner(H), slot_w_uniform)

							H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
						else
							H.loc = pick(prisonsecuritywarp) // teleport security person

						prisonwarped += H
			if("traitor_all")
				if(!ticker)
					alert("The game hasn't started yet!")
					return
				var/objective = copytext(sanitize(input("Enter an objective")),1,MAX_MESSAGE_LEN)
				if(!objective)
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TA([objective])")
				for(var/mob/living/carbon/human/H in player_list)
					if(H.stat == 2 || !H.client || !H.mind) continue
					if(is_special_character(H)) continue
					//traitorize(H, objective, 0)
					ticker.mode.traitors += H.mind
					H.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = H
					new_objective.explanation_text = objective
					H.mind.objectives += new_objective
					ticker.mode.greet_traitor(H.mind)
					//ticker.mode.forge_traitor_objectives(H.mind)
					ticker.mode.finalize_traitor(H.mind)
				for(var/mob/living/silicon/A in player_list)
					ticker.mode.traitors += A.mind
					A.mind.special_role = "traitor"
					var/datum/objective/new_objective = new
					new_objective.owner = A
					new_objective.explanation_text = objective
					A.mind.objectives += new_objective
					ticker.mode.greet_traitor(A.mind)
					ticker.mode.finalize_traitor(A.mind)
				message_admins("<span class='notice'>[key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]</span>", 1)
				log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")
			if("moveadminshuttle")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShA")
				move_admin_shuttle()
				message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom administration shuttle</span>", 1)
				log_admin("[key_name(usr)] moved the centcom administration shuttle")
			if("moveferry")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShF")
				if(!transport_shuttle || !transport_shuttle.linked_area)
					to_chat(usr, "There is no transport shuttle!")
					return

				transport_shuttle.move(usr)

				message_admins("<span class='notice'>[key_name_admin(usr)] moved the centcom ferry</span>", 1)
				log_admin("[key_name(usr)] moved the centcom ferry")
			if("movealienship")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ShX")
				move_alien_ship()
				message_admins("<span class='notice'>[key_name_admin(usr)] moved the alien dinghy</span>", 1)
				log_admin("[key_name(usr)] moved the alien dinghy")
			if("togglebombcap")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BC")
				switch(MAX_EXPLOSION_RANGE)
					if(14)	MAX_EXPLOSION_RANGE = 16
					if(16)	MAX_EXPLOSION_RANGE = 20
					if(20)	MAX_EXPLOSION_RANGE = 28
					if(28)	MAX_EXPLOSION_RANGE = 56
					if(56)	MAX_EXPLOSION_RANGE = 128
					else	MAX_EXPLOSION_RANGE = 14
				var/range_dev = MAX_EXPLOSION_RANGE *0.25
				var/range_high = MAX_EXPLOSION_RANGE *0.5
				var/range_low = MAX_EXPLOSION_RANGE
				message_admins("<span class='danger'> [key_name_admin(usr)] changed the bomb cap to [range_dev], [range_high], [range_low]</span>", 1)
				log_admin("[key_name_admin(usr)] changed the bomb cap to [MAX_EXPLOSION_RANGE]")

			if("flicklights")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FL")
				while(!usr.stat)
//knock yourself out to stop the ghosts
					for(var/mob/M in player_list)
						if(M.stat != 2 && prob(25))
							var/area/AffectedArea = get_area(M)
							if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
								AffectedArea.power_light = 0
								AffectedArea.power_change()
								spawn(rand(55,185))
									AffectedArea.power_light = 1
									AffectedArea.power_change()
								var/Message = rand(1,4)
								switch(Message)
									if(1)
										M.show_message(text("<span class='notice'>You shudder as if cold...</span>"), 1)
									if(2)
										M.show_message(text("<span class='notice'>You feel something gliding across your back...</span>"), 1)
									if(3)
										M.show_message(text("<span class='notice'>Your eyes twitch, you feel like something you can't see is here...</span>"), 1)
									if(4)
										M.show_message(text("<span class='notice'>You notice something moving out of the corner of your eye, but nothing is there...</span>"), 1)
								for(var/obj/W in orange(5,M))
									if(prob(25) && !W.anchored)
										step_rand(W)
					sleep(rand(100,1000))
				for(var/mob/M in player_list)
					if(M.stat != 2)
						M.show_message(text("<span class='notice'>The chilling wind suddenly stops...</span>"), 1)
/*				if("shockwave")
				to_chat(world, "<span class='danger'><big>ALERT: STATION STRESS CRITICAL</big></span>")
				sleep(60)
				to_chat(world, "<span class='danger'><big>ALERT: STATION STRESS CRITICAL. TOLERABLE LEVELS EXCEEDED!</big></span>")
				sleep(80)
				to_chat(world, "<span class='danger'><big>ALERT: STATION STRUCTURAL STRESS CRITICAL. SAFETY MECHANISMS FAILED!</big></span>")
				sleep(40)
				for(var/mob/M in world)
					shake_camera(M, 400, 1)
				for(var/obj/structure/window/W in world)
					spawn(0)
						sleep(rand(10,400))
						W.ex_act(rand(2,1))
				for(var/obj/structure/grille/G in world)
					spawn(0)
						sleep(rand(20,400))
						G.ex_act(rand(2,1))
				for(var/obj/machinery/door/D in world)
					spawn(0)
						sleep(rand(20,400))
						D.ex_act(rand(2,1))
				for(var/turf/station/floor/Floor in world)
					spawn(0)
						sleep(rand(30,400))
						Floor.ex_act(rand(2,1))
				for(var/obj/structure/cable/Cable in world)
					spawn(0)
						sleep(rand(30,400))
						Cable.ex_act(rand(2,1))
				for(var/obj/structure/closet/Closet in world)
					spawn(0)
						sleep(rand(30,400))
						Closet.ex_act(rand(2,1))
				for(var/obj/machinery/Machinery in world)
					spawn(0)
						sleep(rand(30,400))
						Machinery.ex_act(rand(1,3))
				for(var/turf/station/wall/Wall in world)
					spawn(0)
						sleep(rand(30,400))
						Wall.ex_act(rand(2,1)) */
			if("wave")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","MW")
				new /datum/event/meteor_wave

			if("gravanomalies")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","GA")
				command_alert("Gravitational anomalies detected on the station. There is no additional data.", "Anomaly Alert")
				world << sound('sound/AI/granomalies.ogg')
				var/turf/T = pick(blobstart)
				var/obj/effect/bhole/bh = new /obj/effect/bhole( T.loc, 30 )
				spawn(rand(100, 600))
					del(bh)

			if("timeanomalies")	//dear god this code was awful :P Still needs further optimisation
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","STA")
				//moved to its own dm so I could split it up and prevent the spawns copying variables over and over
				//can be found in code\game\game_modes\events\wormholes.dm
				wormhole_event()

			if("goblob")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BL")
				mini_blob_event()
				message_admins("[key_name_admin(usr)] has spawned blob", 1)
			if("aliens")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AL")
				if(aliens_allowed)
					new /datum/event/alien_infestation
					message_admins("[key_name_admin(usr)] has spawned aliens", 1)
			if("alien_silent")								//replaces the spawn_xeno verb
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ALS")
				if(aliens_allowed)
					create_xeno()
			if("spiders")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SL")
				new /datum/event/spider_infestation
				message_admins("[key_name_admin(usr)] has spawned spiders", 1)
			if("comms_blackout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","CB")
				var/answer = alert(usr, "Would you like to alert the crew?", "Alert", "Yes", "No")
				if(answer == "Yes")
					communications_blackout(0)
				else
					communications_blackout(1)
				message_admins("[key_name_admin(usr)] triggered a communications blackout.", 1)

			if("pda_spam")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","PDA")
				new /datum/event/pda_spam

			if("carp")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","C")
				var/choice = input("You sure you want to spawn carp?") in list("Badmin", "Cancel")
				if(choice == "Badmin")
					message_admins("[key_name_admin(usr)] has spawned carp.", 1)
					new /datum/event/carp_migration
			if("radiation")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","R")
				message_admins("[key_name_admin(usr)] has has irradiated the station", 1)
				new /datum/event/radiation_storm
			if("immovable")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","IR")
				message_admins("[key_name_admin(usr)] has sent an immovable rod to the station", 1)
				immovablerod()
			if("prison_break")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","PB")
				message_admins("[key_name_admin(usr)] has allowed a prison break", 1)
				prison_break()
			if("lightout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","LO")
				message_admins("[key_name_admin(usr)] has broke a lot of lights", 1)
				lightsout(1,2)
			if("blackout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BO")
				message_admins("[key_name_admin(usr)] broke all lights", 1)
				lightsout(0,0)
			if("whiteout")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","WO")
				for(var/obj/machinery/light/L in alllights)
					L.fix()
				message_admins("[key_name_admin(usr)] fixed all lights", 1)
			if("aliens")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AL")
				message_admins("[key_name_admin(usr)] has spawned aliens", 1)
				//makeAliens()
				new /datum/event/alien_infestation
			if("radiation")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RAD")
				message_admins("[key_name_admin(usr)] has started a radiation event", 1)
				//makeAliens()
				new /datum/event/radiation_storm
			if("floorlava")
				if(floorIsLava)
					to_chat(usr, "The floor is lava already.")
					return
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","LF")

				//Options
				var/length = input(usr, "How long will the lava last? (in seconds)", "Length", 180) as num
				length = min(abs(length), 1200)

				var/damage = input(usr, "How deadly will the lava be?", "Damage", 2) as num
				damage = min(abs(damage), 100)

				var/sure = alert(usr, "Are you sure you want to do this?", "Confirmation", "YES!", "Nah")
				if(sure == "Nah")
					return
				floorIsLava = 1

				message_admins("[key_name_admin(usr)] made the floor LAVA! It'll last [length] seconds and it will deal [damage] damage to everyone.", 1)
				var/count = 0
				var/list/lavaturfs = list()
				for(var/turf/simulated/floor/F in turfs)
					count++
					if(!(count % 50000)) sleep(world.tick_lag)
					if(F.z == 1)
						F.name = "lava"
						F.desc = "The floor is LAVA!"
						F.overlays += "lava"
						F.lava = 1
						lavaturfs += F

				spawn(0)
					for(var/i = i, i < length, i++) // 180 = 3 minutes
						if(damage)
							for(var/mob/living/carbon/L in living_mob_list)
								if(istype(L.loc, /turf/simulated/floor)) // Are they on LAVA?!
									var/turf/simulated/floor/F = L.loc
									if(F.lava)
										var/safe = 0
										for(var/obj/structure/O in F.contents)
											if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
												safe = 1
												break
										if(!safe)
											L.adjustFireLoss(damage)


						sleep(10)

					for(var/turf/simulated/floor/F in lavaturfs) // Reset everything.
						if(F.z == 1)
							F.name = initial(F.name)
							F.desc = initial(F.desc)
							F.overlays.len = 0
							F.lava = 0
							F.update_icon()
					floorIsLava = 0
				return
			if("thebees")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BEE")
				var/answer = alert("What's this? A Space Station woefully underpopulated by bees?",,"Let's fix it!","On second thought, let's not.")
				if(answer=="Let's fix it!")
					message_admins("[key_name_admin(usr)] unleashed the bees onto the crew.", 1)
					to_chat(world, "<font size='10' color='red'><b>NOT THE BEES!</b></font>")
					world << sound('sound/effects/bees.ogg')
					for(var/mob/living/M in player_list)
						var/mob/living/simple_animal/bee/BEE = new(get_turf(M))
						BEE.strength = 16
						BEE.toxic = 5
						BEE.mut = 2
						BEE.feral = 25
						BEE.target = M
						BEE.icon_state = "bees_swarm-feral"

			if("virus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","V")
				var/answer = alert("Do you want this to be a greater disease or a lesser one?",,"Greater","Lesser")
				if(answer=="Lesser")
					virus2_lesser_infection()
					message_admins("[key_name_admin(usr)] has triggered a lesser virus outbreak.", 1)
				else
					virus2_greater_infection()
					message_admins("[key_name_admin(usr)] has triggered a greater virus outbreak.", 1)
			if("retardify")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","RET")
				for(var/mob/living/carbon/human/H in player_list)
					to_chat(H, "<span class='danger'>You suddenly feel stupid.</span>")
					H.setBrainLoss(60)
				message_admins("[key_name_admin(usr)] made everybody retarded")
			if("fakeguns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FG")
				for(var/obj/item/W in world)
					if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
						continue
					W.icon = 'icons/obj/gun.dmi'
					W.icon_state = "revolver"
					W.item_state = "gun"
				message_admins("[key_name_admin(usr)] made every item look like a gun")
			if("experimentalguns")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","GUN")
				for(var/mob/living/carbon/C in player_list)
					var/list/turflist = list()
					for(var/turf/T in orange(src,1))
						turflist += T
					if(!turflist.len)
						turflist += get_turf(C)
					var/turf/U = pick(turflist)
					var/obj/structure/closet/crate/secure/weapon/experimental/E = new(U)
					to_chat(C, "<span class='danger'>A crate appears next to you. You think you can read \"[E.chosen_set]\" scribbled on it</span>")
					U.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/weapons/emitter2.ogg')
				message_admins("[key_name_admin(usr)] distributed experimental guns to the entire crew")
			if("schoolgirl")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SG")
				for(var/obj/item/clothing/under/W in world)
					W.icon_state = "schoolgirl"
					W.item_state = "w_suit"
					W._color = "schoolgirl"
				message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
				world << sound('sound/AI/animes.ogg')
			if("eagles")//SCRAW
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","EgL")
				for(var/obj/machinery/door/airlock/W in all_doors)
					if(W.z == 1 && !istype(get_area(W), /area/bridge) && !istype(get_area(W), /area/crew_quarters) && !istype(get_area(W), /area/security/prison))
						W.req_access = list()
				message_admins("[key_name_admin(usr)] activated Egalitarian Station mode")
				command_alert("Centcomm airlock control override activated. Please take this time to get acquainted with your coworkers.")
			if("dorf")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","DF")
				for(var/mob/living/carbon/human/B in mob_list)
					B.f_style = "Dward Beard"
					B.update_hair()
				message_admins("[key_name_admin(usr)] activated dorf mode")
			if("ionstorm")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","I")
				generate_ion_law()
				message_admins("[key_name_admin(usr)] triggered an ion storm")
				var/show_log = alert(usr, "Show ion message?", "Message", "Yes", "No")
				if(show_log == "Yes")
					command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert",alert='sound/AI/ionstorm.ogg')
			if("spacevines")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","K")
				new /datum/event/spacevine
				message_admins("[key_name_admin(usr)] has spawned spacevines", 1)
			if("onlyone")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","OO")
				usr.client.only_one()
//				message_admins("[key_name_admin(usr)] has triggered a battle to the death (only one)")
			if("togglenarsie")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","NA")
				var/choice = input("How do you wish for narsie to interact with her surroundings?") in list("CultStation13", "Nar-Singulo")
				if(choice == "CultStation13")
					message_admins("[key_name_admin(usr)] has set narsie's behaviour to \"CultStation13\".")
					narsie_behaviour = "CultStation13"
				if(choice == "Nar-Singulo")
					message_admins("[key_name_admin(usr)] has set narsie's behaviour to \"Nar-Singulo\".")
					narsie_behaviour = "Nar-Singulo"
			if("hellonearth")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","NS")
				var/choice = input("You sure you want to end the round and summon narsie at your location? Misuse of this could result in removal of flags or halarity.") in list("PRAISE SATAN", "Cancel")
				if(choice == "PRAISE SATAN")
					new /obj/machinery/singularity/narsie/large(get_turf(usr))
					message_admins("[key_name_admin(usr)] has summoned narsie and brought about a new realm of suffering.")
			if("supermattercascade")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SC")
				var/choice = input("You sure you want to destroy the universe and create a large explosion at your location? Misuse of this could result in removal of flags or halarity.") in list("NO TIME TO EXPLAIN", "Cancel")
				if(choice == "NO TIME TO EXPLAIN")
					explosion(get_turf(usr), 8, 16, 24, 32, 1)
					new /turf/unsimulated/wall/supermatter(get_turf(usr))
					SetUniversalState(/datum/universal_state/supermatter_cascade)
					message_admins("[key_name_admin(usr)] has managed to destroy the universe with a supermatter cascade. Good job, [key_name_admin(usr)]")
			if("mobswarm")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","MS")
				var/choice = input("Are you sure you want to fill the station with a bunch of unnecessary mobs?") in list("Of course!", "No, I hate timespace anomalies involving fun")
				if(choice == "Of course!")
					var/amt = input("How many would you like to spawn?", 10) as num
					var/mobtype = input("What mob would you like?", "Mob Swarm") as null|anything in typesof(/mob/living)
					message_admins("[key_name_admin(usr)] triggered a mob swarm.")
					new /datum/event/mob_swarm(mobtype, amt)
			if("spawnadminbus")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","AB")
				var/obj/structure/bed/chair/vehicle/adminbus/A = new /obj/structure/bed/chair/vehicle/adminbus(get_turf(usr))
				A.dir = EAST
				A.update_lightsource()
				A.busjuke.dir = EAST
				message_admins("[key_name_admin(usr)] has spawned an Adminbus. Who gave him the keys?")
				log_admin("[key_name_admin(usr)] has spawned an Adminbus.")
			if("spawnselfdummy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TD")
				message_admins("[key_name_admin(usr)] spawned himself as a Test Dummy.")
				log_admin("[key_name_admin(usr)] spawned himself as a Test Dummy.")
				var/turf/T = get_turf(usr)
				var/mob/living/carbon/human/dummy/D = new /mob/living/carbon/human/dummy(T)
				usr.client.cmd_assume_direct_control(D)
				D.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(D), slot_w_uniform)
				D.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(D), slot_shoes)
				D.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(D), slot_ears)
				D.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(D), slot_back)
				D.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival/engineer(D.back), slot_in_backpack)
				T.turf_animation('icons/effects/96x96.dmi',"beamin",-32,0,MOB_LAYER+1,'sound/misc/adminspawn.ogg')
				D.name = "Admin"
				D.real_name = "Admin"
				var/newname = ""
				newname = copytext(sanitize(input(D, "Before you step out as an embodied god, what name do you wish for?", "Choose your name.", "Admin") as null|text),1,MAX_NAME_LEN)
				if (!newname)
					newname = "Admin"
				D.name = newname
				D.real_name = newname
				var/obj/item/weapon/card/id/admin/admin_id = new(D)
				admin_id.registered_name = newname
				D.equip_to_slot_or_del(admin_id, slot_wear_id)
			//False flags and bait below. May cause mild hilarity or extreme pain. Now in one button
			if("fakealerts")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FAKEA")
				var/choice = input("Choose the type of fake alert you wish to trigger","False Flag and Bait Panel") in list("Biohazard", "Lifesigns", "Malfunction", "Ion", "Meteor Wave", "Carp Migration", "Return")
				//Big fat lists of effects, not very modular but at least there's less buttons
				if(choice == "Return") //Actually fuck this
					return //Duh
				if(choice == "Biohazard") //GUISE WE HAVE A BLOB
					var/levelchoice = input("Set the level of the biohazard alert, or leave at 0 to have a random level (1 to 7 supported only)", "Space FEMA Readiness Program", 0) as num
					if(!levelchoice || levelchoice > 7 || levelchoice < 0)
						to_chat(usr, "<span class='warning'>Invalid input range (0 to 7 only)</span>")
						return
					biohazard_alert(level = levelchoice)
					message_admins("[key_name_admin(usr)] triggered a FAKE Biohzard Alert.")
					log_admin("[key_name_admin(usr)] triggered a FAKE Biohzard Alert.")
					return
				if(choice == "Lifesigns") //MUH ALIUMS
					command_alert("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert",alert='sound/AI/aliens.ogg')
					message_admins("[key_name_admin(usr)] triggered a FAKE Lifesign Alert.")
					log_admin("[key_name_admin(usr)] triggered a FAKE Lifesign Alert.")
					return
				if(choice == "Malfunction") //BLOW EVERYTHING
					var/salertchoice = input("Do you wish to include the Hostile Runtimes warning to have an authentic Malfunction Takeover Alert ?", "Nanotrasen Alert Level Monitor") in list("Yes", "No")
					if(salertchoice == "Yes")
						command_alert("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert",alert='sound/AI/aimalf.ogg')
					to_chat(world, "<font size=4 color='red'>Attention! Delta security level reached!</font>")//Don't ACTUALLY set station alert to Delta to avoid fucking shit up for real

					to_chat(world, "<font color='red'>[config.alert_desc_delta]</font>")

					message_admins("[key_name_admin(usr)] triggered a FAKE Malfunction Takeover Alert (Hostile Runtimes alert [salertchoice == "Yes" ? "included":"excluded"])")
					log_admin("[key_name_admin(usr)] triggered a FAKE Malfunction Takeover Alert (Hostile Runtimes alert [salertchoice == "Yes" ? "included":"excluded"])")
					return
				if(choice == "Ion")
					command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert",alert='sound/AI/ionstorm.ogg')
					message_admins("[key_name_admin(usr)] triggered a FAKE Ion Alert.")
					log_admin("[key_name_admin(usr)] triggered a FAKE Ion Alert.")
					return
				if(choice == "Meteor Wave")
					command_alert("A meteor storm has been detected on collision course with the station. Seek shelter within the core of the station immediately.", "Meteor Alert",alert='sound/AI/meteors.ogg')
					message_admins("[key_name_admin(usr)] triggered a FAKE Meteor Alert.")
					log_admin("[key_name_admin(usr)] triggered a FAKE Meteor Alert.")
					return
				if(choice == "Carp Migration")
					command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert")
					message_admins("[key_name_admin(usr)] triggered a FAKE Carp Migration Alert.")
					log_admin("[key_name_admin(usr)] triggered a FAKE Carp Migration Alert.")
					return
			if("fakebooms") //Micheal Bay is in the house !
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","FAKEE")
				var/choice = input("How much high-budget explosions do you want ?", "Micheal Bay SFX Systems", 1) as num
				if(choice < 1) //No negative or null explosion amounts here math genius
					to_chat(usr, "<span class='warning'>Invalid input range (null or negative)</span>")
					return
				message_admins("[key_name_admin(usr)] improvised himself as Micheal Bay and triggered [round(choice)] fake explosions.")
				log_admin("[key_name_admin(usr)] improvised himself as Micheal Bay and triggered [round(choice)] fake explosions.")
				for(var/i = 1 to choice)
					world << sound('sound/effects/explosionfar.ogg')
					sleep(rand(2, 10)) //Sleep 0.2 to 1 second
			if("massbomber")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBM")
				var/choice = alert("Dress every player like Bomberman and give them BBDs?","Bomberman Mode Activation","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_mode = 1
					world << sound('sound/bomberman/start.ogg')
					for(var/mob/living/carbon/human/M in player_list)
						if(M.wear_suit)
							var/obj/item/O = M.wear_suit
							M.u_equip(O,1)
							O.loc = M.loc
							//O.dropped(M)
						if(M.head)
							var/obj/item/O = M.head
							M.u_equip(O,1)
							O.loc = M.loc
							//O.dropped(M)
						M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/bomberman(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/bomberman(M), slot_wear_suit)
						M.equip_to_slot_or_del(new /obj/item/weapon/bomberman/(M), slot_s_store)
						M.update_icons()
						to_chat(M, "Wait...what?")
						spawn(50)
							to_chat(M, "<span class='notice'>Tip: Use the BBD in your suit's pocket to place bombs.</span>")
							to_chat(M, "<span class='notice'>Try to keep your BBD and escape this hell hole alive!</span>")

				message_admins("[key_name_admin(usr)] turned everyone into Bomberman!")
				log_admin("[key_name_admin(usr)] turned everyone into Bomberman!")
			if("bomberhurt")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBH")
				var/choice = alert("Activate Cuban Pete mode? Note that newly spawned BBD will still have player damage deactivated.","Activating Bomberman Bombs Player Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_hurt = 1
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.hurt_players = 1
				message_admins("[key_name_admin(usr)] enabled the player damage of the Bomberman Bomb Dispensers currently in the world. Cuban Pete approves.")
				log_admin("[key_name_admin(usr)] enabled the player damage of the Bomberman Bomb Dispensers currently in the world. Cuban Pete approves.")
			if("bomberdestroy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBD")
				var/choice = alert("Activate Michael Bay mode? Note that newly spawned BBD will still have environnement damage deactivated.","Activating Bomberman Bombs Environnement Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_destroy = 1
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.destroy_environnement = 1
				message_admins("[key_name_admin(usr)] enabled the environnement damage of the Bomberman Bomb Dispensers currently in the world. Michael Bay approves.")
				log_admin("[key_name_admin(usr)] enabled the environnement damage of the Bomberman Bomb Dispensers currently in the world. Michael Bay approves.")
			if("bombernohurt")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBNH")
				var/choice = alert("Disable Cuban Pete mode.","Disable Bomberman Bombs Player Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_hurt = 0
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.hurt_players = 0
				message_admins("[key_name_admin(usr)] disabled the player damage of the Bomberman Bomb Dispensers currently in the world.")
				log_admin("[key_name_admin(usr)] disabled the player damage of the Bomberman Bomb Dispensers currently in the world.")
			if("bombernodestroy")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BBND")
				var/choice = alert("Disable Michael Bay mode?","Disable Bomberman Bombs Environnement Damage","Confirm","Cancel")
				if(choice=="Confirm")
					bomberman_destroy = 0
					for(var/obj/item/weapon/bomberman/B in bombermangear)
						if(!B.arena)
							B.destroy_environnement = 0
				message_admins("[key_name_admin(usr)] disabled the environnement damage of the Bomberman Bomb Dispensers currently in the world.")
				log_admin("[key_name_admin(usr)] disabled the environnement damage of the Bomberman Bomb Dispensers currently in the world.")
			if("togglebombmethod")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","BM")
				var/choice = input("Do you wish for explosions to take walls and obstacles into account?") in list("Yes, let's have realistic explosions", "No, let's have perfectly circular explosions")
				if(choice == "Yes, let's have realistic explosions")
					message_admins("[key_name_admin(usr)] has set explosions to take walls and obstacles into account.")
					explosion_newmethod = 1
				if(choice == "No, let's have perfectly circular explosions")
					message_admins("[key_name_admin(usr)] has set explosions to completely pass through walls and obstacles.")
					explosion_newmethod = 0
			if("placeturret")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","TUR")
				var/list/possible_guns = list()
				for(var/path in typesof(/obj/item/weapon/gun/energy))
					possible_guns += path
				var/choice = input("What energy gun do you want inside the turret?") in possible_guns
				if(!choice)
					return
				var/obj/item/weapon/gun/energy/gun = new choice()
				var/obj/machinery/porta_turret/Turret = new(get_turf(usr))
				Turret.installation = choice
				Turret.gun_charge = gun.power_supply.charge
				Turret.update_gun()
				qdel(gun)
				var/emag = input("Emag the turret?") in list("Yes", "No")
				if(emag=="Yes")
					Turret.emag(usr)
			if("hardcore_mode")
				var/choice = input("Are you sure you want to [ticker.hardcore_mode ? "disable" : "enable"] hardcore mode? Starvation will [ticker.hardcore_mode ? "no longer":""]slowly kill player-controlled humans.", "Admin Abuse") in list("Yes", "No!")

				if(choice == "Yes")
					if(!hardcore_mode_on)
						log_admin("[key_name(usr)] has ENABLED hardcore mode!")
						hardcore_mode = 1
						to_chat(world, "<h5><span class='danger'>Hardcore mode has been enabled</span></h5>")
						to_chat(world, "<span class='info'>Not eating for a prolonged period of time will slowly kill player-controlled characters (braindead and catatonic characters are not affected).</span>")
						to_chat(world, "<span class='info'>If your hunger indicator starts flashing red and black, your character is starving and may die soon!</span>")
					else
						log_admin("[key_name(usr)] has DISABLED hardcore mode!")
						hardcore_mode = 0
						to_chat(world, "<h5><span class='danger'>Hardcore mode has been disabled</span></h5>")
						to_chat(world, "<span class='info'>Starvation will no longer kill player-controlled characters.</span>")
			if("hostile_infestation")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","HI")
				message_admins("[key_name_admin(usr)] has triggered an infestation of hostile creatures.", 1)
				new /datum/event/hostile_infestation
			if("mass_hallucination")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","MH")
				message_admins("[key_name_admin(usr)] made the whole crew trip balls.", 1)
				new /datum/event/mass_hallucination
			if("meaty_gores")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","ODF")
				message_admins("[key_name_admin(usr)] has sent the station careening through a cloud of gore.", 1)
				new /datum/event/thing_storm/meaty_gore
			if("silent_meteors")
				feedback_inc("admin_secrets_fun_used",1)
				feedback_add_details("admin_secrets_fun_used","SILM")
				message_admins("[key_name_admin(usr)] has spawned meteors without a command alert.", 1)
				new /datum/event/meteor_shower/meteor_quiet

			if("maint_access_brig")
				for(var/obj/machinery/door/airlock/maintenance/M in all_doors)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list(access_brig)
				message_admins("[key_name_admin(usr)] made all maint doors brig access-only.")
			if("maint_access_engiebrig")
				for(var/obj/machinery/door/airlock/maintenance/M in all_doors)
					if (access_maint_tunnels in M.req_access)
						M.req_access = list()
						M.req_one_access = list(access_brig,access_engine)
				message_admins("[key_name_admin(usr)] made all maint doors engineering and brig access-only.")
			if("infinite_sec")
				var/datum/job/J = job_master.GetJob("Security Officer")
				if(!J) return
				J.total_positions = -1
				J.spawn_positions = -1
				message_admins("[key_name_admin(usr)] has removed the cap on security officers.")
			if("virus_custom")
				if(virus2_make_custom(usr.client))
					feedback_add_details("admin_secrets_fun_used", "V_C")
					message_admins("[key_name_admin(usr)] has trigger a custom virus outbreak.", 1)
		if(usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")

	else if(href_list["secretsadmin"])
		if(!check_rights(R_ADMIN))
			return

		switch(href_list["secretsadmin"])
			if("clear_bombs")
				var/num=0
				for(var/obj/item/device/transfer_valve/TV in world)
					if(TV.tank_one||TV.tank_two)
						del(TV)
						TV++
				message_admins("[key_name_admin(usr)] has removed [num] bombs", 1)
			if("detonate_bombs")
				var/num=0
				for(var/obj/item/device/transfer_valve/TV in world)
					if(TV.tank_one||TV.tank_two)
						TV.toggle_valve()
				message_admins("[key_name_admin(usr)] has toggled valves on [num] bombs", 1)

			if("list_bombers")
				var/dat = "<B>Bombing List<HR>"
				for(var/l in bombers)
					dat += text("[l]<BR>")
				usr << browse(dat, "window=bombers")
			if("list_signalers")
				var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
				for(var/sig in lastsignalers)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lastsignalers;size=800x500")
			if("list_lawchanges")
				var/dat = "<B>Showing last [length(lawchanges)] law changes.</B><HR>"
				for(var/sig in lawchanges)
					dat += "[sig]<BR>"
				usr << browse(dat, "window=lawchanges;size=800x500")
			if("list_job_debug")
				var/dat = "<B>Job Debug info.</B><HR>"
				if(job_master)
					for(var/line in job_master.job_debug)
						dat += "[line]<BR>"
					dat+= "*******<BR><BR>"
					for(var/datum/job/job in job_master.occupations)
						if(!job)	continue
						dat += "job: [job.title], current_positions: [job.current_positions], total_positions: [job.total_positions] <BR>"
					usr << browse(dat, "window=jobdebug;size=600x500")
			if("showailaws")
				output_ai_laws()
			if("showgm")
				if(!ticker)
					alert("The game hasn't started yet!")
				else if (ticker.mode)
					alert("The game mode is [ticker.mode.name]")
				else alert("For some reason there's a ticker, but not a game mode")
			if("manifest")
				var/dat = "<B>Showing Crew Manifest.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, H.get_assignment())
				dat += "</table>"
				usr << browse(dat, "window=manifest;size=440x410")
			if("check_antagonist")
				check_antagonists()
			if("DNA")
				var/dat = "<B>Showing DNA from blood.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.dna && H.ckey)
						dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.dna.b_type]</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=DNA;size=440x410")
			if("fingerprints")
				var/dat = "<B>Showing Fingerprints.</B><HR>"
				dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.ckey)
						if(H.dna && H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
						else if(H.dna && !H.dna.uni_identity)
							dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
						else if(!H.dna)
							dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
				dat += "</table>"
				usr << browse(dat, "window=fingerprints;size=440x410")
			if("spawn_objects")
				var/dat = "<B>Admin Log<HR></B>"
				for(var/l in admin_log)
					dat += "<li>[l]</li>"
				if(!admin_log.len)
					dat += "No-one has done anything this round!"
				usr << browse(dat, "window=admin_log")
		if (usr)
			log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")

	else if(href_list["ac_view_wanted"])            //Admin newscaster Topic() stuff be here
		src.admincaster_screen = 18                 //The ac_ prefix before the hrefs stands for AdminCaster.
		src.access_news_network()

	else if(href_list["ac_set_channel_name"])
		src.admincaster_feed_channel.channel_name = strip_html_simple(input(usr, "Provide a Feed Channel Name", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_channel.channel_name," ") == 1)
			src.admincaster_feed_channel.channel_name = copytext(src.admincaster_feed_channel.channel_name,2,length(src.admincaster_feed_channel.channel_name)+1)
		src.access_news_network()

	else if(href_list["ac_set_channel_lock"])
		src.admincaster_feed_channel.locked = !src.admincaster_feed_channel.locked
		src.access_news_network()

	else if(href_list["ac_submit_new_channel"])
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.admincaster_feed_channel.channel_name)
				check = 1
				break
		if(src.admincaster_feed_channel.channel_name == "" || src.admincaster_feed_channel.channel_name == "\[REDACTED\]" || check )
			src.admincaster_screen=7
		else
			var/choice = alert("Please confirm Feed channel creation","Network Channel Handler","Confirm","Cancel")
			if(choice=="Confirm")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.admincaster_feed_channel.channel_name
				newChannel.author = src.admincaster_signature
				newChannel.locked = src.admincaster_feed_channel.locked
				newChannel.is_admin_channel = 1
				feedback_inc("newscaster_channels",1)
				news_network.network_channels += newChannel                        //Adding channel to the global network
				log_admin("[key_name_admin(usr)] created command feed channel: [src.admincaster_feed_channel.channel_name]!")
				src.admincaster_screen=5
		src.access_news_network()

	else if(href_list["ac_set_channel_receiving"])
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			available_channels += F.channel_name
		src.admincaster_feed_channel.channel_name = adminscrub(input(usr, "Choose receiving Feed Channel", "Network Channel Handler") in available_channels )
		src.access_news_network()

	else if(href_list["ac_set_new_message"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Write your Feed story", "Network Channel Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,length(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_new_message"])
		if(src.admincaster_feed_message.body =="" || src.admincaster_feed_message.body =="\[REDACTED\]" || src.admincaster_feed_channel.channel_name == "" )
			src.admincaster_screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			newMsg.author = src.admincaster_signature
			newMsg.body = src.admincaster_feed_message.body
			newMsg.is_admin_message = 1
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.admincaster_feed_channel.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					break
			src.admincaster_screen=4

		for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
			NEWSCASTER.newsAlert(src.admincaster_feed_channel.channel_name)

		log_admin("[key_name_admin(usr)] submitted a feed story to channel: [src.admincaster_feed_channel.channel_name]!")
		src.access_news_network()

	else if(href_list["ac_create_channel"])
		src.admincaster_screen=2
		src.access_news_network()

	else if(href_list["ac_create_feed_story"])
		src.admincaster_screen=3
		src.access_news_network()

	else if(href_list["ac_menu_censor_story"])
		src.admincaster_screen=10
		src.access_news_network()

	else if(href_list["ac_menu_censor_channel"])
		src.admincaster_screen=11
		src.access_news_network()

	else if(href_list["ac_menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.admincaster_feed_message.author = news_network.wanted_issue.author
			src.admincaster_feed_message.body = news_network.wanted_issue.body
		src.admincaster_screen = 14
		src.access_news_network()

	else if(href_list["ac_set_wanted_name"])
		src.admincaster_feed_message.author = adminscrub(input(usr, "Provide the name of the Wanted person", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.author," ") == 1)
			src.admincaster_feed_message.author = copytext(admincaster_feed_message.author,2,length(admincaster_feed_message.author)+1)
		src.access_news_network()

	else if(href_list["ac_set_wanted_desc"])
		src.admincaster_feed_message.body = adminscrub(input(usr, "Provide the a description of the Wanted person and any other details you deem important", "Network Security Handler", ""))
		while (findtext(src.admincaster_feed_message.body," ") == 1)
			src.admincaster_feed_message.body = copytext(src.admincaster_feed_message.body,2,length(src.admincaster_feed_message.body)+1)
		src.access_news_network()

	else if(href_list["ac_submit_wanted"])
		var/input_param = text2num(href_list["ac_submit_wanted"])
		if(src.admincaster_feed_message.author == "" || src.admincaster_feed_message.body == "")
			src.admincaster_screen = 16
		else
			var/choice = alert("Please confirm Wanted Issue [(input_param==1) ? ("creation.") : ("edit.")]","Network Security Handler","Confirm","Cancel")
			if(choice=="Confirm")
				if(input_param==1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.admincaster_feed_message.author               //Wanted name
					WANTED.body = src.admincaster_feed_message.body                   //Wanted desc
					WANTED.backup_author = src.admincaster_signature                  //Submitted by
					WANTED.is_admin_message = 1
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.admincaster_screen = 15
				else
					news_network.wanted_issue.author = src.admincaster_feed_message.author
					news_network.wanted_issue.body = src.admincaster_feed_message.body
					news_network.wanted_issue.backup_author = src.admincaster_feed_message.backup_author
					src.admincaster_screen = 19
				log_admin("[key_name_admin(usr)] issued a Station-wide Wanted Notification for [src.admincaster_feed_message.author]!")
		src.access_news_network()

	else if(href_list["ac_cancel_wanted"])
		var/choice = alert("Please confirm Wanted Issue removal","Network Security Handler","Confirm","Cancel")
		if(choice=="Confirm")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.admincaster_screen=17
		src.access_news_network()

	else if(href_list["ac_censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["ac_censor_channel_author"])
		if(FC.author != "<B>\[REDACTED\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[REDACTED\]</B>"
		else
			FC.author = FC.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_author"])
		if(MSG.author != "<B>\[REDACTED\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[REDACTED\]</B>"
		else
			MSG.author = MSG.backup_author
		src.access_news_network()

	else if(href_list["ac_censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["ac_censor_channel_story_body"])
		if(MSG.body != "<B>\[REDACTED\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[REDACTED\]</B>"
		else
			MSG.body = MSG.backup_body
		src.access_news_network()

	else if(href_list["ac_pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_d_notice"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen=13
		src.access_news_network()

	else if(href_list["ac_toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["ac_toggle_d_notice"])
		FC.censored = !FC.censored
		src.access_news_network()

	else if(href_list["ac_view"])
		src.admincaster_screen=1
		src.access_news_network()

	else if(href_list["ac_setScreen"]) //Brings us to the main menu and resets all fields~
		src.admincaster_screen = text2num(href_list["ac_setScreen"])
		if (src.admincaster_screen == 0)
			if(src.admincaster_feed_channel)
				src.admincaster_feed_channel = new /datum/feed_channel
			if(src.admincaster_feed_message)
				src.admincaster_feed_message = new /datum/feed_message
		src.access_news_network()

	else if(href_list["ac_show_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_show_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 9
		src.access_news_network()

	else if(href_list["ac_pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["ac_pick_censor_channel"])
		src.admincaster_feed_channel = FC
		src.admincaster_screen = 12
		src.access_news_network()

	else if(href_list["ac_refresh"])
		src.access_news_network()

	else if(href_list["ac_set_signature"])
		src.admincaster_signature = adminscrub(input(usr, "Provide your desired signature", "Network Identity Handler", ""))
		src.access_news_network()

	else if(href_list["populate_inactive_customitems"])
		if(check_rights(R_ADMIN|R_SERVER))
			populate_inactive_customitems_list(src.owner)

	else if(href_list["vsc"])
		if(check_rights(R_ADMIN|R_SERVER))
			if(href_list["vsc"] == "airflow")
				zas_settings.ChangeSettingsDialog(usr,zas_settings.settings)
			if(href_list["vsc"] == "default")
				zas_settings.SetDefault(usr)

	else if(href_list["toglang"])
		if(check_rights(R_SPAWN))
			var/mob/M = locate(href_list["toglang"])
			if(!istype(M))
				to_chat(usr, "[M] is illegal type, must be /mob!")
				return
			var/lang2toggle = href_list["lang"]
			var/datum/language/L = all_languages[lang2toggle]

			if(L in M.languages)
				if(!M.remove_language(lang2toggle))
					to_chat(usr, "Failed to remove language '[lang2toggle]' from \the [M]!")
			else
				if(!M.add_language(lang2toggle))
					to_chat(usr, "Failed to add language '[lang2toggle]' from \the [M]!")

			show_player_panel(M)

	// player info stuff

	if(href_list["add_player_info"])
		var/key = href_list["add_player_info"]
		var/add = input("Add Player Info") as null|text
		if(!add) return

		notes_add(key,add,usr)
		show_player_info(key)

	if(href_list["remove_player_info"])
		var/key = href_list["remove_player_info"]
		var/index = text2num(href_list["remove_index"])

		notes_del(key, index)
		show_player_info(key)

	if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/M = locate(href_list["mob"])
			if(ismob(M))
				ckey = M.ckey

		switch(href_list["notes"])
			if("show")
				show_player_info(ckey)
			if("list")
				PlayerNotesPage(text2num(href_list["index"]))
		return

//-------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------Shuttle stuff-----------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------

	if(href_list["shuttle_select"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SS")

		var/datum/shuttle/S = select_shuttle_from_all(usr,"Please select a shuttle","Admin abuse")

		if(istype(S))
			selected_shuttle = S
			to_chat(usr, "[S] ([S.type]) selected!")

		shuttle_magic() //Update the window!
	if(href_list["shuttle_add_docking_port"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","CD")

		var/area/A = get_area(get_turf(usr))
		var/datum/shuttle/shuttle_to_add_to = A.get_shuttle()

		if(istype(shuttle_to_add_to))
			if(alert(usr, "Would you like the new shuttle docking port to be assigned to [shuttle_to_add_to.name]? [shuttle_to_add_to.linked_port ? "NOTE: It already has a shuttle docking port." : ""]", "Admin abuse", "Yes", "No") != "Yes")
				shuttle_to_add_to = null

		var/obj/structure/docking_port/shuttle/D = new( get_turf(usr) )
		D.dir = usr.dir

		if(istype(shuttle_to_add_to))
			D.link_to_shuttle(shuttle_to_add_to)
			to_chat(usr, "Assigned the [D] to [shuttle_to_add_to.name]")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new shuttle docking port in [get_area(D)] [formatJumpTo(get_turf(D))][shuttle_to_add_to ? " and assigned it to [shuttle_to_add_to.name]" : ""]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) at [D.x];[D.y];[D.z][shuttle_to_add_to ? " and assigned it to [shuttle_to_add_to.name]" : ""]")

	if(href_list["shuttle_create_destination"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","DC")

		var/area/A = get_area(get_turf(usr))

		var/name = input(usr,"What would you like to name this docking port?","Admin abuse","[A ? "[A.name]" : "Space [rand(100,999)]"]") as text|null
		if(!name) return

		var/obj/structure/docking_port/destination/D = new( get_turf(usr) )
		D.dir = usr.dir
		D.areaname = name

		A = get_area(D)
		if(A)
			var/datum/shuttle/S = A.get_shuttle()
			if(S)
				if(alert(usr,"Would you like the new docking port to be a part of [S.name] ([S.type])? Any shuttles docked to it will be moved together with [S.name].","Admin abuse","Yes","No") == "Yes")
					if(get_area(D) == A) //If the shuttle moved, abort -- as that would lead to weird shittu
						S.docking_ports_aboard |= D
						to_chat(usr, "[D] is now considered a part of [S.name] ([S.type]).")

		if(istype(selected_shuttle))
			if(alert(usr,"Would you like to add [D.areaname] to the list of [selected_shuttle.name]'s destinations?","Admin abuse","Yes","No") == "Yes")
				selected_shuttle.docking_ports |= D
				to_chat(usr, "Added [D] to the list of [selected_shuttle.name]'s destinations")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) in [get_area(D)] [formatJumpTo(get_turf(D))]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new destination docking port ([D.areaname]) at [D.x];[D.y];[D.z]")

	if(href_list["shuttle_modify_destination"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","MD")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		var/list/docking_ports_to_pick_from = all_docking_ports.Copy()
		var/list/options = list()
		for(var/obj/structure/docking_port/destination/D in (docking_ports_to_pick_from - S.docking_ports))
			var/name = D.areaname
			options += name
			options[name] = D

		var/obj/structure/docking_port/destination/choice = options[(input(usr,"Select a docking port to add to [S.name]","Admin abuse") in options)]
		if(!istype(choice)) return

		S.docking_ports |= choice
		to_chat(usr, "Added [choice.areaname] to [S.name]!")

	if(href_list["shuttle_set_transit"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","AT")

		var/list/L = list()
		for(var/obj/structure/docking_port/destination/D in get_turf(usr) )
			var/name = "[D.name] ([D.areaname])"
			L += name
			L[name]=D

		if(!L.len)
			to_chat(usr, "Please stand on the docking port you wish to make a transit area.")

		var/obj/structure/docking_port/port_to_link = L[ (input(usr,"Select a new transit area for the shuttle","Admin abuse") as null|anything in (L + list("Cancel"))) ]
		if(!istype(port_to_link)) return

		var/datum/shuttle/shuttle_to_link = selected_shuttle
		if(!istype(shuttle_to_link)) return

		var/choice = input(usr,"Please confirm that you want to make [port_to_link] ([port_to_link.areaname]) a transit area for [shuttle_to_link.name] ([shuttle_to_link.type])?","Admin abuse") in list("Yes","No")

		if(choice == "Yes")
			shuttle_to_link.set_transit_dock(port_to_link)
		else
			return

		message_admins("[key_name_admin(usr)] has set a destination docking port ([port_to_link.areaname]) at [port_to_link.x];[port_to_link.y];[port_to_link.z] to be [shuttle_to_link.name] ([shuttle_to_link.type])'s transit area [formatJumpTo(get_turf(port_to_link))]", 1)
		log_admin("[key_name_admin(usr)] has set a destination docking port ([port_to_link.areaname]) at [port_to_link.x];[port_to_link.y];[port_to_link.z] to be [shuttle_to_link.name] ([shuttle_to_link.type])'s transit area")

	if(href_list["shuttle_create_shuttleport"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SC")

		var/obj/structure/docking_port/shuttle/D = new(get_turf(usr.loc))
		D.dir = usr.dir

		var/area/A = get_area(D)
		var/datum/shuttle/S = A.get_shuttle()
		if(S && !S.linked_port)
			if(alert(usr,"Would you like to make [S.name] ([S.type]) use this docking port?","Admin abuse","Yes","No") == "Yes")
				if(!S || S.linked_port)
					to_chat(usr, "Either the shuttle was deleted, or somebody already linked a shuttle docking port to it. Sorry!")
					return
				if(!D) return

				S.linked_port = D
				to_chat(usr, "The shuttle docking port will now be used by [S.name]!")

		message_admins("<span class='notice'>[key_name_admin(usr)] has created a new shuttle docking port in [get_area(D)] [formatJumpTo(get_turf(D))]</span>", 1)
		log_admin("[key_name_admin(usr)] has created a new shuttle docking port at [D.x];[D.y];[D.z]</span>")

	if(href_list["shuttle_toggle_lockdown"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","LD")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		if(S.lockdown)
			S.lockdown = 0
			to_chat(usr, "The lockdown from [S.name] has been lifted.")
			message_admins("<span class='notice'>[key_name_admin(usr)] has lifted [capitalize(S.name)]'s lockdown.</span>", 1)
			log_admin("[key_name(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]")
		else
			S.lockdown = 1
			to_chat(usr, "[S.name] has been locked down.")
			var/reason = input(usr,"Would you like to provide additional information, which will be shown on [capitalize(S.name)]'s control consoles?","Shuttle lockdown") in list("Yes","No")
			if(reason == "Yes")
				reason = input(usr,"Please type additional information about the lockdown of [capitalize(S.name)].","Shuttle lockdown")
				if(length(reason)>=1)
					S.lockdown = reason
			message_admins("<span class='notice'>[key_name_admin(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]</span>", 1)
			log_admin("[key_name(usr)] has locked [capitalize(S.name)] down. [(length(S.lockdown)>=1) ? "Reason: [S.lockdown]" : ""]")

	if(href_list["shuttle_move_to"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","MV")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		var/list/possible_ports = list()
		for(var/obj/structure/docking_port/destination/D in S.docking_ports)
			var/name = D.areaname
			possible_ports += name
			possible_ports[name] = D

		var/choice = input(usr, "Select a docking port for [capitalize(S.name)] to travel to", "Shuttle movement") in (possible_ports + list("Cancel"))
		var/obj/structure/docking_port/destination/target_port = possible_ports[choice]

		if(!target_port)
			return

		S.travel_to(target_port,,usr)

		message_admins("[key_name_admin(usr)] has moved [capitalize(S.name)] to [target_port.areaname] ([target_port.x];[target_port.y];[target_port.z])")
		log_admin("[key_name(usr)] has moved [capitalize(S.name)] to [target_port.areaname] ([target_port.x];[target_port.y];[target_port.z])")

	if(href_list["shuttle_edit"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SE")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		var/list/options = list("Cancel","cooldown","pre-flight delay","transit delay","use transit","can link to computer","innacuracy","name","destroy areas","can rotate")
		if(S.is_special()) options += "DEFINED LOCATIONS"
		var/choice = input(usr,"What to edit in [capitalize(S.name)]?","Shuttle editing") in options

		var/new_value
		switch(choice)
			if("cooldown")
				new_value = input(usr,"Input new cooldown for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.cooldown) as num
				S.cooldown = new_value
			if("pre-flight delay")
				new_value = input(usr,"Input new pre-flight delay for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.pre_flight_delay) as num
				S.pre_flight_delay = new_value
			if("transit delay")
				new_value = input(usr,"Input new transit delay for [capitalize(S.name)] (in 1/10s of a second)","Shuttle editing",S.transit_delay) as num
				S.transit_delay = new_value
			if("use transit")
				new_value = input(usr,"[NO_TRANSIT] -  no transit, [TRANSIT_ACROSS_Z_LEVELS] - only across z levels, [TRANSIT_ALWAYS] - always","Shuttle editing ([capitalize(S.name)])",S.use_transit) as num
				if(new_value in list(NO_TRANSIT,TRANSIT_ACROSS_Z_LEVELS,TRANSIT_ALWAYS))
					S.use_transit = new_value
				else
					to_chat(usr, "Not valid!")
					return
			if("can link to computer")
				new_value = input(usr,"[LINK_FREE] - can always link, [LINK_PASSWORD_ONLY] - can only link with password ([S.password]), [LINK_FORBIDDEN] - can't link at all","Shuttle editing ([capitalize(S.name)])",S.can_link_to_computer) as num
				S.pre_flight_delay = new_value
			if("direction")
				new_value = input(usr,"[NORTH] - north, [SOUTH] - south, [WEST] - west, [EAST] - east","Shuttle editing ([capitalize(S.name)])",S.dir) as num
				if(new_value in cardinal)
					S.dir = new_value
				else
					to_chat(usr, "Not valid!")
					return
			if("innacuracy")
				new_value = input(usr,"Input new innacuracy value for [capitalize(S.name)] (when a shuttle moves, its final location is randomly offset by this value)","Shuttle editing",S.innacuracy) as num
				S.innacuracy = new_value
			if("name")
				new_value = input(usr,"Input new name for [capitalize(S.name)]","Shuttle editing",S.innacuracy) as text
				S.name = new_value
			if("can rotate")
				new_value = input(usr,"0 - rotation disabled, 1 - rotation enabled","Shuttle editing",S.can_rotate) as num
				S.can_rotate = new_value
			if("DEFINED LOCATIONS")
				to_chat(usr, "To prevent accidental mistakes, you can only set these locations to docking ports in the shuttle's memory (use the \"Add a destination docking port to a shuttle\" command)")

				var/list/locations = list("--Cancel--")
				switch(S.type)
					if(/datum/shuttle/vox)
						locations += list("Vox home (MOVING TO IT WILL END THE ROUND)" = "dock_home")
					if(/datum/shuttle/escape)
						locations += list("Escape shuttle home" = "dock_station","Escape shuttle centcom" = "dock_centcom")
					if(/datum/shuttle/taxi)
						locations += list("Taxi medbay silicon" = "dock_medical_silicon","Taxi engineering cargo" = "dock_engineering_cargo","Taxi security science" = "dock_security_science","Taxi abandoned station" = "dock_abandoned")
					if(/datum/shuttle/supply)
						locations += list("Centcom loading bay" = "dock_centcom", "Station cargo bay" = "dock_station")

				var/choice2 = input(usr,"Select a location to modify","Shuttle editing") in locations
				var/variable_to_edit = locations[choice2]

				var/obj/structure/docking_port/destination/D = select_port_from_list(usr,"Select a new [choice2] location for [S.name] ([S.type])","Shuttle editing",S.docking_ports)
				if(istype(D))
					S.vars[variable_to_edit] = D
					to_chat(usr, "[S.name]'s [variable_to_edit] has been changed to [D.areaname]")
					message_admins("<span class='notice'>[key_name_admin(usr)] has changed [capitalize(S.name)]'s [choice2] to [D.areaname]!</span>", 1)
					log_admin("[key_name_admin(usr)] has changed [capitalize(S.name)]'s [choice2] to [D.areaname]!")
				else
					return


		message_admins("<span class='notice'>[key_name_admin(usr)] has set [capitalize(S.name)]'s [choice] to [new_value]!</span>", 1)
		log_admin("[key_name_admin(usr)] has set [capitalize(S.name)]'s [choice] to [new_value]!")

		shuttle_magic() //Update the window!

	if(href_list["shuttle_delete"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","DEL")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		var/killed_objs = 0

		if( (input(usr,"Please type \"Yes\" to confirm that you want to delete [capitalize(S)]. This process can't be reverted!","Shuttle deletion","No") as text) != "Yes" )
			return

		if(S.is_special())
			to_chat(usr, "This shuttle can't be deleted. Use the lockdown function instead.")
			return

		var/choice = (input(usr,"Would you like to delete all turfs and objects in the shuttle's current area? Mobs will not be affected.") in list("Yes","No","Cancel") )
		if(choice == "Cancel")
			return
		else if(choice == "Yes")
			killed_objs = 1

		if(S.linked_area)
			if(killed_objs == 1)
				for(var/turf/T in S.linked_area)
					if(istype(T, /turf/simulated))
						qdel(T)
				for(var/obj/O in S.linked_area)
					if(istype(O, /obj/item) || istype(O, /obj/machinery) || istype(O, /obj/structure))
						qdel(O)
				to_chat(usr, "All turfs and objects deleted from [S.linked_area].")

		message_admins("<span class='notice'>[key_name_admin(usr)] has deleted [capitalize(S.name)] ([S.type]). Objects and turfs [(killed_objs) ? "deleted" : "not deleted"].</span>")
		log_admin("[key_name(usr)]  has deleted [capitalize(S.name)]! Objects and turfs [(killed_objs) ? "deleted" : "not deleted"].")

		qdel(S)
		selected_shuttle = null

		shuttle_magic() //Update the window!

	if(href_list["shuttle_teleport_to"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","TP")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		if(!S.linked_area || !istype(S.linked_area, /area/))
			to_chat(usr, "The shuttle is in the middle of nowhere! (The 'linked_area' variable is either null or not an area, please report this)")
			return

		var/turf/T = locate(/turf/) in S.linked_area
		usr.forceMove(T)
		to_chat(usr, "You have teleported to [capitalize(S.name)]")

	if(href_list["shuttle_teleport_to_dock"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","TP2")

		var/list/destinations = list()
		for(var/obj/structure/docking_port/destination/D in all_docking_ports)
			var/name = "[D.areaname][D.docked_with ? " (docked to [D.docked_with.areaname])" : ""]"
			destinations += name
			destinations[name]=D

		var/choice = input(usr,"Select a docking port to teleport to","Finding a docking port") in destinations

		var/obj/structure/docking_port/destination/target = destinations[choice]
		if(!target) return

		usr.forceMove(get_turf(target))
		to_chat(usr, "You have teleported to [choice]")

	if(href_list["shuttle_get_console"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","GC")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		if(!S.control_consoles.len)

			var/choice = input(usr,"There is no control console linked to [capitalize(S.name)]. Would you like to create one at your current location?","Shuttle control access") in list("Yes","No")
			if(choice == "Yes")
				var/turf/usr_loc = get_turf(usr)
				var/obj/machinery/computer/shuttle_control/C = new(usr_loc)
				if(C)
					C.link_to(S)
					to_chat(usr, "A new shuttle control console has been created.")
					message_admins("[key_name_admin(usr)] has created a new shuttle control console connected to [capitalize(S.name)] in [get_area(usr_loc)].")
					log_admin("[key_name(usr)] has created a new shuttle control console connected to [capitalize(S.name)] in [get_area(usr_loc)].")
			else
				return

		else

			var/obj/machinery/computer/shuttle_control/C = pick(S.control_consoles)
			if(C)
				usr.loc = C.loc

	if(href_list["shuttle_shuttlify"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SHH")

		var/area/A = get_area(usr)
		if(!A)
			to_chat(usr, "You must be standing on an area!")
			return
		if(isspace(A))
			to_chat(usr, "You can't turn space into a shuttle.")
			return

		var/datum/shuttle/conflict = A.get_shuttle()
		if(conflict)
			var/choice = input(usr,"This area is already used by [conflict]. Type \"Yes\" to continue and bring on the unintended features","Shuttlify","NO") as text
			if(choice != "Yes")
				return

		if( !(locate(/obj/structure/docking_port/shuttle) in A) )
			to_chat(usr, "Please create a shuttle docking port (/obj/structure/docking_port/shuttle) in this area!")
			return

		var/name = input(usr, "Please name the new shuttle", "Shuttlify", A.name) as text|null

		if(!name)
			to_chat(usr, "Shuttlifying cancelled.")
			return

		var/datum/shuttle/custom/S = new(starting_area = A)
		S.initialize()
		S.name = name

		to_chat(usr, "Shuttle created!")

		selected_shuttle = S
		shuttle_magic() //Update the window!

		message_admins("<span class='notice'>[key_name_admin(usr)] has turned [A.name] into a shuttle named [S.name]. [formatJumpTo(get_turf(usr))]</span>")
		log_admin("[key_name(usr)]  has turned [A.name] into a shuttle named [S.name].")

	if(href_list["shuttle_forcemove"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","FM")

		var/list/L = list("Cancel","YOUR CURRENT LOCATION")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		for(var/obj/structure/docking_port/destination/D in S.docking_ports)
			var/name = "[D.name] [D.areaname]"
			L+=name
			L[name]=D

		L += "---other destinations---"

		for(var/obj/structure/docking_port/destination/D in all_docking_ports - S.docking_ports)
			var/name = D.areaname
			L+=name
			L[name]=D

		var/choice = input(usr, "Select a location to teleport [S.name] to!", "Shuttle teleporting") in L

		if(choice == "YOUR CURRENT LOCATION")
			var/area/A = get_area(usr)
			var/turf/T = get_turf(usr)
			if(!A) return
			if(!T) return

			var/obj/structure/docking_port/destination/temp = new(T)
			temp.invisibility = 101
			temp.areaname = A.name
			temp.dir = usr.dir

			S.move_to_dock(temp)

			message_admins("[key_name_admin(usr)] has teleported [capitalize(S.name)] to himself ([A.name], [temp.x];[temp.y];[temp.z])!")
			log_admin("[key_name(usr)] has teleported [capitalize(S.name)] to himself by ([A.name], [temp.x];[temp.y];[temp.z])")

			qdel(temp)
			return
		else
			var/obj/structure/docking_port/destination/D = L[choice]
			if(!D) return

			S.move_to_dock(D)

			message_admins("<span class='notice'>[key_name_admin(usr)] has teleported [capitalize(S.name)] to [choice] ([D.x];[D.y];[D.z])</span>")
			log_admin("[key_name(usr)] has teleported [capitalize(S.name)] to [choice] ([D.x];[D.y];[D.z])")

			return

	if(href_list["shuttle_reset"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SR")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		if(alert(usr,"ARE YOU SURE YOU WANT TO RESET [S.name] ([S.type])?","HELP","Yes","No")=="No") return

		S.name = initial(S.name)
		S.cooldown = initial(S.cooldown)
		S.innacuracy = initial(S.innacuracy)
		S.transit_delay = initial(S.transit_delay)
		S.pre_flight_delay = initial(S.pre_flight_delay)
		S.use_transit = initial(S.use_transit)
		S.dir = initial(S.dir)

		S.initialize()

		message_admins("[key_name_admin(usr)] has reset [capitalize(S.name)]'s variables")
		log_admin("[key_name(usr)] has reset [capitalize(S.name)]'s variables")

	if(href_list["shuttle_supercharge"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SUP")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		S.supercharge()

	if(href_list["shuttle_mass_lockdown"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","ML")

		if( !(input(usr,"Please type \"Yes\" to confirm that you want to lockdown all shuttles.","IS IT LOOSE?","NO") == "Yes") )
			return

		for(var/datum/shuttle/S in shuttles)
			S.lockdown = 1

		to_chat(usr, "All shuttles were locked down.")

		message_admins("<span class='notice'>[key_name_admin(usr)] has locked all shuttles down!</span>")
		log_admin("[key_name(usr)] has locked all shuttles down!")

	if(href_list["shuttle_show_overlay"])
		feedback_inc("admin_shuttle_magic_used",1)
		feedback_add_details("admin_shuttle_magic_used","SO")

		var/datum/shuttle/S = selected_shuttle
		if(!istype(S)) return

		if(!S.linked_port)
			to_chat(usr, "The shuttle must have a shuttle docking port!")
			return

		if(usr.dir != S.dir)
			to_chat(usr, "WARNING: You're not facing [dir2text(S.dir)]! The result may be <i>slightly</i> innacurate.")

		S.show_outline(usr)


	//------------------------------------------------------------------Shuttle stuff end---------------------------------
