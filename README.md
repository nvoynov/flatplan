% FLATPLAN

# Summary

`Flatplan` treats a photographic story as a musical composition. It balances imagery, text, and empty space ("visual silence") into a structured, flat publication blueprint.

**Installation**

    bin/install

**Usage**

1. Create story manifest
   `flatplan init <path_to_image_folder>`
2. Run preview
   `flatplan preview <manifest_file> --watch`
3. Edit manifest file and see live-preview

# Web manifest

Publication manifest provides with tree basic blocks with the block medium rules

## Text

Text blocks

```
# Text
alignment: left/center/right # the text alignment directive
width_category: narrow/normal/wide # the container width category

The text block
```

## Media

Media blocks

```
# Media
size: standard/large # the visual scale of the asset on the page

![](path_to_an_image)
captured_at: time string
alt: alt text
caption: catption text
title: title text
kairos_keyword_hint: kairos hint based on publication keywords and captured at
```

## MediaAssets

Media assets collection presented as media grid

```
# MediaAssets
columns: 1/2/3              # the number of layout columns in the grid row
aspect_mode: natural/square # the crop or aspect ratio mode for the grid items
```

## TextAndMedia

Combination of Text and MediaAssetes blocks

```
# TextAndMedia    
text_position: left/right # the horizontal position of the text column
flow: true/false          # whether the media grid should flow beneath the text column

Some optinal text


![](image1)
captured_at:
alt:

![](image2)
captured_at:
alt:
```
