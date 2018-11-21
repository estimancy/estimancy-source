namespace :namespace do
  desc "TODO"
  task nom_task: :environment do
    projects = Project.all
    projects.each do |project|
      p "==================================================================="
      comments = project.status_comment
      #p comments

      if /(\w)*___________________________________________________________________________/ =~ comments  #projects avec plusieurs actions
        comments_array = comments.split(". \r\n___________________________________________________________________________\r\n")

        ss_array = Array.new
        for elem in comments_array
          ss_array << Array.new(1, elem)        #chaque devis élément est un tableau
        end

        for elt in ss_array #elt est un tableau seul élément;  elt[0]: chaine de ce tableau
          elem = elt[0].split (" \r\n")
          p elem

          date = elt[0][0..15]
          p "date"
          p date

          intro = elt[0][19..34]


          if /Status changé(\w)*/.match(intro) or /Status changed(\w)*/.match(intro)
            de_ind = elem[0].index("d")
            #par_ind = elem[0].index("p")
            a_par_tab = Array.new(1, elem[0][de_ind..elem[0].length-1])


            ss_apar_tab = a_par_tab.join("")


            ori = Array.new(1, ss_apar_tab[4..ss_apar_tab.index("à")-3])
            p "origine: "
            origine = ori[0]
            p origine

            sss_apar_tab = ss_apar_tab.split("")


            par_ind = sss_apar_tab.index {|x| x=="p"; sss_apar_tab[sss_apar_tab.index(x)+1] == "a"}

            tar = Array.new(1, ss_apar_tab[ss_apar_tab.index("à")+3..par_ind-3])
            p "target: "
            p tar.join("")

            usr_tab = Array.new(1, ss_apar_tab[par_ind+4..elt[0].length-1] )
            user = usr_tab[0]
            p "user: "
            p user

            action = "Changement de statut"

          end

          if /Estimation crea(\w)*/.match(intro)
            rev = elem[0].reverse.split("").compact
            #p rev
            y_ind = rev.index("y") # yb
            user =  rev[2..y_ind-3].reverse

            p "user: "
            p user.join("")

            action = "Création"
          end

          if /Estimation cré(\w)*/.match(intro)
            par_ind = sss_apar_tab.index {|x| x=="p"; sss_apar_tab[sss_apar_tab.index(x)+1] == "a"}
            usr_tab = Array.new(1, a_par_tab[par_ind..elt[0].length-1] )
            user = usr_tab[0]
            p user
            action = "Création"
          end

        end

      else # projects avec une seule action
        p comments

        uniq = Array.new()
        uniq << uniq[19..35]
        #p uniq

        date = uniq[0..15].join("")
        p "date: "
        p date

        intro = uniq.join("")
        #p intro

        action = "Création"

        if /Estimation créée (\w)*/.match(intro) then
          rev = comments.reverse.split("")
          e_ind = rev.index('é') # créée
          user =  rev[5..e_ind-8].reverse
          p "user: "
          p user.join("")
        end

        if /Estimation created(\w)*/.match(intro) then
          rev = elt[0].reverse.split("\r\n")
          y_ind = rev.index("y") # yb
          user =  rev[8..y_ind-3].reverse
          p "user: "
          p user.join("")
        end
      end

      StatusHistory.create(organization: project.organization.name,
                           project: project.title,
                           version_number: project.version_number,
                           change_date: date,
                           action: action,
                           #comments: params["project"]["new_status_comment"].to_s,
                           origin: origine,
                           target: tar,
                           user: user)

    end
  end
end

