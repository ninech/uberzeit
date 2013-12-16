module ActivitiesHelper
  def activity_source_information(activity)
    source_links = [:otrs, :redmine].collect do |source|
      ticket_id = activity.send("#{source}_ticket_id")
      if ticket_id
        url = link_to("##{ticket_id}", ticket_url(source, ticket_id))
        t(".#{source}", { ticket_id: ticket_id, ticket_url: url }).html_safe
      else
        nil
      end
    end.compact
    source_links.to_sentence.html_safe
  end

  def customer_link(customer_id)
    stats_url = UberZeit.config.ubertrack_hosts[:stats]
    customer = Customer.where(id: customer_id).last || customer_id
    link_to(customer, "#{stats_url}/admin/customerdetail.php?id=#{customer_id}")
  end

  private
  def ticket_url(ticketing_system, ticket_id)
    base_url = UberZeit.config.ubertrack_hosts[:"#{ticketing_system}"]
    case(ticketing_system)
    when :redmine
      return "#{base_url}/issues/#{ticket_id}"
    when :otrs
      return "#{base_url}/otrs/index.pl?Action=AgentTicketZoom&TicketNumber=#{ticket_id}"
    end
  end
end
