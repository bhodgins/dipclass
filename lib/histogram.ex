defmodule Histogram do

  def generate(image), do: generate(image.pixels, :grayscale)
  def generate(image, :grayscale) do

    Enum.reduce(image, Map.new(0..255, &{&1, 0}), fn([r, _, _], histogram) ->
    Map.put(histogram, r, Map.get(histogram, r, 0) + 1) end)
  end

  def integrate(histogram) do
    histogram
    |> Enum.sort
    |> Enum.reduce({0,%{}}, fn {index, value}, {prev, acc} ->
      {prev + value, Map.put(acc, index, prev + value)}
    end)
    |> elem(1)

    # Scale the results:
    |> Enum.into([])
    |> Enum.reduce(%{}, fn {index, value}, acc ->
      Map.put(acc, index, Kernel.trunc((255 * value) / (640 * 480)) )
    end)
  end

  def equalize(image, integral) do
    %{ image | pixels: Enum.map(image.pixels, fn(pixel) ->
      Enum.map(pixel, fn(channel) ->
        Kernel.trunc(Map.get(integral, channel)) end)
    end)}
  end
end
