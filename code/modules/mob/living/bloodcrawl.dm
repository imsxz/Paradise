//Travel through pools of blood. Slaughter Demon powers for everyone!


/mob/living/proc/phaseout(var/obj/effect/decal/cleanable/B)
	var/mob/living/kidnapped = null
	var/turf/mobloc = get_turf(src.loc)
	var/turf/bloodloc = get_turf(B.loc)
	if(Adjacent(bloodloc))
		src.notransform = TRUE
		spawn(0)
			src.visible_message("<span class='danger'>[src] sinks into [B].</span>")
			playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
			var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "odd blood"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "jaunt"
			animation.layer = 5
			animation.master = holder
			animation.dir = src.dir

			src.ExtinguishMob()
			if(src.buckled)
				src.buckled.unbuckle()
			if(src.pulling && src.bloodcrawl == 2)
				if(istype(src.pulling, /mob/living/))
					var/mob/living/victim = src.pulling
					if(victim.stat == CONSCIOUS)
						src.visible_message("[victim] kicks free of \the [src] at the last second!")
					else
						victim.loc = holder///holder
						src.visible_message("<span class='danger'><B>\The [src] drags [victim] into [B]!</B></span>")
						kidnapped = victim
			flick("jaunt",animation)
			src.loc = holder
			src.holder = holder

			if(kidnapped)
				src << "<B>You begin to feast on [kidnapped]. You can not move while you are doing this.</B>"
				src.visible_message("<span class='warning'><B>Loud eating sounds come from the blood...</B></span>")
				GibEat(kidnapped)
				sleep(6)
				if (animation)
					qdel(animation)
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				GibEat(kidnapped)
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				GibEat(kidnapped)
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
				src.adjustBruteLoss(-1000)
				kidnapped.ghostize()
				qdel(kidnapped)
				new /obj/effect/gibspawner/human(get_turf(src))///Somewhere a janitor weeps.
				if (istype(src, /mob/living/simple_animal/slaughter)) //rason, do not want humans to get this

					var/mob/living/simple_animal/slaughter/demon = src

					demon.devoured++
					//src.kidnapped = null
					if (demon.devoured == 5)
						src.mind.current.verbs += /mob/living/simple_animal/slaughter/proc/goreThrow
						src.mind.current.verbs += /mob/living/simple_animal/slaughter/proc/bloodSac
						src << "<span class='notice'> You have consumed enough to be able to summon Excess Gore.</span>"
			else
				sleep(6)
				if (animation)
					qdel(animation)
			src.notransform = 0

/mob/living/proc/phasein(var/obj/effect/decal/cleanable/B)
	if(src.notransform)
		src << "<B>Finish eating first!</B>"
	else
		var/atom/movable/overlay/animation = new /atom/movable/overlay( B.loc )
		animation.name = "odd blood"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.icon_state = "jauntup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
		animation.layer = 5
		animation.master = B.loc
		animation.dir = src.dir
		flick("jauntup",animation)
		src.loc = B.loc
		src.client.eye = src
		if (prob(25))
			var/list/voice = list('sound/hallucinations/behind_you1.ogg','sound/hallucinations/im_here1.ogg','sound/hallucinations/turn_around1.ogg','sound/hallucinations/i_see_you1.ogg')
			playsound(get_turf(src), pick(voice),50, 1, -1)
		src.visible_message("<span class='warning'><B>\The [src] rises out of \the [B]!</B>")
		playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
		qdel(src.holder)
		src.holder = null
		sleep(6)
		if(animation)
			qdel(animation)

/obj/effect/decal/cleanable/blood/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/obj/effect/decal/cleanable/trail_holder/CtrlClick(mob/living/user)
	..()
	if(user.bloodcrawl)
		if(user.holder)
			user.phasein(src)
		else
			user.phaseout(src)



/turf/CtrlClick(var/mob/living/user)
	..()
	if(user.bloodcrawl)
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
				if(user.holder)
					user.phasein(B)
					break
				else
					user.phaseout(B)
					break

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1
	//invisibility = INVISIBILITY_OBSERVER

/obj/effect/dummy/slaughter/relaymove(var/mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act(severity)
	return 1

/obj/effect/dummy/slaughter/bullet_act(blah)
	return

/obj/effect/dummy/slaughter/singularity_act(blah)
	return


/obj/item/weapon/guts
	name = "guts"
	desc = "Ewwwwwwwwwwww"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"

//Gib helperfunc
/mob/living/proc/GibEat(var/napped)

	//at some point we may eat a robot..and its gonna throw out gibs..
	//don't question...When a demon drags you into a blood portal you have no idea whos gibs you are actually seeing
	//...Or we can just blame bluespace.
	var/atom/throwtarget = get_edge_target_turf(src.holder, get_dir(src.holder, get_step_away(src.holder, src.holder)))

	if(istype(napped,/mob/living/carbon/human))
		var/mob/living/carbon/human/victimType = napped

		var/obj/effect/decal/cleanable/blood/gibs/gore = new victimType.species.single_gib_type(get_turf(src))
		if(victimType.species.flesh_color)
			gore.fleshcolor = victimType.species.flesh_color
		if(victimType.species.blood_color)
			gore.basecolor = victimType.species.blood_color
		gore.update_icon()
		spawn()//Wait for itt....
			gore.throw_at(get_edge_target_turf(throwtarget,pick(alldirs)),rand(10,20),10)

	else//in case we eat ian.
		new /obj/effect/gibspawner/human(get_turf(src))

	var/obj/tossGuts = new /obj/item/weapon/guts(get_turf(src.holder))
	tossGuts.throw_at(get_edge_target_turf(throwtarget,pick(alldirs)),rand(10,20),5)
