defmodule Color.CMYK do

  # Convert RGB to CMY:
  def convert( %{ type: :rgb } = image, :cmy) do
    %{ image | pixels: Enum.map(image.pixels, fn([b, g, r]) ->
      r = r / (r + g + b)
      g = g / (r + g + b)
      b = b / (r + g + b)

      Enum.map([b, g, r], fn(channel) -> 1 - channel end)
    end), type: :cmy }
  end

  # Convert RGB to XMYK:
  def convert( %{ type: :rgb } = image, :cmyk) do

  end
end
