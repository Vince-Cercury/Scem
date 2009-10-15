class OrganismsUserObserver < ActiveRecord::Observer
  def after_create(organisms_user)
    organisms_user.reload

      #for each _organism_moderator and organism_admin, send signup notification email
      @organism_admins_or_modo = organisms_user.organism.admins + organisms_user.organism.moderators
      @organism_admins_or_modo.each  do |admin_or_modo|
        OrganismsUserMailer.deliver_creation_notification(admin_or_modo, organisms_user.user, organisms_user.organism, organisms_user.role) if organisms_user.pending? unless admin_or_modo.email==""
      end
  end

  def after_save(organisms_user)
    organisms_user.reload

    OrganismsUserMailer.deliver_activation_notification(organisms_user.user, organisms_user.organism, organisms_user.role) if organisms_user.recently_activated? unless organisms_user.email==""
    
  end
end

