module ActivitiesHelper
  def formatted_worktime_for_day(day)
    format_duration @user.activities.where(date: day).sum(:duration)
  end

  def activity_source_information(activity)
    [:otrs, :redmine].each do |source|
      ticket_id = activity.send("#{source}_ticket_id")
      if ticket_id
        url = link_to("##{ticket_id}", ticket_url(source, ticket_id))
        return t(".#{source}", { ticket_id: ticket_id, ticket_url: url }).html_safe
      end
    end
  end

  def customer_link(customer_id)
    stats_url = UberZeit::Config[:ubertrack_hosts]["stats"]
    customer = Customer.find(customer_id)
    link_to(customer.name, "#{stats_url}/admin/customerdetail.php?id=#{customer_id}")
  end

  private
  def ticket_url(ticketing_system, ticket_id)
    base_url = UberZeit::Config[:ubertrack_hosts]["#{ticketing_system}"]
    case(ticketing_system)
    when :redmine
      return "#{base_url}/issues/#{ticket_id}"
    when :otrs
      return "#{base_url}/otrs/index.pl?Action=AgentTicketZoom&TicketNumber=#{ticket_id}"
    end
  end
end
