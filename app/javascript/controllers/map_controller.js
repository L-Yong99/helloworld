import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    center: Array,
    geojson: String,
    activitiesId: Array,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    this.placesGeoJson = JSON.parse(this.geojsonValue);
    console.log(this.placesGeoJson);
    console.log(this.activitiesIdValue);
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
    });

    this.map.on("load", () => {
      // Load all markers for use later
      // Add default food
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289929/Hello%20World/Vegan_8_1_kbpop0.png",
        "default_foods"
      );
      // Add active food
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289929/Hello%20World/Vegan_8_bpi6cs.png",
        "active_foods"
      );

      // Add default interesting places
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289930/Hello%20World/Camera_8_2_tker1q.png",
        "default_interesting_places"
      );
      // Add active interesting places
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289929/Hello%20World/Camera_8_1_jxgjlb.png",
        "active_interesting_places"
      );

      // Add default shops
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289929/Hello%20World/Building_8_rjxila.png",
        "default_shops"
      );
      // Add active shops
      this.#addImage(
        "https://res.cloudinary.com/duadcuueg/image/upload/v1669289929/Hello%20World/Building_8_1_lfq6qm.png",
        "active_shops"
      );

      // Declare the source
      const source = "places";

      // Add Food Source and Layer
      this.#addSource(source, this.placesGeoJson);

      // this.#addLayer(source, 0.35);
      this.layersIdStore = [];
      this.symbolsIdStore = [];
      this.#addMultipleLayers(source);

      //Initilaize pop up and click id
      this.#createPopEvent();

      //Initilaize click id
      let clickedId = null;

      // const layerIds = ["layer-foods","layer-interesting_places","layer-shops"] // Set more here if add more types of places
      this.index = 0;
      this.layersIdStore.forEach((layerId) => {
        // Initialize events
        // Initialize hover Event
        this.#hoverEvent(layerId, 0.35, 0.45);

        // Initialize remove hover event
        this.#removeHoverEvent(layerId, 0.35);

        // Initialize Click event
        this.#clickEvent(layerId);

        // Initialize click remove event
        this.#clickRemoveEvent(layerId, 0.35);

        // Set toggle marker
        this.#toggleMarkers(layerId, 0.35);

        // Set filters
        this.#FilterLayer(layerId, 0.35)
      });

    });

    this.#deleteActivity();
    this.#addMarkerToMap();
    this.#fitMapToMarker();

    // Lets initialize an array to store all markers for users
    this.userMarkers = [];
    this.#loadUserMarkers();

    // =================== end ===============================//
  }

  #FilterLayer(layerId,defaultSize) {
  const filterEl = document.querySelector(".filter-container");
        const divEl = document.createElement("div");

        divEl.setAttribute("for", layerId);
        divEl.classList.add("filter-element")
        divEl.textContent = this.symbolsIdStore[this.index];
        filterEl.insertAdjacentElement("beforeend", divEl);
        this.index = this.index + 1;
        console.log(filterEl);

        // When the checkbox changes, update the visibility of the layer.
        divEl.addEventListener("click", (e) => {
          const visibility = this.map.getLayoutProperty(layerId, "visibility");
          if (visibility === "visible") {
            this.map.setLayoutProperty(layerId, "visibility", "none");
            divEl.classList.add("active");
            this.#setMarkerDefault(layerId, defaultSize);
          } else {
            divEl.classList.remove("active");
            this.map.setLayoutProperty(layerId, "visibility", "visible");
          }
        });
  }

  #addMultipleLayers(source) {
    // this.layersIdStore = []
    this.placesGeoJson.features.forEach((feature) => {
      const symbol = feature.properties.category;
      const layerID = `layer-${symbol}`;
      console.log(layerID);
      const defaultIconSize = 0.35;
      // Add a layer for this symbol type if it hasn't been added already.
      if (!this.map.getLayer(layerID)) {
        this.layersIdStore.push(layerID);
        this.symbolsIdStore.push(symbol);
        this.map.addLayer({
          id: layerID,
          type: "symbol",
          source: source,
          layout: {
            "icon-image": ["get", "defaultIcon"], // reference the image
            "icon-size": defaultIconSize,
            visibility: "visible",
            "icon-allow-overlap": true,
          },
          filter: ["==", "category", symbol],
        });
      }
    });
  }

  #toggleMarkers(layerId, defaultSize) {
    const toggleLayerEl = document.querySelector(".toggle-icons");
    console.log(toggleLayerEl);
    toggleLayerEl.id = layerId;
    toggleLayerEl.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      const visibility = this.map.getLayoutProperty(layerId, "visibility");
      console.log(visibility);

      const filterEls = document.querySelectorAll(".filter-element")
      if (toggleLayerEl.classList.contains("active")) {
        this.layersIdStore.forEach((layerId) => {
          // const visibility = this.map.getLayoutProperty(layerId, "visibility");
          this.map.setLayoutProperty(layerId, "visibility", 'visible');
          toggleLayerEl.classList.remove("active");
          filterEls.forEach(filterEl => filterEl.classList.remove("active"))
          this.#setMarkerDefault(layerId, defaultSize);
        });
      } else {
        this.layersIdStore.forEach((layerId) => {
        // const visibility = this.map.getLayoutProperty(layerId, "visibility");
        this.map.setLayoutProperty(layerId, "visibility", 'none');
        toggleLayerEl.classList.add("active");
        filterEls.forEach(filterEl => filterEl.classList.add("active"))
        this.#setMarkerDefault(layerId, defaultSize);
        })
      }
    });
  }

  #loadUserMarkers() {
    this.activitiesIdValue.forEach((id) => {
      const feature = this.placesGeoJson.features.find((feature) => {
        return feature.properties.placeId === id;
      });
      // console.log(feature.geometry.coordinates);
      const coordinates = feature.geometry.coordinates;
      const markerId = feature.properties.placeId;

      this.#createUserMarker(coordinates, markerId);
      // console.log(this.userMarkers);
    });
  }

  #createUserMarker(coordinates, id) {
    const el = document.createElement("div");
    el.className = "marker";

    // make a marker for each feature and add it to the map
    const marker = new mapboxgl.Marker(el)
      .setLngLat(coordinates)
      .addTo(this.map);

    // console.log("marker id", id);

    this.userMarkers.push({
      id: id,
      marker: marker,
    });
  }

  #deleteActivity() {
    let placeId;
    const dayContainerEL = document.querySelector(".days-container");
    // console.log("delete elements", dayContainerEL);

    const hiddenFormEl2 = document.querySelector(".hidden-form-2");
    // console.log("action", hiddenFormEl2.action);
    // console.log("hidden-form", hiddenFormEl2);

    hiddenFormEl2.addEventListener("submit", (e) => {
      // console.log("hidden-form", hiddenFormEl2);
      e.preventDefault();
      console.log("lets send");
      fetch(hiddenFormEl2.action, {
        method: "POST",
        headers: { Accept: "application/json" },
        body: new FormData(hiddenFormEl2),
      })
        .then((response) => response.json())
        .then((data) => {
          // console.log(data);
          if (data.inserted_item) {
            const daysContainerEl = document.querySelector(".days-container");
            daysContainerEl.innerHTML = "";
            daysContainerEl.insertAdjacentHTML("beforeend", data.inserted_item);

            // Find place id object index and delete marker
            console.log("user act id", placeId);
            const markerindex = this.userMarkers.findIndex((markerObj) => {
              return +markerObj.id === +placeId;
            });
            // console.log("marker",markerindex)
            this.userMarkers[markerindex].marker.remove();
            this.userMarkers.splice(markerindex, 1);
          }
          this.formTarget.outerHTML = data.form;
        });
    });

    dayContainerEL.addEventListener("click", (e) => {
      const submitEl2 = document.querySelector(".submit-hidden-2");
      if (e.target != submitEl2) {
        const userActivityId = e.target.dataset.activityId;
        placeId = e.target.dataset.placeId;
        // console.log(userActivityId);
        // console.log(e);

        const hiddenTag2 = document.querySelector(".data-hidden-2");
        hiddenTag2.value = userActivityId;
        // console.log("!!!", hiddenTag2.value);

        const submitEl2 = document.querySelector(".submit-hidden-2");
        submitEl2.click();
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

  #addLayer(source, defaultIconSize) {
    this.map.addLayer({
      id: source,
      type: "symbol",
      source: source, // reference the data source
      layout: {
        "icon-image": ["get", "defaultIcon"], // reference the image
        "icon-size": defaultIconSize,
        visibility: "visible",
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

  #removeHoverEvent(layerID, defaultSize) {
    // Remove hover
    this.map.on("mouseleave", layerID, (e) => {
      // console.log("mouseleave");
      // this.thing = false

      if (this.clickedId == null) {
        this.map.setLayoutProperty(layerID, "icon-image", [
          "get",
          "defaultIcon",
        ]);
        this.map.setLayoutProperty(layerID, "icon-size", defaultSize);
        this.popup.remove();
      }
    });
  }

  #hoverEvent(layerId, defaultSize, activeSize) {
    this.map.on("mouseenter", layerId, (e) => {
      console.log("mouseenter");

      // console.log("in", e);
      // Pop Up
      this.map.getCanvas().style.cursor = "pointer";
      // e.preventDefault();
      this.map.setLayoutProperty(layerId, "icon-image", [
        "match",
        ["id"], // get the feature id (make sure your data has an id set or use generateIds for GeoJSON sources
        e.features[0].id,
        ["get", "activeIcon"], //image when id is the clicked feature id
        ["get", "defaultIcon"], // default
      ]);

      this.map.setLayoutProperty(layerId, "icon-size", [
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
      // console.log("popupNode", popupNode);

      this.popup
        .setLngLat(coordinates)
        .setDOMContent(popupNode)
        .addTo(this.map);

      this.clickedId = null;
      // console.log("Clicked ID", this.clickedId);
      this.#selectDateEventPopUp(); // Must ON BACK!
    });
  }

  #clickRemoveEvent(layerID, defaultSize) {
    this.map.on("click", (e) => {
      // console.log("map", e);
      if (e.defaultPrevented === false) {
        this.#setMarkerDefault(layerID, defaultSize);
      }
    });
  }

  #setMarkerDefault(layerID, defaultSize) {
    if (this.map._popups != 0) {
      this.map._popups[0].remove();
    }
    this.map.setLayoutProperty(layerID, "icon-image", ["get", "defaultIcon"]);
    this.map.setLayoutProperty(layerID, "icon-size", defaultSize);
    this.clickedId = null;
  }

  #clickEvent(layerId) {
    this.map.on("click", layerId, (e) => {
      e.preventDefault();
      // console.log(this.clickedId);
      this.map.getCanvas().style.cursor = "pointer";
      // console.log(source, e.features);
      if (e.features) {
        this.clickedId = e.features[0].id;
        // console.log(this.clickedId);
        this.map.setLayoutProperty(layerId, "icon-image", [
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
        const placeId = e.features[0].properties.place_id;

        const popupNode = document.createElement("div");
        popupNode.insertAdjacentHTML("beforeend", infoWIndow);
        // console.log("popupNode",popupNode)

        this.popup
          .setLngLat(coordinates)
          .setDOMContent(popupNode)
          .addTo(this.map);

        this.#selectDateEventPopUp(layerId, coordinates, placeId);

        this.map.flyTo({
          center: coordinates,
        });
      }
    });
  }

  #selectDateEventPopUp(layerID, coordinates, placeId) {
    // Pop up date event listener (AJAX) - Add activities
    const dateEl = document.querySelector(".date");
    // console.log("date", dateEl);

    dateEl.addEventListener("change", (e) => {
      const daysEl = document.querySelectorAll(".day");
      const day = e.target.value;
      // console.log("day", day);
      const placeId = e.target.dataset.placeid;
      // console.log("Place ID", placeId);
      const selectedDate = daysEl[day - 1].dataset.date;
      // console.log(selectedDate);
      const itineraryId = e.target.dataset.itineraryid;
      // console.log("itineraryId", itineraryId);
      const dates = e.target.dataset.dates;
      // console.log("dates", dates);

      const dataout = {
        itinerary_id: itineraryId,
        place_id: placeId,
        date: selectedDate,
        day: day,
      };

      const dataout_json = JSON.stringify(dataout);
      // console.log(typeof dataout_json);

      // Input Data into hidden Tag
      const hiddenTag = document.querySelector(".data-hidden-1");
      hiddenTag.value = dataout_json;

      const hiddenFormEl = document.querySelector(".hidden-form-1");
      //  console.log("action",hiddenFormEl.action)

      hiddenFormEl.addEventListener("submit", (e) => {
        e.preventDefault();
        console.log("lets send");
        fetch(hiddenFormEl.action, {
          method: "POST",
          headers: { Accept: "application/json" },
          body: new FormData(hiddenFormEl),
        })
          .then((response) => response.json())
          .then((data) => {
            // console.log(data);
            if (data.inserted_item) {
              const daysContainerEl = document.querySelector(".days-container");
              daysContainerEl.innerHTML = "";
              daysContainerEl.insertAdjacentHTML(
                "beforeend",
                data.inserted_item
              );

              if (this.map._popups != 0) {
                this.map._popups[0].remove();
              }
              this.map.setLayoutProperty(layerID, "icon-image", [
                "get",
                "defaultIcon",
              ]);
              this.map.setLayoutProperty(layerID, "icon-size", 0.35);

              //Add user selected marker here
              this.#createUserMarker(coordinates, placeId);
            }
            this.formTarget.outerHTML = data.form;
          });
      });

      const submitEl = document.querySelector(".submit-hidden-1");
      submitEl.click();
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
