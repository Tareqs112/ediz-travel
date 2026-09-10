class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.fixed_translates(*attributes, **options)
    translates(*attributes, **options)

    attributes.each do |attr|
      [:en, :ar, :tr].each do |loc|
        define_method("#{attr}_#{loc}=") do |*args, **kwargs|
          super(*args, **kwargs).tap { mobility_backends[attr].clear_cache }
        end
      end

      define_method("#{attr}=") do |*args, **kwargs|
        super(*args, **kwargs).tap { mobility_backends[attr].clear_cache }
      end

      [:ar, :tr].each do |loc|
        define_method("#{attr}_#{loc}") do |*args, **kwargs|
          val = super(*args, **kwargs)
          val.presence || send("#{attr}_en")
        end
      end
    end
  end
end
