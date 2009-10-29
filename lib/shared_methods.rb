module SharedMethods

  def self.included(base)
    base.send :include, InstanceMethods
  end

  module InstanceMethods

    # Remove white space from end of strings of every attributes
    def remove_attributes_whitespace
      self.attributes.each do |key,value|
        if value.kind_of(String) && !value.blank?
          write_attribute key, value.strip
        end
      end
    end

    def remove_whitespace_from_name
      self.name = self.name.strip
    end

  end

end
