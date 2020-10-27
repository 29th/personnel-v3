class NotePolicy < ApplicationPolicy
  def self.permission_map
    write = {
      members_only: -> user {
        user.has_permission?('note_view_sq') ||
        user.has_permission?('note_view_pl') ||
        user.has_permission?('note_view_co') ||
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      },
      squad_level: -> user {
        user.has_permission?('note_view_sq') ||
        user.has_permission?('note_view_pl') ||
        user.has_permission?('note_view_co') ||
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      },
      platoon_level: -> user {
        user.has_permission?('note_view_pl') ||
        user.has_permission?('note_view_co') ||
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      },
      company_level: -> user {
        user.has_permission?('note_view_co') ||
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      },
      military_police: -> user {
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      },
      lighthouse: -> user {
        user.has_permission?('note_view_lh') ||
        user.has_permission?('note_view_mp') ||
        user.has_permission?('admin')
      }
    }

    read = write.clone
    read[:members_only] = -> user { user.member? }

    { read: read, write: write }
  end

  class Scope < Scope
    def resolve
      permitted_access_levels = []

      NotePolicy.permission_map[:read].map do |access_level, fn|
        if fn.call(user)
          permitted_access_levels.append(access_level)
        end
      end

      scope.by_access(permitted_access_levels.to_set)
    end
  end

  def index?
    user.member?
  end

  def show?
    self.class.permission_map[:read][record.access.to_sym]&.call(user)
  end

  def create?
    self.class.permission_map[:write][record.access.to_sym]&.call(user) &&
    user != record.user
  end

  def update?
    self.class.permission_map[:write][record.access.to_sym]&.call(user) &&
    (user == record.author || user&.has_permission?('admin'))
  end

  def destroy?
    user and user.has_permission?('admin')
  end
end
