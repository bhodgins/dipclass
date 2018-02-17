defmodule Color do
  
  # Convert CMY to RGB:
  def convert( %{ type: :cmy } = image, :rgb) do
    %{ image | pixels: Enum.map(image.pixels, fn([c, m, y]) ->
      # We do y m c to flip it back to b g r:
      rgb = Enum.map([y, m, c], fn(channel) -> 1 - channel end)
      Enum.map(rgb, fn(channel) -> round(255 * channel) end)
    end), type: :rgb }
  end

  # Convert RGB to CMY:
  def convert( %{ type: :rgb } = image, :cmy) do
    %{ image | pixels: Enum.map(image.pixels, fn([b, g, r]) ->
      r = r / (r + g + b)
      g = g / (r + g + b)
      b = b / (r + g + b)

      Enum.map([b, g, r], fn(channel) -> 1 - channel end)
    end), type: :cmy }
  end

  # Convert RGB to HSI:
  def convert( %{ type: :rgb } = image, :hsi ) do
    %{ image | pixels: Enum.map(image.pixels, fn( [b, g, r]) ->

      # Normalization (Convert RGB space to HSI space):
      r = r / (r + g + b)
      g = g / (r + g + b)
      b = b / (r + g + b)

      theta = :math.acos( 0.5 * ((r - g) + (r - b)) /
      :math.sqrt(:math.pow(r - g, 2) + (r-b)*(g-b)) )

      hue = cond do
        b <= g -> theta
        b  > g -> 2 * :math.pi - theta
      end

      intensity  = (b + g + r) / 3
      saturation = Enum.min([b, g, r]) / intensity

     [hue, saturation, intensity]
   end), type: :hsi }
  end
end
