import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="home"
export default class extends Controller {
  connect() {
    console.log("home");
    addEventListener("scroll", (event) => {
      console.log("scroll Y", window.scrollY);
      console.log("Window inner height", window.innerHeight);

      //Country 1
      if (window.scrollY > 800) {
        const country1ImgEl = document
          .querySelector(".country-img-1")
          .classList.add("active");
        console.log(country1ImgEl);

        const country1TextImgEl = document
          .querySelector(".country-container-1 > div")
          .classList.add("active");
        console.log(country1TextImgEl);
      }

      //Country 2
      if (window.scrollY > 1400) {
        const country1ImgEl = document
          .querySelector(".country-img-2")
          .classList.add("active");
        console.log(country1ImgEl);

        const country1TextImgEl = document
          .querySelector(".country-container-2 > div")
          .classList.add("active");
        console.log(country1TextImgEl);
      }

       //Country 3
       if (window.scrollY > 2000) {
        const country1ImgEl = document
          .querySelector(".country-img-3")
          .classList.add("active");
        console.log(country1ImgEl);

        const country1TextImgEl = document
          .querySelector(".country-container-3 > div")
          .classList.add("active");
        console.log(country1TextImgEl);
      }
    });
  }
}
