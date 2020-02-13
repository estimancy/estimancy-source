ARG RUBY_VERSION
FROM ruby:${RUBY_VERSION}
LABEL maintainer "Estimancy <support@estimancy.com>"

# update system
RUN apt update -y && \
	apt dist-upgrade -y

# installing dependencies
RUN apt install -y nodejs

# installing application
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN bundle install --jobs 20 --retry 5

# configuring application
RUN mv config/database.example.yml config/database.yml && \
	mv config/sensitive_settings.example.yml config/sensitive_settings.yml && \
	mkdir log && \
	chown -R nobody:nogroup .

EXPOSE 3000

# entrypoint
RUN chown root:root /app/docker_entrypoint.sh && \
	chmod 755 /app/docker_entrypoint.sh
ENTRYPOINT /app/docker_entrypoint.sh
USER nobody