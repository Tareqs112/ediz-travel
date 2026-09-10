Mobility.configure do
  plugins do
    backend :container
    active_record
    reader
    writer
    query
    cache
    fallbacks
    locale_accessors
  end
end
