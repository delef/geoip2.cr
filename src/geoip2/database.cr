require "maxminddb"
require "./model"

module GeoIP2
  class Database
    def initialize(db : String | Bytes | IO::Memory, @locales : Array(String))
      @reader = MaxMindDB.open(db)
    end

    def city(ip_address : String)
      model "City", "City", ip_address
    end

    def country(ip_address : String)
      model "Country", "Country", ip_address
    end

    def enterprise(ip_address : String)
      model "Enterprise", "Enterprise", ip_address
    end

    def anonymous_ip(ip_address : String)
      model "AnonymousIp", "Anonymous-IP", ip_address
    end

    def asn(ip_address : String)
      model "Asn", "ASN", ip_address
    end

    def connection_type(ip_address : String)
      model "ConnectionType", "Connection-Type", ip_address
    end

    def domain(ip_address : String)
      model "Domain", "Domain", ip_address
    end

    def isp(ip_address : String)
      model "Isp", "ISP", ip_address
    end

    def user_count(ip_address : String)
      model "UserCount", "User-Count", ip_address
    end

    def density_income(ip_address : String)
      model "DensityIncome", "DensityIncome", ip_address
    end

    def metadata
      @reader.metadata
    end

    private macro model(name, database_type, ip_address)
      unless metadata.database_type.includes?({{database_type}})
        raise ArgumentError.new(
                "The '#{{{name.underscore}}}' method cannot be used" +
                " with the '#{metadata.database_type}' database"
              )
      end

      record = @reader.get({{ip_address}})

      if record.empty?
        raise AddressNotFoundError.new(
                "The address '#{ip_address}' is not in the database"
              )
      end

      Model::{{name.id}}.new(record, @locales, ip_address)
    end
  end
end
