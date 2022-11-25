<div class="main-container">
  <div class="container">
    <h1>Start a New Trip</h1>
    <%= form_with url: '/itineraries', method: :post, data: {controller: "address-autocomplete", address_autocomplete_api_key_value: ENV["MAPBOX_API_KEY"]} do |f| %>
      <%= f.label :address, "Destination" , class:"myform-block"%>
      <%= f.text_field :address, data: { address_autocomplete_target: "address" }, class:"d-none myform-block" %>
      <%= f.label :date, "Select Date", class:"myform-block"%>
      <%= f.text_field :date , class:"myform-block"%>
      <%= f.submit "Start Planning" %>
    <% end %>
  </div>
</div>


<%# <%= form_with url: "/itineraries/#{@itinerary_id}/delete", method: :post, class:"hidden-form-2" do |f| %>
  <%= hidden_field_tag :authenticity_token, form_authenticity_token %>
  <%= hidden_field_tag 'data','none', class:"data-hidden-2"  %>
  <%= f.submit "submit", class:"submit-hidden-2 d-none" %>
<% end %> %>
