class Audiogram < ActiveRecord::Base
  belongs_to :patient
  belomgs_to :examiner
end
