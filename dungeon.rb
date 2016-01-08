# This class contains methods necessary to run the dungeon game, as well as Player, Monster, & Room classes
class Dungeon
    attr_accessor :player
    
    # Create the dungeon object and store the player's name
    def initialize(player_name)
        @player = Player.new(player_name)
        @rooms = []
        @items = []
        @monsters = []
    end
    
    # This method adds a room to the current object's array of rooms
    def add_room(reference, name, description, connections)
        @rooms << Room.new(reference, name, description, connections)
    end
    
    # This method adds an item to the current object's array of items
    def add_item(name, description)
        @items << Item.new(name, description)
    end

    # This method adds a monster to the current object's array of monsters
    def add_monster(name, description, hit_points, attack_min, attack_max)
        @monsters << Monster.new(name, description, hit_points, attack_min, attack_max)
    end

    # This method removes a room's items after they've been taken by the player
    def remove_items(room)
        room.items.clear
    end
    
    # This method disperses all of the current object's items, randomly amongst the rooms
    def disperse_items
        @items.each {|item| 
            room = @rooms[rand(2...@rooms.size)]
            room.items << item
        }
    end

    # This method disperses all of the current object's monsters, randomly amongst the rooms
    def disperse_monsters
        @monsters.each{|monster|
            room = @rooms[rand(2...@rooms.size)]
            room.monsters << monster
        } 
    end
    
    # This method starts the player in a specified room of the dungeon
    def start(location)
        @player.location = location
    end
    
    # This method prints the description of the room the player is currently in
    def show_current_description
        puts find_room_in_dungeon(@player.location).full_description
    end
    
    # This method returns a room object that matches the passed in reference
    def find_room_in_dungeon(reference)
        @rooms.detect {|room| reference.to_sym == room.reference}
    end

    # This method returns a hash value with key matching passed in direction
    def find_room_in_direction(direction)
        find_room_in_dungeon(@player.location).connections[direction]
    end

    # This method moves the player to a new room based on the passed in direction
    def go(direction)
        new_location = find_room_in_direction(direction.to_sym)
    end

    # This method updates the players location
    def update_location(new_location)
        @player.location = new_location
    end
    
    # This method finds items in the current room and adds them to the player's inventory and removes them from the room 
    def search
        current_room = find_room_in_dungeon(@player.location)
        if current_room.items.size > 0
            puts current_room.items.size > 1 ? "Items found!" : "Item found!"
            @player.add_inventory(current_room.items)
            remove_items(current_room)
        else
            puts "No items found"
        end
    end

    # This method looks for monsters in the current room
    def detect_monsters
        current_room = find_room_in_dungeon(@player.location)
        current_room.monsters
    end

    # List names of monsters
    def list_monsters
        monsters = find_room_in_dungeon(@player.location).monsters
        print "\nYou've come upon "
        print "a host of monsters:\n" if monsters.size > 1
        monsters.each{|monster| puts "a #{monster.name}"}
    end


    def battle
        until player_dead or monsters_dead
            
            player_attack = player_attack_generate
            
            if player_strike_first then
                player_inflict_damage
                remove_dead_monsters
                monsters_inflict_damage
                break if player_dead
            else
                monsters_inflict_damage
                player_inflict_damage
                remove_dead_monsters
                break if player_dead
            end
            
        end
        
    end
    
    def report_slain_monster(monster)
        puts "You have slain a #{monster.name}!"
    end
    
    def remove_dead_monsters
        dead = find_room_in_dungeon(@player.location).monsters.find {|monster| monster.hit_points < 1}
        report_slain_monster(dead) if dead
        
        find_room_in_dungeon(@player.location).monsters.delete_if {|monster| 
            monster.hit_points < 1
        }
    end
    
    def player_inflict_damage
        monsters = find_room_in_dungeon(@player.location).monsters
        player_attack = player_attack_generate
        monsters.first.hit_points -= player_attack
        puts "player inflicted #{player_attack} damage on #{monsters.first.name}"
        puts "#{monsters.first.name} hit points remaining: #{monsters.first.hit_points}"
    end
    
    def monsters_inflict_damage
        find_room_in_dungeon(@player.location).monsters.each {|monster|
            monster_attack = monster_attack_generate(monster)
            puts "#{monster.name} inflicts #{monster_attack} damage"
            @player.hit_points -= monster_attack
            puts @player.hit_points > 0 ? "player remaining hit points: #{@player.hit_points}" : "you have fallen in the dungeon!"
            return if player_dead
        }
    end
    
    def player_attack_generate
        rand(@player.attack_min..@player.attack_max)
    end
    
    def monster_attack_generate(monster)
        rand(monster.attack_min..monster.attack_max)
    end
    
    def player_strike_first
        true if rand(1..2) == 1
    end
    
    def player_dead
        true if @player.hit_points <= 0
    end

    def monsters_dead
        monsters = find_room_in_dungeon(@player.location).monsters
        true if monsters.all? {|monster| monster.hit_points <= 0 }
    end

    # This class stores information about dungeon players
    class Player
        attr_accessor :name, :location, :hit_points, :attack_min, :attack_max

        # Create a player object, store the player's name, and set beginning hit points
        def initialize(name)
            @name = name
            @inventory = []
            @hit_points = 1000
            @attack_min = 20
            @attack_max = 500
        end
        
        # This method puts items in the player's inventory
        def add_inventory(items)
            items.each {|item| 
                @inventory << item
                puts "#{item.name} added to inventory"
            }
        end

        # This method lists the current player's inventory
        def list_inventory
            puts "\nInventory List\n"
            @inventory.each {|item| puts item.description}
        end
        
    end

    # This class stores information about dungeon monsters
    class Monster
        attr_accessor :name, :description, :hit_points, :attack_min, :attack_max

        # Create the monster object, and store name and other attributes
        def initialize(name, description, hit_points, attack_min, attack_max)
            @name = name
            @description = description
            @hit_points = hit_points
            @attack_min = attack_min
            @attack_max = attack_max
        end
    end
    
    # This class stores information about dungeon rooms
    class Room
        attr_accessor :reference, :name, :description, :connections, :items, :monsters
        
        # Create the room object and store the passed in attributes
        def initialize(reference, name, description, connections)
            @reference = reference
            @name = name
            @description = description
            @connections = connections
            @items = []
            @monsters = []
        end
        def full_description
            "\n" + "********** " + @name + " **********" + "\n\nYou are in " + @description
        end
    end

    # This struct stores item information
    Item = Struct.new(:name, :description)
    
end

puts "WELCOME, TO THE DUNGEON!\n\n"

puts "Greetings, adventurer. What is your name?\n"

current_player = gets.chomp

current = Dungeon.new(current_player)

current.add_room(:exit, "Exit", "You have escaped the dungeon!", {north: :entrance})
current.add_room(:entrance, "Entrance", "the entrance to the dungeon", {south: :exit, north: :largecave})
current.add_room(:largecave, "Large Cave", "a vast cavern", {west: :smallcave, north: :river, south: :entrance})
current.add_room(:smallcave, "Small Cave", "a small, dank cave", {east: :largecave, south: :idols})
current.add_room(:idols, "Hall of Idols", "a room filed with mysterious idols", {north: :smallcave})

current.add_room(:river, "Underground River", "a swiftly flowing underground river of unknown origin", {south: :largecave, north: :lake})
current.add_room(:lake, "Fathomless lake", "a dark, fathomless lake of ill tidings", {south: :river})


current.add_item(:torch, "A flaming torch")
current.add_item(:compass, "glow-in-the-dark magnetic compass")
current.add_item(:coins, "A small bag of gold coins imprinted with strange runes")
current.add_item(:dagger, "A fine dagger of blue steel")
current.add_item(:shield, "An oval shield of mirrored steel")

current.disperse_items

3.times {current.add_monster(:orc, "A savage orc, dripping with black slime", 100, 5, 50)}
10.times {current.add_monster(:serpent, "A venimous snake of enormous proportions", 50, 0, 1000)}
5.times {current.add_monster(:slime, "A green slime blob emitting noxious fumes", 25, 1, 10)}

current.disperse_monsters


puts "\n#{current.player.name} enters the dungeon"

user_choice = nil
current.start(:entrance)
current.show_current_description

catch(:finish) do
    until user_choice =~ /[qQ]/
        unless current.detect_monsters.empty?
            current.list_monsters
            current.battle
        end
        puts "\n#{current.player.name}, search room (s) or move (north, south, east, west)?\n"
        user_choice = gets.chomp

        if user_choice =~ /(^S$|^s$)/
            current.search
        elsif user_choice =~ /(north|south|east|west)/
            puts "\nYou go " + user_choice
            new_location = current.go(user_choice)
            if new_location == :exit
                puts "You have escaped the dungeon!"
                throw :finish
            elsif new_location
                current.update_location(new_location)
                current.show_current_description
            else
                puts "Dead End"
            end
        end
    end
end

puts "\n#{current.player.name} enters the dungeon"

user_choice = nil
current.start(:entrance)
current.show_current_description

catch(:finish) do
    until user_choice =~ /[qQ]/
        unless current.detect_monsters.empty?
            current.list_monsters
            current.battle
        end
        puts "\n#{current.player.name}, search room (s) or move (north, south, east, west)?\n"
        user_choice = gets.chomp

        if user_choice =~ /(^S$|^s$)/
            current.search
        elsif user_choice =~ /(north|south|east|west)/
            puts "\nYou go " + user_choice
            new_location = current.go(user_choice)
            if new_location == :exit
                puts "You have escaped the dungeon!"
                throw :finish
            elsif new_location
                current.update_location(new_location)
                current.show_current_description
            else
                puts "Dead End"
            end
        end
    end
end
