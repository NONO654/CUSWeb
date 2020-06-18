define("DS/ENOCharacteristicsWebApp/controls/ExportCharacteristics",["UWA/Core","DS/Controls/Abstract","i18n!DS/ENOCharacteristicsWebApp/assets/nls/ENOCharacteristicsWebAppNLS","DS/ENOCharacteristicsWebApp/utils/Constants"],function(d,c,b,a){this.ExportUtil=d.Class.singleton({init:function(e){return this},downloadVisibleContentAsCSV:function(g){var m,j,k,o,f=[],r=g.mViewCharacteristics.getManager(),s=r.getNumberOfRows(),y="\r\n";o="\ufeff";var w=[];r.options.columns.forEach(function(C,B){if(C.isVisible!=undefined&&C.isVisible){w.splice(B,0,C)}});w.forEach(function(C,B){f[B]=C.dataIndex});var z=",";var h="";var t=1;if(g.mIsConsolidatedView===true){h=b.Item+z}else{if(g.mIsConsolidatedView!==true){h="";t=f.indexOf("charCategory")+1}}o=o+'"'+b.Level+'"'+z+h+'"'+b.Category+'"'+z+'"'+b.Mandatory+'"';var e=o.split(",");e.forEach(function(C,B){e[B]=e[B].split('"').join("")});e=e.concat(f.slice(t,f.length));for(j=t;j<w.length;j++){o+=z+'"'+w[j].text+'"'}o+=y;for(m=0;m<s;m++){k=r.getTreeNodeModelFromRowID(m);if(k.options.grid.modelType==="Characteristics"){if(g.mIsConsolidatedView!==true){o+=k._nodeDepth-1}else{o+=k._nodeDepth}for(j=1;j<e.length;j++){if(e[j]===b.Item){o+=z+'"'+k.getParent().getParent().options.label+'"'}else{if(e[j]===b.Category){o+=z+'"'+k.options.grid.categoryName+'"'}else{if(e[j]===b.Mandatory){if(k.options.grid.mandatoryCharacteristic==="Yes"){o+=z+'"'+b.Yes+'"'}else{o+=z+'" "'}}else{if(e[j]==="testMethods"){var p=k.options.grid[e[j]];var u="";for(i=0;i<p.length;i++){u+=p[i].name+"|"}o+=z+u}else{var x=k.options.label[e[j]];if(x.contains('"')){x=x.replace('"','"""');o+=z+'"'+x}else{o+=z+'"'+x+'"'}}}}}}o+=y}}var q=document,A=q.createElement("a");var v=g.mRootItem.mTreeNodeModel.options.grid;var n=v.Title+"_"+v.current+"_Characteristics_"+(new Date()).toString().split(" ").splice(1,4).join(" ")+".csv";if(document.documentMode||(!parent.isIE&&!!window.StyleMedia)){var l=[o];blobObject=new Blob(l);window.navigator.msSaveOrOpenBlob(blobObject,"Characteristics"+(new Date()).toString().split(" ").splice(1,4).join(" ")+".csv")}else{if("download" in A){A.href="data:text/csv,"+encodeURIComponent(o);A.download=n;A.style.cssText="visibility: hidden";q.body.appendChild(A);setTimeout(function(){A.click();q.body.removeChild(A)},66)}}}});return ExportUtil});