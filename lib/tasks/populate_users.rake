# lib/tasks/populate.rake
namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'
    
    #[User].each(&:delete_all)

    User.populate 100 do |user|
      user.login    = Faker::Internet.user_name
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.email   = Faker::Internet.email
    end


    
  end
end


