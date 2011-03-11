namespace :db do
  namespace :refresh do
    desc "Run all db:refresh task"
    task :all => [:environment, :topic_replied_ids] do
    end

    desc "Refresh Topic replied_ids"
    task :topic_replied_ids => [:environment] do
      Topic.all.each do |topic|
        topic.replier_ids = Reply.collection.distinct(:user_id, {:topic_id => topic.id}).delete_if {|id| id == topic.user_id}
        topic.save
      end
    end
  end
end
