% Flatplan

# CLI

`init`

`design`

Есть ли смысл делать уровнеь комманд для чтения/инициалиации? Нужны две вещи

1) прочесть кталог иображений и соэдать файл манифеста, 
2) прочесть файл манфеста и содать объект

это сервисы/комманды?

содание это команда
чтение это билдер, но он всегда в контексте чего-то другого
- соэдать объект и сериалиэовать для АПИ
- принять сериалиэацию, содать объект э

может все это слой прложения НЕ домена?

command
command/initialize_story.rb
command/load_maifest.rb
command/make_pandoc.rb


# Designer

Web app for manifests design and preview.

Two main components here

1. Live preview
2. Inspector

## Live preview

Renders live manifest in browser, highlighting sections and individual components such as texts, image assets, images, spreads, etc. User have options to add new, change, and remove an individual blok's atoms and the whole block.

- add/remove section
- move section top/bottom
- add/remove section image (drqg-and-drop from/to iamge pool of whole imgae assets)
- add/remove section text

## Media Pool

of all manifest media assets

## Inspector

provides properties inspector for content block seelcted in Preview the ability to change content components properties such as alignment, text position, grid columns, etc.
