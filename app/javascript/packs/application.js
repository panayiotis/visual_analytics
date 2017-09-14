/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker')

//import FetchData from 'visualization/fetch_data'
import Cedefop from 'cedefop'

var setup = () =>{
  var nodes = document.getElementsByClassName("cedefop-component");

  for (var node of nodes) {
    var data = JSON.parse(node.getAttribute("data"));
    console.log("data");
    new Cedefop(data);
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  console.log("DOM fully loaded and parsed");
});

document.addEventListener('turbolinks:load', function(event){
  console.log('turbolinks:load');
});

document.addEventListener('turbolinks:render', function(event){
  console.log('turbolinks:render');
});

document.addEventListener('turbolinks:before-render', function(event){
  console.log('turbolinks:before-render')
});


document.addEventListener('turbolinks:load', function(event){
  setup();
}, {once: true})

document.addEventListener('turbolinks:render', function(event){
  setup();
})

//document.addEventListener('turbolinks:render', setup())
//document.addEventListener('turbolinks:before-render', teardown())

//var fd = new FetchData();

// establish event listener
//document.addEventListener('data_fetched', function (e) {
  // run visualization
//  new Visualization(fd.data, fd.geojson);
//}, false);

// fetch data
//fd.fetch();
