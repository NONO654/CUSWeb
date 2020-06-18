<%--  emxEngrSearchIntermediateProcess.jsp -  This page displays clock in search result page on deletion
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>


<% 

  String languageStr = Request.getParameter(request,"languageStr");
  String jsTreeID    = emxGetParameter(request,"jsTreeID");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String fullTextSearch = emxGetParameter(request, "fullTextSearch");
  String suiteKey     = emxGetParameter(request,"suiteKey");  
  String initSource  = emxGetParameter(request,"initSource");
  String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");  
  String ImageData = emxGetParameter(request, "ImageData");  
  String[] checkBoxId =new String[selPartIds.length];
  //Start: 375954
  String struiType =  emxGetParameter(request,"uiType");
  String strIds ="";
  Map levelIdMap      = new HashMap();
  //End: 375954
  String selectedId = "";
   if(selPartIds != null)
    {
           for (int i=0; i < selPartIds.length ;i++)
           {
             StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
             if (strTokens.hasMoreTokens())
             {
                selectedId = strTokens.nextToken();
                if(selPartIds.length >1)
                   //IR-036950 - Starts 
                   //strIds +=selectedId+"|";
                    strIds += selectedId + "~";
                   //IR-036950 - Ends
                else
                	strIds +=selectedId;
                
               //checkBoxId[i] =(String)selectedId;
               //Start: 375954
               if(struiType!=null && !"table".equalsIgnoreCase(struiType)){
               levelIdMap.put(selectedId, strTokens.nextToken());
               }
               //End: 375954
             }//End of if loop
            }//End of for loop
    }//End of if loop
 
%>

  
   <%@include file = "emxDesignBottomInclude.inc" %>
    
  <html><head></head><body><form id='formid' method="post" > 
  <input type="hidden" name="objIds" value="<xss:encodeForHTMLAttribute><%=strIds%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=strIds%></xss:encodeForHTMLAttribute>"/>
  
  </form></body></html>
    <script language="Javascript">
    // IR-034303 Starts (added parameter "selection=multiple")
   sURL = "../common/emxIndentedTable.jsp?table=ENCPartSpecificationSearchEditDetails&header=emxEngineeringCentral.GlobalSearch.MyEngViewSearchSpecificationTitle&program=emxECSearchMassUpdate:getPartSearchEditDetails&toolbar=EmptyMenu&mode=edit&hideHeader=false&ImageData=<xss:encodeForJavaScript><%=ImageData%></xss:encodeForJavaScript>&initSource='<xss:encodeForJavaScript><%=initSource%></xss:encodeForJavaScript>'&jsTreeID=<xss:encodeForJavaScript><%=jsTreeID%></xss:encodeForJavaScript>&languageStr=<xss:encodeForJavaScript><%=languageStr%></xss:encodeForJavaScript>&timeStamp=<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>&suiteKey=<xss:encodeForJavaScript><%=suiteKey%></xss:encodeForJavaScript>&selection=multiple"
    // IR-034303 ends
       // window.location.href = sURL;
document.forms["formid"].action=sURL;
  document.forms["formid"].submit();    
    </script>
