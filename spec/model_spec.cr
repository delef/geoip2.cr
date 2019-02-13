require "json"
require "./spec_helper"

describe GeoIP2::Model do
  describe "Country" do
    ip_address = "2.125.160.216"
    source_data = source_model_data("GeoIP2-Country-Test", ip_address)
    model = GeoIP2::Model::Country.new(source_data[:maxminddb_any], ["en", "fr"], ip_address)

    it "country record" do
      model.country.geoname_id.should eq(2635167)
      model.country.in_european_union?.should be_true
      model.country.name.should eq("United Kingdom")
      model.country.locales.should contain("fr")
      model.country.names["fr"].should eq("Royaume-Uni")
      model.country.empty?.should be_false
      pp model.to_json
    end

    it "registered_country record" do
      model.registered_country.geoname_id.should eq(3017382)
      model.registered_country.in_european_union?.should be_true
      model.registered_country.iso_code.should eq("FR")
      model.registered_country.name.should eq("France")
      model.registered_country.names["fr"].should eq("France")
    end

    it "continent record" do
      model.continent.geoname_id.should eq(6255148)
      model.continent.code.should eq("EU")
      model.continent.name.should eq("Europe")
      model.continent.names["fr"].should eq("Europe")
    end
  end

  describe "City" do
    ip_address = "2.125.160.216"
    source_data = source_model_data("GeoIP2-City-Test", ip_address)
    model = GeoIP2::Model::City.new(source_data[:maxminddb_any], ["ja", "en"], ip_address)

    it "city record" do
      model.city.geoname_id.should eq(2655045)
      model.city.name.should eq("Boxford")
      model.city.names.has_key?("ja").should be_false
    end

    it "country record" do
      model.country.geoname_id.should eq(2635167)
      model.country.in_european_union?.should be_true
      model.country.name.should eq("イギリス")
      model.country.names["de"].should eq("Vereinigtes Königreich")
    end

    it "registered_country record" do
      model.registered_country.geoname_id.should eq(3017382)
      model.registered_country.in_european_union?.should be_true
      model.registered_country.iso_code.should eq("FR")
      model.registered_country.name.should eq("フランス共和国")
      model.registered_country.names["de"].should eq("Frankreich")
    end

    it "continent record" do
      model.continent.geoname_id.should eq(6255148)
      model.continent.code.should eq("EU")
      model.continent.name.should eq("ヨーロッパ")
      model.continent.names["de"].should eq("Europa")
    end

    describe "subdivision record" do
      it "#subdivisions" do
        model.subdivisions[0].geoname_id.should eq(6269131)
        model.subdivisions[0].iso_code.should eq("ENG")
        model.subdivisions[0].name.should eq("England")
        model.subdivisions[0].names.has_key?("ru").should be_false
        model.subdivisions[0].names["fr"].should eq("Angleterre")
      end

      it "#most_specific_subdivision" do
        model.most_specific_subdivision.geoname_id.should eq(3333217)
        model.most_specific_subdivision.iso_code.should eq("WBK")
        model.most_specific_subdivision.name.should eq("West Berkshire")
        model.most_specific_subdivision.names["ru"].should eq("Западный Беркшир")
      end
    end
  end

  describe "Enterprise" do
    ip_address = "216.160.83.56"
    source_data = source_model_data("GeoIP2-Enterprise-Test", ip_address)
    model = GeoIP2::Model::Enterprise.new(source_data[:maxminddb_any], ["en", "ru"], ip_address)

    it "city record" do
      model.city.confidence.should eq(40)
      model.city.geoname_id.should eq(5803556)
      model.city.name.should eq("Milton")
      model.city.names["ru"].should eq("Мильтон")
    end

    it "country record" do
      model.country.confidence.should eq(99)
      model.country.geoname_id.should eq(6252001)
      model.country.in_european_union?.should be_false
      model.country.name.should eq("United States")
      model.country.names["ru"].should eq("США")
    end

    it "registered_country record" do
      model.registered_country.confidence.should be_nil
      model.registered_country.geoname_id.should eq(2635167)
      model.registered_country.in_european_union?.should be_true
      model.registered_country.iso_code.should eq("GB")
      model.registered_country.name.should eq("United Kingdom")
      model.registered_country.names["ru"].should eq("Великобритания")
    end

    it "continent record" do
      model.continent.geoname_id.should eq(6255149)
      model.continent.code.should eq("NA")
      model.continent.name.should eq("North America")
      model.continent.names["ru"].should eq("Северная Америка")
    end

    it "location record" do
      model.location.average_income.should be_nil
      model.location.accuracy_radius.should eq(22)
      model.location.latitude.should eq(47.2513)
      model.location.longitude.should eq(-122.3149)
      model.location.metro_code.should eq(819)
      model.location.population_density.should be_nil
      model.location.time_zone.should eq("America/Los_Angeles")
    end

    it "postal record" do
      model.postal.confidence.should eq(40)
      model.postal.code.should eq("98354")
    end

    it "subdivision record" do
      model.subdivisions[0].confidence.should eq(99)
      model.subdivisions[0].geoname_id.should eq(5815135)
      model.subdivisions[0].iso_code.should eq("WA")
      model.subdivisions[0].name.should eq("Washington")
      model.subdivisions[0].names["ru"].should eq("Вашингтон")

      model.most_specific_subdivision.confidence.should eq(99)
      model.most_specific_subdivision.geoname_id.should eq(5815135)
      model.most_specific_subdivision.iso_code.should eq("WA")
      model.most_specific_subdivision.name.should eq("Washington")
      model.most_specific_subdivision.names["ru"].should eq("Вашингтон")
    end

    it "traits record" do
      model.traits.autonomous_system_number.should eq(209)
      model.traits.connection_type.should eq("Cable/DSL")
      model.traits.isp.should eq("Century Link")
      model.traits.organization.should eq("Lariat Software")
      model.traits.user_type.should eq("government")
    end
  end

  describe "AnonymousIp" do
    ip_address = "81.2.69.0"
    source_data = source_model_data("GeoIP2-Anonymous-IP-Test", ip_address)
    model = GeoIP2::Model::AnonymousIp.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "anonymous_ip values must be boolean" do
      model.anonymous?.should be_true
      model.anonymous_vpn?.should be_true
      model.hosting_provider?.should be_true
      model.public_proxy?.should be_true
      model.tor_exit_node?.should be_true
    end
  end

  describe "Asn" do
    ip_address = "1.128.0.0"
    source_data = source_model_data("GeoLite2-ASN-Test", ip_address)
    model = GeoIP2::Model::Asn.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "asn" do
      model.autonomous_system_number.should eq(1221)
      model.autonomous_system_organization.should eq("Telstra Pty Ltd")
    end
  end

  describe "ConnectionType" do
    ip_address = "1.0.1.0"
    source_data = source_model_data("GeoIP2-Connection-Type-Test", ip_address)
    model = GeoIP2::Model::ConnectionType.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "connection type" do
      model.connection_type.should eq("Cable/DSL")
    end
  end

  describe "Domain" do
    ip_address = "1.2.0.0"
    source_data = source_model_data("GeoIP2-Domain-Test", ip_address)
    model = GeoIP2::Model::Domain.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "domain" do
      model.domain.should eq("maxmind.com")
    end
  end

  describe "Isp" do
    ip_address = "1.128.0.0"
    source_data = source_model_data("GeoIP2-ISP-Test", ip_address)
    model = GeoIP2::Model::Isp.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "isp" do
      model.autonomous_system_number.should eq(1221)
      model.autonomous_system_organization.should eq("Telstra Pty Ltd")
      model.isp.should eq("Telstra Internet")
      model.organization.should eq("Telstra Internet")
    end
  end

  describe "DensityIncome" do
    ip_address = "5.83.124.0"
    source_data = source_model_data("GeoIP2-DensityIncome-Test", ip_address)
    model = GeoIP2::Model::DensityIncome.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "density income" do
      model.average_income.should eq(32323)
      model.population_density.should eq(1232)
    end
  end

  describe "UserCount" do
    ip_address = "2001:edb8:dead:8000::"
    source_data = source_model_data("GeoIP2-User-Count-Test", ip_address)
    model = GeoIP2::Model::UserCount.new(source_data[:maxminddb_any], [] of String, ip_address)

    it "density income" do
      model.ipv4.should be_empty
      model.ipv6["/32"].should eq(5)
      model.ipv6["/48"].should eq(2)
      model.ipv6["/64"].should eq(0)
    end
  end
end
