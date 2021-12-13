class GoodReactionsController < ApplicationController
  protect_from_forgery
  # reaction 集計してslack通知する
  def tally
    begin
      binding.pry
      client = Slack::Web::Client.new
      messages = client.conversations_history(channel: permitted_params[:channel_id]).messages

      react_messages = messages.filter {|message| message.reactions.present?}
      # {"natsuki"=>
      #   {:target_reactions=>[{:name=>"shochi", :count=>1}],
      #    :total_count=>1,
      #    :user_name=>"natsuki"},
      #  ...
      #  }
      hash = react_messages.each_with_object({}) do |v, hash|
        user = v.user
        unless hash.keys.include?(user)
          user_name = client.users_info(user: user).user.real_name
          hash[user] = {user_name: user_name}
        end

        hash[user][:target_reactions] ||= []
        # TODO reaction名切り出し
        target_reactions = v.reactions.filter{|x| ["shochi"].include?(x[:name]) }.map {|reaction| {name: reaction.name, count: reaction["count"]} }
        hash[user][:target_reactions] << target_reactions if target_reactions.present?
        hash[user][:target_reactions].flatten!
      end

      hash.each do |_, v|
        total_count = v[:target_reactions].reduce(0) { |sum, y| sum + y[:count] }
        v[:total_count] = total_count
      end

      sort_hash = hash.sort_by{|_,v| -v[:total_count]}.to_h

      #TODO テキスト整形
      text = "#{sort_hash.values.first[:user_name]}さんが#{sort_hash.values.first[:total_count]}回のリアクション"

      # client.chat_postMessage(channel: '#テスト', text: "Hello, Slack bot! #{Time.now}")
      # TODO channel名
      client.chat_postMessage(
        channel: permitted_params[:channel_id],
        text: text)
    rescue => e
      raise e
    end

    head :ok
  end

  private

  def permitted_params
    params.permit(:channel_id)
  end
end