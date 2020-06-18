<%-- emxpartConnectSparePartProcess.jsp - Used to connect to ECR(s)
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%!
    public String getMarkup(String selPartObjectId, String[] selectedItems) throws Exception {
        String selectedId;    
        int length = (selectedItems == null) ? 0 : selectedItems.length;        
        StringBuffer sbOut = new StringBuffer(length * 150 + 100);
    
        sbOut.append("<mxRoot>").append("<action>add</action>").append("<data status=\"pending\">");        
    
        for (int i = 0; i < length; i++) {
            selectedId = (String) FrameworkUtil.split(selectedItems[i], "|").get(0);
            
            sbOut.append("<item oid=\"").append(selectedId).append("\" pid=\"").append(selPartObjectId).append("\" relType=\"relationship_SparePart\">");
            sbOut.append("<column name=\"Quantity\" edited=\"true\">0.0</column>");
            sbOut.append("</item>");
        }
    
        sbOut.append("</data>").append("</mxRoot>");
        
        return sbOut.toString();    
    }
%>
<%      
        String objectId = emxGetParameter(request, "objectId");
        String[] selPartIds = emxGetParameterValues(request, "emxTableRowId"); 
        String languageStr     = request.getHeader("Accept-Language");
	
        /*String strSelectRootNode     =  i18nNow.getI18nString("emxEngineeringCentral.SpareParts.AddSpareParts.SelectRootNode",
                "emxEngineeringCentralStringResource",languageStr);*/
        String strSelectRootNode     =  EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.SpareParts.AddSpareParts.SelectRootNode");
        String strInput = "";      
        String callbackFunctionName = "addToSelected";
     try {          
              strInput = getMarkup(objectId, selPartIds);
          } catch (Exception ex) {
              if (ex.toString() != null && (ex.toString().trim()).length() > 0)
                  emxNavErrorObject.addMessage(ex.toString().trim()); 
          }  
  %>
 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    <script language="Javascript">   
    //XSSOK
     var callback = eval(getTopWindow().window.getWindowOpener().emxEditableTable.<%=callbackFunctionName%>); 
          
     var oxmlstatus = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');       
     getTopWindow().closeWindow();
     
    </script>

