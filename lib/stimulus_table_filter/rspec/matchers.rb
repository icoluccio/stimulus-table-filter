# frozen_string_literal: true

require 'nokogiri'

RSpec::Matchers.define :have_data do |name, value|
  chain :on, :tag

  match do |html|
    values = data_values(html, name)
    value.nil? ? values.any? : values.include?(value.to_s)
  end

  description { value.nil? ? "have a data-#{name} attribute" : "have data-#{name}=\"#{value}\"" }

  failure_message do |html|
    found = data_values(html, name)
    if found.empty?
      "expected HTML to contain a data-#{name} attribute, but no element has one\n\nHTML:\n#{html}"
    else
      "expected HTML to contain data-#{name}=\"#{value}\", found: #{found.uniq.inspect}\n\nHTML:\n#{html}"
    end
  end

  def data_values(html, name)
    Nokogiri::HTML.fragment(html.to_s).css(tag || '*').filter_map { |el| el["data-#{name}"] }
  end
end

RSpec::Matchers.define :have_data_target do |target|
  match do |html|
    Nokogiri::HTML.fragment(html.to_s).css('*').any? do |el|
      el['data-table-filter-target']&.split&.include?(target.to_s)
    end
  end

  description { "have an element with data-table-filter-target=\"#{target}\"" }

  failure_message do |html|
    present = Nokogiri::HTML.fragment(html.to_s).css('[data-table-filter-target]')
                            .filter_map { |el| el['data-table-filter-target'] }.uniq
    "expected HTML to contain data-table-filter-target=\"#{target}\", targets present: #{present.inspect}"
  end
end
