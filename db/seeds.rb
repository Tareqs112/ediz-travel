# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding Destinations..."

destinations = [
  { name: "Trabzon", slug: "trabzon", region: "Eastern Black Sea", active: true },
  { name: "Uzungöl", slug: "uzungol", region: "Trabzon", active: true },
  { name: "Sümela Monastery", slug: "sumela", region: "Trabzon", active: true },
  { name: "Ayder Plateau", slug: "ayder", region: "Rize", active: true }
]

destinations.each do |dest_attrs|
  dest = Destination.find_or_initialize_by(slug: dest_attrs[:slug])
  dest.update!(dest_attrs)
end

puts "Created #{Destination.count} destinations."

puts "Seeding developmental tours..."

tours = [
  {
    title: "Uzungöl Tour",
    slug: "uzungol-tour",
    description: "A scenic journey to the famous long lake surrounded by dense forests and mountains.",
    destination: Destination.find_by(slug: "uzungol"),
    active: true,
    duration: nil,
    tour_type: nil,
    group_size: nil,
    languages: [],
    included: [],
    excluded: [],
    itinerary: [],
    highlights: [],
    meeting_point: nil,
    cancellation_policy: nil,
    image_filename: "uzungol.webp"
  },
  {
    title: "Sümela Monastery & Karaca Cave",
    slug: "sumela-karaca",
    description: "Discover the ancient Greek Orthodox monastery built into a steep cliff in the Altındere valley.",
    destination: Destination.find_by(slug: "sumela"),
    active: true,
    duration: nil,
    tour_type: nil,
    group_size: nil,
    languages: [],
    included: [],
    excluded: [],
    itinerary: [],
    highlights: [],
    meeting_point: nil,
    cancellation_policy: nil,
    image_filename: "sumela-monastery.webp"
  },
  {
    title: "Ayder & Fırtına Valley",
    slug: "ayder-firtina",
    description: "Experience the lush highlands, traditional wooden houses, and the rushing Fırtına River.",
    destination: Destination.find_by(slug: "ayder"),
    active: true,
    duration: nil,
    tour_type: nil,
    group_size: nil,
    languages: [],
    included: [],
    excluded: [],
    itinerary: [],
    highlights: [],
    meeting_point: nil,
    cancellation_policy: nil,
    image_filename: "ayder-firtina.webp"
  }
]

tours.each do |tour_attrs|
  image_filename = tour_attrs.delete(:image_filename)
  tour = Tour.find_or_initialize_by(slug: tour_attrs[:slug])
  tour.update!(tour_attrs)
  
  if image_filename.present?
    image_path = Rails.root.join("app/assets/images", image_filename)
    if File.exist?(image_path) && !tour.image.attached?
      tour.image.attach(io: File.open(image_path), filename: image_filename, content_type: "image/webp")
    end
  end
end

puts "Created #{Tour.count} tours in the database."
