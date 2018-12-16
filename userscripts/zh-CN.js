// ==UserScript==
// @name         zh-CN
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  Force zh-Hans-CN on certain Chinese websites so that my browser finds the right fonts.
// @author       Artoria2e5
// @match        *://*.solidot.org/*
// @match        *://*.taobao.com/*
// @match        *://*.weibo.cn/*
// @match        *://*.baidu.com/*
// @match        https://cbdb.fas.harvard.edu/cbdbapi/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    document.body.lang = 'zh-Hans-CN'
})();
