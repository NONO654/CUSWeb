define("DS/SMAProcSPUI/Utilities/ExportToExcel",[],function(){var b=function(l,r){var m="sep=,\r\n";var s="";var k;var n;var f=0;var e=0;var c;var p;var h;var g={};var d=[];var o=new RegExp("#","g");for(f=0;f<l.length;f++){g={};p=Object.keys(l[f]);for(e=0;e<p.length;e++){c=p[e];if(c.indexOf("#")===-1){c=c.replace(o,"$")}g[c]=l[f][c]}d.push(g)}p=r?r.map(function(i){return i.keyToDisplay}):Object.keys(d[0]);h=r?r.map(function(i){return i.originalKey}):Object.keys(d[0]);for(f=0;f<p.length;f++){n=String(p[f]);if(navigator.userAgent.search("Firefox")>=0){n=n.replace(o,"$")}s+='"'+n.replace(/"/g,'""')+'",'}s=s.slice(0,-1);m+=s+"\r\n";for(f=0;f<d.length;f++){s="";var q=d[f];for(k in q){if(q.hasOwnProperty(k)&&h.indexOf(k)>-1){n=String(q[k]);if(navigator.userAgent.search("Firefox")>=0){n=n.replace(o,"$")}s+='"'+n.replace(/"/g,'""')+'",'}}s=s.slice(0,-1);m+=s+"\r\n"}return m};var a={};a.exportToExcel=function(f){var c=b(f.data,f.keys);var d=new Blob([c],{type:"text/html"});if(navigator.userAgent.search("Edge")>=0||navigator.userAgent.search("Trident")>=0){window.navigator.msSaveOrOpenBlob(d,f.filename+".csv")}else{var g=document.createElement("a");var e=window.URL.createObjectURL(d);g.style.display="none";g.download=f.filename+".csv";g.href=e;document.body.appendChild(g);g.click();document.body.removeChild(g);window.URL.revokeObjectURL(e)}d=null};return a});