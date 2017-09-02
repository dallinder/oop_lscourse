class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  WINNING_MOVES = {  'rock' => ['scissors', 'lizard'],
                     'paper' => ['rock', 'spock'],
                     'scissors' => ['paper', 'lizard'],
                     'spock' => ['rock', 'scissors'],
                     'lizard' => ['spock', 'paper'] }

  def >(other_move)
    WINNING_MOVES[value].include?(other_move.value)
  end

  def to_s
    @value
  end
end

class History
  attr_accessor :win

  def initialize
    self.win = []
  end

  def win?(move)
    win << move
  end

  LOSING_MOVES = { 'rock' => ['spock', 'paper'],
                   'paper' => ['scissors', 'lizard'],
                   'scissors' => ['rock', 'spock'],
                   'lizard' => ['rock', 'scissors'],
                   'spock' => ['paper', 'lizard'] }

  def which_move
    selector = win.select { |el| el if win.count(el) == 2 }
    return false if selector.empty?
    LOSING_MOVES[selector.sample].sample
  end
end

class Player
  attr_accessor :move, :name, :score, :human_wins

  def initialize
    self.human_wins = History.new
    @score = 0
    set_name
  end
end

class Human < Player
  def set_name
    n = ""
    puts "Welcome to Rock, Paper, Lizard, Spock!"
    loop do
      puts "What is your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp.downcase
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice!"
    end
    self.move = Move.new(choice)
    # history << move.to_s
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def r2d2_choice
    Move.new(['spock', 'lizard', 'paper'].sample)
  end

  def hal_choice
    Move.new(['scissors', 'rock', 'paper'].sample)
  end

  def chappie_choice
    Move.new(['spock', 'scissors'].sample)
  end

  def sonny_choice
    Move.new(['rock', 'paper'].sample)
  end

  def number5_choice
    Move.new(['lizard', 'rock'].sample)
  end

  def choose
    choice_basis = human_wins.which_move

    self.move = if choice_basis
                  Move.new(choice_basis)
                elsif name == 'R2D2'
                  r2d2_choice
                elsif name == 'Hal'
                  hal_choice
                elsif name == 'Chappie'
                  chappie_choice
                elsif name == 'Sonny'
                  sonny_choice
                else
                  number5_choice
                end
  end
end

# GAME LOOP --------------------------------------------

class RPSGame
  attr_accessor :human, :computer, :human_wins

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome, #{human.name}!"
    puts "You will be playing until either you or the computer gets to 3 wins!"
    puts "You're opponent will be #{computer.name}!"
  end

  def display_game_winner
    if human.score > computer.score
      puts "#{human.name} wins the game!"
    else
      puts "#{computer.name} wins the game!"
    end
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Goodbye!"
  end

  def display_moves
    puts ''
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_round_winner
    if human.move > computer.move
      puts "#{human.name} won the round!"
    elsif computer.move > human.move
      puts "#{computer.name} won the round!"
    else
      puts "It's a tie!"
    end
  end

  # not sure how to get rid of the cop on def scoring. not sure moving logic
  # makes the code any cleaner

  def scoring
    if human.move > computer.move
      human.score += 1
      computer.human_wins.win?(human.move.to_s)
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def display_score
    puts "#{human.name}'s score is #{human.score}"
    puts "#{computer.name}'s score is #{computer.score}"
    puts ''
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n"
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def game_order_loop
    loop do
      human.choose
      computer.choose
      display_moves
      display_round_winner
      scoring
      display_score
      # ran the game to 3 because 10 seems like way too much!
      if human.score == 3 || computer.score == 3
        display_game_winner
        break
      end
    end
  end

  def play
    display_welcome_message
    loop do
      game_order_loop
      human.score = 0
      computer.score = 0
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
