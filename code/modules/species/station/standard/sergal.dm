/datum/species/sergal
	name = SPECIES_SERGAL
	name_plural = "Naramadi"
	default_bodytype = BODYTYPE_SERGAL
	icobase = 'icons/mob/human_races/r_sergal.dmi'
	deform = 'icons/mob/human_races/r_def_sergal.dmi'
	tail = "tail"
	icobase_tail = 1
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/bite/sharp)
	slowdown      = -0.25
	snow_movement = -1 // Ignores light snow
	//darksight = 8
	//slowdown = -0.5
	//brute_mod = 1.15
	//burn_mod =  1.15
	//gluttonous = 1
	hunger_factor = 0.1 // By math should be half of the Teshari Nutrition drain
	num_alternate_languages = 3
	secondary_langs = list(LANGUAGE_SAGARU)
	name_language = LANGUAGE_SAGARU
	color_mult = 1

	max_age = 120

	blurb = "The Naramadi (Plural of Naramad) are a species of bipedal, furred mammalians originating from the Verkihar Major system. \
	They share a border with the Unathi, granting both of the species a history of war. \
	Naramadi Ascendancy's location also brings forth a constant danger of Hivebot Fleets attacks, leaving the Empire in a state of constant Defense."

	wikilink=""

	catalogue_data = list(/datum/category_item/catalogue/fauna/sergal)

	primitive_form = SPECIES_MONKEY_SERGAL

	spawn_flags = SPECIES_CAN_JOIN
	species_appearance_flags = HAS_HAIR_COLOR | HAS_LIPS | HAS_UNDERWEAR | HAS_SKIN_COLOR | HAS_EYE_COLOR
	inherent_verbs = list(
		/mob/living/proc/shred_limb,
		/mob/living/carbon/human/proc/tie_hair
		)

	flesh_color = "#AFA59E"
	base_color = "#777777"

	heat_discomfort_strings = list(
		"Your fur prickles in the heat.",
		"You feel uncomfortably warm.",
		"Your overheated skin itches."
		)

	has_limbs = list(
		BP_TORSO =  list("path" = /obj/item/organ/external/chest),
		BP_GROIN =  list("path" = /obj/item/organ/external/groin),
		BP_HEAD =   list("path" = /obj/item/organ/external/head/vr/sergal),
		BP_L_ARM =  list("path" = /obj/item/organ/external/arm),
		BP_R_ARM =  list("path" = /obj/item/organ/external/arm/right),
		BP_L_LEG =  list("path" = /obj/item/organ/external/leg),
		BP_R_LEG =  list("path" = /obj/item/organ/external/leg/right),
		BP_L_HAND = list("path" = /obj/item/organ/external/hand),
		BP_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BP_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BP_R_FOOT = list("path" = /obj/item/organ/external/foot/right)
		)