namespace :estimancy do
  desc "TODO"
  task extract: :environment do

    Biz.configure do |config|
      config.hours = {
          mon: {'09:00' => '12:00', '13:00' => '17:00'},
          tue: {'09:00' => '12:00', '13:00' => '17:00'},
          wed: {'09:00' => '12:00', '13:00' => '17:00'},
          thu: {'09:00' => '12:00', '13:00' => '17:00'},
          fri: {'09:00' => '12:00', '13:00' => '17:00'}
      }
    end

    StatusHistory.delete_all

    Project.all.each do |project|

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
          old_ver = nil
          new_ver = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "à partir".in?(sc)
          action = "Création à partir d'un modèle"
          user = clean(sc[sc.index('" par "')+7..sc.length])
          comment = nil
          origin = nil
          target = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "created from".in?(sc)
          # 10/11/2017 13:53 : Estimation created from the "Prestations Dire Expert - Etudes P1 PARIS - 1.0" estimation by "Eric BELLET"
          action = "Création à partir d'un modèle"
          user = clean(sc[(sc.index('by')+4)..(sc.length)])
          comment = nil
          origin = nil
          target = nil
          #old_ver = nil
          #new_ver = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "Status changé".in?(sc)
          # 11/02/2018 15:50 : Status changé de "En cours" à "Brouillon" par Eric BELLET_ADM.
          action = "Changement de status"
          origin = sc[sc.index('de')+4..(sc.index('à'))-3]
          target = sc[sc.index('à')+3..(sc.index('par'))-3]
          user = clean(sc[sc.index('par')+4..(sc.length)])
          comment = nil
          old_ver = nil
          new_ver = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "Version changée".in?(sc)
          old_ver = sc[sc.index('de')+4..sc.index('à')-3]
          new_ver = sc[sc.index('à')+3..sc.index('par')-3]
          user = clean(sc[sc.index('par')+4..(sc.length)])
          action = nil
          comment = nil
          origin = nil
          target = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "Changement automatique".in?(sc)
          action = nil
          old_ver = sc[sc.index('de la version')+14..sc.index('à')-2]
          new_ver =  sc[sc.index('à')+2..sc.index('par')-2]
          user = clean(sc[sc.index('par')+4..sc.index('Nouveau')])
          comment = sc[sc.index('Changement')..sc.index('versions')+7]
          target = "Abandonnée"
          origin = nil

          create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)

        elsif "Notes modifiées".in?(sc)
          @user = sc[sc.index('par')+5..(sc.length)]
          @date = sc[0..15]

        else
          action = "Commentaire"
          comment = sc

          # si date est nulle
          # @status_history = StatusHistory.where(project_id: project.id).last #receuperer le dernier
          # #mettre a jour avec la suite du commentare
          # sinon, faire la suite...

          unless comment.blank?

            origin = nil
            target = nil
            create_history(project, old_ver, new_ver, @date, action, comment, origin, target, @user)
            @user = nil
            @date = nil
          end
        end
      end
    end
  end

  def create_history(project, old_ver, new_ver, date, action, comment, origin, target, user)
    # Calculer l'écart de date en secondes entre la dernière ligne SH crée pour le project et le nouveau SH

    sh = StatusHistory.where(project_id: project.id).first

    new_sh = StatusHistory.new(organization: project.organization.name,
                               project_id: project.id,
                               project: project.title,
                               old_version_number: old_ver,
                               new_version_number: new_ver,
                               change_date: date,
                               action: action,
                               comments: comment,
                               origin: origin,
                               target: target,
                               user: user)
    unless sh.nil?
      unless sh.change_date.nil? || date.nil?

        p Time.parse(date).class
        p sh.change_date.to_time.class

        gap = Biz.within(Time.parse(date), sh.change_date.to_time).in_minutes
        new_sh.gap = gap
      end
    end

    new_sh.save

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
