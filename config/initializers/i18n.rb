# return humanized text for missing values so it doesn't fuck up the whole html.
# can be removed as soon as all translations are in place.
module I18n
  class MissingTranslation
    def html_message
      keys.last.to_s.gsub('_', ' ').gsub(/\b('?[a-z])/) { $1.capitalize }
    end
  end
end
