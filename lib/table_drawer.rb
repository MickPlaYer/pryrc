# frozen_string_literal: true

$LOAD_PATH << "#{Gem.path[0]}/gems/unicode-display_width-1.6.1/lib"
require 'unicode/display_width'
require 'matrix'

class TableDrawer # :nodoc:
  DEFAULT_SPACE = 4

  def initialize(mysql_result, options = {})
    @matrix = Matrix[mysql_result.fields, *mysql_result.map { |e| e.map(&:ai) }]
    @width = ENV['COLUMNS'].to_i
    @break_columns = []
    @column_width = {}
    @identity_width = 0
    @options = options
  end

  def draw
    check_identity
    count_column_width
    draw_by_parts
    nil
  end

  private

  def check_identity
    index = @matrix.row(0).to_a.index { |e| e == 'id' }
    return if index.nil?

    columns = @matrix.column_vectors.to_a
    @identity_column = columns.delete_at(index)
    @matrix = Matrix.columns(columns)
    @identity_width = @identity_column.map do |e|
      find_display_width(e)
    end.max + DEFAULT_SPACE
  end

  def each_column_max_width
    @matrix.column_count.times do |index|
      width = @matrix.column(index).map do |e|
        find_display_width(e)
      end.max
      yield(width, index)
    end
  end

  def count_column_width
    current_width = @identity_width + DEFAULT_SPACE + 2
    each_column_max_width do |width, i|
      @column_width[i] = width
      current_width += (width + 3)
      if current_width + 1 > @width
        @break_columns.push(i - 1, i)
        current_width = @identity_width + DEFAULT_SPACE + 2 + (width + 3)
      end
    end
    @break_columns = [0, *@break_columns, @matrix.column_count]
  end

  def draw_by_parts
    @break_columns.each_slice(2) do |column_start, column_end|
      part = @matrix.minor(0..(@matrix.row_count - 1), column_start..column_end)
      part.to_a.each_with_index do |row, row_index|
        data = row.map.with_index do |e, i|
          column_display_string(e, @column_width[column_start + i])
        end
        row_display_string(data, row_index)
      end
      puts ''
    end
  end

  def column_display_string(string, width)
    " #{fixed_display_width(string, width)} #{'|'.gray}"
  end

  def fixed_display_width(string, width)
    space_count = width - find_display_width(string)
    ' ' * space_count + string
  end

  def row_display_string(data, index)
    follow = if @identity_column
               fixed_display_width(@identity_column[index], @identity_width)
             else
               ' ' * DEFAULT_SPACE
             end
    puts "#{follow} #{'|'.gray}#{data.join}"
  end

  def find_display_width(string)
    Unicode::DisplayWidth.of(string.gsub(/\e\[([;\d]+)?m/, ''))
  end
end
