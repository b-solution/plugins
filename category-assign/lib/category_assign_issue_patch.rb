# Patches Redmine's Issues dynamically.  Adds a default assignee per
# project.
#
# Based heavily on edavis10's stuff-to-do plugin
#
module CategoryAssignIssuePatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      before_save :category_default_assign

    end
  end

  module InstanceMethods
    # If the issue isn't assigned to someone and a default assignee
    # is set, set it.

    def category_default_assign
      if self.assigned_to.nil? && category && category.assigned_to
        self.assigned_to = category.assigned_to
      end
    end

  end
end
