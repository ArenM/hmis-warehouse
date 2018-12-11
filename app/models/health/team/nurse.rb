# ### HIPPA Risk Assessment
# Risk: Relates to a patient and contains PHI
# Control: PHI attributes documented in base class
module Health
  class Team::Nurse < Team::Member

    def self.member_type_name
      'Nurse Care Manager'
    end
  end
end

