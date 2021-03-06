import Turbolinks from "turbolinks";
import Rails from "rails-ujs";
import * as Web3 from "@nervos/web3";

window.Web3 = Web3;

// Bootstrap
import "bootstrap/dist/js/bootstrap";

// Scss
import "./stylesheets/application.scss";

// Src
import "./images/index";
import './sweet';

// import Vue from 'vue'
// import App from '../app.vue'
//
// document.addEventListener('DOMContentLoaded', () => {
//   const el = document.body.appendChild(document.createElement('hello'))
//   const app = new Vue({
//     el,
//     render: h => h(App)
//   })
//
//   console.log(app)
// })

Rails.start();
Turbolinks.start();
