  /*
        * Filter a table, with a letter specified in an area which id = FilterArea.
        * and the Table ID = TableToFilter
        */
       function filterStrings(){
           var doc = document.getElementById("FilterArea").value;
		   var regex = /\*/g;
		   doc = doc.replace(regex,".*");
           var row= document.getElementById("TableToFilter").rows;
           for (var i = 1 ; i < row.length ; i++){
                row[i].style.display = "";
            }
           for (var i = 1 ; i < row.length ; i++){
                var nom = row[i].cells[0].innerHTML;
                if (nom.match(doc) == null){
                    row[i].style.display = "none";
                }
           }
       }



	    function checkID(elementID){
            var docID = document.getElementById(elementID).value;

            if (docID != ""){
                document.getElementById("imageChecked").src= "images/iconStatusComplete.gif" ;
            }else{
                document.getElementById("imageChecked").src= "images/iconStatusError.gif" ;
            }
        }


	/*
	* Hide a div id given in parameter.
	*/
    function hideit(hidethisone){
            var o = document.getElementById(hidethisone);
            o.style.display = 'none';
     }

	/*
	* Add a div to give the error message
	* Call the hide function after 5s
	*/
    function setTime(message){
          document.write("<div class=\"divPlus\" id=\"hidethisone\"  style=\"z-index:1;_\"><table width=\"100%\"><tr style=\"width:100%\"><td style=\"color:white ; font-style:italic; background-color: #2f4d75; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt\" >"+message+"</td><td align='right'><img src='images/iconActionDelete.gif' onclick='hideit(\"hidethisone\")'></td></tr></table></div>");
      //     setTimeout("hideit('hidethisone')",30000); // 30 seconds after user (re)load the page
        }


	/*
         * Replace in a String all occurence of stringTofind with stringToReplace
         * return the new String
         **/
    function ReplaceAllOccurence(Source,stringToFind,stringToReplace){

        var temp = Source;
        var index = temp.indexOf(stringToFind);
        while(index != -1){
            temp = temp.replace(stringToFind,stringToReplace);
            index = temp.indexOf(stringToFind);
        }
        return temp;
    }


	/*
	*	Submit the form
	*/
	function sendToPage(){
          var res = getSelectedCheckbox();
          document.getElementById("HiddenElement").innerHTML=res;
         // alert(document.getElementById("HiddenElement").innerHTML);
          document.getElementById("submitForm").submit();

      }


	/*
	* Get all input in the page
	* return Selected input ids seperated by ",,"
	*/
	function getSelectedCheckbox(){
          var elements = document.getElementsByTagName("input");
          var selectToSend = "";

          for(var i = 0 ; i < elements.length ; i++){
              if ((elements[i].checked) && (elements[i].type=="checkbox") && !(elements[i].disabled=="true")){
                selectToSend = selectToSend+elements[i].id+",,";
              }
          }
          return selectToSend;
     }

     function getSelectedLicencesCheckbox(){
          var elements = document.getElementsByTagName("input");
          var selectToSend = "";

          for(var i = 0 ; i < elements.length ; i++){
		 if ((elements[i].checked)&& (elements[i].id.indexOf("lic_") == 0)  && (elements[i].type=="checkbox") && !(elements[i].disabled=="true")){
                var textId =  elements[i].id.substring(0,elements[i].id.indexOf("_chk"));
                var selectId= textId + "_selected";

                // JIC 15:03:03 Removed Casual Hour value
                selectToSend =selectToSend+elements[i].id+"!!"+elements[i].value+",,";
              }
          }
          return selectToSend;
     }

	/*
	* Get All unchecked "option" in a set of checkbox.
	*/
	function RemoveCheckBox(boxName){
			var found = false;
			var txt = document.getElementById("ctx2Stock").innerHTML;
			if(txt!=null && txt!="" && txt.indexOf(boxName)>-1) {
				found = true;
				var removeSelect = document.getElementById("removeSelect").innerHTML;
				if (document.getElementById(boxName).checked==false && removeSelect.indexOf(boxName)==-1) {
					removeSelect = removeSelect + ",,"+boxName;
				} else if(document.getElementById(boxName).checked==true && removeSelect.indexOf(boxName)>-1) {
					removeSelect = ReplaceAllOccurence(removeSelect,",,"+boxName,"");
				}
				document.getElementById("removeSelect").innerHTML = removeSelect;
			}
            if (found==false) {
				var HiddenElement = document.getElementById("HiddenElement").innerHTML;
                if (document.getElementById(boxName).checked==true && HiddenElement.indexOf(boxName)==-1) {
                	HiddenElement = HiddenElement + ",,"+boxName;
				} else if(document.getElementById(boxName).checked==false && HiddenElement.indexOf(boxName)>-1) {
					HiddenElement = ReplaceAllOccurence(HiddenElement,",,"+boxName,"");
                }
				document.getElementById("HiddenElement").innerHTML = HiddenElement;
			}
      }

	/*
	*	Get an XMLHTTPRequest Object
	*	return the XMLHTTPRequest
	*/
	function getXMLHTTPObject(){
            var xmlhttp;
            if (window.XMLHttpRequest)
            {
                 // code for IE7+, Firefox, Chrome, Opera, Safari
                xmlhttp=new XMLHttpRequest();
            }
            else if (window.ActiveXObject)
            {
                // code for IE6, IE5
                xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
            }
            else
            {
                alert("Your browser does not support XMLHTTP!");
            }
            return xmlhttp;
    }

	/*
 * Submits a XMLHttpRequest
 *
 * @param strURL        the request URL
 * @param strSubmit     the request content
 * @param strResultFunc the callback function to process response
 */
 function xmlreq(strURL, strSubmit, strResultFunc, req)
{
    xmlHttpReq = null;
	var IE=true;
    // Mozilla/Safari
    if (window.XMLHttpRequest) {
        xmlHttpReq = new XMLHttpRequest();
		if(xmlHttpReq.overrideMimeType){
			xmlHttpReq.overrideMimeType('text/xml');
			IE=false;
		}
    }
    // IE
    else if (window.ActiveXObject) {
        try{
            xmlHttpReq = new ActiveXObject("MSXML2.XMLHTTP");
        } catch(err){
            try{
                xmlHttpReq = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(err){}
        }
    }
    if (xmlHttpReq == null) {
        alert('Sorry, your browser does not support XML HTTP Request!');
        return null;
    }
    xmlreqs[req] = xmlHttpReq;
	if (IE){
        //LXM : added a GET method, Post do not work fine with IE/AIX6.1

        // JIC 2013:04:17 IR IR-205189V6R2014: Added test on strSubmit
        var URL = strURL;
        // Append Submit string when not empty
        if (strSubmit != null && strSubmit != ""){
            URL = URL+"?"+strSubmit;
        }
        xmlHttpReq.open('GET', URL, true);
        xmlHttpReq.onreadystatechange = strResultFunc;
        xmlHttpReq.send(null);

    }else{
        xmlHttpReq.open('POST', strURL, true);
        xmlHttpReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xmlHttpReq.onreadystatechange = strResultFunc;
        xmlHttpReq.send(strSubmit);
    }
	}


   /*Licences*/


var nlsINFO_SELECTALL = "-- Select all";
var nlsINFO_AVAILABLE = "-- Available";
var nlsINFO_UNAVAIL   = "-- Unavailable";
var nlsINFO_UNAVAIL_WARN      = "-- Unavailable warning";
var nlsSECTION_AVAIL          = "-- Available";
var nlsSECTION_UNAVAIL_RICH   = "-- Unavailable rich client";
var nlsSECTION_UNAVAIL_SERVER = "-- Unavailable server";

if(!Array.indexOf){
  Array.prototype.indexOf = function(obj){
   for(var i=0; i<this.length; i++){
    if(this[i]==obj){
     return i;
    }
   }
   return -1;
  }
}

  function $(id)
  {
      return document.getElementById(id);
  }

  function sections(containerId)
  {
      var container = $(containerId);
      var nodes = container.childNodes;
      var nb = 0;
      for (var i=0; i<nodes.length; i++) {
          if (nodes[i].nodeType==1) nb++;
      }
      return nb;
  }

  function toggleSection(elemid)
  {
      var body = $(elemid + "_body");
      var collapsed = (body.style.display == 'none');
      body.style.display = collapsed ? '' : 'none';
      var img = $(elemid + "_img");
      if (img != undefined) {
          img.src = "images/" + (collapsed ? 'iconSectionCollapse.gif' : 'iconSectionExpand.gif');
      }
      // in case of collapsed, disable section check box, enable otherwise
      var chk = $(elemid + "_chk");
      chk.disabled = !collapsed;
  }
  function toggleCheck(chk,elemid)
  {
    var t = $(elemid);
    if (!t) return;
    var nb_rows = t.rows.length;
    for (var ir=0; ir<nb_rows; ir++) {
        var row = t.rows[ir];
        if (row.style.display == '') {
            // row is visible: (un)select
            var row_chk = row.cells[1].childNodes[0];
            if (row_chk.checked != chk.checked) {
                // not same checkbox value b/w row checkbox and section checbox : change it (simulate clic)
                row_chk.checked = chk.checked;
                clic(row_chk);
            }
        }
    }
  }
  // JIC 05:06:05: IR IR-375010-3DEXPERIENCER2015x: Added function "toggleCheckLicense"
  function toggleCheckLicense(chk,elemid)
  {
    var t = $(elemid);
    if (!t) return;
    var nb_rows = t.rows.length;
    for (var ir=0; ir<nb_rows; ir++) {
        var row = t.rows[ir];
        if (row.style.display == '') {
            // row is visible: (un)select
            var row_chk = row.cells[1].childNodes[0];
            if (row_chk.checked != chk.checked && row_chk.disabled != true) {
                // not same checkbox value b/w row checkbox and section checbox : change it (simulate clic)
                row_chk.checked = chk.checked;
                clic(row_chk);
            }
        }
    }
  }
  function setAvailable(elem)
  {
      elem.src = 'images/iconLicenseAvailable.gif';
      var div_txt = $(elem.id+"_txt");
        if (div_txt != undefined) {
        div_txt.style.color = 'black';
        }
      //elem.title = "Available on license server";
      elem.title = nlsINFO_AVAILABLE;
  }
  function setUnavailable(img)
  {
    var div_txt = $(img.id+"_txt");
    if (div_txt != undefined) {
        div_txt.style.color = 'gray';
    }
    var checkbox = $(img.id+"_chk");
    if (checkbox != undefined && checkbox.checked) {
        img.src = 'images/iconLicenseError.gif';
        //img.title = "<u>Warning</u>: Unavailable on license server!";
        img.title = nlsINFO_UNAVAIL_WARN;
    }
    else {
        img.src = 'images/iconLicenseUnavailable.gif';
        //img.title = "Unavailable on license server";
        img.title = nlsINFO_UNAVAIL;
    }
  }
/*  function clic(elem)
  {
      var id = elem.id.substring(0,elem.id.length-4);
      var img = $(id);
      if (!elem.checked) {
          // now unchecked
          // checking whether there was a 'warning' msg
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseError.gif')>=0) {
                  // there was a warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
      else {
          // now checked
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseUnavailable.gif')>=0) {
                  // warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
  }*/
  function clic(elem)
  {
      var id = elem.id.substring(0,elem.id.length-4);
      var img = $(id);
      if (!elem.checked) {
          // now unchecked
          // checking whether there was a 'warning' msg
          // JIC 15:04:20 Removed Casual combo code
          /*
          var sel = $(id+"_sel");
          sel.style.visibility = "hidden";
          */
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseError.gif')>=0) {
                  // there was a warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
      else {
          // JIC 15:04:20 Removed Casual combo code
          /*
          var sel1 = $(id+"_sel");
          sel1.style.visibility = "visible";
          */
          // now checked
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseUnavailable.gif')>=0) {
                  // warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
  }

  function license_filter(elem,tables)
{
    var filter = elem.value.toLowerCase();
    if (filter != prev_filter_lic) {
        if (filter.length>0) {
            // start filtering
            //alert('filter='+filter);
            filter_lic = true;
            for (var it=0; it<tables.length; it++) {
                var t = $(tables[it]);
                if (!t) continue;
                var nb_rows = t.rows.length;
                for (var ir=0; ir<nb_rows; ir++) {
                    var row = t.rows[ir];
                    // JIC 2015:05:29 IR IR-374831-3DEXPERIENCER2015x: Added test on cells & nodes
                    if (row.cells.length>=5) {
                        var cell = row.cells[4];
                        if (cell.childNodes.length>=1) {
                            var childNode = cell.childNodes[0];
                            if (childNode.childNodes.length>=1) {
                                var licName = childNode.childNodes[0].data.toLowerCase();
                                if (licName.indexOf(filter)<0) {
                                    // a filtrer
                                    row.style.display = 'none';
                                }
                                else {
                                    // a (eventuellement) reafficher
                                    row.style.display = '';
                                }
                            }
                        }
                    }
                }
            }
        }
        else if (filter.length<=0) {
            // no more filter
            if (filter_lic) {
                //alert('no more filter');
                filter_lic = false;
                for (var it=0; it<tables.length; it++) {
                    var t = $(tables[it]);
                    if (!t) continue;
                    var nb_rows = t.rows.length;
                    for (var ir=0; ir<nb_rows; ir++) {
                        var row = t.rows[ir];
                        var licName = row.cells[4].childNodes[0].childNodes[0].data.toLowerCase();
                        row.style.display = '';
                    }
                }
            }
        }
        prev_filter_lic = filter;
    }
}


function beginLicSection(section, title) {
    var html = "<div id=\"lics_"+section+"\" class=\"licHeader\">\n";
    html    += "  <table class=\"titleLic\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n";
    html    += "    <colgroup>\n";
    html    += "      <col class=\"tableLicCheckbox\" />\n";
    html    += "      <col class=\"tableLicCheckbox\" />\n";
    html    += "      <col class=\"tableLicTitle\" />\n";
    html    += "    </colgroup>\n";
    html    += "    <tr>\n";
    html    += "      <td onclick=\"toggleSection('lics_"+section+"');\">\n";
    html    += "        <img src=\"images/iconSectionExpand.gif\" id=\"lics_"+section+"_img\">";
    html    += "      </td>\n";
    html    += "      <td>\n";
    html    += "        <input id=\"lics_"+section+"_chk\" type=\"checkbox\" onclick=\"toggleCheck(this,'lics_"+section+"_table');\" title=\""+nlsINFO_SELECTALL+"\" disabled=\"disabled\">\n";
    html    += "      </td>\n";
    html    += "      <td>"+title+"</td>\n";
    html    += "    </tr>\n";
    html    += "  </table>\n";
    html    += "</div>\n";
    html    += "<div id=\"lics_"+section+"_body\" width=\"100%\" style=\"display:none;\">\n";
    html    += "  <table class=\"titleLic\" id=\"lics_"+section+"_table\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">\n";
    html    += "    <colgroup>\n";
    html    += "      <col class=\"tableLicMargin\" />\n";
    html    += "      <col class=\"tableLicCheckbox\" />\n";
    html    += "      <col class=\"tableLicCasual\" />\n";
    html    += "      <col class=\"tableLicAvailability\" />\n";
    html    += "      <col class=\"tableLicTitle\" />\n";
    html    += "    </colgroup>\n";
    return html;
}


// JIC 15:04:21 Added license check information
function addLicLine(id, title, state, nls_state, checked) {
    var html = "    <tr>\n";
    html    += "      <td></td>\n";
    // JIC 15:04:15 Added specific case for licenses IFW and CSV
	// ALU4 17:08:24 IR-536079-3DEXPERIENCER2017x IFW and CSV are selected by default. This IR consists in making CSV optional.
    if (id == "IFW") {
        html += "  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\" checked=\"checked\" disabled=\"disabled\"></td>";
    }
    else {
        if (checked == true) {
            html += "  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\" checked=\"checked\"></td>";
        }
        else {
            html += "  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\"></td>";
        }
    }
    // JIC 15:03:06 Removed Casual Hour combo
    html    += "      <td/>";
    html    += "      <td><img src=\"images/iconLicense"+state+".gif\" id=\"lic_"+id+"\" title=\""+nls_state+"\" style=\"cursor:pointer\"></td>";
    html    += "      <td><div id=\"lic_"+id+"_txt\">"+title+"</div></td>\n";
    html    += "    </tr>\n";
    return html;
}

 function updateLicenseImage(idImage,elem){
             var casualHours = elem.options[elem.options.selectedIndex].value;
             var elemImage = $("lic_"+idImage);

             var LicensePair = xmlLicences.split(";;");
             var LicenseName = idImage +"||"+casualHours;
             var ItIsOK = false;
             for (var i = 0 ; i < LicensePair.length ; i++){
                 if(LicensePair[i] == LicenseName){
                     setAvailable(elemImage);
                     ItIsOK=true;
                 }
             }
             if(!ItIsOK)setUnavailable(elemImage);
}


function endLicSection() {
    return "    </table>\n  </div>\n";
}


function listLicenses(div, name, title, xmlNodes, state, nls_state)
{
    if (!xmlNodes || xmlNodes.length==0) return;
    //var xmlNode = xmlNodes[0];
    var nb = xmlNodes.length;
    if (nb==0) return;
    var html = beginLicSection(name, title);
    try {
        for (var i=0; i<nb; i++) {
            var node = xmlNodes[i];
            // JIC IR IR-270354V6R2014x: Replaced indexes (0, 1) with actual attribute names ("id", "title")
            var lic_name = node.attributes.getNamedItem("id").value;
            var lic_title = lic_name;
            try {
                lic_title = node.attributes.getNamedItem("title").value;
            } catch(err) {}
            // JIC 15:04:21 Added license check information
            var lic_checked = false;
            try {
                lic_checked = node.attributes.getNamedItem("checked").value == "true" ? true : false;
            } catch(err) {}
            html += addLicLine(lic_name, lic_title, state, nls_state, lic_checked);
        }
    } catch (ex) {
        html += "<tr><td/><td/><td>Exception: "+ex+"</td>";
    }
    html += endLicSection();
    div.innerHTML += html;
}


// JIC 15:04:15 Added function listAssignedLicenses
function listAssignedLicenses(div, xmlNodes)
{
    if (!xmlNodes || xmlNodes.length==0) return;
    //var xmlNode = xmlNodes[0];
    var nb = xmlNodes.length;
    if (nb==0) return;
    var html = "";
    html += "<table class=\"titleLic\" id=\"lics_section1_table\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">";
    html += "<colgroup>";
    html += "<col class=\"tableLicMargin\" />";
    html += "<col class=\"tableLicCheckbox\" />";
    html += "<col class=\"tableLicAvailability\" />";
    html += "<col class=\"tableLicTitle\" />";
    html += "</colgroup>";

    try {
        for (var i=0; i<nb; i++) {
            var node = xmlNodes[i];
            var lic_name = node.attributes.getNamedItem("id").value;
            var lic_title = lic_name;
            try {
                lic_title = node.attributes.getNamedItem("title").value;
            } catch(err) {}
            var state = node.attributes.getNamedItem("state").value;
            // JIC 15:04:21 Added license check information
            var lic_checked = false;
            try {
                lic_checked = node.attributes.getNamedItem("checked").value == "true" ? true : false;
            } catch(err) {}
            html += addLicLine(lic_name, lic_title, state, state == "Available" ? nlsINFO_AVAILABLE : nlsINFO_UNAVAIL, lic_checked);
        }
    } catch (ex) {
        html += "<tr><td/><td/><td>Exception: "+ex+"</td>";
    }
    html += "</table>";
    div.innerHTML = html;
}


function getLicensesResponse()
{
    var resp = xmlreqs[1];
    if (resp.readyState == 4)
    {
        var licenses = new Array();
        if (resp.status == 200)
        {
            // server answered correctly
            var xmldoc = resp.responseXML;
            var root_node = xmldoc.getElementsByTagName('licenses')[0];
            if (root_node) {
                var status = xmldoc.getElementsByTagName('status')[0].firstChild.data;
                //alert('Le serveur a repondu['+status+'] = '+resp.responseXML.documentElement);
                if (status) {
                    if (status=="OK") {
                        var xmlLicNodes = xmldoc.getElementsByTagName('lic');
                        if (xmlLicNodes && xmlLicNodes.length>0) {
                            for (var n=0; n<xmlLicNodes.length; n++) {
                                var lic = xmlLicNodes[n].attributes[0].value;
                                licenses[licenses.length]=lic;
                            }
                        }
                        // JIC 15:04:15 Added update of assigned licenses
                        var newSection = $('lics_section1_body');
                        newSection.style.display = '';
                        while (newSection.hasChildNodes()) {
                            newSection.removeChild(newSection.firstChild);
                        }
                        var xmlRootAssigned = xmldoc.getElementsByTagName('assigned');
                        listAssignedLicenses(newSection, xmlRootAssigned);

                        //JPA+
                        // expand section2
                        //toggleSection('lics_section2');
                        // show section3
                        newSection = $('lics_section3_container');
                        newSection.style.display = '';
                        // JIC 15:04:09 Added section clean-up
                        while (newSection.hasChildNodes()) {
                            newSection.removeChild(newSection.firstChild);
                        }
                        var xmlRootAvail         = xmldoc.getElementsByTagName('available');
                        var xmlRootUnavailRich   = xmldoc.getElementsByTagName('unavail_rich');
                        var xmlRootUnavailServer = xmldoc.getElementsByTagName('unavail_server');
                        listLicenses(newSection, "Available",     nlsSECTION_AVAIL,          xmlRootAvail,         "Available",   nlsINFO_AVAILABLE);
                        listLicenses(newSection, "UnavailRich",   nlsSECTION_UNAVAIL_RICH,   xmlRootUnavailRich,   "Unavailable", nlsINFO_UNAVAIL);
                        listLicenses(newSection, "UnavailServer", nlsSECTION_UNAVAIL_SERVER, xmlRootUnavailServer, "Unavailable", nlsINFO_UNAVAIL);
                        //JPA-
                    }
                    else {
                        // exception raised back
                        var xmlException = xmldoc.getElementsByTagName('exception');
                        if (xmlException && xmlException.length>0) {
                            alert("Exception raised by server: "+xmlException[0].firstChild.data);
                        }
                    }
                    //JPA+
                        // hide "working..." section (section0)
                        var workingSection = $('lics_section0_container');
                        workingSection.style.display = 'none';
                    //JPA-
                }
            }
            else {
             //   alert('Le serveur a repondu, mais le stream est invalide');
            }
        }
       // else alert('CB: answered, but status is not OK ='+resp.status);
        //
        var images = document.images;
        for (var i=0; i<images.length; i++) {
          var img = images[i];
          if (img.id != undefined) {
              if (img.id.substring(0,4) == "lic_") {
                  var lic_id = img.id.substring(4);
                  if (licenses!=null && licenses.indexOf(lic_id) > -1) {
                      setAvailable(img);
                  }
                  else {
                      setUnavailable(img);
                  }
              }
          }
        }
    }
    HideLoading();
}



/* Add options to a predefined select
*   selectName :    id of the select section
*   req :           the http request to treat
*   tagName :       Name of the tag given back by the httprequ
*   imageName :     Name of the loading image : if there is no image, imageName = ""
*/
function addOptionsToSelect(selectName,req,tagName,imageName,blank,sizeIn){
               document.getElementById(selectName).style.display = '';
               if(imageName != "")document.getElementById(imageName).style.display = 'none';

               var response = req.responseXML.getElementsByTagName(tagName);
               if (sizeIn == null) sizeIn=12;

               if(blank == "" || blank == null){
                 if(response.length < sizeIn ){document.getElementById(selectName).size=response.length+1;}else{
                    document.getElementById(selectName).size=sizeIn;
                }
               }else{
                   if(response.length < sizeIn ){document.getElementById(selectName).size=response.length;}
                   else{
                       document.getElementById(selectName).size=sizeIn;
                   }
               }

				var items = [];
                for(var i = 0 ; i < response.length ; i++ ){
                    if( (response[i].firstChild != null)  ) {
                        // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                        //items.push(response[i].firstChild.data);
                        var childNodes = response[i].childNodes;
                        var data = ""
                        for (var j = 0; j < childNodes.length; j++)
                        {
                            data = data + childNodes[j].data;
                        }
                        items.push(data);
					}
				}
				items.sort();
                for(var j = 0; j < items.length ; j++ ){
					var nouvel_element = new Option(items[j],items[j],false,true);
                    nouvel_element.id=items[j];
                    nouvel_element.selected=false;
                    document.getElementById(selectName).options[document.getElementById(selectName).length] = nouvel_element;
                }
         }

function addOptionsToSelectWithoutDoublons(selectName,req,tagName,imageName,sizeIn){
               document.getElementById(selectName).style.display = '';
               if(imageName != "")document.getElementById(imageName).style.display = 'none';

               var alreadyDone ="";
               for (var j = 1; j < document.getElementById(selectName).length ; j++){
                   alreadyDone= alreadyDone + document.getElementById(selectName).options[j].value+";;";
               }

               var response = req.responseXML.getElementsByTagName(tagName);
                if (sizeIn == null) sizeIn=12;

               if(response.length < sizeIn ){document.getElementById(selectName).size=response.length+1;}else{
                    document.getElementById(selectName).size=sizeIn;
                }
                for(var i = 0 ; i < response.length ; i++ ){
                    if( (response[i].firstChild != null)  ) {
                        if(alreadyDone.indexOf(response[i].firstChild.data+";;") == -1){
                            alreadyDone=alreadyDone+response[i].firstChild.data+";;";
                        var nouvel_element = new Option(response[i].firstChild.data,response[i].firstChild.data,false,true);
                        nouvel_element.id=response[i].firstChild.data;
                        nouvel_element.selected=false;
                        document.getElementById(selectName).options[document.getElementById(selectName).length] = nouvel_element;
               }
           }
                }
         }


 function addFooter(iFunction, iImage, iLabel,iTitle, iFunction2, iImage2, iLabel2,iTitle2,iFunction3, iImage3, iLabel3,iTitle3,iDisplay,iFunction4, iImage4, iLabel4,iTitle4){

     if (iDisplay == null)iDisplay = "block";
     document.write("<div id=\"divPageFoot\" style=\"display :"+iDisplay+"\"><table><tr>");
     document.write("<td class=\"functions\"></td>");
     document.write("<td class=\"buttons\">");
     document.write("<table><tr>");
     document.write("<td><a title=\""+iTitle+"\" href=\""+iFunction+"\"><img title=\""+iTitle+"\" border=\"0\" alt=\""+iLabel+"\" src=\""+iImage+"\"></a>");
     document.write("</td><td><a title=\""+iTitle+"\" href=\""+iFunction+"\" class=\"button\">"+iLabel+"</a>");
     document.write("</td>");
     if (iFunction2 != null){
         document.write("<td><a title=\""+iTitle2+"\" href=\""+iFunction2+"\"><img title=\""+iTitle2+"\" border=\"0\" alt=\""+iLabel2+"\" src=\""+iImage2+"\"></a>");
         document.write("</td><td><a title=\""+iTitle2+"\" href=\""+iFunction2+"\" class=\"button\">"+iLabel2+"</a>");
         document.write("</td>");
     }
     if (iFunction3 != null){
         document.write("<td><a title=\""+iTitle3+"\" href=\""+iFunction3+"\"><img title=\""+iTitle3+"\" border=\"0\" alt=\""+iLabel3+"\" src=\""+iImage3+"\"></a>");
         document.write("</td><td><a title=\""+iTitle3+"\" href=\""+iFunction3+"\" class=\"button\">"+iLabel3+"</a>");
         document.write("</td>");
     }
     if (iFunction4 != null){
         document.write("<td><a title=\""+iTitle4+"\" href=\""+iFunction4+"\"><img title=\""+iTitle4+"\" border=\"0\" alt=\""+iLabel4+"\" src=\""+iImage4+"\"></a>");
         document.write("</td><td><a title=\""+iTitle4+"\" href=\""+iFunction4+"\" class=\"button\">"+iLabel4+"</a>");
         document.write("</td>");
     }
     document.write("</tr></table></td></tr></table></div>");
 }

function addHeader(iImage,iTitle){
    document.write("<div class=\"headerVPLM\" style=\"height : 5%\">");
    document.write("<img src="+iImage+">"+iTitle+"<hr></div>");
}



function  addMiddle(iFrameID,iFrameSrc,iImage){
    document.write("<div style=\"height:85%\">");
    if (iImage != ""){
        document.write("<img id=\"imageWaiting\"  src=\""+iImage+"\">");
    }
    document.write("<iframe style=\"margin-top: 4%;border:0px\" width=\"100%\" height=\"98%\" id=\""+iFrameID+"\" src=\""+iFrameSrc+"\"></iframe>");
    document.write("</div>");
}

function addReturnMessage(){
    document.write("<div style=\"background-color: #2f4d75; color:#990000 ; font-style:italic;  font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt;  display: none ;   width:10%;   position : absolute; z-index:1;right: 3px\"  id=\"hidethisone\" >");
    document.write("<table width=\"100%\"><tr style=\"width:99%\"><td align=\"right\">");
    document.write("<img src=\"images/iconActionDelete.gif\" onclick=\"javascript:hideit('hidethisone')\"></td></tr>");
    document.write("<tr><td id=\"messageError\" style=\"color:white; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt\">");
    document.write("</td></tr></table></div>");

}



function addTransparentLoading(iText,iDisplay){
    if (iDisplay == "display"){
    document.write("<div class=\"transparencyTotal\" id=\"loading\" style=\"z-index:1; position:absolute\">");
    }else{
        document.write("<div class=\"transparencyTotal\" id=\"loading\" style=\"z-index:1; display: none; position:absolute\">");
    }
    document.write("<table width=\"100%\" style=\"height : 100%\"><tr valign=\"middle\" align=\"middle\">");
    document.write("<td style=\"color:#990000 ; font-style:italic; font-family: Arial, Helvetica, Sans-Serif ; font-weight: bold; font-size: 10pt; letter-spacing: 1pt\">");
    document.write("<img src=\"images/iconParamProgress.gif \"></td></tr></table></div>");
}

//ZUR R211
function addTransparentLoadingInSession(iDisplay, iId)
{
	if (iDisplay == "display")
		document.write('<div class=\"transparencyLoadingWait\" id=\"'+iId+'\" style=\"z-index:1; position:absolute; height:100%\">');
	else
		document.write('<div class=\"transparencyLoadingWait\" id=\"'+iId+'\" style=\"z-index:1; display:none; position:absolute\">');

	document.write("<table width=\"100%\" style=\"height:100%; align:center \"><tr height=\"100%\" align=\"center\" valign=\"center\">");
	document.write("<td style=\"width:10%\"><img src=\"images/iconParamProgress.gif \"></td></tr></table></div>");
}

/*  Function : Adding a cell in a row
 *  iRowWhereToAddCell : Row in wich we need to add the Cell
 *  iCellClass : The css class name of the cell
 *  iCellIndexInTheRow : the index of the cell in the row
 *  iCellInnerHTML : the innerHTML of the cell. If the cell need to be blank, do not valuate this attribute
 *  @return : the new cell node created and added to the row
 *   */
function addCellInARow(iRowWhereToAddCell, iCellClass, iCellIndexInTheRow,iCellInnerHTML){
    var newCell = iRowWhereToAddCell.insertCell(iCellIndexInTheRow);
    newCell.className=iCellClass;
    if( (iCellInnerHTML != null)  ){
        newCell.innerHTML=iCellInnerHTML;
    }
    return newCell;
}

/*  Function : Adding a cell in a row with a text input in the cell
 *  iRowWhereToAddCell : Row in wich we need to add the Cell
 *  iCellClass : The css class name of the cell
 *  iCellIndexInTheRow : the index of the cell in the row
 *  iCellInnerHTML : the innerHTML of the cell. If the cell need to be blank, do not valuate this attribute
 *  iInputId : Id of the text input
 *  iInputClass : css class of the input parameter
 *  iInputSize : size of the input parameter
 *  iInputMax : MaxLength of the input parameter
 *   */
function addCellInARowWithTextInput(iRowWhereToAddCell, iCellClass, iCellIndexInTheRow,iCellInnerHTML,iInputId,iInputClass,iInputSize,iInputMax){
    var newCell = addCellInARow(iRowWhereToAddCell,iCellClass,iCellIndexInTheRow,iCellInnerHTML);
    var element = document.createElement('input');
    element.type = 'text';
    element.value = "";
    element.size = iInputSize;
    element.maxLength = iInputMax;
    element.id = iInputId;
    element.className = iInputClass;
    newCell.appendChild(element);
}




function initAjaxCall(Source,Solution,Destination,Method,Filter,methodReturnName,reqNum){
        var dest = "source="+Source+"&Solution="+Solution+"&Destination="+Destination+"&Method="+Method+"&Filter="+encodeURIComponent(Filter);
        xmlreq("emxPLMOnlineAdminAjaxResponse.jsp",dest,methodReturnName,reqNum);
}

function HideLoading(){
    // JIC 15:04:23 Added test on "loading" element
    if (document.getElementById("loading") != null) {
        document.getElementById("loading").style.display = "none";
    }
}


function DisplayLoading(){
    // JIC 15:04:23 Added test on "loading" element
    if (document.getElementById("loading") != null) {
        document.getElementById("loading").style.display = "block";
    }
}

//function hasSpecialChar(stringToCheck){
//            if ( (stringToCheck.indexOf(",") > -1 ) || (stringToCheck.indexOf("\"") > -1 ) || (stringToCheck.indexOf("\\") > -1 ) || (stringToCheck.indexOf("/") > -1 ) || (stringToCheck.indexOf(":") > -1 ) || (stringToCheck.indexOf("*") > -1 ) || (stringToCheck.indexOf("?") > -1 )|| (stringToCheck.indexOf("<") > -1 )|| (stringToCheck.indexOf(">") > -1 )|| (stringToCheck.indexOf("|") > -1 )|| (stringToCheck.indexOf("#") > -1 ) )
//   			 return true;
//                         return false;
//}

function hasSpecialChar(stringToCheck, checkDot){
	var re = checkDot ? /[\\*$?"',;\n\r.]/ : /[\\*$?"',;\n\r]/;
	return re.test(stringToCheck);
}

var emxUIAdminConsoleUtil = {
		FORBIDDEN_CHARACTERS : '\\*$?"\',;\\n\\r',
		FORBIDDEN_CHARACTERS_WITH_DOT : '\\*$?"\',;\\n\\r.'
};
