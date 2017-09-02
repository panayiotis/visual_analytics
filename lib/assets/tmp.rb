#!/usr/bin/env ruby

require 'colored'
require 'awesome_print'
AwesomePrint.force_colors=true

puts 'Hello world'.green

f = File.read("a.tsv")
f = File.read "ilc_pw03.tsv"

ap tsv = f.split("\n").map{|s| s.split("\t")}

countries = tsv.shift

fields = countries.shift.split(",").push("nut_level_0").push("value")

ap countries

ap fields

data=tsv.map do |a|
 first_col = a.shift.split(",")
 a.each_with_index.map do |val,i|
   Array.new.concat(first_col).push(countries[i].strip).push(val.strip)
 end
end
.flatten(1)
.delete_if do |a|
  %w(EU28 EU).include?(a[fields.find_index('nut_level_0')]) ||
  %w(:).include?(a[fields.find_index('value')]) ||
  %w(TOTAL ED5_6).include?(a[fields.find_index('isced11')]) || 
  %w(Y_GE16).include?(a[fields.find_index('age')]) ||
  %w(T).include?(a[fields.find_index('sex')])
end
.map do |a|
  a[fields.find_index('value')] = a[fields.find_index('value')].to_f
  a.shift # do not forget to shift fields too
  a
end
fields.shift

fields[fields.find_index('time\geo')]="date"

puts fields.join(" ")
puts data.map{|a| a.join(" ")}.join("\n")
puts data.length

json = data.map do |a|
  h = Hash.new
  fields.each_with_index do |key,i|
    h[key]= a[i]
  end
  h
end

ap json
