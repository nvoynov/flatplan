require_relative 'base'

# lib/flatplan/model/series_publication.rb

module Flatplan
  module Model
    class SeriesPublication < Base
      attr_accessor :title, :author, :date, :location, :keywords, :description, :sections

      # Ensure all attributes are explicit constructor keyword arguments
      def initialize(
        title:, 
        author: nil, 
        date: nil, 
        location: nil, 
        keywords: [], 
        description: nil,
        sections: [] # Позволяем передавать секции явно для работы метода #with!
      )
        super()
        @title = title
        @author = author
        @date = date
        @location = location
        @keywords = keywords
        @description = description
        @sections = sections # Честно присваиваем переданное значение
      end

      def add_section(section)
        @sections << section
      end
    end
  end
end
