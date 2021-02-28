# tri-twist
ruleset tweaks:
	grid size
	square
	# of colors
	falling pieces can/can't form matches with fixed pieces or with each other
	restrict how quickly you can drop/DAS/ARR/hard drop
	gravity speed
	# previews
	don't want to make areas but instead just match edges of the same color (more focus on making chains)
	rotate rotates positions of neighbors instead of neighbors twisting in place
	rotate before dropping
	different ways to handle unclearable pieces:
		just keep it as a lose/win condition
		detect and clear immediately or change piece type: award points
		rotate positions rule
		delete as a limited resource (mass delete one color maybe)
	different restrictions on how much you can drop or twist
		switch at time interval or move interval
		free switch but # of twists limited
		you only twist, board fills up either instantly or drops pieces at regular intervals
		you can't twist at all
	time limit/turn limit
	areas don't pop right away
	score
		active chain
		chains can give points but not too many if they're so hard to plan (depends on other rules)
		using a piece in 2 areas should give good points
		bigger areas means bigger points
multiplayer
	one board versus, p1 and p2 each have "their color"
		they either want to clear more of theirs or have more unclearable colors of theirs
	seperate boards versus, play for quota or top out (garbage sends pieces with third color?)
	same board coop/versus, one player drops and the other rotates

other stuff:
2 cute characters, one for each color or one for drop/twist (3rd for squares?)
color choices, like splatoon

todo next:
	ui with score, time, moves, previews, ghost piece, etc
	controller support
	main menu
	experiment with rulesets
