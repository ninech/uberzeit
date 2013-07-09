module TimeTypesHelper

  ICONS_AVAILABLE = [ 'exchange','bell-alt','beer','coffee','food','user-md','ambulance',
                      'medkit','github-alt','book','briefcase','bullhorn','camera','coffee',
                      'cog','comments','fighter-jet','circle-blank','circle','group','home','legal',
                      'road','truck','wrench','fire','ban-circle','shopping-cart','plane',
                      'globe','leaf','adjust','asterisk']

  NUMBER_OF_COLORS = 12

  def list_available_icons(active = nil)
    content_tag(:ul, class: 'list-of-icons' ) do
      ICONS_AVAILABLE.collect do |icon_name|
        content_tag(:li) do
          css_classes = ["icon","icon-#{icon_name}"]
          css_classes << ["active"] if icon_name == active
          content_tag(:i, '', :'data-icon' => icon_name, class: css_classes)
        end
      end.join.html_safe
    end
  end

  def list_available_colors(active = nil)
    content_tag(:ul, class: 'list-of-colors' ) do
      NUMBER_OF_COLORS.times.to_a.collect do |color_index|
        content_tag(:li) do
          css_classes = ["color","icon-sign-blank","event-color#{color_index}"]
          css_classes << ["active"] if color_index == active
          content_tag(:i, '', :'data-color-index' => color_index, class: css_classes)
        end
      end.join.html_safe
    end
  end

  def display_name_bonus_calculator(calculator)
    UberZeit::BonusCalculators.available_calculators[calculator].name if UberZeit::BonusCalculators.available_calculators[calculator]
  end

end
