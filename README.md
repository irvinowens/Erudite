# Erudite

Erudite Ruby Distributed Database
I decided to write erudite because I was fascinated by Erlang’s EPMD
communications daemon.  I was thinking of a new open source project to work on,
and it seemed like a good idea to build a ragged right edge database that would
auto-shard, auto-migrate and auto-cluster.  I also needed for it to listen for
MySQL traffic and have a DSL for SQL which Ruby helps with.

I chose to write it in Ruby because I felt that Ruby’s dynamic nature would
make it easier to work with.

Features

    -Auto sharding
    -Auto data migration based on capacity and usage
    -Partial file storage
    -Self-healing
    -Auto-Discovery of new processes

## Installation

Add this line to your application's Gemfile:

    gem 'Erudite'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install Erudite

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/Erudite/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
