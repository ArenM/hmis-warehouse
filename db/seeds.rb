require 'faker'

# Add roles
admin = Role.where(name: 'admin').first_or_create
dnd_staff = Role.where(name: 'dnd_staff').first_or_create

# Add a user.  This should not be added in production
unless Rails.env =~ /production|staging/
  initial_password = Faker::Internet.password
  user = User.new
  user.email = 'noreply@example.com'
  user.first_name = "Sample"
  user.last_name = 'Admin'
  user.password = user.password_confirmation = initial_password
  user.confirmed_at = Time.now
  user.roles = [admin, dnd_staff]
  user.save!
  puts "Created initial admin email: #{user.email}  password: #{user.password}"
end
