require 'rails_helper'

describe LayoutPosition do
  let(:layout_position) { build_stubbed :layout_position }

  it 'is valid' do
    expect(layout_position).to be_valid
  end

  it 'is not valid without layout' do
    layout_position.label = nil
    expect(layout_position).not_to be_valid
  end
end
