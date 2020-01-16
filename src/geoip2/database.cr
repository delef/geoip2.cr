require "maxminddb"
require "./model"

module GeoIP2
  class Database
    def initialize(db : String | Bytes | IO::Memory, @locales : Array(String))
      @reader = MaxMindDB.open(db)
    end

    private macro def_model(name, database_type)
      # Returns `Model::{{name.id}}` or `nil` if ip_address is not in the database
      def {{name.id.underscore}}?(ip_address : String) : Model::{{name.id}}?
        unless metadata.database_type.includes?({{database_type}})
          raise ArgumentError.new(
            "The '#{{{name.underscore}}}' method cannot be used" +
            " with the '#{metadata.database_type}' database"
          )
        end
        record = @reader.get(ip_address)

        return nil if record.empty?

        Model::{{name.id}}.new(record, @locales, ip_address)
      end

      # Returns `Model::{{name.id}}` or raises `AddressNotFoundError` if ip_address is not in the database
      def {{name.id.underscore}}(ip_address : String) : Model::{{name.id}}
        model = {{name.id.underscore}}?(ip_address)
        if model.nil?
          raise AddressNotFoundError.new("The address '#{ip_address}' is not in the database")
        end
        model
      end
    end

    def_model "City", "City"
    def_model "Country", "Country"
    def_model "Enterprise", "Enterprise"
    def_model "AnonymousIp", "Anonymous-IP"
    def_model "Asn", "ASN"
    def_model "ConnectionType", "Connection-Type"
    def_model "Domain", "Domain"
    def_model "Isp", "ISP"
    def_model "UserCount", "User-Count"
    def_model "DensityIncome", "DensityIncome"

    def metadata
      @reader.metadata
    end
  end
end
