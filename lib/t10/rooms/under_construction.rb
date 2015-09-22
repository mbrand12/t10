module T10
  module Rooms
    # Placeholder methods used for unfinished rooms.
    module UnderConstruction

      # Places the {Items::ShinyItem} in the Hero's {Satchel} upon first visit.
      # See {Room#enter} for more details.
      # @return [Array<String>, String] a description.
      def enter(nouns, modifiers)
        super
        if @visited
          Book.unfinished_room[:enter_visited]
        else
          @room_items << Items::ShinyItem
          @visited = true
          [ Book.unfinished_room[:enter],
                 interact([:put], [:satchel, :shiny], [])]
        end
      end

      # Puts a navigational reminder for the player when Hero obtains the shiny.
      # See {Room#item_obtained} for details.
      # @return [String] a description.
      def item_obtained(item_class)
        Book.unfinished_room[:item_obtained]
      end
    end
  end
end
