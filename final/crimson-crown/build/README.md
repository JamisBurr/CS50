# Crimson Crown

#### Video Demo: https://youtu.be/sRdBhS1YQsk

#### Description: 

###### INTRODUCTION,

Crimson Crown is a straightforward and engaging pixel-art sidescroller. It combines exploration, combat, platforming, and a compelling story, topped off with challenging boss battles. This game offers a direct, classic gaming experience with a modern twist.

###### PLAYER EXPERIENCE,

Dive into a sidescrolling dungeon adventure across three levels, leading up to a challenging boss encounter. Players will navigate through enemy confrontations, acquiring and utilizing new skills to advance. The game includes engaging jumping puzzles that require thoughtful problem-solving. A unique feature is the speed run timer, which records your fastest times, adding a competitive edge to the gameplay.

Exploration is key in this game, with a need for strategic backtracking to uncover the correct paths through the castle's intricate layout. This experience offers a balanced mix of action, strategy, and exploration, ensuring an engaging and satisfying playthrough for gamers.

###### GENRE,

Crimson Crown is categorized as a single-player, platformer, and side-scrolling game with Metroidvania elements.

###### GAMEPLAY OVERVIEW,

Crimson Crown merges classic side-scrolling action with innovative gameplay mechanics. Players take on the role of a lone warrior navigating a mysterious castle. Each level introduces new challenges and puzzles, blending platforming and strategic combat.  The core gameplay of Crimson Crown involves exploration, combat, and puzzle-solving within a pixel-art sidescrolling environment. Players will encounter a variety of enemies and obstacles, requiring both quick reflexes and careful strategy. The game includes hidden areas and special items that reward thorough exploration and creative problem-solving. A total game time counter is present for speed run enthusiasts.

###### FILES,

1. buttons.lua
Purpose: This file contains code related to the creation, management, and functionality of buttons in the game's user interface. It handles different types of buttons (e.g., menu buttons, in-game action buttons) and their behaviors (e.g., click events, hover effects).

Gameplay Design and Programming Methods: From a design perspective, this file is essential for user interaction, enabling players to navigate menus and interact with the game's features. In terms of programming, it uses object-oriented practices to define button classes, event listeners for user actions, and animations and or transitions for button states (normal, hovered, pressed).

2. camera.lua
Purpose: This file is responsible for the camera system in the game, handling how the camera views and follows the game action. It includes functions for camera movement, zoom, and focus on specific game elements or characters.

Gameplay Design and Programming Methods: The camera is a critical component in providing a good player experience, influencing how players perceive and interact with the game world. The programming approach involves mathematical calculations for smooth camera movements, tracking player or object positions, and adjusting the camera view accordingly.

3. destroy.lua
Purpose: This file deals with the destruction or removal of game objects. It includes functions to delete or deactivate objects, clear memory, or handle the game's cleanup processes.

Gameplay Design and Programming Methods: In gameplay design, efficient destruction of objects is important for memory management and performance. Programming-wise, this file uses methods to safely remove objects without causing memory leaks, and it could be closely integrated with the game's physics or collision systems.

4. main.lua
Purpose: main.lua is the entry point of a Lua-based game. It initializes the game, sets up the main game loop, and manages the transition between different states or screens (like the menu, gameplay, pause screen).

Gameplay Design and Programming Methods: This file is central to the game's structure. The programming here involves initializing various subsystems (like graphics, audio), managing game states, and updating and rendering the game loop. It's where the game's heartbeat is maintained.

5. other.lua
Purpose: other.lua is a miscellaneous file containing various utility functions, global variables, or secondary features not directly fitting into other modules.  Mostly NPC's.

Gameplay Design and Programming Methods: The contents range from helper functions (like mathematical operations, string manipulations) to specific game features (like achievements, special effects). The programming approach could vary widely based on its contents.

6. player.lua
Purpose: This file is dedicated to the player's character, including its properties (like health, inventory), behaviors (movement, actions), and interactions with the game world.

Gameplay Design and Programming Methods: From a design perspective, it’s crucial for character control and progression. Programming methods involves physics for movement, collision detection, and an event-driven approach for actions like jumping or attacking.

7. saveManager.lua
Purpose: This file handles game data saving and loading. It includes functions to store player progress, game settings, and possibly other persistent data.

Gameplay Design and Programming Methods: Saving and loading are key for player convenience and game continuity.

8. settings.lua
Purpose: This manages game settings such as graphics, sound levels, and control configurations. This file contains functions to adjust these settings and save user preferences.

Gameplay Design and Programming Methods: User customization is a core aspect of this file. The programming approach includes creating a user interface for settings, storing user preferences, and applying these settings throughout the game.

10. world.lua
Purpose: This file is made to deal with the game world's environment, including the layout, background elements, and level design. It includes functions for creating, modifying, and interacting with the game world.

Gameplay Design and Programming Methods: The world design is crucial for the game's setting and atmosphere. The programming in this file includes spatial calculations, environmental interactions, and more.

11. ghoul.lua
Purpose: This file handles the behavior, attributes, and mechanics of a 'ghoul' character or entity in the game. It includes code for the ghoul's movement, attacks, health, and interactions with the player or environment.

Gameplay Design and Programming Methods: Design-wise, the ghoul character is a challenge or obstacle for the player. Programming methods include AI routines for movement and attack patterns, collision detection, and state management (like idle, chasing, attacking).

12. projectile.lua
Purpose: This file manages projectiles in the game, such as bullets. It includes functions for their creation, movement, collision handling, and effects upon hitting targets.

Gameplay Design and Programming Methods: Projectiles are a key element in action and combat mechanics. Programming-wise, this file uses physics for trajectory calculations, collision detection, and handling the impact effects on targets.

13. spitter.lua
Purpose: This file is dedicated to a 'spitter' type enemy or character, known for attacking by spitting projectiles or substances. It includes the logic for its behavior, attack patterns, and interactions within the game.

Gameplay Design and Programming Methods: In terms of design, the spitter adds variety to the game's challenges. Programming methods include AI routines for targeting, timing of attacks, and handling the spit projectiles (linking to projectile.lua).

14. summoner.lua
Purpose: This file deals with a 'summoner' type character or entity, capable of summoning other characters or objects. It includes code for summoning mechanics, managing summoned entities, and the summoner's own behavior.

Gameplay Design and Programming Methods: Summoners add strategic depth to gameplay. Programming involves managing multiple entities, timers for summoning, and AI routines for when and what to summon.

15. shop.lua
Purpose: This file is to handle the game's shop system, where players can buy or sell items. It is built to include code for displaying items, handling transactions, and possibly inventory management.

Gameplay Design and Programming Methods: The shop is a key element in many games for upgrading or customizing the player's abilities. The programming involves UI design for the shop, and integrating with the player's ability system.

16. watcher.lua
Purpose: The 'watcher' file pertains to an NPC entity. This include enemy AI that interacts with the player, and a system that triggers events based on player save states.

Gameplay Design and Programming Methods: Watchers create a dynamic and responsive game environment. The programming could involve AI routines for detection and reaction, and event-driven programming to trigger specific game events.