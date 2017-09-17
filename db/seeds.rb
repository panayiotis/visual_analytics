# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
Report.create name: "Vacancies", short_name: "vacancies"
Report.create name: "Unemployment", short_name: "unemployment"
Report.create name: "Cedefop heatmap", short_name: "cedefop_heatmap"
Report.create name: "Cedefop heatmap sample", short_name: "cedefop_heatmap_sample"

# Cedefop SparkDataset
schema = '[
  {"name":"date","type":"date","nullable":true,"metadata":{}},
  {"name":"esco_level_1","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_2","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_3","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_4","type":"string","nullable":true,"metadata":{}},
  {"name":"nut_level_0","type":"string","nullable":true,"metadata":{}},
  {"name":"nut_level_1","type":"string","nullable":true,"metadata":{}},
  {"name":"nut_level_2","type":"string","nullable":true,"metadata":{}},
  {"name":"nut_level_3","type":"string","nullable":true,"metadata":{}}
]'

uri="/var/data/cedefop/ft_document_en.parquet"

SparkDataset.create name: "cedefop", description: "cedefop", uri: uri, schema_json: schema

# Eures SparkDataset
schema = '[
  {"name":"age_group","type":"string","nullable":true,"metadata":{}},
  {"name":"date","type":"date","nullable":true,"metadata":{}},
  {"name":"esco_level_1","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_2","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_3","type":"string","nullable":true,"metadata":{}},
  {"name":"esco_level_4","type":"string","nullable":true,"metadata":{}},
  {"name":"gender","type":"string","nullable":true,"metadata":{}},
  {"name":"nut_level_0","type":"string","nullable":true,"metadata":{}}
]'

uri="/var/data/eures/data.parquet"

SparkDataset.create name: "eures", description: "eures", uri: uri, schema_json: schema

User.create name: "cedefop", password: "thessaloniki"
