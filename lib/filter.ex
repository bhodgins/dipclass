defmodule Filter do
  use Bitwise

  def invert(image), do: %{ image | pixels: Enum.map(image.pixels, fn([b, g, r]) ->
      [b ^^^ 0xff, g ^^^ 0xff, r ^^^ 0xff]  end) }

  def grayscale(image), do: grayscale(image, :average)
  def grayscale(image, :average) do
    %{ image | pixels: Enum.map(image.pixels, fn([b, g, r]) ->
      pval = round((b + g + r) / 3)
      [pval, pval, pval]
    end) }
  end

  def histogram_eq(image) do
    integrated = image
    |> Histogram.generate
    |> Histogram.integrate

    image |> Histogram.equalize(integrated)
  end

  # cfilter prototype header:
  def color_channel(image, channel, mask \\ 0xff)

  # Single channel RGB:red filtering:
  def rgb_channel( %{ type: :rgb } = image, :red, mask) do
    %{ image | pixels: Enum.map(image.pixels, fn([_, _, r]) ->
      [ 0, 0,  r &&& mask ]
    end)}
  end

  # Single channel RGB:blue filtering:
  def rgb_channel( %{ type: :rgb } = image, :blue, mask) do
    %{ image | pixels: Enum.map(image.pixels, fn([b, _, _]) ->
      [ b &&& mask, 0, 0 ]
    end) }
  end

  # Single channel RGB:blue filtering:
  def rgb_channel( %{ type: :rgb } = image, :green, mask) do
    %{ image | pixels: Enum.map(image.pixels, fn([_, g, _]) ->
      [ 0, g &&& mask, 0 ]
    end) }
  end
end
