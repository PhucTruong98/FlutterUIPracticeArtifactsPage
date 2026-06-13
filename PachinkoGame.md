I am building a Flutter app called Geodyssey. I need you to implement Version 1 of a Pachinko-style mini game using Flame Engine and Forge2D.

## Technical Requirements

* Flutter
* Flame
* flame_forge2d
* Follow clean, maintainable code structure
* Separate game logic from Flutter UI where appropriate
* Create all necessary classes, widgets, and game components
* Include comments explaining major systems

## Game Concept

The player feeds treats to a puppy.

The Pachinko board contains stationary pegs.

A dog treat acts as the Pachinko ball.

The treat falls through the board, bouncing off pegs and accumulating points.

The puppy sits at the bottom and catches the treat.

The number of peg collisions determines the reward.

## Version 1 Gameplay Flow

### Initial State

When the screen opens:

* Player starts with 5 dog treats
* Treat inventory displayed at top of screen
* Energy gauge displayed near puppy
* Score display initialized to 0

### Load Treat

There is a button labeled:

"Load Treat"

When pressed:

* One treat is consumed from inventory
* A treat appears in the launch position
* Launch position is centered near the top of the Pachinko board
* Only one treat may be loaded at a time
* If inventory is zero, disable the button

After loading:

Display a message:

"Tap to Drop"

### Drop Treat

When the player taps the loaded treat:

* Release the treat into the physics simulation
* Gravity should be handled by Forge2D
* Treat should behave as a dynamic physics body
* Treat should collide naturally with pegs and board boundaries

### Peg Behavior

Pegs are stationary physics bodies.

When the treat collides with a peg:

* Treat bounces according to physics simulation
* Add 50 points
* Increment collision count
* Optional visual feedback:

  * small sparkle effect
  * floating "+50"

### Board Layout

Create a classic Pachinko layout:

* Multiple rows of pegs
* Staggered peg arrangement
* Side walls prevent treat from leaving board
* Treat should realistically bounce through the board

### Puppy Catch Zone

At the bottom of the board:

* Place a puppy graphic or placeholder widget
* Create a catch area above the puppy

When the treat reaches the puppy:

* End the current round
* Freeze or remove the treat
* Display total points earned

Example:

"Treat Collected! 850 Points"

## Energy System

Create an energy gauge below the puppy.

Energy increases based on points earned.

Formula for Version 1:

energyGain = totalPoints

Example:

* 10 peg hits = 500 points
* puppy gains 500 energy

Animate the gauge filling.

Display:

Current Energy
Maximum Energy
Percentage Filled

## UI Layout

Top Section:

* Treat inventory
* Current loaded treat status

Middle Section:

* Pachinko board
* Physics simulation

Bottom Section:

* Puppy
* Energy gauge
* Round result text

## Physics Requirements

Use Forge2D physics.

Treat:

* Dynamic body
* Circular collider
* Realistic restitution
* Realistic friction

Pegs:

* Static bodies
* Circular colliders

Walls:

* Static bodies

Gravity:

* Natural downward movement

Avoid scripted movement.
The outcome should be determined entirely by physics.

## State Requirements

Track:

* Remaining treats
* Loaded treat state
* Current round score
* Total puppy energy
* Peg collision count

## Deliverables

Provide:

1. Complete file structure
2. Flame game implementation
3. Forge2D bodies and components
4. Flutter screen integration
5. State management approach
6. Full source code

Implement a working Version 1 that can be run immediately inside a Flutter project.
