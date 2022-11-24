import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    center: Array,
    geojson: String,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    const placesGeoJson = JSON.parse(this.geojsonValue);
    console.log(placesGeoJson);
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
    });

    this.map.on("load", () => {
      // Load all markers for use later
      // Add Blue Marker
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669210659/Hello%20World/bluemarker_wi2m0m.png",
        "default_foods"
      );
      // Add Red Marker
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669210667/Hello%20World/redmarker_wvzqko.png",
        "active_foods"
      );

      // Add Food Source and Layer
      this.#addSource("foods", placesGeoJson);
      this.#addLayer("foods", "default_foods", 0.25);

      //Initilaize pop up and click id
      this.#createPopEvent();

      //Initilaize click id
      let clickedId = null;
      // this.clickedId = null;

      // Initialize hover Event
      this.#hoverEvent("foods", 0.25, 0.35);

      // Initialize remove hover Event
      this.#removeHoverEvent("foods", 0.25);

      // Initialize Click Event
      this.#clickEvent("foods");

      // Initialize Remove Click Event
      this.#clickRemoveEvent("foods", 0.25);

      // Get day element and get day event listener
      // const daysEl = document.querySelector(".date");
      // console.log("days", daysEl);

      // const detailEl = document.querySelector(".detail");
      // console.log("detail", detailEl);
    });

    this.#addMarkerToMap();
    this.#fitMapToMarker();


    // const sideBarEl = document.querySelector(".sidebar")
    // const btnEl = document.querySelector(".activityBtn")
    // console.log(btnEl)

    // btnEl.addEventListener('click',()=>{
    //   sideBarEl.classList.toggle("active");
    // })
    const sideBarEl = document.querySelector(".sidebar")
    const closeBtnEl = document.querySelector(".close")
    console.log(closeBtnEl)

    closeBtnEl.addEventListener('click',()=>{

      sideBarEl.classList.toggle("active");
    })

    // =================== end ===============================//
  }

  #addImage(image_url, image_name) {
    this.map.loadImage(image_url, (error, image) => {
      if (error) throw error;
      // add image to the active style and make it SDF-enabled
      this.map.addImage(image_name, image);
    });
  }

  #addLayer(source, defaultIcon, defaultIconSize) {
    this.map.addLayer({
      id: source,
      type: "symbol",
      source: source, // reference the data source
      layout: {
        "icon-image": ["get", "defaultIcon"], // reference the image
        "icon-size": defaultIconSize,
      },
    });
  }

  #addSource(source, geoJson) {
    this.map.addSource(source, {
      type: "geojson",
      data: geoJson,
      generateId: true,
    });
  }

  #removeHoverEvent(source, defaultSize) {
    // Remove hover
    this.map.on("mouseleave", source, (e) => {
      // console.log("mouseleave");
      // this.thing = false

      if (this.clickedId == null) {
        this.map.setLayoutProperty("foods", "icon-image", [
          "get",
          "defaultIcon",
        ]);
        this.map.setLayoutProperty("foods", "icon-size", defaultSize);
        this.popup.remove();
      }
    });
  }

  #hoverEvent(source, defaultSize, activeSize) {
    this.map.on("mouseenter", source, (e) => {
      // console.log("mouseenter");

      // console.log("in", e);
      // Pop Up
      this.map.getCanvas().style.cursor = "pointer";
      // e.preventDefault();
      this.map.setLayoutProperty(source, "icon-image", [
        "match",
        ["id"], // get the feature id (make sure your data has an id set or use generateIds for GeoJSON sources
        e.features[0].id,
        ["get", "activeIcon"], //image when id is the clicked feature id
        ["get", "defaultIcon"], // default
      ]);

      this.map.setLayoutProperty(source, "icon-size", [
        "match",
        ["id"], // get the feature id (make sure your data has an id set or use generateIds for GeoJSON sources
        e.features[0].id,
        activeSize, //image when id is the clicked feature id
        defaultSize, // default
      ]);

      // // Copy coordinates array.
      const coordinates = e.features[0].geometry.coordinates.slice();
      // const infoWIndow = e.features[0].properties.description;
      const infoWIndow = e.features[0].properties.info_window;

      const popupNode = document.createElement("div");
      popupNode.insertAdjacentHTML("beforeend", infoWIndow);
      console.log("popupNode", popupNode);

      this.popup
        .setLngLat(coordinates)
        .setDOMContent(popupNode)
        .addTo(this.map);

      const dateEl = document.querySelector(".date");
      // console.log("days", daysEl);

      const daysEl = document.querySelectorAll(".days");
      // console.log("days", daysEl);
    });
  }

  #clickRemoveEvent(source, defaultSize) {
    this.map.on("click", (e) => {
      console.log("map", e);
      if (e.defaultPrevented === false) {
        if (this.map._popups != 0) {
          this.map._popups[0].remove();
          this.map.setLayoutProperty(source, "icon-image", [
            "get",
            "defaultIcon",
          ]);
          this.map.setLayoutProperty(source, "icon-size", defaultSize);
        }
      }
    });
  }
// fire event HERE
  #clickEvent(source) {
    this.map.on("click", source, (e) => {
      e.preventDefault();
      console.log(this.clickedId);
      this.map.getCanvas().style.cursor = "pointer";
      console.log(source, e.features);
      if (e.features) {
        this.clickedId = e.features[0].id;
        // console.log(this.clickedId);
        this.map.setLayoutProperty(source, "icon-image", [
          "match",
          ["id"], // get the feature id (make sure your data has an id set or use generateIds for GeoJSON sources
          e.features[0].id,
          ["get", "activeIcon"], //image when id is the clicked feature id
          ["get", "defaultIcon"], // default
        ]);

        // Copy coordinates array.
        const coordinates = e.features[0].geometry.coordinates.slice();
        const description = e.features[0].properties.description;
        const infoWIndow = e.features[0].properties.info_window;

        const popupNode = document.createElement("div");
        popupNode.insertAdjacentHTML("beforeend", infoWIndow);
        // console.log("popupNode",popupNode)

        this.popup
          .setLngLat(coordinates)
          .setDOMContent(popupNode)
          .addTo(this.map);

        const dateEl = document.querySelector(".date");
        console.log("date", dateEl);

        // const daysEl = document.querySelectorAll(".day");
        // console.log("days", daysEl);

        dateEl.addEventListener("change", (e) => {
          const daysEl = document.querySelectorAll(".day");
          const value = e.target.value;
          console.log("day", value);
          const placeId = e.target.dataset.placeid;
          console.log("Place ID", placeId);
          const selectedDate = daysEl[value-1].dataset.date;
          console.log(selectedDate);
        });

        // --------------------------------------------------------
        // MINE
        const sideBarEl = document.querySelector(".sidebar")
        const btnEl = document.querySelector(".detail");
        console.log("detail", btnEl);


        btnEl.addEventListener("click", (e) => {
          sideBarEl.classList.toggle("active");
        });


        // const sideBarEl = document.querySelector(".sidebar")
        // const btnEl = document.querySelector(".activityBtn")
        // console.log(btnEl)

        // btnEl.addEventListener('click',()=>{
        //   sideBarEl.classList.toggle("active");
        // })

        // Query detail button
        // add event to detail element (detailEl)
        // e.target.dataset.placeid (should get place id)
        // placeJSON -> search for place id -> get data to populate side

        // // Run pop up
        // this.popup.setLngLat(coordinates).setHTML(infoWIndow).addTo(this.map);
        // --------------------------------------------------------
        this.map.flyTo({
          center: coordinates,
        });
      }
    });
  }

  #createPopEvent() {
    this.popup = new mapboxgl.Popup({
      closeButton: true,
      closeOnClick: false,
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
}
