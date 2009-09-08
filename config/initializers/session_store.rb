# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_scem_session',
  :secret      => '0f98ca160df32237ae9c5480511627cf4c42bb7c61359bca1d7850191463da9740602dd362a6c7a3b3eef58f400abaec15716d241303f7c24b0b5e768c69b62f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
