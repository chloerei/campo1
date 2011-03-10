xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title page_title
    xml.link @channel_link
    xml.lastBuildDate @topics.first.created_at.to_s(:rfc822) if @topics.any?

    for topic in @topics
      xml.item do
        xml.title topic.title
        xml.description rich_content(topic.content)
        xml.pubDate topic.created_at.to_s(:rfc822)
        xml.author @user_hash[topic.user_id].profile.name
        xml.link topic_url_with_last_anchor(topic)
        xml.guid topic_url(topic)
        topic.tags.each do |tag|
          xml.category tag
        end
      end
    end
  end
end
