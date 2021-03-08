#La fonction existait, mais la tâche rake a été créée le 10/04/2020
# rake view_widgets:recalculate_widgets_positions RAILS_ENV=production

namespace :view_widgets do

  desc "Recalcule la position des vignettes pour le nouveau Design"

  task recalculate_widgets_positions: :environment do

    widgets_name = ["Abaque", "Localisation", "Charge RTU (jh)", "Charge RIS (jh)", "Coût (€)", "Répartition des Charges", "Dire d'expert", "Charge (jh)", "Coût services (€)", "Synthèse devis", "Synthese devis", "Charge totale", "coût total", "Prix Moyen Pondéré (€/jh)", "prix moyen pondéré"]
    data = []
    #ViewsWidget.first do |view_widget|
    ViewsWidget.all.each do |view_widget|

      puts "#{view_widget.id}"
      case view_widget.name.to_s.downcase

        when "abaque"
          data = [0,0,5,1]

        when ""
          data = [0,0,5,1]
          if view_widget.name.blank? && view_widget.is_label_widget?
            view_widget.name = view_widget.comment.to_s.humanize
            view_widget.save(validate: false)
          end

        when "localisation"
          data = [0,1,5,1]

        when "charge rtu (jh)"
          data = [0,2,3,1] #[0,2,2,1]

        when "charge ris (jh)"
          data = [0,2,3,1]

        when "coût (€)"
          data = [3,2,2,1]

        when "répartition des charges", "répartion des charges", "repartion des charges"
          data = [0,3,5,6]

        when "dire d'expert"
          data = [6,0,6,1]

        when "charge (jh)"
          data = [6,1,3,1]

        when "coût services (€)"
          data = [9,1,3,1]

        when "charge services (€)"
          data = [6,1,3,1]

        when "synthèse devis", "synthese devis"
          data = [6,2,6,1]

        when "charge totale (jh)"
          data = [6,3,3,1]

        when "coût total (€)"
          data = [9,3,3,1]

        when "prix moyen pondéré (€/jh)"
          data = [7,4,4,1]
      end

      unless data.empty?
        view_widget.update_attributes(position_x: data[0], position_y: data[1], width: data[2], height: data[3])
      end
    end
    puts "Fini..."
  end
end