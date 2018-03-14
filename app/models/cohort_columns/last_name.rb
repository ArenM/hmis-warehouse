module CohortColumns
  class LastName < ReadOnly
    attribute :column, String, lazy: true, default: :last_name
    attribute :title, String, lazy: true, default: 'Last Name'

    def column_editable?
      false
    end

    def renderer
      'html'
    end
    
    def value(cohort_client)
      cohort_client.client.LastName
    end 

    def display_for(user)
      display_read_only(user)
    end

    def display_read_only(user)
      html = content_tag(:span, class: "hidden") do 
        value(cohort_client)
      end
      html += link_to_if(user.can_view_clients?, value(cohort_client), client_path(cohort_client.client), target: '_blank')
      html
    end
  end
end
