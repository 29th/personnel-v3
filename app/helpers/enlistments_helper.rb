module EnlistmentsHelper
  def error_tag(err)
    Appsignal.set_error(err)
    tag.span("Error", class: "inline-error", title: err.message,
      "data-toggle": "tooltip", "data-controller": "tooltip")
  end

  def timezone_opts
    [
      ["7pm EST (Midnight GMT)", "est"],
      ["6pm PST (2am GMT)", "pst"],
      ["2pm EST (7pm GMT)", "gmt"],
      ["Any", "any_timezone"]
    ]
  end

  def game_opts
    [
      ["Arma 3", "arma3"],
      ["Rising Storm 2: Vietnam", "rs2"],
      ["Squad", "squad"]
    ]
  end

  def previous_unit_game_opts
    [
      ["Arma 2", "Arma 2"],
      ["Arma 3", "Arma 3"],
      ["Darkest Hour", "DH"],
      ["Day of Defeat", "DOD"],
      ["Day of Defeat: Source", "DODS"],
      ["Red Orchestra", "RO"],
      ["Red Orchestra 2", "RO2"],
      ["Rising Storm", "RS"],
      ["Rising Storm 2: Vietnam", "RS2"],
      ["Squad", "SQ"]
    ]
  end
end
