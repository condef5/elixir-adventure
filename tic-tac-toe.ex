defmodule TicTacToe do
  
  def start(level \\ 2) do
    board = List.duplicate(0, trunc(:math.pow(level, 2)))
    result = stage(board, level)
    cond do
      level > 9 -> IO.puts "End the game"
      result == 1 -> 
        :timer.sleep(1500);
        start(level + 1)
      true ->
        :timer.sleep(1500);
        start(level)
    end
  end

  def stage(board, level, user \\ true) do
    clear()
    cond do
      who_winner?(board, level, 1) ->
        draw_game(board, level)
        IO.puts "You won man, enjoy it 😀"
        1
      who_winner?(board, level, -1) ->
        draw_game(board, level) 
        IO.puts "You just lost with a machine 😀"
        -1
      end_game?(board) ->
        draw_game(board, level)
        IO.puts "Tie 🎌"
        0
      user -> 
        draw_game(board, level)
        pos = enter(board)
        List.replace_at(board, pos, 1) 
        |> stage(level, false)
      true ->
        List.replace_at(board, turn_machine(board), -1) 
        |> stage(level, true)
    end
  end

  def draw_game(board, level) do
    IO.puts "Level #{level} \n"
    board
    |> Enum.chunk_every(level)
    |> Enum.with_index
    |> Enum.each(fn(x) -> draw_row(x, level) end)
    IO.puts ""
  end

  def draw_row({num, index}, level) do
    num
    |> Enum.with_index
    |> Enum.reduce("", fn {item, idx}, acc ->
        acc
        <> cond do
            item == -1 -> " o "
            item == 1 -> " x "
            true -> " " <> Integer.to_string(index * level + idx) <> " " |> String.slice(0..2)
          end
        <> (idx < level - 1 && " |" || "")
      end)
    |> IO.puts()
    if index < level - 1, do: IO.puts String.duplicate("-", level * 4 + level - 1)
  end
  
  def enter(board) do
    pos = IO.gets("You turn, pick the pos: ") 
      |> String.trim() 
      |> String.to_integer
    if !validate(board, pos) do
      enter(board)
    end
    pos
  end

  def validate(board, idx) do
    cond do
      Enum.at(board, idx) == 0 -> true
      true ->
        IO.puts "Enter a correct position"
        false
    end
  end

  def turn_machine(board) do
    board
    |> Enum.with_index
    |> Enum.reduce([], fn({ item, idx }, acc) ->
        if (item == 0), do: [idx | acc], else: acc
       end)
    |> Enum.shuffle
    |> hd
  end

  def end_game?(board) do
    !Enum.any?(board, fn item -> item == 0 end)
  end

  def who_winner?(board, level, brand) do
    level
    |> win_conditions?()
    |> Enum.any?(fn(opt) -> Enum.empty?(opt -- moves(board, brand)) end)
  end

  def win_conditions?(level) do
    winner_hor = 0..trunc(:math.pow(level, 2) - 1) 
      |> Enum.to_list 
      |> Enum.chunk_every(level)
    diag_main = winner_hor 
      |> Enum.with_index 
      |> Enum.map(fn({ item, idx }) -> Enum.at(item, idx) end) 
    diag_sec = winner_hor 
      |> Enum.with_index 
      |> Enum.map(fn({ item, idx }) -> Enum.at(item, level - (idx + 1)) end)
    winner_hor ++ reverse(winner_hor) ++ [diag_main, diag_sec]
  end

  def moves(board, brand) do
    board
    |> Enum.with_index
    |> Enum.reduce([], fn({ item, idx }, acc) ->
        if (item == brand), do: [idx | acc], else: acc
       end)
  end

  def reverse(matriz) do
    matriz 
    |> List.zip 
    |> Enum.map(&Tuple.to_list/1)
  end

  def clear do
    IO.write [IO.ANSI.home, IO.ANSI.clear]; IEx.dont_display_result
  end

end

TicTacToe.start