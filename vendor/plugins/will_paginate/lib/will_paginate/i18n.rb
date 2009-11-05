module WillPaginate
  
  # Contains all of the internationalization (i18n)
  # information that WillPaginate::LinkRender uses.
  #
  # Each of several strings can be customized. Each string has
  # a default value that can be overridden on a site-wide or
  # page-specific basis. (NB: page-specific translations won't work
  # for inline templates; only for the more typical views.)
  #
  # ==== Previous
  # * Default: "&laquo; Previous" (an HTML left-angle-quote and 'Previous')
  # * Site-wide key: "will_paginate.previous_label"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.previous_label"
  #
  # ==== Next
  # * Default: "Next &raquo;" ('Next' and an HTML right-angle-quote)
  # * Site-wide key: "will_paginate.next_label"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.next_label"
  #
  # ==== Gap Marker
  # * Default: "<span class="gap">&hellip;</span>" (an HTML ellipsis wrapped in a span)
  # * Site-wide key: "will_paginate.gap_marker"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.gap_marker"
  # 
  # ==== Entry Name
  # Used when the type of paginated object cannot be otherwise determined.
  # * Default: "entry"
  # * Site-wide key: "will_paginate.entry_name"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.entry_name"
  #
  # ==== Page entries info (zero elements)
  # * Default: "No {{pluralized_entry_name}} found"
  # * Site-wide key: "will_paginate.page_entries_info.zero"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.page_entries_info.zero"
  # * Interpolation options: "pluralized_entry_name"
  #
  # # ==== Page entries info (one element)
  # * Default: "Displaying <em>1</em> {{entry_name}}"
  # * Site-wide key: "will_paginate.page_entries_info.one"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.page_entries_info.one"
  # * Interpolation options: "entry_name"
  #
  # # ==== Page entries info (one page of elements)
  # * Default: "Displaying <em>all #{total_count}</em> {{pluralized_entry_name}}"
  # * Site-wide key: "will_paginate.page_entries_info.all"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.page_entries_info.all"
  # * Interpolation options: "pluralized_entry_name", "total_count"
  #
  # # ==== Page entries info (n-m of x elements)
  # * Default: "Displaying {{pluralized_entry_name}} <em>{{start_count}}&nbsp;-&nbsp;{{end_count}}</em> of <em>{{total_count}}</em> in total"
  # * Site-wide key: "will_paginate.page_entries_info.n_to_m_of_x"
  # * Page-specific key: "#{controller}.#{view}.will_paginate.page_entries_info.n_to_m_of_x"
  # * Interpolation options: "pluralized_entry_name", "start_count", "end_count", "total_count"
  #
  # Example: set some site-wide values and page-specific overrides for blog posts:
  #
  #   # in RAILS_ROOT/config/locales/en.yml:
  #   en:
  #     will_paginate:
  #       previous_label: "<-- Previous"
  #       next_label: "Next -->"
  #       gap_marker: " - "
  #       page_entries_info:
  #         one: "One {{entry_name}} found:"
  #         all: "All {{pluralized_entry_name}}:"
  #         n_to_m_of_x: "{{pluralized_entry_name}} {{start_count}} to {{end_count}} of {{total_count}}:"
  #     posts:
  #       index:
  #         will_paginate:
  #           previous_label: "<-- Earlier"
  #           next_label: "Later -->"
  module I18n
    
    def self.append_translations_load_path
      locales_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'locales'))
      Dir.glob("#{locales_dir}/**/*.{rb,yml}").each do |path|
        unless ::I18n.load_path.include?(path)
          ::I18n.load_path << path
        end
      end
    end
    
    def previous_label
      if options[:prev_label]
        WillPaginate::Deprecation::warn(":prev_label view parameter is deprecated; please see WillPaginate::I18n.", caller)
        options[:prev_label]
      elsif options[:previous_label]
        WillPaginate::Deprecation::warn(":previous_label view parameter is deprecated; please see WillPaginate::I18n.", caller)
        options[:previous_label]
      else
        translate :previous_label
      end
    end
    
    def next_label
      if options[:next_label]
        WillPaginate::Deprecation::warn(":next_label view parameter is deprecated; please see WillPaginate::I18n.", caller)
        options[:next_label]
      else
        translate :next_label
      end
    end
    
    def gap_marker
      if @gap_marker
        WillPaginate::Deprecation::warn("WillPaginate::LinkRenderer#gap_marker is deprecated; please see WillPaginate::I18n.", caller)
        @gap_marker
      else
        translate :gap_marker
      end
    end
    
    def page_entries_info
      entry_name, pluralized_entry_name = entry_name_and_pluralized_for_collection
      interpolations = {
        :entry_name => entry_name,
        :pluralized_entry_name => pluralized_entry_name,
        :total_count => collection.size
      }
      if self.collection.total_pages < 2
        case collection.size
        when 0; key = 'page_entries_info.zero'
        when 1; key = 'page_entries_info.one'
        else;   key = 'page_entries_info.all'
        end
      else
        key = 'page_entries_info.n_to_m_of_x'
        interpolations.merge!({
          :start_count => self.collection.offset + 1,
          :end_count => self.collection.offset + self.collection.length,
          :total_count => self.collection.total_entries
        })
      end
      translate key, interpolations
    end
    
    protected
    
    attr_reader :template, :collection, :options
    
    def entry_name_and_pluralized_for_collection
      if self.options[:entry_name]
        WillPaginate::Deprecation::warn(":entry_name view parameter is deprecated; please see WillPaginate::I18n", caller)
        [ self.options[:entry_name], self.options[:entry_name].pluralize ]
      elsif self.collection.empty?
        e = translate :entry_name
        [e, e.pluralize]
      elsif self.collection.first.class.respond_to?(:human_name)
        [
          self.collection.first.class.human_name(:count => 1),
          self.collection.first.class.human_name(:count => 10)
        ]
      else
        e = self.collection.first.class.name.underscore.sub('_', ' ')
        [e, e.pluralize]
      end
    end
    
    def translate(suffix, interpolations = {})
      if template_supports_page_specific_translations?
        primary = ".will_paginate.#{suffix}"
        default = [*interpolations.fetch(:default, [])]
        default.unshift "will_paginate.#{suffix}"
        interpolations[:default] = default
      else
        primary = "will_paginate.#{suffix}"
      end
      template.t primary, self.options.merge(interpolations)
    end
    
    def template_supports_page_specific_translations?
      template.respond_to? :path_without_format_and_extension
    end
    
  end
  
end
