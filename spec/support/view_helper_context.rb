# frozen_string_literal: true

require 'uri'
require 'action_view'

RSpec.shared_context 'view helper' do
  subject(:helper) { helper_class.new }

  let(:helper_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::CaptureHelper
      include ActionView::Helpers::OutputSafetyHelper
      include StimulusTableFilter::ViewHelper

      attr_accessor :output_buffer

      def initialize = @output_buffer = ActionView::OutputBuffer.new
    end
  end
end
