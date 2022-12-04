import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="showmap"
export default class extends Controller {
  static values = {
    apiKey: String,
    center: String,
    activities: String,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    this.center = JSON.parse(this.centerValue);
    this.activities = JSON.parse(this.activitiesValue);
    console.log("Center",this.center);
    console.log("Activities",this.activities);
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
    });

    this.#addMarkerToMap();
    this.#fitMapToMarker();
    this.#addUserMarkersToMap();

  }

  #addUserMarkersToMap(){
    let index = 1;
    this.activities.forEach((activity) =>{
      const el = document.createElement("div");
      el.className = "marker-red";
      el.innerHTML = `<div class="marker-number">${index}</div>`;

      // make a marker for each feature and add it to the map
      const marker = new mapboxgl.Marker(el)
        .setLngLat([activity.lng,activity.lat])
        .addTo(this.map);

        index = index + 1;
    })
  }

  #addMarkerToMap() {
    const popup = new mapboxgl.Popup().setHTML(`<div class="text-center"><h3>${this.center.name}</h3></div>`)
    console.log(popup)
    console.log("why")
    new mapboxgl.Marker()
      .setLngLat([+this.center.coord[1], +this.center.coord[0]])
      .setPopup(popup)
      .addTo(this.map);
  }

  #fitMapToMarker() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend([+this.center.coord[1], +this.center.coord[0]]);
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 11, duration: 800 });
  }
}
