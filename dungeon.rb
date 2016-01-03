class Dungeon
    attr_accessor :player
    
    def initialize(player_name)
        @player = Player.new(player_name)
        @rooms = []
        @items = []
        @monsters = []
    end
    
    def add_room(reference, name, description, connections)
        @rooms << Room.new(reference, name, description, connections)
    end
    
    def add_item(name, description)
        @items << Item.new(name, description)
    end

    def add_monster(name, description, hit_points, attack_min, attack_max)
        @monsters << Monster.new(name, description, hit_points, attack_min, attack_max)
    end

    def remove_items(room)
        room.items.clear
    end
    
    def disperse_items
        @items.each {|item| 
            room = @rooms[rand(@rooms.size)]
            room.items << item
        }
    end

    def disperse_monsters
        @monsters.each{|monster|
            room = @rooms[rand(@rooms.size)]
            room.monsters << monster
        } 
    end
    
    def start(location)
        @player.location = location
        show_current_description
        detect_monsters
    end
    
    def show_current_description
        puts find_room_in_dungeon(@player.location).full_description
    end
    
    def find_room_in_dungeon(reference)
        @rooms.detect {|room| reference.to_sym == room.reference}
    end
    
    def go(direction)
        puts "\nYou go " + direction
        
        new_location = find_room_in_direction(direction.to_sym)
        
        if new_location
            @player.location = new_location
            puts @player.location
            show_current_description
        else
            puts "Dead End"
        end
        detect_monsters
    end
    
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

    def detect_monsters
        current_room = find_room_in_dungeon(@player.location)

        puts "Monsters type= #{current_room.monsters.size}"
        if current_room.monsters.size == 1
            puts "You've come upon a #{current_room.monsters[0].name}"
        elsif current_room.monsters.size > 1
            puts "You've come upon a host of monsters:"
            current_room.monsters.each{|monster| puts "a #{monster.name}"}
        end
    end
    
    def find_room_in_direction(direction)
        find_room_in_dungeon(@player.location).connections[direction]
    end
    
    class Player
        attr_accessor :name, :location
        def initialize(name)
            @name = name
            @inventory = []
            @hit_points = 1000
        end
        
        Inventory = Struct.new(:name, :description)
        
        def add_inventory(items)
            items.each {|item| 
                @inventory << item
                puts "#{item.name} added to inventory"
            }
        end
        def list_inventory
            puts "\nInventory List\n"
            @inventory.each {|item| puts item.description}
        end
        
    end

    class Monster
        attr_accessor :name
        def initialize(name, description, hit_points, attack_min, attack_max)
            @name = name
            @description = description
            @hit_points = hit_points
            @attack_min = attack_min
            @attack_max = attack_max
        end
    end
    
    class Room
        attr_accessor :reference, :name, :description, :connections, :items, :monsters
        def initialize(reference, name, description, connections)
            @reference = reference
            @name = name
            @description = description
            @connections = connections
            @items = []
            @monsters = []
        end
        def full_description
            "\n" + @name + "\n\nYou are in " + @description
        end
    end
    
    Item = Struct.new(:name, :description)
    
end

puts "WELCOME, TO THE DUNGEON!\n\n"

puts "Greetings, adventurer. What is your name?\n"

current_player = gets.chomp

current = Dungeon.new(current_player)

current.add_room(:entrance, "Entrance", "the entrance to the dungeon", {north: :largecave})
current.add_room(:largecave, "Large Cave", "a vast cavern", {west: :smallcave, south: :entrance})
current.add_room(:smallcave, "Small Cave", "a small, dank cave", {east: :largecave, south: :idols})
current.add_room(:idols, "Hall of Idols", "a room filed with mysterious idols", {north: :smallcave})

current.add_item(:torch, "A flaming torch")
current.add_item(:compass, "glow-in-the-dark magnetic compass")
current.add_item(:coins, "A small bag of gold coins imprinted with strange runes")
current.add_item(:dagger, "A fine dagger of blue steel")
current.add_item(:shield, "An oval shield of mirrored steel")

current.disperse_items

current.add_monster(:orc, "A savage orc, dripping with black slime", 100, 5, 50)
current.add_monster(:serpent, "A venimous snake of enormous proportions", 50, 0, 1000)
current.add_monster(:slime, "A green slime blob emitting noxious fumes", 25, 1, 10)

current.disperse_monsters


puts "\n#{current.player.name} enters the dungeon"

current.start(:entrance)

user_choice = nil

until user_choice =~ /[qQ]/
    puts "\n#{current.player.name}, search room (s) or move (north, south, east, west)?\n"
    user_choice = gets.chomp

    if user_choice =~ /(^S$|^s$)/
        current.search
    elsif user_choice =~ /(north|south|east|west)/
        current.go(user_choice)
    end
end


# current.search

# current.player.list_inventory

# current.go("north")
