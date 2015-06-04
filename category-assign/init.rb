require 'redmine'
require 'category_assign_issue_patch'


Rails.configuration.to_prepare do
  require_dependency 'issue'
  Issue.send(:include, CategoryAssignIssuePatch)
end

Redmine::Plugin.register :redmine_category_assign do
  name 'Category Assign Plugin'
  author 'Akhilesh Rai'
  description 'Extends Redmine\'s default category assignment to work on issue update too.'
  version '0.1.0'
end
