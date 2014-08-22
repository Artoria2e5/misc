Hacking into QQ Group-space
====

[QQ Group Space](http://qun.qq.com/air/) is a place for 'group' members to share files, communicate with each other, etc.
The webpage always loads fscking slow and that's why this article is here.

The fucking webpage loads the bbs site when it is on the 'Shared Files' page.

Well, let's read the HTML.

<head> builtins
----
```JavaScript
// head-1.js: The first JavaScript found in the HTML source.
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
Then:
```JavaScript
// head-2.js: Contains some user info.
// UIN: aka ‘qq number’.
// BITMAP: Regex: [0-9a-f]{16}
var siDomain = 'ctc.qzonestyle.gtimg.cn';
var imgcacheDomain = 'ctc.qzs.qq.com';
var csVar = 'user_platform: imgcache_prefix:ctc. imgcache:qzs.qq.com qzonestyle:qzonestyle.gtimg.cn loginuin:<UIN> uin:<UIN>';
var g_iLoginUin = /* UIN */;
var g_iUin = /* UIN */;
var g_UserBitmap = /* 'BITMAP' */;
var g_LoginBitmap = /* 'BITMAP' */;
var ownerProfileSummary = /* ['nickName'] */;
var g_NowTime = /* 'POSIX TIME IN DEC LIKE IN $(date +%s)' */;


// FUNCTIONS
if (g_iLoginUin == 0) {
  document.cookie = "uin=;domain=qq.com";
  document.cookie = "skey=;domain=qq.com";
  window.location.href = 'http://' + window.location.hostname + "#tourl=" + encodeURIComponent(window.location.href);
}

// userInfo operations
(function() {
  if (typeof window.userInfo != 'undefined') {
    return;
  }
  window.userInfo = {
    'loginUin': 0,
    'loginNick': '',
    'isMember': false,
    'isManager': false,
    'isCreator': false,
    'groupId': '',
    'entryModule': ''
  };
  window.userInfo.set = function(obj) {
    for (var o in obj) {
      if (obj.hasOwnProperty(o) && userInfo.hasOwnProperty(o)) {
        userInfo[o] = obj[o];
      }
    }
  }
  var hash = location.hash;
  hash = hash.replace(/^#/, '').replace(/^(!\/)|(!)|(\/)/, '');
  var fragments = hash.split('\/');
  if (!fragments[0] || /^\d+$/.test(fragments[0])) {
    groupId = fragments[0];
  } else {
    groupId = parseInt(fragments[0], 10);
    if (isNaN(groupId)) {
      window.location.href = "http://" + window.location.hostname + '/group';
    } else {
    // Sets the URL!
      window.location.href = "http://" + window.location.hostname + '/group#!/' + groupId + '/' + fragments[1];
    }
  }
  var entryModule = isNaN(groupId) || !groupId ? (fragments[0] || 'portal') : (fragments[1] || 'home');
  userInfo['groupId'] = groupId;
  userInfo['entryModule'] = entryModule;
  window.uinmap = {};
  window.facemap = {};
  window.setmap = function(obj) {
    for (var o in obj) {
      if (obj.hasOwnProperty(o)) {
        uinmap[o] = obj[o].n;
        facemap[o] = obj[o].f;
      }
    }
  }
})();

window.refine = {};
refine.adapter = {
  quickInit: function() {
    new Image().src = 'http://3.url.cn/qun/zone/feeds/img/8/f_screen_56.png';
  },
  getGroupId: function() {
    return userInfo['groupId'];
  },
  getUin: function() {
    var cookie = document.cookie;
    var uin;
    if (cookie) {
      var arr = cookie.match(/(^| )uin=([^;]*)/);
      if (arr && (uin = arr[2])) {
        uin = parseInt(uin.substring(1, uin.length), 10);
      }
    }
    return uin;
  },
  isGroupManager: function() {
    return userInfo['isManager'] || userInfo['isCreator'];
  },
  getPhotoSize: function(type, ft) {
    return ft !== 'album' ? 628 : (type == 1 ? 800 : 400);
  },
  quickReport: function(oid) {
    var params = {
      '102': 240451,
      '103': 240452,
      '104': 240472,
      '142': 265680,
      '155': 271870
    };
    return function() {
      new Image().src = 'http://jsreport.qq.com/cgi-bin/report?_=' + Math.random() + '&id=95&rs=' + oid + '-1-' + params[oid] + '_1-' + refine.adapter.getGroupId();
    }
  } (),
  showpv: function(pv) {
    pv && $$('#f_vst').html((pv < 999999 ? pv: 999999) + '次访问');
  },
  extend: function(ext) {
    for (var o in ext) {
      refine.adapter[o] = ext[o];
    }
  }
}; (function(window, undefined) {
  var $ = window.$$ = function(selector) {
    if (! (this instanceof $)) {
      return new $(selector);
    }
    return this.add(selector);
  };
  var indexOf = Array.prototype.indexOf,
  toString = Object.prototype.toString;
  var now = $.now = function() {
    return new Date().getTime();
  };
  var noop = $.noop = function() {};
  $.isArray = function(obj) {
    return toString.call(obj) == '[object Array]';
  };
  $.inArray = function(elem, arr, i) {
    if ($.isArray(arr)) {
      if (indexOf) {
        return indexOf.call(arr, elem, i);
      }
      var len = arr.length;
      i = i ? i < 0 ? Math.max(0, len + i) : i: 0;
      for (; i < len; i++) {
        if (i in arr && arr[i] === elem) {
          return i;
        }
      }
    }
    return - 1;
  };
  var parseJSON = $.parseJSON = function(data) {
    try {
      if (window.JSON && window.JSON.parse) {
        return window.JSON.parse(data) || false;
      }
      return eval('(' + data + ')') || false;
    } catch(e) {
      return false;
    }
  };
  function createStandardXHR() {
    try {
      return new window.XMLHttpRequest();
    } catch(e) {}
  }
  function createActiveXHR() {
    try {
      return new window.ActiveXObject('Microsoft.XMLHTTP');
    } catch(e) {}
  }
  var getXHR = $.getXHR = window.ActiveXObject ?
  function() {
    return createStandardXHR() || createActiveXHR();
  }: createStandardXHR;
  $.get = function(url, callback, cache) {
    var xhr = getXHR(),
    _callback = function() {
      if (xhr.readyState != 4) {
        return;
      }
      xhr.onreadystatechange = noop;
      if (xhr.status >= 200 && xhr.status < 300 || xhr.status === 304 || xhr.status === 1223) {
        var data = xhr.responseText;
        callback($.parseJSON(data), data, xhr);
        return;
      }
      callback(false, '', xhr);
    };
    xhr.open('GET', url + (cache ? '': ('&_=' + now())), true);
    xhr.onreadystatechange = _callback;
    xhr.send(null);
  };
  var preventAbort = window.preventAbort = function(e) {
    e = e || window.event;
    var target = e.target || e.srcElement;
    while (target && target.nodeName != 'A') {
      target = target.parentNode;
    }
    if (target && /^javascript:/.test(target.href)) {
      if (e.preventDefault) {
        e.preventDefault();
      } else {
        e.returnValue = false;
      }
    }
  };
  document.onclick = preventAbort;
})(window);
function initHomeData() {
  $$.get('http://' + window.location.hostname + '/cgi-bin/feeds/get_list?qid=' + refine.adapter.getGroupId() + '&i=1&s=-1&n=5',
  function(data, dataText) {
    g_isd[2] = $$.now();
    window.initData = data;
    window.initText = dataText;
    if (window.initCallback) {
      window.initCallback(data, dataText);
      window.initCallback = null;
    }
  },
  true);
  refine.adapter.quickInit && refine.adapter.quickInit();
}
if (userInfo['entryModule'] == 'home') {
  initHomeData();
  g_isd[1] = $$.now();
}
```

You can also find a boring style writer inside. Strange to do, but not really
strange for Tencent. It's said that Tencent guys use MS FrontPage for writing HTML5,
and made font-family typos in Qzone CSS. Qzone is a 'Zone' service for users themselves.

<body> builtins
----

Wow, interesting! They use `<body>` like this: `<body class="noAd">`.
```JavaScript
// Function: changes URL. I don't know how would it appear elsewhere.
(function() {
	if (location.host != 'qun.qq.com' && location.host != 'qun.qzone.qq.com') {
		location.href = 'http://' + window.location.hostname + '/group';
	}
})();
```
```CoffeeScript
(->
  DEFAULT_COUNT = undefined
  DEFAULT_GROUP_COUNT = undefined
  cgiList = undefined
  fragments = undefined
  groupId = undefined
  hash = undefined
  jsList = undefined
  hash = location.hash
  DEFAULT_GROUP_COUNT = 4
  DEFAULT_COUNT = 4
  hash = "#!/portal "  if not hash or not hash.length
  hash = hash.replace(/^#/, "").replace(/^(!\/)|(!)|(\/)/, "")
  fragments = hash.split(" / ")
  groupId = parseInt(fragments[0], 10)
  if isNaN(groupId)
    GroupZone.setConfig "groupId ", 0
    GroupZone.setConfig "groupName ", ""
    QWT.data["entryModule "] = fragments[0] or "portal "
  else
    GroupZone.setConfig "groupId ", groupId
    GroupZone.setConfig "groupName ", groupId
    QWT.data["entryModule "] = fragments[1] or "home "
  cgiList = []
  jsList = []
  cgiList.push "1.url.cn / qun / zone / feeds / js / 12 / all.js ? v = 2 "
  cgiList.push window.location.hostname + " / cgi - bin / get_group_member ? callbackFun = _GroupMember & uin = " + QWT.escHTML(QWT.data["loginUin "]) + " & groupid = " + QWT.escHTML(GroupZone.getConfig("groupId ")) + " & neednum = 1 & r = " + Math.random() + " & g_tk = " + QWT.getACSRFToken() + " & ua = " + encodeURIComponent(navigator.userAgent)
  if QWT.data["entryModule "] is "portal "
    imweb.portalData = {}
    cgiList.push window.location.hostname + " / cgi - bin / get_group_list ? groupcount = " + DEFAULT_GROUP_COUNT + " & count = " + DEFAULT_COUNT + " & callbackFun = _GetGroupPortal & uin = " + QWT.data["loginUin "] + " & g_tk = " + QWT.getACSRFToken() + " & ua = " + encodeURIComponent(navigator.userAgent)
  else
    cgiList.push window.location.hostname + " / cgi - bin / get_group_share_info ? groupid = " + QWT.escHTML(GroupZone.getConfig("groupId ")) + " & uin = " + QWT.escHTML(QWT.data["loginUin "]) + " & callbackFun = _GroupShareInfo & t = " + Math.random() + " & g_tk = " + QWT.getACSRFToken()
    cgiList.push "u.photo.qq.com / cgi - bin / upp / qun_list_album_v2 ? getTotalPhoto = 1 & inCharset = utf - 8 & outCharset = utf - 8 & callbackFun = _GroupAlbumList & qunId = " + QWT.escHTML(GroupZone.getConfig("groupId ")) + " & uin = " + QWT.escHTML(QWT.data["loginUin "]) + " & start = 0 & num = 1000 & userinfo = 1 & t = " + Math.random() + " & output_type = json & refer = jsapi & g_tk = " + QWT.getACSRFToken()
  QWT.load
    jsList: jsList
    cgiList: cgiList
    jsMaxAge: 600
    jsConcat: false

  return
)()
GroupZone.ui.toolbar
  loginUin: GroupZone.getConfig("loginUin ")
  nickname: GroupZone.getConfig("loginNick ")
  groupId: GroupZone.getConfig("groupId ")
  supportId: 873

(->
  if QWT.data["entryModule "] isnt "search " and QWT.data["entryModule "] isnt "portal "
    GroupZone.ui.homeHeader
      groupId: GroupZone.getConfig("groupId ")
      groupName: GroupZone.getConfig("groupName ")
      memberCount: GroupZone.getConfig("members ").length or 0
      picCount: GroupZone.getConfig("totalPhotoCount ") or 0
      shareCount: GroupZone.getConfig("shareCount ") or 0
      bbsCount: GroupZone.getConfig("bbsCount ") or 0

  else
    GroupZone.ui.searchHeader {}  if QWT.data["entryModule "] is "search "
  return
)()
```
