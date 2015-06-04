class SuprajitTasksChecker < IssuesController
  @created_issue = Issue.new;
  STATUS_TO_REPEAT = '19' #status that is used to repeat
  AUTO_PRIORITY = '6'
  def self.suprajittasks!

  def find_issues_with_query(query)
    Issue.find :all,
      :include => [ :assigned_to, :status, :tracker, :project, :priority ],
      :conditions => query.statement
  end
  def self.create_relation (issue, parent)
      relation = IssueRelation.new :issue_from => parent, :issue_to => issue,
                                 :relation_type => IssueRelation::TYPE_RELATES
      relation.save
  end
  def self.create_issue(issue, date_read, repeat)
    new_issue_title = issue.subject + date_read
    @created_issue = Issue.new(:project_id=>issue.project_id, :tracker_id=>6,
                    :assigned_to_id=>issue.assigned_to_id,
                    :author_id=>issue.author_id, :subject=>new_issue_title,
                    :custom_field_values => {'3'=>repeat.to_s,AUTO_PRIORITY=>'1'}); # {'id' => '3', 'value' => 'Monthly' }); # 5 = repeating, 1 = monthly 
    @created_issue.save
    create_relation(@created_issue, issue);
    print "\n----- Periodic Plugin created: " + @created_issue.inspect.to_s + "-------------\n\n";
    return @created_issue;
  end

  def self.create_parent (issue, parent)
      print parent.inspect;
      #print "parent of" + issue.id.to_s + "will be " + parent.id.to_s + "\n";
      issue.update_attribute(:parent_issue_id, parent.id);
  end



  def self.auto_create (issue, date_read, repeat, parent)
    #creating repeated issue with original as parent parent
    temp_issue = Issue.new;
    if (issue.status_id.to_s == STATUS_TO_REPEAT) #if child is always open...
      @created_issue = create_issue(issue, date_read, repeat);
      temp_issue = @created_issue.dup
      if (parent) then create_parent(@created_issue, parent) end;
      
    end
    else if (issue.children)
        #if issue.children.any? 
        print "\n \nCreating Children of:" + @created_issue.id.to_s + " now"
        for child in issue.children
          auto_create (child, date_read, repeat, @created_issue)
          @created_issue = temp_issue
        end

    end
    #create_relation(@created_issue, issue) 
  end

  def self.auto_update (issue)
    if issue.children.present? 
      for child in issue.children
        print 'Updating priority of the child : ' + child.inspect.to_s
        auto_update(child);
      end
    else 
      issue.update_attribute(:updated_on,Time.now) 
      issue.update_attribute(:priority_id, 5) #Priority High
    end
  end

  issues = Issue.find(:all, 
                    :conditions => {:status_id => STATUS_TO_REPEAT}, 
                    :limit => 1000,
                    :include => [:status, :project, :tracker, :priority ],
                    :order => "#{Issue.table_name}.updated_on DESC")


  issues_priority = Issue.find(:all, 
                    :conditions => "(custom2.custom_field_id = 3 AND custom2.value = 'Weekly' OR custom2.value = 'Monthly' OR custom2.value = 'Quarterly' OR custom2.value = 'Annually') AND (custom_values.custom_field_id = #{AUTO_PRIORITY} AND custom_values.value = 1)", #"(custom2.custom_field_id = 5 AND custom2.value = 1 OR custom2.value = 2) AND custom_values.custom_field_id = 3", # {:custom_values => {:custom_field_id => 5, :value => true}, :custom_values => {:custom_field_id => 3, :value => "Quarterly"} }, 
                    :joins => "INNER JOIN custom_values AS custom2 on  issues.id = custom2.customized_id",
                    :limit => 1000,
                    :include => [:custom_values],
                    :order => "#{Issue.table_name}.updated_on DESC")
  x = issues_priority.map{|v| v.id};


  issues_priority = Issue.find(:all, 
                    :conditions => {:id => x}, 
                    :limit => 1000,
                    :include => [:status, :project, :tracker, :priority ],
                    :order => "#{Issue.table_name}.updated_on DESC")


  day = Date.today.day;
  month = Date.today.month;  
  year = Date.today.year;
  wday = Date.today.wday; 
  quarters = Array[3,6,9,12] #Quarters 
  quarters_end = quarters.map{|item| item -= 1}
  is_quarter = quarters.include? (month)
  is_quarter_end = quarters_end.include? (month)
  date_read = " #{day}-#{month}-#{year}"
  #need to raise priority:

  for issue in issues_priority
    print issue.id.to_s;
    repeat = issue.custom_field_values.find {|v| v.custom_field_id == 3}#id 3 is for 'repeating'
    if day==22 && repeat.to_s == 'Monthly' #raise monthly issue priorities on 22nd of every month
      print 'Monthly Priority Updated'
      auto_update(issue)

    end
    if day==4 && is_quarter_end &&repeat.to_s=='Quarterly' #raise monthly issue priorities on 22nd of every month
            
            #issue.update_attribute(:updated_on,Time.now) 
            #issue.update_attribute(:priority_id, 5) #Priority High
            print "\nQuarterly Priority Updated\n"
            auto_update(issue)
    end
    if day==4 && month==3 && repeat.to_s=='Annually' #raise priority for year ending tasks in March
            print "\nAnnually Priority Updated\n"
            auto_update(issue)
    end
    if wday==5 && repeat.to_s=='Weekly' #raise priority for year ending tasks in March
            print "\nWeekly Priority Updated\n"
            auto_update(issue)
    end
  end

  print "\n \n \n PRIORITIES HAVE BEEN UPDATED \n \n \n"




#--------------Issue Creator------------

   #Run this only on first day of every month, run Monthly Issues Here
  #Recreate monthly issues Always open issues:
  for issue in issues
    #print issue.target_version;

    if (issue.parent_id) 
      has_parent = true;
      error_issue = Issue.new(:project_id=>issue.project_id, :tracker_id=>6,
                         :assigned_to_id=>issue.assigned_to_id,
                         :author_id=>issue.author_id, :subject=>"Always open issue should not have parent!"+issue.id.to_s);
      #error_issue.save
        print "\n\n ISSUE HAS PARENT, SKIPPED \n\n\n"
      next
    else has_parent = false;
    end
           
    repeat = issue.custom_field_values.select {|v| v.custom_field_id == 3}#id 3 is for 'repeating'

    if (day == 1)
      case (repeat.to_s)
        when 'Monthly' #This runs every day 1
          print "\nCreating Monthly"
          auto_create(issue, date_read, repeat, '');
        when "Quarterly"
          if (is_quarter)
            print "\nCreating Quarterly"
            auto_create(issue, date_read, repeat, '');
          end  
        when "Annually" 
          if(month == 4) #Begining of new FY
            print "\nCreating Annually"
            auto_create(issue, date_read, repeat, '');
          end             
      end
    end
    if (wday == 1)
      case (repeat.to_s)
        when 'Weekly' #This runs every day 1
              print "\nCreating Weekly"
          auto_create(issue, date_read, repeat, '');
      end
    end
  end
end
end
