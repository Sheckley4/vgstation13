/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = 1
	layer = TURF_LAYER

/obj/effect/decal/cleanable/ash/attack_hand(mob/user as mob)
	user.visible_message("<span class='notice'>[user] wipes away \the [src].</span>")
	qdel(src)

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "dirt"

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	luminosity = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"

/obj/effect/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/obj/chemical.dmi'
	icon_state = "molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"

	basecolor="#FFFF99"
	amount = 2
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	transfers_dna = 1

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/fruit_smudge
	name = "smudge"
	desc = "Some kind of fruit smear."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("fruit_smudge1", "fruit_smudge2", "fruit_smudge3")
	icon_state = "fruit_smudge1"

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/tomatodecal.dmi'
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/scattered_sand
	name = "scattered sand"
	desc = "Now how are you gonna sweep it back up, smartass?"
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "sand"
	gender = PLURAL

/obj/effect/decal/cleanable/campfire
	name = "burnt out campfire"
	icon_state = "campfire"
	desc = "This burnt-out campfire reminds you of someone."
	anchored = 1
	density = 0
	layer = 2
	icon = 'icons/obj/atmos.dmi'
	icon_state = "campfire_burnt"

/obj/effect/decal/cleanable/clay_fragments
	name = "clay fragments"
	desc = "pieces from a broken clay pot"
	gender = PLURAL
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "clay_fragments"
	anchored = 0
	layer=2

/obj/effect/decal/cleanable/clay_fragments/New()
	..()
	pixel_x = rand (-3,3)
	pixel_y = rand (-3,3)

/obj/effect/decal/cleanable/soot
	name = "soot"
	desc = "One hell of a party..."
	gender = PLURAL
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "tile_soot"
	anchored = 1
	layer=2



/obj/effect/decal/cleanable/soot/New()
	..()
	dir = pick(cardinal)

/obj/effect/decal/cleanable/lspaceclutter
	name = "clutter"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/effects.dmi'
	icon_state = "lspaceclutter"

/obj/effect/decal/cleanable/cockroach_remains
	name = "cockroach remains"
	desc = "A disgusting mess."
	icon = 'icons/mob/animal.dmi'
	icon_state = "cockroach_remains1"

/obj/effect/decal/cleanable/cockroach_remains/New()
	..()
	icon_state = "cockroach_remains[rand(1,2)]"
