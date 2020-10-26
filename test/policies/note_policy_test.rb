require 'test_helper'

class NotePolicyTest < ActiveSupport::TestCase
  def scope(user)
    NotePolicy::Scope.new(user, Note.all).resolve
  end

  test "non-member scope has no notes" do
    user = create(:user)
    note = create(:note)
    assert scope(user).length, 0
  end

  test "member scope only contains member notes" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)

    members_only_note = create(:note, access: :members_only)
    create(:note, access: :squad_level)
    create(:note, access: :platoon_level)
    create(:note, access: :lighthouse)

    notes = scope(user)
    assert notes.length, 1
    assert notes.include? members_only_note
  end

  test "show denies non-member" do
    user = create(:user)
    note = create(:note, access: :members_only)
    refute_permit user, note, :show
  end

  test "show permits member on members_only note" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)
    note = create(:note, access: :members_only)
    assert_permit user, note, :show
  end
end
