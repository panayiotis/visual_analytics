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
Report.create name: "Mobility", short_name: "mobility"
Report.create name: "Public Integrity Report", short_name: "public_integrity_report"

schema = '[
{"name":"publication_country","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_4","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_3","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_2","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_3","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_2","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_1","type":"string","nullable":true,"metadata":{}},
{"name":"contract","type":"string","nullable":true,"metadata":{}},
{"name":"educational_level","type":"string","nullable":true,"metadata":{}},
{"name":"industry_level_2","type":"string","nullable":true,"metadata":{}},
{"name":"industry_level_1","type":"string","nullable":true,"metadata":{}},
{"name":"working_hours","type":"string","nullable":true,"metadata":{}},
{"name":"grab_month","type":"date","nullable":true,"metadata":{}},
{"name":"expire_month","type":"date","nullable":true,"metadata":{}},
{"name":"nut_level_0","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_1","type":"string","nullable":true,"metadata":{}}
]'

schema = '[
{"name":"esco_level_4","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_3","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_2","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_3","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_2","type":"string","nullable":true,"metadata":{}},
{"name":"nut_level_1","type":"string","nullable":true,"metadata":{}},
{"name":"date","type":"date","nullable":true,"metadata":{}},
{"name":"nut_level_0","type":"string","nullable":true,"metadata":{}},
{"name":"esco_level_1","type":"string","nullable":true,"metadata":{}}
]'

uri="/var/data/cedefop/ft_document_en.parquet"

SparkDataset.create name: "cedefop", description: "cedefop", uri: uri, schema_json: schema

EurostatDataset.create name: "ilc_pw03", description: "Average rating of trust by domain, sex, age and educational attainment level (ilc_pw03)"

OosaDataset.create name: "gsac dataset", uri: "http://www.gsaci.gov.gr/attachments/article/142/ΑΠΕΙΚΟΝΙΣΗ ΣΥΛΛΟΓΗΣ ΔΕΔΟΜΕΝΩΝ ΔΙΑΦΘΟΡΑΣ.pdf", description: "Dataset extracted from the OOSA pdf report"
