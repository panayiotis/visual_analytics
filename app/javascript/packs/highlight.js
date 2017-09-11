/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'highlight' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

console.log('Hello World from Webpacker highlight pack')

import hljs from 'highlight.js/lib/highlight'
import haml from 'highlight.js/lib/languages/haml'

hljs.registerLanguage('haml', haml);

console.log("highlight.js languages:");
console.table(hljs.listLanguages());

hljs.initHighlightingOnLoad();
