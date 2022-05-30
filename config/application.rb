#encoding: utf-8
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

require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end



module Projestimate
  class Application < Rails::Application

    config.reload_plugins = true

    config.autoload_paths += Dir["#{config.root}/vendor/gems/guw/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/ge/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/operation/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/skb/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/kb/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/staffing/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/expert_judgement/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/effort_breakdown/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/wbs_activity_completion/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/sample_model/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/sandbox/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/effort_balancing/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/initialization/lib"]

    config.autoload_paths += %W(#{config.root}/vendor/gems/guw/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/operation/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/ge/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/skb/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/kb/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/staffing/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/expert_judgement/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/effort_breakdown/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/wbs_activity_completion/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/sample_model/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/sandbox/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/effort_balancing/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/initialization/lib)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << File.join(config.root, "lib")

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :module_project_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('locales','devise','*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('locales','simple_form','*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.paths << Rails.root.join("app", "assets", "font")
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    I18n.config.enforce_available_locales = false

    # Handle errors messages by estimancy routes
    config.exceptions_app = self.routes

    #config.force_ssl = true

    # these lines go within the Application class definition
    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false, :fixture_replacement => :factory_girl, :view_specs => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    config.active_record.raise_in_transactional_callbacks = true

    # Global constante declaration
    ALPHABETICAL = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    INITIALIZATION = "initialization"
    EFFORT_PERSON_HOUR = "effort_person_hour"
    EFFORT = "effort"
    EFFORT_PERSON_WEEK = "effort_person_week"
    DELAY = "delay"
    STAFFING = "staffing"
    COST = "cost"

    # Modules with Factors
    COCOMO_ADVANCED = "cocomo_advanced"
    COCOMO_INTERMEDIATE = "cocomo_advanced"
    COCOMO_EXPERT = "cocomo_expert"
    COCOMO_II = "cocomo_expert"
    MODULES_WITH_FACTORS = [COCOMO_INTERMEDIATE, COCOMO_ADVANCED, COCOMO_II, COCOMO_EXPERT]

    EFFORT_BALANCING = "effort_balancing"
    EFFORT_BREAKDOWN = "effort_breakdown"
    SIZE_BALANCING = "size_balancing"
    BALANCING_MODULE = "balancing_module"
    BALANCING_MODULES_NAME = [ EFFORT_BALANCING, SIZE_BALANCING ]

    # icones for widgets
    #ICON_CLASSES = ["icon-euro", "icon-usd", "icon-gbp", "icon-user", "icon-users", "icon-user-md", "icon-bell", "fa fa-clock-o", "icon-dashboard", "icon-calendar", "icon-bug", " icon-bomb", "icon-warning", "icon-line-chart", "icon-pie-chart", "icon-area-chart", "icon-bar-chart"]
    #ICON_CLASSES = ["icon-euro", "icon-usd", "icon-gbp", "fa-money", "icon-user", "icon-group", "icon-time", "icon-bell", "icon-calendar", "icon-eye-open", "icon-eye-close", "fa-bomb", "icon-bug", "icon-warning-sign", "icon-exclamation-sign", "icon-question-sign", "icon-fire", "fa-minus-circle", "icon-arrow-right", "icon-arrow-up", "icon-arrow-down", "icon-share-alt", "icon-comment", "icon-dashboard", "fa-wrench", "fa-cog", "fa-cogs", "fa-database", "fa-home", "fa-info", "fa-line-chart", "fa-pie-chart", "fa-area-chart", "fa-bar-chart"]
    ICON_CLASSES = [["Euro", "fa-euro"], ["US-Dollar", "fa-usd"], ["GB-Pound", "fa-gbp"], ["User", "fa-user"], ["Users", "fa-users"], ["Clock", "fa-clock-o"], ["Tachometer", "fa-tachometer"], ["Bell", "fa-bell"], ["Calendar", "fa-calendar"], ["Eye-open", "fa-eye"], ["Eye-close", "fa-eye-slash"],
                    ["Bug", "fa-bug"], ["Bomb", "fa-bomb"], ["Warning", "fa-warning"], ["Exclamation mark", "fa-exclamation"], ["Exclamation mark circle", "fa-exclamation-circle"], ["Question mark", "fa-question"], ["Question mark circle", "fa-question-circle"], ["Fire", "fa-fire"], ["Minus circle", "fa-minus-circle"], ["Arrow-right", "fa-arrow-right"],
                    ["Arrow-up", "fa-arrow-up"], ["Arrow-down", "fa-arrow-down"], ["Arrow-left", "fa-arrow-left"], ["Share", "fa-share-alt"], ["Comment", "fa-comment"], ["Dashboard", "fa-dashboard"], ["Wrench", "fa-wrench"], ["Cog", "fa-cog"], ["Cogs", "fa-cogs"],
                    ["Database", "fa-database"], ["Home", "fa-home"], ["Info", "fa-info"], ["Line chart", "fa-line-chart"], ["Pie chart", "fa-pie-chart"], ["Area chart", "fa-area-chart"], ["Bar chart", "fa-bar-chart"], ["Flag", "fa-flag"]
                    ]

    NEW_ICON_CLASSES = [["Euro", "fa-euro"], ["US-Dollar", "fa-usd"], ["GB-Pound", "fa-gbp"], ["User", "fa-user"], ["Users", "fa-users"], ["Clock", "fa-clock-o"], ["Tachometer", "fa-tachometer"], ["Bell", "fa-bell"], ["Calendar", "fa-calendar"], ["Eye-open", "fa-eye"], ["Eye-close", "fa-eye-slash"],
                    ["Bug", "fa-bug"], ["Bomb", "fa-bomb"], ["Warning", "fa-warning"], ["Exclamation mark", "fa-exclamation"], ["Exclamation mark circle", "fa-exclamation-circle"], ["Question mark", "fa-question"], ["Question mark circle", "fa-question-circle"], ["Fire", "fa-fire"], ["Minus circle", "fa-minus-circle"], ["Arrow-right", "fa-arrow-right"],
                    ["Arrow-up", "fa-arrow-up"], ["Arrow-down", "fa-arrow-down"], ["Arrow-left", "fa-arrow-left"], ["Share", "fa-share-alt"], ["Comment", "fa-comment"], ["Dashboard", "fa-dashboard"], ["Wrench", "fa-wrench"], ["Cog", "fa-cog"], ["Cogs", "fa-cogs"],
                    ["Database", "fa-database"], ["Home", "fa-home"], ["Info", "fa-info"], ["Line chart", "fa-line-chart"], ["Pie chart", "fa-pie-chart"], ["Area chart", "fa-area-chart"], ["Bar chart", "fa-bar-chart"], ["Flag", "fa-flag"]
    ]

    WIDGETS_TYPE = [["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"],
                           ["Effort per phase : table", "table_effort_per_phase"], ["Effort per phase : histogram", "histogram_effort_per_phase"], ["Effort per phase : pie chart", "pie_chart_effort_per_phase"],
                           ["Cost per phase : table", "table_cost_per_phase"], ["Cost per phase : histogram", "histogram_cost_per_phase"], ["Cost per phase : pie chart", "pie_chart_cost_per_phase"],
                           ["Effort per phases & profiles : table", "effort_per_phases_profiles_table"], ["Cost per phases & profiles : table", "cost_per_phases_profiles_table"],
                           ["Effort per phases & profiles : Stacked bar chart", "stacked_bar_chart_effort_per_phases_profiles"], ["Cost per phases & profiles : Stacked bar chart", "stacked_bar_chart_cost_per_phases_profiles"]
    ]

    GLOBAL_WIDGETS_TYPE_SAVE1 = [ ["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ]

    BREAKDOWN_WIDGETS_TYPE_SAVE1 = [ ["Effort per phase : table", "table_effort_per_phase"], ["Effort per phase : histogram", "histogram_effort_per_phase"], ["Effort per phase : pie chart", "pie_chart_effort_per_phase"],
                               ["Cost per phase : table", "table_cost_per_phase"], ["Cost per phase : histogram", "histogram_cost_per_phase"], ["Cost per phase : pie chart", "pie_chart_cost_per_phase"],
                               ["Effort per phases & profiles : table", "effort_per_phases_profiles_table"], ["Cost per phases & profiles : table", "cost_per_phases_profiles_table"],
                               ["Effort per phases & profiles : Stacked bar chart", "stacked_bar_chart_effort_per_phases_profiles"], ["Cost per phases & profiles : Stacked bar chart", "stacked_bar_chart_cost_per_phases_profiles"]
                            ]

    # Avant Google chart
    GLOBAL_WIDGETS_TYPE_LAST = [ ["", [  ["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ] ] ]

    BREAKDOWN_WIDGETS_TYPE_LAST = [
                               ["", [  ["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ] ],
                               ["Effort per phase", [ ["Table", "table_effort_per_phase"], ["Table without active phase", "table_effort_per_phase_without_zero"], ["Histogram", "histogram_effort_per_phase"], ["Pie chart", "pie_chart_effort_per_phase"] ] ],
                               ["Cost per phase", [ ["Table", "table_cost_per_phase"], ["Table without active phase", "table_cost_per_phase_without_zero"], ["Histogram", "histogram_cost_per_phase"], ["Pie chart", "pie_chart_cost_per_phase"] ] ],
                               ["Effort per phases and profiles", [ ["Table", "effort_per_phases_profiles_table"], ["Table without active phase", "effort_per_phases_profiles_table_without_zero"], ["Stacked bar chart", "stacked_bar_chart_effort_per_phases_profiles"] ] ],
                               ["Cost per phases and profiles", [ ["Table", "cost_per_phases_profiles_table"], ["Table without active phase", "cost_per_phases_profiles_table_without_zero"], ["Stacked bar chart", "stacked_bar_chart_cost_per_phases_profiles"] ] ]
    ]

    # Avec Google chart
    GLOBAL_WIDGETS_TYPE = [ ["", [  ["Simple text", "text"], ["Histogram", "bar_chart"] ] ] ]

    BREAKDOWN_WIDGETS_TYPE = [
        ["", [  ["Simple text", "text"], ["Histogram", "bar_chart"] ] ],
        ["Effort per phase", [ ["Table", "table_effort_per_phase"], ["Table without active phase", "table_effort_per_phase_without_zero"], ["Histogram", "histogram_effort_per_phase"], ["Diagramme en camembert", "pie_chart_effort_per_phase"] ] ],
        ["Cost per phase", [ ["Table", "table_cost_per_phase"], ["Table without active phase", "table_cost_per_phase_without_zero"], ["Histogram", "histogram_cost_per_phase"], ["Diagramme en camembert", "pie_chart_cost_per_phase"] ] ],
        ["Effort per phases and profiles", [ ["Table", "effort_per_phases_profiles_table"], ["Table without active phase", "effort_per_phases_profiles_table_without_zero"], ["Histogram empilé ", "stacked_bar_chart_effort_per_phases_profiles"], ["Histogram groupé", "stacked_grouped_bar_chart_effort_per_phases_profiles"] ] ],
        ["Cost per phases and profiles", [ ["Table", "cost_per_phases_profiles_table"], ["Table without active phase", "cost_per_phases_profiles_table_without_zero"], ["Histogram empilé", "stacked_bar_chart_cost_per_phases_profiles"], ["Histogram groupé", "stacked_grouped_bar_chart_cost_per_phases_profiles"]] ],

        ["Effort & Cost", [ ["Effort & Cost Table / phase", "table_effort_and_cost_per_phase"], ["Effort & Cost Table / without active phase", "table_effort_and_cost_per_phase_without_zero"],
                            ["Effort & Cost Table / phase / profils", "table_effort_and_cost_per_phases_profiles"], ["Effort & Cost Table / phase / profils sans phases à zéro", "table_effort_and_cost_per_phases_profiles_without_zero"]] ]
    ]

    BREAKDOWN_EFFORT_WIDGETS_TYPE = [
        ["", [  ["Simple text", "text"], ["Histogram", "bar_chart"] ] ],
        ["Effort per phase", [ ["Table", "table_effort_per_phase"], ["Table without active phase", "table_effort_per_phase_without_zero"], ["Histogram", "histogram_effort_per_phase"], ["Diagramme en camembert", "pie_chart_effort_per_phase"] ] ],
        ["Effort per phases and profiles", [ ["Table", "effort_per_phases_profiles_table"], ["Table without active phase", "effort_per_phases_profiles_table_without_zero"], ["Histogram empilé ", "stacked_bar_chart_effort_per_phases_profiles"], ["Grouped Histogram", "stacked_grouped_bar_chart_effort_per_phases_profiles"] ] ],

        ["Effort & Cost", [ ["Effort & Cost Table / phase", "table_effort_and_cost_per_phase"], ["Effort & Cost Table / without active phase", "table_effort_and_cost_per_phase_without_zero"],
                            ["Effort & Cost Table / phase / profils", "table_effort_and_cost_per_phases_profiles"], ["Effort & Cost Table / phase / profils sans phases à zéro", "table_effort_and_cost_per_phases_profiles_without_zero"]] ]
    ]

    BREAKDOWN_COST_WIDGETS_TYPE = [
        ["", [  ["Simple text", "text"], ["Histogram", "bar_chart"] ] ],
        ["Cost per phase", [ ["Table", "table_cost_per_phase"], ["Table without active phase", "table_cost_per_phase_without_zero"], ["Histogram", "histogram_cost_per_phase"], ["Diagramme en camembert", "pie_chart_cost_per_phase"] ] ],
        ["Cost per phases and profiles", [ ["Table", "cost_per_phases_profiles_table"], ["Table without active phase", "cost_per_phases_profiles_table_without_zero"], ["Histogram empilé", "stacked_bar_chart_cost_per_phases_profiles"], ["Grouped Histogram", "stacked_grouped_bar_chart_cost_per_phases_profiles"]] ],

        ["Effort & Cost", [ ["Effort & Cost Table / phase", "table_effort_and_cost_per_phase"], ["Effort & Cost Table / without active phase", "table_effort_and_cost_per_phase_without_zero"],
                            ["Effort & Cost Table / phase / profils", "table_effort_and_cost_per_phases_profiles"], ["Effort & Cost Table / phase / profils sans phases à zéro", "table_effort_and_cost_per_phases_profiles_without_zero"]] ]
    ]

    # Non concern value : "text", table_effort_per_phase", "effort_per_phases_profiles_table", "cost_per_phases_profiles_table",
    DELETE_MIN_MAX_ON_WIDGET_TYPE = [ "line_chart", "bar_chart", "area_chart", "pie_chart", "timeline", "stacked_bar_chart", "histogram_effort_per_phase", "pie_chart_effort_per_phase", "histogram_cost_per_phase",
                                      "pie_chart_cost_per_phase", "stacked_bar_chart_effort_per_phases_profiles",  "stacked_bar_chart_cost_per_phases_profiles" ]

    # Widgets Effort display Unit
    EFFORT_DISPLAY_UNIT = ["organization_effort_unit", "module_instance_effort_unit"]
    EFFORT_ATTRIBUTES_ALIAS = ["effort", "theoretical_effort", "retained_effort", "E1", "E2", "E3", "E4", "retained_size"]

    CHART_COLORS = ['#e5e4e2', '#C5A5CF', '#b87333', 'silver', 'gold', '#76A7FA', '#703593', '#871B47', '#C5A5CF', '#BC5679']
  end
end

APP_CONFIG = YAML.load(IO.read(Rails.root.join("config", "sensitive_settings.yml")))
