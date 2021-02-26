# tri-twist
Triangle puzzle game
basic mechanics:
board of tesselated equilateral triangles with flat bottom and sides sloped 30 degrees outward (or inward?)
Triangles have 3 places that can be 1 of 2 colors: have to make enclosed areas, like carcassone
4 possible pieces (all A, all B, 1A 2B, 2A 1B), 8 if you count rotations
move that would be banned in carcassone, open edge facing an open edge of the opposite color, is allowed but doesn't count as closing
when an area is closed, it scores and all triangles involved disappear; pieces on top fall down piece by piece row by row left to right and bottom to top following piece falling rules below
modes:
	drop pieces in from above; if they land on:
		a flat surface, they don't move
		a sloped surface, they rotate and slide down
		a double slope canyon, they flip
		no rotate allowed, only drop
		game ends on top out or turn limit or time limit
	board is already full and you cursor around and rotate pieces
		rotating a piece also rotates its three neighbors
		popped pieces are not replaced, game ends when no moves left
		alternate idea: pieces are dropping in as you play, don't top out? in multiplayer, clears send lots of pieces? can bump falling stuff?
	mode with both types of piece movement; free/forced switch
	multiple multiplayer ideas
		one board versus, p1 and p2 each have "their color"
		seperate boards versus, play for quota or top out (garbage sends third color?)
		same board coop, one player drops and the other rotates
			simul play; bump a sliding piece this way?

other stuff:
2 cute characters, one for each color or one for drop/twist
color choices, like splatoon

issues:
	if a single color piece is bordered by a wall or an opposite color piece, it is unclearable forever
