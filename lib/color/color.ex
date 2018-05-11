defmodule Color do

  # Conversion stubs for converting between color styles:
  def convert(image, :rgb),  do: Color.RGB.convert(image)
  def convert(image, :hsi),  do: Color.HSI.convert(image)
  def convert(image, :cmy),  do: Color.CMYK.convert(image, :cmy)
  def convert(image, :cmyk), do: Color.CMYK.convert(image, :cmyk)

  # Normalization stubs:
  def normalize(   %{ type: :rgb } = image), do: Color.RGB.normalize(image)

  # Conversion checks:
  def expect(image, type) do
     if image.type == type do
       image
     else
       convert(image, type)
     end
  end
end
