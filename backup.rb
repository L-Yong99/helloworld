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



<div class="day-activities-container">
  <h4 class="activity-day-date"><strong><%= @date_day.strftime("%A, %B %d") %></strong></h4>
  <% @activities_done.each_with_index do |activity,i| %>
    <div class="activity-day" >
      <div class="activity-col">
        <div class="marker-container">
          <img class="activity-marker" src="/assets/greenmarker-day.png" alt="">
          <div><%= i+1 %></div>
        </div>
        <div>
          <h6><%= i+1 %>. <%= activity.place.name %></h6>
        </div>
        <div class="review-details">
          <img src="" alt="">
          <p class="activity-decription"><%= activity.place.description %></p>
          <% 3.times do |a| %>
            <i class="fa-solid fa-star"></i>
          <% end %>
          <% 2.times do |a| %>
            <i class="fa-regular fa-star"></i>
          <% end %>
        </div>
      </div>
    </div>
  <% end %>
</div>

<%# <div class="center-line">
<%# <a href="#" class="scroll-icon"></a> %>
<%#  </div> %>
