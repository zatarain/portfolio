FROM zatarain/rails-api
COPY . .
RUN echo 'export $(strings /proc/1/environ | grep AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)' >> /root/.profile
RUN bundle check || bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
