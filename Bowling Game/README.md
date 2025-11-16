Bowling Game Documentation
Student Name: Daksh Jariwala
Course: Game Programming
Project: Unity 2D Bowling Game

Project Overview
This is a 2D bowling game created in Unity where players can throw a ball to knock down pins. The game includes realistic physics, proper bowling scoring, visual feedback, and sound effects.

Game Features
•	Mouse-controlled throwing - Click and drag to aim and throw the ball
•	10 frames with 2 rolls each - Standard bowling rules
•	Strike and Spare detection - Popup messages when achieved
•	Score tracking - Real-time score display
•	Visual aim line - Shows where you're throwing
•	Power meter - Shows how hard you're throwing
•	Sound effects - Ball rolling and pin collision sounds
•	Restart button - Replay the game anytime

How to Play
1.	Click on the ball and drag your mouse to aim
2.	The further you drag, the more power (watch the power meter at bottom)
3.	Release to throw the ball
4.	Try to knock down all 10 pins
5.	Score is displayed at top-left, frame/roll at top-right
6.	Click "Restart Game" button to play again

Technical Implementation
Collision Detection
The game uses Unity's 2D Physics system for collision detection:
•	Rigidbody2D components on the ball and pins for physics
•	Circle Collider 2D on the ball
•	Capsule Collider 2D on the pins
•	OnCollisionEnter2D() function detects when objects collide
When the ball hits a pin or pins hit each other, the collision is detected, and torque is applied to make pins tip over realistically.
Main Scripts
1. BallController.cs
•	Handles mouse input for aiming and throwing
•	Shows aim line and power meter while dragging
•	Calculates throw direction and power based on drag distance
•	Applies force to the ball when released
•	Resets ball position after each throw
2. PinBehavior.cs
•	Detects collisions between ball and pins
•	Applies torque (rotation force) to make pins tip over
•	Plays sound effect when hit
•	Adjusts pin center of mass for realistic physics
3. GameManager.cs
•	Manages game state (current frame, current roll, total score)
•	Counts how many pins are knocked down after each throw
•	Detects if pin is knocked down by checking rotation angle
•	Implements bowling rules (strikes, spares)
•	Hides knocked pins after first roll
•	Resets all pins for next frame
•	Updates UI text (score and frame counter)
4. StrikeSparePopup.cs
•	Shows "STRIKE!" or "SPARE!" popup messages
•	Animates the text (grows, then fades out)
•	Uses coroutines for smooth animation
5. SoundManager.cs
•	Manages all game sounds
•	Plays ball rolling sound when ball moves
•	Plays pin crash sound on collision
•	Plays celebration sounds for strikes/spares
6. RestartGame.cs
•	Reloads the game scene when restart button is clicked

Programming Concepts Used
1.	Physics System - Rigidbody2D, forces, torque, collisions
2.	Collision Detection - OnCollisionEnter2D events
3.	User Input - Mouse position tracking and click detection
4.	Game State Management - Tracking frames, rolls, and score
5.	UI System - TextMeshPro for text, Sliders for power meter, Buttons
6.	Coroutines - For animations and timed events
7.	Singleton Pattern - GameManager and SoundManager for global access





Challenges and Solutions
Challenge 1: Pins were too easy to knock over
•	Solution: Increased pin mass, added physics materials with friction, adjusted drag values
Challenge 2: Pin detection wasn't accurate
•	Solution: Check if pin rotation is tilted more than 30 degrees to determine if knocked down
Challenge 3: Score counting wrong on second roll
•	Solution: Hide knocked pins after first roll, track first roll count separately, calculate difference for second roll
Challenge 4: Aim line appearing behind lane
•	Solution: Adjusted LineRenderer "Order in Layer" to higher value to appear on top

Code Quality
•	Clear variable names (e.g., pinsKnockedDown, currentFrame)
•	Comments explaining important sections
•	Organized into separate scripts by function
•	Null checks to prevent errors
•	Modular design - each script has specific purpose

Assets Used
•	Scripts: All written from scratch
•	Graphics: Unity built-in sprite shapes (circles, capsules, squares)
•	Sounds: Free sound effects from Freesound.org 

Conclusion
This bowling game demonstrates understanding of Unity 2D physics, collision detection, game state management, and user interface design. The game is fully playable with proper bowling rules, visual feedback, and audio support.
Game Screenshots

 
 
