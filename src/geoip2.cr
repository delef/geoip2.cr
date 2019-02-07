require "./geoip2/exception"
require "./geoip2/database"
require "./geoip2/version"

module GeoIP2
  def self.open(db_path : String, locales : Array(String) = ["en"])
    Database.new(db_path, locales)
  end
end
