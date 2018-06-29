import Turbolinks from "turbolinks";
import Rails from "rails-ujs";
import * as Web3 from "@nervos/web3";

window.Web3 = Web3;

// Example
let web3 = Web3.default("http://47.94.105.230:1337");
web3.cita.getMetaData().then(function(res) {
  console.log(res);
});

// Bootstrap
import "bootstrap/dist/js/bootstrap";

// Scss
import "./stylesheets/application.scss";

// Src
import "./images/index";
import './sweet';

Rails.start();
Turbolinks.start();
