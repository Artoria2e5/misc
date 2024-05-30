// ==UserScript==
// @author         Artoria2e5
// @name           Highlight almost-8 portals
// @category       Highlighter
// @version        0.0.4
// @id             highlight-7miss1@Artoria2e5
// @description    Find portals that are 1/2/3 resonators to level 8. Makes its own requests; use with caution.
// @namespace      https://github.com/IITC-CE/ingress-intel-total-conversion
// @match          https://intel.ingress.com/*
// @match          https://intel-x.ingress.com/*
// @downloadURL    https://github.com/Artoria2e5/misc/raw/master/ingress/highlight-7miss1.js
// @updateURL      https://github.com/Artoria2e5/misc/raw/master/ingress/highlight-7miss1.js
// @grant          none
// ==/UserScript==

/* exported setup, changelog --eslint */
/* global L */
function wrapper(plugin_info) {
  console.log("wrapper");
  // ensure plugin framework is there, even if iitc is not yet loaded
  if (typeof window.plugin !== "function") window.plugin = function () {};

  //PLUGIN AUTHORS: writing a plugin outside of the IITC build environment? if so, delete these lines!!
  //(leaving them in place might break the 'About IITC' page or break update checks)
  /*
  plugin_info.buildName = 'local';
  plugin_info.dateTimeVersion = '2024-04-04-045100';
  plugin_info.pluginId = 'highlight-7miss1';
  */
  //END PLUGIN AUTHORS NOTE

  const changelog = [
    {
      version: "0.0.1",
      changes: ["New"],
    },
    {
      version: "0.0.2",
      changes: [
        "Always use cache regardless of freshness -- should reduce request count.",
      ],
    },
    {
      version: "0.0.3",
      changes: [
        "Exclude self deployed portals.",
        "Exclude Machina from requests.",
        "Include portals with level equal to resCount.",
        "Change color scheme.",
        "Remove debug prints.",
      ],
    },
    {
      version: "0.0.4",
      changes: [
        "Add dashed stroke for the colorblind.",
      ],
    }
  ];

  // use own namespace for plugin
  const self = {};
  window.plugin.highlightSevenMissOne = self;

  // chosen by python-colorspace `darken(sequential_hcl("SunsetDark").colors(5), amount=0.3)`
  self.styles = {
    common: {
      fillOpacity: 0.8,
      linecap: "butt",
    },
    sev_miss_1: {
      fillColor: "#630050",
    },
    sev_miss_2: {
      fillColor: "#C01F3C",
    },
    sev_miss_3: {
      fillColor: "#BD6530",
    },
  };

  self.dashArrayMemo = {
    scale: -1,
  };

  self.makeDashArray = function (scale, dashes) {
    if (self.dashArrayMemo.scale === scale && dashes in self.dashArrayMemo) {
      return self.dashArrayMemo[dashes];
    }
    self.dashArrayMemo.scale = scale;
    // LEVEL_TO_RADIUS[7] === 10; 2pi ~= 6.3
    const c = 63 * scale;
    const unit = c / dashes / 3;
    const da = self.dashArrayMemo[dashes] = `${unit}, ${unit * 2}`;
    return da;
  }

  self.checkDetail = function (data, details) {
    // console.log("candidate " + data.portal.options.guid)
    if (details === undefined) {
      // console.log("no details ")
      return;
    }
    const reso = details.resonators;

    if (reso.some((x) => x.owner === PLAYER.nickname)) return;
    const reso_sum = reso.filter((x) => x.level === 8).length;
    const reso_needed = 8 - reso_sum;
    // console.log("reso_needed " + reso_needed)

    const newStyle = L.extend(
      {},
      self.styles.common,
      self.styles["sev_miss_" + reso_needed],
      {dashArray: self.makeDashArray(window.portalMarkerScale(), reso_sum)},
    );

    if (newStyle.fillColor) {
      data.portal.setStyle(newStyle);
    }
  };

  self.highlight = function (data) {
    const portal_data = data.portal.options.data;
    const portal_level = portal_data.level;
    if (
      !(
        portal_level === 7 ||
        (portal_level >= 5 && portal_level === portal_data.resCount)
      )
    )
      return;
    if (portal_data.team === "M") return;
    const guid = data.portal.options.guid;

    // Accept old data (false). Only request when completely missing (undefined).
    if (window.portalDetail.isFresh(guid) === undefined) {
      const req_promise = window.portalDetail.request(guid);
      req_promise.then(function (_) {
        self.checkDetail(data, window.portalDetail.get(guid));
      });
    }
    self.checkDetail(data, window.portalDetail.get(guid));
  };

  setup = self.setup = function () {
    window.addPortalHighlighter("Almost-8 Portals", self.highlight);
  };

  setup.info = plugin_info; //add the script info data to the function as a property
  if (typeof changelog !== "undefined") setup.info.changelog = changelog;
  if (!window.bootPlugins) window.bootPlugins = [];
  window.bootPlugins.push(setup);
  // if IITC has already booted, immediately run the 'setup' function
  if (window.iitcLoaded && typeof setup === "function") setup();
} // wrapper end


// inject code into site context
const script = document.createElement('script');
const info = {};
if (typeof GM_info !== 'undefined' && GM_info && GM_info.script) info.script = { version: GM_info.script.version, name: GM_info.script.name, description: GM_info.script.description };
script.appendChild(document.createTextNode('(' + wrapper + ')(' + JSON.stringify(info) + ');'));
(document.body || document.head || document.documentElement).appendChild(script);