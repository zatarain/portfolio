FROM zatarain/rails-api
COPY . .
RUN bundle check || bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
