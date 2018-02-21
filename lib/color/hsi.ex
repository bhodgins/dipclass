defmodule Color.HSI do

  # Convert RGB to HSI:
  def convert( %{ type: :rgb } = image) do
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
