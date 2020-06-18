define("DS/MPFAddressConstraintsModel/AddressConstraintsDataProxy",["UWA/Core","DS/MPFDataProxy/DataProxy"],function(b,c){var a=c.extend({init:function(d){this._parent(d,"/formats/postal-addresses")},url:function(d){return this.connector.url(b.String.format(this.resourcePath,d))},request:function(e,d){this._parent(e,d)}});return a});define("DS/MPFAddressConstraintsModel/AddressConstraintsModel",["UWA/Core","UWA/String","DS/MPFModel/MPFModel","DS/MPFConstraintModel/ConstraintModel","DS/MPFAddressModel/AddressModel","DS/MPFDataProxy/NoDataProxy","i18n!DS/MPFAddressConstraintsModel/assets/nls/AddressConstraintsModel"],function(c,g,d,a,f,b,e){var h=d.extend({idAttribute:"countryCode",parse:function(k){var j=Object.keys(k)[0];var l=k[j];var i={countryCode:j};this._addIfOwnProperty(l,i,"address1",f.Fields.LINE1);this._addIfOwnProperty(l,i,"address2",f.Fields.LINE2);this._addIfOwnProperty(l,i,"address3",f.Fields.LINE3);this._addIfOwnProperty(l,i,"address4",f.Fields.LINE4);this._addIfOwnProperty(l,i,"city",f.Fields.CITY);this._addIfOwnProperty(l,i,"county",f.Fields.COUNTY);this._addIfOwnProperty(l,i,"state",f.Fields.STATE);this._addIfOwnProperty(l,i,"postalCode",f.Fields.POSTAL_CODE);this._addIfOwnProperty(l,i,"country",f.Fields.COUNTRY);return i},setup:function(i,j){this._parent(i,j)},_addIfOwnProperty:function(l,i,k,m){if(l.hasOwnProperty(k)){var j={};j[a.Fields.ATTRIBUTE]=m;j[a.Fields.PATTERN]=l[k].pattern;j[a.Fields.REQUIRED]=l[k].required;j[a.Fields.REQUIRED_ERROR]=g.ucfirst(g.format(e.get("requiredError"),e.get(m)));j[a.Fields.INVALID_ERROR]=g.ucfirst(g.format(e.get("invalidError"),e.get(m)));i[m]=new a(j,{dataProxy:b.getInstance()})}}});return h});define("DS/MPFAddressConstraintsModel/AddressConstraintsCollection",["DS/MPFModel/MPFCollection","DS/MPFAddressConstraintsModel/AddressConstraintsModel"],function(a,c){var b=a.extend({model:c});return b});