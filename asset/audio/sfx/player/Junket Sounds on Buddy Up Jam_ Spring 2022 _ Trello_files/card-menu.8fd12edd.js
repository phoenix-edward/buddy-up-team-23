!function(){var e="undefined"!=typeof globalThis?globalThis:"undefined"!=typeof self?self:"undefined"!=typeof window?window:"undefined"!=typeof global?global:{},t={},r={},o=e.parcelRequire3642;null==o&&((o=function(e){if(e in t)return t[e].exports;if(e in r){let o=r[e];delete r[e];let n={id:e,exports:{}};return t[e]=n,o.call(n.exports,n,n.exports),n.exports}var o=new Error("Cannot find module '"+e+"'");throw o.code="MODULE_NOT_FOUND",o}).register=function(e,t){r[e]=t},e.parcelRequire3642=o),o.register("17NnS",(function(e,t){"use strict";var r,n=(r=o("2iUxv"))&&r.__esModule?r:{default:r};var i=o("5PTBZ");const l=TrelloPowerUp.Promise,s={401:i.Unauthorized,403:i.Unauthorized,404:i.NotFound};e.exports=(e,t)=>l.resolve(e).catch((e=>{if(e){let t,r;try{r=JSON.parse(e.body),t=n.default.get(r,"error.message")}catch(e){}if(403===e.status&&r&&"usageLimits"===n.default.get(r,"error.errors[0].domain"))throw console.warn("Rate Limited!"),new i.RateLimited(t);throw((e,t)=>new(s[e]||i.Unknown)(t))(e.status,t)}throw t?new t:new i.Unknown}))})),o.register("5PTBZ",(function(e,t){"use strict";e.exports=TrelloPowerUp.util.makeErrorEnum("GoogleDrive",["Unauthorized","NotFound","Unknown","Cancelled","RateLimited"])}))}();
//# sourceMappingURL=card-menu.8fd12edd.js.map
