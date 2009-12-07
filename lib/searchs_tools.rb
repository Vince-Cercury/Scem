# To change this template, choose Tools | Templates
# and open the template in the editor.

class SearchsTools

  def self.prepare_conditions(search, search_attributes, more_conditions='', more_conditions_param=Array.new)


    not_to_consider = ["'", 'le', 'la', 'les', 'un', 'des', 'et', 'une', 'du', 'de', 'au', 'ou', 'ce', 'cet', 'cette']

    search = search.to_s.split(/(\W)/)
    search_query = ''
    search_keyword = Array.new

    search_attributes_array = search_attributes.to_s.split(' OR ')

    search.each do |a_keyword|
      if !not_to_consider.include?(a_keyword) && a_keyword.size>1
        search_attributes_array.each do |attribute|
          if search_query.blank?
            search_query += "(#{attribute} LIKE ?"
            search_keyword << "%#{a_keyword}%"
          else
            search_query += " OR #{attribute} LIKE ?"
            search_keyword << "%#{a_keyword}%"
          end
        end
      end
    end
    if !search_query.blank?
      search_query += ') AND '
    end


    search_query += more_conditions
    more_conditions_param.each do |param|
      search_keyword << param
    end

    conditions =  [search_query] + search_keyword
    
    return conditions
  end

end
