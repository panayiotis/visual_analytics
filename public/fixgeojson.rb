#!/usr/bin/env ruby

require 'colored'
require 'awesome_print'
require 'json'

puts 'Fix Geojson'.green
original_json = JSON.parse(File.read('europe.geo.json'))
ap original_json["features"]
