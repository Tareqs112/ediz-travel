# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding developmental tours..."

tours = [
  {
    title: "Uzungöl",
    slug: "uzungol",
    description: "[DEVELOPMENT PLACEHOLDER] A scenic journey to the famous long lake surrounded by dense forests and mountains.",
    destination: "Çaykara, Trabzon",
    active: true,
    duration: "Full Day",
    tour_type: "Private",
    group_size: "Up to 6 guests",
    languages: ["English", "Turkish", "Arabic"],
    included: ["Hotel Pickup", "Private Transport", "Local Guide"],
    excluded: ["Lunch", "Personal Expenses"],
    itinerary: [
      { day: 1, title: "Morning Departure", desc: "Pick up from your Trabzon hotel." },
      { day: 1, title: "Uzungöl Exploration", desc: "Free time around the lake and observation deck." }
    ]
  },
  {
    title: "Sümela Monastery",
    slug: "sumela-monastery",
    description: "[DEVELOPMENT PLACEHOLDER] Discover the ancient Greek Orthodox monastery built into a steep cliff in the Altındere valley.",
    destination: "Maçka, Trabzon",
    active: true,
    duration: "6 Hours",
    tour_type: "Private",
    group_size: "Up to 4 guests",
    languages: ["English", "Turkish"],
    included: ["Hotel Pickup", "National Park Fees"],
    excluded: ["Museum Entry Ticket", "Lunch"],
    itinerary: []
  },
  {
    title: "Ayder & Fırtına Valley",
    slug: "ayder-firtina",
    description: "[DEVELOPMENT PLACEHOLDER] Experience the lush highlands, traditional wooden houses, and the rushing Fırtına River.",
    destination: "Çamlıhemşin, Rize",
    active: true,
    duration: "Full Day",
    tour_type: "Group or Private",
    group_size: "Up to 8 guests",
    languages: ["English", "Arabic"],
    included: ["Transport", "Guide", "Tea Tasting"],
    excluded: ["Lunch", "Rafting/Zipline Fees"],
    itinerary: []
  }
]

tours.each do |tour_attrs|
  tour = Tour.find_or_initialize_by(slug: tour_attrs[:slug])
  tour.update!(tour_attrs)
end

puts "Created #{Tour.count} tours in the database."
