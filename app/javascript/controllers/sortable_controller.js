import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["activity"];

  connect() {
    console.log("sortable");
    console.log(this.activityTargets);
    this.activityTargets.forEach((activity) => {
      Sortable.create(activity, {
        group: "shared",
        ghostClass: "ghost",
        animation: 150,
        onEnd: (e) => {
          console.log(e.to);
          console.log(e.from);
          // alert(`${+e.from.id + 1} moved to ${+e.to.id + 1}`);
          // alert(`${+e.oldIndex + 1} moved to ${+e.newIndex + 1}`);

          const p_from = +e.from.id + 1;
          const p_to = +e.to.id + 1;
          const e_from = +e.oldIndex + 1;
          const e_to = +e.newIndex + 1;

          const dataOut = { p_from, p_to, e_from, e_to };

          const dayContainerEL = document.querySelector(".days-container");

          const hiddenTagEl = document.querySelector(".data-hidden-3");
          hiddenTagEl.value = JSON.stringify(dataOut);

          const hiddenFormEl3 = document.querySelector(".hidden-form-3");

          console.log(hiddenFormEl3.action);

          hiddenFormEl3.addEventListener("submit", (e) => {
            // console.log("hidden-form", hiddenFormEl2);
            e.preventDefault();
            console.log("lets send");
            fetch(hiddenFormEl3.action, {
              method: "POST",
              headers: { Accept: "application/json" },
              body: new FormData(hiddenFormEl3),
            })
              .then((response) => response.json())
              .then((data) => {
                console.log(data);
                if (data.inserted_item) {
                  const daysContainerEl =
                    document.querySelector(".days-container");
                  daysContainerEl.innerHTML = "";
                  daysContainerEl.insertAdjacentHTML(
                    "beforeend",
                    data.inserted_item
                  );

                  // Find place id object index and delete marker
                  // console.log("user act id", placeId);
                  // const markerindex = this.userMarkers.findIndex((markerObj) => {
                  //   return +markerObj.id === +placeId;
                  // });
                  // // console.log("marker",markerindex)
                  // this.userMarkers[markerindex].marker.remove();
                  // this.userMarkers.splice(markerindex, 1);
                }
                this.formTarget.outerHTML = data.form;
              });
          });

          const submitEl3 = document.querySelector(".submit-hidden-3");
          submitEl3.click();
        },
      });
    });
  }
}
