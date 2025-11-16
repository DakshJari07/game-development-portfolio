Pinball Game Documentation
Student Name: Daksh Jariwala
Course: 4478 - Game Programming 
Date: November 10, 2025

Game Overview
A 2D pinball game where players use flippers to hit a ball, score points by hitting bumpers and target lanes, and try to keep the ball in play for as long as possible.
How to Play
Controls:
•	Spacebar - Launch ball
•	A - Left flipper
•	D - Right flipper
•	R - Restart (after game over)
Gameplay:
•	Launch the ball with Spacebar
•	Use flippers to keep ball in play
•	Hit bumpers (100-200 points) and target lanes (50-100 points)
•	You have 3 balls - game over when all are lost
Features
•	Flipper controls (A and D keys)
•	Ball launcher system
•	3 balls per game
•	Score tracking system
•	Lives counter
•	Game over screen with restart
•	Multiple obstacles (bumpers, target lanes, slingshots)
•	Physics-based gameplay

Technical Implementation
Collision Detection 
The game uses Unity's 2D Physics system for all collision detection:
Components Used:
•	Rigidbody2D - Adds physics to ball and flippers
•	Circle Collider 2D - For ball and bumpers
•	Box Collider 2D - For flippers, walls, lanes
•	Polygon Collider 2D - For triangular slingshots
Collision Methods:
1.	Physical Collisions (OnCollisionEnter2D) 
o	Used for ball hitting bumpers, flippers, and walls
o	Objects physically bounce off each other
o	Example: When ball hits bumper, it bounces away and adds score
2.	Trigger Collisions (OnTriggerEnter2D) 
o	Used for target lanes
o	Ball passes through without bouncing
o	Still detects entry and awards points
How It Works:
Bumper collision example:
 
Target lane example:
 
Main Scripts
BallController.cs
•	Launches ball when Spacebar pressed
•	Detects when ball falls off table
•	Tells GameManager when ball is lost
•	Resets ball for next attempt
FlipperController.cs
•	Rotates flippers when A or D pressed
•	Adds extra force to ball on collision
•	Makes flippers respond to player input
GameManager.cs
•	Tracks balls remaining (starts at 3)
•	Handles game over when no balls left
•	Shows game over screen
•	Manages restart functionality



ScoreManager.cs
•	Tracks current score
•	Updates score UI when points are earned
•	Called by bumpers and lanes when hit
Bumper.cs
•	Detects ball collision
•	Awards points
•	Bounces ball away
•	Flashes color when hit
TargetLane.cs
•	Detects ball passing through
•	Awards points
•	Flashes to show activation
Programming Concepts
•	Collision Detection - OnCollisionEnter2D and OnTriggerEnter2D
•	Physics - Forces, velocity, gravity control
•	Input Handling - Keyboard input detection
•	UI System - Score display, balls remaining, game over screen
•	Game State - Tracking balls, score, game flow
•	Coroutines - Visual flash effects
•	Singleton Pattern - GameManager and ScoreManager global access
Challenges Solved
1.	Ball flying off screen - Added speed limiting
2.	Flippers too weak - Increased mass and added extra force
3.	Ball count going negative - Added flag to prevent multiple calls
4.	Game over text not visible - Created full-screen overlay panel
5.	Target lanes blocking ball - Changed to trigger colliders
Conclusion
This pinball game demonstrates understanding of Unity 2D development, physics-based collision detection, game state management, and UI systems. The game is fully playable with proper pinball mechanics and scoring.
 
