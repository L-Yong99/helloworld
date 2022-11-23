import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    center: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue
    console.log(this.centerValue)
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12"
    })


    this.map.on('load', () => {
      this.map.addSource('earthquakes', {
        type: 'geojson',

        // Use a URL for the value for the `data` property.
        data: 'https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson'
      });

      this.map.addLayer({
        'id': 'earthquakes-layer',
        'type': 'circle',
        'source': 'earthquakes',
        'paint': {
          'circle-radius': 4,
          'circle-stroke-width': 2,
          'circle-color': 'red',
          'circle-stroke-color': 'white'
        }
      });
    });
    this.#addMarkersToMap()
    this.#fitMapToMarkers()
  }

  // #addMarkersToMap() {
  //   this.markersValue.forEach((marker) => {
  //     new mapboxgl.Marker()
  //       .setLngLat(this.centerValue)
  //       .addTo(this.map)
  //   })
  // }

  #addMarkerToMap() {
    new mapboxgl.Marker()
      .setLngLat([+this.centerValue[1],+this.centerValue[0]])
      .addTo(this.map)
  }

  // #fitMapToMarkers() {
  //   const bounds = new mapboxgl.LngLatBounds()
  //   this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
  //   this.map.fitBounds(bounds, { padding: 70, maxZoom: 12, duration: 800 })
  // }

  #fitMapToMarker() {
    const bounds = new mapboxgl.LngLatBounds()
    bounds.extend([+this.centerValue[1],+this.centerValue[0]])
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 10, duration: 800 })
  }
}
