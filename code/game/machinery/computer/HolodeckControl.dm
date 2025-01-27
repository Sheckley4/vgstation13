/obj/machinery/computer/HolodeckControl
	name = "Holodeck Control Computer"
	desc = "A computer used to control a nearby holodeck."
	icon_state = "holocontrol"
	var/area/linkedholodeck = null
	var/area/target = null
	var/active = 0
	var/list/holographic_items = list()
	var/damaged = 0
	var/last_change = 0

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/HolodeckControl/attack_ai(var/mob/user as mob)
	add_hiddenprint(user)
	return attack_hand(user)

/obj/machinery/computer/HolodeckControl/attack_paw(var/mob/user as mob)
	return

/obj/machinery/computer/HolodeckControl/attack_hand(var/mob/user as mob)

	if(..())
		return
	user.set_machine(src)
	var/dat

	dat += {"<B>Holodeck Control System</B><BR>
		<HR>Current Loaded Programs:<BR>
		<A href='?src=\ref[src];emptycourt=1'>((Empty Court)</font>)</A><BR>
		<A href='?src=\ref[src];boxingcourt=1'>((Boxing Court)</font>)</A><BR>
		<A href='?src=\ref[src];basketball=1'>((Basketball Court)</font>)</A><BR>
		<A href='?src=\ref[src];thunderdomecourt=1'>((Thunderdome Court)</font>)</A><BR>
		<A href='?src=\ref[src];beach=1'>((Beach)</font>)</A><BR>
		<A href='?src=\ref[src];desert=1'>((Desert)</font>)</A><BR>
		<A href='?src=\ref[src];space=1'>((Space)</font>)</A><BR>
		<A href='?src=\ref[src];picnicarea=1'>((Picnic Area)</font>)</A><BR>
		<A href='?src=\ref[src];snowfield=1'>((Snow Field)</font>)</A><BR>
		<A href='?src=\ref[src];theatre=1'>((Theatre)</font>)</A><BR>
		<A href='?src=\ref[src];meetinghall=1'>((Meeting Hall)</font>)</A><BR>"}
//	dat += "<A href='?src=\ref[src];turnoff=1'>((Shutdown System)</font>)</A><BR>"
	dat += "Please ensure that only holographic weapons are used in the holodeck if a combat simulation has been loaded.<BR>"

	if(emagged)
		dat += {"<A href='?src=\ref[src];burntest=1'>(<font color=red>Begin Atmospheric Burn Simulation</font>)</A><BR>
			Ensure the holodeck is empty before testing.<BR>
			<BR>
			<A href='?src=\ref[src];wildlifecarp=1'>(<font color=red>Begin Wildlife Simulation</font>)</A><BR>
			Ensure the holodeck is empty before testing.<BR>
			<BR>"}
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=green>Re-Enable Safety Protocols?</font>)</A><BR>"
		dat += "Safety Protocols are <font color=red> DISABLED </font><BR>"
	else
		if(issilicon(user))
			dat += "<A href='?src=\ref[src];AIoverride=1'>(<font color=red>Override Safety Protocols?</font>)</A><BR>"

		dat += {"<BR>
			Safety Protocols are <font color=green> ENABLED </font><BR>"}
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/HolodeckControl/Topic(href, href_list)
	if(..())
		return 1
	else
		usr.set_machine(src)

		if(href_list["emptycourt"])
			target = locate(/area/holodeck/source_emptycourt)
			if(target)
				loadProgram(target)

		else if(href_list["boxingcourt"])
			target = locate(/area/holodeck/source_boxingcourt)
			if(target)
				loadProgram(target)

		else if(href_list["basketball"])
			target = locate(/area/holodeck/source_basketball)
			if(target)
				loadProgram(target)

		else if(href_list["thunderdomecourt"])
			target = locate(/area/holodeck/source_thunderdomecourt)
			if(target)
				loadProgram(target)

		else if(href_list["beach"])
			target = locate(/area/holodeck/source_beach)
			if(target)
				loadProgram(target)

		else if(href_list["desert"])
			target = locate(/area/holodeck/source_desert)
			if(target)
				loadProgram(target)

		else if(href_list["space"])
			target = locate(/area/holodeck/source_space)
			if(target)
				loadProgram(target)

		else if(href_list["picnicarea"])
			target = locate(/area/holodeck/source_picnicarea)
			if(target)
				loadProgram(target)

		else if(href_list["snowfield"])
			target = locate(/area/holodeck/source_snowfield)
			if(target)
				loadProgram(target)

		else if(href_list["theatre"])
			target = locate(/area/holodeck/source_theatre)
			if(target)
				loadProgram(target)

		else if(href_list["meetinghall"])
			target = locate(/area/holodeck/source_meetinghall)
			if(target)
				loadProgram(target)

		else if(href_list["turnoff"])
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)

		else if(href_list["burntest"])
			if(!emagged)
				return
			target = locate(/area/holodeck/source_burntest)
			if(target)
				loadProgram(target)

		else if(href_list["wildlifecarp"])
			if(!emagged)
				return
			target = locate(/area/holodeck/source_wildlife)
			if(target)
				loadProgram(target)

		else if(href_list["AIoverride"])
			if(!issilicon(usr))
				return
			emagged = !emagged
			if(emagged)
				message_admins("[key_name_admin(usr)] overrode the holodeck's safeties")
				log_game("[key_name(usr)] overrided the holodeck's safeties")
				visible_message("<span class='warning'>Warning: Holodeck safeties overriden. Please contact Nanotrasen maintenance and cease all operation if you are not source of that command.</span>")
			else
				message_admins("[key_name_admin(usr)] restored the holodeck's safeties")
				log_game("[key_name(usr)] restored the holodeck's safeties")
				visible_message("<span class='notice'>Holodeck safeties have been restored. Simulation programs are now safe to use again.</span>")

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/HolodeckControl/attackby(var/obj/item/weapon/D as obj, var/mob/user as mob)
	..() //This still allows items to unrez even if the computer is deconstructed
	return

/obj/machinery/computer/HolodeckControl/emag(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/sparks4.ogg', 75, 1)
	if(emagged)
		return //No spamming
	emagged = 1
	visible_message("<span class='warning'>[user] swipes a card into the holodeck reader.</span>","<span class='notice'>You swipe the electromagnetic card into the holocard reader.</span>")
	visible_message("<span class='warning'>Warning: Power surge detected. Automatic shutoff and derezing protocols have been corrupted. Please contact Nanotrasen maintenance and cease all operation immediately.</span>")
	log_game("[key_name(usr)] emagged the Holodeck Control Computer")
	src.updateUsrDialog()

/obj/machinery/computer/HolodeckControl/New()
	..()
	linkedholodeck = locate(/area/holodeck/alphadeck)

//This could all be done better, but it works for now.
/obj/machinery/computer/HolodeckControl/Destroy()
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/emp_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/ex_act(severity)
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/blob_act()
	emergencyShutdown()
	..()

/obj/machinery/computer/HolodeckControl/process()
	//Note : This was moved BEFORE the process() parent that deals with power and co. to avoid item cheesing from cutting off equipment power !
	for(var/item in holographic_items)
		if(!(get_turf(item) in linkedholodeck))
			derez(item, 0)

	if(!..())
		return
	if(active)
		if(!checkInteg(linkedholodeck))
			damaged = 1
			target = locate(/area/holodeck/source_plating)
			if(target)
				loadProgram(target)
			active = 0
			for(var/mob/M in range(10,src))
				M.show_message("The holodeck overloads!")

			for(var/turf/T in linkedholodeck)
				if(prob(30))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
				T.ex_act(3)
				T.hotspot_expose(1000,500,1,surfaces=1)

/obj/machinery/computer/HolodeckControl/proc/derez(var/obj/obj , var/silent = 1)


	holographic_items.Remove(obj)

	if(obj == null)
		return

	if(isobj(obj))
		var/mob/M = obj.loc
		if(ismob(M))
			M.u_equip(obj, 0)
			M.update_icons()	//so their overlays update

	if(!silent)
		var/obj/oldobj = obj
		visible_message("The [oldobj.name] fades away!")
	qdel(obj)

/obj/machinery/computer/HolodeckControl/proc/checkInteg(var/area/A)


	for(var/turf/T in A)
		if(istype(T, /turf/space))
			return 0
	return 1

/obj/machinery/computer/HolodeckControl/proc/togglePower(var/toggleOn = 0)


	if(toggleOn)
		var/area/targetsource = locate(/area/holodeck/source_emptycourt)
		holographic_items = targetsource.copy_contents_to(linkedholodeck)

		spawn(30)
			for(var/obj/effect/landmark/L in linkedholodeck)
				if(L.name=="Atmospheric Test Start")
					spawn(20)
						var/turf/T = get_turf(L)
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(2, 1, T)
						s.start()
						if(T)
							T.temperature = 5000
							T.hotspot_expose(50000,50000,1,surfaces=1)

		active = 1
	else
		for(var/item in holographic_items)
			derez(item)
		var/area/targetsource = locate(/area/holodeck/source_plating)
		targetsource.copy_contents_to(linkedholodeck , 1)
		active = 0

/obj/machinery/computer/HolodeckControl/proc/loadProgram(var/area/A)


	if(world.time < (last_change + 25))
		if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
			return
		for(var/mob/M in range(3,src))
			M.show_message("<B>ERROR. Recalibrating projetion apparatus.</B>")
			last_change = world.time
			return

	last_change = world.time
	active = 1

	for(var/item in holographic_items)
		derez(item)

	for(var/obj/effect/decal/cleanable/blood/B in linkedholodeck)
		returnToPool(B)

	for(var/mob/living/simple_animal/hostile/carp/holocarp/holocarp in linkedholodeck)
		qdel(holocarp)

	holographic_items = A.copy_contents_to(linkedholodeck , 1)

	if(emagged)
		for(var/obj/item/weapon/holo/esword/H in linkedholodeck)
			H.damtype = BRUTE

	spawn(30)
		for(var/obj/effect/landmark/L in linkedholodeck)
			if(L.name=="Atmospheric Test Start")
				spawn(20)
					var/turf/T = get_turf(L)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, T)
					s.start()
					if(T)
						T.temperature = 5000
						T.hotspot_expose(50000,50000,1,surfaces=1)
			if(L.name=="Holocarp Spawn")
				new /mob/living/simple_animal/hostile/carp/holocarp(L.loc)

/obj/machinery/computer/HolodeckControl/proc/emergencyShutdown()
	//Get rid of any items
	for(var/item in holographic_items)
		derez(item)
	//Turn it back to the regular non-holographic room
	target = locate(/area/holodeck/source_plating)
	if(target)
		loadProgram(target)

	var/area/targetsource = locate(/area/holodeck/source_plating)
	targetsource.copy_contents_to(linkedholodeck , 1)
	active = 0

// Holographic Items!

/turf/simulated/floor/holofloor/
	thermal_conductivity = 0

/turf/simulated/floor/holofloor/grass
	name = "Lush Grass"
	icon_state = "grass1"
	floor_tile = new/obj/item/stack/tile/grass

	New()
		floor_tile.New() //I guess New() isn't run on objects spawned without the definition of a turf to house them, ah well.
		icon_state = "grass[pick("1","2","3","4")]"
		..()
		spawn(4)
			update_icon()
			for(var/direction in cardinal)
				if(istype(get_step(src,direction),/turf/simulated/floor))
					var/turf/simulated/floor/FF = get_step(src,direction)
					FF.update_icon() //so siding get updated properly

/turf/simulated/floor/holofloor/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return
	// HOLOFLOOR DOES NOT GIVE A FUCK



/obj/structure/table/holotable
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	layer = 2.8
	throwpass = 1	//You can throw objects over this, despite it's density.

/obj/structure/table/holotable/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/table/holotable/attack_alien(mob/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_animal(mob/living/simple_animal/user as mob) //Removed code for larva since it doesn't work. Previous code is now a larva ability. /N
	return attack_hand(user)

/obj/structure/table/holotable/attack_hand(mob/user as mob)
	return // HOLOTABLE DOES NOT GIVE A FUCK

/obj/structure/table/holotable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		visible_message("<span class='warning'>[G.assailant] puts [G.affecting] on the table.</span>")
		qdel(W)
		return

	if(iswrench(W))
		to_chat(user, "It's a holotable!  There are no bolts!")
		return

	if(isrobot(user))
		return

/obj/structure/table/holotable/wood
	name = "table"
	desc = "A square piece of wood standing on four wooden legs. It can not move."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodtable"

/obj/item/clothing/gloves/boxing/hologlove
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	item_state = "boxing"

/obj/structure/holowindow
	name = "reinforced window"
	icon = 'icons/obj/structures.dmi'
	icon_state = "rwindow"
	desc = "A window."
	density = 1
	layer = 3.2//Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

/obj/structure/holowindow/Destroy()
	..()

/obj/item/weapon/holo
	damtype = HALLOSS

/obj/item/weapon/holo/esword
	desc = "May the force be within you. Sorta"
	icon_state = "sword0"
	force = 3.0
	throw_speed = 1
	throw_range = 5
	throwforce = 0
	w_class = 2
	flags = FPRINT
	var/active = 0

/obj/item/weapon/holo/esword/green
	New()
		..()
		_color = "green"

/obj/item/weapon/holo/esword/red
	New()
		..()
		_color = "red"

/obj/item/weapon/holo/esword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/holo/esword/attack(target as mob, mob/user as mob)
	..()

/obj/item/weapon/holo/esword/New()
	AddToProfiler()
	_color = pick("red","blue","green","purple")

/obj/item/weapon/holo/esword/attack_self(mob/living/user as mob)
	active = !active
	if(active)
		force = 30
		icon_state = "sword[_color]"
		w_class = 4
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		icon_state = "sword0"
		w_class = 2
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)
	return

//BASKETBALL OBJECTS

/obj/item/weapon/beach_ball/holoball
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	name = "basketball"
	item_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = 4 //Stops people from hiding it in their bags/pockets

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!."
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = 1
	density = 1
	throwpass = 1

/obj/structure/holohoop/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/grab) && get_dist(src,user)<2)
		var/obj/item/weapon/grab/G = W
		if(G.state<GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return

		G.affecting.forceMove(src.loc)
		G.affecting.Weaken(5)
		visible_message("<span class='warning'>[G.assailant] dunks [G.affecting] into the [src]!</span>")
		qdel(W)
		return
	else if (istype(W, /obj/item) && get_dist(src,user)<2)
		if(user.drop_item(W, src.loc))
			visible_message("<span class='notice'>[user] dunks [W] into the [src]!</span>")
			return

/obj/structure/holohoop/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/weapon/dummy) || istype(I, /obj/item/projectile))
			return
		if(prob(50))
			I.forceMove(src.loc)
			visible_message("<span class='notice'>Swish! \the [I] lands in \the [src].</span>")
		else
			visible_message("<span class='warning'>\The [I] bounces off of \the [src]'s rim!</span>")
		return 0
	else
		return ..(mover, target, height, air_group)


/obj/machinery/readybutton
	name = "Ready Declaration Device"
	desc = "This device is used to declare ready. If all devices in an area are ready, the event will begin!"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/ready = 0
	var/area/currentarea = null
	var/eventstarted = 0

	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/readybutton/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices")
	return

/obj/machinery/readybutton/attack_paw(mob/user as mob)
	to_chat(user, "You are too primitive to use this device")
	return

/obj/machinery/readybutton/New()
	..()

/obj/machinery/readybutton/attackby(obj/item/weapon/W as obj, mob/user as mob)
	to_chat(user, "The device is a solid button, there's nothing you can do with it!")

/obj/machinery/readybutton/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return

	currentarea = get_area(src.loc)
	if(!currentarea)
		qdel(src)

	if(eventstarted)
		to_chat(usr, "The event has already begun!")
		return

	ready = !ready
	update_icon()

	var/numbuttons = 0
	var/numready = 0
	for(var/obj/machinery/readybutton/button in currentarea)
		numbuttons++
		if (button.ready)
			numready++

	if(numbuttons == numready)
		begin_event()

/obj/machinery/readybutton/update_icon()
	if(ready)
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/readybutton/proc/begin_event()


	eventstarted = 1

	for(var/obj/structure/holowindow/W in currentarea)
		qdel(W)

	for(var/mob/M in currentarea)
		to_chat(M, "FIGHT!")
