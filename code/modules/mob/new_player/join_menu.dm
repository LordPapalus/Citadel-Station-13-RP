GLOBAL_DATUM_INIT(join_menu, /datum/join_menu, new)

/**
 * Global singleton for holding TGUI data for players joining.
 */
/datum/join_menu

/datum/join_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JoinMenu", "Join Menu")
		ui.open()

/datum/join_menu/proc/queue_update()
	addtimer(CALLBACK(src, /datum/proc/update_static_data), 0, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/join_menu/ui_state(mob/user)
	return GLOB.explicit_new_player_state

/datum/join_menu/ui_static_data(mob/user)
	. = ..()
	// every entry will have:
	// - faction
	// - department
	// - title, and a description
	// faction dropdown --> department dropdown --> title (slots left) with join button and dropdown for description
	// ghostroles will be considered a ""faction"" but will use a special list.
	var/mob/new_player/N = user
	if(!istype(N))
		return	// nice one lmao

	// generate job list
	var/list/jobs = list()
	.["jobs"] = jobs

	// collect
	var/list/datum/job/eligible = list()
	for(var/title in SSjob.name_occupations)
		var/datum/job/J = SSjob.name_occupations[title]
		if(!(J.join_types & JOB_LATEJOIN))
			continue
		if(!IsJobAvailable(J, N))
			continue
		eligible += J

	// make
	for(var/datum/job/J as anything in eligible)	// already type filtered
		// faction
		var/list/faction
		if(!jobs[J.faction])
			jobs[J.faction] = faction = list()
		else
			faction = jobs[J.faction]
		// department
		var/list/department
		// todo: this is awful
		var/department_name = LAZYACCESS(J.departments, 1)
		department_name = capitalize(department_name)
		if(!jobs[J.faction][department_name])
			jobs[J.faction][department_name] = department = list()
		else
			department = jobs[J.faction][department_name]
		// finally, add job data
		var/slots = J.slots_remaining()
		var/list/data = list(
			"id" = J.id,
			"name" = EffectiveTitle(J, N),
			"desc" = EffectiveDesc(J, N),
			"slots" = slots == INFINITY? -1 : slots,
			"real_name" = J.title
		)
		department += list(data)	// wrap list

	// generate ghostrole list
	var/list/ghostroles = list()
	.["ghostroles"] = ghostroles
	for(var/id in GLOB.ghostroles)
		var/datum/ghostrole/R = GLOB.ghostroles[id]
		// can't afford runtime here
		if(!istype(R) || !IsGhostroleAvailable(R, N))
			continue
		var/slots = R.SpawnsLeft(user.client)
		var/list/data = list(
			"id" = id,
			"name" = R.name,
			"desc" = R.desc,
			"slots" = slots == INFINITY? -1 : slots
		)
		ghostroles += list(data)	// wrap list


/datum/join_menu/ui_data(mob/user)
	. = ..()
	// common info goes into ui data
	var/level = "green"
	switch(GLOB.security_level)
		if(SEC_LEVEL_BLUE)
			level = "blue";
		if(SEC_LEVEL_ORANGE)
			level = "orange";
		if(SEC_LEVEL_VIOLET)
			level = "violet";
		if(SEC_LEVEL_YELLOW)
			level = "yellow";
		if(SEC_LEVEL_GREEN)
			level = "green";
		if(SEC_LEVEL_RED)
			level = "red";
		else
			level = "delta";
	.["security_level"] = level
	.["duration"] = DisplayTimeText(world.time - SSticker.round_start_time)
	// 0 = not evaccing, 1 = evacuating, 2 = crew transfer, 3 = evacuated
	var/evac = 0
	if(SSemergencyshuttle.going_to_centcom())
		evac = 3
	else if(SSemergencyshuttle.online())
		if(SSemergencyshuttle.evac)
			evac = 1
		else
			evac = 2
	.["evacuated"] = evac
	.["charname"] = user.client?.prefs?.real_name || "Unknown User"
	// position in queue, -1 for not queued, null for no queue active, otherwise number
	// if -1, ui should present option to queue
	// if null, ui shouldn't show queue at all or say "there is no queue" etc etc
	.["queue"] = QueueStatus(user)

/**
 * checks if job is available
 * if not, it shouldn't even show
 * if so, return slots
 */
/datum/join_menu/proc/IsJobAvailable(datum/job/J, mob/new_player/N)
	return J.check_client_availability_one(N.client) == ROLE_AVAILABLE

/**
 * checks if ghostrole is available
 * if not, it shouldn't even show
 * if so, return slots
 */
/datum/join_menu/proc/IsGhostroleAvailable(datum/ghostrole/G, mob/new_player/N)
	return G.AllowSpawn(N.client)

/**
 * return effective title - used for alt titles - JOBS ONLY, not ghostroles
 */
/datum/join_menu/proc/EffectiveTitle(datum/job/J, mob/new_player/N)
	#warn this
	return "Job #[rand(1, 100)]"	// i'm sorry sandpoot but atleast you get the code early..

/**
 * returns effective desc - used for alt titles - JOBS ONLY, not ghostroles
 */
/datum/join_menu/proc/EffectiveDesc(datum/job/J, mob/new_player/N)
	#warn impl
	return // blank but CAN be null

/datum/join_menu/proc/QueueStatus(mob/new_player/N)
	return null

/*
/datum/join_menu/proc/QueueStatus(mob/new_player/N)
	QueueActive()? (SSticker.queued_players.Find(N) || -1) : null
*/

/datum/join_menu/proc/QueueActive()
	return FALSE

/*
/datum/join_menu/proc/QueueActive()
	var/relevant_cap = PopCap()
	return length(SSticker.queued_players) || (relevant_cap && living_player_count() > relevant_cap)
*/

/datum/join_menu/proc/PopCap()
	return INFINITY

/*
/datum/join_menu/proc/PopCap()
	. = null
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		. = min(hpc, epc)
	else
		. = max(hpc, epc)
*/

/datum/join_menu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/new_player/N = usr
	if(!istype(N))
		to_chat(usr, "<span class='danger'>You are not in the lobby.</span>")
		return
	switch(action)
		if("join")
			if(!SSticker || !SSticker.IsRoundInProgress())
				to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
				return
			if(!AttemptQueue(usr))
				return
			var/id = params["id"]
			if(!id)
				return
			switch(params["type"])
				if("job")
					if(!config_legacy.enter_allowed)
						to_chat(usr, SPAN_NOTICE("There is an administrative lock on entering the game."))
						return
					var/datum/job/J = SSjob.job_by_id(id)
					if(!J)
						to_chat(usr, "<span class='warning'>Failed to find job [id].")
						return
					to_chat(usr, "<span class='notice'>Attempting to latespawn as [id] ([J.title]).</span>")
					N.AttemptLateSpawn(J)
				if("ghostrole")
					var/datum/ghostrole/R = get_ghostrole_datum(id)
					if(!R)
						to_chat(usr, "<span class='warning'>Failed to find ghostrole [R]</span>")
						return
					to_chat(usr, "<span class='warning'>Attempting to join as ghostrole [id] ([R.name]).</span>")
					N.close_spawn_windows()
					var/client/C = N.client
					var/error = R.AttemptSpawn(C)
					if(istext(error))
						to_chat(C, SPAN_DANGER(error))
		if("queue")
			// AttemptQueue(usr)

/**
 * Return FALSE to block joining.
 */
/datum/join_menu/proc/AttemptQueue(mob/new_player/N)
	. = TRUE
/*
	if(QueueActive() && !(ckey(N.key) in GLOB.admin_datums))
		var/queue_position = SSticker.queued_players.Find(usr)
		if(queue_position == 1)
			if(living_player_count() < CONFIG_GET(number/hard_popcap))
				return TRUE
			to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
			return FALSE
		else
			to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")
			if(queue_position)
				to_chat(usr, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
				return FALSE
			else
				SSticker.queued_players += usr
				to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
				return FALSE
*/

/mob/new_player/proc/LateChoices()
	GLOB.join_menu.ui_interact(src)
