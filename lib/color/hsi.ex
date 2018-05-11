defmodule Color.HSI do

  # Convert RGB to HSI:
  def convert( %{ type: :rgb } = image) do

    # A normalized image is required:
    normalized = Color.normalize(image)

    %{ normalized | pixels: Enum.map(normalized.pixels, fn [b, g, r] = pixel ->

      # Theta calculation:
      num = (( (r - g) + (r - b) ) / 2)
      den = :math.sqrt(:math.pow(r - g, 2) + (r - b) * (g - b))

      hue = cond do
        den == 0 ->       0
        b   <= g ->       (:math.acos(num / den) * 180) / :math.pi
        b    > g -> 360 - (:math.acos(num / den) * 180) / :math.pi
      end

      intensity  = (b + g + r) / 3
      saturation = 1 - (3 / (r + g + b) * Enum.min(pixel))

     [hue, saturation, intensity]
   end), type: :hsi }
  end
end
