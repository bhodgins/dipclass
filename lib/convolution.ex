defmodule Convolution do
  @moduledoc """
  A module for performing convolution mask filtering.
  """

  def perform(image, mask) do
    np = image.width * image.height
    image_map = image |> Image.create_map

    %{ image | pixels: Enum.reduce(image.pixels, {[], 0}, fn px, {a, index} ->

      xy      = image |> Image.pos2xy(index)
      kernel  = image |> Image.get_neighbors(image_map, xy)

      # Perform convolution products:
      products = Enum.map(Enum.zip(kernel, mask), fn {pixel, mval} ->
        Enum.map(pixel, fn channel ->
          mval * channel
        end)
      end)

      # Perform convolution sum:
      sum = Enum.reduce(products, [0, 0, 0], fn [b, g, r], [a_b, a_g, a_r] ->
        s_b = b + a_b
        s_g = g + a_g
        s_r = r + a_r

        s_b = if s_b > 255, do: 255
        s_g = if s_g > 255, do: 255
        s_r = if s_r > 255, do: 255

        s_b = if s_b < 0, do: 0
        s_g = if s_g < 0, do: 0
        s_r = if s_r < 0, do: 0

        [s_b, s_g, s_r]
      end)

      {[sum | a], index + 1}
    end) |> elem(0) |> Enum.reverse() }
  end

  # Presets:
  def sharpen() do
    [
      0, -1,  0,
     -1,  5, -1,
      0, -1,  0
    ]
  end

  def blur() do
    [
      0.0625, 0.125, 0.0625,
      0.125,  0.25,  0.125,
      0.0625, 0.125, 0.0625
    ]
  end
end
