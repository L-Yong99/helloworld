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






<% @dates.each_with_index do |date,i| %>
  <h3 class="summary-day-date">Day <%= i+1 %>: <%= date.strftime("%A, %B %d") %></h3>
  <% @activities_day = @activities.where(date: date)%>
  <% @activities_day.each_with_index do |activity,j| %>
    <% if activity.status == "updated"%>
      <% reviews = activity.reviews.where(user: current_user) %>
      <div class="activity_container">
        <div class="daily_activity">
          <div class="place_thumbnail">
            <% if reviews.count == 0 %>
              <img src="https://www.newshub.co.nz/home/lifestyle/2019/01/tips-for-safe-and-exciting-new-zealand-camping-over-the-summer-break/_jcr_content/par/image.dynimg.full.q75.jpg/v1546993217423/Freedom_Camping_1200.jpg" alt="thumbnail">
            <% else %>
              <%= cl_image_tag reviews[0].photo.key, class:"review-image"%>
            <% end %>
          </div>
          <div class="place_summary">
            <div class="place-summary-title d-flex .justify-content-between">
              <h4 class="activity-place"><%= activity.place.name %></h4>
              <h4 class="activity-date"><%= activity.date.strftime("%b %d")  %></h4>
            </div>
            <% reviews.each do |review| %>
              <h6><%= review.comment %></h6>
              <h6>by <%= review.user.first_name %></h6>
            <% end %>
          </div>
        </div>
      </div>
      <% end %>
  <% end %>
<% end %>


<select name="date" class="summary-date">
<option value="">--All Days--</option>
<%= @dates.each_with_index do |date,i| %>
  <option class="day" data-date="<%= date %>" value="<%= i + 1 %>" >Day <%=i + 1%> (<%= date%>)</option>
<% end %>
</select>


<% @todolist.each do |todo| %>
  <li class="prepare-checklist-checkbox">
  <% if todo.status == 'pending' %>
   <input value=<%= activity.id %> class="prepare-checkbox-input" type="checkbox" id="check1"/>
  <% else %>
   <input value=<%= activity.id %> checked class="prepare-checkbox-input" type="checkbox" id="check1"/>
  <% end %>
    <label class="prepare-checkbox-input"for="check1">
      <h6><%= todo.content %></h6>
    </label>
  </li>
<% end %>


<div class="background_index" style="background-image:url('https://pbs.twimg.com/media/FgR3lN1XoAE7HhY?format=jpg&name=4096x4096')">
  <div class="backdrop_cover">
    <div class="index_container-dashbox-page">
      <div class="index_completed_container">
        <h1 class="index_h1">All Itineraries</h1>
        <div class="container">
          <div class="gallery-grid">
            <% @reviews.each do |review| %>
              <%= cl_image_tag review.photo.key, class:"gallery-image"%>
            <% end %>
          </div>
        </div>
        <%# <form action="">
          <button class="testha" type="submit"> complete </button>
        </form> %>
      </div>
    </div>
  </div>
</div>


<% if reviews.count == 0 %>
<img src="https://www.newshub.co.nz/home/lifestyle/2019/01/tips-for-safe-and-exciting-new-zealand-camping-over-the-summer-break/_jcr_content/par/image.dynimg.full.q75.jpg/v1546993217423/Freedom_Camping_1200.jpg" alt="thumbnail">
<% else %>
<% if reviews[0].photo.key.nil? %>
  <img src="https://www.newshub.co.nz/home/lifestyle/2019/01/tips-for-safe-and-exciting-new-zealand-camping-over-the-summer-break/_jcr_content/par/image.dynimg.full.q75.jpg/v1546993217423/Freedom_Camping_1200.jpg" alt="thumbnail">
<% else %>
  <%= cl_image_tag reviews[0].photo.key, class:"review-image"
<% end %>
<% end %>
