require "padrino"
require "padrino-helpers"
require "ostruct"
require "rack/test"
require "bootstrap_forms"
require File.dirname(__FILE__) + "/app/app"

support = File.join(File.dirname(__FILE__), "support", "*.rb")
Dir[support].each { |path| require path }

RSpec.configure do |config|
  config.include Padrino::Helpers::OutputHelpers
  config.include Padrino::Helpers::FormatHelpers
  config.include Padrino::Helpers::TagHelpers
  config.include Padrino::Helpers::FormHelpers
  config.include Rack::Test::Methods

  config.include Module.new {
    VALIDATION_STATES = [:error, :success, :warning, :info]

    def app
      Padrino.application
    end

    def req(format, view, q = {})
      get "/#{format}/#{view}", q
      body = last_response.body
      # Only clean what looks like HTML. Makes any errors eaiser to trackdown.
      body =~ /\A\s*<\w/ ? clean(body) : body
    end

    def clean(str)
      str.gsub(/\s{2,}|\n/, "")
    end

    def control_group(klasses = nil)
      klasses = Array(klasses)
      klasses.unshift "control-group"
      content_tag(:div, :class => klasses.join(" ")) { yield }
    end
    
    def controls
      content_tag(:div, :class => "controls") { yield }
    end
    
    def build_control_group(name, field, options = {})
      message = options.keys.find { |k| VALIDATION_STATES.include?(k) }
      group_css = %w[control-group]
      group_css << message.to_s if message
      label_for = nil
      
      if Hash === field
        type  = field.delete(:type) || "text"
        fname = field.delete(:name) || "item[#{name}]"
        field[:id] ||= name
        label_for = field[:id]
        field = send("#{type}_field_tag", fname, field)
      elsif field =~ /id=["']([-\w]+)["']/
        label_for = $1
      end

      expected = control_group(message) do
        label_tag(name.to_s.titleize, :class => "control-label", :for => label_for) << controls do
          css   = []
          nodes = []

          if options[:prepend]
            css << "input-prepend"
            nodes << content_tag(:span, options[:prepend], :class => "add-on")
          end
          
          nodes << field

          if options[:append]
            css << "input-append"
            nodes << content_tag(:span, options[:append], :class => "add-on")
          end

          if options[:help_inline] 
            nodes << content_tag(:span, options[:help_inline], :class => "help-inline") 
          end

          if message
            nodes << content_tag(:span, options[message], :class => "help-inline") 
          end

          if options[:help_block]
            nodes << content_tag(:span, options[:help_block], :class => "help-block") 
          end

          html = nodes.join("")
          css.any? ? content_tag(:div, html, :class => css.join(" ")) : html
        end
      end

      clean(expected)
    end
  }
end

class Item < OpenStruct
  def errors
    @errors ||= Errors.new
  end
end

class Errors < Hash
  def initialize
    super { |h, v| h[v] = [] }
  end

  def each
    super do |k, v|
      v.each { |e| yield(k, e) }
    end
  end
end
