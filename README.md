# GeoIP2.cr
[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=flat-square)](https://crystal-lang.org/)
[![Build Status](https://api.travis-ci.org/delef/geoip2.cr.svg)](https://travis-ci.org/delef/geoip2.cr)
[![Releases](https://img.shields.io/github/release/delef/geoip2.cr.svg?style=flat-square)](https://github.com/delef/geoip2.cr/releases)

Pure Crystal GeoIP2 [databases](http://dev.maxmind.com/geoip/geoip2/downloadable) reader.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  geoip2:
    github: delef/geoip2.cr
```

## Usage

### Country Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoLite2-Country.mmdb")
record = reader.country("128.101.101.101")

record.country.iso_code # => "US"
record.country.in_european_union? # => false
record.country.name # => "United States"
record.country.names["de"] # => "USA"

record.continent.code # => "NA"
record.continent.name # => "North America"

record.registered_country.iso_code # => "US"
record.registered_country.name # => "United States"
```

### City Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoLite2-City.mmdb", ["en", "ru", "de"])
record = reader.city("128.101.101.101")

record.city.geoname_id # => 5045360
record.city.name # => "Minneapolis"
record.city.names["ru"] # => "Миннеаполис"

record.country.iso_code # => "US"
record.country.in_european_union? # => false
record.country.name # => "United States"
record.country.names["de"] # => "USA"

record.continent.code # => "NA"
record.continent.name # => "North America"

record.location.accuracy_radius # => 20
record.location.latitude # => 44.9532
record.location.longitude # => -93.158
record.location.metro_code # => 613
record.location.time_zone # => "America/Chicago"

record.postal.code # => "55104"

record.registered_country.iso_code # => "US"
record.registered_country.name # => "United States"

record.subdivisions[0].iso_code # => "MN"
record.subdivisions[0].name # => "Minnesota"
```

### Enterprise Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoIP2-Enterprise.mmdb")
record = reader.enterprise("128.101.101.101")

record.city.name # => "Minneapolis"
record.city.confidence # => 60

record.country.iso_code # => "US"
record.country.name # => "United States"
record.country.names["zh-CN"] # => "美国"
record.country.confidence # => 99

record.subdivisions[0].name # => "Minnesota"
record.subdivisions[0].iso_code # => "MN"
record.subdivisions[0].confidence # => 77

record.postal.code # => "55455"
record.postal.confidence # => "55455"

record.location.latitude # => 44.9733
record.location.longitude # => -93.2323
record.location.accuracy_radius # => 50
```

### Anonymous IP Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoIP2-Anonymous-IP.mmdb")
record = reader.anonymous_ip("128.101.101.101")

record.anonymous? # => false
record.anonymous_vpn? # => false
record.hosting_provider? # => false
record.public_proxy? # => false
record.tor_exit_node? # => false
record.ip_address # => "128.101.101.101"
```

### Connection-Type Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoIP2-Connection-Type.mmdb")
record = reader.connection_type("128.101.101.101")

record.connection_type # => "Corporate"
record.ip_address # => "128.101.101.101"
```

### Domain Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoIP2-Domain.mmdb")
record = reader.domain("128.101.101.101")

record.domain # => "umn.edu"
record.ip_address # => "128.101.101.101"
```

### ISP Example ###
```crystal
require "geoip2"

reader = GeoIP2.open("/path/to/GeoIP2-ISP.mmdb")
record = reader.isp("128.101.101.101")

record.autonomous_system_number # => 217
record.autonomous_system_organization # => "University of Minnesota"
record.isp # => "University of Minnesota"
record.organization # => "University of Minnesota"
record.ip_address # => "128.101.101.101"
```

## Links

 - MaxMind DB reader https://github.com/delef/maxminddb.cr
 - MaxMind DB file format specification http://maxmind.github.io/MaxMind-DB/
 - MaxMind test/sample DB files https://github.com/maxmind/MaxMind-DB
 - GeoLite2 Free Downloadable Databases http://dev.maxmind.com/geoip/geoip2/geolite2/

## Contributing

1. Fork it ( https://github.com/delef/geoip2.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [delef](https://github.com/delef) - creator, maintainer
