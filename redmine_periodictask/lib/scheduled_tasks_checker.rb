class ScheduledTasksChecker
  def self.checktasks!
=begin
    Periodictask.all().each do |task|
      puts task.inspect 
    end
=end
    Periodictask.all(:conditions=> ["next_run_date <= ? ", Time.now.to_date]).each do |task| 

      print "assigning #{task.subject}"
        issue = Issue.new(:project_id=>task.project_id, :tracker_id=>task.tracker_id,
                          :assigned_to_id=>task.assigned_to_id,
                          :author_id=>task.author_id, :subject=>task.subject);
        issue.save         
        interval = task.interval_number
        units = task.interval_units
        task.next_run_date =  interval.send(units.downcase).from_now
        task.last_assigned_date = Time.now.to_date
        task.save
     end
  end
end
