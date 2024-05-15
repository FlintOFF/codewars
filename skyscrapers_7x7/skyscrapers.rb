class Skyscrapers
  attr_reader :all_possible_combinations, :possible_column_combinations, :possible_row_combinations, :grid

  def initialize(clues:, grid: nil, all_possible_combinations: nil, possible_row_combinations: nil, possible_column_combinations: nil)
    @clues = clues
    @size = @clues.size / 4
    clues_chunk = @clues.each_slice(@size).to_a
    @clue_column_set = clues_chunk[0].zip(clues_chunk[2].reverse)
    @clue_row_set = (clues_chunk[3].reverse).zip(clues_chunk[1])
    @grid = grid || Array.new(@size, Array.new(@size, 0)).map(&:dup)
    @all_possible_combinations = all_possible_combinations || generate_possible_combinations
    @possible_column_combinations = possible_column_combinations || @clue_column_set.map { |arr| find_possible_combinations(*arr) }
    @possible_row_combinations = possible_row_combinations || @clue_row_set.map { |arr| find_possible_combinations(*arr) }
    @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
    @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
  end

  def main_process
    (0...@size).each do |row_i|
      next unless @grid[row_i].include?(0)

      (0...@size).each do |col_j|
        next unless @grid[row_i][col_j] == 0

        return false if @possible_row_combinations.dig(row_i, 0, col_j).nil?

        # if one number is present in all combinations then it is a right number
        if check_element(@possible_row_combinations[row_i][0][col_j], col_j, @possible_row_combinations[row_i])
          @grid[row_i][col_j] = @possible_row_combinations[row_i][0][col_j]
          @possible_row_combinations = filter_possible_combinations(@possible_row_combinations, row_i, col_j, @grid[row_i][col_j])
          @possible_column_combinations = filter_possible_combinations(@possible_column_combinations, col_j, row_i, @grid[row_i][col_j])
          @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
          @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
        end

        return false if @possible_column_combinations.dig(col_j, 0, row_i).nil?

        if check_element(@possible_column_combinations[col_j][0][row_i], row_i, @possible_column_combinations[col_j])
          @grid[row_i][col_j] = @possible_column_combinations[col_j][0][row_i]
          @possible_row_combinations = filter_possible_combinations(@possible_row_combinations, row_i, col_j, @grid[row_i][col_j])
          @possible_column_combinations = filter_possible_combinations(@possible_column_combinations, col_j, row_i, @grid[row_i][col_j])
          @possible_row_combinations = cross_check(@possible_row_combinations, @possible_column_combinations)
          @possible_column_combinations = cross_check(@possible_column_combinations, @possible_row_combinations)
        end
      end
    end

    true
  end

  def guess
    @grid.each_with_index do |row, row_i|
      next unless row.include?(0)

      @possible_row_combinations[row_i].each do |combination|
        tmp_grid = @grid.map(&:clone)
        tmp_grid[row_i] = combination

        new_possible_row_combinations = @possible_row_combinations.map(&:clone)
        new_possible_row_combinations[row_i] = [combination]

        sky_instans = Skyscrapers.new(
          clues: @clues,
          grid: tmp_grid,
          all_possible_combinations: @all_possible_combinations,
          possible_row_combinations: new_possible_row_combinations,
          possible_column_combinations: @possible_column_combinations.map(&:clone)
        )

        begin
          unless sky_instans.solved?
            @size.times do
              grid_before = sky_instans.grid.dup
              raise unless sky_instans.main_process

              break if grid_before == sky_instans.grid
            end
          end
        rescue
          next
        end

        unless sky_instans.solved?
          next if sky_instans.guess == false
        end

        next unless sky_instans.valid?

        @grid = sky_instans.grid.dup

        return true
      end
    end

    solved? && valid?
  end

  def generate_possible_combinations(deep = 1, previous_values = [])
    possible = []

    ((1..@size).to_a - previous_values).each do |el|
      if deep == @size
        possible << previous_values + [el]
      else
        possible += generate_possible_combinations(deep+1, previous_values + [el])
      end
    end

    possible
  end

  def find_possible_combinations(clue_first, clue_last)
    out = []

    if clue_first.zero? && clue_last.zero?
      out = @all_possible_combinations
    elsif !clue_first.zero? && clue_last.zero?
      @all_possible_combinations.each do |combination|
        if find_clue(*combination) == clue_first
          out << combination
        end
      end
    elsif clue_first.zero? && !clue_last.zero?
      @all_possible_combinations.each do |combination|
        if find_clue(*combination.reverse) == clue_last
          out << combination
        end
      end
    else
      @all_possible_combinations.each do |combination|
        if find_clue(*combination) == clue_first && find_clue(*combination.reverse) == clue_last
          out << combination
        end
      end
    end

    out
  end

  def find_clue(*values)
    count = 0
    prev_val = 0
    max_val = 0

    values.each do |val|
      next if val == 0

      count += 1 if val > prev_val && val > max_val
      max_val = val if val > max_val
      prev_val = val
    end

    count
  end

  def cross_check(first_combinations, second_combinations)
    out = Array.new(@size, [])
    present_numbers = combinations_to_numbers(second_combinations)

    (0...@size).each do |i|
      out_i = []

      first_combinations[i].each do |first_combination|
        out_j = []

        @size.times do |j|
          out_j << present_numbers[j][i].include?(first_combination[j])
        end

        out_i << first_combination if out_j.count(true) == @size
      end

      out[i] = out_i
    end

    out
  end

  # checking if all combinations has the same value in specific column
  def check_element(possible_value, index_value, combinations)
    combinations.each do |combination|
      return false unless combination[index_value] == possible_value
    end

    true
  end

  def filter_possible_combinations(combinations, row_i, col_j, element)
    out = Array.new(@size, [])

    (0...@size).each do |index|
      if index == row_i
        out[index] = combinations[index].select { |el| el[col_j] == element }
      else
        out[index] = combinations[index].select { |el| el[col_j] != element }
      end
    end

    out
  end

  def solved?
    !@grid.flatten.include?(0)
  end

  def valid?
    @grid.each_with_index do |row, row_i|
      return false if row.include?(0)
      return false unless row.detect { |e| row.count(e) > 1 }.nil?
      return false if @clue_row_set[row_i][0] > 0 && @clue_row_set[row_i][0] != find_clue(*row)
      return false if @clue_row_set[row_i][1] > 0 && @clue_row_set[row_i][1] != find_clue(*row.reverse)
    end

    grid_as_columns.each_with_index do |col, col_j|
      return false if col.include?(0)
      return false unless col.detect { |e| col.count(e) > 1 }.nil?
      return false if @clue_column_set[col_j][0] > 0 && @clue_column_set[col_j][0] != find_clue(*col)
      return false if @clue_column_set[col_j][1] > 0 && @clue_column_set[col_j][1] != find_clue(*col.reverse)
    end

    true
  end

  def grid_as_columns
    @grid.transpose
  end

  def combinations_to_numbers(combinations)
    present_numbers = []

    (0...@size).each do |i|
      present_numbers_i = Array.new(@size) { Array.new }

      combinations[i].each do |combination|
        combination.each_with_index do |number, j|
          present_numbers_i[j] << number
        end
      end

      present_numbers << present_numbers_i.map(&:uniq)
    end

    present_numbers
  end
end
