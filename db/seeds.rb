u = User.find_or_initialize_by \
  firstname: 'Free',
  lastname: 'User',
  role: Role.find_by_name('Free'),
  email: 'freeuser@rever.local'

u.update password: 'password', units: 'imperial'
