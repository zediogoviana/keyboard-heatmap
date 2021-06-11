defmodule Painter do
  import Mogrify

  @key_size 90

  def perform(frequencies, keyboard) do
    base_image = draw_base_image(keyboard)

    keyboard
    |> Enum.with_index()
    |> draw_keyboard(base_image, frequencies)
    |> create(path: ".")
  end

  defp draw_keyboard([], image, _frequencies), do: image

  defp draw_keyboard([next_row | keyboard], image, frequencies) do
    {row, yy_position} = next_row

    new_image = draw_row(row, 0, yy_position, image, frequencies)

    draw_keyboard(keyboard, new_image, frequencies)
  end

  defp draw_row([], _xx_position, _yy_position, image, _frequencies), do: image

  # if it's white space, just advance the position pointer
  defp draw_row([%{white_space: true} = key | row], xx_position, yy_position, image, frequencies) do
    xx_shift = key_width(key) + xx_position

    draw_row(row, xx_shift, yy_position, image, frequencies)
  end

  defp draw_row([key | row], xx_position, yy_position, image, frequencies) do
    new_image = draw_key(key, xx_position, yy_position, image, frequencies)
    xx_shift = key_width(key) + xx_position

    draw_row(row, xx_shift, yy_position, new_image, frequencies)
  end

  defp draw_key(key, xx_position, yy_position, image, frequencies) do
    freq = frequencies[to_string(key.keycode)] || 0

    {red, green, blue} = get_rgb_color(freq)

    image
    |> custom("fill", "rgb(#{red},#{green},#{blue})")
    |> rounded_rectangle(
      xx_position * @key_size + 10,
      yy_position * @key_size + 10,
      xx_position * @key_size + @key_size * key_width(key),
      yy_position * @key_size + @key_size * key_height(key),
      10,
      10
    )
    |> custom("fill", "white")
    |> Mogrify.Draw.text(
      xx_position * @key_size + 45,
      yy_position * @key_size + 45,
      key.name
    )
  end

  defp draw_base_image(keyboard) do
    keyboard_width = length(Enum.at(keyboard, 0))
    keyboard_height = length(keyboard)

    %Mogrify.Image{path: "heatmap.png", ext: "png"}
    |> custom("size", "#{95 * keyboard_width}x#{95 * keyboard_height}")
    |> canvas("white")
  end

  defp rounded_rectangle(
         image,
         upper_left_x,
         upper_left_y,
         lower_right_x,
         lower_right_y,
         border_w,
         border_h
       ) do
    image
    |> custom(
      "draw",
      "roundRectangle #{to_string(:io_lib.format("~g,~g ~g,~g ~g,~g", [upper_left_x / 1, upper_left_y / 1, lower_right_x / 1, lower_right_y / 1, border_w / 1, border_h / 1]))}"
    )
  end

  defp get_rgb_color(0) do
    {185, 185, 185}
  end

  defp get_rgb_color(freq) do
    {
      min(255, 200 * freq * 2 + 45),
      max(0, 100 - 100 * freq * 2),
      max(0, 150 - 245 * freq * 2)
    }
  end

  defp key_width(%{size: size}) do
    size
  end

  defp key_width(%{width: width}) do
    width
  end

  defp key_height(%{size: _size}) do
    1
  end

  defp key_height(%{height: height}) do
    height
  end
end
