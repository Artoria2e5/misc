Hacking into QQ Group-space
====

[QQ Group Space](http://qun.qq.com/air/) is a place for 'group' members to share files, communicate with each other, etc.
The webpage always loads fscking slow and that's why this article is here.

The fucking webpage loads the bbs site when it is on the 'Shared Files' page.

Well, let's read the HTML.

<head> builtins
----
```JavaScript
// 1.js: The first JavaScript found in the HTML source.
// Implements:
//   winName.{get,remove,clear} Does something with Window name.
var winName = {
  set: function(n, v) {
    var name = window.name || "";
    v = encodeURIComponent(v);
    if (name.match(new RegExp(";" + n + "=([^;]*)(;|$)"))) {
      window.name = name.replace(new RegExp(";" + n + "=([^;]*)"), ";" + n + "=" + v);
    } else {
      window.name = name + ";" + n + "=" + v;
    }
  },
  get: function(n) {
    var name = window.name || "";
    var v = name.match(new RegExp(";" + n + "=([^;]*)(;|$)"));
    return decodeURIComponent(v ? v[1] : "");
  },
  remove: function(n) {
    var name = window.name || "";
    window.name = name.replace(new RegExp(";" + n + "=([^;]*)"), "");
  },
  clear: function() {
    window.name = "";
  }
};
// Bunches of variables
var g_fromProtal = winName.get("fromPortal") == 1;
document.domain = 'qq.com';
var g_isd = [new Date() - 0];
var g_V = {
  qz: '_2.1.1.4',
  ci: '_915b'
},
g_V = {
  qz: '_2.1.34',
  ci: '_v6_20131113',
  se: '',
  gp: ''
},
g_iLoginUin = 0,
siDomain = 'qzonestyle.gtimg.cn',
imgcacheDomain = 'qzs.qq.com',
g_UserBitmap = "0",
g_LoginBitmap = "0",
g_StyleID = "v6/16",
g_hasCustomStyle = 0,
g_diyTitle = "",
g_diySkin = 0,
g_SceneID = 9,
g_StyleID = "v6/16",
g_fullMode = 6,
g_Mode = "ofp",
g_frameStyle = 1,
g_version = 6,
g_isFriend = 0,
g_timestamp = 0,
g_Dressup = {
  items: [],
  windows: []
},
iv = {},
g_StaticFlag = "0",
g_TransparentLevel = 0,
g_isDirectApp = 0,
g_isBGScroll = 0,
ownermode = true,
ownerProfileSummary = [],
g_fl = 0,
g_ReadOnly = 0,
g_Errno = 0,
g_isOFP = "1",
g_isHideTitle = "0",
g_icLayout = "0",
g_Data = {},
g_isFromPengYou = "",
g_isBrandQzone = "",
g_isFamousQzone = "",
g_xwMode = "",
g_needDec = 1,
g_isFastPav = "1",
_s_ = new Date();
window.onerror = function(msg, url, line) {
  var info = [msg, url, line, window.navigator.userAgent].join('|_|');
  new Image().src = 'http://badjs.qq.com/cgi-bin/js_report?level=4&bid=155&mid=275014&old=1&msg=' + encodeURIComponent(info) + '&' + new Date().getTime();
  return false;
};
window.imweb = {
  report: (function() {
    var mIds = ["*", 277425, 277427, 277429, 277431, 277433, 277435, 289259, 289260, 289261, 289262, 289263, 289264, 289265, 289266, 289267, 289268, 289269, 289270, 289271, 289272, 289273, 290175, 290176, 295753, 295754, 295755, 295756, 299214, 299215, 299216, 299231, 352949];
    var caches = {};
    var img = new Image();
    var timer;
    var reportData = function() {
      var arr = [];
      for (var o in caches) {
        arr.push(o + '-' + caches[o].v + '-' + mIds[o] + '_' + caches[o].v);
      }
      img.src = 'http://jsreport.qq.com/cgi-bin/report?id=164&rs=' + arr.join('|_|') + '&r=' + Math.random();
      caches = {};
    };
    return function(key, num) {
      if (!mIds[key]) {
        return;
      }
      num = parseInt(num) || 1;
      if (!caches[key]) {
        caches[key] = {
          v: num
        }
      } else {
        caches[key].v += num;
      }
      clearTimeout(timer);
      timer = setTimeout(reportData, 500);
    };
  })()
};
void
function() {
  setTimeout(function() {
    var b = document.cookie.match(/(^| )nohost_guid=([^;]*)(;|$)/);
    if (!b ? 0 : decodeURIComponent(b[2])) {
      var b = 'http://' + window.location.hostname + "/nohost_htdocs/js/SwitchHost.js?random=" + Math.random(),
      c = function(a) {
        try {
          eval(a)
        } catch(b) {}
        window.SwitchHost && window.SwitchHost.init && window.SwitchHost.init()
      },
      a = window.ActiveXObject ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest;
      a.open("GET", b);
      a.onreadystatechange = function() {
        4 == a.readyState && ((200 <= a.status && 300 > a.status || 304 === a.status || 1223 === a.status || 0 === a.status) && c(a.responseText), a = null)
      };
      a.send(null)
    }
  },
  2000)
} (); (function() {
  var base = "http://1.url.cn/qun/zone/feeds/js/12/";
  var jsNames = ["BaseClass", "Constant", "catractModuelView", "click_stat", "config", "feed_detail", "frontPage", "groupGuide", "groupHeader", "groupHome", "groupLikeComponent", "groupMember", "groupMoodPoster", "groupNotice", "groupPhoto", "groupPortal", "groupPortalFeeds", "groupPortalSidebar", "groupSearch", "groupShare", "groupShareUploader", "groupZone", "history", "moduleCallMonitor", "music", "pageTitleManager", "placeholder", "portalUi", "qunPortal", "request", "requestCenter", "router", "scrollLoader", "tool", "toolBar"];
  window.g_js = {};
  for (var i = 0; i < jsNames.length; i++) {
    window.g_js[jsNames[i]] = base + jsNames[i] + ".js";
  }
})();
```
