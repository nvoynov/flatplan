module Negatives

  # An immutable value object representing the complete technical and creative
  # blueprint of a physical master image file extracted from EXIF/IPTC tags.
  Image = Data.define(
    :filename,     # [String] filename serve for root identifier (e.g., "DP2Q2173")
    :width,        # [Integer, nil] original master width in pixels
    :height,       # [Integer, nil] original master height in pixels
    :captured_at,  # [String, nil] timestamp of the shutter click
    :title,        # [String, nil] embedded IPTC creative name/object title
    :description,  # [String, nil] embedded IPTC caption or text description
    :camera,       # [String, nil] hardware camera model name (e.g., "Sigma dp2 Quattro")
    :lens          # [String, nil] optical lens model description
  ) do
    # You can insert custom helper methods inside this block later if needed,
    # for example, a helper to calculate aspect ratio or format timestamps.
  end
end
