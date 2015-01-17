# Ruboty::Songinfo

show song information, meta data, lyrics via Ruboty

## Supported providers

- Kasi-time via Duckduckgo

## Commands

```
> ruboty help
ruboty /lyric\s+of\s+(?<query>.+)/                                                                                                        - show lyric for song
ruboty /search\s+(?<type>songinfo|song|artist|composer|arranger|lyricist|appearance)\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/ - search songinfo something
ruboty /show\s+(?<type>songinfo|song|artist|composer|arranger|lyricist|appearance)\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/   - show songinfo something
ruboty /songinfo\s+flush\s+?cache/                                                                                                        - flush songinfo cache
ruboty /songinfo\s+search\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/                                                            - search songinfo
ruboty /songinfo\s+show\s+?(?:page(?:\s+|[=:])(?<page>\d+)\s+)?(?<query>.+)/                                                              - show songinfo
```

### Show lyric

```
> ruboty lyric of SONG NAME
```

### Show item

```
> show artist ARTIST NAME
> show composer COMPOSER NAME
> show arranger ARRANGER NAME
> show lyricist LYRICIST NAME
> show appearance APPEARANCE

(query all of those kinds)
> show songinfo QUERY
```

(You can also use `songinfo show` instead of `show songinfo`)

### Search

```
> search artist ARTIST NAME
> search composer COMPOSER NAME
> search arranger ARRANGER NAME
> search lyricist LYRICIST NAME
> search appearance APPEARANCE

(query all of those kinds)
> search songinfo QUERY

(pagination)
> search XXX page 2 QUERY
```

(You can also use `songinfo search` instead of `search songinfo`)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-songinfo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruboty-songinfo

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ruboty-songinfo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
