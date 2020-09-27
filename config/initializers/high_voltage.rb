HighVoltage.configure do |config|
  # Use top-level routes for high_voltage
  # e.g. 29th.org/about instead of 29th.org/pages/about
  config.route_drawer = HighVoltage::RouteDrawers::Root
  config.layout = 'about'
end
