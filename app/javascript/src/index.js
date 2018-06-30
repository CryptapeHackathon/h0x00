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

Rails.start();
