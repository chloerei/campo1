namespace :stream do
  desc "Rebuild stream with current status"
  task :rebuild => [:environment] do
    $redis.flushdb
    Status::Base.all.desc(:created_at).limit(ENV['LIMIT'] || 10000).reverse_each do |status|
      status.send_stream
    end
  end

  namespace :status do
    desc "Rebuild statuses then rebuild stream"
    task :rebuild => [:environment] do
      Status::Base.delete_all

      Topic.all.each do |topic|
        topic.create_status(:silent => true)
      end

      Reply.all.each do |reply|
        reply.create_status(:silent => true)
      end

      Rake::Task["stream:rebuild"].execute
    end
  end
end
