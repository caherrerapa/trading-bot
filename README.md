Set your `BINANCE_API_KEY` and `BINANCE_SECRET_KEY` in  `application.yml`

```
rvm install ruby-2.7.4
echo 'rvm use 2.7.4' >> .rvmrc
docker-compose -f docker-compose.dev.yml up -d
bundle install
rails db:create
rails db:migrate
rake binance:load_pairs
rake binance:load_balances
bundle exec ruby ./lib/scripts/binance_daemon.rb start
bundle exec rails s
```
