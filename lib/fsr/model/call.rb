module FSR
  module Model
    class Call
      attr_reader :created, :created_epoch, :function, :caller_id_name, :caller_id_number,
                  :caller_destination, :caller_channel_name, :caller_uuid, :callee_id_name,
                  :callee_id_number, :callee_destination, :callee_channel_name, :callee_uuid
      def initialize(created,
                     created_epoch,
                     function,
                     caller_cid_name,
                     caller_cid_num,
                     caller_dest_num,
                     caller_chan_name,
                     caller_uuid,
                     callee_cid_name,
                     callee_cid_num,
                     callee_dest_num,
                     callee_chan_name,
                     callee_uuid)
        @created,
        @created_epoch,
        @function,
        @caller_id_name,
        @caller_id_number,
        @caller_destination,
        @caller_chan_name,
        @caller_uuid,
        @callee_id_name,
        @callee_id_number,
        @callee_destination,
        @callee_channel_name,
        @callee_uuid = created, 
                       created_epoch,
                       function,
                       caller_cid_name,
                       caller_cid_num,
                       caller_dest_num,
                       caller_chan_name,
                       caller_uuid,
                       callee_cid_name,
                       callee_cid_num,
                       callee_dest_num,
                       callee_chan_name,
                       callee_uuid
      end
    end
  end
end
