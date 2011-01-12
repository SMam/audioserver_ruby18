class Examiner < ActiveRecord::Base
  has_many :audiograms
  has_many :patients, :through => :audiograms
end
