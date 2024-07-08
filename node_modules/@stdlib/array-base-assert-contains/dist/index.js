"use strict";var o=function(r,e){return function(){return e||r((e={exports:{}}).exports,e),e.exports}};var v=o(function(M,c){
var y=require('@stdlib/array-base-assert-is-accessor-array/dist'),d=require('@stdlib/array-base-accessor-getter/dist'),p=require('@stdlib/array-base-getter/dist'),g=require('@stdlib/array-dtype/dist');function A(r,e){var a,i,u,s;for(u=g(r),y(r)?i=d(u):i=p(u),a=r.length,s=0;s<a;s++)if(i(r,s)===e)return!0;return!1}c.exports=A
});var l=o(function(O,f){
var h=require('@stdlib/assert-is-collection/dist'),m=require('@stdlib/array-base-assert-is-accessor-array/dist'),w=require('@stdlib/array-base-accessor-getter/dist'),G=require('@stdlib/array-dtype/dist'),b=require('@stdlib/error-tools-fmtprodmsg/dist');function j(r){var e,a,i;if(!h(r))throw new TypeError(b('1Yr2u',r));return i=G(r),m(r)&&(e=w(i)),a=r.length,e===void 0?u:s;function u(n){var t;for(t=0;t<a;t++)if(r[t]===n)return!0;return!1}function s(n){var t;for(t=0;t<a;t++)if(e(r,t)===n)return!0;return!1}}f.exports=j
});var k=require('@stdlib/utils-define-nonenumerable-read-only-property/dist'),q=v(),C=l();k(q,"factory",C);module.exports=q;
/** @license Apache-2.0 */
//# sourceMappingURL=index.js.map
