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
    return unless customer_link_enabled?
    customer_url = UberZeit.config.customer_url
    customer = Customer.where(id: customer_id).last
    return if customer.nil?
    link_to(customer, (customer_url % customer.number))
  end

  def customer_link_enabled?
    UberZeit.config.customer_url.present?
  end

  def redmine_enabled?
    UberZeit.config.ubertrack_hosts.present? && UberZeit.config.ubertrack_hosts[:redmine].present?
  end

  def otrs_enabled?
    UberZeit.config.ubertrack_hosts.present? && UberZeit.config.ubertrack_hosts[:otrs].present?
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
