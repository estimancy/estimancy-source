class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  begin
    NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
  rescue
    # ignored
  end
end