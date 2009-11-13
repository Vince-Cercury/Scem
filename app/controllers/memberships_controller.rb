class MembershipsController < ApplicationController

  # store the current location in case of an atempt to login, for redirecting back
  before_filter :store_location, :only => [:index, :accept]

  before_filter :is_logged?, :except => [:index]

  before_filter :ensure_organism_parameter?, :except => [:index]
  before_filter :ensure_role_s_parameter?, :only  => [:index]
  before_filter :ensure_a_role_parameter, :only  => [:create_or_update, :create_or_update_current_user, :accept]
  before_filter :ensure_user_parameter?, :only => [:index, :create_or_update, :destroy_relation, :accept, :refuse]
  #the current user cannot decide himself to become admin or moderator of the organism
  before_filter :cant_become_himself_admin_or_modo, :only  => [:create_or_update_current_user]


  # only an admin or moderator of the organism or an admin or moderator of the whole system
  before_filter :ensure_current_user_moderator_of_organism?, :only => [:create_or_update, :destroy_relation, :accept, :refuse]


  def index
      @user = User.find(params[:user_id])
      @organisms = @user.search_organisms(params[:role],params[:search], params[:page])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
      format.js {
        render :update do |page|
          page.replace_html 'results', :partial => '/organisms/organisms_list'
        end
      }
    end
  end


  def create_or_update

    organism = Organism.find(params[:organism_id])
    organism_user = organism.organisms_users.find(:first, :conditions => ["user_id=? ", params[:user_id]])

    if(organism_user.nil?)
      
      organism_user = OrganismsUser.new
      organism_user.organism_id=params[:organism_id]
      organism_user.user_id=params[:user_id]
      organism_user.register!
    end

    organism_user.role = params[:role]

    respond_to do |format|
      if organism_user.save
        flash[:notice] = I18n.t('memberships.controller.Update_done')
        format.html { redirect_back_or_default('/') }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => organism_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_or_update_current_user

    organism = Organism.find(params[:organism_id])
    organism_user = organism.organisms_users.find(:first, :conditions => ["user_id=? ", self.current_user.id])

    if(organism_user.nil?)
      organism_user = OrganismsUser.new
      organism_user.organism_id=params[:organism_id]
      organism_user.user_id=current_user.id
      organism_user.register! unless params[:members_password] && params[:members_password] == organism.members_password
    end

    organism_user.role=params[:role]

    organism_user.activate! if params[:members_password] && params[:members_password] == organism.members_password

    
    respond_to do |format|
      if organism_user
        flash[:notice] = I18n.t('memberships.controller.Update_done')
        format.html { redirect_back_or_default('/') }
        format.xml  { head :ok }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => organism_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_relation

    organism = Organism.find(params[:organism_id])
    organism_user = organism.organisms_users.find(:first, :conditions => ["user_id=? ", params[:user_id]])

    organism_user.destroy unless(organism_user.nil?)

    respond_to do |format|
      format.html { redirect_back_or_default('/') }
      format.xml  { head :ok }
    end
  end

  def destroy_current_user_relation

    organism = Organism.find(params[:organism_id])
    organism_user = organism.organisms_users.find(:first, :conditions => ["user_id=? ", current_user.id])

    organism_user.destroy unless(organism_user.nil?)

    respond_to do |format|
      format.html { redirect_back_or_default('/') }
      format.xml  { head :ok }
    end
  end

  def accept
    organism = Organism.find(params[:organism_id])
    organism_user = organism.organisms_users.find(:first, :conditions => ["user_id=? ", params[:user_id]])

    organism_user.role = params[:role]

    if organism_user && !organism_user.active?
      organism_user.activate!
      flash[:notice] = I18n.t('memberships.controller.Update_done')
      redirect_to(organism)
    else
      flash[:error]  = I18n.t('memberships.controller.Update_error')
      redirect_back_or_default('/')
    end

  end

  def refuse
    destroy_relation
  end

  protected

  def ensure_organism_parameter?
    param_uncorrect_redirection unless !params[:organism_id].nil? and Organism.exists?(params[:organism_id])
  end


  def ensure_user_parameter?
    param_uncorrect_redirection unless !params[:user_id].nil? and User.exists?(params[:user_id])
  end


  def ensure_a_role_parameter
    params[:role] = "member" unless (params[:role]=="admin" or params[:role]=="moderator" or params[:role]=="member")
  end

  def ensure_role_s_parameter?
    if(!params[:organism_id].nil?)
      params[:role] = "members" unless (params[:role]=="admins" or params[:role]=="moderators" or params[:role]=="members")
    else
      params[:role] = "member" unless (params[:role]=="admin" or params[:role]=="moderator" or params[:role]=="member")
    end
  end

  def ensure_current_user_moderator_of_organism?
    organism = Organism.find(params[:organism_id])
    no_permission_redirection unless organism.is_user_moderator?(current_user)
  end

  def param_uncorrect_redirection
    flash[:error] = I18n.t('memberships.controller.Incorrect_parameter')
    redirect_to root_path
  end

  def cant_become_himself_admin_or_modo
    if(params[:role] == "admin" or params[:role] == "moderator")
      flash[:error] = I18n.t('memberships.controller.Cant_decide_alone')
      redirect_to root_path
    end
  end

end
