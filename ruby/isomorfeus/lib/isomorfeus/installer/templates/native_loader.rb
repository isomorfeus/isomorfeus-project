require 'opal'
require 'isomorfeus-redux'
require 'isomorfeus-react-native'
require 'isomorfeus-react'
require 'isomorfeus-policy'
require 'isomorfeus-transport'
require 'isomorfeus-data'
require 'isomorfeus-i18n'
require 'isomorfeus-operation'

require_tree 'policies', :autoload
require_tree 'channels', :autoload
require_tree 'data', :autoload
require_tree 'operations', :autoload
require_tree 'components', :autoload

Isomorfeus.zeitwerk.setup
