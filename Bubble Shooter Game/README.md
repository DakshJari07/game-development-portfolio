Bubble Shooter Game - Documentation

•	PROGRAMMING
The code is split into 2 main files:
-Main.hx sets up the game window (800x600 pixels) and starts everything running.
-PlayState.hx is where most of the action happens - it handles the bubble grid, detects when you shoot bubbles, checks for matches, and manages the game state.
The Bubble class represents each individual bubble. It draws the circular graphics and checks if it's hitting other bubbles while flying.
The Shooter class is the cannon at the bottom. It has a base and a barrel that rotates to follow your mouse.
For the grid layout, I used a hexagonal pattern because that's how real bubble shooters work. The bubbles are arranged in a 15x20 grid, but every other row is offset by half a bubble width, so they fit together nicely. The math for positioning looks like:
x position = 175 + (column * 32) + ((row is odd? 16 : 0))
y position = 50 + (row * 24)
To find matching bubbles, I used a flood fill algorithm. It starts at one bubble and spreads out to all connected bubbles of the same color:
function floodFill(x, y, color, matches, visited) {
    if we've been here before or wrong color, stop
    mark this spot as visited
    add this bubble to matches
    check all 6 neighbors and repeat
}
After clearing matches, there might be bubbles floating in the air with nothing holding them up. I wrote code that marks every bubble connected to the top row, then deletes anything that's not marked.




•	PHYSICS & COLLISION DETECTION
When you shoot a bubble, it flies in the direction you aimed based on the angle: horizontal speed = cos(angle) * 400 vertical speed = sin(angle) * 400
If the bubble hits a wall, it bounces by flipping the horizontal speed to negative.
For collision detection, I calculate the distance between the flying bubble and every other bubble on screen. If the distance is less than 28 pixels, they're touching and the bubble stops. The formula is:
distance = square root of ((x1-x2)² + (y1-y2)²)
Once a collision happens, the code finds the closest empty spot on the grid where the bubble can snap into place. It only picks spots that have at least one neighbor already there (or are on the top row), otherwise bubbles would just stick anywhere randomly.
I had issues with bubbles leaving gaps at first. Turned out I was using different formulas for positioning in different parts of the code. Once I made sure the same calculation was used everywhere, the gaps went away.

•	SCORING & GAME MECHANICS
The matching system only clears groups of 3 or more bubbles - pairs don't count. When you place a bubble, the flood fill checks all touching bubbles of that color. If there are at least 3 total, they all get deleted.
To keep the game from going on forever, I added a difficulty system. Every 5 shots, all the bubbles drop down one row, and a new random row appears at the top. This slowly increases the pressure.
You win if you clear every bubble. You lose if any bubble reaches the bottom row.
For visuals, I added some polish:
•	Background fades from dark blue at top to lighter blue at bottom
•	Bubbles have a gradient and shine effect to look 3D
•	The cannon is metallic looking with a barrel that rotates
•	The aiming line pulses slightly





•	PROBLEMS I RAN INTO
Making circular bubbles was harder than I thought. At first, they were just colored squares. I had to manually draw each pixel by calculating if it was inside a circle (using the distance from center). Then I added gradients and a highlight to make them look round.
Getting the hexagonal grid right took some trial and error. Regular grid layouts leave weird gaps, so I had to offset every other row by exactly half a bubble. The vertical spacing also needed to be 0.75x the bubble size instead of 1x.
The cannon wasn't aiming properly at first because I was rotating the whole thing. I split it into two sprites - a fixed base and a rotating barrel - which fixed the problem.
Finding valid grid positions for shot bubbles was tricky. If the search radius was too small, it would fail to find spots. If it was too big, bubbles would snap to weird locations. I settled on 1.5x the bubble size which works well.

•	CONCLUSION
The game works pretty well now. The hexagonal grid makes bubbles line up like they should, the flood fill algorithm finds matches efficiently, and the collision detection feels responsive. The progressive difficulty prevents games from lasting forever, and the visual effects make it look more polished than just colored circles.
Overall, this project taught me a lot about grid systems, recursive algorithms, and collision detection in game development.

