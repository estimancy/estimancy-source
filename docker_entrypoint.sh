#!/bin/bash -xe

# configuring sensitive_settings.yml
sed -i "s/SECRET_TOKEN_TO_REPLACE/${SECRET_TOKEN}/g" config/sensitive_settings.yml
sed -i "s/SMTP_ADDRESS_TO_REPLACE/${SMTP_ADDRESS}/g" config/sensitive_settings.yml
if [ -z "${SMTP_PORT}" ]; then SMTP_PORT="587"; fi
sed -i "s/SMTP_PORT_TO_REPLACE/${SMTP_PORT}/g" config/sensitive_settings.yml
if [ -z "${SMTP_AUTHENTICATION}" ]; then SMTP_AUTHENTICATION=":login"; fi
sed -i "s/SMTP_AUTHENTICATION_TO_REPLACE/${SMTP_AUTHENTICATION}/g" config/sensitive_settings.yml
sed -i "s/SMTP_DOMAIN_TO_REPLACE/${SMTP_DOMAIN}/g" config/sensitive_settings.yml
sed -i "s/SMTP_USER_NAME_TO_REPLACE/${SMTP_USER_NAME}/g" config/sensitive_settings.yml
sed -i "s/SMTP_PASSWORD_TO_REPLACE/${SMTP_PASSWORD}/g" config/sensitive_settings.yml
sed -i "s/HOST_URL_TO_REPLACE/${HOST_URL}/g" config/sensitive_settings.yml
sed -i "s/SMTP_FROM_TO_REPLACE/${SMTP_FROM}/g" config/sensitive_settings.yml

# launching server
rails server --binding=0.0.0.0 -e ${RAILS_ENV} $@
