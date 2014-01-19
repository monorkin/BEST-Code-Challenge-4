class User < ActiveRecord::Base

	#####################
    ### Relationships ###
    #####################
	has_and_belongs_to_many :roles

	##################
    ### Encription ###
    ##################
	attr_accessor :password, :password_confirmation
	before_save :encryptPassword

	##################
    ### Validation ###
    ##################
	validates_confirmation_of :password
	validates_presence_of :password, :on => :create
	validates_presence_of :loginUsername
	validates_uniqueness_of :loginUsername

	before_create { generateToken(:loginAuthToken) }
  
  	###############
    ### Methods ###
    ###############

	def authenticate(name, password)
	  	user = User.find_by loginUsername: name
	  	if user && user.loginPasswordHash == BCrypt::Engine.hash_secret(password, user.loginPasswordSalt)
	  	  	return user
	  	else
	  	  	return nil
	  	end
	end # authenticate
  
	def encryptPassword
	  if password.present?
	    	self.loginPasswordSalt = BCrypt::Engine.generate_salt
	    	self.loginPasswordHash = BCrypt::Engine.hash_secret(password, loginPasswordSalt)
	  end
	end # encryptPassword

  	def generateToken(column)
	  	begin
	    	self[column] = SecureRandom.urlsafe_base64
	  	end while User.exists?(column => self[column])
	end # generateToken
end