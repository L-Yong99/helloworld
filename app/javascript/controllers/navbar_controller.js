import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="navbar"
export default class extends Controller {
  connect() {
    // console.log(document.querySelector(".navbar-lewagon .navbar-brand img"))
    // addEventListener("scroll", (event) => {
    //   console.log("scroll Y", window.scrollY);
    //   console.log("Window inner height", window.innerHeight);
    // });
  }

  updateNavbar() {
    const navLinkEls = document.querySelectorAll(".nav-link")
    if (window.scrollY <= 61) {
      navLinkEls.forEach(navLinkEl => navLinkEl.classList.remove("inverse"))
      document.querySelector(".navbar-nav").classList.add("inverse")
      this.element.classList.remove("d-none");
      document.querySelector(".navbar-lewagon .navbar-brand img").classList.remove("active")
    }
    else if(window.scrollY > 61 && window.scrollY <= window.innerHeight) {
      this.element.classList.add("d-none");
    }

    // const navLink2Els = document.querySelectorAll(".nav-link2")
    // if (window.scrollY <= 61) {
    //   navLink2Els.forEach(navLink2El => navLink2El.classList.remove("inverse"))
    //   document.querySelector(".navbar-nav").classList.add("inverse")
    //   this.element.classList.remove("d-none");
    //   document.querySelector(".navbar-lewagon .navbar-brand img").classList.remove("active")
    // }
    // else if(window.scrollY > 61 && window.scrollY <= window.innerHeight) {
    //   this.element.classList.add("d-none");
    // }




    if (window.scrollY >= window.innerHeight) {
      navLinkEls.forEach(navLinkEl => navLinkEl.classList.add("inverse"))
      this.element.classList.remove("d-none");
      this.element.classList.add("navbar-lewagon-white");
      document.querySelector(".search-icon").classList.add("active")
      // console.log(document.querySelector(".navbar-lewagon .navbar-brand img"))
      document.querySelector(".navbar-lewagon .navbar-brand img").classList.add("active")
    } else {
      this.element.classList.remove("navbar-lewagon-white");
      document.querySelector(".search-icon").classList.remove("active")
    }
  }
}
