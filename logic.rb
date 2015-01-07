require 'readability'
require 'open-uri'

class Logic
  def initialize
    @content = process('http://en.wikipedia.org/wiki/Transhumanism')
  end

  def process(url='http://en.wikipedia.org/wiki/Special:Random')
    resp = open(url)
    url = resp.base_uri.to_s
    source = resp.read
    content = Readability::Document.new(source,  :tags => %w[]).content
    title = Nokogiri::HTML(source).css('h1')[0].text
    length = content.length
    ratio = nil
    if @content
      ratio = length.to_f / @content['length']
    end

    {
      'url' => url,
      'length' => length,
      'title' => title,
      'ratio' => ratio,
    }
  end

  def seek 
    target = nil
    until target and target['length'] < @content['length']
      target = process
    end


    return target
  end

  def generate(target=nil)
    if target == nil
      target = seek
    else
      target = process target
    end

    text = ""
    url = target["url"]
    title = target["title"]
    ratio = target["ratio"]

    strings = [
      "The Wikipedia page for \"#{title}\" is shorter than the article on Transhumanism",
      "\"#{title}\" is shorter than the Wikipedia for Transhumanism ",
      "shorter then Transhumanism: #{title}",
      "The wiki for \"#{title}\" is shorter than that of Transhumanism",
      "The wiki for transhumanism is #{(1/ratio).round 2} times longer than that of #{title}",
    ]
    if ratio >= 0.01
      strings.concat [
        "On Wikipedia, \"#{title}\" is #{(ratio*100).round 2}% the length of \"Transhumanism\"",
        "Wiki for\" #{title}\" is #{ratio.round 2}x the length of \"Transhumanism\"",
      ]
    end

    until text != "" and text.length <= 125
      text = strings.sample
    end
    return "#{text} #{url}"
  end
end