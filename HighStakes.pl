% Dynamic predicates to track game state 
:- dynamic(at/2).         % at(Object, Location) 
:- dynamic(has/2).        % has(Person, Object) 
:- dynamic(alive/1).     % alive(Person) 
:- dynamic(money/2).      % money(Player, Amount) 
:- dynamic(bet_placed/3). % bet_placed(Game, Amount, Outcome) 
:- dynamic(visited/1).    % visited(Location) 
:- dynamic(game_state/1). % game_state(State) 

% Initial game state 
:- initialization(init_game).

init_game :-
    retractall(at(_, _)),
    retractall(has(_, _)),
    retractall(alive(_)),
    retractall(money(_, _)),
    retractall(bet_placed(_, _, _)),
    retractall(visited(_)),
    retractall(game_state(_)),
    
    % Set player starting position 
    assertz(at(player, entrance)),
    
    % Set NPC locations 
    assertz(at(victor_kane, high_stakes_table)),
    assertz(at(lana_sinclair, bar)),
    assertz(at(frank_reich, security_office)),
    assertz(at(doorman, entrance)),
    
    % Set objects in the world 
    assertz(at(invitation, player)),  % Player starts with the invitation 
    assertz(at(roulette_wheel, main_floor)),
    assertz(at(blackjack_table, main_floor)),
    assertz(at(poker_table, high_stakes_room)),
    assertz(at(safe, hidden_room)),
    assertz(at(secret_door, main_floor)),
    
    % Set player's initial money 
    assertz(money(player, 5000)),
    
    % Set NPCs as alive 
    assertz(alive(victor_kane)),
    assertz(alive(lana_sinclair)),
    assertz(alive(frank_reich)),
    assertz(alive(doorman)),
    
    % Set initial game state 
    assertz(game_state(started)),
    
    % Start the game 
    write('Welcome to High Stakes, a text adventure game.'), nl,
    write('You stand before the unmarked door of The Emperor, an exclusive underground casino.'), nl,
    write('Type "help." for available commands.'), nl,
    look.

% Define locations 
location(entrance, 'The entrance to The Emperor casino. A doorman guards access.').
location(main_floor, 'The main casino floor with various gambling tables and well-dressed patrons.').
location(bar, 'A luxurious bar area where guests relax with expensive drinks.').
location(high_stakes_room, 'An exclusive room for high-stakes games. Victor Kane deals at the central table.').
location(security_office, 'Frank Reich\'s domain - security monitors and armed guards everywhere.').
location(hidden_room, 'A secretive room behind a hidden door. This must be where the real action happens.').

% Define connections between locations 
connection(entrance, north, main_floor).
connection(main_floor, south, entrance).
connection(main_floor, east, bar).
connection(bar, west, main_floor).
connection(main_floor, north, high_stakes_room) :- 
    has(player, vip_pass),
    write('You show your VIP pass and enter the high stakes room.'), nl.
connection(main_floor, north, high_stakes_room) :- 
    \+ has(player, vip_pass),
    write('A security guard blocks your way: "VIP pass required beyond this point."'), nl,
    fail.
connection(high_stakes_room, south, main_floor).
connection(high_stakes_room, east, security_office) :-
    has(player, security_keycard),
    write('You use the security keycard to open the door.'), nl.
connection(high_stakes_room, east, security_office) :-
    \+ has(player, security_keycard),
    write('The door is locked and requires a security keycard.'), nl,
    fail.
connection(security_office, west, high_stakes_room).
connection(main_floor, west, hidden_room) :-
    at(secret_door, revealed),
    write('You slip through the secret door into a hidden room.'), nl.
connection(main_floor, west, hidden_room) :-
    \+ at(secret_door, revealed),
    write('There\'s just a wall here.'), nl,
    fail.
connection(hidden_room, east, main_floor).

% Game commands 
% Look around current location 
look :-
    at(player, Location),
    location(Location, Description),
    write('Location: '), write(Location), nl,
    write(Description), nl,
    write('You can see:'), nl,
    list_objects_at(Location),
    list_people_at(Location),
    list_exits(Location).

% List objects at the current location 
list_objects_at(Location) :-
    at(Object, Location),
    Object \= player,
    \+ person(Object),
    write('  - '), write(Object), nl,
    fail.
list_objects_at(_).

% List people at the current location 
list_people_at(Location) :-
    at(Person, Location),
    person(Person),
    Person \= player,
    write('  - '), write(Person), nl,
    fail.
list_people_at(_).

% Define who is a person 
person(victor_kane).
person(lana_sinclair).
person(frank_reich).
person(doorman).
person(player).

% List available exits 
list_exits(Location) :-
    write('Exits:'), nl,
    connection(Location, Direction, _),
    write('  - '), write(Direction), nl,
    fail.
list_exits(_).

% Move in a direction 
go(Direction) :-
    at(player, CurrentLocation),
    connection(CurrentLocation, Direction, NewLocation),
    retract(at(player, CurrentLocation)),
    assertz(at(player, NewLocation)),
    look.

% Take an object 
take(Object) :-
    at(player, Location),
    at(Object, Location),
    \+ person(Object),
    retract(at(Object, Location)),
    assertz(at(Object, player)),
    write('You take the '), write(Object), write('.'), nl.
take(Object) :-
    at(player, Location),
    \+ at(Object, Location),
    write('There is no '), write(Object), write(' here.'), nl.
take(Object) :-
    at(Object, _),
    person(Object),
    write('You can\'t take '), write(Object), write('!'), nl.

% Examine an object or person 
examine(Object) :-
    at(player, Location),
    at(Object, Location),
    describe(Object),
    nl.
examine(Object) :-
    at(Object, player),
    describe(Object),
    nl.
examine(Object) :-
    \+ at(Object, player),
    \+ at(Object, _),
    write('You don\'t see a '), write(Object), write(' here.'), nl.
examine(Object) :-
    at(player, Location),
    \+ at(Object, Location),
    \+ at(Object, player),
    write('You don\'t see a '), write(Object), write(' here.'), nl.

% Object descriptions 
describe(invitation) :-
    write('A luxurious invitation card embossed with a golden crown. It reads:'), nl,
    write('"The Emperor awaits those with courage to stake it all.'), nl,
    write('Enter if you dare. Exit if you can."').
describe(roulette_wheel) :-
    write('A standard roulette wheel with red and black numbers. It looks well-maintained.').
describe(blackjack_table) :-
    write('A blackjack table covered in green felt. The dealer smiles invitingly.').
describe(poker_table) :-
    write('An exclusive poker table. The minimum bet is $1,000.').
describe(safe) :-
    write('A large wall safe with an electronic keypad. It appears to be locked.').
describe(secret_door) :-
    write('A cleverly concealed door in the wall. It\'s currently hidden from casual observation.').
describe(victor_kane) :-
    write('Victor Kane, the enigmatic dealer. His hands move with hypnotic precision as he shuffles cards.').
describe(lana_sinclair) :-
    write('Lana Sinclair, dressed in a striking red dress. She carries herself with confident grace.').
describe(frank_reich) :-
    write('Frank Reich, the intimidating security chief. A scar runs across his left cheek.').
describe(doorman) :-
    write('A towering man in an impeccable suit. His expression is professionally neutral.').
describe(vip_pass) :-
    write('A VIP pass that grants access to the high-stakes room.').
describe(security_keycard) :-
    write('A security keycard with magnetic strip. It can unlock secured doors.').

% Talk to a person 
talk_to(Person) :-
    at(player, Location),
    at(Person, Location),
    dialogue(Person),
    nl.
talk_to(Person) :-
    at(player, Location),
    \+ at(Person, Location),
    write('There is no '), write(Person), write(' here to talk to.'), nl.

% Dialogue options 
dialogue(victor_kane) :-
    write('Victor smiles coldly. "Care to try your luck? The house always wins... eventually."'), nl,
    write('He lowers his voice. "But if you\'re looking for the real game, you\'ll need to prove yourself first."').
dialogue(lana_sinclair) :-
    write('Lana sips her champagne. "New blood, how refreshing. If you\'re searching for something more than"'), nl,
    write('just games of chance, we should talk. But first, show me you know how to play."').
dialogue(frank_reich) :-
    write('"Keep your nose clean and we won\'t have problems," Frank growls. "Break the rules, and..."'), nl,
    write('He doesn\'t finish the sentence, but his meaning is clear enough.').
dialogue(doorman) :-
    write('The doorman nods respectfully. "Welcome to The Emperor. Mr. Kane is at the high-stakes table if you\'re looking for him."').

% Check inventory 
inventory :-
    write('You are carrying:'), nl,
    has_something,
    money(player, Amount),
    write('Money: $'), write(Amount), nl.

has_something :-
    at(Object, player),
    write('  - '), write(Object), nl,
    fail.
has_something.

% Bet at a game 
bet(Game, Amount) :-
    at(player, Location),
    at(Game, Location),
    game(Game),
    money(player, CurrentMoney),
    Amount > 0,
    Amount =< CurrentMoney,
    random(1, 3, Outcome),  % 1 = win, 2 = lose
    process_bet(Game, Amount, Outcome).
bet(Game, _) :-
    at(player, Location),
    \+ at(Game, Location),
    write('There is no '), write(Game), write(' here to bet on.'), nl.
bet(Game, _) :-
    \+ game(Game),
    write('You can\'t bet on that.'), nl.
bet(_, Amount) :-
    money(player, CurrentMoney),
    (Amount =< 0 ; Amount > CurrentMoney),
    write('Invalid bet amount. You have $'), write(CurrentMoney), write('.'), nl.

% Define what objects are games 
game(roulette_wheel).
game(blackjack_table).
game(poker_table).

% Process the outcome of a bet 
process_bet(Game, Amount, 1) :-  % Win
    money(player, CurrentMoney),
    Winnings is Amount * 2,
    NewMoney is CurrentMoney + Amount,
    retract(money(player, CurrentMoney)),
    assertz(money(player, NewMoney)),
    write('You bet $'), write(Amount), write(' on '), write(Game), write(' and win $'), write(Winnings), write('!'), nl,
    write('You now have $'), write(NewMoney), write('.'), nl,
    check_special_events(Game, win).
process_bet(Game, Amount, 2) :-  % Lose
    money(player, CurrentMoney),
    NewMoney is CurrentMoney - Amount,
    retract(money(player, CurrentMoney)),
    assertz(money(player, NewMoney)),
    write('You bet $'), write(Amount), write(' on '), write(Game), write(' and lose.'), nl,
    write('You now have $'), write(NewMoney), write('.'), nl,
    check_special_events(Game, lose).

% Check for special events after betting 
check_special_events(poker_table, win) :-
    \+ has(player, vip_pass),
    write('Victor Kane notices your skill and approaches. "Impressive. Perhaps you\'d like access to our more... exclusive games?"'), nl,
    write('He hands you a VIP pass.'), nl,
    assertz(at(vip_pass, player)).
check_special_events(blackjack_table, win) :-
    money(player, Amount),
    Amount > 10000,
    at(secret_door, main_floor),
    \+ at(secret_door, revealed),
    write('As you collect your winnings, Lana Sinclair whispers in your ear, "The real game is behind the wall."'), nl,
    write('She subtly points to a section of wall that looks slightly different from the rest.'), nl,
    retract(at(secret_door, main_floor)),
    assertz(at(secret_door, revealed)).
check_special_events(_, _).

% Help command 
help :-
    write('Available commands:'), nl,
    write('  look.                          - Look around'), nl,
    write('  go(Direction).                 - Move in a direction (north, south, east, west)'), nl,
    write('  take(Object).                  - Pick up an object'), nl,
    write('  examine(Object).               - Examine an object or person'), nl,
    write('  talk_to(Person).               - Talk to a person'), nl,
    write('  inventory.                     - Check what you\'re carrying'), nl,
    write('  bet(Game, Amount).             - Place a bet at a game'), nl,
    write('  help.                          - Show this help message'), nl,
    write('  quit.                          - End the game'), nl,
    nl,
    write('Example: go(north). or take(invitation).'), nl.

% Quit the game 
quit :-
    write('Thanks for playing High Stakes!'), nl,
    halt.
