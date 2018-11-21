namespace :wp do
  desc "TODO"
  task test_task: :environment do
    last_project = Project.last
    comments = last_project.status_comment

    if /(\w)*___________________________________________________________________________/ =~ comments  #projects avec plusieurs actions
      comments_array = comments.split(". \r\n___________________________________________________________________________\r\n")

      ss_array = Array.new
      for elem in comments_array
        ss_array << Array.new(1, elem)        #chaque devis élément est un tableau
      end

      for elt in ss_array #elt est un tableau seul élément;  elt[0]: chaine de ce tableau
        elem = elt[0].split (" \r\n")
        p elem

        date = elem[0][0..15]
        p "date"
        p date

        intro = elt[0][19..34]
        p intro

        if /Status changé(\w)*/.match(intro) or /Status changed(\w)*/.match(intro)
          de_ind = elem[0].index("d")
          par_ind = elem[0].index("p")
          a_par_tab = Array.new(1, elem[0][de_ind..par_ind+3])
          ss_apar_tab = a_par_tab.join("")
          origine = Array.new(1, ss_apar_tab[4..ss_apar_tab.index("à")-3])
          p "origine: "
          p origine[0]
          target = Array.new(1, ss_apar_tab[ss_apar_tab.index("à")+3..ss_apar_tab.index("p")-3])
          p "target: "
          p target[0]
        end

        if /Estimation crea(\w)*/.match(intro)
          rev = elem[0].reverse.split("").compact

          p rev
          y_ind = rev.index("y") # yb
          user =  rev[2..y_ind-3].reverse
          p "user: "
          p user.join("")
        end

        if /Estimation créée(\w)*/.match(intro)
          rev = elem[0].reverse.split("")
          p rev
          y_ind = rev.index("y") # yb
          user =  rev[8..y_ind-3].reverse
          p "user: "
          p user.join("")
        end

      end

    else # projects avec une seule action
      p comments

      uniq = Array.new()
      uniq << uniq[19..35]
      p uniq

      date = uniq[0..15].join("")
      p "date: "
      p date

      intro = uniq.join("")
      #p intro

      if /Estimation créée(\w)*/.match(intro)
        rev = comments.reverse.split("")
        p rev
        e_ind = rev.index('é') # créée
        user =  rev[5..e_ind-8].reverse
        p "user: "
        p user.join("")
      end

      if /Estimation created(\w)*/.match(intro)
        rev = elt[0].reverse.split("\r\n")
        p rev
        y_ind = rev.index("y") # yb
        user =  rev[8..y_ind-3].reverse
        p "user: "
        p user.join("")
      end
    end

    # Code d'exemeple
      Project.take(4).each do |project|
      comments = project.status_comment
      comments_array = comments.split("\r\n")

      comments_array.each do |comment|*

        ####### DATE #######
        date = comment[0..15]

        # intro
        intro = elt[0][19..34]

        ####### USER #######
        if /Estimation créée(\w)*/.match(intro)
          rev = comments.reverse.split("")
          e_ind = rev.index('é') # créée
          user = rev[5..e_ind-8].reverse
        end

        ####### ORIGIN #######
        origin = ""

        ####### ORIGIN #######
        target = ""

        StatusHistory.create(organization: project.organization.name,
                             project: project.title,
                             version_number: project.version_number,
                             change_date: date,
                             origin: origin,
                             target: target,
                             user: user,
                             action: "")

      #pour action
      # si origin != target action = "changement de statut"
      # si origin == target action = "Nouvelle notes"
      # si origin ou target == nil alors action = "Creation"
      end

  end
end

#
# "11/02/2018 15:54 : Status changé de \"En cours\" à \"Brouillon\" par Eric BELLET_ADM. \r\n"
# comments.split("\n")

#   date = comments.split("")[0..16.joins
#   origin =
#   target =
#   user = comments.gsub(".", "").split
