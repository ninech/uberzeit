class SubnavRenderer < SimpleNavigation::Renderer::Base

  def render(item_container)
    dl_content = item_container.items.inject([]) do |list, item|
      dd_options = item.html_options
      dd_content = tag_for(item)
      list << content_tag(:dd, dd_content, dd_options)
    end.join
    content_tag :dl, dl_content, id: item_container.dom_id, class: item_container.dom_class
  end

end
