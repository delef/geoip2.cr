require "spec"
require "../src/geoip2"

def db_path(name : String)
  "spec/data/test-data/#{name}.mmdb"
end

def source_model_data(file_name, ip_address)
  source_path = "spec/data/source-data/#{file_name}.json"
  source_data = File.read(source_path)
  json_any = nil

  JSON.parse(source_data).as_a.each do |row|
    if Regex.new(ip_address).match(row.as_h.keys.first)
      json_any = row.as_h.values[0]
      break
    end
  end

  raise "IP address not found in the source file" unless json_any

  {json_any: json_any, maxminddb_any: json_any_to_maxminddb_any(json_any)}
end

private def json_any_to_maxminddb_any(json_any)
  if value = json_any.as_h?
    result = {} of String => MaxMindDB::Any

    value.each do |k, v|
      result[k] = json_any_to_maxminddb_any(v)
    end
  elsif value = json_any.as_a?
    result = [] of MaxMindDB::Any

    value.each do |v|
      result << json_any_to_maxminddb_any(v)
    end
  elsif value = json_any.as_i?
    result = value.to_i32
  elsif value = json_any.as_f?
    result = value.to_f64
  elsif value = json_any.as_s?
    result = value
  elsif value = json_any.as_bool?
    result = value
  else
    result = nil
  end

  MaxMindDB::Any.new(result)
end
