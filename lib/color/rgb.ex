defmodule Color.RGB do

  # Convert CMY to RGB:
  def convert( %{ type: :cmy } = image) do
    %{ image | pixels: Enum.map(image.pixels, fn([c, m, y]) ->
      # We do y m c to flip it back to b g r:
      rgb = Enum.map([y, m, c], fn(channel) -> 1 - channel end)
      Enum.map(rgb, fn(channel) -> round(255 * channel) end)
    end), type: :rgb }
  end

  def normalize( %{ type: :rgb } = image) do
    %{ image | pixels: Enum.map(image.pixels, fn(pixel) ->
      
    end)}
  end
end
