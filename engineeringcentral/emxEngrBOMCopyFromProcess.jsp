<%-- emxEngrBOMCopyFromProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.util.BOMMgtUIUtil"%>
<%@page import="com.dassault_systemes.enovia.bom.modeler.constants.BOMMgtConstants"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<jsp:useBean id="copyPart" class="com.matrixone.apps.engineering.Part" scope="session" />
<%
  boolean isMBOMInstalled = com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context);
  String strInput = "<mxRoot>";//<action><![CDATA[add]]></action><message><![CDATA[]]></message><data status=\"pending\">";
  String callbackFunctionName = "loadMarkUpXML";
  String failedToConnect = "";
  String ebomPartName = "";
  
  boolean isReplace = false;
  boolean isAppend = false;
  boolean isMerge = false;
  boolean blnFNsMatch = false;
 
  StringList tempList = new StringList();
  StringList mepSelectStmts = new StringList(2);
  StringList vecFN = new StringList();

  BusinessObjectWithSelect busWithSelect = null;
	//364521
  	//DomainObject selObj = DomainObject.newInstance(context);
  DomainObject selObj = new DomainObject();

  String objectId = emxGetParameter(request, "objectId");  
  String strSelPartId = emxGetParameter(request, "checkBox");  
  String selList = emxGetParameter(request, "selList");
  String AppendReplaceOption = emxGetParameter(request, "AppendReplaceOption");
  String isAVLReport = emxGetParameter(request,"AVLReport");
  String selPartRelId = emxGetParameter(request,"selPartRelId");
  String selPartObjectId = emxGetParameter(request,"selPartObjectId");  
  String selPartParentOId = emxGetParameter(request,"selPartParentOId");
  String frameName = emxGetParameter(request, "frameName");
  //Start : Added for IR-044888V6R2011
  String selPartRowId = (String) session.getAttribute("selPartRowId");
  session.removeAttribute("selPartRowId");
  //End : IR-044888V6R2011
	boolean blnFNsAppend = false;
	String sNewFNIncrement = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.StructureBrowser.FNIncrement");
  	String selPartFNAppend = "";
  	String selPartInstanceAppend = "";
  	String selPartInstanceDescAppend = "";
  	ArrayList<Integer> alFindNumb = new ArrayList<Integer>();
  	Iterator itrFN = null;
  	int sHighestFN = 0;

  if (AppendReplaceOption == null || "null".equals(AppendReplaceOption) || AppendReplaceOption.length() == 0)
  {
	  AppendReplaceOption = "Append";
  }
  if("Replace".equals(AppendReplaceOption))
  {
	  isReplace = true;
  }
  else if("Append".equals(AppendReplaceOption))
  {
	  isAppend = true;
  }
  else if("Merge".equals(AppendReplaceOption))
  {
	  isMerge = true;
  }

  if (selPartObjectId!=null && !selPartObjectId.equals("") && !selPartObjectId.equals("null")) {
  objectId = selPartObjectId;
  }
 
  String vpmControlState = "false".equalsIgnoreCase( BOMMgtUIUtil.getBOMColumnDesignCollaborationValue(context, selPartObjectId, null) ) ? "true" : "false";
  String strVPMVisibleTrue = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.TRUE");  
  String strVPMVisibleFalse = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.isVPMVisible.FALSE");
  boolean isENGSMBInstalled = EngineeringUtil.isENGSMBInstalled(context, false);
  
  //Start : IR-044888V6R2011
  strInput = strInput + "<object objectId=\"" + objectId + "\" rowId = \"" + selPartRowId + "\">";
  //End : IR-044888V6R2011
  Part partObj = new Part(objectId);
             
       if(isReplace) {
		StringList slObjectIds = (StringList)partObj.getInfoList(context, "from["+DomainConstants.RELATIONSHIP_EBOM+"]."+DomainConstants.SELECT_TO_ID);
		StringList slRelIds = (StringList)partObj.getInfoList(context, "from["+DomainConstants.RELATIONSHIP_EBOM+"].id");
		if(slObjectIds!=null && slRelIds!=null && slRelIds.size()==slObjectIds.size()){
			for(int i=0;i<slObjectIds.size();i++){
				String sNewObjId = (String)slObjectIds.get(i);
				String sNewRelId = (String)slRelIds.get(i);
				strInput = strInput + "<object objectId=\"" + sNewObjId + "\" relId=\"" + sNewRelId + "\" relType=\"relationship_EBOM\" markup=\"cut\"></object>";
	}
    }
  }
	//else if(isMerge){
	else if(isMerge || isAppend){
		vecFN = (StringList)partObj.getInfoList(context, "from["+DomainConstants.RELATIONSHIP_EBOM+"]."+DomainConstants.SELECT_FIND_NUMBER);
  }
	 if(isAppend){
 	   if(!vecFN.isEmpty()){
 		   itrFN = vecFN.iterator();
 		   while(itrFN.hasNext()){
 			 alFindNumb.add(Integer.parseInt((String)itrFN.next()));
 		   }
                            sHighestFN = Collections.max(alFindNumb);
 	   }
    } 


  mepSelectStmts.addElement(DomainConstants.SELECT_RELATIONSHIP_MANUFACTURER_EQUIVALENT_TO_ID);
  mepSelectStmts.addElement(DomainConstants.SELECT_LOCATION_EQUIVALENT_TO_ID);

  if(selList != null && !"".equals(selList))
  {
    String relType = DomainConstants.RELATIONSHIP_EBOM;
    String attrQuantity = DomainConstants.ATTRIBUTE_QUANTITY;
    String attrUsage = DomainConstants.ATTRIBUTE_USAGE;
    HashMap map = new HashMap();

    selList = selList.substring(0,selList.length() - 1);
    StringTokenizer st = new StringTokenizer(selList, ",");
    int count = st.countTokens();
    int storeCount = count;
%>
    <%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
  boolean flag=true;
    while(st.hasMoreTokens())
    {
      flag=true;

      //intHighestFN = intHighestFN + 10;

      String i = st.nextToken();

      try
      {
        ContextUtil.setSavePoint(context, "CopyEBOM");
        String selOid = emxGetParameter(request, "selId" + i);
        String selRelId = emxGetParameter(request, "selRelId" + i);
        String selPartInstanceReplace = (new DomainRelationship(selRelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_TITLE);
		String selPartInstanceDescReplace = (new DomainRelationship(selRelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_DESCRIPTION);
	// 365752
        String selFN = emxGetParameter(request, "selFN" + i);
        String selQTY = emxGetParameter(request, "selQTY" + i);
        String selUSG = emxGetParameter(request, "selUSG" + i);
        //Added for IR-097616V6R2012 starts                        
        //Multitenant
        /* String   strLangUsage = i18nNow.getI18nString("emxFramework.Range.Usage."+ selUSG.replaceAll(" ","_"),
                "emxFrameworkStringResource", context.getSession().getLanguage()); */
        String   strLangUsage =EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(),"emxFramework.Range.Usage."+ selUSG.replaceAll(" ","_"));
        //Added for IR-097616V6R2012 ends
        String selRD = emxGetParameter(request, "selRD" + i);
        String selCMPLOC = emxGetParameter(request, "selCMPLOC" + i);
        selCMPLOC = FrameworkUtil.findAndReplace(selCMPLOC,"&","&amp;");
        String selNOTE = emxGetParameter(request, "selNOTE" + i);
        String selSOURCE = emxGetParameter(request, "selSOURCE" + i);
        selNOTE = FrameworkUtil.findAndReplace(selNOTE,"&","&amp;");
        selSOURCE = FrameworkUtil.findAndReplace(selSOURCE,"&","&amp;");
        String selUOM = emxGetParameter(request, "selUOM" + i);

        //364521
        selObj.setId(selOid);

				try{
            if (isAVLReport.equalsIgnoreCase("TRUE")) {
				map=(HashMap)DomainRelationship.getAttributeMap(context,selRelId);
				        map.put(attrQuantity,"1");
				        map.put(attrUsage, "Standard");
                busWithSelect = selObj.select(context,mepSelectStmts);
                tempList = busWithSelect.getSelectDataList(DomainConstants.SELECT_RELATIONSHIP_MANUFACTURER_EQUIVALENT_TO_ID);
                if (tempList!=null) {
                    if (tempList.size()<=0) {
                        flag = false;
                    } else {
                        flag = true;
                    }
                } else  {
                    flag = false;
                }
                if (!flag) {
                    tempList = busWithSelect.getSelectDataList(DomainConstants.SELECT_LOCATION_EQUIVALENT_TO_ID);
                    if (tempList!=null) {
                        if (tempList.size()<=0) {
                            flag = false;
                        } else {
                            flag = true;
                        }
                    } 
                    else {
                        flag = false;
                    }
                }
            }
            if (flag) {
           boolean remove = false;
           if (count == storeCount && "Replace".equals(AppendReplaceOption)) {
           remove = true;
           count--;
           }
           if ("TRUE".equals(isAVLReport))
           {
          HashMap paramMap = new HashMap();
           paramMap.put("map", map);
           paramMap.put("selOid", selOid);
           paramMap.put("selPartRelId", selPartRelId);
           paramMap.put("selPartObjectId", selPartObjectId);
           paramMap.put("selPartParentOId", selPartParentOId);
           paramMap.put("objectId", objectId);
           paramMap.put("AppendReplaceOption", AppendReplaceOption);
           paramMap.put("strSelPartId", strSelPartId);
           //HF-028395
           //paramMap.put("remove", remove);
           paramMap.put("remove",Boolean.valueOf(remove));
           String[] methodargs = JPO.packArgs(paramMap);
           MapList retMap =(MapList)JPO.invoke(context, "emxPart", null, "copyPartFromBOM", methodargs, MapList.class);
	   }
						else
{
           
           if (isReplace) {
			    if(isMBOMInstalled){
//Modified for copy from Common View : Start
           strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">";
          //Modified for IR-097616V6R2012 	   
           strInput += "<column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column><column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\" edited=\"true\"  a=\""+selUSG+"\">"+strLangUsage+"</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
           strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
           strInput += "</object>";
                         //Modified for copy from Common View : End
				}else{				
												//Modified for copy from Common View : Start
           strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">";
           //Modified for IR-097616V6R2012            
           strInput += "<column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"InstanceTitle\" edited=\"true\">"+selPartInstanceReplace+"</column><column name=\"InstanceDescription\" edited=\"true\">"+selPartInstanceDescReplace+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column><column name=\"Usage\" edited=\"true\"  a=\""+selUSG+"\">"+strLangUsage+"</column>";
           
           if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
        	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>";
           } else {
        	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>";
           } 
           strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management           
           strInput += "</object>";
								//Modified for copy from Common View : End
				}
           }
           if(isAppend) {
			 selPartFNAppend = (new DomainRelationship(selRelId)).getAttributeValue(context,DomainConstants.ATTRIBUTE_FIND_NUMBER);
			 selPartInstanceAppend = (new DomainRelationship(selRelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_TITLE);
			 selPartInstanceDescAppend = (new DomainRelationship(selRelId)).getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_DESCRIPTION);
        	   
        	   if(alFindNumb.contains(Integer.parseInt(selPartFNAppend))){
        			
        		   selFN = String.valueOf((sHighestFN) +   Integer.parseInt(sNewFNIncrement));      	
   	     	 		blnFNsAppend = true;
   	     	} 
 
			    if(isMBOMInstalled){
//Modified for copy from Common View : Start
	   strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">";
	   //strInput = strInput + "<column name=\"Find Number\" edited=\"true\">"+intHighestFN+"</column>";
	   //Modified for IR-097616V6R2012 
           strInput += "<column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column><column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\" edited=\"true\"  a=\""+selUSG+"\">"+strLangUsage+"</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
           strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
			   strInput += "</object>";
                         //Modified for copy from Common View : End
				}else{
								//Modified for copy from Common View : Start
								strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\"Find Number\" edited=\"true\"></column>";
                                //Modified for IR-097616V6R2012 								
                                strInput += "<column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"InstanceTitle\" edited=\"true\">"+selPartInstanceAppend+"</column><column name=\"InstanceDescription\" edited=\"true\">"+selPartInstanceDescAppend+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column><column name=\"Usage\" edited=\"true\"  a=\""+selUSG+"\">"+strLangUsage+"</column>";
                                
                                if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
                             	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>";
                                } else {
                             	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>";
                                }
                                strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
								strInput += "</object>";
								//Modified for copy from Common View : End
				}
        	       if(Integer.parseInt(selFN) > sHighestFN){
                      sHighestFN = Integer.parseInt(selFN);
                      alFindNumb.add(sHighestFN);
              }else{
                   alFindNumb.add(Integer.parseInt(selFN));
               } 

		   }
           if(isMerge) {
	     Part selPartObj = new Part(strSelPartId);
	     	DomainRelationship dr = new DomainRelationship(selRelId);
	     	String selPartFN = dr.getAttributeValue(context,DomainConstants.ATTRIBUTE_FIND_NUMBER);
	    	String selPartInstanceTitle = dr.getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_TITLE);
	    	String selPartInstanceDescription = dr.getAttributeValue(context,BOMMgtConstants.ATTRIBUTE_EBOM_INSTANCE_DESCRIPTION);
				             if(vecFN.contains(selPartFN)) {
								 if(isMBOMInstalled){
									 //Modified for copy from Common View
			                         strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">";
									strInput +="<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\">Standard</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
									strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management				
											 //strInput += "<column name=\"Find Number\" edited=\"true\"></column><column name=\"Reference Designator\" edited=\"true\"></column>" + "</object>";
									strInput += "<column name=\"Find Number\" edited=\"true\"></column><column name=\"Reference Designator\" edited=\"true\"></column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column>" + "</object>";
								 }else{
			                       //strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">" + 
			                       //"<column name=\"Find Number\" edited=\"true\"></column><column name=\"Reference Designator\" edited=\"true\"></column>"; 
			                       strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\">" + 
			                       "<column name=\"Find Number\" edited=\"true\"></column><column name=\"InstanceTitle\" edited=\"true\">"+selPartInstanceTitle+"</column><column name=\"InstanceDescription\" edited=\"true\">"+selPartInstanceDescription+"</column><column name=\"Reference Designator\" edited=\"true\"></column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column>";
			                       
			                       if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
			                    	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>";
			                       } else {
			                    	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>";
			                       }
			                       strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
                                   strInput += "</object>";          
                                  }
			                         blnFNsMatch = true;
	         }
				             else {
								 if(isMBOMInstalled){
//Modified for copy from Common View
			                         strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column>";
                                                 //Modified for IR-097616V6R2012                                                  
                                                 strInput +="<column name=\"Manufacturing Part Usage\" edited=\"true\">Primary</column><column name=\"Usage\" edited=\"true\"  a=\""+selUSG+"\">"+strLangUsage+"</column><column name=\"Stype\">Unassigned</column><column name=\"Switch\">Yes</column><column name=\"Target Start Date\" edited=\"true\"></column><column name=\"Target End Date\" edited=\"true\"></column>";
                                                 strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
                                                 strInput +="</object>";
								 }else{
									//Modified for copy from Common View
                                                //Modified for IR-097616V6R2012 			                         
                                                strInput = strInput + "<object objectId=\"" + selOid + "\" relId=\"\" relType=\"relationship_EBOM\" markup=\"add\"><column name=\"Find Number\" edited=\"true\">"+selFN+"</column><column name=\"Reference Designator\" edited=\"true\">"+selRD+"</column><column name=\"Quantity\" edited=\"true\">"+selQTY+"</column><column name=\"Component Location\" edited=\"true\">"+selCMPLOC+"</column><column name=\"Notes\" edited=\"true\">"+selNOTE+"</column><column name=\"Source\" edited=\"true\">"+selSOURCE+"</column><column name=\"Usage\" edited=\"true\" a=\""+selUSG+"\">"+strLangUsage+"</column>";
                                                if(isENGSMBInstalled && "true".equalsIgnoreCase(vpmControlState)) { 
             			                    	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"False\">"+strVPMVisibleFalse+"</column>";
             			                       } else {
             			                    	   strInput += "<column name=\"VPMVisible\" edited=\"true\" actual=\"True\">"+strVPMVisibleTrue+"</column>";
             			                       }
                                                strInput = strInput + "<column name=\"UOM\" edited=\"true\" actual=\""+selUOM+"\" a=\""+selUOM+"\">"+ selUOM +"</column>"; //UOM Management
			                                    strInput +="</object>";
									           //Modified for copy from Common View - End
								 }
	       }
           }
           }
            } else {
			//364521
			//ebomPartName = selObj.getName(context);	
			ebomPartName = selObj.getInfo(context,DomainConstants.SELECT_NAME);
                if (failedToConnect.length()== 0) {
                    failedToConnect = ebomPartName;
                } else {
                    failedToConnect = failedToConnect + ", " +ebomPartName;
                }
            }
        }
        catch(Exception e)
        {
          ContextUtil.abortSavePoint(context, "CopyEBOM");
          session.putValue("error.message", e.toString());
          continue;
        }
      }
      catch(Exception Ex)
      {
        ContextUtil.abortSavePoint(context, "CopyEBOM");
        session.putValue("error.message", Ex.toString());
      }
    }

      strInput = strInput + "</object></mxRoot>";
      strInput = FrameworkUtil.findAndReplace(strInput,"'","\\\'");
     
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript">
	//XSSOK
	var isMBOMInstalled = "<%=isMBOMInstalled%>";
<%
    if (failedToConnect.length()!=0) {
%>
	  //XSSOK
      alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Part.AVL.NoManufacturingData</emxUtil:i18nScript>"+ " " + "<%=failedToConnect%>");
<%
    }
%>
//Added for 300389 
    if (getTopWindow().getWindowOpener() != null && !getTopWindow().getWindowOpener().closed)
    {
        if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().modalDialog)
        {
            getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
        }
    }
//till here


  var objWin = null;
	if(emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),"<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>")){
		objWin = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(),"<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>");
	}
	else{
		objWin =getTopWindow().getWindowOpener().parent;
	}
  if(getTopWindow().getWindowOpener().parent.name == "treeContent")
  {
     objWin=getTopWindow().getWindowOpener();
  }

 <%
  if (blnFNsMatch)
  {
 %>
alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOM.CopyFrom.FindNumbersMatch</emxUtil:i18nScript>");
<%
}
 if(blnFNsAppend){
	  %>
	  alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.BOM.CopyFrom.FindNumbersAppend</emxUtil:i18nScript>");
		 <% 
	 }
	%>



//if(isMBOMInstalled == "false"){
	//XSSOK
 if ("<%=XSSUtil.encodeForJavaScript(context,isAVLReport)%>" == "TRUE")
 {
	 //getTopWindow().getWindowOpener().location.href=getTopWindow().opener.location.href;
	 getTopWindow().getWindowOpener().location.href=getTopWindow().getWindowOpener().location.href;
 }
//}
  parent.closeWindow();
  if (objWin.emxEditableTable) {
     //Modified for 008394
     //Start : IR-044888V6R2011
       var xML           = '<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>';
     //XSSOK
       var prwId         = '<%=selPartRowId%>';
       var dupemxUICore  = objWin.emxUICore;
       var xMLdom        = dupemxUICore.createXMLDOM();
       xMLdom.loadXML(xML);
       dupemxUICore.checkDOMError(xMLdom);
       var getChildRowId = eval(objWin.emxEditableTable.prototype.getChildRowId);
       var oNodes        = dupemxUICore.selectNodes(xMLdom,"/mxRoot//object[@markup='cut']");        
      
      for(var i = 0; i < oNodes.length; i++)
      {
        var oNode = oNodes[i];
        var obId  = oNode.getAttribute("objectId");
        var rlId  = oNode.getAttribute("relId");
        var rwId  = getChildRowId(prwId, obId, rlId);
        oNode.setAttribute("rowId", rwId);
      }
     //XSSOK
      var callback = eval(objWin.emxEditableTable.prototype.<%=callbackFunctionName%>);
      var oxmlstatus = callback(xMLdom.xml, "true"); 
  } 
 //End : IR-044888V6R2011
</script>

<%
  }
  else
  {
%>
<script language="Javascript">
  parent.closeWindow();
</script>
<%
  }
%>
