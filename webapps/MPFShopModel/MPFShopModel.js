define("DS/MPFShopModel/BackgroundModel",["DS/MPFModel/MPFModel"],function(a){var b=a.extend({setup:function(c,d){this._parent(c,d)}});return b});define("DS/MPFShopModel/PublicShopDataProxyV8",["DS/MPFDataProxy/DataProxy"],function(b){var a=b.extend({init:function(c){this._parent(c,"/mdshop/public/shopsv8")}});return a});define("DS/MPFShopModel/ProductDataProxy",["DS/MPFDataProxy/DataProxy"],function(b){var a=b.extend({init:function(c){this._parent(c,"/mdshop/shop-services/{0}/products")},urlGet:function(){return this.connector.url(this.resourcePath)},urlPost:null,urlPut:null,urlPatch:null,urlDelete:null,doPost:null,doPut:null,doPatch:null,doDelete:null});return a});define("DS/MPFShopModel/ShopPublicDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d,e){this._parent(d,"/mdshop/public/shopsv3?expand=false");this.addESID=e!==false},request:function(e,d){this._parent(e,d)},url:function(){if(!this.addESID){return this.connector.url(this.resourcePath,{addESID:false})}else{return this.connector.url(this.resourcePath)}}});return c});define("DS/MPFShopModel/ShopValidationModel",["DS/MPFModel/MPFModel"],function(b){var a;var d={};d.FORCE="force";var c={};c[d.FORCE]="identification";a=b.extend({defaults:c,setup:function(e,f){this._type="ShopValidationModel";this._parent(e,f)}});a.Fields=Object.freeze(d);return a});define("DS/MPFShopModel/MediaModel",["DS/MPFModel/MPFModel"],function(b){var a=b.extend({setup:function(c,d){this._parent(c,d)}});return a});define("DS/MPFShopModel/PublicShopDataProxyV1",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(b,c){var a=c.extend({init:function(d){this._parent(d,"/mdshop/public/shops")}});return a});define("DS/MPFShopModel/ShopNoPublicDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d,e){this._parent(d,"/mdshop/shops?expand=shop-services",e)},doPost:null,doPut:null,doPatch:null,doDelete:null});return c});define("DS/MPFShopModel/ShopValidationDataProxy",["UWA/String","DS/MPFDataProxy/DataProxy","DS/MPFError/NotImplementedError","DS/MPFError/BadArgumentError"],function(e,d,b,a){var c=d.extend({init:function(f){this._parent(f,"/mdshop/shops/{0}/kyc")},buildPath:function(f){if(f&&f.get("id")){return e.format(this.resourcePath,f.get("id"))}else{return new a("model id not defined")}},urlPut:b.emit,urlGet:b.emit,urlPost:b.emit});return c});define("DS/MPFShopModel/ProductModel",["DS/MPFModel/MPFModel"],function(b){var a=b.extend({setup:function(c,d){this._parent(c,d)}});return a});define("DS/MPFShopModel/ShopDataProxy",["UWA/String","DS/MPFDataProxy/DataProxy","DS/MPFUrl/UrlUtils"],function(d,c,b){var a=c.extend({init:function(e){this._parent(e,"/mdshop/shops")},urlGet:function(g,f){var e;f||(f={});f.expand||(f.expand=["offers"]);e=this._parent(g,f);if(f.uc2){e=(new b(e)).addParameter("uc2",f.uc2).getUrl()}return e}});return a});define("DS/MPFShopModel/BackgroundDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(b,c){var a=c.extend({init:function(d){this._parent(d,"/mdshop/shop-services/{0}/background")},urlPost:function(d){return this.connector.url(b.String.format(this.resourcePath,d.parentResourceId))},urlPut:null,urlPatch:function(d){return this.connector.url(b.String.format(this.resourcePath,d.parentResourceId))},urlDelete:null,doPut:null,doPatch:null,doDelete:null});return a});define("DS/MPFShopModel/ShopModel",["UWA/Core","UWA/Promise","UWA/String","DS/MPFModel/MPFModel","DS/MPFModel/ModelValidator","DS/MPFServices/MarketplaceServices","i18n!DS/MPFShopModel/assets/nls/ShopModel"],function(h,i,j,b,c,k,m){var l;var f={};var a={};var e={};var g={};f.NAME="shopName";f.LOGO="logo";f.DESCRIPTION="description";f.LONGITUDE="geolocLongitude";f.LATITUDE="geolocLatitude";f.OWNER="owner";f.STATE="currentState";f.EMAIL="email";f.CURRENCIES="supportedCurrencies";f.ADDRESS="postal-address";f.SERVICES="shopServices";f.DRUPAL_ID="drupalId";f.PHONE_NUMBER="phoneNumber";f.IS_COMPANY="isCompany";f.IS_INTERNAL="IsInternal";f.IS_AUTOMATIC_PRICING="isAutomaticPricing";f.KYC_STATUS="kycStatus";f.KYC_FORCED_STATUS="kycForcedStatus";f.COUNTRY="country";a.SUBMITTED="SUBMITTED";a.DRAFT="DRAFT";a.ACTIVE="ACTIVE";e.OFFERS="offers";e.SHOP_SERVICES="shop-services";g[k.MAKE]="MP3DP_PrintShopService";g[k.PART_SUPPLY]="MP_PartSupplyShopService";g[k.ENGINEERING]="MP_EngineeringShopService";var d={};d[f.NAME]="";d[f.IS_COMPANY]=true;d[f.EMAIL]="";d[f.PHONE_NUMBER]="";d[f.OWNER]="";l=b.extend({setup:function(n,o){this.constraints=o.constraints||null;this._type="ShopModel";this._parent(n,o);this.validator=this._createValidator()},defaults:d,parse:function(n){if(n.hasOwnProperty("shopServices")&&n.shopServices.hasOwnProperty("MP3DP_PrintShopService")){n.shopServices=n.shopServices.MP3DP_PrintShopService}if(n.hasOwnProperty("supportedCurrencies")&&typeof n.supportedCurrencies==="string"){n.supportedCurrencies=n.supportedCurrencies.split(",")}if(n.hasOwnProperty("owner")){n.owner=n.owner.substring(n.owner.lastIndexOf("/")+1,n.owner.length)}if(n["postal-address"]){n.address=n["postal-address"].substring(n["postal-address"].lastIndexOf("/")+1,n["postal-address"].length)}return n},toJSON:function(){var n=this._parent();delete n.parentResourceId;return n},validate:function(n){return this.validator.validate(n)},getName:function(){return this.get(f.NAME)},setName:function(n){return this.set(f.NAME,n)},getLogo:function(){return this.get("logoUrl")||this.get(f.LOGO)},isInternal:function(){var n;n=this.get(f.IS_INTERNAL);return n==="true"||n==="TRUE"||n===true},getLatitude:function(){return this.get("latitude")||this.get(f.LATITUDE)},getLongitude:function(){return this.get("longitude")||this.get(f.LONGITUDE)},getOwner:function(){return this.get(f.OWNER)},setOwner:function(n){return this.set(f.OWNER,n)},getState:function(){return this.get(f.STATE)},setState:function(n){return this.set(f.STATE,n)},getEmail:function(){return this.get(f.EMAIL)},getSupportedCurrencies:function(){return this.get(f.CURRENCIES)},setSupportedCurrencies:function(n){return this.set(f.CURRENCIES,n)},getAddress:function(){return this.get(f.ADDRESS)},setAddress:function(n){return this.set(f.ADDRESS,n)},getServices:function(){return this.get(f.SERVICES)},getService:function(r){var n;var q;var p;var o;q=g[r];p=this.getServices();if(p){o=!p.hasOwnProperty("id");if(o){n=p[q]}else{if(r===k.MAKE){n=p}}return n}},getDrupalId:function(){return this.get(f.DRUPAL_ID)},getPhoneNumber:function(){return this.get(f.PHONE_NUMBER)},isCompany:function(){return this.get(f.IS_COMPANY)},getCountry:function(){return this.get(f.COUNTRY)},hasAutomatedPricing:function(){return this.get(f.IS_AUTOMATIC_PRICING)},_createValidator:function(){return new c({model:this,validations:[{attribute:f.NAME,required:true,requiredError:j.ucfirst(j.format(m.get("isRequired"),m.get("name")))},{attribute:f.EMAIL,pattern:/.+/,required:true,requiredError:j.ucfirst(j.format(m.get("isRequired"),m.get("email"))),conditions:[[f.IS_INTERNAL,"TRUE",true],[f.IS_INTERNAL,"true",true],[f.IS_INTERNAL,true,true]]},{attribute:f.EMAIL,required:false,isEmail:true,invalidError:j.ucfirst(j.format(m.get("isInvalid"),m.get("email"))),conditions:[[f.IS_INTERNAL,"TRUE",true],[f.IS_INTERNAL,"true",true],[f.IS_INTERNAL,true,true]]},{attribute:f.CURRENCIES,required:true,isArray:true,requiredError:m.get("currencyError")}]})}});l.Fields=Object.freeze(f);l.States=Object.freeze(a);l.Expands=Object.freeze(e);return l});define("DS/MPFShopModel/ShopServiceModel",["DS/MPFModel/MPFModel"],function(d){var e={};var c={};var b={};var f={};e.DESCRIPTION="description";e.BACKGROUND_IMAGE="background";e.CONTRACT_DOCUMENTS="contract-documents";e.STATE="currentState";e.VISIBILITY="visibility";e.MODIFICATION_REQUEST_STATUS="modificationRequestStatus";e.NUMBER_EMPLOYEES="employeeNumber";f.MAKE="MP3DP_PrintShopService";f.ENGINEERING="MP_EngineeringShopService";f.PART_SUPPLY="MP_PartSupplyShopService";c.TO_BE_VALIDATED="TOBEVALIDATED";c.VALIDATED="VALIDATED";b.DRAFT="DRAFT";b.SUBMITTED="SUBMITTED";b.ACTIVE="ACTIVE";var a=d.extend({defaults:{invoice:false,paint:false,pickup:false,polish:false,postalDelivery:false,visibility:"Community",employeeNumber:null},setup:function(g,h){this._parent(g,h)},parse:function(g){var i;var k=["additionalEquipments","certification","skills","supportedFormats",e.NUMBER_EMPLOYEES];var j=["invoice","paint","pickup","polish","postalDelivery","shopstatus","testOrderStatus"];var h=["answeringDelay","printingDelay","turnAroundTime"];if(g.hasOwnProperty(f.MAKE)){g=g[f.MAKE]}if(g.hasOwnProperty(f.ENGINEERING)){g=g[f.ENGINEERING]}if(g.hasOwnProperty(f.PART_SUPPLY)){g=g[f.PART_SUPPLY]}for(i=0;i<k.length;i++){if(g.hasOwnProperty(k[i])&&typeof g[k[i]]==="string"){g[k[i]]=[g[k[i]]]}}for(i=0;i<j.length;i++){if(g.hasOwnProperty(j[i])&&typeof g[j[i]]==="string"){g[j[i]]=g[j[i]].toLowerCase()==="true"}}for(i=0;i<h.length;i++){if(g.hasOwnProperty(h[i])&&typeof g[h[i]]==="string"){g[h[i]]=parseInt(g[h[i]])}}delete g.products;return g},toJSON:function(){var g;var j;var l=["additionalEquipments","certification","skills","supportedFormats",e.NUMBER_EMPLOYEES];var k=["invoice","paint","pickup","polish","postalDelivery","shopstatus","testOrderStatus"];var i=["answeringDelay","printingDelay","turnAroundTime"];var h=["visibility"];g=this._parent();for(j=0;j<l.length;j++){if(this.has(l[j])){g[l[j]]=this.get(l[j])}}for(j=0;j<k.length;j++){if(this.has(k[j])){g[k[j]]=this.get(k[j])?"TRUE":"FALSE"}}for(j=0;j<i.length;j++){if(this.has(i[j])){g[i[j]]=this.get(i[j]).toString()}}for(j=0;j<h.length;j++){if(this.has(h[j])){g[h[j]]=this.get(h[j])}}return g},getBackgroundImage:function(){return this.get(e.BACKGROUND_IMAGE)},setBackgroundImage:function(g){return this.set(e.BACKGROUND_IMAGE,g)},getDescription:function(){return this.get(e.DESCRIPTION)},setDescription:function(g){return this.set(e.DESCRIPTION,g)},getState:function(){return this.get(e.STATE)},setState:function(g){return this.set(e.STATE,g)},getNumberEmployees:function(){return this.get(e.NUMBER_EMPLOYEES)},setNumberEmployees:function(g){return this.set(e.NUMBER_EMPLOYEES,g)}});a.Fields=Object.freeze(e);a.RequestStatus=Object.freeze(c);a.States=Object.freeze(b);a.Types=Object.freeze(f);return a});define("DS/MPFShopModel/ShippingOffersDataProxy",["UWA/String","DS/MPFDataProxy/DataProxy","DS/MPFOfferModel/OfferDataProxy","DS/MPFError/NotImplementedError"],function(e,b,d,a){var c=b.extend({init:function(f){var g;g=new d(f);this._parent(f,"/mdshop/shop-services/{0}/offers/shipping",g)},buildPath:function(f){return e.format(this.resourcePath,f.shopServiceId)},urlPatch:null,urlPut:a.emit,urlDelete:a.emit,urlPost:a.emit,doPatch:null,doPut:a.emit,doDelete:a.emit,doPost:a.emit});return c});define("DS/MPFShopModel/LogoModel",["DS/MPFModel/MPFModel"],function(a){var b=a.extend({setup:function(c,d){this._parent(c,d)}});return b});define("DS/MPFShopModel/LogoDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d){this._parent(d,"/mdshop/shops/{0}/logo")},urlPost:function(d){return this.connector.url(a.String.format(this.resourcePath,d.parentResourceId))},urlPatch:function(d){return this.connector.url(a.String.format(this.resourcePath,d.parentResourceId))},urlDelete:null,doPut:null,doPatch:null,doDelete:null});return c});define("DS/MPFShopModel/MediaDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,c){var b=c.extend({init:function(d){this._parent(d,"/mdshop/showcase-items/{0}/media")},urlDelete:null,urlGet:null,urlPatch:null,urlPost:function(d){return this.connector.url(a.String.format(this.resourcePath,d.parentResourceId))},urlPut:null,doDelete:null,doGet:null,doPatch:null,doPut:null});return b});define("DS/MPFShopModel/ShopStatisticsModel",["DS/MPFModel/MPFModel","UWA/Core","DS/MPFError/BadArgumentError"],function(c,d,a){var b=c.extend({defaults:function(){var e={all:"0",confirmedOrder:"0",country:"",machines:"0",materials:"0",newRequests:"0",orders:"0"};return e},setup:function(e,f){if(!d.is(f.parentResourceId,"string")){throw new a("options.parentResourceId expected")}this._type="ShopStatisticsModel";this._parent(e,f);this.setParentResourceId(f.parentResourceId)}});return b});define("DS/MPFShopModel/ShopPublicPMPDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d,e){this._parent(d,"/mdshop/shopsPMP?expand=false",e)},doPost:null,doPut:null,doPatch:null,doDelete:null});return c});define("DS/MPFShopModel/ShopStatisticsDataProxy",["UWA/String","DS/MPFDataProxy/DataProxy","DS/MPFError/NotImplementedError"],function(c,b,a){var d;d=b.extend({init:function(e,f){this._parent(e,"/me/shops/{0}/countV2",f)},buildPath:function(f,e){return c.format(this.resourcePath,f.parentResourceId)}});return d});define("DS/MPFShopModel/ShopServicesDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(a,b){var c=b.extend({init:function(d){this._parent(d,"/mdshop/shop-services")},request:function(e,d){this._parent(e,d)},urlDelete:function(d){return this.connector.url(this.delegate.resourcePath+"/"+d.get("id"))},urlPatch:function(d){if(this.delegate){return this.connector.url(this.delegate.resourcePath+"/"+d.get("id"))}else{return this._parent(d)}}});return c});define("DS/MPFShopModel/ShopShopServiceDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy","DS/MPFShopModel/ShopServicesDataProxy"],function(a,b,d){var c=b.extend({init:function(e){this._parent(e,"/mdshop/shops/{0}/shop-services",new d(e))},request:function(f,e){this._parent(f,e)},urlDelete:null,urlGet:function(e){return this.connector.url(a.String.format(this.resourcePath,e.parentResourceId||e.collection.parentResourceId))},urlPost:function(e){return this.connector.url(a.String.format(this.resourcePath,e.parentResourceId||e.collection.parentResourceId))},urlPatch:null});return c});define("DS/MPFShopModel/MeShopDataProxy",["DS/MPFDataProxy/DataProxy","DS/MPFShopModel/ShopDataProxy"],function(b,a){var c=b.extend({init:function(d){this._parent(d,"/me/shops",new a(d))},buildPath:function(){return this.resourcePath},urlGet:function(e,d){d||(d={});d.expand||(d.expand=["offers"]);return this._parent(e,d)},urlPut:b.delegate,urlPatch:b.delegate,urlDelete:b.delegate,doPut:b.delegate,doPatch:b.delegate,doDelete:b.delegate});return c});define("DS/MPFShopModel/ShopSubmitor",["UWA/Class","DS/MPFShopModel/ShopModel","DS/MPFShopModel/ShopServiceModel","DS/MPFServices/ObjectService"],function(c,g,b,f){var h=c.extend();function e(j){var i={};i[b.Fields.MODIFICATION_REQUEST_STATUS]=b.RequestStatus.TO_BE_VALIDATED;return j.savePromise(i,{patch:true})}function d(i){i.setState(g.States.SUBMITTED);return i.savePromise()}function a(i){i.setState(b.States.SUBMITTED);return i.savePromise(i.pick(b.Fields.STATE),{patch:true})}h.submit=function(j,i){f.requiredOfPrototype(j,g,"shop must be a ShopModel");f.requiredOfPrototype(i,b,"shopService must be a ShopServiceModel");return e(i).then(d.bind(null,j)).then(a.bind(null,i))};return h});define("DS/MPFShopModel/ForcedShopValidator",["UWA/Core","UWA/Class","UWA/Promise","DS/MPFServices/ObjectService","DS/MPFShopModel/ShopModel","DS/MPFShopModel/ShopServiceModel","DS/MPFModelFactory/ShopValidationFactory"],function(f,a,g,h,k,e,d){function b(l){l.set(e.Fields.MODIFICATION_REQUEST_STATUS,e.RequestStatus.VALIDATED);return l.savePromise(l.pick(e.Fields.MODIFICATION_REQUEST_STATUS),{patch:true})}function c(l){l.set(k.Fields.STATE,k.States.ACTIVE);return l.savePromise(l.pick(k.Fields.STATE),{patch:true})}function i(l){l.set(e.Fields.STATE,e.States.ACTIVE);return l.savePromise(l.pick(e.Fields.STATE),{patch:true})}var j=a.extend();j.validate=function(o,n,m){h.requiredOfPrototype(o,k,"options.shop must be a ShopModel");h.requiredOfPrototype(n,e,"options.shopService must be a ShopServiceModel");h.requiredOfPrototype(m,d,"options.shopValidationFactory must be a ShopValidationFactory");if(!f.is(o.get("id"),"string")){return g.reject("Shop must have an id. New shops cannot be validated.")}var l=m.createModel({id:o.get("id")});return l.savePromise(null,{patch:true}).then(c.bind(null,o)).then(i.bind(null,n)).then(function(){return[o,n]})};j.validateLabDetails=function(l){h.requiredOfPrototype(l,e,"shopService must be a ShopServicesModel");return b(l)};return j});define("DS/MPFShopModel/ShopCollection",["DS/MPFModel/MPFCollection","DS/MPFShopModel/ShopModel"],function(b,a){var c=b.extend({model:a,setup:function(e,d){this.constraints=d.constraints||null;this._parent(e,d)},create:function(d,e){e=e||{};e.constraints=this.constraints;return this._parent(d,e)},parse:function(d){var e=[];if(d.hasOwnProperty("shops")){d.shops.forEach(function(f){e.push(f)});return e}else{if(Object.keys(d).length===0){return e}else{return d}}}});return c});define("DS/MPFShopModel/ShopServiceCollection",["DS/MPFModel/MPFCollection","DS/MPFShopModel/ShopServiceModel"],function(c,a){var b=c.extend({model:a,setup:function(e,d){this._parent(e,d)},create:function(d,e){return this._parent(d,e||{})}});return b});