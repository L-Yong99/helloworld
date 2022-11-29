import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="mapday"
export default class extends Controller {
  static values = {
    apiKey: String,
    center: Array,
    geojson: String,
    activities: String,
  };

  connect() {
    console.log("map2");
    this.placesGeoJson = JSON.parse(this.geojsonValue);
    this.activities = JSON.parse(this.activitiesValue);
    console.log(this.placesGeoJson);
    console.log(this.activities);
    mapboxgl.accessToken = this.apiKeyValue;

    // console.log(this.placesGeoJson);
    // console.log(this.activitiesIdValue);
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
    });

    this.map.on("load", () => {
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669643871/Hello%20World/Map_Marker_8_2_aouhqs.png",
        "default_icon"
      );
      // Add Food Source and Layer
      this.#addSource("places", this.placesGeoJson);
      this.map.addLayer({
        id: "places",
        type: "symbol",
        source: "places",
        layout: {
          "icon-image": ["get", "defaultIcon"], // reference the image
          "icon-size": 0.3,
        },
      });
      this.#createPopEvent();
      this.#clickEvent("places");
    });

    this.#addMarkerToMap();
    this.#fitMapToMarker();

    this.userMarkers = [];
    this.#loadUserMarkers();

    this.#sidebar();
    this.#closeModal();
    this.#addDirection()
  }

  // ================== Functions ===========================

  #addDirection() {
    const directionEl = document.querySelector(".direction");
    directionEl.addEventListener("click", (e) => {
      directionEl.classList.toggle("active");
      if (directionEl.classList.contains("active")) {
        if (this.map._popups != 0) {
          this.map._popups[0].remove();
        }

        this.md = new MapboxDirections({
          accessToken: mapboxgl.accessToken,
        });
        this.map.addControl(this.md, "top-right");

        this.map.on("click", "places", (e) => {
          const directionEl = document.querySelector(".direction");
          console.log(directionEl.classList.contains("active"));
          if (directionEl.classList.contains("active")) {
            console.log(this.map._popups);
            if (this.map._popups != 0) {
              this.map._popups[0].remove();
            }
          }
        });
      } else {
        this.map.removeControl(this.md);
      }
    });
  }

  #closeModal() {
    const closeModalButtonEL = document.querySelector(".modal-close-botton");
    closeModalButtonEL.addEventListener("click", (e) => {
      document.querySelector(".modal-overlay").classList.remove("active");
      if (this.map._popups != 0) {
        this.map._popups[0].remove();
      }
    });
  }

  #addImage(image_url, image_name) {
    this.map.loadImage(image_url, (error, image) => {
      if (error) throw error;
      // add image to the active style and make it SDF-enabled
      this.map.addImage(image_name, image);
    });
  }

  #createPopEvent() {
    this.popup = new mapboxgl.Popup({
      closeButton: true,
      closeOnClick: true,
    });
  }

  #clickEvent(layerId) {
    this.map.on("click", layerId, (e) => {
      e.preventDefault();
      console.log("hello");
      this.map.getCanvas().style.cursor = "pointer";
      // console.log(source, e.features);
      // Copy coordinates array.
      const coordinates = e.features[0].geometry.coordinates.slice();
      const description = e.features[0].properties.description;
      const infoWIndow = e.features[0].properties.info_window;
      const placeId = e.features[0].properties.place_id;

      this.place = e.features[0];
      // console.log("placeID",e.features[0])

      const popupNode = document.createElement("div");
      popupNode.insertAdjacentHTML("beforeend", infoWIndow);
      // console.log("popupNode",popupNode)

      this.popup
        .setLngLat(coordinates)
        .setDOMContent(popupNode)
        .addTo(this.map);

      const addReviewEl = document.querySelector(".add-review");
      // console.log(addReviewEl);
      // console.log(this.aa)`
      addReviewEl.addEventListener("click", (e) => {
        // Populate
        console.log(this.place);
        document.querySelector(".place-content img").src =
          this.place.properties.image;
        document.querySelector(".place-content h4").innerText =
          this.place.properties.name;
        document.querySelector(".place-content p").innerText =
          this.place.properties.description;

        document.querySelector(".modal-overlay").classList.add("active");
        document
          .querySelector(".photo-container-main")
          .addEventListener("click", () => {
            document.querySelector(".photo").click();
          });

        document.querySelector(".review-form-hidden").value =
          this.place.properties.activityId;
      });
    });
  }

  #addSource(source, geoJson) {
    this.map.addSource(source, {
      type: "geojson",
      data: geoJson,
      generateId: true,
    });
  }
  #sidebar() {
    const ddLabel = document.querySelector(".dropdown-label");
    ddLabel.addEventListener("click", (e) => {
      document.querySelector(".dates-dropdown").classList.toggle("d-none");
    });

    const closeEl = document.querySelector(".dates-sidebar .close");
    closeEl.addEventListener("click", (e) => {
      document.querySelector(".dates-sidebar").classList.remove("active");
    });

    const openEl = document.querySelector(".toggle-sidebar");
    openEl.addEventListener("click", (e) => {
      document.querySelector(".dates-sidebar").classList.add("active");
    });
  }

  #addMarkerToMap() {
    new mapboxgl.Marker()
      .setLngLat([+this.centerValue[1], +this.centerValue[0]])
      .addTo(this.map);
  }

  #fitMapToMarker() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend([+this.centerValue[1], +this.centerValue[0]]);
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 12, duration: 800 });
  }

  #loadUserMarkers() {
    this.activities.forEach((activity) => {
      // console.log(feature.geometry.coordinates);
      const coordinates = activity.coordinates;
      const activityId = activity.id;
      const placeId = activity.place_id;
      const event_sequence = activity.event_sequence;
      const infoWIndow = activity.info_window;
      const status = activity.status;

      const popupNode = document.createElement("div");
      popupNode.insertAdjacentHTML("beforeend", infoWIndow);

      this.#createUserMarker(
        coordinates,
        activityId,
        placeId,
        event_sequence,
        infoWIndow,
        status
      );
      // console.log(this.userMarkers);
    });
  }

  #createUserMarker(
    coordinates,
    activityId,
    placeId,
    event_sequence,
    infoWIndow,
    status
  ) {
    // Create POP up
    // const popup = new mapboxgl.Popup();
    // const popupNode = document.createElement("div");
    // popupNode.insertAdjacentHTML("beforeend", infoWIndow);
    // popup.setLngLat(coordinates).setDOMContent(popupNode).addTo(this.map);

    const el = document.createElement("div");
    if (status === "updated") {
      el.className = "marker-green";
    } else {
      el.className = "marker-red";
    }
    el.innerHTML = `<div class="marker-number">${event_sequence}</div>`;

    // make a marker for each feature and add it to the map
    const marker = new mapboxgl.Marker(el)
      .setLngLat(coordinates)
      // .setPopup(popup)
      .addTo(this.map);

    // console.log("marker id", id);
    this.userMarkers.push({
      id: event_sequence,
      marker: marker,
    });
  }
}
