[![Build Status](https://travis-ci.org/sinsoku/rails_hint.svg?branch=master)](https://travis-ci.org/sinsoku/rails_hint)

# RailsHint

**RailsHint** is a static analyzer for Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_hint'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_hint

## Usage

### Schame Parsing

```ruby
schema = RailsHint.parse_schema("db/schema.rb")
schema.version  #=> 2018_07_01_010203

table = schema.tables.first
table.name      #=> "articles"

column = table.columns.first
column.type     #=> :string
column.name     #=> "title"
column.options  #=> { :null => false }

index = table.indexes.first
index.column_name  #=> "title"
index.options      #=> { :name => "index_articles_on_title", unique: true }

foreign_key = table.foreign_keys
foreign_key.to_table  #=> "users"
foreign_key.options   #=> { :on_delete => :cascade }
```

### Class Tree Parsing

```ruby
classes = RailsHint.parse_files("app/models/*.rb")
klass = classes.first
klass.type        #=> :class
klass.name        #=> "User"
klass.superclass  #=> "ApplicationRecord"
klass.ancestors   #=> ["ApplicationRecord", "ActiveRecord::Base"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sinsoku/rails_hint. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RailsHint project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rails_hint/blob/master/CODE_OF_CONDUCT.md).
