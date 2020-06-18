<%--
ProductLineAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
boolean bIsError = false;

  try
  {  
      
     String strObjId = emxGetParameter(request, "objectId");
     String parentOID = emxGetParameter(request, "parentOID");  
     String strLanguage = context.getSession().getLanguage();   
     String strFullSearchSelection = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.FullSearch.Selection", strLanguage);      
     String strArrSelectedTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
     
    //If the selection are not made in Search results page  
     if(strArrSelectedTableRowId==null){
         %>    
           <script language="javascript" type="text/javaScript">
               alert("<xss:encodeForJavaScript><%=strFullSearchSelection%></xss:encodeForJavaScript>");
           </script>
         <%
     }        
     else{        
             Map strSelectedFeatures = new LinkedHashMap();          
             String strSelectedObject = "";
             String strtemp = "";
             String xml = "";
             String strFeatureType = "";
             String relType = "";
             boolean isValidationFailed = false;                         
             DomainObject parentObj = new DomainObject(strObjId);             
             StringList objectSelectList = new StringList();
             objectSelectList.addElement(ProductLineConstants.SELECT_TYPE);             
             Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);             
             String strParentType = (String)parentInfoTable.get(ProductLine.SELECT_TYPE);        
             StringList strObjectIdList = new StringList();          
             for(int i=0;i<strArrSelectedTableRowId.length;i++)
             {   
                 StringTokenizer strTokenizer = new StringTokenizer(strArrSelectedTableRowId[i] ,"|");                 
                 //Extracting the Object Id from the String.
                 for(int j=0;j<strTokenizer.countTokens();j++)                 {
                     strSelectedObject = strTokenizer.nextElement().toString();             
                     strObjectIdList.addElement(strSelectedObject);
                      break;
                 }
                 strFeatureType = new DomainObject(strSelectedObject).getInfo(context, "type");              
                        relType = "relationship_SubProductLines";
                        strSelectedFeatures.put(strSelectedObject, relType);              
              }                      
        
                // checking for different RDO alert
                 Set keySet = strSelectedFeatures.keySet();
                 String[] selectedFetureIDList = new String[keySet.size()]; 
                 selectedFetureIDList = (String[])keySet.toArray(selectedFetureIDList);              
                 String strContext =  strObjId;         
 
                     Iterator itr = keySet.iterator();
                             
                             relType =  "relationship_SubProductLines";
                     while(itr.hasNext()){
                             strSelectedObject = itr.next().toString();     
                             relType = strSelectedFeatures.get(strSelectedObject).toString();                             
                             HashMap paramMap = new HashMap();
                             paramMap.put("newObjectId", strSelectedObject);
                             paramMap.put("objectId", strObjId);                         
                             paramMap.put("featureType",strFeatureType);                
                             paramMap.put("languageStr", strLanguage);
                             paramMap.put("relId","");
                             paramMap.put("objectCreation","Existing");
                             
                             if(strContext != null && !"".equalsIgnoreCase(strContext)){
                             DomainRelationship.connect(context, strContext, PropertyUtil.getSchemaProperty(context, relType), strSelectedObject, false);
                             }
                             
                             xml = ProductLine.getXMLForSBCreate(context, paramMap, relType);
                             %>
                             <script language="javascript" type="text/javaScript">
                                    //XSSOK
                                    var strXml="<%=xml%>";                                
                                    var contentFrameObj = findFrame(window.parent.getTopWindow().getWindowOpener().parent.getTopWindow(),"detailsDisplay");                   
                                    contentFrameObj.emxEditableTable.addToSelected(strXml);
                             </script>
                            <%                                                
                     }  
                     %>
                     <script language="javascript" type="text/javaScript">               
                            //getTopWindow().window.location.href = "../common/emxCloseWindow.jsp";
                            //getTopWindow().close(); SHould not use browser Close- in 3DSpace it is closing complete window
                            getTopWindow().closeWindow();
                     </script>
                     <%                               
         }
  }catch(Exception e)
  {
        bIsError=true;
        session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
