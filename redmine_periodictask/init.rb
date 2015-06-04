require 'redmine'

Redmine::Plugin.register :redmine_periodictask do
  name 'Suprajit Periodictask plugin'
  author 'Akhilesh Rai'
  description 'This is a plugin for Redmine that will allow you to schedule a task to be assigned based on certain repeating conditions of a task and current date of financial year'
  version '1.0.1'

  project_module :periodictask_module do
    permission :periodictask, {:periodictask => [:index, :edit]}, :public => true
  end

  menu :project_menu, :periodictask, { :controller => 'periodictask', :action => 'index' },
        :caption => 'Periodic Task', :after => :settings, :param => :project_id
end
