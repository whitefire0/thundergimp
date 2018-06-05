# UserInterface will eventually shield the entire inner application, exposing only accepted commands
class UserInterface
  attr_accessor :delays_off

  def initialize(game)
    @game_instance = game
    @player_created = false
    @character_chosen = false
    @chosen_action = nil
    @play_again = nil
  end
  
  def run_root_controller
    while @game_instance.on do
      player_creation_if_needed
      get_player_action
      run_player_action

      # return true/false to outer game creation loop in main.rb
      if @play_again
        return true
      else
        return false unless @game_instance.on
      end
    end
  end

  def player_creation_if_needed
    create_player unless @player_created
    select_character_instance unless @character_chosen
    @game_instance.on = true if @player_created && @character_chosen
  end

  def select_character_instance
    while player_class == NilClass
      puts "\nPlease choose your character class:
              v = Viking 
              b = Barbarian
              w = Wizard 
              r = Rogue 
              c = Cleric 
              g = Gimp\n".colorize(:magenta)
      # chosen_class = gets.chomp
      # *** FOR TESTING ***
      chosen_class = 'v'
      case chosen_class
      when /^v|V/
        @game_instance.set_player_class('Viking')
      when /^b|B/
        @game_instance.set_player_class('Barbarian')
      when /^w|W/
        @game_instance.set_player_class('Wizard')
      when /^r|R/
        @game_instance.set_player_class('Rogue')
      when /^c|C/
        @game_instance.set_player_class('Cleric')
      when /^g|G/
        @game_instance.set_player_class('Gimp')
      else
        puts "Invalid choice, please choose again.".colorize(:light_black)
      end
    end
  end

  def run_player_action
    case @chosen_action
      when "walk"
        if enemy_is_present
          render_message('enemy blocking')
          reset_player_action
        end
        if tile_unspent
          # HACK - find some other way of preventing tile_unspent running if an enemy has already prevented action
          unless enemy_is_present
            render_message('not now')
            reset_player_action
          end
        end
        unless tile_unspent || enemy_is_present
          move_forward_and_act
          reset_player_action
        end
      when "attack"
        if @game_instance.current_tile.enemy_present
          run_battle_sequence
        else
          render_message('attacking nothing')
        end
        reset_player_action
      when "rest"
        @healed = @game_instance.player_char.rest
        if @healed
          render_message('heal')
        else
          render_message('no more rests')
        end
        reset_player_action
      when "inspect"
        # code
        reset_player_action        
      when "hide"
        # code
        reset_player_action        
      else
    end
  end

  def run_battle_sequence
    @game_instance.battle_mode
    @game_instance.spent_tiles += 1
    exit_game? if @game_instance.player_char.is_dead   
  end

  def move_forward_and_act
    reset_available_rests
    @game_instance.get_new_tile
    present_tile
    get_player_action
  end

  def enemy_is_present
    unless @game_instance.current_tile == nil
      @game_instance.current_tile.enemy_present
    end
  end

  def create_player
    unless @player_created
      render_message('get name')
      # @game_instance.player_name = gets.chomp
      # *** FOR TESTING ***
      @game_instance.player_name = 'Rick'
      @player_created = true
    end
  end

  def welcome_player
    render_message('welcome player')
    render_message('character stats')
    @character_chosen = true
    sleep(2) unless dev_mode
    render_message('walk into dungeon')
  end

  def present_tile
    sleep(1) unless dev_mode
    render_message('step forward')
    sleep(1) unless dev_mode
    render_message('tile description')
    sleep(1.5) unless dev_mode
    if @game_instance.current_tile.enemy_present
      render_message('enemy appears')
      sleep(2) unless dev_mode
      render_message('inspect enemy')
    end
  end

  def get_player_action
    # *** FOR TESTING ***
    # @chosen_action = 'attack'
    sleep(2) unless dev_mode
    # binding.pry
    while @chosen_action == nil
      render_message('choose action')
      response = gets.chomp
      puts "\n"
      case response
      when /^w|W/
        @chosen_action = 'walk'
      when /^a|A/
        @chosen_action = 'attack'
      when /^r|R/
        @chosen_action = 'rest'
      when /^i|I/
        @chosen_action = 'inspect'
      else
        render_message('invalid action')
      end
    end
  end

  def tile_unspent
    @game_instance.tile_number > @game_instance.spent_tiles
  end

  def reset_player_action
    @chosen_action = nil
  end

  def reset_available_rests
    @game_instance.player_char.rests_remaining = @game_instance.player_char.rests_per_turn
  end

  def exit_game?
    # do we need this nil?
    # @play_again = nil
    while @play_again == nil do
      render_message('play again?')
      response = gets.chomp
      case response
      when /^y|Y/
        @play_again = true
      when /^n|N/
        @play_again = false
      else
        render_message('invalid action')
      end
    end

    @game_instance.on = false if @play_again == false
  end

  def dev_mode
     @game_instance.delays_off
  end

  def player_name
    @game_instance.player_char.name
  end

  def player_class
    @game_instance.player_char.class
  end
  
  def player_age
    @game_instance.player_char.age
  end

  def player_health
    @game_instance.player_char.health
  end

  def player_strength
    @game_instance.player_char.strength
  end

  def player_constitution
    @game_instance.player_char.constitution
  end

  def player_intelligence
    @game_instance.player_char.intelligence
  end

  def player_dexterity
    @game_instance.player_char.dexterity
  end

  def player_unique_skills
    @game_instance.player_char.unique_skills
  end

  def enemy_name
    @game_instance.current_tile.enemy.name
  end

  def enemy_class
    @game_instance.current_tile.enemy.class
  end
  
  def enemy_age
    @game_instance.current_tile.enemy.age
  end

  def enemy_health
    @game_instance.current_tile.enemy.health
  end

  def enemy_strength
    @game_instance.current_tile.enemy.strength
  end

  def enemy_constitution
    @game_instance.current_tile.enemy.constitution
  end

  def enemy_intelligence
    @game_instance.current_tile.enemy.intelligence
  end

  def enemy_dexterity
    @game_instance.current_tile.enemy.dexterity
  end

  def enemy_unique_skills
    @game_instance.current_tile.enemy.unique_skills
  end

  def render_message(msg)
    case msg
    when 'attacking nothing'
      puts "You are attacking thin air...there is no enemy. Conserve your energy you dimwit.\n"
    when 'get name'
      puts "Please enter your name, player: \n".colorize(:magenta)
    when 'welcome player'
      puts "Welcome to the dungeon, #{player_name} the #{player_class}! Untold glory awaits you.\n".colorize(:magenta)
    when 'character stats'
      puts "These are your character stats:\n
        Age: #{player_age}
        Health: #{player_health}
        Strength: #{player_strength}
        Constitution: #{player_constitution}
        Intelligence: #{player_intelligence}
        Dexterity: #{player_dexterity}
        Your unique skill: #{player_unique_skills}\n".colorize(:blue)
    when 'walk into dungeon'
      puts "It is here that we begin. If you are sure you wish to proceed, you must walk into the dungeon itself...\n".colorize(:light_green)
    when 'step forward'
      puts "You step forward, into the next dungeon area, reaching tile #{@game_instance.tile_number}...".colorize(:light_green)
    when 'tile description'
      puts @game_instance.current_tile.tile_description.colorize(:green)
    when 'enemy appears'
      puts "\nAn enemy has appeared! #{enemy_name} the #{enemy_class} is standing in front of you!\n".colorize(:light_red)
    when 'inspect enemy'
      puts "You take a look closer at the bastard, and see...\n
            Name: #{enemy_name}
            Type: #{enemy_class}
            Age: #{enemy_age}
            Health: #{enemy_health}
            Strength: #{enemy_strength}
            Constitution: #{enemy_constitution}
            Intelligence: #{enemy_intelligence}
            Dexterity: #{enemy_dexterity}
            Unique Skill: #{enemy_unique_skills}\n".colorize(:yellow)
    when 'choose action'
      puts "Player, make your choice:
        w = Walk forward...further into the dungeon
        a = Attack
        r = Rest
        i = Inspect area\n".colorize(:magenta)
    when 'hit'
      puts "#{@game_instance.last_attacking_char.name} the #{@game_instance.last_attacking_char.class} hit #{@game_instance.last_defending_char.name} the #{@game_instance.last_defending_char.class} for #{@game_instance.last_damage_dealt} hitpoints".colorize(:red) 
      puts "#{@game_instance.last_defending_char.name} has #{@game_instance.last_defending_char.health} health remaining\n".colorize(:red)
    when 'heal'
      puts "#{player_name} the #{player_class} healed for #{@healed} hitpoints\n".colorize(:red)
    when 'no more rests'
      puts "You have no more rests remaining in this area...you must advance!\n".colorize(:red)
    when 'died'
      if @game_instance.player_char.is_dead
        puts "#{player_name} lost all their health points and has died!\n".colorize(:red)
      elsif @game_instance.current_tile.enemy.class == NilClass
        puts "#{@game_instance.previous_enemy.name} lost all their health points and has died!\n".colorize(:red)
      end
    when 'enemy blocking'
      # binding.pry
      puts "You can't move foward, #{enemy_name} the #{enemy_class} is blocking your path!\n\n"
    when 'invalid action'
      puts "Invalid action. Please choose again.".colorize(:light_black)
    when 'not now'
      puts "\nYou can't do that right now\n\n"
    when 'play again?'
      puts "You have been defeated! Would you like to play again? (y/n)"
    else
    end
  end
end