require 'test_helper'

class AssignmentPolicyTest < ActiveSupport::TestCase
  setup do
    @admin = users(:ltc_fish)
    @clerk = users(:t5_dingo)
    @rifleman = users(:pvt_antelope)
    @assignment_ap1s1 = assignments(:pvt_antelope_ap1s1)
    @assignment_ap2s1 = assignments(:pvt_emu_ap2s1)
  end

  test "rifleman" do
    assert_permit @rifleman, :assignment, :index
    assert_permit @rifleman, @assignment_ap1s1, :show
    refute_permit @rifleman, :assignment, :new
    refute_permit @rifleman, @assignment_ap1s1, :create
    refute_permit @rifleman, @assignment_ap1s1, :update
    refute_permit @rifleman, @assignment_ap1s1, :destroy
  end

  test "platoon clerk" do
    assert_permit @clerk, :assignment, :new
    assert_permit @clerk, @assignment_ap1s1, :create
    assert_permit @clerk, @assignment_ap1s1, :update
    assert_permit @clerk, @assignment_ap1s1, :destroy

    refute_permit @clerk, @assignment_ap2s1, :update
    refute_permit @clerk, @assignment_ap2s1, :destroy
  end
end
