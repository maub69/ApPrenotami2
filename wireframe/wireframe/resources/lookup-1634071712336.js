(function(window, undefined) {
  var dictionary = {
    "85e3dd4a-9e3e-4fab-9ef1-178ab03ef36a": "Calendario",
    "84862f76-2193-4d75-a208-ce2a077d8f9d": "Dash",
    "0aa46381-4c90-43c3-bc02-0c36026d60c4": "Chat",
    "41c9db38-bd16-48d7-b7c2-18f328a74b8e": "Lista prenotazioni",
    "d444ec1b-1ade-48c4-a3b2-1ab30a07c3ca": "Prenotazione",
    "d12245cc-1680-458d-89dd-4f0d7fb22724": "Login",
    "282f66a8-4739-4e13-a055-e57712e3b999": "Archivio",
    "f39803f7-df02-4169-93eb-7547fb8c961a": "Template 1",
    "bb8abf58-f55e-472d-af05-a7d1bb0cc014": "default"
  };

  var uriRE = /^(\/#)?(screens|templates|masters|scenarios)\/(.*)(\.html)?/;
  window.lookUpURL = function(fragment) {
    var matches = uriRE.exec(fragment || "") || [],
        folder = matches[2] || "",
        canvas = matches[3] || "",
        name, url;
    if(dictionary.hasOwnProperty(canvas)) { /* search by name */
      url = folder + "/" + canvas;
    }
    return url;
  };

  window.lookUpName = function(fragment) {
    var matches = uriRE.exec(fragment || "") || [],
        folder = matches[2] || "",
        canvas = matches[3] || "",
        name, canvasName;
    if(dictionary.hasOwnProperty(canvas)) { /* search by name */
      canvasName = dictionary[canvas];
    }
    return canvasName;
  };
})(window);