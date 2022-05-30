namespace :ns do
  desc "TODO"
  task prj_each: :environment do


    projs = Project.all

=begin
    projs.each do |proj|
      p "======================================="
      p proj.status_comment
    end
=end

    puts projs[3].status_comment

=begin
    prjs = Project.all
    prjs.each do |projet|
        puts "========================================="
        puts projet.status_comment
    end
=end
  end
end
