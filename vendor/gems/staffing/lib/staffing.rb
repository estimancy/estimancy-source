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

require "staffing/engine"
require "staffing/version"

# Module Equipes : Durée et taille des équipes
# Entrées: au moins l'Effort (E)
# Sorties : Effort calculé, Staffing théorique, Staffinf calculé, Max staffing, Durée, Tableau de valeurs de staffing de la courbe
# En abscisse : Première date = date de début du projet

module Staffing
  class Staffing
    attr_accessor :effort, :duration

    def initialize

    end
  end
end
