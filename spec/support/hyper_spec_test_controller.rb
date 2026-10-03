# Lets hyper-spec's `mount` helper render a single Hyperstack component on a
# minimal page, independent of this app's real routes/controllers. Defined
# here (not app/controllers/) so it only exists for RSpec runs.
#
# Rails 8 loads routes lazily (Rails::Engine::LazyRouteSet) in test. The
# include below clears and redraws the route set, and its own `routes.draw`
# call would trigger that lazy load mid-way, which re-enables clear-on-draw
# and leaves neither the app's routes nor the hyper_spec route defined
# (every request 404s). Loading the routes first keeps its redraw intact.
Rails.application.reload_routes_unless_loaded

class HyperSpecTestController < ApplicationController
  include HyperSpec::Internal::RailsControllerHelpers
end
