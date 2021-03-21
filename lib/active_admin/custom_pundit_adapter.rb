module ActiveAdmin
  # Differentiate between new? and create?
  class CustomPunditAdapter < PunditAdapter
    def format_action(action, subject)
      if action == Auth::CREATE && (subject.is_a?(Class) || !subject.changed?)
        :new?
      else
        super(action, subject)
      end
    end
  end
end
