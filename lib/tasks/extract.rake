namespace :estimancy do
  desc "TODO"
  task extract: :environment do

    StatusHistory.delete_all

    Project.where(id: 5232).each do |project|

      status_comments = project.status_comment.split("\r\n").delete_if{ |i| i == "___________________________________________________________________________" } #Array

      status_comments.each do |sc|
        date = sc[0..15]

        if "créée par".in?(sc)
          # 21/11/2017 16:11 : Estimation créée par "Adm Administrateur"
          action = "Création"
          target = nil
          origin = nil
          user = sc[41..(sc.length-4)]
          comment = nil

          create_history(project, date, action, comment, origin, target, user)

        elsif "à partir".in?(sc)
          action = "Création à partir d'un modèle"
          user = clean(sc[sc.index('" par "')+7..sc.length])
          comment = nil

          create_history(project, date, action, comment, origin, target, user)

        elsif "created from".in?(sc)
          # 10/11/2017 13:53 : Estimation created from the "Prestations Dire Expert - Etudes P1 PARIS - 1.0" estimation by "Eric BELLET"
          action = "Création à partir d'un modèle"
          user = clean(sc[(sc.index('by')+4)..(sc.length)])
          comment = nil

          create_history(project, date, action, comment, origin, target, user)

        elsif "Status changé".in?(sc)
          #   11/02/2018 15:50 : Status changé de "En cours" à "Brouillon" par Eric BELLET_ADM.
          action = "Changement de status"
          origin = sc[sc.index('de')+4..(sc.index('à'))-3]
          target = sc[sc.index('à')+3..(sc.index('par'))-3]
          user = clean(sc[sc.index('par')+4..(sc.length)])
          comment = nil

          create_history(project, date, action, comment, origin, target, user)

        # elsif version changé in?(sc)

        # elsif changement automatique de statut des anciennes versions lors du passage de la version 1.0 à TOTO par...
          # target => Abandonnée


        elsif "Notes modifiées".in?(sc)

          @user = sc[sc.index('par')+5..(sc.length)]
          @date = sc[0..15]

        else
          action = "Commentaire"
          comment = sc

          unless comment.blank?
            create_history(project, @date, action, comment, origin, target, @user)
            @user = nil
            @date = nil
          end
        end
      end
    end

  end

  def create_history(project, date, action, comment, origin, target, user)
    StatusHistory.create(organization: project.organization.name,
                         project_id: project.id,
                         project: project.title,
                         version_number: project.version_number,
                         change_date: date,
                         action: action,
                         comments: comment,
                         origin: origin,
                         target: target,
                         user: user)
  end

  def clean(str)
    str.gsub('.','').gsub(/"/, '')
  end

end

#     last_project = Project.last
#     comments = last_project.status_comment
#
#     if /(\w)*___________________________________________________________________________/ =~ comments  #projects avec plusieurs actions
#       arr_tab = comments.split(". \r\n___________________________________________________________________________\r\n")
#
#       tab2 = Array.new
#       for elem in arr_tab
#         tab2 << Array.new(1, elem)
#       end
#
#       for elt in tab2 #elt est un tableau seul élément;  elt[0]: chaine de ce tableau
#         p elt[0]
#
#         date = elt[0][0..15]
#         p "date"
#         p date
#
#         intro = elt[0][19..32]
#         #p intro
#
#         if /Status changé(\w)*/.match(intro) then
#           de_ind = elt[0].index("d")
#           par_ind = elt[0].index("p")
#           a_par_tab = Array.new(1, elt[0][de_ind..par_ind+3])
#           ss_apar_tab = a_par_tab.join("")
#           origine = Array.new(1, ss_apar_tab[4..ss_apar_tab.index("à")-3])
#           p "origine: "
#           p origine[0]
#           target = Array.new(1, ss_apar_tab[ss_apar_tab.index("à")+3..ss_apar_tab.index("p")-3])
#           p "target: "
#           p target[0]
#         end
#
#         if /Estimation(\w)*/.match(intro) then
#           rev = elt[0].reverse.split("")
#           y_ind = rev.index("y") # yb
#           user =  rev[8..y_ind-3].reverse
#           p "user: "
#           p user.join("")
#         end
#
#       end
#
#     else # projects avec une seule action
#       p comments
#
#       uniq =  comments.split("")
#
#       uniq2 = Array.new()
#       uniq2 << uniq[19..35]
#
#       date = uniq[0..15].join("")
#       p "date: "
#       p date
#
#       intro = uniq.join("")
#       #p intro
#
#       if /Estimation créée (\w)*/.match(intro) then
#         rev = comments.reverse.split("")
#         e_ind = rev.index('é') # créée
#         user =  rev[5..e_ind-8].reverse
#         p "user: "
#         p user.join("")
#       end
#
#       if /Estimation create(\w)*/.match(intro) then
#         rev = elt[0].reverse.split("")
#         y_ind = rev.index("y") # yb
#         user =  rev[8..y_ind-3].reverse
#         p "user: "
#         p user.join("")
#       end
#
#
#     end
#   end
# end

#
# "11/02/2018 15:54 : Status changé de \"En cours\" à \"Brouillon\" par Eric BELLET_ADM. \r\n"
# comments.split("\n")

#   date = comments.split("")[0..16.joins
#   origin =
#   target =
#   user = comments.gsub(".", "").split
