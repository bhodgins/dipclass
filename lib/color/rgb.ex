defmodule Color.RGB do

  # Convert CMY to RGB:
  def convert( %{ type: :cmy } = image) do
    %{ image | pixels: Enum.map(image.pixels, fn([c, m, y]) ->
      # We do y m c to flip it back to b g r:
      rgb = Enum.map([y, m, c], fn(channel) -> 1 - channel end)
      Enum.map(rgb, fn(channel) -> round(255 * channel) end)
    end), type: :rgb }
  end

  def convert( %{ type: :hsi} = image) do
    %{ image | pixels: Enum.map(image.pixels, fn [h, s, i] ->
      cond do
        h >= 0 && h < 120 ->
          b = i * (1 - s)
          r = i * (1 +
              (s * :math.cos(h))
            / (:math.cos(60 - h))
          )
          g = 3 * i - (r + b)

          [b, g, r]

        h >= 120 && h < 240 ->
          h = h - 120
          r = i * (1 - s)
          g = i * (1 +
              (s * :math.cos(h))
            / (:math.cos(60 - h))
          )
          b = 3 * i - (r + g)

          [b, g, r]

        h >= 240 && h <= 360 ->
          h = h - 240
          g = i * (1 - s)
          b = i * (1 +
              (s * :math.cos(h))
            / (:math.cos(60 - h))
          )
          r = 3 * i - (g + b)

          [b, g, r]
      end
    end), type: :rgb} |> Color.RGB.standardize
  end

  #def normalize( %{ type: :rgb } = image) do
  #  %{ image | pixels: Enum.map(image.pixels, fn [b, g, r] = pixel ->
  #    Enum.map(pixel, fn channel -> channel / (b + g + r) end)
  #  end)}
  #end

  def normalize( %{ type: :rgb } = image) do
    %{ image | pixels: Enum.map(image.pixels, fn pixel ->
      Enum.map(pixel, fn channel -> channel / 255 end)
    end)}
  end

  def standardize( %{ type: :rgb } = image) do
    %{ image | pixels: Enum.map(image.pixels, fn pixel ->
      Enum.map(pixel, fn channel -> Kernel.trunc(255 * channel) end)
    end)}
  end

  def threshold( %{ type: :rgb} = image, [b2, g2, r2] = rel, thres) do
    %{ image | pixels: Enum.map(image.pixels, fn([b1, g1, r1]) ->
      if :math.sqrt(:math.pow(b2 - b1, 2) + :math.pow(g2 - g1, 2) + :math.pow(r2 - r1, 2)) <= thres do
        [255, 255, 255]
      else
        [0, 0, 0]
      end
    end) }
  end
end



#  m = Enum.reduce(img.pixels, {%{}, 0}, fn pixel, {acc, index} ->
#        x = Kernel.trunc(rem(index, img.width))
#        y = Kernel.trunc(index / img.width)
#
#        {IO.inspect{x, y}}
#
#        {
#          Map.put(acc, {x, y}, pixel ),
#          index + 1
#        }
#      end) |> elem(0)
