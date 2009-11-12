class ActivitiesController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:show, :index]

  # Protect these actions behind an admin login
  before_filter :is_admin?, :only => [:destroy]

  # Protect these actions behind a moderator login
  before_filter :ensure_is_moderator?, :except => [:index, :show]

  # GET /activities
  # GET /activities.xml
  def index
    @activities = Activity.paginate :per_page => ENV['PER_PAGE_ACTIVITIES'], :page => params[:page], :order => 'created_at DESC'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => 'activities_list'
        end
      }
    end
  end

  # GET /activities/1
  # GET /activities/1.xml
  def show
    @activity = Activity.find(params[:id])
    @organisms = @activity.organisms.search(params[:search], params[:page])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @activity }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/organisms/organisms_list'
        end
      }
    end
  end

  # GET /activities/new
  # GET /activities/new.xml
  def new
    @activity = Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
  end

  # POST /activities
  # POST /activities.xml
  def create
    @activity = Activity.new(params[:activity])

    respond_to do |format|
      if @activity.save
        flash[:notice] = I18n.t('activities.controller.Successfully_created')
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.xml
  def update
    @activity = Activity.find(params[:id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        flash[:notice] = I18n.t('activities.controller.Successfully_updated')
        format.html { redirect_to(activities_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to(activities_url) }
      format.xml  { head :ok }
    end
  end
end
