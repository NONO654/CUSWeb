<%--  emxAEFCheckUniqueResult.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAEFCheckUniqueResult.jsp.rca 1.3 Tue Feb 10 09:18:00 2009 ds-smourougayan Experimental $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
HashMap params = new HashMap();
String searchTimeStamp = "";
String displayName ="";
String actualName ="";
String objectID = "";
int objectCount = 0;
String timestampToBePassed = UIComponent.getTimeStamp();
String languageStr = request.getHeader("Accept-Language");
HashMap resultMap;
String initargs[] = {};
StringBuffer qStringBuff = new StringBuffer();
Enumeration eNumParameters = emxGetParameterNames(request);
String fieldSeperator = EnoviaResourceBundle.getProperty(context,"emxFramework.FullTextSearch.FieldSeparator");
String strFieldSeperator = emxGetParameter(request, "fieldSeparator");
if(strFieldSeperator!=null && strFieldSeperator.length() != 0){
    fieldSeperator =  strFieldSeperator;
}

while( eNumParameters.hasMoreElements() ) {
    String parmName = (String)eNumParameters.nextElement(); 
    String parmValue = (String)emxGetParameter(request,parmName);    
	if(parmName.equals("field") || parmName.equals("default")) {	    
		parmValue = UISearchUtil.convertSymbolicNames(context, parmValue, fieldSeperator);
	}
    qStringBuff.append(parmName); 
    qStringBuff.append("="); 
    qStringBuff.append(parmValue);
	params.put(parmName, parmValue);    
    if(eNumParameters.hasMoreElements()){
        qStringBuff.append("&"); 
    }
}
params.put("searchTimeStamp",timestampToBePassed);
params.put("queryLimit","2");
params.put("fullTextSearchTimestamp",timestampToBePassed);
params.put("languageStr",languageStr);
params.put("localeObj",request.getLocale());
params.put("timeZone",session.getAttribute("timeZone"));
//if a particular field is defined in filters and default value, then it removed from the refinements
//params.put("firstTimeFormLoad","true");
ContextUtil.startTransaction(context, false);
resultMap = (HashMap)JPO.invoke(context, "emxAEFFullSearch", initargs, "getSearchResults", JPO.packArgs (params), HashMap.class);
Integer objCount = (Integer)resultMap.get("objectCount");
searchTimeStamp = (String)resultMap.get("fullTextSearchTimestamp");
objectCount = objCount.intValue();
if(objectCount >1){
    //here checkStoredResult and fullTextSearchTimestamp
}else if(objectCount ==1){
    MapList objectList = (MapList)resultMap.get("searchResult");
    HashMap object =(HashMap)objectList.get(1);
    objectID = (String)object.get("id");
    DomainObject objContext = new DomainObject(objectID);
    String strContextObjectType =  objContext.getInfo(context,DomainConstants.SELECT_TYPE);
    String strTypeSymbolicName  = UICache.getSymbolicName(context, strContextObjectType, "type");
    displayName = (String)object.get("displayName");
    actualName = displayName;
    if(!UIUtil.isNullOrEmpty(strTypeSymbolicName) && "type_Person".equals(strTypeSymbolicName)) {
        displayName = PersonUtil.getFullName(context, displayName);
    }
}
//clear the output buffer
out.clear();
response.setContentType("text/xml; charset=UTF-8");
String dataXML = "<mxRoot>";
   dataXML += "<objectCount>"+ objectCount +"</objectCount>";
   dataXML += "<searchTimeStamp>"+searchTimeStamp+"</searchTimeStamp>";
   dataXML += "<displayName>"+XSSUtil.encodeForXML(context,displayName)+"</displayName>";
   dataXML += "<actualName>"+actualName+"</actualName>";
   dataXML += "<OID>"+objectID+"</OID>";
   dataXML += "</mxRoot>";
out.write(dataXML);
%>
