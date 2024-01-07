module EnlistmentsHelper
  def error_tag(err)
    Appsignal.set_error(err)
    tag.span("Error", class: "inline-error", title: err.message,
      "data-toggle": "tooltip", "data-controller": "tooltip")
  end
end
