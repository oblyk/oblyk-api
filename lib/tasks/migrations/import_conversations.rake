# frozen_string_literal: true

namespace :import do
  task :conversations, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM conversations').to_a

    # 0 : id
    # 1 : label
    # 2 : created_at
    # 3 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[2]}"

      conversation = Conversation.new(
        legacy_id: data[0],
        created_at: data[2],
        updated_at: data[3]
      )
      binding.pry unless conversation.save
    end

    out.puts 'End'
  end

  task :conversation_users, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM user_conversations').to_a

    # 0 : id
    # 1 : user_id
    # 2 : conversation_id
    # 3 : new_messages
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      conversation = Conversation.find_by legacy_id: data[2]
      user = User.find_by legacy_id: data[1]

      conversation_user = ConversationUser.new(
        legacy_id: data[0],
        conversation: conversation,
        user: user,
        created_at: data[4],
        updated_at: data[5]
      )
      binding.pry unless conversation_user.save
    end

    out.puts 'End'
  end

  task :conversation_messages, %i[database out] => :environment do |_t, args|
    out = args[:out] || $stdout
    database = args[:database].to_sym

    ## cache data
    import_db = ActiveRecord::Base.establish_connection(:import_db).connection
    all_old_data = import_db.execute('SELECT * FROM messages').to_a

    # 0 : id
    # 1 : user_id
    # 2 : conversation_id
    # 3 : message
    # 4 : created_at
    # 5 : updated_at

    # Connect to database
    ActiveRecord::Base.establish_connection(database)

    # Import data
    all_old_data.each do |data|
      out.puts "import #{data[0]} : #{data[1]}"

      conversation = Conversation.find_by legacy_id: data[2]
      user = User.find_by legacy_id: data[1]

      next if conversation.conversation_users.empty?
      next if data[3].blank?

      conversation_message = ConversationMessage.new(
        legacy_id: data[0],
        body: data[3],
        conversation: conversation,
        user: user,
        posted_at: data[4],
        created_at: data[4],
        updated_at: data[5]
      )

      binding.pry unless conversation_message.save
    end

    out.puts 'End'
  end
end
