class NotePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      permitted_access_levels = []

      NotePolicy.access_permission_map.map do |access_level, fn|
        if fn.call(user)
          permitted_access_levels.append(access_level)
        end
      end

      scope.for_access(permitted_access_levels.to_set)
    end
  end

  def index?
    user&.member?
  end

  def show?
    access_to_note?(record)
  end

  def new?
    user && (user.has_permission?("note_view_sq") ||
             user.has_permission?("note_view_pl") ||
             user.has_permission?("note_view_co") ||
             user.has_permission?("note_view_mp") ||
             user.has_permission?("admin"))
  end

  def create?
    new? && access_to_note?(record) && user != record.user
  end

  def update?
    create?
  end

  def destroy?
    user&.has_permission?("admin")
  end

  def self.access_permission_map
    {
      members_only: ->(user) { user.member? },
      squad_level: ->(user) {
        user.has_permission?("note_view_sq") ||
          user.has_permission?("note_view_pl") ||
          user.has_permission?("note_view_co") ||
          user.has_permission?("note_view_mp") ||
          user.has_permission?("admin")
      },
      platoon_level: ->(user) {
        user.has_permission?("note_view_pl") ||
          user.has_permission?("note_view_co") ||
          user.has_permission?("note_view_mp") ||
          user.has_permission?("admin")
      },
      company_level: ->(user) {
        user.has_permission?("note_view_co") ||
          user.has_permission?("note_view_mp") ||
          user.has_permission?("admin")
      },
      military_police: ->(user) {
        user.has_permission?("note_view_mp") ||
          user.has_permission?("admin")
      },
      lighthouse: ->(user) {
        user.has_permission?("note_view_lh") ||
          user.has_permission?("note_view_mp") ||
          user.has_permission?("admin")
      }
    }
  end

  private

  def access_to_note?(note)
    access_symbol = note.access&.to_sym
    has_access = self.class.access_permission_map[access_symbol]
    has_access&.call(user)
  end
end
