# lib/tasks/populate.rake
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    [Category, Event, Term].each(&:delete_all)


    Category.populate 7..10 do |category|
      category.name = Populator.words(1..2).titleize
      category.to_display = true
      category.description = Populator.sentences(2..10)
    end

    Event.populate 10..2000 do |event|
        Term.populate 1..7   do |term|
          term.event_id = event.id
          term.start = 2.years.ago..3.months.from_now
          term.end = 2.years.ago..3.months.from_now
        end
        event.title = Populator.words(1..5).titleize
        event.description_short = Populator.sentences(1..6)
        event.description_long = Faker::Lorem.paragraphs
        event.created_at = 2.years.ago..Time.now
      end

    
  end
end


