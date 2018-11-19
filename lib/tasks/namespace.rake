namespace :namespace do
  desc "TODO"
  task nom_task: :environment do
    projects = Project.all
    projects.each do |project|

      comments = project.status_comment

      if /(\w)*___________________________________________________________________________/ =~ comments  #projects avec plusieurs actions
        arr_tab = comments.split(". \r\n___________________________________________________________________________\r\n")

        tab2 = Array.new
        for elem in arr_tab
          tab2 << Array.new(1, elem)
        end

        for elt in tab2 #elt est un tableau seul élément;  elt[0]: chaine de ce tableau
          p elt[0]

          date = elt[0][0..15]
          p "date"
          p date

          intro = elt[0][19..32]
          #p intro

          if /Status changé(\w)*/.match(intro) then
            de_ind = elt[0].index("d")
            par_ind = elt[0].index("p")
            a_par_tab = Array.new(1, elt[0][de_ind..par_ind+3])
            ss_apar_tab = a_par_tab.join("")
            origine = Array.new(1, ss_apar_tab[4..ss_apar_tab.index("à")-3])
            p "origine: "
            p origine[0]
            target = Array.new(1, ss_apar_tab[ss_apar_tab.index("à")+3..ss_apar_tab.index("p")-3])
            p "target: "
            p target[0]
          end

          if /Estimation(\w)*/.match(intro) then
            rev = elt[0].reverse.split("")
            y_ind = rev.index("y") # yb
            user =  rev[8..y_ind-3].reverse
            p "user: "
            p user.join("")
          end

        end

      else # projects avec une seule action
        p comments

        uniq =  comments.split("")

        uniq2 = Array.new()
        uniq2 << uniq[19..35]

        date = uniq[0..15].join("")
        p "date: "
        p date

        intro = uniq.join("")
        #p intro

        if /Estimation créée (\w)*/.match(intro) then
          rev = comments.reverse.split("")
          e_ind = rev.index('é') # créée
          user =  rev[5..e_ind-8].reverse
          p "user: "
          p user.join("")
        end

        if /Estimation create(\w)*/.match(intro) then
          rev = elt[0].reverse.split("")
          y_ind = rev.index("y") # yb
          user =  rev[8..y_ind-3].reverse
          p "user: "
          p user.join("")
        end

      end
    end
  end
end




#p comments[0..15]
 #array
 #"==========================================="
#
#StatusHistory.create(organization: project.organization.name,
#project: project.title,
#version_number: project.version_number,
#change_date: Time.now,
#action: "Changement de statut",
#comments: ,
#origin:
#target: EstimationStatus.find(params[:project][:estimation_status_id].to_i).name,
#user: current_user.name)