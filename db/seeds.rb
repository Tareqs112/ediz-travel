# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding developmental tours..."

tours = [
  {
    title: "Uzungöl",
    slug: "uzungol",
    description: "[DEVELOPMENT PLACEHOLDER] A scenic journey to the famous long lake surrounded by dense forests and mountains.",
    destination: "Çaykara, Trabzon",
    active: true
  },
  {
    title: "Sümela Monastery",
    slug: "sumela-monastery",
    description: "[DEVELOPMENT PLACEHOLDER] Discover the ancient Greek Orthodox monastery built into a steep cliff in the Altındere valley.",
    destination: "Maçka, Trabzon",
    active: true
  },
  {
    title: "Ayder & Fırtına Valley",
    slug: "ayder-firtina",
    description: "[DEVELOPMENT PLACEHOLDER] Experience the lush highlands, traditional wooden houses, and the rushing Fırtına River.",
    destination: "Çamlıhemşin, Rize",
    active: true
  }
]

tours.each do |tour_attrs|
  tour = Tour.find_or_initialize_by(slug: tour_attrs[:slug])
  tour.update!(tour_attrs)
end

puts "Created #{Tour.count} tours in the database."
