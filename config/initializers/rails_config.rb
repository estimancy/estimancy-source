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

#This load the file that contain the rails protected parameters

SETTINGS = YAML.load(IO.read(Rails.root.join("config", "sensitive_settings.yml")))
#ENV.update YAML.load_file('config/sensitive_settings.yml')[Rails.env] rescue {}
#ENV.update YAML.load(IO.read(Rails.root.join("config", "sensitive_settings.yml")))[Rails.env] rescue {}

#You need to set the following parameters wih your own values in your "config/sensitive_settings.yml" file that you have to create locally

# SECRET_TOKEN: your_generated_token_value
#
# SMTP_ADDRESS: smtp.sample.com
#
# SMTP_PORT: your_SMTP_Port_Number
#
# SMTP_DOMAIN: your_domain.com
#
# SMTP_USER_NAME: your_SMTP_username
#
# SMTP_PASSWORD: your_SMTP_password
#
