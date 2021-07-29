--[[

Snuggles Supernova FFXI (75 cap) Pivate Servers Bard Gearswap Script V.1

This file is loosely based off of Kinematics bard scripts, but has ultimately been gutted for 75 cap simplification and optimization,
I've also added several of my own personal touches. I have heavily commented most aspects so that it is user friendly
for anyone wanting to get started with gearswap. Feel free to ignore the comments if you are a pro :)

This Gearswap file uses Motenten's library files for Gearswap available here: https://github.com/Kinematics/Mote-libs
just click "Code" and then "Download Zip" then extract them into the gearswap/libs folder. (they may already be there, if so, this step is not necessary)

It also uses the Cancel plugin, but if you don't have/want it, I don't think it'll cause any errors. Just manually cancel Stoneskin and Utsusemi: Ni buffs.

Features:
          automatic minstrel ring activation on every song
		  stops yellow hp set while weakened so you don't drop to 1 hp while playing songs (ring still procs)
		  lullaby timer reminders, with and without troubadour buff
		  korin/hachirin obi activation on cures when appropriate
		  automatically cancel utsusemi ni when casting ichi
		  melee and dual wield toggles to preserve tp
		  auto macro book/page changing when loaded or changing subjob
		  auto lockstyle of choice on load or SJ change
		  automatically change to your nation's aketon when in appropriate zones
		  gear validation check to ensure you don't leave home without something

ToDo: gitgud at bard.

Note on Minstrel's Ring: You will have more hp as /nin than the standard /whm or /rdm subs. Take this into account for your precast yellow set's hp calculations.
Additionally, if you eat food with +HP on it, make sure you calculate for that. And lastly but perhaps most importantly, you should consider that if you use
Rostrum Pumps in your fast cast set, you will need to calculate more -hp in your yellow set as it will start counting from a 30 hp lower max hp 
than your bardbuff /debuff set.

My song casting hp % before food for /whm or /rdm is 69/70%. When song is finished my idleSet will bring me back to 81% hp. For /nin its's 69% and 79% respectively.
With food take 1% or 2%(hq) off of each (rolandberry daifuku). That is to say I am never in Yellow HP for more than the time it takes to play a song.
Healers are more likely to leave you alone in this case, and you're less likely to stress them out.

Note on shiekh manteel: I have found no discernable spellcasting time difference while using it with my fastcast set + minstrels ring. So I don't use it.
It's possible with my fastcast set i'm hitting or close to hitting the -50% songcasting hardcap before Nightingale.
Your results may differ depending on your gear, and you might get some use out of it.

On /whm, with my fastcast set + ring, my first song finishes at about 38% of cast bar completion, and I can start the second song when it gets to around 52%.
It's slightly faster on /rdm due to the Enhanced Fast Cast trait.

One button toggle macro you can use with this script for buffs:

    /ma "Stoneskin" <me>
	/ma "Blink" <me>
	/ma "Phalanx" <me>

You can just hit the same macro 1-3 times (depending on your sj) as needed. just fill out your macro lines as shown above.

]]--

-- Initialization function for this job file.
function get_sets()
	mote_include_version = 2

    -- load and initialize the include file.
    include("Mote-Include.lua")
end

-- Setup vars that are user-dependent.
function user_setup()
    -- toggles melee/normal mode with F9
	-- if for some reason you have F9 unbound, you can use //gs c cycle OffenseMode to toggle between the two, or macro it
	-- macro ex: /console gs c cycle OffenseMode
	-- melee = disables main, sub and ammo slots so you can keep your tp when you disengage
	-- normal = after any event (spell, rest, disengage, etc) you will return to your normal idle set
	state.OffenseMode:options('Normal', 'Melee')

	-- same as above but for Dual Wield, use Control+F9 to toggle or //gs c cycle HybridMode
	-- macro ex: /console gs c cycle HybridMode
	-- you will need to manually equip your offhand weapon for DW
	state.HybridMode:options('Normal', 'DW')

    -- select your bard's macro book/page to load on initial job or subjob change. Page # first, then book #.
	-- when already logged in and changing to bard, I recommend changing your chosen subjob before main, so it runs once.
    if player.sub_job == 'WHM' or player.sub_job == 'RDM' then
        set_macro_page(4, 18)
	elseif player.sub_job == 'NIN' then
	    set_macro_page(5, 18)
	elseif player.sub_job == 'DNC' then
	    set_macro_page(6, 18)
	end

    -- equip idle set, turn on chosen lockstyleset (100 in my case), and check to make sure we have all our gear
	-- if you login and validation fails, type //gs validate to run it again, or adjust the wait time below and reload
    send_command("wait 2;gs equip idle;wait 3;input /lockstyleset 100;wait 2;input //gs validate")
end

-- Called when this job file is unloaded (job change).
function user_unload()
-- re-enable our body slot if was locked from aketon function
    enable('body')
end

-- Define sets and vars used by this job file.
function init_gear_sets()

	--------------------------------------
    -- Start defining the sets
    --------------------------------------

    -- Precast Sets

    -- fast cast gear set
    sets.precast.FC = {
        sub = "Vivid Strap +1",
        back = "Veela Cape",
        feet = "Rostrum Pumps",
        left_ear = "Loquac. Earring"
    }

	-- HP minus or hp>mp convert gear to bring us to yellow HP so we can proc minstrel's ring
	-- base yellow hp on the highest hp of the song buff/debuff sets you will define below
	-- you MUST put Minstrel's ring in this set!!
    sets.precast.yellow = {
	    head ="Empress Hairpin",
	    neck ="Star Necklace",  -- I only need this with HQ food or /nin, otherwise I comment it out
        body = "Dalmatica +1",
        hands = "Zenith Mitts +1",
        right_ear = "Astral Earring",
		left_ring = "Serket Ring",
		right_ring= "Minstrel's Ring",
        waist = "Scouter's Rope"
    }

    -- waltz set (chr and vit)
    sets.precast.Waltz = {
        range = "Gjallarhorn",
        head = "Genbu's Kabuto",
        left_ear = "Melody Earring +1",
        right_ear = "Melody Earring +1",
        body = "Kirin's Osode",
        hands = "Bricta's Cuffs",
        back = "Bard's Cape",
		waist = "Warwolf Belt",
        legs = "Sheikh Seraweels",
        feet = "Dance Shoes +1"
    }

    -- Weaponskill set

	-- I use this set for Evisceration and Mercy Stroke w/Dagger
	-- you can define other ws sets, ex: sets.precast.WS['Spirit Taker']
    sets.precast.WS = {
        head = "Hecatomb Cap +1",
        body = "Hct. Harness +1",
        hands = "Hct. Mittens +1",
        legs = "Hct. Subligar +1",
        feet = "Hct. Leggings +1",
        neck = "Soil Gorget",
        waist = "Warwolf Belt",
        left_ear = "Harmonius Earring",
        right_ear = "Brutal Earring",
        left_ring = "Rajas Ring",
        right_ring = "Strigoi Ring",
        back = "Cerb. Mantle +1"
    }

    -- Midcast Sets

    -- recast reduction for spells that don't require a defined set
	-- +haste % gear goes here (caps at 25% haste, I use 26% for margin of error)
	-- for spells like: Erase, Regen, Protect, Shell, Raise, Reraise, Sneak, Invisible
    sets.midcast.FastRecast = {
        range = "Angel Lyre",
        head = "Walahra Turban",
        Body = "Goliard Saio",
        Hands = "Dusk Gloves +1",
        waist = "Speed Belt",
        Legs = "Byakko's Haidate"
    }

    -- for song buffs
    sets.midcast.SongBuff = {
        range = "Gjallarhorn",
        main = "Chanter's Staff",
        sub = "Reign Grip",
        head = "Demon Helm +1",
        neck = "Wind Torque",
        left_ear = "Singing Earring",
        right_ear = "Wind Earring",
        body = "Minstrel's Coat",
        hands = "Sheikh Gages", -- 0 chance im doing bard af quests, come at me
        left_ring = "Nereid Ring",
        right_ring = "Nereid Ring",
        back = "Astute Cape",
        waist = "Speed Belt",  -- marching belt prz
        legs = "Sheikh Seraweels",
        feet = "Oracle's Pigaches"
    }

    -- for song defbuffs
    sets.midcast.SongDebuff = {
        range = "Gjallarhorn",
        main = "Chatoyant Staff",
        sub = "Reign Grip",
        head = "Demon Helm +1",
        neck = "Wind Torque",
        left_ear = "Singing Earring",
        right_ear = "Wind Earring",
        body = "Mahatma Hpl.",
        hands = "Bricta's Cuffs",
        left_ring = "Nereid Ring",
        right_ring = "Nereid Ring",
        back = "Astute Cape",
        waist = "Speed Belt",
        legs = "Sheikh Seraweels",
        feet = "Oracle's Pigaches"
    }

    sets.midcast.requiem = set_combine(sets.midcast.SongDebuff, {range = "Requiem Flute"})

    -- enfeebling skill + Macc + MND (this is mostly for slow, paralyze and silence)
    sets.midcast["Enfeebling Magic"] = {
        sub = "Reign Grip",
        head = "Ree's Headgear",
        neck = "Enfeebling Torque",
		left_ear = "Incubus Earring +1",
        right_ear = "Enfeebling Earring",
        body = "Mahatma Hpl.",
        hands = "Oracle's Gloves",
        left_ring = "Celestial Ring",
        right_ring = "Celestial Ring",
        back = "Altruistic Cape",
        waist = "Pythia Sash +1",
        legs = "Mahatma Slops",
        feet = "Goliard Clogs"
    }

    -- other general spells
    sets.midcast.Cure = {
        main = "Chatoyant Staff",
        sub = "Reign Grip",
        head = "Goliard Chapeau",
        neck = "Fylgja Torque +1",
        right_ear = "Celestial Earring",
        left_ear = "Celestial Earring",
        body = "Mahatma Hpl.",
        hands = "Bricta's Cuffs",
        left_ring = "Celestial Ring",
        right_ring = "Celestial Ring",
        back = "Dew Silk Cape +1",
        waist = "Pythia Sash +1",
        legs = "Mahatma Slops",
        feet = "Suzaku's Sune-Ate"
    }

    sets.midcast.Curaga = sets.midcast.Cure

    sets.midcast.Stoneskin = {
        main = "Chatoyant Staff",
        sub = "Reign Grip",
        head = "Goliard Chapeau",
        neck = "Enhancing Torque",
        right_ear = "Augment. Earring",
        left_ear = "Celestial Earring",
        body = "Mahatma Hpl.",
        hands = "Bricta's Cuffs",
        left_ring = "Celestial Ring",
        right_ring = "Celestial Ring",
        back = "Merciful Cape",
        waist = "Pythia Sash +1",
        legs = "Mahatma Slops",
        feet = "Suzaku's Sune-Ate"
    }


	sets.midcast.Blink = sets.midcast.Stoneskin

	sets.midcast.Phalanx = sets.midcast.Stoneskin

	sets.midcast.BarElement = sets.midcast.Stoneskin

    -- Resting set

	-- equip our rest set when we /heal for MP. fill it with lots of +hMP here
    sets.resting = {
        main = "Chatoyant Staff",
        head = "Mirror Tiara",
        neck = "Gnole Torque",
        left_ear = "Antivenom Earring",
        right_ear = "Relaxing Earring",
        body = "Mahatma Hpl.",
        hands = "Oracle's Gloves",
        left_ring = "Celestial Ring",
        right_ring = "Celestial Ring",
        back = "Invigorating Cape",
        waist = "Qiqirn Sash +1",
        legs = "Oracle's Braconi",
        feet = "Goliard Clogs"
    }

    -- Idle sets

	-- we'll return to this set when we finish doing any action
    sets.idle = {
        main = "Terra's Staff",
        sub = "Reign Grip",
        range = "Gjallarhorn",
        head = "Optical Hat",
        neck = "Evasion Torque",
        left_ear = "Melody Earring +1",
        right_ear = "Melody Earring +1",
        body = "Dalmatica +1",
        hands = "Patrician's Cuffs",
        left_ring = "Succor Ring",
        right_ring = "Shadow Ring",
        back = "Shadow Mantle",
        waist = "Scouter's Rope",
        legs = "Goliard Trews",
        feet = "Dance Shoes +1"
    }

	-- we'll swap to this set with the 'Weakness' status. I put a little +hp for survivability and to add balance
	-- don't go overboard with +hp, you want it pretty similar to your other sets hp values (+125 for me and -scouters rope)
	sets.idle.Weak = {
        main = "Terra's Staff",
        sub = "Reign Grip",
        range = "Gjallarhorn",
        head = "Optical Hat",
        neck = "Bloodbead Gorget",
        left_ear = "Melody Earring +1",
        right_ear = "Melody Earring +1",
		body = "Dalmatica +1",
        hands = "Creek F Mitts",
        left_ring = "Succor Ring",
        right_ring = "Shadow Ring",
        back = "Shadow Mantle",
        waist = "Resolute Belt",
        legs = "Goliard Trews",
        feet = "Dance Shoes +1"
    }
    -- Engaged set

    -- basic set for TP, don't forget to toggle F9 or ctrl+F9(for dual wield) so you don't lose your tp!
	-- I'm always eating acc food, so your gear needs may differ
    sets.engaged = {
	    main = "Mandau",
        range = "Angel Lyre",
        head = "Walahra Turban",
        neck = "Ancient Torque",
        right_ear = "Brutal Earring",
        left_ear = "Pixie Earring",
        body = "Antares Harness",
        hands = "Dusk Gloves +1",
        left_ring = "Lava's Ring",
        right_ring = "Kusha's Ring",
        back = "Cerb. Mantle +1",
        waist = "Speed Belt",
        legs = "Byakko's Haidate",
        feet = "Dusk Ledelsens +1"
    }

    -- set if dual-wielding (if you don't have suppanomimi, you can comment out this set so validate doesn't annoy you
	-- you still need to manually equip your offhand weapon~
    sets.engaged.DW = set_combine(sets.engaged, {left_ear="Suppanomimi"})

end

-------------------------------------------------------------------------------------------------------------------
-- Functions (rules for when we cast our songs/spells or perform an action)
-------------------------------------------------------------------------------------------------------------------

-- Post precast functions (after regular precast logic and before your actual action begins)
function job_post_precast(spell, action, spellMap, eventArgs)
    -- use yellow set, unless weakened
	if spell.type == 'BardSong' and not buffactive['Weakness'] then
	    equip(sets.precast.yellow)
	elseif spell.type == 'BardSong' and buffactive['Weakness'] then
	-- still use minstrel's ring when weakened, though
        equip({right_ring="Minstrel's Ring"})
	end
end

-- Midcast functions
function job_midcast(spell, action, spellMap, eventArgs)
    if spell.type == "BardSong" then
        equip(sets.midcast.SongBuff)
    end

	-- only use debuff set when we're casting these spells
    if string.find(spell.english, "Elegy") or string.find(spell.english, "Threnody") or
       string.find(spell.english, "Lullaby") or string.find(spell.english, "Finale") then
        equip(sets.midcast.SongDebuff)
    end

	-- requiem uses it's own special flute(+4)
    if string.find(spell.english, "Requiem") then
        equip(sets.midcast.requiem)
    end

	-- equip light obi when appropriate for heals
    if spell.action_type == "Magic" then
        if string.find(spell.english, "Cure") or string.find(spell.english, "Curaga") then
            if world.weather_element == "Light" or world.day_element == "Light" then
		    -- if you have Hachirin-no-Obi put it here instead. I shall remain Scrubbles, tyvm.
				equip ({waist="Korin Obi"})
			end
		end
	end

	-- when casting utsusemi ichi, this makes sure ni is cancelled first
	-- based on differences between your fastcast set and mine, you may need to adjust the wait time here
	if spell.english == 'Utsusemi: Ichi' then
        if buffactive['Copy Image'] then
            send_command('@wait 3.4;cancel 66')
        elseif buffactive['Copy Image (2)'] then
            send_command('@wait 3.4;cancel 444')
        elseif buffactive['Copy Image (3)'] then
            send_command('@wait 3.4;cancel 445')
        end
	end
end

-- Aftercast functions
function job_aftercast(spell, action, spellMap, eventArgs)
-- let us know in chat before lullaby is going to wear so we can be prepared for re-application
-- each +1 song effect is +3 seconds from Lullaby's base 30s, adjust your timer accordingly (mine is set for +2 on songs)
    if spell.english == 'Foe Lullaby' or spell.english == 'Horde Lullaby' then
	    if buffactive['Troubadour'] then
		-- troubadour lullaby is double the duration!
            send_command('@wait 62;input /echo ------- '..spell.english..' is wearing off in 10 seconds -------')
	    else
			send_command('@wait 26;input /echo ------- '..spell.english..' is wearing off in 10 seconds -------')
	    end
    end
end
	
-- Handle switching between normal, melee and dual wield modes (F9 or ctrl+F9 to toggle)
function job_state_change(stateField, newValue, oldValue)
    if stateField == "Offense Mode" then
        if newValue == "Melee" then
            disable("main", "sub", "ammo")
        else
            enable("main", "sub", "ammo")
        end
    end

	if stateField == "Hybrid Mode" then
        if newValue == "DW" then
            disable("main", "sub", "ammo")
        else
            enable("main", "sub", "ammo")
        end
    end
end

  -- equip your nation's aketon in appropriate zones 
  -- remove --[[ and ]]-- from your relevant nation and replace it around nations you aren't a citizen of to comment it out
windower.register_event('zone change',function(zone_id)
    -- windurst
    if (world.area:contains("Windurst") or world.area:contains("Heavens"))
	-- don't equip aketon or lock our body if in dyna windy or windy waters S
	and not (world.area:contains("Dynamis") or world.area:contains("[S]")) then
        equip ({body="Federation Aketon"})
	-- disable our body slot in windy so if we cast mazurka it won't come off
	    disable('body')
    else
	    -- enable body if we're not in windy and equip our idle set
        enable('body')
	    equip(sets.idle)
	end
	
--[[
	-- bastok
    if (world.area:contains("Bastok") or world.area:contains("Metal"))
	and not (world.area:contains("Dynamis") or world.area:contains("[S]")) then
        equip ({body="Republic Aketon"})
        disable('body')
    else
	    enable('body')
        equip(sets.idle)
    end
]]--

--[[	
    -- sandoria
    if (world.area:contains("San dOria") or world.area:contains("Chateau"))
	and not (world.area:contains("Dynamis") or world.area:contains("[S]")) then
        equip ({body="Kingdom Aketon"})
	    disable('body')
    else
	    enable('body')
        equip(sets.idle)
	end
]]--

end)
