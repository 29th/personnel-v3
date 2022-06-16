require "test_helper"

class NotePolicyTest < ActiveSupport::TestCase
  def scope(user)
    NotePolicy::Scope.new(user, Note.all).resolve
  end

  test "scope for user who is not a member includes no notes" do
    user = create(:user)
    note = create(:note)
    assert scope(user).length, 0
  end

  test "scope for user with no note_view_* permission only includes members_only notes" do
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

  test "scope for user with note_view_pl includes members_only, squad_level, and platoon_level notes, but not company_level" do
    unit = create(:unit)
    user = create(:user)
    create(:assignment, user: user, unit: unit)

    create(:note, access: :members_only)
    create(:note, access: :squad_level)
    create(:note, access: :platoon_level)
    company_level_note = create(:note, access: :company_level)

    notes = scope(user)
    assert notes.length, 3
    refute notes.include? company_level_note
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

  test "show permits user with note_view_pl on squad_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_pl", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :squad_level)
    assert_permit user, note, :show
  end

  test "show denies user with note_view_pl on company_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_pl", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :company_level)
    refute_permit user, note, :show
  end

  test "create permits user with note_view_sq on squad_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_sq", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :squad_level)
    assert_permit user, note, :create
  end

  test "create denies user with note_view_sq on platoon_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_sq", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level)
    refute_permit user, note, :create
  end

  test "create denies user acting on self" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_sq", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :squad_level, user: user)
    refute_permit user, note, :create
  end

  test "update permits original author with note_view_pl on platoon_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_pl", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level, author: user)
    assert_permit user, note, :create
  end

  test "update denies user who is not original author" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_pl", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level)
    refute_permit user, note, :update
  end

  test "update denies original author with note_view_sq on platoon_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_sq", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level, author: user)
    refute_permit user, note, :update
  end

  test "update permits original author with note_view_co on platoon_level note" do
    unit = create(:unit)
    create(:permission, abbr: "note_view_co", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level, author: user)
    assert_permit user, note, :update
  end

  test "create/update denies user without note_view_* permission on members_only note" do
    unit = create(:unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :members_only)
    refute_permit user, note, :create
    refute_permit user, note, :update
  end

  test "update permits user who is not original author but has admin" do
    unit = create(:unit)
    create(:permission, abbr: "admin", unit: unit)

    user = create(:user)
    create(:assignment, user: user, unit: unit)

    note = create(:note, access: :platoon_level)
    assert_permit user, note, :update
  end
end
