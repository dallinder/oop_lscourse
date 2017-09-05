class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def threat_count(line)
    line.select { |el| @squares[el].marker =~ /[^O ]/ }.size == 2 &&
      line.select { |el| @squares[el].marker == ' ' }.size == 1
  end

  def threat_marker(line)
    @squares.select do |k, _|
      line.include?(k) && @squares[k].marker == Square::INITIAL_MARK
    end.keys.first
  end

  def detect_threat
    WINNING_LINES.each do |line|
      if threat_count(line)
        return threat_marker(line)
      end
    end
    nil
  end

  def attack_sq_five
    return 5 if @squares[5].marker == ' '
  end

  def attack_count(line)
    line.select do |el|
      @squares[el].marker == TTTGame::COMPUTER_MARKER
    end.size == 2 &&
      line.select { |el| @squares[el].marker == ' ' }.size == 1
  end

  def attack_marker(line)
    @squares.select do |k, _|
      line.include?(k) && @squares[k].marker == Square::INITIAL_MARK
    end.keys.first
  end

  def attack_to_win
    WINNING_LINES.each do |line|
      if attack_count(line)
        return attack_marker(line)
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end

  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARK = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARK)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARK
  end

  def marked?
    marker != INITIAL_MARK
  end
end

class Player
  attr_accessor :marker, :name

  def initialize(marker)
    @marker = marker
  end

  def name_choice
    if @marker == "O"
      self.name = ['R2D2', 'Chappie', 'Hal'].sample
    else
      human_name = nil
      loop do
        puts "What is your name?"
        human_name = gets.chomp
        break unless human_name.empty? || human_name =~ /[^a-z]/i
        puts "Please enter your name."
      end
      self.name = human_name
    end
  end
end

module Display
  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts "First to win 5 rounds, wins the game!"
    human.name_choice
    computer.name_choice
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_board
    puts "#{human.name} is #{human.marker}."
    puts "#{computer.name} is #{computer.marker}."
    update_score
    display_score
    puts ""
    board.draw
    puts ""
  end

  def clear
    system 'clear'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def joinor(array, delimiter=', ', word='or')
    case array.size
    when 0 then ''
    when 1 then array.first
    when 2 then array.join("#{word} ")
    else
      array[-1] = "#{word} #{array.last}"
      array.join(delimiter)
    end
  end

  def reset
    board.reset
    clear
    @current_marker = @first_marker
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ''
  end
end

module Moves
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = 'O'

  def human_moves
    puts "Please choose #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a vaild choice."
    end

    board[square] = human.marker
  end

  def computer_attack_or_defend
    if board.attack_to_win
      board[board.attack_to_win] = computer.marker
    elsif board.detect_threat
      board[board.detect_threat] = computer.marker
    end
  end

  def computer_moves
    if computer_attack_or_defend
      computer.marker
    elsif board.attack_sq_five
      board[board.attack_sq_five] = computer.marker
    else
      board[board.unmarked_keys.sample] = computer.marker
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def who_moves_first
    answer = nil
    loop do
      puts "Who should go first? (P)layer or (C)omputer?"
      answer = gets.chomp.downcase
      break if answer == 'p' || answer == 'c'
      puts "Please enter P for player or C for computer."
    end
    if answer == 'p'
      @first_marker = HUMAN_MARKER
    elsif answer == 'c'
      @first_marker = COMPUTER_MARKER
    end
  end
end

class TTTGame
  include Display
  include Moves

  attr_reader :board, :human, :computer
  attr_accessor :human_score, :computer_score

  def initialize
    @board = Board.new
    @human = Player.new("X")
    @computer = Player.new(COMPUTER_MARKER)
    @human_score = 0
    @computer_score = 0
  end

  def play
    game_start
    loop do
      loop do
        display_board

        main_game_loop

        display_result
        break if human_score == 5 || computer_score == 5
        reset
        display_play_again_message
      end
      break unless play_again?
      score_reset
      reset
    end
    display_goodbye_message
  end

  def main_game_loop
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def game_start
    clear
    display_welcome_message
    pick_a_marker
    who_moves_first
    @current_marker = @first_marker
    clear
  end

  private

  def pick_a_marker
    marker = nil
    loop do
      puts "Please pick a 1 character marker."
      marker = gets.chomp
      break unless marker.size != 1 || marker =~ /[ ]/
      "Your marker has more than 1 character, please pick 1 character."
    end
    human.marker = marker
  end

  def update_score
    case board.winning_marker
    when human.marker then self.human_score += 1
    when computer.marker then self.computer_score += 1
    end
  end

  def display_score
    puts "#{human.name}: #{self.human_score}"
    puts "#{computer.name}: #{self.computer_score}"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def score_reset
    @human_score = 0
    @computer_score = 0
  end
end

game = TTTGame.new
game.play
