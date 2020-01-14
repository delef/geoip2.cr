require "./spec_helper"

describe GeoIP2::Database do
  it "name from default locale" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))
    record = database.city("81.2.69.160")

    record.country.name.should eq("United Kingdom")
  end

  it "name from locales list" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"), ["xx", "ru", "es"])
    record = database.city("81.2.69.160")

    record.country.name.should eq("Великобритания")
    record.country.names.keys.should contain("zh-CN")
    record.country.names["zh-CN"].should eq("英国")
  end

  it "traits has ip_address" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))
    record = database.city("81.2.69.160")

    record.traits.ip_address.should eq("81.2.69.160")
  end

  it "country in european union?" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))
    record = database.city("81.2.69.160")

    record.country.in_european_union?.should be_true
    record.registered_country.in_european_union?.should be_false
  end

  it "unknown ip address" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))

    expect_raises(GeoIP2::AddressNotFoundError, "The address '10.10.10.10' is not in the database") do
      database.city("10.10.10.10")
    end
  end

  it "incorrect database type" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))

    {% for db_type in %w(country domain enterprise) %}
      message = "The '{{db_type.id}}' method cannot be used with" +
                " the '#{database.metadata.database_type}' database"

      expect_raises(ArgumentError, message) do
        database.{{db_type.id}}("81.2.69.160")
      end
    {% end %}
  end

  it "incorrect ip address" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))

    expect_raises(ArgumentError, "Unknown IP address: incorrect") do
      database.city("incorrect")
    end
  end

  it "metadata" do
    database = GeoIP2.open(db_path("GeoIP2-City-Test"))
    database.metadata.database_type.should eq("GeoIP2-City")
  end

  describe "Enterprise database" do
    database = GeoIP2.open(db_path("GeoIP2-Enterprise-Test"))
    record = database.enterprise("74.209.24.0")

    it "#city" do
      record.city.confidence.should eq(11)
      record.city.geoname_id.should eq(5112335)
      record.city.name.should eq("Chatham")
      record.city.names.should eq({"en" => "Chatham"})
    end

    it "#country" do
      record.country.confidence.should eq(99)
      record.country.geoname_id.should eq(6252001)
      record.country.in_european_union?.should be_false
      record.country.name.should eq("United States")
      record.country.names["es"].should eq("Estados Unidos")
    end

    it "#registered_country" do
      record.registered_country.confidence.should be_nil
      record.registered_country.geoname_id.should eq(6252001)
      record.registered_country.in_european_union?.should be_false
      record.country.name.should eq("United States")
      record.country.names["es"].should eq("Estados Unidos")
    end

    it "#subdivisions" do
      record.subdivisions[0].confidence.should eq(93)
      record.subdivisions[0].geoname_id.should eq(5128638)
      record.subdivisions[0].in_european_union?.should be_false
      record.subdivisions[0].name.should eq("New York")
    end

    it "#most_specific_subdivision" do
      record.most_specific_subdivision.confidence.should eq(93)
      record.most_specific_subdivision.geoname_id.should eq(5128638)
      record.most_specific_subdivision.in_european_union?.should be_false
      record.most_specific_subdivision.name.should eq("New York")
    end

    it "#location" do
      record.location.accuracy_radius.should eq(27)
    end

    it "#traits" do
      record.traits.connection_type.should eq("Cable/DSL")
      record.traits.legitimate_proxy?.should be_true
      record.traits.ip_address.should eq("74.209.24.0")
    end
  end

  describe "Traits" do
    it "check AnonymousIp database" do
      database = GeoIP2.open(db_path("GeoIP2-Anonymous-IP-Test"))
      record = database.anonymous_ip("1.2.0.1")

      record.anonymous?.should be_true
      record.anonymous_vpn?.should be_true
      record.hosting_provider?.should be_false
      record.public_proxy?.should be_false
      record.tor_exit_node?.should be_false
      record.ip_address.should eq("1.2.0.1")
    end

    it "check ASN database" do
      database = GeoIP2.open(db_path("GeoLite2-ASN-Test"))
      record = database.asn("1.128.0.0")

      record.autonomous_system_number.should eq(1221)
      record.autonomous_system_organization.should eq("Telstra Pty Ltd")
      record.ip_address.should eq("1.128.0.0")
    end

    it "check ConnectionType database" do
      database = GeoIP2.open(db_path("GeoIP2-Connection-Type-Test"))
      record = database.connection_type("1.0.1.0")

      record.connection_type.should eq("Cable/DSL")
      record.ip_address.should eq("1.0.1.0")
    end

    it "check Domain database" do
      database = GeoIP2.open(db_path("GeoIP2-Domain-Test"))
      record = database.domain("1.2.0.0")

      record.domain.should eq("maxmind.com")
      record.ip_address.should eq("1.2.0.0")
    end

    it "check ISP database" do
      database = GeoIP2.open(db_path("GeoIP2-ISP-Test"))
      record = database.isp("1.128.0.0")

      record.autonomous_system_number.should eq(1221)
      record.autonomous_system_organization.should eq("Telstra Pty Ltd")
      record.isp.should eq("Telstra Internet")
      record.organization.should eq("Telstra Internet")
      record.ip_address.should eq("1.128.0.0")
    end

    it "loads database from Bytes" do
      bytes : Bytes = db_bytes("GeoIP2-Domain-Test")
      database = GeoIP2.open(bytes)

      record = database.domain("1.2.0.0")
      record.domain.should eq("maxmind.com")
      record.ip_address.should eq("1.2.0.0")
    end

    it "loads database from IO::Memory" do
      memory = IO::Memory.new(db_bytes("GeoIP2-Domain-Test"))
      database = GeoIP2.open(memory)

      record = database.domain("1.2.0.0")
      record.domain.should eq("maxmind.com")
      record.ip_address.should eq("1.2.0.0")
    end
  end
end
