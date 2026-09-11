# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding Destinations..."

destinations = [
  { name: "Trabzon", slug: "trabzon", region: "Eastern Black Sea", active: true },
  { name: "Uzungöl", slug: "uzungol", region: "Trabzon", active: true },
  { name: "Sümela Monastery", slug: "sumela", region: "Trabzon", active: true },
  { name: "Ayder Plateau", slug: "ayder", region: "Rize", active: true },
  { name: "Hıdırnebi Plateau", slug: "hidirnebi-plateau", region: "Trabzon", active: true },
  { name: "Rize", slug: "rize", region: "Eastern Black Sea", active: true },
  { name: "Elevit Plateau", slug: "elevit-plateau", region: "Rize", active: true },
  { name: "Hamsiköy", slug: "hamsikoy", region: "Trabzon", active: true },
  { name: "Ordu", slug: "ordu", region: "Black Sea Coast", active: true }
]

destinations.each do |dest_attrs|
  dest = Destination.where(slug: dest_attrs[:slug]).first_or_initialize
  if dest.new_record?
    dest.assign_attributes(dest_attrs)
    dest.save!
  elsif dest.active.nil?
    dest.update!(active: true)
  end
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
    destination: Destination.find_by(slug: "sumela") || Destination.find_by(slug: "sumela-monastery"),
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
    destination: Destination.find_by(slug: "ayder") || Destination.find_by(slug: "ayder-plateau"),
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
  
  if tour.new_record?
    tour.assign_attributes(tour_attrs)
    tour.save!
  end
  
  if image_filename.present?
    image_path = Rails.root.join("app/assets/images", image_filename)
    if File.exist?(image_path) && !tour.image.attached?
      tour.image.attach(io: File.open(image_path), filename: image_filename, content_type: "image/webp")
    end
  end
end

puts "Seeding additional regional tours..."

additional_tours_shared = {
  included_en: ["Private vehicle with driver", "Pickup and drop-off from your hotel or an agreed location in Trabzon"],
  included_ar: ["سيارة خاصة مع سائق", "التوصيل من فندقكم أو من نقطة التقاء متفق عليها في طرابزون"],
  included_tr: ["Şoförlü özel araç", "Otelinizden veya Trabzon'da mutabık kalınan bir noktadan alış ve bırakış"],

  excluded_en: ["Meals and drinks", "Personal expenses", "Entrance and museum fees", "Optional activities"],
  excluded_ar: ["الوجبات والمشروبات", "النفقات الشخصية", "رسوم الدخول والمتاحف", "الأنشطة الاختيارية"],
  excluded_tr: ["Yemek ve içecekler", "Kişisel harcamalar", "Giriş ve müze ücretleri", "İsteğe bağlı aktiviteler"],

  meeting_point_en: "Your hotel or an agreed meeting point in Trabzon",
  meeting_point_ar: "فندقكم أو نقطة التقاء متفق عليها في طرابزون",
  meeting_point_tr: "Oteliniz veya Trabzon'da mutabık kalınan bir buluşma noktası",

  cancellation_policy_en: "Free cancellation up to 24 hours before departure.",
  cancellation_policy_ar: "إلغاء مجاني حتى 24 ساعة قبل موعد المغادرة.",
  cancellation_policy_tr: "Hareket saatinden 24 saat öncesine kadar ücretsiz iptal."
}

additional_tours_data = [
  {
    destination_slug: "trabzon",
    slug: "trabzon-city-tour",
    price_from: 100.00,
    currency: "USD",
    featured: true,
    tour_type: "Private",
    duration: "Half to Full Day (approx. 5–7 hours)",
    group_size: nil,

    title_en: "Trabzon City Tour",
    description_en: "A comprehensive tour of Trabzon's most important historical and natural sites.",
    highlights_en: [
      "Hagia Sophia of Trabzon (Ayasofya)",
      "Atatürk Pavilion",
      "Sera Lake",
      "Boztepe Hill"
    ],
    itinerary_en: [
      { day: 1, title: "Hagia Sophia (Ayasofya)", desc: "Visit this 13th-century Byzantine building and observe its preserved architecture and frescoes." },
      { day: 2, title: "Atatürk Pavilion", desc: "Explore this historic early 20th-century mansion surrounded by pine trees." },
      { day: 3, title: "Sera Lake", desc: "Take a relaxing break at this natural lake located in the Akçaabat district." },
      { day: 4, title: "Boztepe Hill", desc: "End the tour with a drive up to Boztepe for panoramic views of Trabzon and the Black Sea coast." }
    ],

    title_ar: "جولة مدينة طرابزون",
    description_ar: "جولة شاملة لأهم المعالم التاريخية والطبيعية في طرابزون.",
    highlights_ar: [
      "آيا صوفيا في طرابزون",
      "قصر أتاتورك",
      "بحيرة سيرا",
      "تلة بوزتبه"
    ],
    itinerary_ar: [
      { day: 1, title: "آيا صوفيا", desc: "زيارة هذا المبنى البيزنطي الذي يعود للقرن الثالث عشر ومشاهدة هندسته المعمارية واللوحات الجدارية المحفوظة." },
      { day: 2, title: "قصر أتاتورك", desc: "استكشاف هذا القصر التاريخي الذي يعود لأوائل القرن العشرين والمحاط بأشجار الصنوبر." },
      { day: 3, title: "بحيرة سيرا", desc: "استراحة للاسترخاء في هذه البحيرة الطبيعية الواقعة في منطقة أكشابات." },
      { day: 4, title: "تلة بوزتبه", desc: "ختام الجولة بالصعود إلى بوزتبه للاستمتاع بإطلالات بانورامية على مدينة طرابزون وساحل البحر الأسود." }
    ],

    title_tr: "Trabzon Şehir Turu",
    description_tr: "Trabzon'un en önemli tarihi ve doğal alanlarını kapsayan kapsamlı bir tur.",
    highlights_tr: [
      "Trabzon Ayasofya Camii",
      "Atatürk Köşkü",
      "Sera Gölü",
      "Boztepe"
    ],
    itinerary_tr: [
      { day: 1, title: "Ayasofya Camii", desc: "13. yüzyıldan kalma bu tarihi Bizans yapısını ve günümüze ulaşan fresklerini ziyaret edin." },
      { day: 2, title: "Atatürk Köşkü", desc: "Çam ağaçlarıyla çevrili, 20. yüzyılın başlarından kalma bu tarihi köşkü keşfedin." },
      { day: 3, title: "Sera Gölü", desc: "Akçaabat ilçesinde bulunan bu doğal gölde dinlendirici bir mola verin." },
      { day: 4, title: "Boztepe", desc: "Trabzon ve Karadeniz sahilinin panoramik manzarasını izlemek için Boztepe'ye çıkarak turu tamamlayın." }
    ]
  },
  {
    destination_slug: "hidirnebi-plateau",
    slug: "hidirnebi-cal-cave",
    price_from: 130.00,
    currency: "USD",
    featured: false,
    tour_type: "Private",
    duration: "Full Day (approx. 7–8 hours)",
    group_size: nil,

    title_en: "Hıdırnebi Plateau & Çal Cave",
    description_en: "A nature-focused excursion combining an impressive underground cave system with the high-altitude Hıdırnebi Plateau.",
    highlights_en: [
      "Çal Cave's underground water and natural formations",
      "Hıdırnebi Plateau at 1,600 meters",
      "Black Sea highland scenery",
      "Scenic journey through the traditional valleys of the Akçaabat district"
    ],
    itinerary_en: [
      { day: 1, title: "Çal Cave", desc: "Explore this well-known cave system featuring an underground river and natural limestone formations." },
      { day: 2, title: "Hıdırnebi Plateau", desc: "Ascend to 1,600 meters to experience the highland atmosphere, mountain air, and regional scenery before returning to Trabzon." }
    ],

    title_ar: "مرتفعات خضر نبي ومغارة تشال",
    description_ar: "رحلة تركز على الطبيعة تجمع بين نظام كهفي مثير للإعجاب ومرتفعات خضر نبي العالية.",
    highlights_ar: [
      "المياه الجوفية والتكوينات الطبيعية في مغارة تشال",
      "مرتفعات خضر نبي على ارتفاع 1600 متر",
      "مناظر مرتفعات البحر الأسود",
      "رحلة ذات مناظر خلابة عبر الوديان التقليدية في منطقة أكشابات"
    ],
    itinerary_ar: [
      { day: 1, title: "مغارة تشال", desc: "استكشاف هذا النظام الكهفي المعروف الذي يضم نهرًا جوفيًا وتكوينات جيرية طبيعية." },
      { day: 2, title: "مرتفعات خضر نبي", desc: "الصعود إلى ارتفاع 1600 متر للاستمتاع بأجواء المرتفعات والهواء الجبلي والمناظر الإقليمية قبل العودة إلى طرابزون." }
    ],

    title_tr: "Hıdırnebi Yaylası ve Çal Mağarası",
    description_tr: "Etkileyici bir yeraltı mağara sistemi ile yüksek rakımlı Hıdırnebi Yaylası'nı birleştiren doğa odaklı bir gezi.",
    highlights_tr: [
      "Çal Mağarası'ndaki yeraltı suları ve doğal oluşumlar",
      "1.600 metre rakımdaki Hıdırnebi Yaylası",
      "Karadeniz yayla manzaraları",
      "Akçaabat ilçesinin geleneksel vadilerinden geçen manzaralı yolculuk"
    ],
    itinerary_tr: [
      { day: 1, title: "Çal Mağarası", desc: "Yeraltı nehri ve doğal kireçtaşı oluşumlarına ev sahipliği yapan bu bilindik mağara sistemini keşfedin." },
      { day: 2, title: "Hıdırnebi Yaylası", desc: "Yayla atmosferini, dağ havasını ve bölgenin doğasını deneyimlemek için 1.600 metreye çıkın; ardından Trabzon'a dönün." }
    ]
  },
  {
    destination_slug: "rize",
    slug: "rize-tea-experience",
    price_from: 140.00,
    currency: "USD",
    featured: true,
    tour_type: "Private",
    duration: "Full Day (approx. 7–9 hours)",
    group_size: nil,

    title_en: "Rize & Tea Experience",
    description_en: "Explore the coastal city of Rize and its local tea culture with visits to historic sites and botanical gardens.",
    highlights_en: [
      "Rize Castle",
      "Ziraat Botanical Tea Garden",
      "Tea plantation or local tea experience (subject to availability)",
      "Rize city and coastal views"
    ],
    itinerary_en: [
      { day: 1, title: "Rize Castle", desc: "Visit the historic castle offering elevated views of the city and the Black Sea coast." },
      { day: 2, title: "Ziraat Botanical Tea Garden", desc: "Walk through the terraced tea gardens and learn about the region's tea cultivation." },
      { day: 3, title: "Local Tea Experience (Optional/Subject to Availability)", desc: "A potential stop at a tea plantation or local factory to see the tea production process, subject to operational hours." },
      { day: 4, title: "Rize City & Coast", desc: "Free time to explore the city center or coastal area before returning to Trabzon." }
    ],

    title_ar: "ريزه وتجربة الشاي",
    description_ar: "استكشاف مدينة ريزه الساحلية وثقافة الشاي المحلية مع زيارة المواقع التاريخية والحدائق النباتية.",
    highlights_ar: [
      "قلعة ريزه",
      "حديقة زراعات النباتية للشاي",
      "مزارع الشاي أو تجربة الشاي المحلية (حسب التوفر)",
      "إطلالات على مدينة ريزه والساحل"
    ],
    itinerary_ar: [
      { day: 1, title: "قلعة ريزه", desc: "زيارة القلعة التاريخية التي توفر إطلالات مرتفعة على المدينة وساحل البحر الأسود." },
      { day: 2, title: "حديقة زراعات للشاي", desc: "التجول في حدائق الشاي المدرجة والتعرف على زراعة الشاي في المنطقة." },
      { day: 3, title: "تجربة الشاي المحلية (اختياري / حسب التوفر)", desc: "توقف محتمل في مزرعة شاي أو مصنع محلي للتعرف على عملية إنتاج الشاي، رهنًا بساعات العمل." },
      { day: 4, title: "مدينة ريزه والساحل", desc: "وقت حر لاستكشاف وسط المدينة أو المنطقة الساحلية قبل العودة إلى طرابزون." }
    ],

    title_tr: "Rize ve Çay Deneyimi",
    description_tr: "Tarihi mekanlar ve botanik bahçeleri ziyaretleriyle sahil şehri Rize'yi ve yerel çay kültürünü keşfedin.",
    highlights_tr: [
      "Rize Kalesi",
      "Ziraat Botanik Çay Bahçesi",
      "Çay tarlası veya yerel çay deneyimi (müsaitliğe bağlı)",
      "Rize şehir ve sahil manzaraları"
    ],
    itinerary_tr: [
      { day: 1, title: "Rize Kalesi", desc: "Şehrin ve Karadeniz sahilinin yüksekten manzarasını sunan tarihi kaleyi ziyaret edin." },
      { day: 2, title: "Ziraat Botanik Çay Bahçesi", desc: "Teraslanmış çay bahçelerinde yürüyün ve bölgenin çay tarımı hakkında bilgi edinin." },
      { day: 3, title: "Yerel Çay Deneyimi (İsteğe Bağlı / Müsaitliğe Bağlı)", desc: "Çalışma saatlerine bağlı olarak, çay üretim sürecini görmek için bir çay tarlasına veya yerel bir fabrikaya olası bir ziyaret." },
      { day: 4, title: "Rize Şehri ve Sahil", desc: "Trabzon'a dönmeden önce şehir merkezini veya sahil şeridini keşfetmek için serbest zaman." }
    ]
  },
  {
    destination_slug: "elevit-plateau",
    slug: "elevit-plateau",
    price_from: 160.00,
    currency: "USD",
    featured: false,
    tour_type: "Private",
    duration: "Full Day (approx. 9–11 hours)",
    group_size: nil,

    title_en: "Elevit Plateau",
    description_en: "A highland journey deep into the Kaçkar Mountains to experience the high-altitude Elevit Plateau.",
    highlights_en: [
      "Elevit Plateau (1,800+ meters)",
      "Çamlıhemşin and Fırtına Valley scenery",
      "Traditional highland wooden architecture",
      "Alpine mountain environment"
    ],
    itinerary_en: [
      { day: 1, title: "Çamlıhemşin & Fırtına Valley", desc: "Travel inland from the coast through the Fırtına River valley and the district of Çamlıhemşin." },
      { day: 2, title: "Şenyuva Village (Optional)", desc: "A brief stop to see the traditional architecture of Şenyuva." },
      { day: 3, title: "Elevit Plateau", desc: "Ascend the mountain roads to reach Elevit Plateau. Spend time walking in the alpine environment and viewing the traditional highland houses before returning. (Note: Road and weather conditions can affect access, particularly during the winter season. The route is subject to seasonal conditions.)" }
    ],

    title_ar: "مرتفعات إيليفيت",
    description_ar: "رحلة جبلية عميقة في جبال كاجكار لتجربة مرتفعات إيليفيت العالية.",
    highlights_ar: [
      "مرتفعات إيليفيت (أكثر من 1800 متر)",
      "مناظر تشاملي همشين ووادي فيرتينا",
      "الهندسة المعمارية الخشبية الجبلية التقليدية",
      "بيئة الجبال الألبية"
    ],
    itinerary_ar: [
      { day: 1, title: "تشاملي همشين ووادي فيرتينا", desc: "السفر من الساحل نحو الداخل عبر وادي نهر فيرتينا ومنطقة تشاملي همشين." },
      { day: 2, title: "قرية شينيوفا (اختياري)", desc: "توقف قصير لمشاهدة الهندسة المعمارية التقليدية في شينيوفا." },
      { day: 3, title: "مرتفعات إيليفيت", desc: "صعود الطرق الجبلية للوصول إلى مرتفعات إيليفيت. قضاء الوقت في التجول في البيئة الألبية ومشاهدة المنازل الجبلية التقليدية قبل العودة. (ملاحظة: يمكن أن تؤثر ظروف الطريق والطقس على الوصول، خاصة خلال فصل الشتاء. المسار يخضع للظروف الموسمية.)" }
    ],

    title_tr: "Elevit Yaylası",
    description_tr: "Yüksek rakımlı Elevit Yaylası'nı deneyimlemek için Kaçkar Dağları'nın derinliklerine yapılan bir yayla yolculuğu.",
    highlights_tr: [
      "Elevit Yaylası (1.800+ metre)",
      "Çamlıhemşin ve Fırtına Vadisi manzaraları",
      "Geleneksel ahşap yayla mimarisi",
      "Alpin dağ doğası"
    ],
    itinerary_tr: [
      { day: 1, title: "Çamlıhemşin ve Fırtına Vadisi", desc: "Sahilden içeriye doğru ilerleyerek Fırtına Deresi vadisinden ve Çamlıhemşin ilçesinden geçin." },
      { day: 2, title: "Şenyuva Köyü (İsteğe Bağlı)", desc: "Şenyuva'nın geleneksel mimarisini görmek için kısa bir mola." },
      { day: 3, title: "Elevit Yaylası", desc: "Dağ yollarından tırmanarak Elevit Yaylası'na ulaşın. Dönüşten önce alpin ortamda yürüyüş yaparak ve geleneksel yayla evlerini görerek vakit geçirin. (Not: Yol ve hava koşulları, özellikle kış aylarında ulaşımı etkileyebilir. Rota mevsimsel koşullara tabidir.)" }
    ]
  },
  {
    destination_slug: "hamsikoy",
    slug: "hamsikoy-zigana",
    price_from: 130.00,
    currency: "USD",
    featured: false,
    tour_type: "Private",
    duration: "Full Day (approx. 6–8 hours)",
    group_size: nil,

    title_en: "Hamsiköy & Zigana",
    description_en: "A scenic mountain drive exploring the Zigana route and the traditional village of Hamsiköy.",
    highlights_en: [
      "Zigana mountain scenery",
      "Hamsiköy village",
      "Traditional local atmosphere",
      "Hamsiköy sütlaç (rice pudding)"
    ],
    itinerary_en: [
      { day: 1, title: "Zigana Mountains", desc: "Drive south from Trabzon into the Pontic Mountains, passing through the scenic Zigana route." },
      { day: 2, title: "Hamsiköy Village", desc: "Descend into the village of Hamsiköy, enjoy the mountain atmosphere, and taste the local traditional sütlaç (rice pudding) before returning to Trabzon. (Optional Note: A visit to Limni Lake may be possible subject to route, time, and prior arrangement.)" }
    ],

    title_ar: "هامسيكوي وزيغانا",
    description_ar: "رحلة جبلية خلابة لاستكشاف طريق زيغانا وقرية هامسيكوي التقليدية.",
    highlights_ar: [
      "مناظر جبال زيغانا",
      "قرية هامسيكوي",
      "الأجواء المحلية التقليدية",
      "أرز بالحليب (سوتلاتش) الخاص بقرية هامسيكوي"
    ],
    itinerary_ar: [
      { day: 1, title: "جبال زيغانا", desc: "القيادة جنوبًا من طرابزون نحو جبال بونتيك، مرورًا بطريق زيغانا ذي المناظر الخلابة." },
      { day: 2, title: "قرية هامسيكوي", desc: "النزول إلى قرية هامسيكوي للاستمتاع بالأجواء الجبلية وتذوق حلوى الأرز بالحليب التقليدية المحلية قبل العودة إلى طرابزون. (ملاحظة اختيارية: يمكن زيارة بحيرة ليمني حسب الطريق والوقت المتاح والترتيب المسبق.)" }
    ],

    title_tr: "Hamsiköy ve Zigana",
    description_tr: "Zigana rotasını ve geleneksel Hamsiköy köyünü keşfeden manzaralı bir dağ gezisi.",
    highlights_tr: [
      "Zigana dağ manzaraları",
      "Hamsiköy köyü",
      "Geleneksel yerel atmosfer",
      "Hamsiköy sütlacı"
    ],
    itinerary_tr: [
      { day: 1, title: "Zigana Dağları", desc: "Trabzon'dan güneye, Pontus Dağları'na doğru manzaralı Zigana rotası üzerinden ilerleyin." },
      { day: 2, title: "Hamsiköy", desc: "Hamsiköy köyüne inerek dağ atmosferinin tadını çıkarın ve Trabzon'a dönmeden önce meşhur yerel sütlacı tadın. (İsteğe Bağlı Not: Rota, zaman ve önceden planlamaya bağlı olarak Limni Gölü'ne bir ziyaret gerçekleştirilebilir.)" }
    ]
  },
  {
    destination_slug: "ordu",
    slug: "black-sea-coastal-drive",
    price_from: 120.00,
    currency: "USD",
    featured: false,
    tour_type: "Private",
    duration: "Full Day (approx. 11–13 hours)",
    group_size: nil,

    title_en: "Black Sea Coastal Drive",
    description_en: "A full-day coastal journey exploring the cities and historical sites of Giresun and Ordu.",
    highlights_en: [
      "Giresun Castle and city",
      "Ordu city coastal area",
      "Ordu Boztepe",
      "Boztepe cable car (subject to operation)"
    ],
    itinerary_en: [
      { day: 1, title: "Tirebolu (Optional)", desc: "If time and route conditions allow, a coastal stop in the town of Tirebolu." },
      { day: 2, title: "Giresun Castle & City", desc: "Arrive in Giresun and visit the historic castle offering panoramic views over the city and sea." },
      { day: 3, title: "Ordu City & Boztepe", desc: "Continue west to Ordu. Explore the city and ride the cable car (subject to operating conditions) to the summit of Boztepe for sweeping views of the coastline before the drive back to Trabzon." }
    ],

    title_ar: "جولة الساحل على البحر الأسود",
    description_ar: "رحلة ساحلية ليوم كامل لاستكشاف المدن والمواقع التاريخية في غيرسون وأوردو.",
    highlights_ar: [
      "قلعة ومدينة غيرسون",
      "المنطقة الساحلية لمدينة أوردو",
      "بوزتبه في أوردو",
      "تلفريك بوزتبه (حسب التشغيل)"
    ],
    itinerary_ar: [
      { day: 1, title: "تيريبولو (اختياري)", desc: "توقف ساحلي في بلدة تيريبولو، إذا سمح الوقت وظروف الطريق." },
      { day: 2, title: "قلعة ومدينة غيرسون", desc: "الوصول إلى غيرسون وزيارة القلعة التاريخية التي توفر إطلالات بانورامية على المدينة والبحر." },
      { day: 3, title: "مدينة أوردو وبوزتبه", desc: "المتابعة غربًا إلى أوردو. استكشاف المدينة وركوب التلفريك (حسب ظروف التشغيل) إلى قمة بوزتبه للاستمتاع بإطلالات واسعة على الساحل قبل العودة إلى طرابزون." }
    ],

    title_tr: "Karadeniz Sahil Turu",
    description_tr: "Giresun ve Ordu'nun şehirlerini ve tarihi yerlerini keşfeden tam günlük bir sahil yolculuğu.",
    highlights_tr: [
      "Giresun Kalesi ve şehri",
      "Ordu şehri sahil bölgesi",
      "Ordu Boztepe",
      "Boztepe teleferiği (çalışma durumuna bağlı)"
    ],
    itinerary_tr: [
      { day: 1, title: "Tirebolu (İsteğe Bağlı)", desc: "Zaman ve rota koşulları elverirse, sahil kasabası Tirebolu'da bir mola." },
      { day: 2, title: "Giresun Kalesi ve Şehri", desc: "Giresun'a varış ve şehir ile deniz üzerinde panoramik manzaralar sunan tarihi kaleyi ziyaret." },
      { day: 3, title: "Ordu Şehri ve Boztepe", desc: "Batıya, Ordu'ya doğru devam edin. Şehri keşfedin ve Trabzon'a dönüş yolculuğundan önce sahil şeridinin geniş manzaralarını görmek için teleferiğe (çalışma durumuna bağlı olarak) binerek Boztepe'nin zirvesine çıkın." }
    ]
  }
]

additional_tours_data.each do |data|
  tour = Tour.find_or_initialize_by(slug: data[:slug])
  next unless tour.new_record?

  dest = Destination.find_by(slug: data[:destination_slug])
  tour.destination = dest
  tour.active = true
  tour.price_from = data[:price_from]
  tour.currency = data[:currency]
  tour.featured = data[:featured]
  tour.tour_type = data[:tour_type]
  tour.duration = data[:duration]
  tour.group_size = data[:group_size]

  # EN
  tour.title_en = data[:title_en]
  tour.description_en = data[:description_en]
  tour.highlights_en = data[:highlights_en]
  tour.itinerary_en = data[:itinerary_en].map { |i| i.transform_keys(&:to_s) }
  tour.included_en = additional_tours_shared[:included_en]
  tour.excluded_en = additional_tours_shared[:excluded_en]
  tour.meeting_point_en = additional_tours_shared[:meeting_point_en]
  tour.cancellation_policy_en = additional_tours_shared[:cancellation_policy_en]

  # AR
  tour.title_ar = data[:title_ar]
  tour.description_ar = data[:description_ar]
  tour.highlights_ar = data[:highlights_ar]
  tour.itinerary_ar = data[:itinerary_ar].map { |i| i.transform_keys(&:to_s) }
  tour.included_ar = additional_tours_shared[:included_ar]
  tour.excluded_ar = additional_tours_shared[:excluded_ar]
  tour.meeting_point_ar = additional_tours_shared[:meeting_point_ar]
  tour.cancellation_policy_ar = additional_tours_shared[:cancellation_policy_ar]

  # TR
  tour.title_tr = data[:title_tr]
  tour.description_tr = data[:description_tr]
  tour.highlights_tr = data[:highlights_tr]
  tour.itinerary_tr = data[:itinerary_tr].map { |i| i.transform_keys(&:to_s) }
  tour.included_tr = additional_tours_shared[:included_tr]
  tour.excluded_tr = additional_tours_shared[:excluded_tr]
  tour.meeting_point_tr = additional_tours_shared[:meeting_point_tr]
  tour.cancellation_policy_tr = additional_tours_shared[:cancellation_policy_tr]

  tour.save!
  puts "Seeded Tour: #{tour.title_en} (#{tour.slug})"
end

puts "Total Tours in database: #{Tour.count}"

if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  puts "Seeding admin user..."
  admin = User.find_or_initialize_by(email_address: ENV["ADMIN_EMAIL"])
  if admin.new_record?
    admin.password = ENV["ADMIN_PASSWORD"]
    admin.save!
    puts "Admin user created (#{admin.email_address})."
  else
    puts "Admin user already exists (#{admin.email_address}). Password was not changed."
  end
end

puts "Seeding Business Setting..."
BusinessSetting.first_or_create!(
  company_name: '61 EDİZ TRAVEL',
  whatsapp_number: '+905540171890',
  tursab_number: '15956',
  singleton_guard: true
)
puts "Business setting verified."

puts "Seeding Commercial Vehicles..."
[
  { name: 'Mercedes Vito', category: 'chauffeured', price_from: 80, currency: 'USD' },
  { name: 'Renault Taliant', category: 'self_drive', price_from: 40, currency: 'USD' },
  { name: 'Dacia Duster', category: 'self_drive', price_from: 60, currency: 'USD' }
].each do |vehicle_attrs|
  CommercialVehicle.find_or_create_by!(name: vehicle_attrs[:name], category: vehicle_attrs[:category]) do |v|
    v.price_from = vehicle_attrs[:price_from]
    v.currency = vehicle_attrs[:currency]
  end
end
puts "Commercial Vehicles verified."
