module Dated
  extend ActiveSupport::Concern

  module ClassMethods
    def scope_date(date_field_name)
      [:add_date_between_scope, :add_date_not_between_scope, :add_year_month_scope, :add_year_scope].each do |method|
        send(method, date_field_name)
      end
    end

    private
    def add_date_between_scope(date_field_name)
      class_eval do
        scope :"with_#{date_field_name}_between", ->(date_range) do
          if date_range.respond_to?(:min)
            where("#{date_field_name} BETWEEN ? AND ?", date_range.min, date_range.max)
          else
            where(date_field_name => date_range)
          end
        end
      end
    end

    def add_date_not_between_scope(date_field_name)
      class_eval do
        scope :"with_#{date_field_name}_not_between", ->(date_range) do
          if date_range.respond_to?(:min)
            where("NOT (#{date_field_name} BETWEEN ? AND ?)", date_range.min, date_range.max)
          else
            where("#{date_field_name} != ?", date_range)
          end
        end
      end
    end

    def add_year_month_scope(date_field_name)
      class_eval do
        scope :"with_#{date_field_name}_in_year_and_month", ->(year, month) do
          send(:"with_#{date_field_name}_between", UberZeit.month_as_range(year, month))
        end
      end
    end

    def add_year_scope(date_field_name)
      class_eval do
        scope :"with_#{date_field_name}_in_year", ->(year) do
          send(:"with_#{date_field_name}_between", UberZeit.year_as_range(year))
        end
      end
    end
  end
end
