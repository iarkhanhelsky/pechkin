module Pechkin
  Channel = Struct.new(:chat_ids, :connector, :messages, keyword_init: true)
end
