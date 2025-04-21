class MissingAwardCalculator
  include Service

  def initialize(user)
    @user = user
  end

  def call
    # Merge the results of both award calculations
    missing_service_duration_awards.merge(missing_recruitment_awards)
  end

  def missing_service_duration_awards
    service_duration = @user.service_duration

    # Calculate how many awards the user should have based on service duration
    months_of_service = (service_duration.to_i / 1.month).floor
    years_of_service = (service_duration.to_i / 1.year).floor

    # For every 6 months of service, a user should be awarded an Army of Occupation Medal (aocc)
    expected_aocc_count = (months_of_service / 6).floor

    # For every 2 years of service, a user should be awarded a World War I Victory Medal (ww1v)
    expected_ww1v_count = (years_of_service / 2).floor

    # Ignore awards given prior to non-honorable discharge
    discharge = @user.latest_non_honorable_discharge
    relevant_awards = if discharge.present?
      @user.user_awards.select { |ua| (discharge.date..).cover?(ua.date) }
    else
      @user.user_awards
    end

    # Count how many of each award the user already has
    # Filter in memory to avoid N+1 queries
    actual_aocc_count = relevant_awards.count { |ua| ua.award.code == "aocc" }
    actual_ww1v_count = relevant_awards.count { |ua| ua.award.code == "ww1v" }

    # Calculate missing awards
    missing_aocc = [expected_aocc_count - actual_aocc_count, 0].max
    missing_ww1v = [expected_ww1v_count - actual_ww1v_count, 0].max

    {aocc: missing_aocc, ww1v: missing_ww1v}
  end

  def missing_recruitment_awards
    # Ignore enlistments and awards given prior to non-honorable discharge
    discharge = @user.latest_non_honorable_discharge

    # Filter relevant enlistments based on discharge date
    relevant_enlistments = if discharge.present?
      # Filter in memory to avoid N+1 queries
      # Only count enlistments after the discharge date
      @user.accepted_recruited_enlistments.select { |e| e.date >= discharge.date }
    else
      @user.accepted_recruited_enlistments
    end

    # Get the count of accepted enlistments where this user is the recruiter
    recruitment_count = relevant_enlistments.size

    # Calculate how many awards the user should have based on recruitment count
    expected_cab1_count = (recruitment_count >= 2) ? 1 : 0
    expected_cab2_count = (recruitment_count >= 5) ? 1 : 0
    expected_cab3_count = (recruitment_count >= 10) ? 1 : 0
    expected_cab4_count = (recruitment_count >= 20) ? 1 : 0

    # Filter relevant awards based on discharge date
    relevant_awards = if discharge.present?
      @user.user_awards.select { |ua| ua.date >= discharge.date }
    else
      @user.user_awards
    end

    # Count how many of each award the user already has
    # Using preloaded user_awards and filtering in memory to avoid N+1 queries
    actual_cab1_count = relevant_awards.count { |ua| ua.award.code == "cab1" }
    actual_cab2_count = relevant_awards.count { |ua| ua.award.code == "cab2" }
    actual_cab3_count = relevant_awards.count { |ua| ua.award.code == "cab3" }
    actual_cab4_count = relevant_awards.count { |ua| ua.award.code == "cab4" }

    # Calculate missing awards
    missing_cab1 = [expected_cab1_count - actual_cab1_count, 0].max
    missing_cab2 = [expected_cab2_count - actual_cab2_count, 0].max
    missing_cab3 = [expected_cab3_count - actual_cab3_count, 0].max
    missing_cab4 = [expected_cab4_count - actual_cab4_count, 0].max

    {cab1: missing_cab1, cab2: missing_cab2, cab3: missing_cab3, cab4: missing_cab4}
  end
end
