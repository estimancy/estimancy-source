#encoding: utf-8
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

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Projestimate::Application.initialize!
#config.autoload_paths << File.join(config.root, "lib")

#Encoding.default_external = Encoding::UTF_8

COMMIT_VERSION = `git rev-list -n1 --abbrev-commit HEAD` unless defined? COMMIT_VERSION
COMMIT_DATE = `git log -1 --format="%cd"`

