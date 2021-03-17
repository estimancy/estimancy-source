#!/bin/bash -xe

# configuring database.yml
sed -i 's/${RAILS_ENV}/RAILS_ENV_TO_REPLACE/g' config/database.yml

# configuring sensitive_settings.yml
sed -i 's/${SECRET_TOKEN}/SECRET_TOKEN_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${SMTP_ADDRESS}/SMTP_ADDRESS_TO_REPLACE/g' config/sensitive_settings.yml
if [ -z "${SMTP_PORT}" ]; then SMTP_PORT="587"; fi
sed -i 's/${SMTP_PORT}/SMTP_PORT_TO_REPLACE/g' config/sensitive_settings.yml
if [ -z "${SMTP_AUTHENTICATION}" ]; then SMTP_AUTHENTICATION=":login"; fi
sed -i 's/${SMTP_AUTHENTICATION}/SMTP_AUTHENTICATION_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${SMTP_DOMAIN}/SMTP_DOMAIN_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${SMTP_USER_NAME}/SMTP_USER_NAME_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${SMTP_PASSWORD}/SMTP_PASSWORD_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${HOST_URL}/HOST_URL_TO_REPLACE/g' config/sensitive_settings.yml
sed -i 's/${SMTP_FROM}/SMTP_FROM_TO_REPLACE/g' config/sensitive_settings.yml

# If database exists, migrate. Otherweise setup (create and migrate)
# bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate

# launching server
rails server --daemon --binding=0.0.0.0 -e ${RAILS_ENV} $@
# displaying logs
tail -f ./log/${RAILS_ENV}.log
