xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset(
  "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:xhtml" => "http://www.w3.org/1999/xhtml"
) do
  
  # Lambda to render a url node for a given route and optional record
  render_node = -> (path_helper, record = nil) do
    @locales.each do |loc|
      loc_param = loc == I18n.default_locale ? nil : loc
      
      # Build the main loc URL
      args = []
      args << record if record
      args << { locale: loc_param }
      
      url = send(path_helper, *args)
      
      xml.url do
        xml.loc url
        
        # Hreflang for all available locales
        @locales.each do |alt_loc|
          alt_loc_param = alt_loc == I18n.default_locale ? nil : alt_loc
          alt_args = []
          alt_args << record if record
          alt_args << { locale: alt_loc_param }
          
          alt_url = send(path_helper, *alt_args)
          xml.xhtml :link, rel: "alternate", hreflang: alt_loc.to_s, href: alt_url
        end
        
        # x-default points to the default locale
        default_args = []
        default_args << record if record
        default_args << { locale: nil }
        default_url = send(path_helper, *default_args)
        xml.xhtml :link, rel: "alternate", hreflang: "x-default", href: default_url
        
        if record.respond_to?(:updated_at)
          xml.lastmod record.updated_at.iso8601
        end
      end
    end
  end

  static_routes = [
    :root_url, :tours_url, :services_url, :airport_transfer_url, 
    :car_rental_url, :chauffeured_car_url, :private_tours_url, 
    :packages_url, :accommodations_url, :travel_guides_url, 
    :about_url, :contact_url, :faq_url, :plan_your_trip_url
  ]

  static_routes.each do |route|
    render_node.call(route)
  end

  @tours.each { |tour| render_node.call(:tour_url, tour) }
  @travel_guides.each { |guide| render_node.call(:travel_guide_url, guide) }
  @packages.each { |package| render_node.call(:package_url, package) }
  @accommodations.each { |acc| render_node.call(:accommodation_url, acc) }
end
