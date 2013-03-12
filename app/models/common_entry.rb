module CommonEntry
  extend ActiveSupport::Concern

  # if Rails.env.development? # populate descendants in lazy loading environment
  #   %w(date_entry time_entry).each do |class_name|
  #     require_dependency File.join("app","models","#{class_name}.rb")
  #   end
  # end

  included do
    acts_as_paranoid

    belongs_to :time_sheet
    belongs_to :time_type

    has_one :recurring_schedule, :as => :enterable

    attr_accessible :recurring_schedule, :recurring_schedule_attributes

    attr_accessible :time_sheet_id, :time_type_id, :type
    validates_presence_of :time_sheet, :time_type

    accepts_nested_attributes_for :recurring_schedule, reject_if: :reject_recurring_schedule_condition, allow_destroy: true
    before_save :mark_recurring_schedule_for_removal, if: :delete_recurring_schedule_condition

    scope :work, joins: :time_type, conditions: ['is_work = ?', true]
    scope :vacation, joins: :time_type, conditions: ['is_vacation = ?', true]
  end

  module ClassMethods
    def find_chunks(date_or_range, time_type_scope = nil)
      range = date_or_range.to_range

      scope_to_search_on = scope_for(time_type_scope)

      entries_in_range = scope_to_search_on.between(range)
      chunks_in_range = entries_in_range.to_chunks
      clip_chunks(chunks_in_range, range)
    end

    def scope_for(time_type)
      if time_type
        self.send(time_type)
      else
        self.scoped
      end
    end

    def clip_chunks(chunks, clip_range)
      clipped_chunks = []
      # cnt = 0
      chunks.each do |chunk|
        intersected_range = chunk.range.intersect(clip_range)
        if intersected_range && intersected_range.duration > 0
          clipped_chunks << TimeChunk.new(range: intersected_range, time_type: chunk.time_type, parent: chunk.parent)
        end
      end
      clipped_chunks
    end
  end

  def duration
    range.duration
  end

  def range
    (starts..ends)
  end

  private

  def delete_recurring_schedule_condition
    recurring_schedule && !recurring_schedule.active?
  end

  def reject_recurring_schedule_condition(attributes)
    attributes['id'].nil? && attributes['active'].to_i != 1
  end
end
