<%--  emxMEPREvValidation.jsp

    Copyright Dassault Systemes, 2007. All rights reserved
  This program is proprietary property of Dassault Systemes and its subsidiaries.
  This documentation shall be treated as confidential information and may only be used by employees or contractors
  with the Customer in accordance with the applicable Software License Agreement
  static const char RCSID[] = $Id: /web/manufacturerequivalentpart/emxRevValidation.jsp 

 --%>
<%-- Common Includes --%>
<%@include file = "../components/emxComponentsCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@ page import="matrix.db.*, matrix.util.*, java.util.*,com.matrixone.apps.manufacturerequivalentpart.Part"  %>


<%
try{
    String returnString ="";
   // HashMap hMap=new HashMap();
   String[] args  = null;
    String orgId = emxGetParameter(request,"orgId");
    String locObjId=emxGetParameter(request,"locId");
    
    HashMap hMap=(new Part()).getRevisionValue(context,orgId,locObjId);
    StringBuffer revValue=new StringBuffer();
    revValue.append((String)hMap.get("CompId"));
    revValue.append("|");
    revValue.append((String)hMap.get("CageCode"));
    revValue.append("|");
    revValue.append((String)hMap.get("customRevision"));
    revValue.append("|");
    revValue.append((String)hMap.get("uniqueIdentifier"));
    revValue.append("|");
    revValue.append((String)hMap.get("plantId"));
    revValue.append("|");
    revValue.append(hMap.get("revSeqValue").toString());
    returnString =revValue.toString();
    out.clear();
out.println(returnString);
}catch(Exception e){
    e.printStackTrace();
}
%>

