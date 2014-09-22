# Base Activity Objects
require 'nelumba/object'
require 'nelumba/activity'
require 'nelumba/collection'

# Activity Objects
require 'nelumba/article'
require 'nelumba/audio'
require 'nelumba/badge'
require 'nelumba/binary'
require 'nelumba/bookmark'
require 'nelumba/comment'
require 'nelumba/device'
require 'nelumba/event'
require 'nelumba/file'
require 'nelumba/group'
require 'nelumba/image'
require 'nelumba/note'
require 'nelumba/place'
require 'nelumba/question'
require 'nelumba/review'
require 'nelumba/service'
require 'nelumba/video'

# Data Structures
require 'nelumba/feed'
require 'nelumba/person'
require 'nelumba/identity'
require 'nelumba/notification'
require 'nelumba/link'

# Crypto
require 'nelumba/crypto'

# Pub-Sub
require 'nelumba/subscription'
require 'nelumba/publisher'

# This module contains elements that allow federated interaction. It also
# contains methods to construct these objects from external sources.
module Nelumba
  # This module isolates Atom generation.
  module Atom; end
end
