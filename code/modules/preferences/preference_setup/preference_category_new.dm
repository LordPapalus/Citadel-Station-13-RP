/datum/category_group/player_setup_category

/datum/category_group/player_setup_category/proc/sanitize_data(datum/preferences/prefs, list/errors)
	for(var/datum/category_item/player_setup_item/preference in items)
		preference.sanitize_data(prefs, errors)

/datum/category_group/player_setup_category/proc/spawn_checks(datum/preferences/prefs, flags, list/errors)
	. = TRUE
	for(var/datum/category_item/player_setup_item/preference in items)
		if(!preference.spawn_checks(prefs, prefs.get_character_data(preference), flags, errors))
			. = FALSE

// todo: multi stage random character generation