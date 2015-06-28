# fluent-plugin-nested-hash-filter

[![Build Status](https://travis-ci.org/sugilog/fluent-plugin-nested-hash-filter.svg?branch=master)](https://travis-ci.org/sugilog/fluent-plugin-nested-hash-filter)


Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/fluent/plugin/filter_nested_hash`.

TODO: Delete this and the text above, and describe your gem

## Installation

install to your td-agent env

```ruby
td-agent-gem install fluent-plugin-nested-hash-filter
```

## Usage

Add config to your `td-agent.conf`

**Filter**: just only convert passed hash into flatten key-value pair.

```
<filter {MATCH_PATTERN}>
  type nested_hash
</filter>
```

**Output**: convert passed hash into flatten key-value pair, and rename tag.

```
<match {MATCH_PATTERN}>
  type       nested_hash
  tag_prefix {PREFIX}
</match>
```

`tag_prefix` is required parameter to add prefix to matched tag name.

- ex: matched tag is `access.log` and `tag_prefix` is `converted.`, then log will be passed with tag name `converted.access.log`.

## Development

After checking out the repo, run `bundle install` to install dependencies.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/sugilog/fluent-plugin-nested-hash-filter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
