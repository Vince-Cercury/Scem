# To change this template, choose Tools | Templates
# and open the template in the editor.

class SearchsTools

  def self.prepare_conditions(search, search_attribute, more_conditions='', more_conditions_param=Array.new)


    not_to_consider = ['le', 'la', 'les', 'un', 'des', 'et', 'une', 'du', 'de', 'au', 'ou', 'ce', 'cet', 'cette']

    search = search.to_s.split
    search_query = ''
    search_keyword = Array.new
    search.each do |a_keyword|
      if !not_to_consider.include?(a_keyword)
        if search_query.blank?
          search_query += "(#{search_attribute} LIKE ?"
          search_keyword << "%#{a_keyword}%"
        else
          search_query += " OR #{search_attribute} LIKE ?"
          search_keyword << "%#{a_keyword}%"
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
