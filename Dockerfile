FROM zatarain/rails-api
RUN bundle check || bundle install
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
