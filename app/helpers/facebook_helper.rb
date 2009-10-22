module FacebookHelper
  def fb_logout_link(text,url,*args)
    js = update_page do |page|
      page.call "FB.Connect.logoutAndRedirect",url
      # When session is valid, this call is meaningless, since we already redirect
      # When session is invalid, it will log the user out of the system.
      page.redirect_to url # You can use any *string* based path here
    end
    link_to_function text, js, *args
  end

end
