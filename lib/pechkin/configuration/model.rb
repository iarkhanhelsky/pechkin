module Pechkin
  Bot = Struct.new(:token, :connector, :name, keyword_init: true)
  Channel = Struct.new(:chat_ids, :connector, :messages, keyword_init: true)
end
