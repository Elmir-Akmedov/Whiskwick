# 🍰 Whiskwick — Codex Desktop Build Prompts
> Cozy Food Shop Tycoon | Godot 4 + GDScript | Solo Dev Roadmap

---

## 🗂 HOW TO USE THIS FILE
- Work through milestones in order
- Paste each prompt directly into Codex Desktop
- Complete and test before moving to the next
- Add notes under each prompt as you go

---

## ✅ MILESTONE 1 — Project Setup & Scene Structure

### Prompt 1.1 — Project Skeleton
Create a Godot 4 project called "Whiskwick". Set up the following scene structure:

Main.tscn (root scene, controls scene switching)
ShopFloor.tscn (main gameplay scene)
MarketScreen.tscn (buy ingredients)
UpgradeScreen.tscn (buy upgrades)
MenuScreen.tscn (manage dish menu)
DaySummaryScreen.tscn (end of day results)
Each scene should have a root Node2D with a placeholder Label showing its name. Main.tscn should have buttons to switch between all scenes for testing. Use GDScript only. No C#.


### Prompt 1.2 — Autoload Singletons
In Godot 4 GDScript, create the following Autoload singleton scripts:

GameState.gd — holds global game variables: coins (int), xp (int), shop_level (int), reputation (float 0.0-5.0), current_day (int)
SaveManager.gd — handles save/load using JSON to "user://save.json". Functions: save_game(), load_game(). Save all GameState variables.
UIManager.gd — stub file, will handle showing/hiding popups later
Register all three in Project Settings > Autoload. Add a test function to SaveManager that prints "Save successful" and "Load successful".


---

## ✅ MILESTONE 2 — Core Data: Ingredients, Recipes & Inventory

### Prompt 2.1 — InventoryManager
Create InventoryManager.gd as a Godot 4 Autoload singleton. It should manage a dictionary of ingredients: { "flour": 10, "butter": 5, "sugar": 8 } Functions needed:

add_ingredient(name: String, amount: int)
remove_ingredient(name: String, amount: int) → returns false if not enough stock
get_stock(name: String) → int
is_low_stock(name: String, threshold: int) → bool
get_all_ingredients() → Dictionary
Print a warning in the Godot console when any ingredient drops below threshold (default: 2).


### Prompt 2.2 — RecipeManager
Create RecipeManager.gd as a Godot 4 Autoload singleton. Define 5 starter recipes as a dictionary. Each recipe has:

name: String
ingredients: Dictionary (e.g. {"flour": 2, "butter": 1})
prep_time: float (seconds)
base_price: int (coins)
unlocked: bool
Starter recipes: Butter Cookie, Cinnamon Roll, Cream Puff, Honey Cake, Berry Tart. Functions:

get_unlocked_recipes() → Array
unlock_recipe(name: String)
can_make(name: String) → bool (checks InventoryManager stock)
get_recipe(name: String) → Dictionary

### Prompt 2.3 — Menu Management
Create MenuManager.gd as a Godot 4 Autoload singleton. It controls which recipes are currently active on the shop menu (max 4 active at once). Functions:

set_active(recipe_name: String, active: bool)
get_active_menu() → Array of recipe names
set_price(recipe_name: String, price: int)
get_price(recipe_name: String) → int
Prices default to the recipe's base_price from RecipeManager. Active menu should persist to SaveManager (add menu state to save data).


---

## ✅ MILESTONE 3 — Customer System

### Prompt 3.1 — Customer Data & Patience
Create Customer.gd as a Godot 4 Node2D script (not Autoload). Each customer has:

customer_name: String (randomly picked from a list of 10 cozy names)
order: String (random item from MenuManager's active menu)
patience: float = 30.0 (seconds)
tip_amount: int = 0
is_served: bool = false
Functions:

_process(delta): count down patience timer
serve(dish_name: String): if dish matches order, mark served, calculate tip based on remaining patience
leave(): called when patience hits 0, emit signal "customer_left_unhappy"
get_satisfaction() → float: returns 0.0-1.0 based on remaining patience when served
Emit signals: "customer_served", "customer_left_unhappy"


### Prompt 3.2 — CustomerManager (Spawner)
Create CustomerManager.gd as a Godot 4 Autoload singleton. It spawns customers during an active shop day. Variables:

max_customers_at_once: int = 3
spawn_interval: float = 15.0 (seconds between new customers)
active_customers: Array
Functions:

start_day(): begin spawning customers, reset daily stats
end_day(): stop spawning, return daily stats dict (total_served, total_coins, avg_satisfaction)
spawn_customer(): instance Customer scene, add to active_customers
on_customer_served(customer): update daily stats, remove from active list
on_customer_left(customer): update unhappy count, remove from active list
Use a Timer node for spawn_interval. Spawn rate should increase slightly with shop_level from GameState.


---

## ✅ MILESTONE 4 — Shop Floor Scene (Active Gameplay)

### Prompt 4.1 — ShopFloor UI
Build the ShopFloor.tscn scene in Godot 4. UI layout (for mobile, portrait orientation):

Top bar: coins label, XP label, reputation stars (1-5), day number
Middle area: customer queue (3 slots showing customer name + order + patience bar)
Bottom area: dish buttons (one button per active menu item, shows name + prep time)
Side button: "End Day" button
When a dish button is tapped:

Check if ingredients are available (RecipeManager.can_make)
Deduct ingredients
After prep_time seconds (use a Timer), serve the first waiting customer whose order matches
Add coins to GameState
Wire all labels to GameState values. Refresh UI after every action. Use GDScript. Portrait mobile layout using Control nodes and anchors.


### Prompt 4.2 — Day Flow
In Godot 4 GDScript, implement the full day flow for ShopFloor.tscn:

On scene load: call CustomerManager.start_day(), show "Shop is Open!" popup for 2 seconds
During day: customers spawn, player taps dish buttons to serve them
"End Day" button: call CustomerManager.end_day(), disable all buttons, transition to DaySummaryScreen after 1 second
Pass daily stats (coins earned, customers served, satisfaction avg) to DaySummaryScreen via a global variable in GameState
Handle edge cases:

No active menu items → show warning "Add items to your menu first!"
No ingredients → grey out dish buttons automatically

---

## ✅ MILESTONE 5 — Day Summary Screen

### Prompt 5.1 — DaySummaryScreen
Build DaySummaryScreen.tscn in Godot 4. Display end-of-day results:

"Day X Complete!" heading
Coins earned today
Customers served vs total who visited
Average satisfaction (shown as emoji: 😊 great / 😐 ok / 😞 bad)
Reputation change (+0.1 for great day, -0.1 for bad day) with animation
XP gained (10 XP per customer served)
Total coins (updated GameState.coins)
Two buttons: "Go to Market" → MarketScreen, "Upgrade Shop" → UpgradeScreen
On load: read stats from GameState.daily_stats, update GameState.coins, GameState.xp, GameState.reputation. Check if player leveled up (every 100 XP), show "Level Up!" popup if so. Auto-save via SaveManager.save_game() on load.


---

## ✅ MILESTONE 6 — Market Screen

### Prompt 6.1 — MarketScreen
Build MarketScreen.tscn in Godot 4. Show a shop grid of ingredients to buy:

Flour (5 coins / unit)
Butter (8 coins / unit)
Sugar (6 coins / unit)
Eggs (4 coins / unit)
Cream (10 coins / unit)
Honey (12 coins / unit)
Berries (9 coins / unit)
Cinnamon (7 coins / unit)
Each item card shows: ingredient name, current stock (from InventoryManager), price, +/- quantity selector, "Buy" button. Top of screen: current coins display. "Buy" button: deduct coins, call InventoryManager.add_ingredient(), refresh UI. Highlight ingredients that are low stock (below 2) in orange. Back button returns to Main scene.


---

## ✅ MILESTONE 7 — Upgrade Screen

### Prompt 7.1 — UpgradeManager
Create UpgradeManager.gd as a Godot 4 Autoload singleton. Define these upgrades:

"Better Oven" → reduces all prep times by 20% (cost: 100 coins)
"Cozy Decor" → increases reputation gain by 0.05 per day (cost: 80 coins)
"Extra Staff" → enables idle earning (cost: 150 coins)
"Larger Kitchen" → increases max active menu items from 4 to 6 (cost: 120 coins)
"Speed Training" → increases customer patience by +10 seconds (cost: 90 coins)
Each upgrade: name, description, cost, purchased: bool, effect applied via function. Functions:

get_available_upgrades() → Array (unpurchased only)
purchase(name: String) → bool (deduct coins, apply effect, return success)
apply_all_effects(): called on game load to re-apply purchased upgrades

### Prompt 7.2 — UpgradeScreen UI
Build UpgradeScreen.tscn in Godot 4. Show all available upgrades as cards:

Upgrade name + description
Cost in coins
"Buy" button (greyed out if not enough coins)
Already purchased upgrades show a ✓ checkmark
Wire to UpgradeManager. On buy: call UpgradeManager.purchase(), refresh UI, update coin display. Back button returns to Main.


---

## ✅ MILESTONE 8 — Idle System

### Prompt 8.1 — Idle Earnings
In Godot 4 GDScript, implement idle earnings in SaveManager.gd. When load_game() is called:

Read the timestamp of last save (store as Unix timestamp)
Calculate time elapsed since last save in seconds
If "Extra Staff" upgrade is purchased (check UpgradeManager):
Calculate idle_coins = floor(elapsed_seconds / 60) * idle_rate
idle_rate = shop_level * 2 coins per minute
Cap at 60 minutes worth of earnings maximum
Add idle_coins to GameState.coins
Show a popup: "You were away for X minutes! Earned Y coins while you slept 💤"
Save current timestamp on every save_game() call.


---

## ✅ MILESTONE 9 — Menu Management Screen

### Prompt 9.1 — MenuScreen UI
Build MenuScreen.tscn in Godot 4. Show all unlocked recipes in a scrollable list. Each recipe card:

Dish name
Ingredients required (listed)
Prep time
Current price (editable with +/- buttons, min = base_price, max = base_price * 3)
Toggle button: "On Menu" / "Off Menu" (max 4 active unless "Larger Kitchen" upgrade)
Wire to RecipeManager and MenuManager. Show a "locked" section below for locked recipes with: name, "Unlocks at Level X" label. Back button returns to Main.


---

## ✅ MILESTONE 10 — Polish & Feel

### Prompt 10.1 — Juice & Feedback
Add the following visual and audio feedback to Whiskwick in Godot 4:

Coin earn animation: a "+X coins" label floats up and fades when coins are earned
Customer patience bar: color changes green → yellow → red as patience decreases
"Level Up!" popup: animated scale tween, stays for 2 seconds, then disappears
Dish button press: slight scale bounce animation (scale to 1.1 then back to 1.0)
End of day: coins counter animates counting up to new total over 1 second
Use Tween nodes in GDScript for all animations. No external plugins. Keep all animation durations short (0.2-0.5s) for a snappy, cozy feel.


### Prompt 10.2 — Save & Resume
Polish the save/load system in Godot 4.

Auto-save every time: day ends, upgrade is bought, market purchase is made
On game launch: auto-load if save file exists, skip to ShopFloor. If no save, start new game flow.
New game flow: show a Name Your Shop screen (simple TextEdit + "Start!" button), save shop name to GameState.shop_name, then go to ShopFloor.
Add a Settings button on Main that shows: "Reset Save" (with confirmation dialog), current version label.

---

## ✅ MILESTONE 11 — Android Export

### Prompt 11.1 — Mobile Readiness
Review and adapt all Whiskwick scenes for Android mobile export in Godot 4:

All touch targets (buttons) should be minimum 80x80 pixels
All scenes use portrait orientation (1080x1920 or similar 9:16 ratio)
Replace any keyboard input with on-screen controls
Set project viewport to stretch mode: canvas_items, aspect: keep
Add a back button handler on Android (connect to go back one screen)
Test that all font sizes are readable on a small screen (min 20px)
List any scenes or scripts that need changes and apply them.


---

## 🔮 FUTURE MILESTONE — Multiplayer Prep

### Prompt F.1 — Multiplayer Architecture Prep
Review the current Whiskwick GDScript codebase and refactor for future multiplayer readiness. Goals (no actual networking yet):

All game state should live in GameState.gd (no logic hidden in scene scripts)
All player actions should go through a single PlayerActions.gd script (buy ingredient, serve dish, purchase upgrade) — scenes call PlayerActions, which updates GameState
Replace all direct scene-to-scene variable passing with GameState signals
Document every function that would need to become an RPC call in multiplayer with a comment: # FUTURE_MULTIPLAYER: convert to rpc()
This refactor should not change any visible gameplay behavior.


---

## 📋 QUICK REFERENCE — Singleton Map

| Singleton | File | Purpose |
|---|---|---|
| GameState | GameState.gd | Global variables, day stats |
| SaveManager | SaveManager.gd | Save/load JSON, idle time |
| InventoryManager | InventoryManager.gd | Ingredient stock |
| RecipeManager | RecipeManager.gd | Recipes, unlock logic |
| MenuManager | MenuManager.gd | Active menu, pricing |
| CustomerManager | CustomerManager.gd | Spawn, track customers |
| UpgradeManager | UpgradeManager.gd | Upgrades, effects |
| UIManager | UIManager.gd | Popups, notifications |

---

## 🐛 DEBUG PROMPTS (Use anytime)

My Godot 4 GDScript code has this error: [PASTE ERROR HERE] The error is in [FILE NAME]. Here is the relevant code: [PASTE CODE] Fix the error and explain what caused it.

Review this GDScript file for Whiskwick and suggest improvements for readability and performance. Do not change functionality: [PASTE CODE]

I implemented [FEATURE] but it's not working as expected. Expected behavior: [DESCRIBE]. Actual behavior: [DESCRIBE]. Here is the code: [PASTE CODE]. Find the bug and fix it.

Save this as WHISKWICK_CODEX_PROMPTS.md in your project root — you're ready to build! 🎉