def initialize_layout_positions
  positions = %w[top-left top-center top-right left-center center rigth-center bottom-left bottom-center bottom-right fullscreen]
  positions.each do |position|
    create :layout_position, label: position
  end
end
