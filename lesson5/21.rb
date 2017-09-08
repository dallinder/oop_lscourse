module Hand
  def hit(one_card)
    cards << one_card
  end

  def ace_value(new_value)
    ace = cards.select { |card| card.split[0] == 'A' }
    if ace.size >= 1 && new_value < 11
      new_value + 10
    else
      new_value + 0
    end
  end

  def show_initial_cards
    puts "#{player.name}'s hand is #{player.cards.join(', ')}."
    puts ''
    puts "#{dealer.name} is showing #{dealer.cards.first}."
  end

  def deal
    2.times do
      player.cards << deck.pop
      dealer.cards << deck.pop
    end
  end
end

class Participant
  def initialize
    @cards = []
  end

  def total
    values = []
    cards.each do |card|
      values << case card[0]
                when 'K' then 10
                when 'Q' then 10
                when 'J' then 10
                when 'A' then 1
                else
                  card.split[0].to_i
                end
    end
    values = values.inject(:+)
    values
    # ace_value(values)
  end

  def busted?
    return true if total > 21
  end

  def show_cards
    puts "#{name} has #{cards.join(', ')} for a total of #{total}."
  end
end

class Deck
  SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs']
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'K', 'Q', 'J', 'A']

  def initialize
    @suits = SUITS
    @values = VALUES
  end

  def new_deck
    deck = []
    @suits.map do |suit|
      @values.map do |value|
        deck << "#{value} of #{suit}"
      end
    end
    deck
  end
end

class Player < Participant
  include Hand
  attr_accessor :name, :cards

  def initialize
    @name = name
    @cards = []
  end
end

class Dealer < Participant
  include Hand
  attr_accessor :cards
  attr_reader :name

  def initialize
    @cards = []
    @name = ['R2D2', 'Chappie', 'Hal', 'Wall-E'].sample
  end
end

class Game
  include Hand
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new.new_deck
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    game_start
    loop do
      deck.shuffle!
      deal
      turns_loop
      puts ""
      display_winners
      puts "Do you want to play again? (y or n)"
      answer = gets.chomp
      break unless answer == 'y'
      reset
      system 'clear'
    end
  end

  def game_start
    puts "Welcome to 21! What is your name?"
    loop do
      player.name = gets.chomp
      break if player.name.size > 1 && player.name =~ /[^ ]/
      puts "Please enter your name."
    end
    introductions
  end

  def introductions
    puts "Nice to meet you, #{player.name}"
    puts "Your dealer will be #{dealer.name}"
    puts ''
    puts "The goal of 21 is to get as close to 21 without going over."
    puts "Lets play!"
    puts ''
    sleep(2)
  end

  def turns_loop
    loop do
      show_initial_cards
      player_turn
      break if player.busted?
      dealer_turn
      break
    end
  end

  def display_winners
    dealer.show_cards
    player.show_cards
    puts ''
    winner
  end

  def winner
    if player_won?
    elsif dealer_won?
    elsif dealer.total == player.total
      puts "It's a push!"
    end
  end

  def player_won?
    if dealer.busted?
      puts "Dealer busted with #{dealer.total}! You win!"
    elsif player.total > dealer.total && player.busted? != true
      puts "#{player.name} won!"
    end
  end

  def dealer_won?
    if player.busted?
      puts "You busted with #{player.total}! Dealer wins"
    elsif dealer.total > player.total && dealer.busted? != true
      puts "#{dealer.name} won!"
    end
  end

  def player_turn
    loop do
      break if player.busted?
      player_turn_prompt
      choice = gets.chomp

      loop do
        break if choice == 'hit' || choice == 'stay'
        puts "Please enter hit or stay."
        choice = gets.chomp
      end

      system "clear"
      return nil if choice == 'stay'
      player.hit(deck.pop)
    end
  end

  def player_turn_prompt
    puts "You now have a total of: #{player.total}"
    puts "Dealer is showing #{dealer.cards.first}"
    puts ''
    puts "Would you like to hit or stay?"
  end

  def reset
    self.deck = Deck.new.new_deck
    player.cards = []
    dealer.cards = []
  end

  def dealer_turn
    loop do
      break if dealer.total >= 17
      dealer.hit(deck.pop)
      dealer.total
    end
  end
end

Game.new.start
