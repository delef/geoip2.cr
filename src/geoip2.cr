require "./geoip2/exception"
require "./geoip2/database"
require "./geoip2/version"

module GeoIP2
  def self.open(db : String | Bytes | IO::Memory, locales : Array(String) = ["en"])
    Database.new(db, locales)
  end
end
