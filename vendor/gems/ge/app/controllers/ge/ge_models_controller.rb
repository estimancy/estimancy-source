# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Ge::GeModelsController < ApplicationController

  require 'rubyXL'

  def show
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title @ge_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @ge_model = Ge::GeModel.new
    set_page_title I18n.t(:new_instance_of_effort)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title I18n.t(:Edit_instance_of_effort)
    #set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.organization => ""
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params?organization_id=#{@organization.id}", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""

  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:ge_model][:organization_id])

    @ge_model = Ge::GeModel.new(params[:ge_model])
    @ge_model.organization_id = params[:ge_model][:organization_id].to_i
    if @ge_model.save
      redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
      #redirect_to redirect_apply(ge.edit_ge_model_path(@ge_model, organization_id: @organization.id), main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort"))
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    if @ge_model.update_attributes(params[:ge_model])
      #redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
      redirect_to redirect_apply(ge.edit_ge_model_path(@ge_model, organization_id: @organization.id), nil ,main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort"))
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    organization_id = @ge_model.organization_id

    @ge_model.module_projects.each do |mp|
      mp.destroy
    end

    @ge_model.destroy
    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end

  #Delete all factors and factor-values data of the model
  def delete_all_factors_data
    @ge_model = Ge::GeModel.find(params[:ge_model_id])    #For the factors list worksheet
    ge_model_factors = @ge_model.ge_factors
    #ge_factor_values = @ge_model.ge_factor_values

    unless ge_model_factors.nil?
      begin
        ge_model_factors.destroy_all
      rescue
        flash[:error] = I18n.t(:error_failed_to_delete_factors)
      end
    end
    redirect_to ge.edit_ge_model_path(@ge_model, anchor: "tabs-2")
  end

  # Data export
  # if there is no data, a file with data format will be exported
  def data_export
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:ge_model_id])    #For the factors list worksheet
    ge_model_factors = @ge_model.ge_factors
    ge_factor_values = @ge_model.ge_factor_values

    workbook = RubyXL::Workbook.new
    workbook.add_worksheet("Factors")
    workbook.add_worksheet("Values")
    workbook.add_worksheet("Help")

    # add worksheet to workbook
    model_worksheet = workbook[0]
    factors_worksheet = workbook[1]
    values_worksheet = workbook[2]
    help_worksheet = workbook[3]

    model_worksheet.sheet_name = "Model"

    first_page = [[I18n.t(:model_name),  @ge_model.name],
                  [I18n.t(:model_description), @ge_model.description ],
                  [I18n.t(:ge_model_instance_mode), @ge_model.ge_model_instance_mode],
                  [I18n.t(:three_points_estimation), @ge_model.three_points_estimation ? 1 : 0],

                  ["#{I18n.t(:label_Factor)} a", @ge_model.coeff_a ],
                  ["#{I18n.t(:scale_factor)} : b", @ge_model.coeff_b ],
                  [I18n.t(:p_factors_calculation_method), @ge_model.p_calculation_method],
                  [I18n.t(:c_factors_calculation_method), @ge_model.c_calculation_method],
                  [I18n.t(:s_factors_calculation_method), @ge_model.s_calculation_method],

                  [I18n.t(:entree1), "#{{ unit: @ge_model.ent1_unit, coeff: @ge_model.ent1_unit_coefficient, modifiable: @ge_model.ent1_is_modifiable }}"],
                  [I18n.t(:entree2), "#{{ unit: @ge_model.ent2_unit, coeff: @ge_model.ent2_unit_coefficient, modifiable: @ge_model.ent2_is_modifiable }}"],
                  [I18n.t(:entree3), "#{{ unit: @ge_model.ent3_unit, coeff: @ge_model.ent3_unit_coefficient, modifiable: @ge_model.ent3_is_modifiable }}"],
                  [I18n.t(:entree4), "#{{ unit: @ge_model.ent4_unit, coeff: @ge_model.ent4_unit_coefficient, modifiable: @ge_model.ent4_is_modifiable }}"],

                  [I18n.t(:sortie1), "#{{ unit: @ge_model.sort1_unit, coeff: @ge_model.sort1_unit_coefficient, modifiable: @ge_model.sort1_is_modifiable }}"],
                  [I18n.t(:sortie2), "#{{ unit: @ge_model.sort2_unit, coeff: @ge_model.sort2_unit_coefficient, modifiable: @ge_model.sort2_is_modifiable }}"],
                  [I18n.t(:sortie3), "#{{ unit: @ge_model.sort3_unit, coeff: @ge_model.sort3_unit_coefficient, modifiable: @ge_model.sort3_is_modifiable }}"],
                  [I18n.t(:sortie4), "#{{ unit: @ge_model.sort4_unit, coeff: @ge_model.sort4_unit_coefficient, modifiable: @ge_model.sort4_is_modifiable }}"],

                  [I18n.t(:advice_ge), ""]]

    first_page.each_with_index do |row, index|
      model_worksheet.add_cell(index, 0, row[0].value)
      model_worksheet.add_cell(index, 1, row[1].value).change_horizontal_alignment('center')
      ["bottom", "right"].each do |symbole|
        model_worksheet[index][0].change_border(symbole.to_sym, 'thin')
        model_worksheet[index][1].change_border(symbole.to_sym, 'thin')
      end
    end
    model_worksheet.change_column_bold(0,true)
    model_worksheet.change_column_width(0, 45)
    model_worksheet.sheet_data[1][1].change_horizontal_alignment('left')

    # factors and values worksheet headers
    factors_default_attributs = ["Scale-Prod", I18n.t(:factor_type), I18n.t(:short_name), I18n.t(:long_name), I18n.t(:description)]
    values_default_attributs = [I18n.t(:factors), I18n.t(:value_text), I18n.t(:value_number), I18n.t(:default_value)]

    factors_counter_line = 1
    factors_default_attributs.flatten.each_with_index do |w_header, index|
      factors_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
    end
    factors_worksheet.change_row_bold(0,true)
    factors_worksheet.change_column_width(0, 10)

    values_counter_line = 1
    values_default_attributs.flatten.each_with_index do |w_header, index|
      values_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
    end
    values_worksheet.change_row_bold(0,true)
    values_worksheet.change_column_width(0, 20)

    # For help worksheet
    help_worksheet.add_cell(0, 0, "Quelques remarques concernant la construction de ce fichier : ")
    help_worksheet.change_row_bold(0,true)
    help_worksheet.add_cell(1, 0, "Un attribut ayant une seule valeur n'est pas affiché")
    help_worksheet.add_cell(2, 0, I18n.t(:scale_prod_help))
    help_worksheet.change_row_height(0, 30)
    help_worksheet.change_row_height(2, 60)

    #fill data if worksheets
    if ge_model_factors.nil? || ge_model_factors.empty?
      #create exemple of the data : factors and factor values
      workbook.add_worksheet("Factors exemples")
      workbook.add_worksheet("Values exemples")
      factors_exple_worksheet = workbook['Factors exemples']
      values_exple_worksheet = workbook['Values exemples']

      help_worksheet.add_cell(4, 0, "Il n'existe pas de donnée de facteurs pour ce module. \nPour vous aider à constituer et à créer vos facteurs et les valeurs associées à ces facteurs, nous avons ajoué 2 onglets pour exemple.")
      help_worksheet.add_cell(5, 0, "L'onglet \"Factors exemples\" contient des exemples de facteurs pour remplir l'onglet \"Factors\". \n")
      help_worksheet.add_cell(6, 0, "L'onglet \"Values exemples\" contient des exemples de valeurs des facteurs pour remplir l'onglet \"Values\". \n")
      help_worksheet.add_cell(8, 0, "Seuls les 3 premiers onglets (\"Model attribute\", \"Factors\" et \"Values\") seront pris en compte lors d'un import depuis l'application. \n Les autres onglets servent d'exemples ou de remarques.")
      help_worksheet.change_row_font_color(8, 'FF0000') #change_row_fill(8, 'FF0000')
      help_worksheet.change_row_height(8, 50)

      factors_exple_counter_line = 1
      factors_default_attributs.flatten.each_with_index do |w_header, index|
        factors_exple_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
      end
      factors_exple_worksheet.change_row_bold(0,true)
      factors_exple_worksheet.change_column_width(0, 10)

      values_exple_counter_line = 1
      values_default_attributs.flatten.each_with_index do |w_header, index|
        values_exple_worksheet.add_cell(0, index, w_header).change_horizontal_alignment('center')
      end
      values_exple_worksheet.change_row_bold(0,true)
      values_exple_worksheet.change_column_width(0, 20)

      factors_exple = [
        ["P",	"Facteurs produits", "RELY", "Exigence de fiabilité du logiciel",	"Ce paramètre mesure le niveau de fiabilité exigé, en général sur les applications de gestion  paramètre entre L et H"],
        ["P",	"Facteurs produits", "DATA", "Taille des données nécessaires aux tests", "Mesure es exigences de tests- nbre de règles de gestion, multiplicité des cas à tester"],
        ["P", "Facteurs produits", "CPLX", "Complexité du produit",	"5 types de complexité à prendre en compte : opérations de contrôle, opérations de calcul, opérations dépendantes du hardware, opérations de gestion des données, opérations de gestion de l'interface utilisateur \nValeur = mix de ces différents paramètres"],
        ["P",	"Facteurs produits",	"RUSE", "Développé pour une réutilisation", "La réutilisabilité du composant ou du projet est-elle à prendre en compte dans le coût du développement ?"],
        ["P", "Facteurs produits", "DOCU", "Niveau de la documentation attendue", "La documentation ( exigences, specifications, tests, ...) à fournir lors du développement correspond-elle aux besoins ?"],
        ["P",	"Facteurs techniques", "TIME",	"Contraintes de temps de réponses",	"Le developpement doit prendre en compte des exigences de performance liées à la durée du traitement"],
        ["P",	"Facteurs techniques",	"STOR",	"Contraintes de taille mémoire",	"Le developpement doit prendre en compte des limites en terme de taille méméoire"],
        ["P",	"Facteurs techniques",	"PVOL",	"Stabilité de la plateforme de développement",	"Plateforme de développement, y compris les outils de dev., mais aussi plateforme d'exploitation (OS, DBMS….)"],
        ["P",	"Facteurs projets", "TOOL",	"Utilisation d'outils de développement", "outils de dev et de tests, AGL, gestion de conf, gestion des exigences, planification ..."],
        ["P", "Facteurs projets", "SITE",	"Développement multi sites", "Mix entre la localisation et les moyens de communications"],
        ["P",	"Facteurs projets",	"SCED",	"Contrainte de délai", ""],
        ["P", "Facteurs personnels", "ACAP", "Maîtrise des analystes", "Capacité à analyser et concevoir, efficacité et précision, capacité à communiquer et coopérer"],
        ["P", "Facteurs personnels", "PCAP", "Maîtrise des développeurs", "Jugement sur l'équipe et non sur l'individu, précision, efficacité, capacité à communiquer et coopérer"],
        ["P", "Facteurs personnels", "PCON", "Turn-over du personnel", "taux de turn-over"],
        ["P",	"Facteurs personnels",	"APEX",	"Expérience sur ce type d'application", ""],
        ["P",	"Facteurs personnels",	"PLEX",	"Expérience sur l'environnement technique", ""],
        ["P",	"Facteurs personnels",	"LTEX",	"Expérience sur le langage et les outils de développment", ""],
        ["P",	"NA",	"PBASE",	"Coefficient de base COCOMOII : 2.94", ""],
        ["S",	"Organisation",	"PREC",	"Antériorité",	"Si le projet est comparable à d'autres projets développés antérieurement, alors l'antériorité est élevée (H)"],
        ["S",	"Organisation",	"FLEX",	"Flexibilité plus ou moins forte du respects des exigences (vs délai)",	"Ce paramètre vérifie les besoins de satisfaction des exigences et des interfaces. Si le niveau de flexibilité est important (priorité à la livraison par rapport à la satisfaction rigoureuse des exigences)  la valeur de l'indicateur est XH"],
        ["S",	"Organisation",	"RESL",	"Architecture et Résolution des risques",	"Gestion et suivi des risques, incertitude sur l'architecture et nombre d'architectes sur le projet par rapport aux besoins"],
        ["S",	"Organisation", "TEAM", "Cohésion de l'équipe", "Mesure la difficulté de synchroniser toutes les parties prenantes du projet utilisateurs, clients, développeurs, architectes…"],
        ["S",	"Organisation",	"PMAT",	"Maturité des processus",	"Maturité de l'organisation"],
        ["S",	"NA",	"COCOMO PostArch",	"Coef de base pour Post Architecture", "Coef de base auquel s'ajoute les facteurs d'échelle"],
        ["C",	"Langages",	"LANG",	"Conversion FP-> KSLOC", "Ce paramètre permet de traduire une taille en Points de Fonction IFPUG en Ksloc, en appliquant une table de conversion"],
        ["C",	"Réutilisation", "SIZE", "Taux de réutilisation de code existant", "Permet de prendre en compte un code existant."]
      ]

      factor_values_exple = [
          ["PREC",	"Totalement sans précédent", "0,062", ""],
          ["PREC",	"Largement sans précédent", "0,0496", ""],
          ["PREC",	"Légèrement sans précédent",	"0,0372",	"Default"],
          ["PREC",	"Plutôt familier", "0,0248", ""],
          ["PREC",	"Largement familier", "0,0124", ""],
          ["FLEX",	"conformité générale",	"0,0203", ""],
          ["RESL",	"Peu - 20%",	"0,0707", ""],
          ["TEAM",	"Coopération basique",	"0,0329", ""],
          ["PMAT",	"CMMI - level 2",	"0,0468", ""],
          ["COCOMO PostArch",	"Coef de base pour Post Architecture",	"0,91", ""],
          ["RELY",	"modérée, pertes facilement récupérables", 	"1", ""],
          ["DATA",	"Besoin important",	"1,14", ""],
          ["CPLX",	"Complexité de base",	"1", ""],
          ["RUSE",	"Pas de réutilisation", "0,95", ""],
          ["DOCU",	"documentation adaptée", "1", ""],
          ["TIME",	"< = 50% du temps disponible",	"1", ""],
          ["STOR",	"< = 50% de l'espace disponible",	"1", ""],
          ["PVOL",	"Plateforme stable, cgt majeur tous les ans, chgt mineur mensuel",	"0,87"],
          ["ACAP",	"bonne",	"0,85", ""],
          ["PCON",	"12%/ year",	"1", ""],
          ["APEX",	"Jamais",	"1,22", ""],
          ["APEX", 	"1 à 2 applications",	"1,1", ""],
          ["APEX",	"3 à 5 applications",	"1", ""],
          ["APEX",	"Plus de 5 applications",	"0,88", ""],
          ["PLEX",	"Expérimenté",	"1",	"Default"],
          ["LTEX",	"3 ans",	"0,91", ""],
          ["TOOL",	"Outils de base du cycle de vie modérément intégrés", "1", ""],
          ["SITE",	"Même batiment - communication large bande teleconférence",	"0,86", ""],
          ["SCED",	"100% du délai calculé",	"1", ""],
          ["PBASE",	"Facteur de base pour Cocomo II Post Architecture",	"2,94", ""],
          ["LANG",	"JAVA",	"0,053",	"Default"],
          ["LANG",	"C++",	"0,029", ""],
          ["SIZE",	"Nouveau code",	"1",	"Default"]
      ]

      #export factors exeemples
      factors_exple.each_with_index do |factor, index |
        factors_exple_worksheet.add_cell(index+1, 0, factor[0]).change_horizontal_alignment('center')
        factors_exple_worksheet.add_cell(index+1, 1, factor[1])
        factors_exple_worksheet.add_cell(index+1, 2, factor[2])
        factors_exple_worksheet.add_cell(index+1, 3, factor[3])
        factors_exple_worksheet.add_cell(index+1, 4, factor[4])
        factors_exple_counter_line  += 1
      end
      factors_exple_worksheet.change_row_horizontal_alignment(5, 'justify')
      factors_exple_worksheet.change_column_width(1, 20)
      factors_exple_worksheet.change_column_width(2, 15)
      factors_exple_worksheet.change_column_width(3, 35)
      factors_exple_worksheet.change_column_width(4, 50)

      #add column border
      factors_exple_counter_line.times.each do |line|
        ["bottom", "right"].each do |symbole|
          factors_exple_worksheet[line][0].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][1].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][2].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][3].change_border(symbole.to_sym, 'thin')
          factors_exple_worksheet[line][4].change_border(symbole.to_sym, 'thin')
        end
      end

      #export factors values exemples
      factor_values_exple.each_with_index do |factor_value, index|
        #values_worksheet.add_cell(index+1, 0, factor_value.factor_scale_prod).change_horizontal_alignment('center')
        values_exple_worksheet.add_cell(index+1, 0, factor_value[0])
        values_exple_worksheet.add_cell(index+1, 1, factor_value[1])
        values_exple_worksheet.add_cell(index+1, 2, factor_value[2]).change_horizontal_alignment('rigth')
        values_exple_worksheet.add_cell(index+1, 3, factor_value[3]).change_horizontal_alignment('center')
        values_exple_counter_line += 1
      end
      values_exple_worksheet.change_column_width(1,38)
      values_exple_worksheet.change_column_width(2,15)
      values_exple_worksheet.change_column_width(3,15)

      #add column border
      values_exple_counter_line.times.each do |line|
        ["bottom", "right"].each do |symbole|
          values_exple_worksheet[line][0].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][1].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][2].change_border(symbole.to_sym, 'thin')
          values_exple_worksheet[line][3].change_border(symbole.to_sym, 'thin')
        end
      end

    #the model factors are not nil or empty
    else
      #export factors
      ge_model_factors.each_with_index do |factor, index |
        factors_worksheet.add_cell(index+1, 0, factor.scale_prod).change_horizontal_alignment('center')
        factors_worksheet.add_cell(index+1, 1, factor.factor_type)
        factors_worksheet.add_cell(index+1, 2, factor.short_name)
        factors_worksheet.add_cell(index+1, 3, factor.long_name)
        factors_worksheet.add_cell(index+1, 4, factor.description)
        factors_counter_line += 1
      end

      factors_worksheet.change_row_horizontal_alignment(5, 'justify')
      factors_worksheet.change_column_width(1, 20)
      factors_worksheet.change_column_width(2, 15)
      factors_worksheet.change_column_width(3, 35)
      factors_worksheet.change_column_width(4, 50)

      #export factors values
      ge_factor_values.each_with_index do |factor_value, index|
        #values_worksheet.add_cell(index+1, 0, factor_value.factor_scale_prod).change_horizontal_alignment('center')
        values_worksheet.add_cell(index+1, 0, factor_value.factor_name)
        values_worksheet.add_cell(index+1, 1, factor_value.value_text)
        values_worksheet.add_cell(index+1, 2, factor_value.value_number).change_horizontal_alignment('rigth')
        values_worksheet.add_cell(index+1, 3, factor_value.default).change_horizontal_alignment('center')
        values_counter_line += 1
      end

      values_worksheet.change_column_width(1,38)
      values_worksheet.change_column_width(2,15)
      values_worksheet.change_column_width(3,15)
    end

    #add column border
    factors_counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        factors_worksheet[line][0].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][1].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][2].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][3].change_border(symbole.to_sym, 'thin')
        factors_worksheet[line][4].change_border(symbole.to_sym, 'thin')
      end
    end

    values_counter_line.times.each do |line|
      ["bottom", "right"].each do |symbole|
        values_worksheet[line][0].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][1].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][2].change_border(symbole.to_sym, 'thin')
        values_worksheet[line][3].change_border(symbole.to_sym, 'thin')
      end
    end

    send_data(workbook.stream.string, filename: "#{@ge_model.organization.name[0..4]}-#{@ge_model.name.gsub(" ", "_")}_ge_data-#{Time.now.strftime("%Y-%m-%d_%H-%M")}.xlsx", type: "application/vnd.ms-excel")
  end


  # Import Data with Excel files
  def import
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    tab_error = []

    if params[:file]
      if !params[:file].nil? && (File.extname(params[:file].original_filename).to_s.downcase == ".xlsx")

        #get the file data
        workbook = RubyXL::Parser.parse(params[:file].path)

        sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
        sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value", :"3" => "default" }

        #if a model exists, only factors data will be imported
        if !params[:ge_model_id].nil? && !params[:ge_model_id].empty?

          @ge_model = Ge::GeModel.find(params[:ge_model_id])
          Ge::GeFactor.destroy_all("ge_model_id = #{@ge_model.id}")

        else
          #there is no model, we will create new model from the model attributes data of the file to import
          model_sheet_order_attributes = ["name", "description", "ge_model_instance_mode", "three_points_estimation",
                                          "coeff_a", "coeff_b", "p_calculation_method", "c_calculation_method", "s_calculation_method",
                                          "ent1", "ent2", "ent3", "ent4", "sort1", "sort2", "sort3", "sort4"]

          # model_sheet_order = { :"0" => "name", :"1" => "description", :"2" => "three_points_estimation", :"3" => "enabled_input",
          #                       :"4" => "modify_theorical_effort", :"5" => "transform_size_and_effort", :"6" => "display_size_and_effort_attributes",
          #                       :"7" =>"input_pe_attribute_id", :"8" => "output_pe_attribute_id", :"9" => "coeff_a", :"10" => "coeff_b", :"11" => "p_calculation_method",
          #                       :"12" => "c_calculation_method", :"13" => "s_calculation_method", :"14" => "input_size_unit",
          #                       :"15" => "output_size_unit", :"16" => "input_effort_unit", :"17" => "output_effort_unit",
          #                       :"18" => "input_effort_standard_unit_coefficient", :"19" => "output_effort_standard_unit_coefficient" }

          model_sheet_order = Hash.new
          model_sheet_order_attributes.each_with_index do |attr_name, index|
            model_sheet_order["#{index}".to_sym] = attr_name
          end

          model_worksheet = workbook['Model']

          if !model_worksheet.nil?
            @ge_model = Ge::GeModel.new
            @ge_model.organization = @organization

            #[I18n.t(:entree1), "#{{ unit: @ge_model.ent1_unit, coeff: @ge_model.ent1_unit_coefficient, modifiable: @ge_model.ent1_is_modifiable }}"],

            model_worksheet.each_with_index do | row, index |
              row && row.cells.each do |cell|
                if cell.column == 1 && !cell.nil?
                  val = cell && cell.value
                  attr_name = model_sheet_order["#{index}".to_sym]
                  begin
                    if attr_name.in?(["ent1", "ent2", "ent3", "ent4", "sort1", "sort2", "sort3", "sort4"])
                      val_attr_value = eval(val)
                      if val_attr_value.nil?
                        @ge_model["#{attr_name}_unit"] = nil
                        @ge_model["#{attr_name}_unit_coefficient"] = nil
                        @ge_model["#{attr_name}_is_modifiable"] = nil
                      else
                        @ge_model["#{attr_name}_unit"] = val_attr_value[:unit]
                        @ge_model["#{attr_name}_unit_coefficient"] = val_attr_value[:coeff]
                        @ge_model["#{attr_name}_is_modifiable"] = val_attr_value[:modifiable]
                      end
                    else
                      @ge_model["#{attr_name}"] = val unless attr_name.nil?
                    end
                  rescue
                    # ignored
                  end
                end
              end
            end
            #save the model
            if @ge_model.save
              flash[:notice] = "Modèle créé avec succès"
            else
              existing_ge_model_name = Ge::GeModel.where(name: @ge_model.name).first
              if existing_ge_model_name
                tab_error << "Une instance du module de transformation avec le même nom '#{@ge_model.name}' existe déjà"
              else
                tab_error << "Erreur lors de l'import du modèle. \n"
                # if @ge_model.errors
                #   tab_error << @ge_model.errors.full_messages.to_sentence
                # end
              end
            end
          else
            tab_error << "Les attributs du modèle ne sont pas définis dans le fichier importé"
          end
        end

        # si pas d'erreur lors de la création du modèle
        if tab_error.empty?
          # We must have 2 sheets in this file
          filename = params[:file].original_filename
          worksheet1 = workbook['Factors']  # workbook[0]    # Sheet of the list of Factors
          worksheet2 = workbook['Values']    # Sheet of the factors values

          # feuille1 : worksheet1.dimension.ref.row_range
          worksheet1.each_with_index do |row, index|
            if index > 0
              row_factor = Hash.new

              row && row.cells.each do |cell|
                unless cell.nil?
                  val = cell && cell.value
                  #add value to table
                  key_name = sheet1_order["#{cell.column}".to_sym]
                  row_factor["#{key_name}"] = val unless key_name.nil?
                end
              end


              unless row_factor.empty?
                #Create data in factors table
                #sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
                short_name_factor = row_factor["short_name_factor"]
                factor_alias = short_name_factor.nil? ? "" : short_name_factor.gsub(/( )/, '_').downcase
                Ge::GeFactor.create(ge_model_id: @ge_model.id, short_name: short_name_factor, long_name: row_factor["long_name_factor"], factor_type: row_factor["type"],
                                    scale_prod: row_factor["scale_prod"],  data_filename: filename, description: row_factor["description"], alias: factor_alias)
              end
            end
          end

          # feuille2
          worksheet2.each_with_index do |row, index|
            if index > 0
              row_factor = Hash.new

              row && row.cells.each do |cell|
                unless cell.nil?
                  val = cell && cell.value
                  #add value to table
                  key_name = sheet2_order["#{cell.column}".to_sym]
                  row_factor["#{key_name}"] = val unless key_name.nil?
                end
              end

              unless row_factor.empty?
                #Create data in factors values table
                #sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value" }
                #FactorValues ==> :name, :alias, :value_number, :value_text, :ge_factor_id, :ge_model_id
                factor_name = row_factor["factor"]
                if !factor_name.nil? && !factor_name.empty?
                  factor_alias = factor_name.gsub(/( )/, '_').downcase
                  factors = @ge_model.ge_factors.where(alias: factor_alias)
                  unless factors.nil?
                    factor = factors.first
                    begin
                      factor_value = Ge::GeFactorValue.create(ge_model_id: @ge_model.id,
                                                              ge_factor_id: factor.id, factor_alias: factor_alias, factor_scale_prod: factor.scale_prod, factor_type: factor.factor_type,
                                                              factor_name: factor_name, value_text: row_factor["text"], value_number: row_factor["value"], default: row_factor["default"])
                    rescue
                      factor_value = Ge::GeFactorValue.create(ge_model_id: @ge_model.id,
                                                              ge_factor_id: nil,
                                                              factor_alias: "???",
                                                              factor_scale_prod: 1,
                                                              factor_type: nil,
                                                              factor_name: "???",
                                                              value_text: "???",
                                                              value_number: 1,
                                                              default: nil)
                    end
                  end
                end
              end
            end
          end
          flash[:notice] = "Les facteurs ont été importés avec succès"
        else
          flash[:error] = tab_error.join(" , ")
        end

      else
        flash[:error] =  I18n.t(:route_flag_error_4)
      end
    else
      flash[:error] =  I18n.t(:route_flag_error_17)
    end

    if @ge_model && @ge_model.save
      redirect_to ge.edit_ge_model_path(@ge_model, anchor: "tabs-2")
    else
      redirect_to request.referer + "#tabs-1" #redirect_to :back
    end
  end

  #Update the calculated effort when changing slider value
  def update_calculated_effort

    authorize! :execute_estimation_plan, @project

    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    @ge_input = @ge_model.ge_inputs.where(module_project_id: current_module_project.id).first_or_create
    @calculated = {}

    if @ge_model.coeff_a.blank? || @ge_model.coeff_b.blank?
      # Get factors values and save them in the GeInput table
      # GeInput "values" attribute is serialize as an Array of Hash  ==> [ { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... ]
      #scale_factor_sum = 0.0
      #prod_factor_product = 1.0
      #conversion_factor_product = 1.0

      #= Calculate coefficients according to the select operation method
      #default calculations methods operators for each type of factor
      p_calculation_operator = "*"
      c_calculation_operator = "*"
      s_calculation_operator = "+"

      # For P_calculation_method
      case @ge_model.p_calculation_method
        when "sum"
          prod_factor_product = 0.0
          p_calculation_operator = "+"
        when "product"
          prod_factor_product = 1.0
          p_calculation_operator = "*"
        else
          prod_factor_product = 1.0
      end

      # For C_calculation_method for conversion
      case @ge_model.c_calculation_method
        when "sum"
          conversion_factor_product = 0.0
          c_calculation_operator = "+"
        when "product"
          conversion_factor_product = 1.0
          c_calculation_operator = "*"
        else
          conversion_factor_product = 1.0
      end

      # For S_calculation_method
      case @ge_model.s_calculation_method
        when "sum"
          scale_factor_sum = 0.0
          s_calculation_operator = "+"
        when "product"
          scale_factor_sum = 1.0
          s_calculation_operator = "*"
        else
          scale_factor_sum = 0.0
      end

      scale_factors = params["S_factor"] || []
      prod_factors = params["P_factor"]  || []
      conversion_factors = params["C_factor"] || []

      @ge_input_values = Hash.new
      #Save Scale Factors data in GeInput table
      scale_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###scale_factor_sum += factor_value_number
          scale_factor_sum = scale_factor_sum.send(s_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Prod Factors multiplier data in GeInput table
      prod_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###prod_factor_product *= factor_value_number
          prod_factor_product = prod_factor_product.send(p_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Conversion Factors data in GeInput table
      conversion_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###conversion_factor_product *= factor_value_number
          conversion_factor_product = conversion_factor_product.send(c_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end
    end

    @formula = "#{prod_factor_product.to_f} (X * #{conversion_factor_product})^ #{scale_factor_sum.to_f}"

    #attribut d'entrée
    input_pe_attribute = @ge_model.input_pe_attribute
    if input_pe_attribute.nil?
      input_pe_attribute = PeAttribute.where(alias: "retained_size").first
    end
    #attribut de sortie
    output_pe_attribute = @ge_model.output_pe_attribute
    if output_pe_attribute.nil?
      output_pe_attribute = PeAttribute.where(alias: "effort").first
    end

    ### TEST
    input_attribute_ids = PeAttribute.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:id).flatten
    output_attribute_ids = PeAttribute.where(alias: Ge::GeModel::OUTPUT_ATTRIBUTES_ALIAS).map(&:id).flatten  ###input_attribute_ids

    defined_input_ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => input_pe_attribute.id, in_out: "input").first
    current_mp_estimation_values = current_module_project.estimation_values
    input_evs = current_mp_estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")
    output_evs = current_mp_estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")
    @output_attribute_evs = output_evs

    # Gestion des entrées
    input_am = current_module_project.pemodule.attribute_modules
    output_am = current_module_project.pemodule.attribute_modules

    input_size_data = Hash.new
    input_data_for_outputs = Hash.new
    out_tmp_probable = Hash.new

    outputs_evs_coeff = Hash.new

    output_evs.each do |output_ev|
      input_data_for_outputs["#{output_ev.pe_attribute.id}"] = Hash.new
      out_tmp_probable["#{output_ev.id}"] = Array.new

      current_output_effort_unit_coefficient = get_ge_input_output_standard_unit_coefficient(@ge_model, output_ev)
      outputs_evs_coeff["#{output_ev.id}"] = current_output_effort_unit_coefficient
    end

    ### FIN TEST

    ###current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      #ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first

      unless input_evs.nil? || output_evs.nil?

        ["low", "most_likely", "high"].each do |level|

          input_size_data[level] = Hash.new
          input_data_for_outputs[level] = Hash.new
          @calculated[level] = Hash.new

          # Gestion des entrées
          input_evs.each do |input_ev|
            if @ge_model.three_points_estimation?
              size = params["retained_size_#{level}"]["#{input_ev.id}"].to_f
            else
              size = params["retained_size_most_likely"]["#{input_ev.id}"].to_f
            end

            input_size_data[level]["#{input_ev.id}"] = size
            input_data_for_outputs[level]["#{input_ev.pe_attribute.id}"] = size
          end

          # Gestion des sorties
          output_evs.each do |output_ev|
            begin
              corresponding_input_attribute_alias = Ge::GeModel::CORRESPONDING_INPUTS_WITH_OUTPUTS[output_ev.pe_attribute.alias]
              corresponding_input_attribute = PeAttribute.where(alias: corresponding_input_attribute_alias).first
              size = input_data_for_outputs[level]["#{corresponding_input_attribute.id}"]
            rescue
              size = 0
            end

            case @ge_model.ge_model_instance_mode

              when "standard"
                if !@ge_model.coeff_a.blank? && !@ge_model.coeff_b.blank?
                  effort = @ge_model.coeff_a * size ** @ge_model.coeff_b   #Using "a" and "b" coefficients
                else
                  #The effort value will be calculated as : Effort = p * (Taille * c)^s  # with: s = sum of scale factors ; p = multiply of prod factors and c = product of conversion factors
                  effort = (prod_factor_product * ((size * conversion_factor_product) ** scale_factor_sum))
                end

                effort = effort * outputs_evs_coeff["#{output_ev.id}"]

                @calculated["#{level}"]["#{output_ev.id}"] = effort
                out_tmp_probable["#{output_ev.id}"] << effort

              when "defects_calculation"
                ent1_attr = PeAttribute.where(alias: "ent1").first
                size = input_data_for_outputs[level]["#{ent1_attr.id}"] #input_data_for_outputs[level]["#{input_pe_attribute.id}"]
                defect = (size * scale_factor_sum * conversion_factor_product)
                total_remaining_defects = defect * prod_factor_product

                defect = defect * outputs_evs_coeff["#{output_ev.id}"]
                total_remaining_defects = total_remaining_defects * outputs_evs_coeff["#{output_ev.id}"]

                case output_ev.pe_attribute.alias
                  when "sort1"
                    @calculated["#{level}"]["#{output_ev.id}"] = defect
                    out_tmp_probable["#{output_ev.id}"] << defect

                  when "sort2"
                    @calculated["#{level}"]["#{output_ev.id}"] = total_remaining_defects
                    out_tmp_probable["#{output_ev.id}"] << total_remaining_defects
                  else
                    # type code here
                end

              else
                # type code here
            end
          end
        end

        # calculate probable value
        @calculated_ratio = Hash.new
        @calculated["probable"] = Hash.new
        output_evs.each do |output_ev|

          #effort probable
          probable_value = (out_tmp_probable["#{output_ev.id}"][0].to_f + (4 * out_tmp_probable["#{output_ev.id}"][1].to_f) + out_tmp_probable["#{output_ev.id}"][2].to_f)/6
          @calculated["probable"]["#{output_ev.id}"] = probable_value

          # calculate ratio
          corresponding_input_attribute_alias = Ge::GeModel::CORRESPONDING_INPUTS_WITH_OUTPUTS[output_ev.pe_attribute.alias]
          corresponding_input_attribute = PeAttribute.where(alias: corresponding_input_attribute_alias).first
          corresponding_input_ev = input_evs.where(pe_attribute_id: corresponding_input_attribute.id).first

          current_output_effort_unit_coefficient = get_ge_input_output_standard_unit_coefficient(@ge_model, output_ev)

          begin
            input_low = input_size_data["low"]["#{corresponding_input_ev.id}"]
            input_ml = input_size_data["most_likely"]["#{corresponding_input_ev.id}"]
            input_high = input_size_data["high"]["#{corresponding_input_ev.id}"]

            input_probable = (input_low.to_f + (4*input_ml.to_f) + input_high.to_f) / 6

            ratio_value = (input_probable==0) ? nil : (probable_value / current_output_effort_unit_coefficient) / input_probable
          rescue
            ratio_value = nil
          end
          @calculated_ratio["#{output_ev.id}"] = ratio_value
        end
      end
    ###end

    respond_to do |format|
      format.html
      format.js { render layout: false, content_type: 'text/javascript' }
    end
  end

  # Get the input or output coefficient
  def get_ge_input_output_standard_unit_coefficient(ge_model, ev)
    begin
      current_unit_coefficient = ge_model.send("#{ev.pe_attribute.alias}_unit_coefficient")
      current_unit_coefficient.nil? ? (current_unit_coefficient = 1) : (current_unit_coefficient = current_unit_coefficient.to_f)
    rescue
      current_unit_coefficient = 1
    end

    current_unit_coefficient
  end


  #Save effort according to the selected factors values
  def save_efforts
    authorize! :execute_estimation_plan, @project

    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    @ge_input = @ge_model.ge_inputs.where(module_project_id: current_module_project.id).first_or_create

    if @ge_model.coeff_a.blank? || @ge_model.coeff_b.blank?
      # Get factors values and save them in the GeInput table
      # GeInput "values" attribute is serialize as an Array of Hash  ==> [ { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... ]
      ###scale_factor_sum = 0.0    ###prod_factor_product = 1.0   ###conversion_factor_product = 1.0

      #======= Calculate coefficients according to the select operation method
      #default calculations methods operators for each type of factor
      p_calculation_operator = "*"
      c_calculation_operator = "*"
      s_calculation_operator = "+"

      # For P_calculation_method
      case @ge_model.p_calculation_method
        when "sum"
          prod_factor_product = 0.0
          p_calculation_operator = "+"
        when "product"
          prod_factor_product = 1.0
          p_calculation_operator = "*"
        else
          prod_factor_product = 1.0
      end

      # For C_calculation_method for conversion
      case @ge_model.c_calculation_method
        when "sum"
          conversion_factor_product = 0.0
          c_calculation_operator = "+"
        when "product"
          conversion_factor_product = 1.0
          c_calculation_operator = "*"
        else
          conversion_factor_product = 1.0
      end

      # For S_calculation_method
      case @ge_model.s_calculation_method
        when "sum"
          scale_factor_sum = 0.0
          s_calculation_operator = "+"
        when "product"
          scale_factor_sum = 1.0
          s_calculation_operator = "*"
        else
          scale_factor_sum = 0.0
      end

      scale_factors = params["S_factor"] || []
      prod_factors = params["P_factor"]  || []
      conversion_factors = params["C_factor"] || []

      @ge_input_values = Hash.new
      #Save Scale Factors data in GeInput table according to selected calculation method
      scale_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###scale_factor_sum += factor_value_number
          scale_factor_sum = scale_factor_sum.send(s_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Prod Factors multiplier data in GeInput table according to selected calculation method
      prod_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###prod_factor_product *= factor_value_number
          prod_factor_product = prod_factor_product.send(p_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Save Conversion Factors data in GeInput table according to selected calculation method
      conversion_factors.each do |key, factor_value_id|
        factor_value = Ge::GeFactorValue.find(factor_value_id)
        unless factor_value.nil?
          factor_value_number = factor_value.value_number
          ###conversion_factor_product *= factor_value_number
          conversion_factor_product = conversion_factor_product.send(c_calculation_operator, factor_value_number)
          value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
          @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
        end
      end

      #Update GeInput
      @formula = "#{prod_factor_product.to_f} (X * #{conversion_factor_product})^ #{scale_factor_sum.to_f}"
      @ge_input.formula = @formula
      @ge_input.s_factors_value = scale_factor_sum
      @ge_input.p_factors_value = prod_factor_product
      @ge_input.c_factors_value = conversion_factor_product
      @ge_input.values = @ge_input_values
      @ge_input.save
    end

   #attribut d'entrée
    input_pe_attribute = @ge_model.input_pe_attribute
    if input_pe_attribute.nil?
      input_pe_attribute = PeAttribute.where(alias: "retained_size").first
    end
    #attribut de sortie
    output_pe_attribute = @ge_model.output_pe_attribute
    if output_pe_attribute.nil?
      output_pe_attribute = PeAttribute.where(alias: "effort").first
    end

    #input_attribute_ids = [input_pe_attribute.id]
    #output_attribute_ids = [output_pe_attribute.id]

    input_attribute_ids = PeAttribute.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:id).flatten
    output_attribute_ids = PeAttribute.where(alias: Ge::GeModel::TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS).map(&:id).flatten #input_attribute_ids

    defined_input_ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => input_pe_attribute.id, in_out: "input").first
    #output_evs = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => output_pe_attribute.id, in_out: "output")#.first
    current_mp_estimation_values = current_module_project.estimation_values

    input_evs = current_mp_estimation_values.where(pe_attribute_id: input_attribute_ids, in_out: "input")
    output_evs = current_mp_estimation_values.where(pe_attribute_id: output_attribute_ids, in_out: "output")

   # Gestion des entrées
    input_am = current_module_project.pemodule.attribute_modules
    output_am = current_module_project.pemodule.attribute_modules

    input_size_data = Hash.new
    input_data_for_outputs = Hash.new
    output_evs.each do |output_ev|
      input_data_for_outputs["#{output_ev.pe_attribute.id}"] = Hash.new
    end


    unless input_am.nil?

      unless input_evs.nil? || input_evs.empty?
        input_evs.each do |input_ev|

          tmp_prbl = Array.new

          input_size_data["#{input_ev.id}"] = Hash.new
          input_data_for_outputs["#{input_ev.pe_attribute.id}"] = Hash.new

          ["low", "most_likely", "high"].each do |level|
            if @ge_model.three_points_estimation?
              size = params["retained_size_#{level}"]["#{input_ev.id}"].to_f
            else
              size = params["retained_size_most_likely"]["#{input_ev.id}"].to_f
            end

            # We should multiply with the standard_unit_coeff before saving the value in DB
            input_effort_unit_coefficient = @ge_model.send("#{input_ev.pe_attribute.alias}_unit_coefficient")
            input_effort_unit_coefficient.nil? ? (input_effort_unit_coefficient = 1) : (input_effort_unit_coefficient = input_effort_unit_coefficient.to_f)
            size = size * input_effort_unit_coefficient

            input_size_data["#{input_ev.id}"][level] = size
            input_data_for_outputs["#{input_ev.pe_attribute.id}"][level] = size

            input_ev.send("string_data_#{level}")[current_component.id] = size
            input_ev.save
            tmp_prbl << input_ev.send("string_data_#{level}")[current_component.id]
          end

          input_probable_value = ((tmp_prbl[0].to_f + (4 * tmp_prbl[1].to_f) + tmp_prbl[2].to_f)/6)
          input_ev.update_attribute(:"string_data_probable", { current_component.id => input_probable_value } )
        end
      end
    end


    # Gestion des sorties
    unless output_am.nil?
      #tmp_prbl = Array.new

      unless output_evs.nil? || output_evs.empty?

        # Le mode de calcul : Standard ou Calcul des defauts avec les defauts residuels
        case @ge_model.ge_model_instance_mode

          # Mode standard
          when "standard"

            output_evs.each do |output_ev|

              tmp_prbl = Array.new
              current_output_effort_unit_coefficient = get_ge_input_output_standard_unit_coefficient(@ge_model, output_ev)
              corresponding_input_attribute_alias = Ge::GeModel::CORRESPONDING_INPUTS_WITH_OUTPUTS[output_ev.pe_attribute.alias]
              corresponding_input_attribute = PeAttribute.where(alias: corresponding_input_attribute_alias).first
              is_modifiable = @ge_model.send("#{output_ev.pe_attribute.alias}_is_modifiable")

              ["low", "most_likely", "high"].each do |level|

                begin
                  # Gestions des attributs
                  size = input_data_for_outputs["#{corresponding_input_attribute.id}"][level]
                rescue
                  size = 0
                end

                if !@ge_model.coeff_a.blank? && !@ge_model.coeff_b.blank?
                  effort = @ge_model.coeff_a * size ** @ge_model.coeff_b   #Using "a" and "b" coefficients

                  @ge_input.formula = "#{@ge_model.coeff_a} X ^ #{@ge_model.coeff_b}"
                  @ge_input.save
                else
                  #The effort value will be calculated as : Effort = p * Taille^s (# with: s = sum of scale factors and  p = multiply of prod factors)
                  effort = prod_factor_product * ((size * conversion_factor_product) ** scale_factor_sum)
                end

                if is_modifiable == true
                  if @ge_model.three_points_estimation?
                    output_value = params["effort_#{level}"]["#{output_ev.id}"]
                  else
                    output_value = params["effort_most_likely"]["#{output_ev.id}"]
                  end

                  output_value.nil? ? (output_value = nil) : (output_value = output_value.to_f)
                  if output_value != effort
                    effort = output_value
                  end
                end

                output_calculated_value = effort * current_output_effort_unit_coefficient

                output_ev.send("string_data_#{level}")[current_component.id] = output_calculated_value
                output_ev.save
                tmp_prbl << output_ev.send("string_data_#{level}")[current_component.id]
              end

              output_probable_value = ((tmp_prbl[0].to_f + (4 * tmp_prbl[1].to_f) + tmp_prbl[2].to_f) / 6 )
              output_ev.update_attribute(:"string_data_probable", { current_component.id => output_probable_value } )
            end

          # Calcul des defauts
          when "defects_calculation"
            #begin
              #Introduced defects
              entree1_ev = input_evs.includes(:pe_attribute).where(:pe_attributes => { alias: "ent1"}, in_out: "input").first
              sortie1_ev = output_evs.includes(:pe_attribute).where(:pe_attributes => { alias: "sort1"}, in_out: "output").first
              sortie2_ev = output_evs.includes(:pe_attribute).where(:pe_attributes => { alias: "sort2"}, in_out: "output").first

              tmp_prbl_s1 = Array.new
              tmp_prbl_s2 = Array.new

              ["low", "most_likely", "high"].each do |level|
                begin
                  # Gestions des attributs
                  size = input_data_for_outputs["#{entree1_ev.pe_attribute.id}"][level]
                rescue
                  size = 0
                end

                total_defects = size * scale_factor_sum * conversion_factor_product
                total_remaining_defects = total_defects * prod_factor_product

                #introduced defect
                sortie1_ev.send("string_data_#{level}")[current_component.id] = total_defects
                sortie1_ev.save
                tmp_prbl_s1 << total_defects

                #Remaining defects
                sortie2_ev.send("string_data_#{level}")[current_component.id] = total_remaining_defects
                sortie2_ev.save
                tmp_prbl_s2 << total_remaining_defects

              end

              s1_probable_value = ((tmp_prbl_s1[0].to_f + 4 * tmp_prbl_s1[1].to_f + tmp_prbl_s1[2].to_f)/6)
              sortie1_ev.update_attribute(:"string_data_probable", { current_component.id => s1_probable_value } )

              s2_probable_value = ((tmp_prbl_s2[0].to_f + 4 * tmp_prbl_s2[1].to_f + tmp_prbl_s2[2].to_f)/6)
              sortie2_ev.update_attribute(:"string_data_probable", { current_component.id => s2_probable_value } )

            #rescue
            #end
          else
            # type code here
        end
      end
    end

    @module_project = current_module_project
    @project = @module_project.project

    ViewsWidget::update_field(@module_project, @current_organization, @project, current_component)

    # Reset all view_widget results
    ViewsWidget.reset_nexts_mp_estimation_values(@module_project, current_component)
    @module_project.all_nexts_mp_with_links.each do |module_project|
      ViewsWidget::update_field(module_project, @current_organization, @project, current_component, true)
    end

    redirect_to main_app.dashboard_path(@project)
  end


  #duplicate GeModel
  def duplicate
    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    new_ge_model = @ge_model.amoeba_dup

    new_copy_number = @ge_model.copy_number.to_i+1
    new_ge_model.name = "#{@ge_model.name}(#{new_copy_number})"
    new_ge_model.copy_number = 0
    @ge_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_ge_model.transaction do
      if new_ge_model.save
        @ge_model.save

        #Then copy the factor values
        new_ge_model.ge_factors.each do |factor|
          #get the factor values for each factor of new model

          # get the original factor from copy_id
          parent_factor = Ge::GeFactor.find(factor.copy_id)

          if parent_factor
            parent_factor.ge_factor_values.each do |parent_factor_value|
              new_factor_value =  parent_factor_value.dup
              new_factor_value.ge_model_id = new_ge_model.id
              new_factor_value.ge_factor_id = factor.id
              new_factor_value.save
            end
          end
        end

        flash[:notice] = "Modèle copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie du modèle"
      end
    end

    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end


  def change_ge_model_instance_mode
    @traductions = { "ent1" => "entree1", "ent2" => "entree2", "ent3" => "entree3", "ent4" => "entree4",
                     "sort1" => "sortie1", "sort2" => "sortie2", "sort3" => "sortie3", "sort4" => "sortie4" }

    @ge_model = Ge::GeModel.find(params['ge_model_id'])
    @ge_model_instance_mode = params['ge_model_instance_mode']

    # if @ge_model_instance_mode == "defects_calculation"
    #   @inputs_attributes_alias = PeAttribute.where(alias: Ge::GeModel::DEFECTS_INPUT_EFFORTS_ALIAS).map(&:alias).flatten
    #   @ouputs_attributes_alias = PeAttribute.where(alias: Ge::GeModel::DEFECTS_TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS).map(&:alias).flatten
    # else
    #   @inputs_attributes_alias = PeAttribute.where(alias: Ge::GeModel::INPUT_EFFORTS_ALIAS).map(&:alias).flatten
    #   @ouputs_attributes_alias = PeAttribute.where(alias: Ge::GeModel::TRANSFORMATION_OUTPUT_ATTRIBUTES_ALIAS).map(&:alias).flatten
    # end
  end

end
