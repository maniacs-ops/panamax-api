class LocalImageSearchResultSerializer < ActiveModel::Serializer
  attributes :source, :tags, :description, :is_official, :is_trusted, :star_count

  def source
    object.id
  end

  def description; end

  def is_official; end

  def is_trusted; end

  def star_count; end
end
