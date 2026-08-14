# Lets hyper-spec's `mount` helper render a single Hyperstack component on a
# minimal page, independent of this app's real routes/controllers. Defined
# here (not app/controllers/) so it only exists for RSpec runs.
class HyperSpecTestController < ApplicationController
  include HyperSpec::Internal::RailsControllerHelpers
end
