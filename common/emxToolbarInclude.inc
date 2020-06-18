<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
    
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%!
    static final String popupSuffix = "...";
    static int intDefaultLength  = 0;
    //Seperator to be used to display the Labels while showing the pivoted (In case of duplicate labels)
    static final String lablePrefisSeperator = ">>";
    static Integer intCommandLimit = null;
    int limit = 0;
    static String strAlternateCmdIcon = null;
    
%>
    
<%

if(intCommandLimit == null) {
    String strLimit = "";
    try{
        strLimit = EnoviaResourceBundle.getProperty(context, "emxFramework.Toolbar.PivotCommand.Limit").trim();
    } catch (FrameworkException ex){
        //do nothing if the property is not set
    }
    if(strLimit != null && strLimit.length()>0){
        try{
            if(Integer.parseInt(strLimit) >0 ){
                intCommandLimit = new Integer(strLimit);
            } else {
                throw new NumberFormatException();
            }
        } catch (NumberFormatException ex){
            intCommandLimit = new Integer(0);
        }
    }
}

if(intCommandLimit != null){
        limit = intCommandLimit.intValue();
}

String defaultLength  = EnoviaResourceBundle.getProperty(context, "emxFramework.Toolbar.MaximumLength");
if (defaultLength != null && defaultLength.trim().length() > 0)
{
    if ("0".equals(defaultLength))
    {
        defaultLength = "";
    }
    else
    {
        intDefaultLength = Integer.parseInt(defaultLength);
    }
}
else
{
    defaultLength = "";
}

%>

<%!

//This method will override the mode setting of the command, if it is not defined
public static void overrideModeSetting(HashMap component, String parentMenuMode) {
    	overrideSetting(component, parentMenuMode, "Mode");
    }
    public static void overrideExpandedSetting(HashMap component, String parentExpanded) {
    	overrideSetting(component, parentExpanded, "Expanded");
    }    
    
    public static void overrideDisplayModeSetting(HashMap component, String parentExpanded) {
    	overrideSetting(component, parentExpanded, "Display View");    	
}
    
    public static void overrideSetting(HashMap component, String parentExpanded, String settingName) {
    if(component.get("settings")==null){
        component.put("settings",new HashMap());
    }
    if(UIToolbar.getSetting(component,"Mode").length() == 0){        
        ((HashMap)component.get("settings")).put("Mode",parentExpanded);
    }    
}
//Method to load the toolbar wiith its actual label prefixed with some string
// Introduced for Toolbar Enhancement
String loadToolbar(Context context, HashMap component, HashMap requestParams, int level, String errorLabel, boolean isHomePage, String strLabelPrefix, boolean bUseAlternateCmdIcon)
{
        return loadToolbar(context,component,requestParams,level,errorLabel,isHomePage,strLabelPrefix,bUseAlternateCmdIcon,null);
}

private String loadToolbar(Context context, HashMap component, HashMap requestParams, int level, String errorLabel, boolean isHomePage,String strLabelPrefix, boolean bUseAlternateCmdIcon,String currToolbar)
{
 
    if (currToolbar==null ||"null".equals(currToolbar))
    {
                currToolbar="objMainToolbar";
    }
    StringBuffer toolBar = new StringBuffer(1024);
    String itemType;
    String uiType = XSSUtil.encodeForJavaScript(context, (String) requestParams.get("uiType"));
    String isFS = (String) requestParams.get("isFS");
    String isFullSearch = (String) requestParams.get("isFullSearch");
    
    //added for bug : 342600
    String isRMB  = XSSUtil.encodeForJavaScript(context, (String) requestParams.get("isRMB"));
    if(isRMB == null){
        isRMB = "false";
    }

    String expanded  = XSSUtil.encodeForJavaScript(context, (String) requestParams.get("Expanded"));
    String expandedSetting = UIToolbar.getSetting(component,"Expanded");
    if(expanded=="true" || expanded=="True" || expandedSetting.contains("true") || expandedSetting.contains("True") ){
        expanded = "true";
        expandedSetting="true";
    }

    // determine the type of component
    if (UIToolbar.isMenu(component))
    {
        itemType =  "Menu";
    }
    else
    {
        if (UIToolbar.isSeparator(component))
        {
            itemType = (level == 0) ? "Separator" : "MenuSeparator";
        }
        else
        {
            itemType = (level == 0) ? "Button" : "MenuItem";
        }
    }

    try
    {
        String strMenu = "";
        String itemName = UIToolbar.getName(component);
        String itemDescription = UIToolbar.getDescription(component);
        String itemActualName = itemName+"_actualValue";
        String itemOIDName = itemName+"_OID";
        String itemLabel = UIToolbar.getLabel(component);
        if(strLabelPrefix != null && strLabelPrefix.trim().length()>0){
            StringBuffer sbLabel = new StringBuffer(200);
            sbLabel.append(strLabelPrefix);
            sbLabel.append(itemLabel);
            itemLabel = sbLabel.toString();
        }
        int maxLabelLength = UIToolbar.getMaximumLength(component);
        int iLabelLength = 0;

        if(maxLabelLength != -1 && level == 0){
           iLabelLength = maxLabelLength;
        }else{
            if(intDefaultLength != 0 && level == 0){
                if(itemLabel.length() > intDefaultLength) {
                    iLabelLength = intDefaultLength;
                }
            }
        }


        String itemIcon = UIToolbar.getImage(component);
        StringBuffer itemUrl = new StringBuffer(150);
        itemUrl.append(UIToolbar.getHRef(context, component, requestParams));

        if(bUseAlternateCmdIcon && "Button".equals(itemType) && itemIcon.length()==0){
            if(strAlternateCmdIcon == null){
                try{
                        strAlternateCmdIcon = EnoviaResourceBundle.getProperty(context, "emxFramework.Toolbar.DefaultCmdIcon");
                }catch (FrameworkException ex) {
                    strAlternateCmdIcon = "";
                }
            }
            if(strAlternateCmdIcon != null && strAlternateCmdIcon.trim().length()>0){
                    itemIcon = (new StringBuffer("../common/images/")).append(strAlternateCmdIcon).toString();
            }
        }

        String itemTargetLocation = UIToolbar.getTargetLocation(component);

        String itemRowSelect = UIToolbar.getRowSelect(component);
        //Added for Bug : 353307
        if("true".equalsIgnoreCase(isRMB))
        {
            itemRowSelect = "rmb";
        }

        
        //Using the popup sizes configured in the 
        String popupSize = UIToolbar.getPopupSize(component);
        
        String itemWidth = "812";
        String itemHeight = "500";
                
        try{
            if(popupSize == null || popupSize.trim().length() == 0){
                popupSize = "Medium";
            }
            StringList dimList = FrameworkProperties.getTokenizedProperty(context,"emxFramework.PopupSize." + popupSize , "x");
            itemWidth = (String)dimList.get(0);
            itemHeight = (String)dimList.get(1);
        }catch(Exception ex1){
            try{
                 popupSize = EnoviaResourceBundle.getProperty(context, "emxFramework.PopupSize.Default");
                 StringList dimList = FrameworkProperties.getTokenizedProperty(context,"emxFramework.PopupSize." + popupSize , "x");
                 itemWidth = (String)dimList.get(0);
                 itemHeight = (String)dimList.get(1);
            }catch(Exception ex2){
            }
        }
        
        boolean grayout     = "true".equals(UIToolbar.getSetting(component,"GrayOut"));
        String helpMarker = UIToolbar.getSetting(component,"Help Marker");
        String registeredSuite = UIToolbar.getSetting(component,"Registered Suite");
        //Added to support Structure Browser - Edit Mode Toolbar 
        String modeSetting = UIToolbar.getSetting(component,"Mode");      
        String displayModeSetting = UIToolbar.getSetting(component,"Display View");
	    String manualEdit = UIToolbar.getSetting(component,"Allow Manual Edit");
        //Added for Toolbar enhancement code - Begin
        String inputType    = UIToolbar.getSetting(component,"Input Type");
        String actionLabel  = UIToolbar.getActionLabel(component);

        String defaultValue  = (String)requestParams.get(itemName);
        String defaultActualValue = (String)requestParams.get(itemActualName);
        String defaultOIDValue = (String)requestParams.get(itemOIDName);
        if (UIUtil.isNullOrEmpty(defaultActualValue)) {
        	String defaultValueTemp = UIToolbar.getSetting(component,"Default");
        	String strResourceFile = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
        	String defaultENValue = EnoviaResourceBundle.getProperty(context, strResourceFile, new Locale("en"), defaultValueTemp);        	
        	defaultActualValue = defaultENValue ;
        }
        else{
        	defaultActualValue = XSSUtil.encodeForHTML(context, defaultActualValue);
        }
        if (defaultOIDValue == null || "null".equals(defaultOIDValue) || "".equals(defaultOIDValue)) {
            defaultOIDValue = defaultValue;
        }
        
        if (defaultValue == null || "".equals(defaultValue) || "null".equals(defaultValue)) {
                defaultValue  = UIToolbar.getSetting(component,"Default");
                String strResourceFile = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
                defaultValue = EnoviaResourceBundle.getProperty(context, strResourceFile, new Locale((String)requestParams.get("languageStr")), defaultValue);                
        }
        if(actionLabel==null || "null".equalsIgnoreCase(actionLabel) || "".equals(actionLabel))
        {
           actionLabel = "";
        }
        if ("textbox".equalsIgnoreCase(inputType) || "submit".equalsIgnoreCase(inputType) || "combobox".equalsIgnoreCase(inputType) || "checkbox".equalsIgnoreCase(inputType)) {
                if(intDefaultLength != 0 && level == 0){
                        iLabelLength = intDefaultLength;
                }
        }

        //Added for Toolbar enhancement code - End
        //this sets whether or not the link will get added to the history
        String pageHistoryToolbarName = PropertyUtil.getSchemaProperty(context, "command_AEFPageHistoryToolbar");
        boolean blnHistoryEnabled =  (isHomePage && ("popup".equalsIgnoreCase(itemTargetLocation) || "content".equalsIgnoreCase(itemTargetLocation)));
        if(pageHistoryToolbarName != null && itemName.equals(pageHistoryToolbarName)){
            blnHistoryEnabled = false;
        }

        String registeredSuiteDir = "";
        if ((registeredSuite != null) && (registeredSuite.trim().length() > 0))
        {
            registeredSuiteDir = UINavigatorUtil.getRegisteredDirectory(context, registeredSuite);
        }

        String isPopup = "popup".equals(itemTargetLocation) ? "true" : "false";
        String isSlideIn = "slidein".equals(itemTargetLocation) ? "true" : "false";
        boolean isSelectionRequired = ("none".equals(itemRowSelect) == false);

        // if it is a popup
        if ("popup".equals(itemTargetLocation))
        {
            // Check label for ellipses
            //
            if (!itemLabel.endsWith(popupSuffix) && !"Menu".equals(itemType) && level != 0 &&
            		itemDescription != "Table Filters" && itemDescription != "Program Filters" && itemDescription != "Program Menu Filters") {
              itemLabel += popupSuffix;
            }

            if (!isHomePage && UIToolbar.willSubmit(component))
            {
				//modified for consolidated search
                if("structureBrowser".equalsIgnoreCase(uiType) || "ConsolidatedSearch".equalsIgnoreCase(uiType))
                {
		            // ended for consolidated search
		            itemUrl.insert(0,"javascript:submitFreezePaneData(\\\"");
		            itemUrl.append("\\\", \\\"");
		            itemUrl.append(itemTargetLocation);
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(itemRowSelect);
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(isPopup);
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(UIToolbar.isPopupModal(component));
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(itemWidth);
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(itemHeight);
		            itemUrl.append("\\\",\\\"");
		            itemUrl.append(UIToolbar.getConfirmMessage(component));
		            itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
                    itemUrl.append("\\\")");
		        }
                else
                {
                    itemUrl.insert(0,"javascript:submitList(\\\"");
                    itemUrl.append("\\\", \\\"");
                    itemUrl.append(itemTargetLocation);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemRowSelect);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(isPopup);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemWidth);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getConfirmMessage(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.isPopupModal(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
                    itemUrl.append("\\\")");
                }
            }
            else if (itemUrl.toString() != null && !itemUrl.toString().startsWith("javascript:"))
            {
                if (UIToolbar.isPopupModal(component))
                {
                    itemUrl.insert(0,"javascript:showModalDialog(\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemWidth);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",true ,\\\"");
                    itemUrl.append(popupSize);
                    itemUrl.append("\\\")");
                    
                }
                else
                {
                    String sHref = UIToolbar.getHRef(context, component, requestParams);
                    if(sHref != null && sHref.startsWith("../common/emxPageHistory.jsp")) {
                        itemUrl.insert(0,"javascript:showNonModalDialogWithName(\\\"");
                    }else {
                    itemUrl.insert(0,"javascript:showNonModalDialog(\\\"");
                    }
                   
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemWidth);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",true ,\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
                    itemUrl.append("\\\")");
                    
                }
            }
        }
        else if ("slidein".equals(itemTargetLocation))
        {
            // Check label for ellipses
            //
            if (!itemLabel.endsWith(popupSuffix) && !"Menu".equals(itemType) && level != 0) {
              itemLabel += popupSuffix;
            }

            if (!isHomePage && UIToolbar.willSubmit(component))
            {
                //modified for consolidated search
                if("structureBrowser".equalsIgnoreCase(uiType) || "ConsolidatedSearch".equalsIgnoreCase(uiType))
                {
                    // ended for consolidated search
                    itemUrl.insert(0,"javascript:submitFreezePaneData(\\\"");
                    itemUrl.append("\\\", \\\"");
                    itemUrl.append(itemTargetLocation);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemRowSelect);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(isPopup);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.isPopupModal(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemWidth);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getConfirmMessage(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
                    itemUrl.append("\\\")");
                }
                else
                {
                    itemUrl.insert(0,"javascript:submitList(\\\"");
                    itemUrl.append("\\\", \\\"");
                    itemUrl.append(itemTargetLocation);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemRowSelect);
                    itemUrl.append("\\\",");
                    itemUrl.append(false);
                    itemUrl.append(",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getConfirmMessage(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
		    itemUrl.append("\\\",\\\"");
		    itemUrl.append("\\\",\\\"");		    
		    itemUrl.append("\\\",\\\"");
		    itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
                    itemUrl.append("\\\")");   
                }
            }
            else if (itemUrl.toString() != null && !itemUrl.toString().startsWith("javascript:"))
            {
                String slideinWidth = UIToolbar.getSetting(component,"Slidein Width");
                if (UIToolbar.isPopupModal(component))
                {
                	if("true".equals(isFullSearch)){//In case of Full Search, window open as popup
                		 itemUrl.insert(0,"javascript:showModalDialog(\\\"");
                         itemUrl.append("\\\")");
                	}else{
                        itemUrl.insert(0,"javascript:getTopWindow().showSlideInDialog(\\\"");
                        //itemUrl.insert(0,"javascript:getTopWindow().showWiderSlideInDialog(\\\"");
                        itemUrl.append("\\\",true");
                        
                    	if(slideinWidth != null && !"".equals(slideinWidth)){
                    		itemUrl.append(", \\\"$OPENERFRAME$\\\",\\\"right\\\",\\\"" + slideinWidth + "\\\")");
                    	} else {
                    		itemUrl.append(",\\\"$OPENERFRAME$\\\")");
                    	}                        
                	}  
                }
                else
                {
                	if("true".equals(isFullSearch)){//In case of Full Search, window open as popup
                		 itemUrl.insert(0,"javascript:showNonModalDialog(\\\"");
                         itemUrl.append("\\\")");
                	}else{
                    	itemUrl.insert(0,"javascript:getTopWindow().showSlideInDialog(\\\"");
                        itemUrl.append("\\\",false");
                    	if(slideinWidth != null && !"".equals(slideinWidth)){
                    		itemUrl.append(", \\\"$OPENERFRAME$\\\",\\\"right\\\",\\\"" + slideinWidth + "\\\")");
                    	} else {
                    		itemUrl.append(",\\\"$OPENERFRAME$\\\")");
                    	}
                	}     
                }
            }
        } else if ("self".equals(itemTargetLocation)) {
            String categoryTreeName = XSSUtil.encodeForURL(context, (String) requestParams.get("categoryTreeName"));
            String formHeader = XSSUtil.encodeForURL(context, (String) requestParams.get("formHeader"));
            String strForm = XSSUtil.encodeForURL(context, (String) requestParams.get("form"));
            String toolbar = XSSUtil.encodeForURL(context, (String) requestParams.get("toolbar"));
            String targetLocation = XSSUtil.encodeForURL(context, (String) requestParams.get("targetLocation"));
            String slideinType = XSSUtil.encodeForURL(context, (String) requestParams.get("slideinType"));
            if(toolbar == null || "".equals(toolbar)) {
            	toolbar = (String) requestParams.get("actionBarName");
            }

        	if (itemUrl.toString() != null && !itemUrl.toString().startsWith("javascript:")) {
        		if(itemUrl.indexOf("categoryTreeName") < 0){
	        		itemUrl.append("&categoryTreeName=" + categoryTreeName); 
	        		itemUrl.append("&viewformHeader=" + formHeader);
	        		itemUrl.append("&viewtoolbar=" + toolbar);
        		}
        		if(strForm != null && !"".equals(strForm)){
        			if(itemUrl.indexOf("form="+strForm + "&") < 0){
        				itemUrl.append("&viewform=" + strForm);
        			}
        		}
        		String portalMode = (String) requestParams.get("portalMode");
        		if(portalMode != null && "true".equalsIgnoreCase(portalMode)){
        			itemUrl.append("&portalMode=true");
        		}
        		
                String strotherTollbarParams = (String) requestParams.get("otherTollbarParams");
                if(!"".equals(strotherTollbarParams)){
                    String otherParamstr = "&otherTollbarParams=" + XSSUtil.encodeForURL(context,strotherTollbarParams);
                	StringList paramList = FrameworkUtil.split(strotherTollbarParams, ",");
            		for(int i =0; i < paramList.size(); i++){
            			String paramName = (String)paramList.get(i);
            			otherParamstr += "&" + XSSUtil.encodeForURL(context,paramName) + "=" + XSSUtil.encodeForURL(context, (String) requestParams.get(paramName));
            		}
            		itemUrl.append(otherParamstr);
                }
        		itemUrl.append("&targetLocation="+targetLocation);
        		itemUrl.append("&slideinType="+slideinType);
        		itemUrl.insert(0,"javascript:toggleMode(\\\"");
            	itemUrl.append("\\\")");
        	}
        } // not a popup
        else
        {
            if (!isHomePage && UIToolbar.willSubmit(component))
            {
                isPopup="";
				//modified for consolidated search
                if("structureBrowser".equalsIgnoreCase(uiType) || "ConsolidatedSearch".equalsIgnoreCase(uiType))
                {
                // ended for consolidated search
            itemUrl.insert(0,"javascript:submitFreezePaneData(\\\"");
            itemUrl.append("\\\", \\\"");
            itemUrl.append(itemTargetLocation);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(itemRowSelect);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(isPopup);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(UIToolbar.isPopupModal(component));
            itemUrl.append("\\\",\\\"");
            itemUrl.append(itemWidth);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(itemHeight);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(UIToolbar.getConfirmMessage(component));
            itemUrl.append("\\\",\\\"");
            itemUrl.append(popupSize);
            itemUrl.append("\\\",\\\"");
            itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
            itemUrl.append("\\\")");
        }
        else
        {
                    itemUrl.insert(0,"javascript:submitList(\\\"");
                    itemUrl.append("\\\", \\\"");
                    itemUrl.append(itemTargetLocation);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemRowSelect);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(isPopup);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemWidth);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(itemHeight);
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(UIToolbar.getConfirmMessage(component));
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append("\\\",\\\"");
                    itemUrl.append(popupSize);
		    itemUrl.append("\\\",\\\"");
		    itemUrl.append("\\\",\\\"");		    
		    itemUrl.append("\\\",\\\"");
		    itemUrl.append(UIToolbar.getSetting(component,"Slidein Width"));
                    itemUrl.append("\\\")");
        }
            }

            //searchContent???
            if ("searchContent".equals(itemTargetLocation))
            {
                
				//added for for consolidated search                
                String searchType  = UIToolbar.getSetting(component,"Search Type");
                String table 	   = UIToolbar.getSetting(component,"table");
                String program     = UIToolbar.getSetting(component,"program");
                String function     = UIToolbar.getSetting(component,"function");                
                // ended for consolidated search       
                 
               
                //modified for consolidated search
             
                // Check label for ellipses
                //
                if (isHomePage && !itemLabel.endsWith(popupSuffix) && !"Menu".equals(itemType) && level != 0) {
                  itemLabel += popupSuffix;
                }
                itemUrl.insert(0,"javascript:getTopWindow().findSearchFrame(\\\"");
                itemUrl.append("\\\",\\\"");
                itemUrl.append(itemTargetLocation);
                itemUrl.append("\\\",\\\"");
                itemUrl.append(itemLabel);
                itemUrl.append("\\\",\\\"");
                itemUrl.append(UIToolbar.getName(component));
                itemUrl.append("\\\",\\\"");
                itemUrl.append(helpMarker);
                itemUrl.append("\\\",\\\"");
                itemUrl.append(registeredSuiteDir);
                itemUrl.append("\\\",\\\"");                
                itemUrl.append("null");		  // this is for toolbar enhancement code .. not used in consolidate search.
                itemUrl.append("\\\",\\\"");
                itemUrl.append(searchType);      // to determine whether it is general search or consolidate search
                itemUrl.append("\\\",\\\"");
                itemUrl.append(table);
                itemUrl.append("\\\",\\\"");
                itemUrl.append(program);
                itemUrl.append("\\\",\\\"");
                itemUrl.append(function);
                itemUrl.append("\\\")");             
                 
                //ended for consolidated search
                 

//If condition Added for Toolbar Enhancement Code - Begin                                                                
                if(inputType==null || (!inputType.equalsIgnoreCase("textbox") && !inputType.equalsIgnoreCase("combobox") && !inputType.equalsIgnoreCase("submit")))
                {
                    itemTargetLocation = "null";
                }
//Added for Toolbar Enhancement Code - End                

            }
            if ("metricsReportContent".equals(itemTargetLocation))
                        {
                            // Check label for ellipses
                            //
                            if (isHomePage && !itemLabel.endsWith(popupSuffix) && !"Menu".equals(itemType) && level != 0) {
                              itemLabel += popupSuffix;
                            }
                            itemUrl.insert(0,"javascript:getTopWindow().findReportFrame(\\\"");
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(itemTargetLocation);
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(itemLabel);
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(UIToolbar.getName(component));
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(helpMarker);
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(registeredSuite);
                            itemUrl.append("\\\",\\\"");
                            itemUrl.append(registeredSuiteDir);
                            itemUrl.append("\\\")");
                            itemTargetLocation = "null";
            }
            
            if ("slidein".equals(itemTargetLocation)) {
                String slideinWidth = UIToolbar.getSetting(component,"Slidein Width");
            	if (isHomePage && !itemLabel.endsWith(popupSuffix)
	                                && !"Menu".equals(itemType) && level != 0) {
	                            itemLabel += popupSuffix;
	                        }
	    
	                        itemUrl.insert(0, "javascript:showSlideInDialog(\\\"");
	                        itemUrl.append("\\\",");
	                        itemUrl.append(UIToolbar.isPopupModal(component));
	                    	if(slideinWidth != null && !"".equals(slideinWidth)){
	                    		itemUrl.append(", \\\"$OPENERFRAME$\\\",\\\"right\\\",\\\"" + slideinWidth + "\\\")");
	                    	} else {
	                        itemUrl.append(",\\\"$OPENERFRAME$\\\")");
	                    	}	                        
	                        itemTargetLocation = "null";
            }
            
            if ("windowshade".equals(itemTargetLocation)) {
                
                if (isHomePage && !itemLabel.endsWith(popupSuffix)
                        && !"Menu".equals(itemType) && level != 0) {
                    itemLabel += popupSuffix;
                }

                itemUrl.insert(0, "javascript:showWindowShadeDialog(\\\"");
                itemUrl.append("\\\",");
                itemUrl.append(UIToolbar.isPopupModal(component));
                itemUrl.append(")");
                itemTargetLocation = "null";
            }

            // backwards compatibility fix
            // if not a popup, but submit=false and is a Javascript method
            if (UIToolbar.isJavaScript(component))
            {
            	if("true".equalsIgnoreCase(UIToolbar.getSetting(component, "isFS")) || "true".equalsIgnoreCase(isFS)){
            		itemUrl.insert(0, "javascript:frames[1].");
            	} else {
                itemUrl.insert(0, "javascript:frames[0].");
            	}
            }
        }
        StringBuffer comboBuffer = new StringBuffer();
        
        String itemUrlEscaped = FrameworkUtil.findAndReplace(itemUrl.toString(),"'","\\\\'");

        String submitFunction   =   UIToolbar.getSetting(component,"Submit Function");
        String submitProgram    =   UIToolbar.getSetting(component,"Submit Program");
        String format           =   UIToolbar.getSetting(component,"format");
        String sCommandCode = getValue(component, "code");
        String javascriptInclude=   UINavigatorUtil.parseHREF(context, UIToolbar.getSetting(component,"Javascript Include"),UIToolbar.getSetting(component,"Registered Suite"));
        String width            =   UIToolbar.getSetting(component,"Width");
        String displayMode      =   UIToolbar.getSetting(component,"Display View");
        if(width == null || "null".equals(width) || "".equals(width)) {
            width               =   UIToolbar.getSetting(component,"width");
        }
// Added the two variables isPopModal and willSubmit to check for the value of Popup Modal and submit setting
        boolean isPopModal       =   UIToolbar.isPopupModal(component);
        boolean willSubmit       =   UIToolbar.willSubmit(component);
        String strLanguage      =   (String)requestParams.get("languageStr");   
        String msValue="";
        if ("date".equalsIgnoreCase(format)) {
                String dateValue=getValue(requestParams,itemName);
                if(!"".equals(dateValue)) {
                        double iClientTimeOffset = (new Double((String) requestParams.get("timeZone"))).doubleValue();
                        int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();;
                        Locale locale = (Locale)requestParams.get("localeObj");
                        msValue=String.valueOf(DateUtil.getMilliseconds(context, dateValue, iDateFormat, iClientTimeOffset, locale));
                }
        }

  		//Added for RMB START
        String strName = "";
        String strJPOName = "";
        String strMethodName = "";
        String strLabelJPOName = "";
        String strLabelMethodName = "";
        String strJPOName1 = "";
        String strMethodName1 = "";
        String strName1 = "";
        String strAlignment = "";
        String sbModeforDynamicMenu = (String) requestParams.get("sbModeforDynamicMenu");
        strJPOName    = UIToolbar.getSetting(component,"Dynamic Command Program");
        strMethodName = UIToolbar.getSetting(component,"Dynamic Command Function");
        strLabelJPOName = UIToolbar.getSetting(component,"Dynamic Label Program");
        strLabelMethodName = UIToolbar.getSetting(component,"Dynamic Label Function");
        boolean bolDynamicLabelCmd = false;
        /********Dynamic label*********/
        if (strLabelJPOName != null && !"".equals(strLabelJPOName))
        {
            bolDynamicLabelCmd = true;
            HashMap progMap = new HashMap();
            progMap.put("requestMap",requestParams);
            progMap.put("commandMap",component);
            FrameworkUtil.validateMethodBeforeInvoke(context, strLabelJPOName, strLabelMethodName, "Program");
            itemLabel = (String) JPO.invoke(context,
                                        strLabelJPOName, new String[] {}, strLabelMethodName, JPO.packArgs(progMap),
                                        String.class);
        }
        /********Dynamic label*********/                                                     
									
        strAlignment = UIToolbar.getSetting(component,"Alignment");  
        strName = UIComponent.getName(component);
        boolean bolDynamicChild = false;
        boolean bolDynamicCmd = false;
        if (strJPOName != null && !"".equals(strJPOName))
        {
            bolDynamicCmd = true;
        }
        
       //Added for RMB END
       if (!"MenuItem".equals(itemType)) {
        toolBar.append("\n  var currentToolbarObj = eval("+currToolbar+");");
       }
//Added code to handle JSON code
//start
        String varName = getJSVariableName(itemName);
        if(sCommandCode == null){
            sCommandCode = "";
        }

        toolBar.append("\n  var " + varName + "mxcommandcode = eval("+sCommandCode+");\n");

//End
        if ("Button".equals(itemType))
        {
			//Modified for RMB START
            /*
            If any of the Menu /Command on the toolbar is a Dynamic
            Add a "Loading..." item to the menu/command.
            A Dynamic Command on toolbar will be displayed as Menu
            */                    
            if (bolDynamicCmd)
            {
                if (itemIcon.length() > 0 && itemLabel.length() > 0)
                {
                	toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, \"").append(itemIcon).append("\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                }
                else if(itemIcon.length() == 0 && itemLabel.length() > 0)
                {
                    toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                }
                else if (itemIcon.length() > 0 && itemLabel.length() == 0)
                {
                    toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(");

                    //intFormat
                    toolBar.append("emxUIToolbar.ICON_ONLY, \"");

                    //strIcon
                    toolBar.append(itemIcon).append("\", \"");

                    //strText
                    toolBar.append(UIToolbar.getAlt(component));

                    //strURL
                    toolBar.append("\", \"").append(itemUrl.toString());

                    //strTarget
                    toolBar.append("\",\"").append(itemTargetLocation);
                }
                else
                {   
                	toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                }
                toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                toolBar.append(", \"").append(iLabelLength);                
                toolBar.append("\",\"").append("");
                toolBar.append("\",\"").append(strJPOName);
                toolBar.append("\",\"").append(strMethodName);
                toolBar.append("\",\"").append(strName);
                toolBar.append("\",\"").append(strAlignment);
                toolBar.append(isSelectionRequired ? "\"),true);\n" : "\"));\n");
                toolBar.append("objMenuItem.addMenu(new emxUIToolbarMenu());");
                toolBar.append("objMenuItem.grayout = \"").append(grayout).append("\";");
                toolBar.append("objMenu = objMenuItem.menu;");
                toolBar.append("objStack.push(objMenu);");
				toolBar.append("objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", emxUIConstants.STR_LOADING_MENU, \"\",\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", false");
				toolBar.append(",\"").append(strJPOName);
				toolBar.append("\",\"").append(strMethodName);
				toolBar.append("\",\"").append(strName);
				toolBar.append("\",\"").append(strAlignment);
				toolBar.append("\"));");
				toolBar.append("objMenuItem.setMode(\"").append(modeSetting.toString()).append("\");"); 
				toolBar.append("objMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
				toolBar.append("objMenuItem.displayMode=objMenuItem.getDisplayMode();");
				toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");");
           		toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");
                toolBar.append("objMenu = objStack.pop();");
            }
            else 
            {
            //Modified for RMB END
           	if (itemIcon.length() > 0 && itemLabel.length() > 0)
            {
           		String program = (String) requestParams.get("program");
            // Added for Toolbar enhancement code - Begin
                if("textbox".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_TEXTBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context,defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }
                else if ("combobox".equalsIgnoreCase(inputType))
                {
                	String rangeValues= UIToolbar.getSetting(component,"Range Values");

                	comboBuffer = getComboboxBuffer(context,component,requestParams,itemName,rangeValues,itemLabel,UIToolbar.getHRef(context, component, requestParams),itemTargetLocation,itemWidth,itemHeight,actionLabel,submitFunction,submitProgram,uiType,width,getMXString(context, component,UIToolbar.getAlt(component),strLanguage),isPopModal,willSubmit,iLabelLength,defaultValue);

                	if (component.containsKey("expandMenu")){
                	
                	    //only show 'expand all' if there is one root node
                        toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, \"iconActionExpandAll.png\", emxUIConstants.STR_EXPAND_ALL, \"javascript:expandAll()\"));");
                	
                		//JMW - adding expand n-levels menu
                		toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, \"iconActionSetNodeExpansionLevel.png\",emxUIConstants.STR_EXPAND_N_LEVELS, \"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\"));");

                		toolBar.append("objMenuItem.setMode(\"").append(modeSetting.toString()).append("\");"); 
                		toolBar.append("objMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
                		toolBar.append("objMenuItem.displayMode=objMenuItem.getDisplayMode();");
                		toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");");
           		        toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");
                		
                		toolBar.append("objMenuItem.addMenu(new emxUIToolbarMenu());");
                		toolBar.append("objMenu = objMenuItem.menu;");

                		//following comment helps describe the params for the formfield object
                		//								emxUIToolbarFormField(    htmlControl,                                 itemName,                         itemLabel,                                                     strURL,                                       strTarget,                                                actionLabel,                           uiType,       itemWidth,                         itemHeight,                              htmlString,                              submitFunction,                         submitProgram,                        format,                        isModal,                           willSubmit,                        width,                                    altText,                                     strID,                  strJPOName,  strMethodName,     strCmdName,   labelLength,   strAlignment,  sCommandCode,      msValue,     manualEdit,     defaultActualValue,defaultOIDValue)
                		toolBar.append("objMenu.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX, \"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(comboBuffer.toString()).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength).append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\",\"").append("\"));");


                		//THIS IS NEEDED because of bad logic.
                		//TODO refactor this method. The current method assumes all if statements will
                		//have trailing javascript properties added
                		toolBar.append("//");
                	}else{
                		toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(comboBuffer.toString()).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                	}
                }
                else if("submit".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_SUBMIT,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"\",\"").append(isPopModal).append("\",\"").append("\",\"").append(willSubmit).append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }                
				else if ("checkbox".equalsIgnoreCase(inputType))
                {
				   // Modified for bug 347655	
                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_CHECKBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else
                {
    // Added by for Toolbar html controls enhancement - End            

                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, \"").append(itemIcon).append("\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                    //NEED TO ADD: strMenu, strCommand, itemLabel, strLinkType, itemWidth, itemHeight, registeredSuite
                    if (isHomePage)
                    {
                        toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                        toolBar.append("\", \"").append(registeredSuite);
                        toolBar.append("\", ").append(blnHistoryEnabled);
                        toolBar.append(", \"").append(iLabelLength).append("\",\"").append(itemName);
                    }else{
                        toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                        toolBar.append(", \"").append(iLabelLength).append("\",\"").append(itemName);
                     }
                }//added for toolbar enhancement
				//Modified for RMB START
				toolBar.append("\",\"").append("");
				toolBar.append("\",\"").append(strJPOName);
				toolBar.append("\",\"").append(strMethodName);
				toolBar.append("\",\"").append(strName);
				toolBar.append("\",\"").append(strAlignment);
				//Modified for RMB END
                String codeVarName = FrameworkUtil.findAndReplace(itemName, " ", "_") + "mxcommandcode";
                toolBar.append(isSelectionRequired ? "\",'"+codeVarName+"','"+msValue+"',null,'"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'),true);\n" : "\", '"+codeVarName+"','"+msValue+"','"+manualEdit+"','"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'));\n");
				
                //Set Mode for objMenuBtn[Added to support Structure Browser - Edit Mode Toolbar] 
                if (toolBar.indexOf("objMenuBtn") != -1){
	                    toolBar.append("objMenuBtn.setMode(\"").append(modeSetting.toString()).append("\");");  
	                    toolBar.append("objMenuBtn.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
	                    toolBar.append("objMenuBtn.displayMode=objMenuBtn.getDisplayMode();");
	                    toolBar.append("objMenuBtn.setExpanded(\"").append(expandedSetting.toString()).append("\");");
           		        toolBar.append("objMenuBtn.expanded=objMenuBtn.getExpanded();");
	                    
                    	toolBar.append("objMenuBtn.grayout = \"").append(grayout).append("\";");
                    }
                }
            else if (itemIcon.length() == 0 && itemLabel.length() > 0)
            {
            // Added for Toolbar enhancement code - Begin
                if("textbox".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_TEXTBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }
                else if ("combobox".equalsIgnoreCase(inputType))
                {
                   String rangeValues= UIToolbar.getSetting(component,"Range Values");
                   comboBuffer = getComboboxBuffer(context,component,requestParams,itemName,rangeValues,itemLabel,UIToolbar.getHRef(context, component, requestParams),itemTargetLocation,itemWidth,itemHeight,actionLabel,submitFunction,submitProgram,uiType,width,getMXString(context, component,UIToolbar.getAlt(component),strLanguage),isPopModal,willSubmit,iLabelLength,defaultValue);
                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(comboBuffer.toString()).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else if("submit".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_SUBMIT,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }                
				else if ("checkbox".equalsIgnoreCase(inputType))
                {
					// Modified for bug 347655
                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_CHECKBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);                   
                }
                else if(bolDynamicLabelCmd){
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarLabelField(emxUIToolbar.TEXT_ONLY,\"")
                        .append(itemName).append("\",\"")
                        .append(itemLabel).append("\",\"")
                        .append(strAlignment);
                }
                else
                {
        // Added by for Toolbar html controls enhancement - End            
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);

                    if (isHomePage)
                    {
                        toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                        toolBar.append("\", \"").append(registeredSuite);
                        toolBar.append("\", ").append(blnHistoryEnabled);
                        toolBar.append(", \"").append(iLabelLength);//.append("\",\"").append(itemName);
                    }else{
                        toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                        toolBar.append(", \"").append(iLabelLength);//.append("\",\"").append(itemName);
                     }
                }
				// Modified for RMB START
				toolBar.append("\",\"").append(itemName);
				toolBar.append("\",\"").append(strJPOName);
				toolBar.append("\",\"").append(strMethodName);
				toolBar.append("\",\"").append(strName);
				toolBar.append("\",\"").append(strAlignment);
				//Modified for RMB END
                String codeVarName = FrameworkUtil.findAndReplace(itemName, " ", "_") + "mxcommandcode";
				toolBar.append(isSelectionRequired ? "\",'"+codeVarName+"','"+msValue+"',null,'"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'),true);\n" : "\", '"+codeVarName+"','"+msValue+"','"+manualEdit+"','"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'));\n");
				
                //Added to support Structure Browser - Edit Mode Toolbar 
                toolBar.append("objMenuBtn.setMode(\"").append(modeSetting.toString()).append("\");");               
                toolBar.append("objMenuBtn.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
                toolBar.append("objMenuBtn.displayMode=objMenuBtn.getDisplayMode();");
                toolBar.append("objMenuBtn.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                toolBar.append("objMenuBtn.expanded=objMenuBtn.getExpanded();");
                 
                
                toolBar.append("objMenuBtn.grayout = \"").append(grayout).append("\";");
	              
            }
            else if (itemIcon.length() > 0 && itemLabel.length() == 0)
            {
                // Added by for Toolbar html controls enhancement - Start            

                if("textbox".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_TEXTBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }
                else if ("combobox".equalsIgnoreCase(inputType))
                {
                	String rangeValues= UIToolbar.getSetting(component,"Range Values");
                	comboBuffer = getComboboxBuffer(context,component,requestParams,itemName,rangeValues,itemLabel,UIToolbar.getHRef(context, component, requestParams),itemTargetLocation,itemWidth,itemHeight,actionLabel,submitFunction,submitProgram,uiType,width,getMXString(context, component,UIToolbar.getAlt(component),strLanguage),isPopModal,willSubmit,iLabelLength,defaultValue);
                	toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(comboBuffer.toString()).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else if("submit".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_SUBMIT,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }                
				else if ("checkbox".equalsIgnoreCase(inputType))
                {
					// Modified for bug 347655
	                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_CHECKBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else{
                    // Added by for Toolbar html controls enhancement - End            

                toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarButton(");

                //intFormat
                toolBar.append("emxUIToolbar.ICON_ONLY, \"");

                //strIcon
                toolBar.append(itemIcon).append("\", \"");

                //strText
                toolBar.append(UIToolbar.getAlt(component));

                //strURL
                toolBar.append("\", \"").append(itemUrl.toString());

                //strTarget
                toolBar.append("\",\"").append(itemTargetLocation);

                if (isHomePage)
                {

                    //strMenu
                    toolBar.append("\", \"").append(strMenu);

                    //strCommand
                    toolBar.append("\", \"").append(itemName);

                    //strCommandTitle
                    toolBar.append("\",\"").append(itemLabel);

                    //strLinkType
                    toolBar.append("\", \"").append("toolbar");

                    //intWidth
                    toolBar.append("\", \"").append(itemWidth);

                    //intHeight
                    toolBar.append("\",\"").append(itemHeight);

                    //strSuite
                    toolBar.append("\", \"").append(registeredSuite);

                    //blnHistoryEnabled
                    toolBar.append("\", ").append(blnHistoryEnabled);

                    //intLabelLength
                    toolBar.append(", \"").append(iLabelLength);

                }else{
                    toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                    toolBar.append(", \"").append(iLabelLength);
                }
                }
				//Modified for RMB Start
                toolBar.append("\",\"").append("");
                toolBar.append("\",\"").append(strJPOName);
                toolBar.append("\",\"").append(strMethodName);
                toolBar.append("\",\"").append(strName);
                toolBar.append("\",\"").append(strAlignment);
                //Modified for RMB END
                String codeVarName = FrameworkUtil.findAndReplace(itemName, " ", "_") + "mxcommandcode";
                toolBar.append(isSelectionRequired ? "\",'"+codeVarName+"','',null,'"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'),true);\n" : "\", '"+codeVarName+"','','"+manualEdit+"','"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'));\n");
                
		//Added to support Structure Browser - Edit Mode Toolbar 
                toolBar.append("objMenuBtn.setMode(\"").append(modeSetting.toString()).append("\");");				
                toolBar.append("objMenuBtn.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");");
                toolBar.append("objMenuBtn.displayMode=objMenuBtn.getDisplayMode();");
                toolBar.append("objMenuBtn.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                toolBar.append("objMenuBtn.expanded=objMenuBtn.getExpanded();");
                toolBar.append("objMenuBtn.grayout = \"").append(grayout).append("\";");
            }
            else
            {
                // Added by for Toolbar html controls enhancement - Start            

                if("textbox".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_TEXTBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }
                else if ("combobox".equalsIgnoreCase(inputType))
                {
                   String rangeValues= UIToolbar.getSetting(component,"Range Values");
                   comboBuffer = getComboboxBuffer(context,component,requestParams,itemName,rangeValues,itemLabel,UIToolbar.getHRef(context, component, requestParams),itemTargetLocation,itemWidth,itemHeight,actionLabel,submitFunction,submitProgram,uiType,width,getMXString(context, component,UIToolbar.getAlt(component),strLanguage),isPopModal,willSubmit,iLabelLength,defaultValue);
                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_COMBOBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(comboBuffer.toString()).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else if("submit".equalsIgnoreCase(inputType))
                {
                    toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_SUBMIT,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"").append(uiType).append("\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(getMXString(context, component,UIToolbar.getAlt(component),strLanguage)).append("\",\"").append(iLabelLength);
                }                
				 else if ("checkbox".equalsIgnoreCase(inputType))
                {
					// Modified for bug 347655
	                   toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarFormField(emxUIToolbar.INPUT_TYPE_CHECKBOX,\"").append(itemName).append("\", \"").append(itemLabel).append("\",\"").append(UIToolbar.getHRef(context, component, requestParams)).append("\",\"").append(itemTargetLocation).append("\",\"").append(getMXString(context, component,actionLabel,strLanguage)).append("\",\"\",\"").append(itemWidth).append("\",\"").append(itemHeight).append("\",\"").append(XSSUtil.encodeForJavaScript(context, defaultValue)).append("\",\"").append(submitFunction).append("\",\"").append(submitProgram).append("\",\"").append(format).append("\",\"").append(isPopModal).append("\",\"").append(willSubmit).append("\",\"").append(width).append("\",\"").append(UIToolbar.getAlt(component)).append("\",\"").append(iLabelLength);
                }
                else{
                // Added by for Toolbar html controls enhancement - End            

                toolBar.append("objMenuBtn = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\", \"").append(errorLabel).append("\"));\n");
            }
                 // Added by for Toolbar html controls enhancement - Start           
               if("textbox".equalsIgnoreCase(inputType) || "combobox".equalsIgnoreCase(inputType) || "submit".equalsIgnoreCase(inputType)){
					//Modified for RMB START
					toolBar.append("\",\"").append("");    
					toolBar.append("\",\"").append(strJPOName);
					toolBar.append("\",\"").append(strMethodName);
					toolBar.append("\",\"").append(strName);
					toolBar.append("\",\"").append(strAlignment);
					//Modified for RMB END
                        String codeVarName = FrameworkUtil.findAndReplace(itemName, " ", "_") + "mxcommandcode";
                	toolBar.append(isSelectionRequired ? "\",'"+codeVarName+"','"+msValue+"',null,'"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'),true);\n" : "\", '"+codeVarName+"','"+msValue+"','"+manualEdit+"','"+defaultActualValue+"','"+XSSUtil.encodeForJavaScript(context, defaultOIDValue)+"'));\n");				
               }
               toolBar.append("objMenuBtn.grayout = \"").append(grayout).append("\";");
                 // Added by for Toolbar html controls enhancement - End            
            }
 			//Modified for RMB START
            }
            //Modified for RMB END


        }
        else if ("Separator".equals(itemType))
        {
            toolBar.append("currentToolbarObj.addItem(new emxUIToolbarSeparator());\n");
        }
        else if ("MenuItem".equals(itemType))
        {
            if (itemIcon.length() > 0 && (itemLabel.length() > 0 || UIToolbar.getAlt(component).length() > 0))
            {
                if(itemLabel.length()==0){
                    itemLabel = UIToolbar.getAlt(component);
                    }
                //Added to support Structure Browser - Edit Mode Toolbar 
                toolBar.append("tempMenuItem = new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, \"").append(itemIcon).append("\", \"").append(itemLabel).append("\", \"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);

                if (isHomePage)
                {
                    toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                    toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                    toolBar.append("\", \"").append(registeredSuite);
                    toolBar.append("\", ").append(blnHistoryEnabled);
                }else{
                    toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                }

				//Modified for RMB START
                toolBar.append(",\"").append(strJPOName);
                toolBar.append("\",\"").append(strMethodName);
                toolBar.append("\",\"").append(strName);
                toolBar.append("\",\"").append(strAlignment);
                toolBar.append("\"");
                //Modified for RMB END
                //Added to support Structure Browser - Edit Mode Toolbar 
                toolBar.append(isSelectionRequired ? ")\n" : ");\n");
                toolBar.append("tempMenuItem.setMode(\"").append(modeSetting.toString()).append("\");");
                toolBar.append("tempMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
                toolBar.append("tempMenuItem.displayMode=tempMenuItem.getDisplayMode();");
                toolBar.append("tempMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                toolBar.append("tempMenuItem.expanded=tempMenuItem.getExpanded();");
                
                toolBar.append("tempMenuItem.setRMB(\"").append(isRMB).append("\");");
                toolBar.append("tempMenuItem.grayout = \"").append(grayout).append("\";");
                toolBar.append("objMenu.setRMB(\"").append(isRMB).append("\");");
                if(isRMB.contains("true")){
                toolBar.append("objMenu.setExpanded(\"").append(expanded).append("\");"); 
                toolBar.append("objMenu.expanded=objMenu.getExpanded();");
               }
                toolBar.append("objMenu.addItem(tempMenuItem,"+isSelectionRequired+");\n"); 
                itemLabel = FrameworkUtil.findAndReplace(itemLabel,"'", "\\\\'");
                if(isHomePage && "content".equalsIgnoreCase(itemTargetLocation)) {
	                	toolBar.append("tempMenuItem.onClick = \" if(getTopWindow().bclist != null){getTopWindow().bclist = new getTopWindow().emxBreadCrumbList();");
	                	toolBar.append("getTopWindow().bclist.insert(\\\"MyDesk\\\", \\\"").append(itemLabel).append("\\\", \\\":\\\", null, null, \\\"").append(itemUrl.toString()).append("\\\");").append("}");
	                    if("AEFPageHistoryToolbar".equalsIgnoreCase(itemName)){
	                		toolBar.append("\";");
	                	} else {
	                		toolBar.append("emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(itemLabel).append("\\\", \\\"toolbar\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
	                	}
	  			} else {
		  			if(!"AEFPageHistoryToolbar".equalsIgnoreCase(itemName) && !UIToolbar.willSubmit(component)){
		  				toolBar.append("tempMenuItem.onClick = \" emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(itemLabel).append("\\\", \\\"toolbar\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
		  			}
	  			}


                String labelsk = (String)component.get("label");                
                labelsk   = FrameworkUtil.findAndReplace(labelsk, "'", "\\\\'");                
                if("true".equals(component.get("isCategoryTreeCommand"))){
                	toolBar.append("tempMenuItem.onClick = \"if(getTopWindow().bclist != null) getTopWindow().bclist.insert(\\\"").append(component.get("objectId"))
                    	.append("\\\",null,null,\\\"").append(labelsk).append("\\\", null, \\\"").append(itemUrl.toString()).append("\\\");\";");
                  
                    if(!UIToolbar.willSubmit(component)){
                    	toolBar.append("emxUICore.addToPageHistory(\"").append(registeredSuite).append("\", \"").append(itemUrlEscaped).append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\", \"").append(itemTargetLocation).append("\", \"").append(itemLabel).append("\", \"tree\", ").append(itemWidth).append(", ").append(itemHeight).append(");");
                    } else {
                    	//toolBar.append("\";");
                    }
                }
            }
            else
            {
                if (itemLabel.length() == 0)
                {
	     	    //Added to support Structure Browser - Edit Mode Toolbar 
                    toolBar.append("tempMenuItem = new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", \"").append(errorLabel);

                    if (isHomePage)
                    {
                        toolBar.append("\", \"\",\"popup");
                        toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                        toolBar.append("\", \"").append(registeredSuite);
                        toolBar.append("\", ").append(blnHistoryEnabled);
                    }else{
                        toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                    }
             	    //Added to support Structure Browser - Edit Mode Toolbar 
                    toolBar.append(");\n");
                    toolBar.append("tempMenuItem.setMode(\"").append(modeSetting.toString()).append("\");");
                    toolBar.append("tempMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
                    toolBar.append("tempMenuItem.displayMode=tempMenuItem.getDisplayMode();");
                    toolBar.append("tempMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                    toolBar.append("tempMenuItem.expanded=tempMenuItem.getExpanded();");
                    toolBar.append("tempMenuItem.setRMB(\"").append(isRMB).append("\");");
                    toolBar.append("tempMenuItem.grayout = \"").append(grayout).append("\";");
                    toolBar.append("objMenu.setRMB(\"").append(isRMB).append("\");");
                    if(isRMB.contains("true")){
                    toolBar.append("objMenu.setExpanded(\"").append(expanded).append("\");"); 
           	        toolBar.append("objMenu.expanded=objMenu.getExpanded();");
               }
                    toolBar.append("objMenu.addItem(tempMenuItem,"+isSelectionRequired+");\n");
                    itemLabel = FrameworkUtil.findAndReplace(itemLabel,"'", "\\\\'");
                    if(isHomePage && "content".equalsIgnoreCase(itemTargetLocation)) {                   
    	                	toolBar.append("tempMenuItem.onClick = \" if(getTopWindow().bclist != null){ getTopWindow().bclist.clear();");
    	                	toolBar.append("getTopWindow().bclist.insert(\\\"MyDesk\\\", \"").append(itemLabel).append("\\\", \\\":\\\", null, null, \\\"").append(itemUrl.toString()).append("\");").append("};");
    	                    if("AEFPageHistoryToolbar".equalsIgnoreCase(itemName)){
    	                		toolBar.append("\";");
    	                	} else {
    	                		toolBar.append("emxUICore.addToPageHistory(\"").append(registeredSuite).append("\", \"").append(itemUrlEscaped).append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\", \"").append(itemTargetLocation).append("\", \"").append(itemLabel).append("\", \"toolbar\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
    	                	}
   		  			} else {
   			  			if(!"AEFPageHistoryToolbar".equalsIgnoreCase(itemName) && !UIToolbar.willSubmit(component)){
   			  			toolBar.append("tempMenuItem.onClick = \" emxUICore.addToPageHistory(\"").append(registeredSuite).append("\", \"").append(itemUrlEscaped).append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\", \"").append(itemTargetLocation).append("\", \"").append(itemLabel).append("\", \"toolbar\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
   			  			}
   		  			}                        

                    String labelsk = (String)component.get("label");
                    labelsk   = FrameworkUtil.findAndReplace(labelsk, "'", "\\\\'");
                    if("true".equals(component.get("isCategoryTreeCommand"))){
                    	toolBar.append("tempMenuItem.onClick = \"if(getTopWindow().bclist != null) getTopWindow().bclist.insert(\\\"").append(component.get("objectId"))
                        		.append("\\\",null,null,\\\"").append(labelsk).append("\\\",null,\\\"").append(itemUrl.toString()).append("\\\");");
                        if(!UIToolbar.willSubmit(component)){
                        	toolBar.append("tempMenuItem.onClick = \" emxUICore.addToPageHistory(\"").append(registeredSuite).append("\", \"").append(itemUrlEscaped).append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\", \"").append(itemTargetLocation).append("\", \"").append(itemLabel).append("\", \"tree\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
                        }else {
                        	toolBar.append("\";");
                        }
                    }
                }
                else
                {
             	    //Added to support Structure Browser - Edit Mode Toolbar 
                    toolBar.append("tempMenuItem = new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\", \"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);  

                    if (isHomePage)
                    {
                        toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                        toolBar.append("\", \"").append(registeredSuite);
                        toolBar.append("\", ").append(blnHistoryEnabled);
                    }else{
                        toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                    }
					//Modified for RMB START
					toolBar.append(",\"").append(strJPOName);
					toolBar.append("\",\"").append(strMethodName);
					toolBar.append("\",\"").append(strName);
					toolBar.append("\",\"").append(strAlignment);
					toolBar.append("\"");
					//Modified for RMB END
            	    //Added to support Structure Browser - Edit Mode Toolbar 
                  	toolBar.append(isSelectionRequired ? ");\n" : ");");
                 	toolBar.append("tempMenuItem.setMode(\"").append(modeSetting.toString()).append("\");");
                 	toolBar.append("tempMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
                 	toolBar.append("tempMenuItem.displayMode=tempMenuItem.getDisplayMode();");
                 	
                 	toolBar.append("tempMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                 	toolBar.append("tempMenuItem.expanded=tempMenuItem.getExpanded();");
                 	toolBar.append("tempMenuItem.setRMB(\"").append(isRMB).append("\");");
                    toolBar.append("tempMenuItem.grayout = \"").append(grayout).append("\";");
                 	toolBar.append("objMenu.setRMB(\"").append(isRMB).append("\");");
                 	 if(isRMB.contains("true")){
                 	toolBar.append("objMenu.setExpanded(\"").append(expanded).append("\");"); 
                    toolBar.append("objMenu.expanded=objMenu.getExpanded();");
                    }
  				  	toolBar.append("objMenu.addItem(tempMenuItem,"+isSelectionRequired+");\n");
  				  	itemLabel = FrameworkUtil.findAndReplace(itemLabel,"'", "\\\\'");
  				  	if(isHomePage && "content".equalsIgnoreCase(itemTargetLocation)&& !itemUrl.toString().startsWith("javascript:")) {
					  		toolBar.append("tempMenuItem.onClick = \" if(getTopWindow().bclist != null){ getTopWindow().bclist.clear();");
					  		toolBar.append("getTopWindow().bclist.insert(\\\"MyDesk\\\", \\\"").append(itemLabel).append("\\\", \\\":\\\", null, null, \\\"").append(itemUrl.toString()).append("\\\");").append("};");
	                    	if("AEFPageHistoryToolbar".equalsIgnoreCase(itemName)){
	                    		toolBar.append("\";");
	                    	} else {
	                    		toolBar.append("emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(itemLabel).append("\\\", \\\"toolbar\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
	                    	}
			  		} else {
			  			if(!"AEFPageHistoryToolbar".equalsIgnoreCase(itemName) && !UIToolbar.willSubmit(component)){
			  				toolBar.append("tempMenuItem.onClick = \" emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(itemLabel).append("\\\", \\\"toolbar\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
			  			}
			  		}                    

                    String labelsk = (String)component.get("label");                    
                    labelsk   = FrameworkUtil.findAndReplace(labelsk, "'", "\\\\'");  
                    if("true".equals(component.get("isCategoryTreeCommand"))){
                    	toolBar.append("tempMenuItem.onClick = \"if(getTopWindow().bclist != null) getTopWindow().bclist.insert(\\\"").append(component.get("objectId"))
                        		.append("\\\",null,null,\\\"").append(labelsk).append("\\\",null,\\\"").append(itemUrl.toString()).append("\\\");");
                   		if(!UIToolbar.willSubmit(component)) {
                   			toolBar.append("emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(labelsk).append("\\\", \\\"tree\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
                   		}else{
                   			toolBar.append("\";");
                   		}
                    }
                }
            }
            if(UIUtil.isNotNullAndNotEmpty(sbModeforDynamicMenu)){
                toolBar.append("tempMenuItem.sbModeforDynamicMenu = \"").append(sbModeforDynamicMenu).append("\";");
            }
        }
        else if ("Menu".equals(itemType))
        {
            if (level == 0)
            {
				//Modified for RMB START
	            if (bolDynamicCmd)
	            {
	                toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\",\"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
	                toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
	                toolBar.append(", \"").append(iLabelLength);                
	                toolBar.append("\",\"").append("");
	                toolBar.append("\",\"").append(strJPOName);
	                toolBar.append("\",\"").append(strMethodName);
	                toolBar.append("\",\"").append(strName);
	                toolBar.append("\",\"").append(strAlignment);
	                toolBar.append(isSelectionRequired ? "\"),true);\n" : "\"));\n");
	                toolBar.append("objMenuItem.addMenu(new emxUIToolbarMenu());");
	                toolBar.append("objMenu = objMenuItem.menu;");
	                toolBar.append("objStack.push(objMenu);");
	               	toolBar.append("objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", emxUIConstants.STR_LOADING_MENU, \"\",\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", false");
					toolBar.append(",\"").append(strJPOName);
					toolBar.append("\",\"").append(strMethodName);
					toolBar.append("\",\"").append(strName);
					toolBar.append("\",\"").append(strAlignment);
					toolBar.append("\"));");
	                toolBar.append("objMenu = objStack.pop();");
              	}else if (!bolDynamicCmd )
          		 {
	           		//Modified for RMB END
	                String urlcode = "";
	                if (!"null".equalsIgnoreCase(itemUrl.toString()) && !"".equals(itemUrl.toString()))
	                {
	                        urlcode = ", \"" + itemUrl.toString() + "\",\"" + itemTargetLocation + "\"";
	                }

	                if (itemIcon.length() > 0)
	                {
			            // To avoid displaying of the label content if it is ClipboardCollections and diplaying ToolTip for Clipboard Collections Menu 
			            if (itemName.equals("AEFClipboardCollections"))
			            {
							 String strToolTip = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Collections.AEFClipboardCollections.Tooltip", new Locale((String)requestParams.get("languageStr")));							 
			                 toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, \"").append(itemIcon).append("\",\"").append(strToolTip).append("\"");		                    
			            }
			            else
			            {
			                if(itemLabel.length() == 0){
			                		toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_ONLY, \"").append(itemIcon).append("\",\"").append(UIToolbar.getAlt(component)).append("\"");
			                }else{
							 toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.ICON_AND_TEXT, \"").append(itemIcon).append("\",\"").append(itemLabel).append("\"");
			            }
			            }

	                    if (!"null".equalsIgnoreCase(itemUrl.toString()) && !"".equals(itemUrl.toString()))
	                    {
	                        toolBar.append(urlcode);
	                    }else{
	                        toolBar.append(", \"\", \"\"");
	                    }
	
	                    if (isHomePage)
	                    {
	                        toolBar.append(", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
	                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
	                        toolBar.append("\", \"").append(registeredSuite);
	                        toolBar.append("\", ").append(blnHistoryEnabled);
	                        toolBar.append(", \"").append(iLabelLength).append("\"");
	                    }else{
	                        toolBar.append(", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ");
	                        toolBar.append(blnHistoryEnabled);
	                        toolBar.append(", \"").append(iLabelLength).append("\"");
	                    }
	                }
	                else
	                {

	                    toolBar.append("objMenuItem = currentToolbarObj.addItem(new emxUIToolbarButton(emxUIToolbar.TEXT_ONLY, \"\",\"").append(itemLabel).append("\"");
	
	                    if (!"null".equalsIgnoreCase(itemUrl.toString()) && !"".equals(itemUrl.toString()))
	                    {
	                        toolBar.append(urlcode);
	                    }else{
	                        toolBar.append(", \"\", \"\"");
	                    }
	
	                    if (isHomePage)
	                    {
	                        toolBar.append(", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
	                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
	                        toolBar.append("\", \"").append(registeredSuite);
	                        toolBar.append("\", ").append(blnHistoryEnabled);
	                        toolBar.append(", \"").append(iLabelLength).append("\"");
	                    }else{
                        toolBar.append(", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ");
                        toolBar.append(blnHistoryEnabled);
                        toolBar.append(", \"").append(iLabelLength).append("\"");
                    }
                }
				// Modified for RMB START
				if("true".equals(component.get("isCategoryToolbar"))){
					toolBar.append(",\"").append("Categories");	
				}else{
					toolBar.append(",\"").append("");
				}
				toolBar.append("\",\"").append(strJPOName);
				toolBar.append("\",\"").append(strMethodName);
				toolBar.append("\",\"").append(strName);
				toolBar.append("\",\"").append(strAlignment);
				toolBar.append("\"");
				//Modified for RMB END
                toolBar.append(isSelectionRequired ? "),true);\n" : "));\n");
                //Added to support Structure Browser - Edit Mode Toolbar 						
				toolBar.append("objMenuItem.setMode(\"").append(modeSetting.toString()).append("\");");				  
				toolBar.append("objMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");"); 
				toolBar.append("objMenuItem.displayMode=objMenuItem.getDisplayMode();");
				toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");
                toolBar.append("objMenuItem.addMenu(new emxUIToolbarMenu);\n");
                toolBar.append("objMenu = objMenuItem.menu;\n");
                String categoryName = (String) requestParams.get("category");
                if(UIUtil.isNotNullAndNotEmpty(categoryName)){
                    toolBar.append("objMenuItem.category = \"").append(XSSUtil.encodeForJavaScript(context, categoryName)).append("\";");
                }               
                toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");              
                toolBar.append("objMenuItem.setRMB(\"").append(isRMB).append("\");");
                toolBar.append("objMenuItem.grayout = \"").append(grayout).append("\";");
                toolBar.append("objMenu.setRMB(\"").append(isRMB).append("\");");
                 if(isRMB.contains("true")){
                toolBar.append("objMenu.setExpanded(\"").append(expanded).append("\");"); 
                toolBar.append("objMenu.expanded=objMenu.getExpanded();");
               }
                toolBar.append("objStack.push(objMenu);\n"); //push menu into stack
		 	// Modified for RMB START
        	}
        	// Modified for RMB END
            }
            else
            {
                if (UIToolbar.isPullRightMenu(component) == false)
                {
                    toolBar.append("objMenu.addItem(new emxUIToolbarMenuTitle(\"").append(itemLabel).append("\"));\n");
                }
                else
                {
                    if (itemIcon.length() > 0 && (itemLabel.length() > 0 || UIToolbar.getAlt(component).length() > 0))
                    {
                        if(itemLabel.length()==0){
                            itemLabel = UIToolbar.getAlt(component);
                            }
                    
                        toolBar.append("objMenuItem = objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.ICON_AND_TEXT, \"").append(itemIcon).append("\",\"").append(XSSUtil.encodeForHTML(context, itemLabel)).append("\", \"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                    }
                    else
                    {
                        toolBar.append("objMenuItem = objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", \"").append(itemLabel).append("\", \"").append(itemUrl.toString()).append("\",\"").append(itemTargetLocation);
                    }

                    if (isHomePage)
                    {
                        toolBar.append("\", \"").append(strMenu).append("\", \"").append(itemName).append("\",\"").append(itemLabel);
                        toolBar.append("\", \"").append("toolbar").append("\", \"").append(itemWidth).append("\",\"").append(itemHeight);
                        toolBar.append("\", \"").append(registeredSuite);
                        toolBar.append("\", ").append(blnHistoryEnabled);
                    }else{
                        toolBar.append("\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", ").append(blnHistoryEnabled);
                    }
					// Modified  for RMB START
                	toolBar.append(",\"").append(strJPOName);
                    toolBar.append("\",\"").append(strMethodName);
                    toolBar.append("\",\"").append(strName);
                    toolBar.append("\",\"").append(strAlignment);
                    toolBar.append("\"");
                    //Modified for RMB END	
                    toolBar.append(isSelectionRequired ? "),true);\n" : "),false);\n");
                    
                    if("true".equals(component.get("isCategoryTreeMenu"))){
                    	toolBar.append("objMenuItem.onClick = \"if(getTopWindow().bclist != null) getTopWindow().bclist.insert(\\\"").append(component.get("objectId"))
	                    		.append("\\\",null,null,\\\"Home\\\",null,\\\"").append(itemUrl.toString()).append("\\\");");
                    	toolBar.append("emxUICore.addToPageHistory(\\\"").append(registeredSuite).append("\\\", \\\"").append(itemUrlEscaped).append("\\\", \\\"").append(strMenu).append("\\\", \\\"").append(itemName).append("\\\", \\\"").append(itemTargetLocation).append("\\\", \\\"").append(itemLabel).append("\\\", \\\"toolbar\\\", ").append(itemWidth).append(", ").append(itemHeight).append(");\";");
                    }
                    
                    //Added to support Structure Browser - Edit Mode Toolbar 
		            toolBar.append("objMenuItem.setMode(\"").append(modeSetting.toString()).append("\");\n");        
		            toolBar.append("objMenuItem.setDisplayMode(\"").append(displayModeSetting.toString()).append("\");\n"); 
		            toolBar.append("objMenuItem.displayMode=objMenuItem.getDisplayMode();\n");
                    toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                    toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");

                    toolBar.append("objStack.push(objMenu);\n");
                    toolBar.append("objMenuItem.addMenu(new emxUIToolbarMenu);\n");
                    toolBar.append("objMenu = objMenuItem.menu;\n");
					//Modified for RMB START
                    if (bolDynamicCmd && level != 0)
                    {
                        toolBar.append("objStack.push(objMenu);");
                        toolBar.append("objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", emxUIConstants.STR_LOADING_MENU, \"\",\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", false");
                        toolBar.append(",\"").append(strJPOName);
                        toolBar.append("\",\"").append(strMethodName);
                        toolBar.append("\",\"").append(strName);
                        toolBar.append("\",\"").append(strAlignment);
                        toolBar.append("\"));");
                        toolBar.append("objMenu = objStack.pop();");
                    }
                     //  Modified for RMB END
                    toolBar.append("objMenuItem.setRMB(\"").append(isRMB).append("\");");
                    toolBar.append("objMenuItem.grayout = \"").append(grayout).append("\";");
                    toolBar.append("objMenuItem.setExpanded(\"").append(expandedSetting.toString()).append("\");"); 
                    toolBar.append("objMenuItem.expanded=objMenuItem.getExpanded();");
                    toolBar.append("objMenu.setRMB(\"").append(isRMB).append("\");");  
                     if(isRMB.contains("true")){
                    toolBar.append("objMenu.setExpanded(\"").append(expanded).append("\");"); 
                    toolBar.append("objMenu.expanded=objMenu.getExpanded();");
                   }
                }
            }
        }
        else if ("MenuSeparator".equals(itemType))
        {
            toolBar.append("objMenu.addItem(new emxUIToolbarMenuSeparator());\n");
        }

        // create javascript for the children
        MapList children = UIToolbar.getChildren(component);
        if (children != null)
        {
        	//Modified for RMB START
	         if (!bolDynamicCmd)
	         {
				for (int i = 0; i < children.size(); i++)
				{
	              strJPOName1 = UIToolbar.getSetting((HashMap) children.get(i),"Dynamic Command Program");                   
	              if (strJPOName1 != null && !"".equals(strJPOName1) && !UIToolbar.isMenu((HashMap) children.get(i)))
	              {
	                  strMethodName1 = UIToolbar.getSetting((HashMap) children.get(i),"Dynamic Command Function");
	                  strName1 = UIComponent.getName((HashMap) children.get(i));
	                  bolDynamicChild = true;
	                  break;
	              }
	          }
	          if (bolDynamicChild)
	          {
	             	toolBar.append("objMenu.addItem(new emxUIToolbarMenuItem(emxUIToolbar.TEXT_ONLY, \"\", emxUIConstants.STR_LOADING_MENU, \"\",\"\", \"\", \"\", \"\", \"\", \"\", \"\", \"\", false");
	                toolBar.append(",\"").append(strJPOName1);
	                toolBar.append("\",\"").append(strMethodName1);
	                toolBar.append("\",\"").append(strName);
	                toolBar.append("\",\"").append(strAlignment);
	                toolBar.append("\"));");   
	         }
         }
          if (!bolDynamicChild && !bolDynamicCmd)
           {
	           // Modified for RMB END
	        
	            for (int i = 0; i < children.size(); i++)
	            {

	            		HashMap hm = (HashMap)children.get(i);
	            		if(hm.containsKey("settings")){
	            			HashMap hmSettings = (HashMap)hm.get("settings");
	            			if(hmSettings != null && hmSettings.containsKey("Level")){
	            				String strLevel = (String)hmSettings.get("Level");
	            				if(strLevel.indexOf(",")!= -1){
	            					continue;
	            				}
	            			}
	            		}

 	   	                toolBar.append(loadToolbar(context, (HashMap) children.get(i), requestParams, level + 1, errorLabel, isHomePage, strLabelPrefix, bUseAlternateCmdIcon));

	            }
		
			//Modified for RMB START
			}
			//Modified for RMB END
            if (UIToolbar.isPullRightMenu(component))
            {
                toolBar.append("objMenu = objStack.pop();\n");
            }
        }
    }
    catch (Exception e)
    {
       toolBar.append( "Error: Loading ToolBar --" + e.toString());
    }

    return (toolBar.toString());
}

//Method to load the toolbar 
	String loadToolbar(Context context, HashMap component,
			HashMap requestParams, int level, String errorLabel,
			boolean isHomePage) {
		return loadToolbar(context, component, requestParams, level,
				errorLabel, isHomePage, null, false);
	}%>

<%!boolean isDisplayItem(HashMap map) throws FrameworkException {
    boolean isDisplayOK = false;

		try {
        MapList children = UIToolbar.getChildren(map);

			for (int i = 0; i < children.size(); i++) {
            HashMap child = (HashMap) children.get(i);

            // if the child is a menu or menu item
				if (UIToolbar.isMenu(child)
						|| UIToolbar.isSeparator(child) == false) {
                isDisplayOK = true;
                break;
            }
        }
		} catch (Exception e) {
        DebugUtil.debug("Error: Processing ToolBar --" + e.toString());
    }

    return (isDisplayOK);
	}%>


<%!//This method checks if the commands in the passed in Toolbar can be pivoted and shown..
boolean canPivotCommands(Map toolBar) throws Exception{
	String PivotCommandLimit = UIToolbar.getSetting(toolBar, "PivotCommandLimit");
	int tlbLimit =0;	
	if(UIUtil.isNotNullAndNotEmpty(PivotCommandLimit)){
		try{
			tlbLimit=Integer.parseInt(PivotCommandLimit);
		}catch(Exception e){}
	}

    //Only if the Pivot functionality is enabled
	if(tlbLimit != 0){
	limit=tlbLimit;
	}else if (limit > 0
				&& getCommandCount(UIToolbar.getChildren(toolBar), limit) <= limit) {
            //If the number of commands count is less than the limit then return true
            return true;
    }
    
    return false;
}

//This command gets the number of commands present in the passed in menu content.
//This method will check for all levels
	int getCommandCount(MapList menuContent, int limit)
			throws FrameworkException {
    int count = 0;
    if(menuContent != null){
            String childType = "";
            String strActionType = "";
            HashMap child = null;
            HashMap settingsMap = null;
            for(int i=0; i<menuContent.size(); i++){
                child = (HashMap)menuContent.get(i);
                childType = "";
                if(child != null) {
                    childType = (String)child.get("type");
                }
                //If the item is command inceremnt the count
                if("command".equalsIgnoreCase(childType)) {
                    settingsMap = (HashMap)child.get("settings");
                    if(settingsMap != null){
                        strActionType = (String)settingsMap.get("Action Type");
						if (strActionType != null
								&& strActionType.equalsIgnoreCase("Separator")) {
                            continue;
                        }
                    }
                    count++;
                } else if("menu".equalsIgnoreCase(childType)) {
                    //If the item is menu then recurese to the same method
                    count+=getCommandCount(UIToolbar.getChildren(child),limit);
                }
                //If the count crossed the limit then return
                if(count>limit){
                    break;
                }
            }
    }
    return count;
}

//This method loads the passed in menu content horizontaly directly under the toolbar.
//This method will not pivot a command which is already present in the toolbar. This is 
//tracked in the StringList toolCommands.
	String loadMenuCommandsPivoted(Context context, HashMap child,
			HashMap requestParams, int level, String errorLabel,
			boolean isHomePage, StringBuffer sbComponentLabel,
			matrix.util.StringList duplicateLabels,
			matrix.util.StringList toolCommands, boolean isPrevItmSeparator,
			String currentToolbar) {
    StringBuffer sbReturn = new StringBuffer(1024);
    if(UIToolbar.isMenu(child)) {            
			//get Mode setting from parent menu
			String strParentMenuMode = UIToolbar.getSetting(child,"Mode");
			String strParentLabel = UIToolbar.getLabel(child);
			//Getting the childeren of the passed in menu.
            MapList children = UIToolbar.getChildren(child);
            if(children != null){
                String strComponentPrefix = "";
                //Initializing the label prefix and suffixing it with the seperator if there is 
                //Prefix already present.
                if(sbComponentLabel == null){
                    sbComponentLabel = new StringBuffer(200);
				} else if (!((sbComponentLabel.toString())
						.endsWith(lablePrefisSeperator) && (sbComponentLabel
						.toString()).trim().length() > 0)) {
                    sbComponentLabel.append(lablePrefisSeperator);
                }
                HashMap component = null;
                //Iterate thro the children and load only the commands and ignore the menu.
                for (int i = 0; i < children.size(); i++){
                    component = (HashMap) children.get(i);
                    //if the first item to display is a separator, skip it
					if ((i == 0 && UIToolbar.isSeparator(component))
							|| (UIToolbar.isSeparator(component) && isPrevItmSeparator)) {
                        continue;
                    }
                    strComponentPrefix = "";
                    if(UIToolbar.isMenu(component)){
                        sbComponentLabel.append(UIToolbar.getLabel(component));
                        overrideModeSetting(component,strParentMenuMode);
						sbReturn.append(loadMenuCommandsPivoted(context,
								component, requestParams, level, errorLabel,
								isHomePage, sbComponentLabel, duplicateLabels,
								toolCommands, isPrevItmSeparator,
								currentToolbar));
                    } else {
                        if(!UIToolbar.isSeparator(component)){
                            if(toolCommands.contains(UIComponent.getName(component))){
                                continue;
                            }
							if (duplicateLabels != null
									&& duplicateLabels.contains(UIToolbar
											.getLabel(component))) {
								strComponentPrefix = sbComponentLabel
										.toString();
                            }
                            isPrevItmSeparator = false;
                            overrideModeSetting(component,strParentMenuMode);
							sbReturn.append(loadToolbar(context, component,
									requestParams, level, errorLabel,
									isHomePage, strComponentPrefix, true,
									currentToolbar));
                        } else {
                            isPrevItmSeparator = true;
							sbReturn.append(loadToolbar(context, component,
									requestParams, level, errorLabel,
									isHomePage, null, true, currentToolbar));
                        }
                    }
                }
            }
    } else if (child != null){
            //If the passed in Component is command then the command is directly loaded.
			sbReturn.append(loadToolbar(context, child, requestParams, level,
					errorLabel, isHomePage, null, true, currentToolbar));
    }
    return sbReturn.toString();
}

//This method checks for duplicate labeled menus in the passed in menu and will return the 
//duplicate labels in a String list.
	matrix.util.StringList getDuplicateCommandLabels(Context context,
			HashMap menuMap, matrix.util.StringList duplicateList,
			matrix.util.StringList uniqCommandList) throws FrameworkException {
    if(duplicateList == null){
            duplicateList = new matrix.util.StringList();
    }
    if(uniqCommandList == null){
            uniqCommandList = new matrix.util.StringList();
    }
    if(UIToolbar.isMenu(menuMap)) {
            MapList children = UIToolbar.getChildren(menuMap);
            if(children != null){
                String strCompLabel = "";
                HashMap component = null;
                //Iterate thro the children and identify the Duplicate command labels
                for (int i = 0; i < children.size(); i++){
                    component = (HashMap) children.get(i);
                    if(UIToolbar.isMenu(component)){
                        if(isDisplayItem(component)){
							duplicateList = getDuplicateCommandLabels(context,
									component, duplicateList, uniqCommandList);
                        }
                    } else if (!UIToolbar.isSeparator(component)){
                        strCompLabel = UIToolbar.getLabel(component);
                        if(!uniqCommandList.contains(strCompLabel)){
                            uniqCommandList.add(strCompLabel);
                        } else if(!duplicateList.contains(strCompLabel)){
                            duplicateList.add(strCompLabel);
                        }
                    }
                }
            }
    }
    
    return duplicateList;
}
//method to get the combobox using Range Function/Range Program or Range Values setting.
	StringBuffer getComboboxBuffer(Context context, HashMap component,
			HashMap requestParams, String formFieldName, String RangeValues,
			String itemLabel, String itemUrl, String itemTargetLocation,
			String itemWidth, String itemHeight, String actionLabel,
			String submitFunction, String submitProgram, String uiType,
			String width, String altText, boolean isPopModal,
			boolean willSubmit, int iLabelLength, String defaultValue) {
		StringBuffer comboBuffer = new StringBuffer();
		String strLanguage = (String)requestParams.get("languageStr");
		String strDisplayText = itemLabel;

		if (iLabelLength < strDisplayText.length()) {
			strDisplayText = strDisplayText.substring(0,
					Math.min(iLabelLength, strDisplayText.length()))
					+ "...";
		}

		try {
			/*comboBuffer.append("<label title=\\\""+altText+"\\\">");
			comboBuffer.append(strDisplayText);
			if (component.containsKey("expandMenu")){
				comboBuffer.append("</label>");
				comboBuffer.append("<table><tr><td class=\\\"input\\\">");
				width = "50px";
			} else {
				comboBuffer.append("</label>");
			}*/
			comboBuffer.append("<div class=\\\"menu-dialog-head\\\" onclick=\\\"stopPropogationOnMenu()\\\">");
			comboBuffer.append(strDisplayText);
			comboBuffer.append("</div>");
			if (component.containsKey("expandMenu")){
				comboBuffer.append("<div class=\\\"menu-dialog-body\\\" onclick=\\\"stopPropogationOnMenu()\\\">");
				width = "50px";
			}
			comboBuffer.append("<select name=");
			comboBuffer.append(formFieldName);
			comboBuffer.append(" ");
			comboBuffer.append("title='");
			comboBuffer.append(altText);
			comboBuffer.append("' ");
			comboBuffer.append("style='");
			comboBuffer.append("width:");
			comboBuffer.append(width);
			comboBuffer.append(";'");
			comboBuffer.append(" ");
			comboBuffer.append("id='");
			comboBuffer.append(formFieldName);
			comboBuffer.append("' ");    
			comboBuffer.append("onChange=submitToolbarForm(");
			comboBuffer.append("'");
			comboBuffer.append(itemUrl);
			comboBuffer.append("'");    
			comboBuffer.append(",");
			comboBuffer.append("'");    
			comboBuffer.append(itemTargetLocation);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(formFieldName);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(itemWidth);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(itemHeight);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(uiType);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(submitFunction);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(submitProgram);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(isPopModal);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(willSubmit);
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append("combobox");
			comboBuffer.append("'");
			comboBuffer.append(",");
			comboBuffer.append("'");
			comboBuffer.append(FrameworkUtil.findAndReplace(formFieldName, " ",
			"_"));
			comboBuffer.append("mxcommandcode");
			comboBuffer.append("'");
			comboBuffer.append(")");
			comboBuffer.append(">");

			String labelRangeValues = UIToolbar.getSetting(component,
			"Range Display Values");
			StringList rangeList=null;
			String defaultInList="false";
			if (RangeValues == null || "".equals(RangeValues) || "null".equals(RangeValues)) {
				String fieldChoice = "";
				String fieldChoiceDisplay = "";
				UIForm formEditBean = new UIForm();
				formEditBean.fillRangeValues(context, requestParams, null,
						null, component, strLanguage, 0);
				StringList fieldChoices = formEditBean
				.getFieldChoices(component);
				StringList fieldChoicesDisplay = formEditBean
				.getFieldDisplayChoices(component);
				if(fieldChoices != null) {
					for (int j = 0; j < fieldChoices.size(); j++) {
						fieldChoice = (String)fieldChoices.get(j);
						fieldChoiceDisplay = (String) fieldChoicesDisplay.get(j);
						comboBuffer.append("<option value=\\\"");

						comboBuffer.append(fieldChoice);
						comboBuffer.append("\\\" ");
						if (fieldChoice.equals(defaultValue) || fieldChoiceDisplay.equals(defaultValue)) {
							comboBuffer.append("selected = 'selected' ");
							defaultInList="true";
						}
						comboBuffer.append(">");
						comboBuffer.append(fieldChoiceDisplay);
						comboBuffer.append("</option>");
					}
				}
			} else if (labelRangeValues != null && !"".equals(labelRangeValues)	&& !"null".equals(labelRangeValues)) {
				labelRangeValues = getMXString(context, component, labelRangeValues,	strLanguage);
				rangeList = FrameworkUtil.split(RangeValues,",");
				StringList labelList = FrameworkUtil.split(labelRangeValues, ",");
				String rangeValue = "";
				String rangeMXValue = "";

				for(int i=0; i < rangeList.size();i++){
					rangeValue = (String)rangeList.get(i);
					rangeMXValue = getMXString(context, component,(String) labelList.get(i), strLanguage);
					comboBuffer.append("<option value=\\\"");
					comboBuffer.append(rangeValue);
					comboBuffer.append("\\\" ");
					if (rangeValue.equals(defaultValue)	|| rangeMXValue.equals(defaultValue)) {
						comboBuffer.append("selected = 'selected' ");
						defaultInList="true";
					}
					comboBuffer.append(">");
					comboBuffer.append(rangeMXValue);
					comboBuffer.append("</option>");
				}
			}
			else {
				labelRangeValues = getMXString(context, component,labelRangeValues,strLanguage);
				rangeList = FrameworkUtil.split(RangeValues,",");
				String rangeValue = "";
				String rangeMXValue = "";
				for(int i=0;i<rangeList.size();i++){
					rangeValue = (String)rangeList.get(i);
					rangeMXValue = getMXString(context, component,(String)rangeList.get(i),strLanguage);
					comboBuffer.append("<option value=\\\"");
					comboBuffer.append(rangeValue);
					comboBuffer.append("\\\" ");
					if (rangeValue.equals(defaultValue)|| rangeMXValue.equals(defaultValue)){
						comboBuffer.append("selected = 'selected' ");
						defaultInList="true";
					}
					comboBuffer.append(">");
					comboBuffer.append(rangeMXValue);
					comboBuffer.append("</option>");
				}
			}
			if(!"".equals(defaultValue) && defaultInList.equals("false")) {
				comboBuffer.append("<option value=\\\"");
				comboBuffer.append(defaultValue);
				comboBuffer.append("\\\" selected='selected' >");
				comboBuffer.append(defaultValue);
				comboBuffer.append("</option>");
			}
			comboBuffer.append("</select>");
			String strExpandFilter = (String) requestParams.get("toolbarExpandFilter");
			if ("true".equals(strExpandFilter)) 
			{
				/*if (component.containsKey("expandMenu")){
					comboBuffer.append("</td><td class=\\\"label\\\">");
				} else {
					comboBuffer.append("<label>");
				}*/

				comboBuffer.append(getMXString(context, component,"emxFramework.FreezePane.ExpandLevel", strLanguage));

				/*if (component.containsKey("expandMenu")){
				} else {
					comboBuffer.append("</label>");
				} */       
				requestParams.remove("toolbarExpandFilter");
			}
			if (component.containsKey("expandMenu")){
				//comboBuffer.append("</td>");
				//comboBuffer.append("<td class=\\\"button\\\">");
		        comboBuffer.append("<input type=\\\"button\\\" class=\\\"btn-default custom\\\" value=\\\"");
			    comboBuffer.append(getMXString(context, component,"emxFramework.FreezePane.Apply", strLanguage));
				comboBuffer.append("\\\" onclick=\\\"expandNLevels()\\\"/>");
				/*comboBuffer.append("</td></tr></table>");
				comboBuffer.append("<p class=\\\"hint\\\">");
				comboBuffer.append(getMXString(context, component,"emxFramework.FreezePane.ExpandHint", strLanguage));
				comboBuffer.append("</p>");*/
				comboBuffer.append("</div>");
			}

		} catch (Exception ex) {
			DebugUtil.debug("Exception in toolbar"+ex.toString());
		}
		return comboBuffer; 

}
//This method is used to Internationalize the Action Label setting
	String getMXString(Context context, HashMap component, String key, String strLanguage) {
    String strMx="";
		try {
			String fieldSuite = UIToolbar.getSetting(component,
					"Registered Suite");
			String resourceId = UINavigatorUtil
					.getStringResourceFileId(context, fieldSuite);
			strMx = (String) UINavigatorUtil.getI18nString(key, resourceId,
					strLanguage);
		} catch (Exception ex) {
			DebugUtil.debug("Exception in Internationalizing string"
					+ ex.toString());
        strMx = key;
   }
   return strMx;

}

	private String getValue(Map map, String key) {
        String value = (String) map.get(key);
        return ((value == null) ? "" : value.trim());
}

	private String getJSVariableName(String toolbarName) {
        String strToolbar = toolbarName;
		if (toolbarName != null) {
            //Modified for Bug : 348022
            int iIndex = toolbarName.lastIndexOf("/");
	        if (iIndex != -1) {
	            strToolbar = toolbarName.substring(iIndex + 1);
	            strToolbar = strToolbar.trim();
				if ("".equals(strToolbar))
					strToolbar = "_toolbar_";
	        }
	        
	        if (strToolbar.indexOf(" ") != -1) {
	            strToolbar = FrameworkUtil.findAndReplace(strToolbar," ", "_");
	        }
	        if (strToolbar.indexOf("-") != -1) {
	            strToolbar = FrameworkUtil.findAndReplace(strToolbar,"-", "_");
		   	}
	        //IR-077253V6R2012
	        if (strToolbar.indexOf("@") != -1) {
	        	strToolbar = FrameworkUtil.findAndReplace(strToolbar, "@", "_");
	        }
        }


        return strToolbar;
	}%>
