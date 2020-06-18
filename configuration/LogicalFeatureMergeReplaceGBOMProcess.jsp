<%--  LogicalFeatureMergeReplaceGBOMProcess.jsp


   Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>


<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %> 
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<body leftmargin="1" rightmargin="1" topmargin="1" bottommargin="1" scroll="no">
<%--Breaks without the useBean--%>

<%@ page import = "com.matrixone.apps.domain.util.MapList"%>
<%@ page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="com.matrixone.jdom.Document"%>
<%@page import="com.matrixone.jdom.Element"%>
<%@page import="matrix.db.JPO"%>
<%@page import="java.util.Map"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="java.util.HashMap"%>

<html>

  <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
  <jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%
try
{
    String strMode    = emxGetParameter(request, "mode");
    String timeStamp = emxGetParameter(request, "timeStamp");   
    LogicalFeature logicalFeature = new LogicalFeature();
    
    if(strMode.equalsIgnoreCase("editPostMergedPartMode"))
    {        
        HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);        
        HashMap tableDataMap = indentedTableBean.getTableData(timeStamp);
        MapList objList = indentedTableBean.getObjectList(tableDataMap);
        MapList columnList = (MapList)tableDataMap.get("columns");         
        MapList removedPartList = (MapList) session.getAttribute("removedParts");  
      try{   
            for(int i =0 ; i< objList.size(); i++)
            {                
                StringList allDesignVariantList = new StringList(); 
                Map mapPart = new HashMap();
                mapPart = (Map) objList.get(i);
                String strRelId = (String) mapPart.get(ConfigurationConstants.SELECT_RELATIONSHIP_ID);
                String strFeatureId = (String) ((Map)(DomainRelationship.getInfo(context,new String[] {strRelId},new matrix.util.StringList("from.id"))).get(0)).get("from.id");
                mapPart.put("LogicalFeatureId",strFeatureId);
                mapPart.put("LogicalFeaturePartconnectionId",strRelId);
               
                for(int j =0; j< columnList.size(); j++)
                {
                    Map mapColumn = new HashMap();
                    mapColumn = (Map) columnList.get(j);
                    String columnId = (String) mapColumn.get("id");
                    if(columnId != null && !"".equals(columnId))
                    {
                        StringList sbObjSelect = new StringList();
                        sbObjSelect.add(ConfigurationConstants.SELECT_ID);
                        StringList sbRelSelect = new StringList();
                        sbRelSelect.add(ConfigurationConstants.SELECT_PHYSICAL_ID);
                        //used CF API to get COS details
                        ConfigurationFeature cfBean = new ConfigurationFeature(columnId);
                        Map confOptionToRel =cfBean.getDesignVariantChoices(context); 
                        mapPart.put(columnId,confOptionToRel);
                        allDesignVariantList.add(columnId);                       
                    }
                }
                mapPart.put("AllDesignVariantList",allDesignVariantList);
            }               
        
       Document tableDoc = (Document) request.getAttribute("XMLDoc");
       MapList updtedCellsList = new MapList();       
       Element rootElement =  tableDoc.getRootElement();         
       for(int j=0;j < rootElement.getChildren().size();j++)
        {
            Element docEle = (Element) rootElement.getChildren().get(j);
            String elementName =  docEle.getName();
            if("object".equals(elementName))
            {                
                for(int k=0; k<docEle.getChildren("column").size();k++ )
                {
                Map updatedCell = new HashMap();
                updatedCell.put("RowId",docEle.getAttributeValue("rowId"));
                updatedCell.put("PartId",docEle.getAttributeValue("objectId"));
                updatedCell.put("RelId",docEle.getAttributeValue("relId"));     
                Element columnEle = new Element("column");
                columnEle = (Element) docEle.getChildren("column").get(k);
                updatedCell.put("DesignVariantId",columnEle.getAttributeValue("name"));
                String strNewValue = columnEle.getText();
                String strNewFeatureId = "";
                String strNewFeatureRelId = "";
                
                if(!"-".equals(strNewValue))                    
                {
                    java.util.StringTokenizer newValueTZ = new java.util.StringTokenizer(strNewValue,"|");
                    strNewFeatureId = newValueTZ.nextToken();
                    strNewFeatureRelId = newValueTZ.nextToken(); 

                }else
                {
                    strNewFeatureId = "-";
                    strNewFeatureRelId = "-"; 
                }
                updatedCell.put("NewFeatureId",strNewFeatureId);     
                updatedCell.put("NewFeatureRelId",strNewFeatureRelId);    
                updtedCellsList.add(updatedCell);
                }
            }            
        }
       
       for(int i= 0;i<objList.size();i++)
       {
           Map objMap = (Map) objList.get(i);
          
           String objLevelId = (String) objMap.get("id[level]");
           for(int j=0;j < updtedCellsList.size();j++)
           {
               Map updatedCell = (Map) updtedCellsList.get(j);
               String cellLevelId = (String) updatedCell.get("RowId");
               if(objLevelId.equals(cellLevelId))
               {
                   String strDVId = (String) updatedCell.get("DesignVariantId");                   
                   Map updateCell = (Map)objMap.get(strDVId);
                   updatedCell.put("physicalIdMap",(Map)objMap.get(strDVId));
                   objMap.put(strDVId,updatedCell);
                   objMap.put("Updated",Boolean.valueOf(true));
               }
           }
       }       
       
       requestMap.put("UpdatedCells",objList);
       session.setAttribute("UpdatedCells",objList);
       requestMap.put("removedPartList",removedPartList);     

       Map programMap = new HashMap();
       String strMasFeaId = (String) requestMap.get("objectId");
       tableDataMap.put("objectId",strMasFeaId);       
       tableDataMap.put("RequestMap",requestMap);
       programMap.put("tableData",tableDataMap);    
       // call the method to update the maplist for post process.
       String[] arrJPOArgs = (String[])JPO.packArgs(programMap);                                                 
       MapList mapUpdatedPartsActual = (MapList) JPO.invoke(context,"emxFTRPart",null,"getUpdatedGBOMListPostMerge",arrJPOArgs,MapList.class);
       session.setAttribute("Part List",mapUpdatedPartsActual);
        
    } 
        catch(Exception e){e.printStackTrace();}

    }
    else if (strMode.equalsIgnoreCase("MergeReplaceRemove"))
    {
        try
        {
            com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
            formBean.processForm(session,request);
            String tableTimestamp =(String) session.getAttribute("TableTimeStamp");        
            if(tableTimestamp==null )
            {
                tableTimestamp =timeStamp;
                session.setAttribute("originalPartList",null);
                session.setAttribute("originalTableData",null);
                session.setAttribute("nonRemoveParts",null);     
                session.setAttribute("removedParts",null); 
           }        
            session.setAttribute("TableTimeStamp",tableTimestamp);        
            HashMap tableDataMap = indentedTableBean.getTableData(timeStamp);
            Map requestMap = (Map) indentedTableBean.getRequestMap(timeStamp);
            MapList originalPartList = (MapList) session.getAttribute("originalPartList");
            MapList partList =  indentedTableBean.getObjectList(timeStamp);
            MapList nonRemovedPartsList = (MapList) session.getAttribute("nonRemoveParts");
            MapList removedPartList = (MapList) session.getAttribute("removedParts");        
            if(nonRemovedPartsList==null && removedPartList==null)
            {
                nonRemovedPartsList = indentedTableBean.getObjectList(timeStamp);
                removedPartList = new com.matrixone.apps.domain.util.MapList();
            }       
            String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
            StringList strSelRelObjIds = new StringList();
            StringList strSelObjParentIds = new StringList();
            StringList strSelObjLevelIds = new StringList();        
            for(int i=0; i<strTableRowIds.length;i++ )
            {
                StringTokenizer strRowIdTZ = new StringTokenizer(strTableRowIds[i],"|");
                strSelRelObjIds.add(i,strRowIdTZ.nextToken());
                strRowIdTZ.nextToken();
                strSelObjParentIds.add(i,strRowIdTZ.nextToken());
                strSelObjLevelIds.add(i,"'"+strTableRowIds[i]+"'");
            }              
              formBean.setElementValue("nonRemovedPartsList",nonRemovedPartsList);
              formBean.setElementValue("removedPartList",removedPartList);
              formBean.setElementValue("strRelIds",strSelRelObjIds);
              
              MapList UpdatedCells = (MapList) session.getAttribute("UpdatedCells");
              
              if(UpdatedCells != null)
              {
                  partList = UpdatedCells;
              }
              
              formBean.setElementValue("partList",partList); 
              StringList strRelIds = (StringList)formBean.getElementValue("strRelIds");
              Map mergereplaceMap = new HashMap();
              mergereplaceMap.put("nonRemovedPartsList",nonRemovedPartsList);
              mergereplaceMap.put("removedPartList",removedPartList);
              mergereplaceMap.put("strRelIds",strSelRelObjIds);
              mergereplaceMap.put("partList",partList);
              mergereplaceMap.put("strRelIds",strRelIds);
              
              Map updatedTableMap  = logicalFeature.removeMergedGBOM(context,mergereplaceMap);          
              nonRemovedPartsList = (MapList) updatedTableMap.get("nonRemovedPartsList");
              removedPartList = (MapList) updatedTableMap.get("removedPartList");
              partList = (MapList) updatedTableMap.get("partList");          
              session.setAttribute("originalPartList",originalPartList);
              session.setAttribute("nonRemoveParts",partList);
              session.setAttribute("removedParts",removedPartList);
              
              tableDataMap.put("ObjectList",partList);
              
              Map programMap = new HashMap();
              String strMasFeaId = (String) requestMap.get("objectId");
              requestMap.put("removedPartList",removedPartList);
              
              //UpdatedCells
              if(UpdatedCells != null)
              {
                  requestMap.put("UpdatedCells",UpdatedCells);
              }
              else
              {
                  requestMap.put("UpdatedCells",partList);
              }
              tableDataMap.put("objectId",strMasFeaId);              
              tableDataMap.put("RequestMap",requestMap);
              programMap.put("tableData",tableDataMap);
           
              // call the method to update the maplist for post process.
              String[] arrJPOArgs = (String[])JPO.packArgs(programMap);                                                 
              Map mapUpdatedPartsActual = (Map) JPO.invoke(context,"emxFTRPart",null,"postJPOMergeReplaceEdit",arrJPOArgs,Map.class);
              String strLevelIds = ((StringList)mapUpdatedPartsActual.get("LevelIds")).toString();              
              String strGrpNo = ((StringList)mapUpdatedPartsActual.get("GrpNumbers")).toString();
              String strSelRowLevelIds = strSelObjLevelIds.toString();
              strLevelIds = strLevelIds.substring(strLevelIds.lastIndexOf("[")+1,strLevelIds.lastIndexOf("]"));
              strGrpNo = strGrpNo.substring(strGrpNo.lastIndexOf("[")+1,strGrpNo.lastIndexOf("]"));
              strSelRowLevelIds = strSelRowLevelIds.substring(strSelRowLevelIds.lastIndexOf("[")+1,strSelRowLevelIds.lastIndexOf("]"));
              
              out.clear();//added
              response.setContentType("text/html");//added
             
              %>   
              <script>           
              var tableXML = window.parent.oXML;
              var levelIds =new Array(<%=strLevelIds%>);
              var grpNos =new Array(<%=strGrpNo%>);
              var selRowIds = new Array(<%=strSelRowLevelIds%>);
              
              for(var i =0; i<grpNos.length && window.parent.getTopWindow().oXML==null ;i++){
                  var aRows = window.parent.emxUICore.selectSingleNode(tableXML.documentElement,"/mxRoot/rows/r[@id='"+levelIds[i]+"']");
                 
                 aRows.removeAttribute("status");
                 for(var j=0;j<aRows.childNodes.length && window.parent.getTopWindow().oXML == null ;j++){                          
                                  var value = window.parent.emxUICore.getText(aRows.childNodes[j]);
                                  if(j == 1){
                                     var objDOM = window.parent.emxUICore.createXMLDOM();
                                     objDOM.loadXML("<c a='"+grpNos[i]+"'>"+grpNos[i]+"</c>");                       
                                     aRows.replaceChild(objDOM.documentElement,aRows.childNodes[j]);}
                                  else{
                                     aRows.childNodes[j].setAttribute("a",value);                
                                     }
                                  aRows.childNodes[j].setAttribute("edited","false");
                    }
                 }              
              
              if(window.parent.getTopWindow().oXML != null)
              {
                  var parentXML = window.parent.getTopWindow().oXML;
                  var prentRowIds = new Array(selRowIds.length);
                  var i=0;                      
                  var aRows = parentXML.getElementsByTagName("rows")[0];
                  for(var j=0;j<aRows.childNodes.length;j++){
                      var rEle =  aRows.childNodes[j];
                      var oId = rEle.attributes.getNamedItem("o").nodeValue;
                      var rId = rEle.attributes.getNamedItem("r").nodeValue;
                      var pId = rEle.attributes.getNamedItem("p").nodeValue;
                      var lId = rEle.attributes.getNamedItem("id").nodeValue;
                      for (var k = 0; k<selRowIds.length; k++  )
                      {
                          var rowId = selRowIds[k];
                          var ids = rowId.split("|");
                          if(ids[0] == rId && ids[1] == oId && ids[2] == pId)
                          {
                              var parentRowIDs = rId+"|"+oId+"|"+pId+"|"+lId
                              prentRowIds[i] = parentRowIDs;
                              i++;
                          }
                      }
                  }
                  
                  for(var i =0; i<grpNos.length;i++){
                      var aRows = window.parent.getTopWindow().emxUICore.selectSingleNode(parentXML.documentElement,"/mxRoot/rows/r[@id='"+levelIds[i]+"']"); 
                     
                     aRows.removeAttribute("status");
                     for(var j=0;j<aRows.childNodes.length ;j++){                          
                                      var value = window.parent.getTopWindow().emxUICore.getText(aRows.childNodes[j]);
                                      if(j == 1){
                                         var objDOM = window.parent.getTopWindow().emxUICore.createXMLDOM();
                                         objDOM.loadXML("<c a='"+grpNos[i]+"'>"+grpNos[i]+"</c>");                       
                                         aRows.replaceChild(objDOM.documentElement,aRows.childNodes[j]);}
                                      else{
                                         aRows.childNodes[j].setAttribute("a",value);                
                                         }
                                      aRows.childNodes[j].setAttribute("edited","false");
                        }
                     }      
                  window.parent.getTopWindow().getWindowOpener().removeRows(prentRowIds);
                  //top.getWindowOpener().rebuildView();
                  window.parent.getTopWindow().location.href = window.parent.getTopWindow().location.href;                  
              }
              else
              {
                  window.parent.removeRows(selRowIds);
              }                                
              </script>
             
                <%   
        } catch (Exception e){
            e.printStackTrace();
        }
    }
    else
    {

        HashMap tableDataMap = indentedTableBean.getTableData(timeStamp);
        MapList partList = (MapList) tableDataMap.get("ObjectList");
        MapList originalPartList = (MapList) session.getAttribute("originalPartList");
        MapList nonRemovedPartsList = (MapList) session.getAttribute("nonRemoveParts");
        MapList removedPartList = (MapList) session.getAttribute("removedParts");
        MapList columnsList =(MapList)tableDataMap.get("columns");

        MapList updatedPartList = (MapList) session.getAttribute("Part List");
        boolean submit = true;
        if(updatedPartList == null)
        	nonRemovedPartsList=partList;

        LogicalFeature logicalfeatureBean = new LogicalFeature();
        
        com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
        formBean.processForm(session,request);
        
        String strMasterId = (String) formBean.getElementValue("objectId");
        
        String strNoOfFeature = (String) formBean.getElementValue("noOfTargetFeatures");
        
        int count = Integer.parseInt(strNoOfFeature);
        String[] strTargetIds = new String[count];
        for (int i = 0; i < count; i++) {
            strTargetIds[i] = (String) formBean.getElementValue("objectIDs"+ i);
        }
        
        
        Map programMap = new HashMap();
        programMap.put("FinalPartList",partList);
        String[] arrJPOArgs = (String[])JPO.packArgs(programMap);

        programMap.put("nonRemoveParts",partList);
        programMap.put("removedParts",removedPartList);
        programMap.put("UpdatedPartsList",updatedPartList);
        programMap.put("columns",columnsList);
        programMap.put("objectId",strMasterId); 
        programMap.put("noOfTargetFeatures",strNoOfFeature);
        programMap.put("selectedObjects",strTargetIds);
        if(submit)
        {
         //TODO Check all conditions

        logicalfeatureBean.mergeReplace(context,programMap);
        //Part.generateEquipmentReportForAllProducts(context,strObjectId,DomainConstants.EMPTY_STRING);
 
            %>
            <Script>
              //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
              
              getTopWindow().close();
              //getTopWindow().getWindowOpener().parent.location = getTopWindow().getWindowOpener().parent.location;
            </Script>
            <%
        }
    
    	
    }
    
}
     
     catch(Exception e)
     {
      
       if(session.getAttribute("error.message") == null){
          session.putValue("error.message", e.toString());
       }
      
     }
     %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>


