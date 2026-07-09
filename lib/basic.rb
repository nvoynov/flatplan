require_relative 'basic/callable'
require_relative 'basic/cli_tool'
require_relative 'basic/model'
require_relative 'basic/configuration'

module Basic

  LOREM_IPSUM = <<~LOREM.strip.lines.map(&:strip).join(" ").freeze
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
    non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  LOREM

end
