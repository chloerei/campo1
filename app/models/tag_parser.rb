module TagParser
  def parse_tags_from_string(string)
    tags = string.downcase.split
    tags.map! {|tag| tag.gsub "/", ""}
    tags.delete_if {|tag| tag.size > 20 or tag.empty? or tag == '.'}
    tags.uniq
  end
end
