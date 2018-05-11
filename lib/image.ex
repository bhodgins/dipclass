defmodule Image do
  defstruct header: [], pixels: [], type: nil, filename: nil, width: 0, height: 0

  use Bitwise

  @doc ~S"""
  Reads a Bitmap (24-bit) and displays width, height, and the RGB of each pixel
  """

  # This one function I did not write (But I did modify); It is a pattern
  # matching feature of Elixir grabbed from somebody's example for BMP data
  # loading.
  def load(filename) do
    {:ok, bindata} = File.read(filename)
    <<  "BM",
      _::size(64),
      offset_to_pixels::size(32)-little,
      _::size(32),
      width::size(32)-little,
      height::size(32)-little,
      _::size(16),
      24::size(16)-little,
      _rest::binary>> = bindata

    IO.inspect(bindata)

    <<hdata::size(offset_to_pixels)-bytes, pixels::binary>> = bindata
    IO.puts "Offset:#{offset_to_pixels} Width:#{width} Height:#{height}"

    imgdata = for <<b::size(8), g::size(8), r::size(8) <- pixels >>, do: [b, g, r]
    hret = for <<n::size(8) <- hdata>>, do: n

    %Image{ header: hret, pixels: imgdata, type: :rgb, filename: filename, width: width, height: height }
  end

  def dfilter(image, mask \\ 0xff) do
    %{ image | pixels: Enum.map(image.pixels, fn(pixel) ->
      Enum.map(pixel, fn(channel) -> channel &&& mask  end)
    end) }
  end

  def subtract(image1, image2) do
    %{ image2 | pixels:
      Enum.zip(image1.pixels, image2.pixels) |> Enum.map( fn(pair) ->
      [
        Enum.at( elem(pair, 0), 0 ) - Enum.at( elem(pair, 1), 0 ),
        Enum.at( elem(pair, 0), 1 ) - Enum.at( elem(pair, 1), 1 ),
        Enum.at( elem(pair, 0), 2 ) - Enum.at( elem(pair, 1), 2 )
      ]
    end) }
  end

  def cflat(image, color_pos, color_neg) do
    %{ image | pixels: Enum.map(image.pixels, fn(pixel) ->
      if Enum.max(pixel) > 0 do color_pos else
        [color_neg, color_neg, color_neg] end
    end) }
  end

  def get_neighbors(image, image_map, {x, y}) do

      w  = image.width
      h  = image.height
      e  = w * h

      u  = y - 1
      d  = y + 1
      l  = x - 1
      r  = x + 1

      ul = if l >= 0 and u >= 0, do: {l, u}, else: nil
      uu = if u >= 0,           do: {x, u}, else:  nil
      ur = if r < w and u >= 0, do: {r, u}, else:  nil
      ll = if l >= 0,           do: {l, y}, else:  nil
      cc = {x, y}
      rr = if r < w,           do: {r, y}, else:   nil
      dl = if l >= 0 and d < h, do: {l, d}, else:  nil
      dd = if d < h,           do: {x, d}, else:   nil
      dr = if r < w and d < h, do: {r, d}, else:   nil

      Enum.map([
        ul, uu, ur,
        ll, cc, rr,
        dl, dd, dr
      ], fn coord ->
        px = Map.get(image_map, coord)
        if px == nil do
          [0, 0, 0]
        else
          px
        end
    end)
  end

  # Image.load("out.bmp") |> Convolution.perform(Convolution.sharpen())

  # Convert a position of a list into x, y coordinates:
  def pos2xy(image, pos) do
    {Kernel.trunc(rem(pos, image.height)),  Kernel.trunc(:math.floor(pos / image.width))}
  end

  def display(image) do
    tmpfile = image.filename <> ".tmp"
    image |> save(tmpfile)
    System.cmd("xv", [tmpfile])
    System.cmd("rm", [tmpfile])
  end

  def invert_colors(image) do
    image
    |> image_map_flatten( fn([r, g, b]) -> [b ^^^ 0xff, g ^^^ 0xff, r ^^^ 0xff] end )
  end

  def average_gs(image) do
    image
    |> image_map_flatten( fn([r, g, b]) -> [
      round((b + g + r) / 3),
      round((b + g + r) / 3),
      round((b + g + r) / 3)
      ] end )
  end

  def image_map_flatten(image, func) do
    {header, imgdata} = image

    # Really just a helper function:
    mapped = Enum.flat_map(imgdata, func)
    [ header | mapped ]
  end

  def save(image, filename) do
      {:ok, fh} = File.open filename, [:write]
      IO.binwrite fh, [ image.header | image.pixels |> List.flatten ]
      File.close(fh)

      filename
  end

  def create_map (img) do
    Enum.reduce(img.pixels, {%{}, 0}, fn pixel, {acc, index} ->
      x = Kernel.trunc(rem(index, img.width))
      y = Kernel.trunc(index / img.width)

      {
        Map.put(acc, {x, y}, pixel ),
        index + 1
      }
    end) |> elem(0)
  end
end

defmodule InvertImage do
@magic_reduction_number 20000
@mask :binary.copy(<<255>>, @magic_reduction_number)

def invert(binary), do: do_exor(binary, [])

defp do_exor("", acc), do: acc

defp do_exor(data, acc) when byte_size(data) < @magic_reduction_number,
  do: [acc | :crypto.exor(data, :binary.copy(<<255>>, byte_size(data)))]

defp do_exor(<<data::binary-size(20000), rest::binary>>, acc),
  do: do_exor(rest, [acc | :crypto.exor(data, @mask)])
end
