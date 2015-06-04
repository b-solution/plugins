class Periodictask < ActiveRecord::Base
  unloadable
  belongs_to :project
  INTERVAL_UNITS = ['day','week', 'month']

  #attr_accessible :subject, :tracker_id
  validates_presence_of :subject, :interval_number, :next_run_date  
  validates_uniqueness_of :subject, :message => "Subject name already exists." 
  validates_numericality_of :interval_number, :only_integer=>true, :greater_than=>0
end
