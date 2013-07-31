$ ->
  $('#project_customer_id').typeahead
      name: 'customers'
      prefetch: '/api/customers.json'
      valueKey: 'display_name'
      limit: 10
