class CategoriesController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # Protect these actions behind an admin login
  before_filter :is_admin?, :only => [:destroy]

  # Protect these actions behind a moderator login
  before_filter :ensure_is_moderator?, :except => [:index, :show]

  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.paginate :per_page => ENV['PER_PAGE'], :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'categories_list'
        end
      }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    if params[:category_id]
      @category = Category.find(params[:category_id])
      date_param = params[:id]
    else
      @category = Category.find(params[:id])
    end

    @show_end_date = true
    

    if !date_param
      if params[:period] == "past"
        @period_link_param = "futur"
        @terms = Term.search_has_publisher_past_by_category(params[:search], params[:page], @category.id)
      else
        @period_link_param = "past"
        @show_end_date = false
        @terms = Term.search_has_publisher_futur_by_category(params[:search], params[:page], @category.id)
      end
    else
      @the_selected_date = Time.parse(date_param)
      today = Time.zone.now
      #if date selected is the same as today
      if @the_selected_date.strftime("%y") == today.strftime("%y") && @the_selected_date.strftime("%m") == today.strftime("%m") && @the_selected_date.strftime("%d") == today.strftime("%d")
        if params[:period] == "past"
          @period_link_param = "futur"
          @terms = Term.search_has_publisher_past_by_date_and_category(params[:search], params[:page], @category.id, @the_selected_date)
        else
          @period_link_param = "past"
          @show_end_date = false
          @terms = Term.search_has_publisher_futur_by_date_and_category(params[:search], params[:page], @category.id, @the_selected_date)
        end
      else
        @terms = Term.search_has_publisher_by_date_and_category(params[:search], params[:page], @category.id, @the_selected_date)
      end
    end

    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @category }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/terms/terms_list'
        end
      }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        flash[:notice] = 'Category was successfully created.'
        format.html { redirect_to new_category_path }
        format.xml  { render :xml => categories_path, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Category was successfully updated.'
        format.html { redirect_to(categories_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end
end
