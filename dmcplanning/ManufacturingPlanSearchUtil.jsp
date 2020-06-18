<%--
  ManufacturingPlanSearchUtil.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.db.Context"%> 
<%@page import="com.matrixone.apps.productline.Image"%>
<%@page import = "com.matrixone.apps.productline.TestCase"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.List"%>

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
     String strMode = emxGetParameter(request,"mode");
     String strObjId = emxGetParameter(request, "objectId");
     String strparentId = emxGetParameter(request, "parentID");
     String strSelId =  emxGetParameter(request, "SelId");
     String strContext = emxGetParameter(request,"context");
     String strRelName = emxGetParameter(request,"relName");   
     String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
     String strToConnectObjectType = "";
     boolean isConnected = false;
     Object objToConnectObject = "";
     String strToConnectObject = "";
     String strParams = (String)session.getAttribute("params");   
     String strCutXML = null;
     String strAddXML = null;
     String strTodisconnectConnectObject ="";
   
     if(strContextObjectId==null)
     {   
     %>    
       <script language="javascript" type="text/javaScript">
           alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
       </script>
     <%}
     else
      { 
         if(strMode.equals("insertManufacturingPlan"))
         {    
             StringList strToConnectObjectList = new StringList();
                for(int i=0;i<strContextObjectId.length;i++)
                {
                    StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
                        
                    //Extracting the Object Id from the String.
                     for(int j=0;j<strTokenizer.countTokens();j++)
                      {
                                 objToConnectObject = strTokenizer.nextElement();
                                 strToConnectObject = objToConnectObject.toString();
                                 strToConnectObjectList.add(strToConnectObject);
                                 break;
                      } 
                 }
                
                //Added for IR-034828V6R2011
                //Check for the other revisions of the seelcted feature and get if any MP already connected before committing to database
                DomainObject domstrObjId = new DomainObject(strObjId);
                MapList lstRevIdList = new MapList();
                StringList singleValueSelects= new StringList(DomainObject.SELECT_ID);
                StringList multiValueSelects= new StringList();
                lstRevIdList = domstrObjId.getRevisionsInfo(context,
                		            singleValueSelects,
                                    multiValueSelects);
                String strRev = null;
                strRev = domstrObjId.getRevision();
                
                //Check whether already any MP is connected to the selected Feature
                //Added for IR-046355V6R2011
                com.matrixone.apps.dmcplanning.ManufacturingPlan contextMP = new com.matrixone.apps.dmcplanning.ManufacturingPlan(strSelId);
                //Modified for IR-046355V6R2011
                strTodisconnectConnectObject = contextMP.getMPInStructure(context,strObjId,strparentId);
                
               //Modified for IR-030719V6R2011
               if (strTodisconnectConnectObject != null && !strTodisconnectConnectObject.equals("") && !strTodisconnectConnectObject.equals("null"))
                {
                     %>
                      <%-- Removed for R211
                      <script language="javascript" type="text/javaScript">
                      var tableXML = getTopWindow().getWindowOpener().parent.oXML;                     
                      var oid = "<%=XSSUtil.encodeForURL(context,strTodisconnectConnectObject)%>";
                      var aRow = emxUICore.selectSingleNode(getTopWindow().getWindowOpener().parent.oXML.documentElement,"/mxRoot/rows//r[@o ='" + oid + "']");
                      var levelID = aRow.getAttribute("id");

                      var levels= new Array();
                      levels[0] = levelID;
                      getTopWindow().getWindowOpener().parent.emxEditableTable.prototype.cutRows(levels);

                      </script>
                      --%>
                     <%
                     strAddXML = com.matrixone.apps.dmcplanning.ManufacturingPlan.insertManufacturingPlan(context,strObjId,strToConnectObjectList,strParams,strSelId);
                     %>
                        <script language="javascript" type="text/javaScript"> 
                        //XSSOK- encoding handled in JAVA code  
                        var strAddXml="<%=strAddXML%>";
                        getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strAddXml); 
                        getTopWindow().window.closeWindow();  
                        </script>
                     <%
                }
               //Added for IR-031135V6R2011
                else
                {
                    strAddXML = com.matrixone.apps.dmcplanning.ManufacturingPlan.insertManufacturingPlan(context,strObjId,strToConnectObjectList,strParams,strSelId);
                    %>
                       <script language="javascript" type="text/javaScript">  
                       var strAddXml="<%=XSSUtil.encodeForJavaScript(context,strAddXML)%>";
                       var podid = "<%=XSSUtil.encodeForJavaScript(context,strObjId)%>";
                                       
                       var xmlObj; 
                       var aChildRow;
                       if (isEdge)
                       {
                    	   var xmlDoc =getTopWindow().getWindowOpener().parent.oXML.xml;
                    	   var parser=new DOMParser();
                           xmlObj=parser.parseFromString(xmlDoc,"text/xml");
                           aChildRow = emxUICore.selectSingleNode(xmlObj,"/mxRoot/rows//r[@p ='" + podid + "']");
                       }
                       else 
                       {
                    	 aChildRow = emxUICore.selectSingleNode(getTopWindow().getWindowOpener().parent.oXML.documentElement,"/mxRoot/rows//r[@p ='" + podid + "']"); 
                       }
                                            
                       if(aChildRow)
                       {
                           var aRowId = aChildRow.getAttribute("id");
                           var response = "<mxRoot><item" +" "+ "id=\""+aRowId+"\"/></mxRoot>";
                           //Commented this line for fixing IR-084197V6R2012 :2-Dec-2012:ixe
                           //top.getWindowOpener().parent.removedeletedRows(response);
                           //END - IR-084197V6R2012
                           
                         getTopWindow().window.closeWindow();
                         getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strAddXml);
                          
                       }
                       else
                       {
                          
                           //Added for IR-037041V6R2011
                           <%
                           for(int i=0;i<lstRevIdList.size();i++)
                           {
                               Map mapTemp = (Map)lstRevIdList.get(i);
                               String strFeatId =(String)mapTemp.get(DomainObject.SELECT_ID);
                               if(strFeatId!=null && !strFeatId.equalsIgnoreCase(strObjId))
                               {
                               %>
                                   var podid = "<%=XSSUtil.encodeForJavaScript(context,strFeatId)%>";
                                   
                                   var xmlObj;
                                   var aRevChildRow;
                                   if (isEdge)
                                   {
                                	   var xmlDoc =getTopWindow().getWindowOpener().parent.oXML.xml;
                                	   var parser=new DOMParser();
                                       xmlObj=parser.parseFromString(xmlDoc,"text/xml");
                                       aRevChildRow = emxUICore.selectSingleNode(xmlObj,"/mxRoot/rows//r[@p ='" + podid + "']");
                                   }
                                   else 
                                   {
                                	   aRevChildRow = emxUICore.selectSingleNode(getTopWindow().getWindowOpener().parent.oXML.documentElement,"/mxRoot/rows//r[@p ='" + podid + "']"); 
                                   }
                                   
                                   if(aRevChildRow!=null)
                                   {
                                        var aRowId = aRevChildRow.getAttribute("id");
                                        var response = "<mxRoot><item" +" "+ "id=\""+aRowId+"\"/></mxRoot>";
                                        getTopWindow().getWindowOpener().parent.removedeletedRows(response);
                                        
                                   }
                              <%     
                               }
                           }
                           %>
                           getTopWindow().getWindowOpener().parent.emxEditableTable.addToSelected(strAddXml);
                       }
                       getTopWindow().window.closeWindow();  
                       </script>
                    <%
                }
             }
         }
    }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
    //emxNavErrorObject.addMessage(e.toString().trim());
  }// End of main Try-catck block
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
