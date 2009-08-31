# lib/tasks/populate.rake
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    [Activity, Organism].each(&:delete_all)



    Activity.populate 20..60 do |activity|
      activity.name = Populator.words(1..2).titleize
      activity.description = Populator.sentences(2..10)
    end

    Organism.populate 30..200 do |organism|
        organism.name = Populator.words(1..5).titleize
        organism.description_short = Populator.sentences(1..6)
        organism.description_long = Populator.sentences(4..30)
        organism.created_at = 2.years.ago..Time.now
        organism.manager_name = Faker::Name.name
        organism.in_directory = true
        organism.state = "active"
        organism.activated_at = 2.years.ago..Time.now
      end

    
  end
end


