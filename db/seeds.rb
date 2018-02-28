# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(name: 'development', password: 'development')

Notebook.create(
  name: 'development notebook',
  user: user,
  adapter: 'livy',
  pack: 'hello_react'
)

Notebook.create(
  name: 'visual analytics notebook',
  user: user,
  adapter: 'livy',
  pack: 'visual_analytics'
)
