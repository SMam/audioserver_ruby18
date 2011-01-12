class Patient < ActiveRecord::Base
  has_many :audiograms
  has_many :examiners, :through => :audiograms
end
