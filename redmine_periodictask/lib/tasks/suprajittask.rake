desc <<-END_DESC
Check for and assign periodic tasks

Example:
  rake redmine:check_periodictasks RAILS_ENV="production"
END_DESC
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")

namespace :redmine do
  print "got here suprajit"
    task :suprajit_periodictasks => :environment do
      SuprajitTasksChecker.suprajittasks!
    end
end
