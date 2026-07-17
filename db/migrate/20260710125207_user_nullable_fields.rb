class UserNullableFields < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :admin, from: nil, to: false
    change_column_default :users, :instructor, from: nil, to: false
    change_column_default :users, :researcher, from: nil, to: false

    User.where( admin: nil ).update_all( admin: false )
    User.where( instructor: nil ).update_all( instructor: false )
    User.where( researcher: nil ).update_all( researcher: false )

    change_column_null :users, :admin, false
    change_column_null :users, :instructor, false
    change_column_null :users, :researcher, false

  end
end
