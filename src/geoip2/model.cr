require "./record"

module GeoIP2::Model
  abstract struct BaseModel
    getter raw, locales, ip_address

    def initialize(@raw : MaxMindDB::Any, @locales : Array(String), @ip_address : String)
    end

    protected def data(key : String)
      @raw[key]? || MaxMindDB::Any.new({} of String => MaxMindDB::Any)
    end
  end

  abstract struct BaseCountry < BaseModel
    {% for method in %w(continent country registered_country represented_country maxmind traits) %}
      {% method_type = "Record::#{method.camelcase.id}".id %}

      def {{method.id}} : {{method_type}}
        {{method_type}}.new(data({{method}}), @locales, @ip_address)
      end
    {% end %}
  end

  abstract struct BaseCity < BaseCountry
    {% for method in %w(city location postal) %}
      {% method_type = "Record::#{method.camelcase.id}".id %}

      def {{method.id}} : {{method_type}}
        {{method_type}}.new(data({{method}}), @locales, @ip_address)
      end
    {% end %}

    def subdivisions
      subdivisions = [] of Record::Subdivision

      if data = @raw["subdivisions"]?
        data.as_a.each do |subdivision|
          subdivisions << Record::Subdivision.new(subdivision, @locales, @ip_address)
        end
      end

      subdivisions
    end
  end

  struct Country < BaseCountry
  end

  struct City < BaseCity
  end

  struct Insights < BaseCity
  end

  struct Enterprise < BaseCity
  end

  abstract struct SimpleModel < BaseModel
    def initialize(@raw : MaxMindDB::Any, @locales : Array(String), @ip_address : String)
      @traits = Record::Traits.new(@raw, @locales, @ip_address)
    end

    macro def_traits(*methods)
      {% for method in methods %}
        def {{method.id}}
          @traits.{{method.id}}
        end
      {% end %}
    end
  end

  struct AnonymousIp < SimpleModel
    def_traits(
      :anonymous?,
      :anonymous_vpn?,
      :hosting_provider?,
      :public_proxy?,
      :tor_exit_node?
    )
  end

  struct Asn < SimpleModel
    def_traits(
      :autonomous_system_number,
      :autonomous_system_organization
    )
  end

  struct ConnectionType < SimpleModel
    def_traits(
      :connection_type
    )
  end

  struct Domain < SimpleModel
    def_traits(
      :domain
    )
  end

  struct Isp < SimpleModel
    def_traits(
      :isp,
      :organization,
      :autonomous_system_number,
      :autonomous_system_organization
    )
  end

  struct DensityIncome < SimpleModel
    def average_income?
      @raw.as_h.has_key? "average_income"
    end

    def average_income
      @raw["average_income"].as_i
    end

    def population_density?
      @raw.as_h.has_key? "population_density"
    end

    def population_density
      @raw["population_density"].as_i
    end
  end

  struct UserCount < SimpleModel
    def ipv4
      result = {} of String => Int32

      @raw.as_h.each do |k, v|
        next unless k.includes?("ipv4")
        result[k.gsub("ipv4_", "/")] = v.as_i
      end

      result
    end

    def ipv6
      result = {} of String => Int32

      @raw.as_h.each do |k, v|
        next unless k.includes?("ipv6")
        result[k.gsub("ipv6_", "/")] = v.as_i
      end

      result
    end
  end
end
