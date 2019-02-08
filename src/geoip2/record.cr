module GeoIP2::Record
  abstract struct BaseRecord
    getter raw, locales, ip_address
    def_equals raw

    def initialize(@raw : MaxMindDB::Any, @locales : Array(String), @ip_address : String)
    end

    def inspect(io)
      data = {} of String => MaxMindDB::Any

      @raw.as_h.each do |k, v|
        k = k.lchop("is_") + "?" if k.includes?("is_")
        data[k] = v
      end

      data.inspect(io)
    end

    macro mapping(*properties)
      {% for property in properties %}
        {% if property.type.stringify == "Bool" %}
          def {{property.var}} : Bool
            key = "is_#{{{property.var.stringify.gsub(/\?/, "")}}}"
            @raw[key]?.try(&.as_bool) || false
          end
        {% else %}
          def {{property.var}} : {{property.type}}?
            if value = @raw[{{property.var.stringify}}]?
              {% if property.type.stringify == "Int32" %}
                value.as_i? || value.as_s?.try &.to_i32
              {% elsif property.type.stringify == "Float64" %}
                value.as_f? || value.as_s?.try &.to_f64
              {% elsif property.type.stringify == "String" %}
                value.as_s?
              {% else %}
                value
              {% end %}
            end
          end
        {% end %}
      {% end %}
    end
  end

  abstract struct PlaceRecord < BaseRecord
    def names : Hash(String, String)
      if names = @raw["names"]?
        names.as_h.transform_values &.as_s
      else
        {} of String => String
      end
    end

    def name : String?
      @locales.each do |locale|
        if name = names[locale]?
          return name
        end
      end
    end

    def name(locale : String) : String?
      names[locale]?
    end
  end

  struct City < PlaceRecord
    mapping(
      confidence : Int32,
      geoname_id : Int32
    )
  end

  struct Continent < PlaceRecord
    mapping(
      geoname_id : Int32,
      code : String
    )
  end

  struct Country < PlaceRecord
    mapping(
      confidence : Int32,
      geoname_id : Int32,
      in_european_union? : Bool,
      iso_code : String
    )
  end

  struct RegisteredCountry < PlaceRecord
    mapping(
      confidence : Int32,
      geoname_id : Int32,
      in_european_union? : Bool,
      iso_code : String
    )
  end

  struct RepresentedCountry < PlaceRecord
    mapping(
      confidence : Int32,
      geoname_id : Int32,
      in_european_union? : Bool,
      iso_code : String,
      type : String
    )
  end

  struct Subdivision < PlaceRecord
    mapping(
      confidence : Int32,
      geoname_id : Int32,
      in_european_union? : Bool,
      iso_code : String
    )
  end

  struct Postal < BaseRecord
    mapping(
      confidence : Int32,
      code : String
    )
  end

  struct Location < BaseRecord
    mapping(
      accuracy_radius : Int32,
      average_income : Int32,
      latitude : Float64,
      longitude : Float64,
      metro_code : Int32,
      population_density : Int32,
      time_zone : String
    )
  end

  struct MaxMind < BaseRecord
    mapping(
      accuracy_radius : Int32,
      average_income : Int32,
      latitude : Float64,
      longitude : Float64,
      metro_code : Int32,
      population_density : Int32,
      time_zone : String
    )
  end

  struct MaxMind < BaseRecord
    mapping(
      queries_remaining : Int32
    )
  end

  struct Traits < BaseRecord
    mapping(
      autonomous_system_number : Int32,
      autonomous_system_organization : String,
      connection_type : String,
      domain : String,
      anonymous? : Bool,
      anonymous_proxy? : Bool,
      anonymous_vpn? : Bool,
      hosting_provider? : Bool,
      legitimate_proxy? : Bool,
      public_proxy? : Bool,
      satellite_provider? : Bool,
      tor_exit_node? : Bool,
      isp : String,
      organization : String,
      user_type : String
    )
  end
end
