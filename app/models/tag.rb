class Tag < ApplicationRecord
  alias_attribute :disabled_lectures, :lectures
  has_many :course_contents
  has_many :courses, through: :course_contents
  has_many :disabled_contents
  has_many :lectures, through: :disabled_contents
  has_many :lesson_contents
  has_many :lessons, through: :lesson_contents
  has_many :asset_tags
  has_many :learning_assets, through: :asset_tags
  has_many :relations, dependent: :destroy
  has_many :related_tags, through: :relations, dependent: :destroy

  def neighbours
    related_ids = Relation.where(tag_id: id).map(&:related_tag_id)
    inverse_ids = Relation.where(related_tag_id: id).map(&:tag_id)
    Tag.where(id: related_ids).or(Tag.where(id: inverse_ids))
  end
end
