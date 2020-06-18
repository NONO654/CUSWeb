<%--
  EffectivityUtil.jsp
  Copyright (c) 1993-2015 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException" %>
<%@page import="com.matrixone.apps.domain.util.mxType" %>
<%@page import="com.matrixone.apps.domain.util.CacheUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.json.JSONArray"%>
<%@page import="com.matrixone.json.JSONObject"%>
<%@page import="matrix.util.StringList" %>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.TimeZone"%>
<%@page import = "java.util.Calendar"%>
<%@page import="com.matrixone.apps.domain.util.eMatrixDateFormat" %>
<%@page import = "com.matrixone.apps.effectivity.EffectivityFramework"%>
<%@page import="com.matrixone.json.JSONObject"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Scanner"%>
<%@page import="java.text.DateFormat"%>
<script language="JavaScript" type="text/javascript" src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  out.clear();
  boolean bIsError = false;
  try
  {
     String strMode = emxGetParameter(request, "mode");
     String effType = emxGetParameter(request, "effType");
     String effExpr = emxGetParameter(request,"effExpr");
     if(effExpr!=null && !effExpr.equals("")){
        effExpr = effExpr.replace("\\x22","\"");

			if(effType != null && effType.contains("Date")){
			JSONObject jsonObj1 = new JSONObject(effExpr);
			JSONArray dateArray = jsonObj1.getJSONArray("values");
			for (int i = 0; i < dateArray.length(); i++) {
				String sDate = dateArray.get(i).toString();
				Scanner scanner = new Scanner(sDate);
				// Code Added to handle use case when the date value is passed as Millisecs  
				if (scanner.hasNextLong()) {
					
					TimeZone tz = TimeZone.getTimeZone(context.getSession().getTimezone());
					int tzoff = tz.getRawOffset();
					Double timezone = new Double((-1) * ((tzoff )/(3600000)));
					
					Locale locale = context.getLocale();
				    if(context.getSession() != null){
				    	locale = MessageUtil.getLocale(context);
				    }
				    
					Date vDate = new Date((Long.parseLong(sDate)));
					//DateFormat formatter = new SimpleDateFormat("MM/dd/yyyy hh:mm:ss aa");
					DateFormat formatter = new SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat());
					int iDateFormat = DateFormat.SHORT + 1;
					String dateFormatted = formatter.format(vDate);
					dateFormatted = eMatrixDateFormat
							.getFormattedDisplayDateTime(dateFormatted,
									false, iDateFormat, timezone,
									locale);

					dateArray.put(i, dateFormatted);
					System.out.println(dateFormatted);
				}
			}
			effExpr=jsonObj1.toString();
			}
      }
     String strDisplay = emxGetParameter(request, "displayString");
     String strActual = emxGetParameter(request, "actualString");
     String keyInValue = emxGetParameter(request, "keyInValue");
     String infinitySymbolAct = EffectivityFramework.INFINITY_SYMBOL_STORAGE;
     String rangeSeparatorStorage = EffectivityFramework.RANGE_SEPARATOR_STORAGE;
     String valueSeparatorStorage = EffectivityFramework.VALUE_SEPARATOR_STORAGE;
     String openSeriesBracket = EffectivityFramework.SERIES_OPEN_BRACKET;
     String closeSeriesBracket = EffectivityFramework.SERIES_CLOSE_BRACKET;
     double iClientTimeOffset = (new Double((String)session.getAttribute("timeZone"))).doubleValue();
     String currentEffExprActual = emxGetParameter(request, "currentEffExprActual");
     String includeContextList = emxGetParameter(request, "includeContextList");
     String globalContextPhyId = emxGetParameter(request, "globalContextPhyId");
     String filterMode = emxGetParameter(request, "filterMode");   
      
     
     
     
     String sEffectivityUsageRel = PropertyUtil.getSchemaProperty("relationship_EffectivityUsage");
     
     // setting the preference 
     if(strMode != null && strMode.equalsIgnoreCase("framePref")){   	 
   	  String  sFrameName = emxGetParameter(request, "vFrameName");   	
   	  String frameValue = sFrameName;
   	  String frameActual= frameValue.substring(6);
   	
   	   PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_EffTypeModified", frameActual);
     }
     
     //// setting the preference 
     if(strMode != null && strMode.equalsIgnoreCase("getFramePref")){
    	String framePreference =PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_EffTypeModified");
  	    
  	      out.write(framePreference);
      	   
        }
     if(strMode != null && strMode.equalsIgnoreCase("getPhysicalId")){
    	 String strMpId = emxGetParameter(request, "mpId");
    	 DomainObject domMp = new DomainObject(strMpId);
    	 String strMPPhysicalId = domMp.getInfo(context,"physicalid");
   	     
    		out.write(strMPPhysicalId);
       	   
         }
     EffectivityFramework EFF = new EffectivityFramework();
     if (strMode!= null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("format"))
     {  
         String isENO_ECH = emxGetParameter(request, "ENO_ECH");
         if(isENO_ECH != null && "true".equalsIgnoreCase(isENO_ECH)){
             PropertyUtil.setGlobalRPEValue(context, "ENO_ECH", "true");
         }
         
         Map mapExpr = EFF.formatExpression(context, effType, effExpr);
         String strActualString = (String)mapExpr.get(EFF.ACTUAL_VALUE);
         String strDisplayString = (String)mapExpr.get(EFF.DISPLAY_VALUE);
         StringBuffer sb = new StringBuffer();
         sb.append(strActualString);
         sb.append("-@ActualDisplay@-");
         sb.append(strDisplayString);

         out.write(sb.toString());
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("getDisplayExpression") && effExpr != null){
         //parse the input from the browser in order to get a json object
         JSONObject appObjsJSON = new JSONObject(effExpr);       
         Iterator<String> appObjsJSONKeysItr = appObjsJSON.keys();
         StringList contextModelList = new StringList();
         //get a list of context Model ids
         while (appObjsJSONKeysItr.hasNext()) {
             String appObjsJSONKey = appObjsJSONKeysItr.next();
             JSONObject appObjJSON = new JSONObject(appObjsJSON.getString(appObjsJSONKey));
             if (appObjJSON!=null) {
                 String contextId = appObjJSON.getString("contextId");
                 if(!contextModelList.contains(contextId)){
                     contextModelList.add(contextId);
                 }
             }
         }
         //get display expression for each context and concatenate them with OR
         StringBuffer formatedStringBuf = new StringBuffer();
         int index = 0;
         for(int i=0; i < contextModelList.size(); i++){
             String contextId = (String)contextModelList.get(i);
             Iterator<String> appObjsJSONKeysItr2 = appObjsJSON.keys();
             MapList appObjMapList = new MapList();
             while (appObjsJSONKeysItr2.hasNext()) {
                 String appObjsJSONKey = appObjsJSONKeysItr2.next();
                 index = Integer.parseInt(appObjsJSONKey);                               
                 JSONObject appObjJSON = new JSONObject(appObjsJSON.getString(appObjsJSONKey));
                 if (appObjJSON!=null) {
                     //get all objects connected to same context model
                     String appObjJSONContextid = appObjJSON.getString("contextId");
                     if(contextId.equals(appObjJSONContextid)){
                         HashMap appObjMap = new HashMap();
                         appObjMap.put(DomainObject.SELECT_ID, appObjJSON.getString("objId"));
                         appObjMap.put(DomainObject.SELECT_TYPE, appObjJSON.getString("objType"));
                         appObjMap.put(DomainObject.SELECT_NAME, appObjJSON.getString("objName"));
                         appObjMap.put(DomainObject.SELECT_REVISION, appObjJSON.getString("seqSel"));
                         appObjMap.put("physicalid", appObjJSON.getString("physicalid"));
                         //temporary attribute - this index serves for positioning selections as sent in
                         appObjMap.put("index", appObjsJSONKey);
                         appObjMapList.add(appObjMap);
                     }
                 }
             }//End of while appObjsJSONKeysItr2
             HashMap objListMap = new HashMap();
             objListMap.put("contextModelId", contextId);
             //This does not sort the data in the list but rather options in select list
             appObjMapList.sort("index", "ascending", "string");
             objListMap.put("applicableItemsList", appObjMapList);
             if(formatedStringBuf.length() > 0){
                 formatedStringBuf.append(" OR ");
             }
             //format expression: the format is based on .xsl template           
             formatedStringBuf.append(EFF.getDisplayExpression(context, objListMap));
         }
         String displayExpression = formatedStringBuf.toString();
         displayExpression = displayExpression.replace("<", "\u003C");
         out.write(displayExpression);
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("ValidateExpression")){

         ArrayList lstExpression = new ArrayList();
         String strPdtId = emxGetParameter(request, "ContextId");
         String strExpression = emxGetParameter(request, "LeftExpression");
         
         if(!strExpression.equalsIgnoreCase(""))
         {    
             StringTokenizer stSel = new StringTokenizer(strExpression,",",false);
             String strFtrSelLstId = null;
             while (stSel.hasMoreElements())
             {
                  strFtrSelLstId=(String)stSel.nextElement();
                  lstExpression.add(strFtrSelLstId);
             }
         }
         
         boolean bLeftExpValid  = EffectivityFramework.validateExpression(context ,lstExpression ,'"');
         out.println(bLeftExpValid);

     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equals("ValidateActualExpression")){
         String actualExpression = emxGetParameter(request, "actualExpression"); 
         boolean bActualExpValid = true;
         try 
         {
             bActualExpValid  = EffectivityFramework.validateExpression(context ,actualExpression);
             out.println(bActualExpValid);
         }
         catch(Exception e)
         {
             out.println(e.getMessage());
         }
     }     
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("effectivityToolbar"))
     {
         String strEffExprnDisplay = emxGetParameter(request, "CFFEffectivityExpressionInput");  
         String strEffExprnActual = emxGetParameter(request, "CFFEffectivityExpressionInput_actualValue");
         
         // the controle comes in this if condition when the 'Filter' button from the effectivity toolbar is clicked.
         // TODO => Invoke the apporpriate API to filter the structure based on the effectivity criteria available in 'strEffExprnDisplay' & 'strEffExprnActual' variable
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("CompareRoot"))
     {
         
         try
         {
             String strSearchType = emxGetParameter(request, "searchType");  
             String strSearchTypeAdmin =  PropertyUtil.getSchemaProperty(context,strSearchType);
             String strObjectId = emxGetParameter(request, "objectId");
             String strParentOID = emxGetParameter(request, "parentOID");
             String strRootType = emxGetParameter(request, "rootType");
             
             if(strRootType == null)
             {
                 if(strObjectId != null)
                 {
                     DomainObject rootDom = new DomainObject(strObjectId);
                   strRootType = rootDom.getInfo(context, DomainConstants.SELECT_TYPE);
                 }
                 if(strParentOID != null && !"".equals(strParentOID) && !"null".equalsIgnoreCase(strParentOID))
                 {
                     DomainObject rootDom = new DomainObject(strParentOID);
                    strRootType = rootDom.getInfo(context, DomainConstants.SELECT_TYPE);
                 }
             }
             if(strRootType != null)
             {
                 if(mxType.isOfParentType(context, strRootType,
                         strSearchTypeAdmin))
                 {
                     out.println(true);
                 }
                 else
                 {
                     out.println(false);
                 }   
             }
             else
             {
                 out.println(false);
             }
             
         }
         catch(Exception e)
         {
             System.out.println( " exp " +e);
         }
     }
     else if (strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getBinary"))
     {
         Map binaryMap = EFF.getFilterCompiledBinary(context, effExpr, filterMode);
         String compiledBinary = (String)binaryMap.get(EFF.COMPILED_BINARY_EXPR);
         out.write(compiledBinary);
     }
     else if("saveEffectivity".equalsIgnoreCase(strMode))
     {
         try
         {
             String strId = emxGetParameter(request, "relId");
             String streffExpr = emxGetParameter(request, "actualExp");

             HashMap paramMap = new HashMap();
             HashMap programMap = new HashMap();

             paramMap.put("relId", strId);
             paramMap.put("New Value", streffExpr);

             programMap.put("paramMap", paramMap);

             String[] args = JPO.packArgs(programMap);

             EffectivityFramework ef = new EffectivityFramework();
             ef.updateRelExpression(context, args);

         }catch(Exception ex)
         {
             out.println("ERROR:"+ex.getMessage());
         }
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("showKeyInEditor"))
     {
         if(strDisplay.contains(openSeriesBracket) && strDisplay.contains(closeSeriesBracket))
         {
             EffectivityFramework ef = new EffectivityFramework();
             String effectivity = strDisplay.substring(strDisplay.indexOf(openSeriesBracket)+1,strDisplay.indexOf(closeSeriesBracket));
             CharSequence csInfKeyIn = ef.getInfinitySymbolKeyIn(context);
             CharSequence csInfStore = EffectivityFramework.INFINITY_SYMBOL_STORAGE;
             CharSequence csInfDisp = ef.getInfinitySymbolDisplay(context);
             if(effectivity.contains(csInfDisp))
             {
                 effectivity =  effectivity.replace(csInfDisp,csInfKeyIn);
             }
             out.write(effectivity);   
         }
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("keyIn"))
     {
         EffectivityFramework ef = new EffectivityFramework();
         ef.setDisplaySeparators(context,effType);
         StringBuffer sb =  new StringBuffer();
         StringBuffer sb1 =  new StringBuffer();
         String rangeSeparatordisplay = ef.RANGE_SEPARATOR_DISPLAY;
         String valueSeparatordisplay = ef.VALUE_SEPARATOR_DISPLAY;
         CharSequence csInfKeyIn = ef.getInfinitySymbolKeyIn(context);
         CharSequence csInfStore = EffectivityFramework.INFINITY_SYMBOL_STORAGE;
         CharSequence csRangeSeparatordisplay = rangeSeparatordisplay;
         CharSequence csValueSeparatordisplay = valueSeparatordisplay;
         CharSequence csInfDisp = ef.getInfinitySymbolDisplay(context);
         String keyInStorage = keyInValue;
         if(keyInStorage.contains(rangeSeparatordisplay))
         {
             keyInStorage = keyInStorage.replace(rangeSeparatordisplay,rangeSeparatorStorage);   
         }
         if(keyInStorage.contains(valueSeparatordisplay))
         {
             keyInStorage = keyInStorage.replace(valueSeparatordisplay,valueSeparatorStorage);     
         }
         if(keyInValue.contains(csInfKeyIn))
         {
             keyInStorage = keyInStorage.replace(csInfKeyIn,csInfStore);
             keyInValue =  keyInValue.replace(csInfKeyIn,csInfDisp);
         }
         try
         {
             if(strDisplay.contains(openSeriesBracket) && strDisplay.contains(closeSeriesBracket))
             {
                 String effectivity = strDisplay.substring(strDisplay.indexOf(openSeriesBracket)+1,strDisplay.indexOf(closeSeriesBracket));
                 if(effectivity.equalsIgnoreCase(""))
                 {
                    
                     sb.append(strDisplay);
                     sb.insert(strDisplay.indexOf(openSeriesBracket)+1,keyInValue);
                     sb.append("-@displayActual@-");
                     sb1.append(strActual);
                     sb1.insert(strActual.indexOf(openSeriesBracket)+1,keyInStorage);
                 }
                 else
                 {
                     sb.append(strDisplay);
                     sb.replace(strDisplay.indexOf(openSeriesBracket)+1,strDisplay.indexOf(closeSeriesBracket),keyInValue);
                     sb.append("-@displayActual@-");
                     sb1.append(strActual);
                     sb1.replace(strActual.indexOf(openSeriesBracket)+1,strActual.indexOf(closeSeriesBracket),keyInStorage);
                 }
                 sb.append(sb1.toString());
                 out.write(sb.toString());   
             }
         }
         catch(StringIndexOutOfBoundsException e)
         {
             e.printStackTrace();
         }
         catch(Exception e)
         {
               System.out.println("Problem in Key In");
         }
         
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("infinity"))
     {
         StringBuffer sb =  new StringBuffer();
         try
         {
             EffectivityFramework ef = new EffectivityFramework();
             String infinitySymbolDisp = ef.getInfinitySymbolDisplay(context);
             ef.setDisplaySeparators(context,effType);
             String rangeSeparatorDisplay = ef.RANGE_SEPARATOR_DISPLAY;
             if(strDisplay.contains(openSeriesBracket) && strDisplay.contains(closeSeriesBracket))
             {
             String check = strDisplay.substring(strDisplay.indexOf(openSeriesBracket),strDisplay.indexOf(closeSeriesBracket)+1);
             if(check!= null && check.contains(rangeSeparatorDisplay))
             {
                 int openSeriesIdx = check.indexOf(openSeriesBracket);
                 int closeSeriesIdx = check.indexOf(closeSeriesBracket);
                 int rangeSeparatorIdx = check.indexOf(rangeSeparatorDisplay);
                 String startRange = null;
                 String endRange = null;
                 if(openSeriesIdx != -1)
                 {
                      startRange = check.substring(openSeriesIdx+1,rangeSeparatorIdx);
                 }
                 if(closeSeriesIdx != -1)
                 {
                     endRange = check.substring(rangeSeparatorIdx+1,closeSeriesIdx);     
                 }
                 //int replaceIndex = strDisplay.indexOf(closeSeriesBracket.charAt(0))-1;
                 //int replaceIndex = strDisplay.indexOf(rangeSeparatorStorage.charAt(0))+1;
                 int replaceIndex = strDisplay.indexOf(openSeriesBracket)+check.indexOf(rangeSeparatorDisplay.charAt(0))+1;
                 if(startRange.equalsIgnoreCase(endRange))
                 {
                     closeSeriesIdx = strDisplay.indexOf(closeSeriesBracket);
                     String str =strDisplay.replace(strDisplay.substring(replaceIndex,closeSeriesIdx+1),infinitySymbolDisp+closeSeriesBracket);
                     sb.append(str);
                     sb.append("-@displayActual@-");
                     closeSeriesIdx = strActual.indexOf(closeSeriesBracket);
                     replaceIndex = strActual.indexOf(rangeSeparatorStorage.charAt(0))+1;
                     str =strActual.replace(strActual.substring(replaceIndex,closeSeriesIdx+1),infinitySymbolAct+closeSeriesBracket);
                     sb.append(str);
                     out.write(sb.toString());   
                 }
                 else
                 {
                     sb.append("Invalid_Infinity");
                     out.write(sb.toString());   
                 }
             }
             else
             {
                    sb.append("Invalid_Infinity");
                    out.write(sb.toString());   
             }
             }
             else
             {
                 sb.append("Invalid_Infinity");
                 out.write(sb.toString());   
             }
         }
         catch(Exception e)
         {
             System.out.println("Exception e"+e.getMessage());
         }
        
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getObjectInfo"))
     {
         StringList sListSelectables = new StringList();
         String sParam = null;
         String sObjectID = null;
         String sOutput = null;
         EffectivityFramework Eff = new EffectivityFramework();
         
         //1. Get the Object ID;
         sObjectID = emxGetParameter(request, "objectId");
         if(sObjectID != null)
         {
         
        sParam = emxGetParameter(request, "Parameter");
        if(sParam != null)
        {
                 // 2. Get the Parameter: is comma separated list
                // returned values are also comma separated
               sParam = emxGetParameter(request, "Parameter");
               if(sParam != null)
            {
                
                   if(sParam.equalsIgnoreCase("formattedname"))
                    {
                        sListSelectables.addElement(DomainObject.SELECT_NAME);
                        sListSelectables.addElement(DomainObject.SELECT_TYPE);
                  
                        
                        Map objInfo = Eff.getObjectInfo(context, sObjectID, sListSelectables);
                        
                        String sObjName = (String)objInfo.get(DomainObject.SELECT_NAME);
                        String sObjType = (String)objInfo.get(DomainObject.SELECT_TYPE);
               
                        
                       //Get the formatted name
                        sOutput = Eff.getFormattedName(context,sObjectID,sObjType,sObjName);
                        
                   } else { //comma separated string param                     
                       if(sOutput == null){
                           sOutput = "";
                        }
                       sListSelectables = FrameworkUtil.split(sParam, ",");
                       DomainObject dmObj = DomainObject.newInstance(context, sObjectID);
                       Map objInfo = dmObj.getInfo(context, sListSelectables);
                       for(int i=0; i < sListSelectables.size(); i++){
                           if(sOutput.length() < 1){
                               sOutput = (String)objInfo.get(sListSelectables.get(i));
                           } else {
                               sOutput += "," + (String)objInfo.get(sListSelectables.get(i));
        }
                       }                       
                   }                
               }
   
                //Send the output
        out.print(sOutput);
          
            }
         }
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getEffTypeSetting"))
     {
         String sSettingName = emxGetParameter(request, "settingName");
         String sEffType = emxGetParameter(request, "effType");
         String sOutput = null;
         if(sSettingName != null && sEffType != null && !sSettingName.trim().isEmpty() && !sEffType.trim().isEmpty())
         {
         
               Map effSettings = EFF.getEffectivityTypeSettings(context);
         
               if(effSettings != null)
               {
                    Map currentEffTypeSettings = (Map)effSettings.get(sEffType);
                    
                    if(currentEffTypeSettings != null)
                    {
                        sOutput = (String)currentEffTypeSettings.get(sSettingName);
                            
                    }
               }
         }
         if(sOutput != null)
         {
               out.write(sOutput);
                 out.flush();
         }
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getSeparators"))
     {
         EffectivityFramework ef = new EffectivityFramework();
         ef.setDisplaySeparators(context,effType);
         String rangeSeparatorDisplay = ef.RANGE_SEPARATOR_DISPLAY;
         String valueSeparatorDisplay = ef.VALUE_SEPARATOR_DISPLAY;
         StringBuffer sb =  new StringBuffer(30);
         sb.append("<Separators");
         sb.append(" rangeSeparator =");
         sb.append("\"");
         sb.append(rangeSeparatorDisplay);
         sb.append("\"");
         sb.append(" valueSeparator =");
         sb.append("\"");
         sb.append(valueSeparatorDisplay);
         sb.append("\"");
         sb.append("></Separators>");
         out.write(sb.toString()); 
         out.flush();
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getContextsFromSavedSearchResults"))
     {       
         String contextsString = "";

         //1. get Most Recent Search Results for Effectivity Type
         StringList mrsrList = (StringList)CacheUtil.getCacheObject(context, "MostRecentContextSearchResults");
         if(mrsrList != null && mrsrList.size() > 0){
             for(int n=0; n < mrsrList.size(); n++){
                String tmpId = (String)mrsrList.get(n);
                contextsString += (contextsString.length() > 0)?"|"+tmpId:tmpId;     
             }       
         }       
         
         out.write(contextsString);
         out.flush();
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("removeSavedContexts"))
     {
         StringList removedList = (StringList) CacheUtil.removeCacheObject(context, "MostRecentContextSearchResults");
         out.flush();
     }
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getContextsMap")){
         JSONArray cxtJsonArray = new JSONArray();
         if(currentEffExprActual != null && currentEffExprActual.length() > 0){
             Map cxtsMap = EFF.getEffectivityByContext(context, currentEffExprActual);
             if(cxtsMap != null && cxtsMap.size() > 0){
                 
                 for(Iterator cxtItr = cxtsMap.keySet().iterator();cxtItr.hasNext();){
                     String cxtPhysicalId = (String)cxtItr.next();
                     /*
                     if(cxtPhysicalId == null || "null".equalsIgnoreCase(cxtPhysicalId) || cxtPhysicalId.length() < 1){
                         continue;
                     }
                     */
                     JSONObject cxtJson = new JSONObject();
                     
                     if((cxtPhysicalId == null || "null".equalsIgnoreCase(cxtPhysicalId)) ||
                         //(globalContextPhyId != null && globalContextPhyId.equalsIgnoreCase(cxtPhysicalId))){
                         "Global".equalsIgnoreCase(cxtPhysicalId)){
                         cxtJson.put("contextId",globalContextPhyId);
                     //  cxtJson.put(EFF.DISPLAY_VALUE, "Global");
                     } else {
                         cxtJson.put("contextId",cxtPhysicalId);
                     //  cxtJson.put(EFF.DISPLAY_VALUE,((Map)cxtsMap.get(cxtPhysicalId)).get(EFF.DISPLAY_VALUE));
                     }
                     
                     //cxtJson.put("contextId",cxtPhysicalId);
                     cxtJson.put("validated","true");
                     
                     List listValue = (List)((Map)cxtsMap.get(cxtPhysicalId)).get(EFF.LIST_VALUE);  
                     List listValueActual = (List)((Map)cxtsMap.get(cxtPhysicalId)).get(EFF.LIST_VALUE_ACTUAL);
                     StringBuffer sbListValue = new StringBuffer();
                     for(int i=0;i<listValue.size();i++){
                        sbListValue.append(listValue.get(i));
                        sbListValue.append("@delimitter@");
                     }
                     
                     String strListValue = sbListValue.toString();
                     sbListValue.delete(0, sbListValue.length());
                     for(int i=0;i<listValueActual.size();i++){
                        sbListValue.append(listValueActual.get(i));
                        sbListValue.append("@delimitter@");
                     }
                     
                     String quoteSeparatedIds = strListValue.substring(0, strListValue.length());
                     String strListValueAc = sbListValue.toString();
                     String quoteSeparatedIdsAc = strListValueAc.substring(0, strListValueAc.length());                  
                     
                     cxtJson.put(EFF.DISPLAY_VALUE,((Map)cxtsMap.get(cxtPhysicalId)).get(EFF.DISPLAY_VALUE));
                     cxtJson.put(EFF.ACTUAL_VALUE,((Map)cxtsMap.get(cxtPhysicalId)).get(EFF.ACTUAL_VALUE));
                     cxtJson.put("contextRuleTextList",strListValue.substring(0, strListValue.length()));
                     cxtJson.put("contextRuleActualList",strListValueAc.substring(0, strListValueAc.length()));
                     cxtJsonArray.put(cxtJson);            
                 }
             }           
         }
         out.write(cxtJsonArray.toString());
         out.flush();
     } 
     else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getContextsForSelect"))
     {       
         JSONArray cxtJsonArray = new JSONArray();       
         if(includeContextList != null && !"null".equalsIgnoreCase(includeContextList) && includeContextList.length() > 0){
            StringList idUniqList = new StringList();
            StringList idsList = FrameworkUtil.split(includeContextList, "|");          
            String[] idArray = new String[idsList.size()];

            for(int n=0; n < idsList.size(); n++){
                String nullStr = (String)idsList.get(n);
                if(nullStr != null && !"null".equalsIgnoreCase(nullStr)){
                    idArray[n] = (String)idsList.get(n);        
                }               
            }
            
            StringList selects = new StringList(5);
            selects.add(DomainObject.SELECT_ID);
            selects.add(DomainObject.SELECT_TYPE);
            selects.add(DomainObject.SELECT_NAME);
            selects.add(DomainObject.SELECT_REVISION);
            selects.add("physicalid");
            
            MapList cxtMapList = DomainObject.getInfo(context, idArray, selects);
            
            if(cxtMapList != null && cxtMapList.size() > 0){
                for(int i=0; i < cxtMapList.size(); i++)
                {
                    Map cxtMap = (Map)cxtMapList.get(i);
                    if(cxtMap != null)
                    {                       
                        String sCxtDisplay = (String)cxtMap.get(DomainObject.SELECT_NAME);
                        if(sCxtDisplay != null && !sCxtDisplay.trim().isEmpty()&& !sCxtDisplay.equalsIgnoreCase("Global")){
                            String revisionStr = (String)cxtMap.get(DomainObject.SELECT_REVISION);
                            String physicalId = (String)cxtMap.get("physicalid");
                            String cxtId = (String)cxtMap.get(DomainObject.SELECT_ID);
                            //continue if it's already processed
                            if(idUniqList.contains(cxtId)){
                                continue;   
                            } else {
                                idUniqList.add(cxtId);
                            }
                            
                            sCxtDisplay += (revisionStr != null)? " " + revisionStr:"";
                            String sCxtActual = (String)cxtMap.get(DomainObject.SELECT_ID);
                            String sCxtActualType = (String)cxtMap.get(DomainObject.SELECT_TYPE);
                            if(sCxtDisplay != null && !sCxtActual.trim().isEmpty() && sCxtActual != null && !sCxtActual.trim().isEmpty())
                            {
                                JSONObject cxtObj = new JSONObject();
                                cxtObj.put("displayValue", sCxtDisplay);
                                cxtObj.put("actualValue", sCxtActual);
                                cxtObj.put("typeIcon", UINavigatorUtil.getTypeIconProperty(context, sCxtActualType));
                                cxtObj.put("physicalid", physicalId);
                                cxtJsonArray.put(cxtObj);
                            }
                            
                        }
                        
                    }
            
                }           
            }
         }
         out.write(cxtJsonArray.toString());
         out.flush();
     }else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("relVariesByExists"))
     {
         boolean bVariesBy = false;
         //1. Get the Object ID;
         String sObjectID = null;
         sObjectID = emxGetParameter(request, "vContxtLFId");        
         if(sObjectID != null && !"null".equalsIgnoreCase(sObjectID) && sObjectID.length() > 0){
             DomainObject dom = DomainObject.newInstance(context, sObjectID);
             String relVariesBy = PropertyUtil.getSchemaProperty(context, "relationship_VariesBy");
             Boolean strListDesignVariants= dom.hasRelatedObjects(context,relVariesBy,true);
             if (strListDesignVariants) {
                 bVariesBy = true;
             }
         }
         out.println(bVariesBy);
     }else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getRelationshipId"))
     {
         //1. Get the Object ID;
         String sColumnId = emxGetParameter(request, "ColumnId");
         String sValueSelectedInCell = emxGetParameter(request, "ValueSelectedInCell");
         
			//1. Get the Rel ID;

			String strMqlCmd = "expand bus $1 from relationship $2 select $3 $4 where $5 dump $6 ";
			String sRelId = MqlUtil.mqlCommand(context, strMqlCmd,
					true, sColumnId, "CONFIGURATION STRUCTURES", "rel",
					"id", "to.id == " + sValueSelectedInCell, "|");

			StringTokenizer selRelTokenizer = new StringTokenizer(sRelId, "|");

			while (selRelTokenizer.hasMoreTokens()) {
				sRelId = selRelTokenizer.nextToken();
			}
			if (sRelId == null) {
				sRelId = "";
			}
			String strTempRelId[] = sRelId.split("\n");
			sRelId = strTempRelId[0];

			out.println(sRelId);
     }else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getCellValueObjectId"))
     {
         //1. Get the Object ID
         String sColumnId = emxGetParameter(request, "ColumnId");
         String sRelId = emxGetParameter(request, "RelId");
         
            //TODO : below business Logic needs to be added JPO/bean
            //Relationshipid LF/GBOM
            //Get Info related to this rel id and display the value for given column
            StringBuffer sbSelOptInfo  = new StringBuffer();
            DomainRelationship domRel = new DomainRelationship(sRelId);
            StringList relInfoList = new StringList();
            relInfoList.addElement(DomainConstants.SELECT_TO_ID);
            
            relInfoList.addElement("frommid["+sEffectivityUsageRel+"].torel.to.id");
            relInfoList.addElement("frommid["+sEffectivityUsageRel+"].torel.to.name");
            relInfoList.addElement("frommid["+sEffectivityUsageRel+"].torel.from.id");
            relInfoList.addElement("frommid["+sEffectivityUsageRel+"].torel.id");
            
            Map relInfoMap = domRel.getRelationshipData(context, relInfoList);
            String strFeatureId = (String) ((StringList) relInfoMap.get(DomainConstants.SELECT_TO_ID)).get(0);
            
            Object objDVSelOptionId = relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.to.id");
            Object objDVColumnId = relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.from.id");
            Object objDVSelOptionRelId = relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.id");
            
            StringList sLDVSelOptionId = new StringList();
            StringList sLDVColumnId = new StringList();
            StringList sLDVSelOptionRelId = new StringList();
            
            if(objDVSelOptionId!=null)
            {
                 if(objDVSelOptionId instanceof StringList)
                 {
                     sLDVSelOptionId = (StringList)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.to.id");
                     sLDVSelOptionRelId = (StringList)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.id");
                     
                 }else if(objDVSelOptionId instanceof String)
                 {
                     sLDVSelOptionId.addElement((String)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.to.id"));
                     sLDVSelOptionRelId.addElement((String)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.id"));
                 }
            }
            
            if(objDVColumnId!=null)
            {
                 if(objDVColumnId instanceof StringList)
                 {
                     sLDVColumnId = (StringList)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.from.id");
                     
                 }else if(objDVColumnId instanceof String)
                 {
                     sLDVColumnId.addElement((String)relInfoMap.get("frommid["+sEffectivityUsageRel+"].torel.from.id"));
                 }
            }
            
            for(int iCnt=0;iCnt<sLDVColumnId.size();iCnt++){
                String strDVColumnId = (String)sLDVColumnId.get(iCnt);
                String strDVColumnName = (String)sLDVSelOptionId.get(iCnt);
                String strDVSelOptionRelId = (String)sLDVSelOptionRelId.get(iCnt);
                
                if(sColumnId!=null && sColumnId.equals(strDVColumnId)){
                    sbSelOptInfo.append(strDVColumnName);
                    sbSelOptInfo.append("|");
                    sbSelOptInfo.append(strDVSelOptionRelId);
                }
            }
            out.println(sbSelOptInfo.toString());
     }else if(strMode != null && !("").equalsIgnoreCase(strMode) && strMode.equalsIgnoreCase("getModelCriterias"))
     {
    	 String modelId = emxGetParameter(request, "modelId");
    	 List<String> ModelIDsToLoad = new ArrayList<String>();
    	 ModelIDsToLoad.add(modelId);
    	 StringList criteriaList = EFF.getModelCriteria(context, ModelIDsToLoad);
    	 String ModelCriteria = "";
    	 for (Iterator dictStrItr = criteriaList.iterator(); dictStrItr.hasNext();)
    	 {
    		 ModelCriteria = ModelCriteria + (String)dictStrItr.next();
    		 if(dictStrItr.hasNext() == true)ModelCriteria = ModelCriteria + ",";
     }
    	 out.write(ModelCriteria);
         out.flush();
     }
   
  }
  catch(Exception e)
  {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
  }// End of main Try-catck block
%>
