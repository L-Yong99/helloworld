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

    // delete-activity

    // const deleteActivityEls = document.querySelectorAll(".delete-activity");

    const dayContainerEL = document.querySelector(".days-container");
    console.log("delete elements", dayContainerEL);
    //     dayContainerEL.addEventListener("click", (e) => {
    // console.log(e.target)
    //     })

    const hiddenFormEl2 = dayContainerEL.querySelector(".hidden-form-2");
    console.log("action", hiddenFormEl2.action);
    console.log("hidden-form", hiddenFormEl2);

    hiddenFormEl2.addEventListener("submit", (e) => {
      console.log("hidden-form", hiddenFormEl2);
      e.preventDefault();
      console.log("lets send");
      fetch(hiddenFormEl2.action, {
        method: "POST",
        headers: { Accept: "application/json" },
        body: new FormData(hiddenFormEl2),
      })
        .then((response) => response.json())
        .then((data) => {
          console.log(data);
          if (data.inserted_item) {
            const daysContainerEl = document.querySelector(".days-container");
            daysContainerEl.innerHTML = "";
            daysContainerEl.insertAdjacentHTML("beforeend", data.inserted_item);
          }
          this.formTarget.outerHTML = data.form;
        });
    });


    dayContainerEL.addEventListener("click", (e) => {
      const submitEl2 = dayContainerEL.querySelector(".submit-hidden-2");
      if (e.target != submitEl2) {

        const userActivityId = e.target.dataset.activityId;
        console.log(userActivityId);
        console.log(e);

        const hiddenTag2 = dayContainerEL.querySelector(".data-hidden-2");
        hiddenTag2.value = userActivityId;
        console.log("!!!", hiddenTag2.value);

        const submitEl2 = dayContainerEL.querySelector(".submit-hidden-2");
        submitEl2.click();
      }
    });


    this.#addMarkerToMap();
    this.#fitMapToMarker();

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

      this.clickedId = null;
      console.log("Clicked ID", this.clickedId);
      this.#selectDateEventPopUp();
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

        // // Pop up date event listener (AJAX) - Add activities
        // const dateEl = document.querySelector(".date");
        // console.log("date", dateEl);

        // dateEl.addEventListener("change", (e) => {
        //   const daysEl = document.querySelectorAll(".day");
        //   const day = e.target.value;
        //   // console.log("day", day);
        //   const placeId = e.target.dataset.placeid;
        //   // console.log("Place ID", placeId);
        //   const selectedDate = daysEl[day - 1].dataset.date;
        //   // console.log(selectedDate);
        //   const itineraryId = e.target.dataset.itineraryid;
        //   // console.log("itineraryId", itineraryId);
        //   const dates = e.target.dataset.dates;
        //   // console.log("dates", dates);

        //   const dataout = {
        //     itinerary_id: itineraryId,
        //     place_id: placeId,
        //     date: selectedDate,
        //     day: day,
        //   };

        //   const dataout_json = JSON.stringify(dataout);
        //   console.log(typeof dataout_json);

        //   // Input Data into hidden Tag
        //   const hiddenTag = document.querySelector(".data-hidden-1");
        //   hiddenTag.value = dataout_json;

        //   const hiddenFormEl = document.querySelector(".hidden-form-1");
        //   //  console.log("action",hiddenFormEl.action)

        //   hiddenFormEl.addEventListener("submit", (e) => {
        //     e.preventDefault();
        //     console.log("lets send");
        //     fetch(hiddenFormEl.action, {
        //       method: "POST",
        //       headers: { Accept: "application/json" },
        //       body: new FormData(hiddenFormEl),
        //     })
        //       .then((response) => response.json())
        //       .then((data) => {
        //         console.log(data);
        //         if (data.inserted_item) {
        //           const daysContainerEl =
        //             document.querySelector(".days-container");
        //           daysContainerEl.innerHTML = "";
        //           daysContainerEl.insertAdjacentHTML(
        //             "beforeend",
        //             data.inserted_item
        //           );
        //         }
        //         this.formTarget.outerHTML = data.form;
        //       });
        //   });

        //   const submitEl = document.querySelector(".submit-hidden-1");
        //   submitEl.click();
        // });

        // Query detail button
        // add event to detail element (detailEl)
        // e.target.dataset.placeid (should get place id)
        // placeJSON -> search for place id -> get data to populate side

        // // Run pop up
        // this.popup.setLngLat(coordinates).setHTML(infoWIndow).addTo(this.map);
        this.#selectDateEventPopUp();

        this.map.flyTo({
          center: coordinates,
        });
      }
    });
  }

  #selectDateEventPopUp() {
    // Pop up date event listener (AJAX) - Add activities
    const dateEl = document.querySelector(".date");
    console.log("date", dateEl);

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
      console.log(typeof dataout_json);

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
            console.log(data);
            if (data.inserted_item) {
              const daysContainerEl = document.querySelector(".days-container");
              daysContainerEl.innerHTML = "";
              daysContainerEl.insertAdjacentHTML(
                "beforeend",
                data.inserted_item
              );
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
