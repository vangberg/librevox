require "freeswitcher/database"
module FreeSwitcher
  module Database
    module CallLimit
      DB = Sequel.connect("sqlite:///" + File.join(FreeSwitcher::FS_DB_PATH, "call_limit.db"))
      class LimitData < Sequel::Model
        def self.table_name
          :limit_data
        end
      end
      LimitData.set_dataset :limit_data

      class DbData < Sequel::Model
        def self.table_name
          :db_data
        end
      end
      DbData.set_dataset :db_data

      class GroupData < Sequel::Model
        def self.table_name
          :group_data
        end
      end
      GroupData.set_dataset :group_data

      LimitData.db, DbData.db, GroupData.db = [DB] * 3
    end
  end
end
