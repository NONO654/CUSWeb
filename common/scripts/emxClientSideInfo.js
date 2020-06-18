/*!================================================================
*  JavaScript Client Side Info Component
*  emxClientSideInfo.js
*  Version 1.0
*  Requires: emxUICore.js
*  Last Updated: 29-July-04, John M. Williams (JMW)
*
*  This file contains methods to retrieve client side data.
*
*  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
*  This program contains proprietary and trade secret information 
*  of MatrixOne,Inc. Copyright notice is precautionary only
*  and does not evidence any actual or intended publication of such program
* 
*  static const char RCSID[] = $Id: emxClientSideInfo.js.rca 1.6 Wed Oct 22 15:48:32 2008 przemek Experimental przemek $
*=================================================================
*/

var strProtocol, strHost, strPort, strPathname, currentTimeZoneOffsetInHours, xmlData, strURL;
var x = new Date();

strURL = "emxClientSideInfoProcessing.jsp?xhr=" + Math.random();

with(document.location){
    strProtocol = protocol;
    strHost = hostname;
    strPort = port;
    strPathname = pathname;
}

currentTimeZoneOffsetInHours = x.getTimezoneOffset()/60;
if (isDaylightSavingTime())
{
    currentTimeZoneOffsetInHours += 1;
}

//build xml data
xmlData = createXML();

//send xmlData
try{
var postResult = emxUICore.sendXMLPost(strURL, xmlData);
document.write(postResult);
}catch(e){}


//FUNCTIONS

function isDaylightSavingTime() {

        //date where standard time is used
        var objStdDate = new Date(2002,0,1);

        //today's date
        var objToday = new Date;

        //if the two are not equal, it's daylight saving time
        return (objStdDate.getTimezoneOffset() != objToday.getTimezoneOffset());

} //End: function isDaylightSavingTime()


function createXML(){
    var xmlDoc = emxUICore.createXMLDOM();
    xmlDoc.loadXML("<emxRoot/>");
    
    //root
    var root = xmlDoc.documentElement;
    
    //timeZoneOffset
    var tz = xmlDoc.createElement("timeZoneOffset");
    tz.appendChild(xmlDoc.createTextNode(currentTimeZoneOffsetInHours));
    root.appendChild(tz);
    
    //client side URL info
    var ci = xmlDoc.createElement("clientSideUrlInfo");
    root.appendChild(ci);
    
    var ciProtocol = xmlDoc.createElement("protocol");
    ciProtocol.appendChild(xmlDoc.createTextNode(strProtocol));
    ci.appendChild(ciProtocol);
    
    var ciHost = xmlDoc.createElement("host");
    ciHost.appendChild(xmlDoc.createTextNode(strHost));
    ci.appendChild(ciHost);
    
    var ciPort = xmlDoc.createElement("port");
    ciPort.appendChild(xmlDoc.createTextNode(strPort));
    ci.appendChild(ciPort);
    
    var ciPathname = xmlDoc.createElement("pathname");
	ciPathname.appendChild(xmlDoc.createTextNode(strPathname));
    ci.appendChild(ciPathname);

    return xmlDoc.xml;
}
