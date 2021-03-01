# tri-twist
ruleset tweaks:
	can clear against an edge
	piece could roll off a double-balanced piece
	grid size
	square*
	# of colors
	piece randomizer weights/special cases (no full triangles in the first 2 moves)
	restrict how quickly you can drop/DAS/ARR/hard drop
	gravity speed
	control piece as it falls, allowing overhangs and tucks
	# previews
	don't want to make areas but instead just match edges of the same color (more focus on making chains)
	different kinds of board shakeup (rotate, mass delete)
	rotate before dropping* (often possible with tumbling already)
	different ways to handle unclearable pieces:
		just keep it as a lose/win condition
		detect and clear immediately or change piece type: award points
		board shake as a limited resource (mass delete one color maybe)
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
		tucks give points
multiplayer
	one board versus, p1 and p2 each have "their color"
		they either want to clear more of theirs or have more unclearable colors of theirs
	seperate boards versus, play for quota or top out (garbage sends pieces with third color?)
	same board coop/versus, one player drops and the other rotates

other stuff:
2 cute characters, one for each color or one for drop/twist (3rd for squares?)
color choices, like splatoon

One path I see is to focus on the tumbling and make everything else as easy as possible (except maybe might keep out initial rotate, which you can get around with big slopes and it might be fun to do so, idk)
	ghost piece helps
	no clears on falling pieces since it's hard enough to plan already
	don't expect anyone to plan ahead after a big clear: it's just gonna jumble the pieces and that's okay
	solid color triangles are either the lose condition or extremely generous, with some other lose condition
	one problem I see with this is it's impossible to dig sometimes: need to be able to shake the board
	piece randomizer can really kick your butt; can look to previews/hold/tetris randomizers

todo next:
	edge clear rule
	no clears while falling
	gravity timer problems
		a piece that is just spawned in should skip a gravity cycle if it comes too soon after dropping in (like less than half the wait time)
		non-global gravity timer start when the piece is dropped or when a clear happens, and then stop after (but then they won't be synchronized)
		disallow dropping until the piece has dropped all the way and all clears have settled)
	ghost piece
	squares
	ui with score, time, moves, etc
	controller support
	main menu
	experiment with rulesets
