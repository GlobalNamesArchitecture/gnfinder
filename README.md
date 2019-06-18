# gnfinder

Ruby gem to access functionality of [gnfinder] project written in Go. This gem
allows to perform fast and accurate scientific name finding in UTF-8 encoded
plain texts for Ruby-based projects.


## Requirements

This gem uses gRPC to access a running [gnfinder] server. You can find how
to run it in [gnfinder] README file.

## Installation

To use the gem from Ruby proect install it using Gemfile, or manually:

```bash
gem install gnfinder
```

## Usage

The purpose of this gem is to access [gnfinder] functionality out of Ruby
applications. If you need to find names using other languages, use the
[source code][client] of this gem for reference. For other usages read
the original Go-lang [gnfinder] README file.

First you need to create a instance of a `gnfinder` client

```ruby
require 'gnfinder'

gf = Gnfinder::Client.new
```

By default the client will try to connect to `localhost:8778`. If you
have another location for the server use:



```
require 'gnfinder'

# you can use global public gnfinder server
# located at finder-rpc.globalnames.org
gf = Gnfinder::Client.new(host: 'finder-rpc.globalnames.org', port: 80)

# localhost, different port
gf = Gnfinder::Client.new(host: '0.0.0.0', port: 8000)
```

### Finding names in a text using default settings

```ruby
txt = File.read('utf8-text-with-names.txt')

names = gf.find_names(txt)
puts names[0].value
puts names[0].odds
```

Returned result will have the following methods for each name:

  * value: mame-string cleaned up for verification.
  * verbatim: name-string as it was found in the text.
  * odds: Bayes' odds value. For example odds 0.1 would mean that according to
    the algorithm there is 1 chance out of 10 that the name-string is
    a scientific name. This field will be empty if Bayes algorithms did not run.

### Always enable Bayes search

For languages that are not supported by [gnfinder] only heuristic algorithms
are used by default, because some languages that are close to Latin (Italian,
French, Portugese) would generate too many false positives. However you can
override this default setting by running:

```ruby
names = gf.find_names(txt, with_bayes: true)
```

### Set a language for the text

Sometimes gnfinder cannot determine the language of a text correctly. For
example it happens when the text mostly consists of scientific names, or has
large citations or list of references in a different language. It is possible
to set a language for a text by hand. For supported languages
(English and German) it will enable Bayes algorithm. For other languages
this setting will be ignored.

List of supported languages will increase with time.

```ruby
names = gf.find_names(txt, language: 'eng')
names = gf.find_names(txt, language: 'deu')

# setting is ignored, only known by gnfinder
# 3-character notations iso-639-2 code are supported
names = gf.find_names(txt, language: 'english')
names = gf.find_names(txt, language: 'rus')
```

### Set verification option

In case if found names need to be validated against a large collection of
name-strings, use `with_verification` option. For each name algorithm will
return the following information:

  * match type:
    -	``NONE``: name-string is unknown
    - ``EXACT``: name-string matched exactly.
    - ``CANONICAL_EXACT``: canonical form of a name-string matched exactly.
    - ``CANONICAL_FUZZY``: fuzzy match of a canonical string.
    - ``PARTIAL_EXACT``: only part of a name matched. For examle only genus of a
      species was found.
    - ``PARTIAL_FUZZY``: fuzzy match of a partial result. For example canonical
      form of a trinomial matched on a species level with some corrections.
  * source_id: ID of a data-source of a best matched result. Data source IDs
    can be compared with the [data-source list]
  * curated: true if name-string was found in some data-sources that are
    deemed to curated by humans.
  * path: the classification path of a matched name (if available)

```ruby
names = gf.find_names(txt, with_verification: true)
```

### Set preferred data-sources list

Sometimes it is important to know if a name was found in a particular
data-source (data-sources). There is a parameter that takes IDs from the
[data-source list]. If a name-string was found in these data-sources, match
results will be returned back.

```ruby
names = gf.find_names(txt, with_verification: true, sources: [1, 4, 179])
```
### Combination of parameters.

It is possible to combine parameters. However if a parameter makes no sense in
a particular context. It is silently ignored.

```ruby
# Runs Bayes' algorithms using English training set, runs verification and
# returns matched results for 3 data-sources if they are available.
names = gf.find_names(txt, language: eng, with_verification: true,
                           sources: [1, 4, 179])

# Ignores `sources:` settings, because `with_verification` is not set to `true`
names = gf.find_names(txt, language: eng, sources: [1, 4, 179])
```

## Development

This gem uses gRPC to access [gnfinder] server. gRPC in turn depends on a
protobuf library. If you need to compile Ruby programs with protobuf you need
to install [Go] language and download [gnfinder] project.

```bash
go get github.com/gnames/gnfinder
```
Then you need to run bundle from the root of the project and generate
grpc files:

```bash
bundle
rake grpc
```

If you get an error, you might need to set a ``GOPATH`` environment variable.

After starting the server with default host and port (localhost:8778) you will
be able to run tests for this Ruby client with:

```bash
bundle exec rake
```

To run rubocop test

```bash
bundle exec rake rubocop
```

To run tests without rubocop
```bash
bundle exec rspec
```

[gnfinder]: https://github.com/gnames/gnfinder
[gnfinder recent release]: https://github.com/gnames/gnfinder/releases
[Go]: https://golang.org/doc/install
[client]: https://github.com/GlobalNamesArchitecture/gnfinder/blob/master/lib/gnfinder/client.rb
[data-source list]: http://index.globalnames.org/datasource
