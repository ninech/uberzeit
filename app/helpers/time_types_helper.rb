module TimeTypesHelper

  def list_available_icons(active = nil)
    icons_available = [ 'exchange','bell-alt','beer','coffee','food','user-md','ambulance',
                        'medkit','github-alt','book','briefcase','bullhorn','camera','coffee',
                        'cog','comments','fighter-jet','circle-blank','circle','group','home','legal',
                        'road','truck','wrench','fire','ban-circle','shopping-cart','plane',
                        'globe','leaf','adjust','asterisk']

    content_tag(:ul, class: 'list-of-icons' ) do
      icons_available.collect do |icon_name|
        content_tag(:li) do
          css_classes = ["icon icon-#{icon_name}"]
          css_classes << ["active"] if icon_name == active
          content_tag(:i, '', :'data-icon' => icon_name, class: css_classes.join(' '))
        end
      end.join.html_safe
    end
  end
end
