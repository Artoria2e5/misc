// ==UserScript==
// @author         Artoria2e5
// @name           Highlight 7-miss-123 portals
// @category       Highlighter
// @version        0.0.1
// @description    Find L7 portals that are almost L8. Makes its own requests; use with caution.
// @namespace      https://github.com/IITC-CE/ingress-intel-total-conversion
// @match          https://intel.ingress.com/*
// @match          https://intel-x.ingress.com/*
// @grant          none
// ==/UserScript==

/* exported setup, changelog --eslint */
/* global L */
function wrapper(plugin_info) {
  console.log('wrapper');
  // ensure plugin framework is there, even if iitc is not yet loaded
  if (typeof window.plugin !== 'function') window.plugin = function () { };

  //PLUGIN AUTHORS: writing a plugin outside of the IITC build environment? if so, delete these lines!!
  //(leaving them in place might break the 'About IITC' page or break update checks)
  /*
  plugin_info.buildName = 'local';
  plugin_info.dateTimeVersion = '2024-04-04-045100';
  plugin_info.pluginId = 'highlight-7miss1';
  */
  //END PLUGIN AUTHORS NOTE

  var changelog = [
    {
      version: '0.0.1',
      changes: ['New'],
    },
  ];

  // use own namespace for plugin
  var self = {};
  window.plugin.highlightSevenMissOne = self;

  self.styles = {
    common: {
      fillOpacity: 0.7
    },
    sev_miss_1: {
      fillColor: 'magenta'
    },
    sev_miss_2: {
      fillColor: 'red'
    },
    sev_miss_3: {
      fillColor: 'orange'
    }
  };

  self.highlightSevenMissOne_real = function(data, details) {
    // console.log("candidate " + data.portal.options.guid)
    if (details === undefined) {
      // console.log("no details ")
      return
    }
    var reso = details.resonators;
    var reso_sum = reso.filter((x) => x.level === 8).length;
    var reso_needed = 8 - reso_sum;
    // console.log("reso_needed " + reso_needed)

    var newStyle = L.extend({},
      self.styles.common,
      self.styles['sev_miss_' + reso_needed]
    );

    if (newStyle.fillColor) {
      data.portal.setStyle(newStyle);
    }
  }

  self.highlightSevenMissOne = function(data) {
    var portal_level = data.portal.options.data.level;
    if (portal_level !== 7) return;
    var guid = data.portal.options.guid;

    if (!window.portalDetail.isFresh(guid)) {
      var req_promise = window.portalDetail.request(guid);
      req_promise.then((function (_) {
        self.highlightSevenMissOne_real(data, window.portalDetail.get(guid));
      }));
    }
    self.highlightSevenMissOne_real(data, window.portalDetail.get(guid));
  }

  self.setup = function () {
    console.error('7m123setup');
    window.addPortalHighlighter('Almost-8 Portals', self.highlightSevenMissOne);
  }
  console.error('7m123');

  self.setup.info = plugin_info; //add the script info data to the function as a property
  if (typeof changelog !== 'undefined') self.setup.info.changelog = changelog;
  if (!window.bootPlugins) window.bootPlugins = [];
  window.bootPlugins.push(self.setup);
  // if IITC has already booted, immediately run the 'setup' function
  if (window.iitcLoaded && typeof setup === 'function') self.setup();
} // wrapper end
// inject code into site context
console.log('7m123boom')
var script = document.createElement('script');
var info = {};
if (typeof GM_info !== 'undefined' && GM_info && GM_info.script) info.script = { version: GM_info.script.version, name: GM_info.script.name, description: GM_info.script.description };
script.appendChild(document.createTextNode('(' + wrapper + ')(' + JSON.stringify(info) + ');'));
(document.body || document.head || document.documentElement).appendChild(script);