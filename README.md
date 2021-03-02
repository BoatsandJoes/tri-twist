# tri-twist
todo next:
	give Timo repo permissions
	test tumbling off an overhang (it should go 1 farther, because clears can lock an overhang into place and then you could build a slope on top of it, and the immediate drop is unexpected.) see if it's fixed
	Change internal state to frames (this should fix suspension bug--which I can't reproduce...-- and make serializing/synchronizing game state easier)
	Add tuning settings
	ui with score, time, moves, etc
	controller support
	main menu
	license
	credits

Tuning settings (*- can ramp for difficulty, based on score or moves or time or some combination):
	DAS/ARR
	Piece drop cooldown
	Rotate allowed
	Hard drop allowed (the only reason to soft drop is if you want to change piece order and get another, later piece under it with hard drop)
	Gravity* (ramp to keep pace with other changes only. As gravity gets faster, piece height matters less; matches low down effectively have shorter timers in low gravity. So high gravity kind of gets easier, but high gravity is bad for learning. Instant sounds fun though)
	Clear timer (including literally 0 and infinite + button or + scaling)* (ramping is weird because it doesn't change the difficulty of match 2, so digging actually gets faster. Could just keep pace with gravity? In that case chain extensions at the bottom of the board would not change difficulty, but top would get harder.)
	Clear timer scaling (lower numbers could literally never clear until a third is added and that would also work. Technically that's what single triangles are already doing. Could clear instantly at a certain number (although could connect a neighboring chain to extend more… seems powerful and annoying to do)
	Forced drop timer* (most powerful way to end the game)
	# colors*
	# previews* (ramping would be weird)
	Grid size*
	Garbage incoming at regular intervals*
	Ghost piece search depth (0, contact stack, final resting place, final resting place of balancing pieces)* (ramping would be weird, people don't like it in TGM. It could be made better to keep pace with gravity, maybe, but probably just starting with the best version is fine)
	Hold
	Nice randomizer* (ramping this would be wild):
		First two pieces restricted to avoid annoying cases (is it more annoying to have no match possible, or have a forced match? or are both fine?)
		All triangles solid (very interesting)
		Bag
		Puyo 2 randomizer
		Piece history
		Piece reroll
		TGM 3 randomizer
	Time limit (could have score extension)
	Piece limit (could have score extension)
	Score quota (could function as time/piece extension)
	a chain of sufficient size (maybe the cap?) could award a helpful item piece (either random, specific, or choose based on some controlable criteria like chain length or tucks or color distribution)

Score:
	4 match should be bigger than 2 2 matches, but idk exactly how much it should scale up. Depends on chain length distribution
	Tucking into the middle of a chain is already implicitly worth more (longer chain), so maybe it doesn't need to award points, but maybe it should or at least make a different sound (this would raise the skill ceiling)
	Rolling at all could award nominal points. It could increase the chain value by a lot or it could not at all
	Non-active chains could award points and then allow extensions (basically only a 2 chain has meaning), but they are difficult to plan (might be cool…)
	All Clear is easy and shouldn't award points
	Could have a TGM/TAP grading system, tie to score or require to fill up a score counter in a short time to advance, or you have to hit score extensions to get the highest grade (but missing them you don't lose)

Multiplayer:
	GGPO is a C++ module so I could compile the engine with both modules, or remove FMod, or change to FMod GDNative
	Could have people play 2 single player games side by side and see who wins, either playing a game to completion and seeing who did better, or going over a certain score differential
	Could have item attacks/buffs like (stars on the actually good ideas):
		match anything and whatever matches, mass replace that color with a random other color (probably making a big clear)*
		explode when matched, either in a line or in an area*
		board shuffle, flip, rotate
		extra color
		mess with tuning settings (see tuning)
		Invisible mode
		Piece pairs (this is horrifying)*
		Ice (pieces slide down w/o tumbling and then slide sideways too)*
		Garbage (see garbage)*
	Garbage:
		come in like:
			Petal Crash?
			Tetris (kind of like changing grid size but you can dig out in chunks) (I think I like this one. Only thing I don't like about it is you have to send a FULL line every time. Would need to make the grid big so one line is nbd)
		cleared like:
			puyo (I think I like this one, because it changes the way you play to shorter chains if you want to dig through multiple lines)
			Petal Crash garbage attack
			puzzle fighter (normal piece but unclearable for some moves/time, they're still really not that different from ordinary pieces so idk)
			tofu (gives opponent points when cleared)
		Counter like:
			T99 with garbage limit/delay, better for new players but too easy to defend against when you're good
			Puyo/guideline
		Damage formula:
			seems hard but basically same as guideline tetris or maybe include petal crash tug of war for bad players
	Attacks could ramp certain tuning settings to make the game harder for the opponent or kill them (like grid size)
	Each player could do different kinds of attacks, potentially tied to a character (do you pick your attack, or your opponent's attack?)
	Coop:
		shared board coop
		shared score/ramp separate board coop
		Could send each other helpful items
		Twist + drop coop
Scope Creep:
	Juice in gameplay and menus and characters:
		Art
		animations
		VFX
		Music
		SFX
		color choices (in menu or per character or both)
	Core singleplayer modes:
		Triathlon (tuning and ramp are basically difficulties, plus 100% custom mode which will technically be the first mode I make)
		Zen
		Vs cpu
		Death mode with instant gravity and fast pace, focused on survival
		Purify/dig race/Dr mario
		Mystery/Item
		Training
		Story mode:
			Any other mode or item effect can be a stage
			Could have some floating cells permanently filled as maps
			Puzzle mode
			Each stage tracks completion score/time/moves
				could have stars/goals that gate progress
				dev records
			Would love to have story before and after levels
	Core multiplayer modes (see multiplayer)
	online play
	button configuration
	controller support
	mobile port
	Tutorials
Things that I want but will have to cut:
	steam leaderboards
	steam achievements
	Daily challenge
	save/share rulesets
	replays
		watch leaderboard replays
		export clip/video
	Big ruleset changes:
		Twist mode (basically just bejeweled):
			Single piece rotate
			Tumble fill/direct fill
			Analysis paralysis is a problem
			Can have no possible moves although it's rareish; need board shakeup like bejewled
		Literally just Carcassonne

Credits
Joe
Timo
Crimefighter (playtesting, came up with idea of edge match clear)
BunniesFromHell (balancing, no, the other kind of balancing)
Thank you indie developers:
	Tim Ashley Jenkins
	Dave Makes
	Derek Yu
	Andy Hull
	Tom Francis
	Bennett Foddy