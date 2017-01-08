class AddRoleIdToUser < ActiveRecord::Migration
  def up
    add_column :users, :role_id, :integer
    execute 'update users u set role_id = (select role_id from roles_users ru where ru.user_id = u.id limit 1)'
  end

  def down
    remove_column :users, :role_id
  end
end
