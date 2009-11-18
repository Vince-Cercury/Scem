class SearchsController < ApplicationController
  def index

    
    terms_futur = Term.search_has_publisher_futur(params[:search], params[:page], ENV['PER_PAGE'])
    terms_past = Term.search_has_publisher_past(params[:search], params[:page], ENV['PER_PAGE'])

    if params[:focus].blank? || params[:focus] == 'terms_past'
      @terms = terms_past
    elsif params[:focus].blank? || params[:focus] == 'terms_futur'
      @terms = terms_futur
    end
#    terms_scope = Term.event_name_like_any(keywords).state_equal_to('active').event_state_equal_to('active').event_is_private_equal_to(false)
#    terms_past_scope = terms_scope.start_at_less_than(Time.now)
#    terms_futur_scope = terms_scope.start_at_greater_than(Time.now)
#    raise terms_past_scope.count.inspect
#
#    #terms in a category
#    terms_by_category = Array.new
#    i = 0
#    keywords.each do |category|
#      terms_by_category[i] = Hash.new
#      terms_by_category[i]['category'] = category
#      terms_by_category[i]['terms_scope'] =  terms_by_category[i]['terms_scop'].event_category_name_like(category.name)
#      terms_by_category[i]['terms_past_scope'] = terms_scope.start_at_less_than(Time.now)
#      terms_by_category[i]['terms_futur_scope'] = terms_scope.start_at_greater_than(Time.now)
#      i=i+1
#    end
#
#    #organisms
#    organisms_scope_past = Organism.name_like_all(keywords)
#
#    #organisms in a activity
#    organisms_by_activity = Array.new
#    i = 0
#    keywords.each do |activity|
#      organisms_by_activity[i] = Hash.new
#      organisms_by_activity[i]['category'] = activity
#      organisms_by_activity[i]['organisms_scope'] =  organisms_by_activity[i]['organisms_scope'].activity_name_like(activity.name)
#      i=i+1
#    end
#
#    #galleries
#    galleries_scope = Gallery.name_like_any(keywords)

  end
end
