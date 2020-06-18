<%--emxLibraryCentralDisconnectRecord.jsp   -  This page removes the selected objectIds

    Copyright (c) 2006-2016 Dassault Systemes.
    All Rights Reserved.
    This program contains proprietary and trade secret information of MatrixOne,Inc.
    Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

    static const char RCSID[] = $Id: emxLibraryCentralDisconnectRecord.jsp.rca 1.1.1.4 Wed Oct 22 16:02:24 2008 przemek Experimental przemek $
    --%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "emxLibraryCentralUtils.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
    String jsTreeID = emxGetParameter(request,"jsTreeID");
    String objectId = emxGetParameter(request,"objectId");

    String initSource = emxGetParameter(request,"initSource");
    String suiteKey = emxGetParameter(request,"suiteKey");
    String sObjId ="";
    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    String emxTableRowIds[]     =(String[]) emxGetParameterValues(request, "emxTableRowId");
    Vector vecObjectIds = new Vector();
    StringBuffer responseXML    = new StringBuffer();
    Map levelIdMap      = new HashMap();
    if(checkBoxId != null)
    {
        try
        {
            for(int i=0;i<checkBoxId.length;i++)
            {
                StringTokenizer token = new StringTokenizer(checkBoxId[i], "|", false);
                String sRelId = token.nextToken().trim();
                sObjId = token.nextToken().trim();
                checkBoxId[i] = sObjId;
                DomainRelationship.disconnect(context, sRelId);
            }
            //vecObjectIds.addElement(sObjId);
        }
        catch(Exception Ex)
        {
            System.out.println("Exception "+Ex.toString());
        }
    }
    String []objIds     = getTableRowIDsArray(emxTableRowIds);
    if(objIds != null) {
        for(int i = 0; i < objIds.length; i++) {
            vecObjectIds.addElement(objIds[i]);
            StringTokenizer strTokens = new StringTokenizer(emxTableRowIds[i],"|");
            while (strTokens.hasMoreTokens()) {
                levelIdMap.put(objIds[i], strTokens.nextToken());
            }
        }
    }
    responseXML.append("<mxRoot>");
    responseXML.append("<action>remove</action>");
    Iterator itr =  vecObjectIds.iterator();
    // Adding the Item level details for the Deleted Objects
     while ( itr.hasNext() ){
         String objectId1 = (String)itr.next();
         responseXML.append("<item id='");
         responseXML.append((String)levelIdMap.get(objectId1));
         responseXML.append("'/>");
     }
     responseXML.append("</mxRoot>");
%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>

<script language="javascript" type="text/javaScript">
var vDeleteRows = <xss:encodeForJavaScript><%=vecObjectIds.size()>0%></xss:encodeForJavaScript>;
if(vDeleteRows) { 
    if(parent.removedeletedRows) {
        var responseXML  = "<xss:encodeForJavaScript><%=responseXML.toString()%></xss:encodeForJavaScript>";
        parent.removedeletedRows(responseXML);
    }
}
    try{
<%
        int iSize = vecObjectIds.size();
        for (int i = 0; i < iSize; ++i) {
%>
            var childId     = '<xss:encodeForJavaScript><%=(String)vecObjectIds.elementAt(i)%></xss:encodeForJavaScript>';
            getTopWindow().deleteObjectFromTrees(childId,true);
<%
        }
%>
         //getTopWindow().refreshTrees();
         //getTopWindow().refreshTablePage();
    }catch(exec){
    }
</script>
