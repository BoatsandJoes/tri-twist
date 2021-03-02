# tri-twist
ruleset tweaks:
	piece could roll off a double-balanced piece
	grid size
	square
	# of colors
	piece randomizer weights/special cases
	restrict how quickly you can drop/DAS/ARR/hard drop
	gravity speed
	# previews
	don't want to make areas but instead just match edges of the same color (more focus on making chains)
	different kinds of board shakeup (rotate, mass delete)
	rotate before dropping
	time limit/turn limit
	areas don't pop right away
	score
		active chain
		regular chains
		using a piece in 2 areas should give good points
		bigger areas means bigger points
		tucks give points
multiplayer
	seperate boards versus, play for quota or top out (garbage sends pieces with garbage color? or just normal garbage blocks?)
	big board coop

other stuff:
cute characters for each color (one can drop the pieces)
color choices, like splatoon

todo next:
	bug where balancing pieces can't be toppled to the right, only the left (because when the gravity times out, the piece on the left has gone, so it doesn't go anywhere. falling on the right changes the processing order)
	consider restarting the clear timer all the way down the chain, not just our neighbor
	lose condition
	randomizer/previews/hold
	ghost piece
	ui with score, time, moves, etc
	controller support
	main menu