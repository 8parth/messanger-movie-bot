require 'mechanize'
require 'pry'
class Shows
  attr_reader :shows, :agent

  def self.shows
    @shows ||= get_shows
  end

  def self.get_shows
    page = agent.get('http://showrss.info/browse')
    form = page.forms.first
    select_field = form.field_with(id: 'showselector')
    opts = select_field.options.map do |option|
      {
          text: option.text,
          url: "http://showrss.info/show/#{option.value}.rss"
      }
    end

    Hash[opts.map { |h| h.values_at(:text, :url) }]
  end

  def self.search_from_shows(term)
    shows.keys.each do |key|
      if key.downcase.include?(term.downcase)
        return shows[key]
      else
        nil
      end
    end
  end

  def self.agent
    @agent ||= Mechanize.new
  end
end
