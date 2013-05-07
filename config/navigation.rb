# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  navigation.selected_class = :active

  # Define the primary navigation
  navigation.items do |primary|

    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.  You may also use a proc, or the symbol <tt>:subpath</tt>.
    #
    primary.item :timesheet, t('navigation.timesheet'), time_sheet_path(current_user.current_time_sheet)
    primary.item :absences, t('navigation.absences'), time_sheet_absences_path(current_user.current_time_sheet)
    primary.item :reports, t('navigation.reports'), user_summaries_work_month_path(current_user, Date.current.year, Date.current.month), highlights_on: %r$\A/users/summaries$ do |second|
      second.item :my_work, t('navigation.sub.reports.my_work'), user_summaries_work_month_path(current_user, Date.current.year, Date.current.month)
      second.item :my_absence, t('navigation.sub.reports.my_absence'), user_summaries_absence_year_path(current_user, Date.current.year)
      second.item :work, t('navigation.sub.reports.work'), month_summaries_work_users_path(Date.current.year, Date.current.month), highlights_on: %r$\A/users/summaries/work$
      second.item :absences, t('navigation.sub.reports.absences'), calendar_summaries_absence_users_path(Date.current.year, Date.current.month), highlights_on: %r$\A/users/summaries/absence$
      second.item :vacation, t('navigation.sub.reports.vacation'), year_summaries_vacation_users_path(Date.current.year), highlights_on: %r$\A/users/summaries/vacation$
      second.dom_class = 'sub-nav'
    end
    primary.item :manage, t('navigation.manage'), public_holidays_path, if: -> { show_manage_link_in_navigation? } do |second|
      second.item :public_holidays, t('navigation.sub.manage.public_holidays'), public_holidays_path
      second.item :users, t('navigation.sub.manage.users'), users_path
      second.item :time_types, t('navigation.sub.manage.time_types'), time_types_path
      second.dom_class = 'sub-nav'
    end

  end

end
