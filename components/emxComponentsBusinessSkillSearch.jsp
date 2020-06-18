<%--  emxComponentsBusinessSkillSearch.jsp

  Displays the company's Business Skills.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsBusinessSkillSearch.jsp.rca 1.9 Wed Oct 22 16:17:55 2008 przemek Experimental przemek $";
--%>
<%@page import = "com.matrixone.apps.domain.util.*"%>
<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>


<%!
    public boolean isLastNode(MapList searchList, String searchId, String selectId, boolean topLevel){
        
        Iterator searchListItr = searchList.iterator();
        
        if(searchId != null && searchId.equals("Find") && selectId != null){
            while(searchListItr.hasNext()) {
                Map searchMap = (Map) searchListItr.next();
                String objId = searchMap.get("id").toString();
                if(objId.equals(selectId)){
                    if(searchMap.get("to[SubSkill].from.id") == null)
                        searchId = null;
                    else
                        searchId = searchMap.get("to[SubSkill].from.id").toString();
                }
                    
            }
        }
        
        if(searchId == null)
            topLevel = true;
        searchListItr = searchList.iterator();
        int allNode = 0;
        int foundNode = 0;
        while(searchListItr.hasNext()) {
            Map searchMap = (Map) searchListItr.next();
            String objId = searchMap.get("id").toString();
            if(!topLevel){
                if(searchMap.get("to[SubSkill].from.id") != null){
                    String parentId = (String) searchMap.get("to[SubSkill].from.id");
                    if(parentId.equals(searchId)){
                        allNode++;
                        if(selectId.equals(objId)) foundNode = allNode;
                    }
                }
            }else if(searchMap.get("to[SubSkill].from.id") == null){
                allNode++;
                if(selectId.equals(objId)) foundNode = allNode;
            }
        }
        
        if(allNode == foundNode)
            return true;
        else
            return false;
    }
%>

<%
                  
  DomainObject businessSkill = new DomainObject();
  
 
  String filterValue   = emxGetParameter(request,"mx.page.filter");
  String jsTreeID      = emxGetParameter( request, "jsTreeID" );
  String suiteKey      = emxGetParameter( request, "suiteKey" );
  String initSource    = emxGetParameter( request, "initSource" );
  String objectId      = emxGetParameter( request, "objectId" );
  String personId      = emxGetParameter( request, "personId" );
  String setSkillList  = emxGetParameter(request, "setSkillList");
  String topId      = emxGetParameter(request, "topId");
  String mode      = emxGetParameter(request, "mode");
  String fieldName      = emxGetParameter(request, "fieldName");
  String multiSelect      = emxGetParameter(request, "multiSelect");
  String expanded   = emxGetParameter(request, "expanded");
  String hideSkill   = emxGetParameter(request, "hideSkill");
  String sLanguage = request.getHeader("Accept-Language");
  String printerFriendly = emxGetParameter(request,"PrinterFriendly");
  String targetSearchPage = emxGetParameter(request,"targetSearchPage");
  MapList skillsList = new MapList();
  StringList  nonSelectList = new StringList();
  
  if(multiSelect == null || multiSelect.equals("null") || multiSelect.equals("")) {
     multiSelect = "true";
  }

//do initialization
  if(hideSkill == null || hideSkill.equals("null") || hideSkill.equals("")) {
     hideSkill = "true";
  }
  if(expanded==null || expanded.equals("null")|| expanded.equals("")) {
    expanded = "false";
  }
  
 
  if(setSkillList==null || setSkillList.equals("null")) {
    skillsList = null;
    setSkillList = null;
  } else {
    skillsList = (MapList) session.getAttribute("searchSkillList");
  }


  if(mode == null || !mode.equalsIgnoreCase("multiBusinessSkillSearch")){
      nonSelectList = (StringList) session.getAttribute("nonSelectList");
      if(nonSelectList == null){
        nonSelectList = new StringList();
      }
  }
  
  String jsTreeIDValue    = null;
  if (jsTreeID!=null && !jsTreeID.equals("null"))
  {
    jsTreeIDValue = jsTreeID;
  }
  if(topId == null || topId.equals("null") || topId.equals("")) {
   topId = objectId;
  }

  if(printerFriendly == null || printerFriendly.equals("") || printerFriendly.equals("null"))
  {
    printerFriendly = "false";
  }
  
  if (personId!=null && personId.indexOf("~")!= -1) {
      
      personId = personId.substring(0,personId.lastIndexOf("~"));

    }

 //set the company id to extract Business Skills



  businessSkill.setId(topId);
  

  String HAS_SUB_SKILL = "from[SubSkill]";
  String PARENT_SKILL_ID = "to[SubSkill].from.id";
  
  // Add selectables
  StringList busSelects = new StringList(14);
  busSelects.add(businessSkill.SELECT_ID);
  busSelects.add(businessSkill.SELECT_NAME);
  busSelects.add(businessSkill.SELECT_TYPE);
  busSelects.add(businessSkill.SELECT_DESCRIPTION);
  busSelects.add(HAS_SUB_SKILL);
  busSelects.add(PARENT_SKILL_ID);

  
  //get the current (root) business skill information
  MapList businessSkillList = new MapList();
  MapList topSkillList = new MapList();
  boolean removeSkills = false;
  MapList removeFinalSkillList = new MapList();
  Map parentList = businessSkill.getInfo(context, busSelects);

  String parentType = parentList.get(businessSkill.SELECT_TYPE).toString();
  String topLevelRelationShip = PropertyUtil.getSchemaProperty(context,"relationship_OrganizationSkill");


  
   if(!parentType.equals(DomainConstants.TYPE_COMPANY)) topLevelRelationShip =  PropertyUtil.getSchemaProperty(context,"relationship_SubSkill");  
  boolean refreshSelection = false;
  boolean insertSubSkill = false;

  
  topSkillList = businessSkill.getRelatedObjects(context, topLevelRelationShip, PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);


  Iterator topSkillItr = topSkillList.iterator();
  while(topSkillItr.hasNext()){
    Map topSkillMap = (Map) topSkillItr.next();
    
    String topSkillId = (String)topSkillMap.get(businessSkill.SELECT_ID);
    businessSkill.setId(topSkillId);
    businessSkill.open(context);

    if(hideSkill.equals("true")) {
        if(expanded.equals("true") && !removeSkills) {
            businessSkill.setId(objectId);
            businessSkillList = businessSkill.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)0, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
        }

        if(skillsList != null) {
            int counter = 0;              //index counter for parentListItr
            boolean parentFound = false;  //If parent is found then brean from both loops
            
            if(expanded.equals("false")) {
            
                //This entire code section is used to enter the subSkills into the correct
                //Spot in the list
                //Loops through parentList

                Iterator parentListItr = skillsList.iterator();

                while(parentListItr.hasNext()) {

                    Map parentSkillMap = (Map) parentListItr.next();
                    String skillsId = (String) parentSkillMap.get(businessSkill.SELECT_ID);
                    String parentExpanded =  parentSkillMap.get("EXPANDED").toString();

                    if(skillsId.equals(objectId) && !insertSubSkill && parentExpanded.equalsIgnoreCase("false")){
                        businessSkill.setId(objectId);
                        businessSkill.open(context);
                        businessSkillList = businessSkill.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
                        
                        //Loops thorugh child list
                        Iterator childListItr = businessSkillList.iterator();

                        while(childListItr.hasNext()) {
                            Map childSkillMap = (Map) childListItr.next();
                            String skillId = (String) childSkillMap.get(businessSkill.SELECT_ID);
                            businessSkill.setId(skillId);
                            businessSkill.open(context);
                            
                            //MapList parentSkill = businessSkill.getParentInfo(context, 1, busSelects);
                            MapList parentSkill = businessSkill.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, true, false, (short)1, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
                            
                            Map parentSkillInfo = (Map) parentSkill.get(0);
                            String parentSkillId = (String) parentSkillInfo.get(businessSkill.SELECT_ID);
                            if(skillsId.equals(parentSkillId)) {
                                parentFound = true;
                                break;
                            }
                        } //end while childListItr.hasNext()
                    
                    }
                    
                    if(skillsId.equals(objectId) && parentExpanded.equalsIgnoreCase("true")){
                        refreshSelection = true;
                    }

                    if (parentFound == true) {
                        break; //break from while(parentListItr.hasNext()
                    }   

                    counter++;
                } //end while parentListItr.hasNext()
                
            
                if(printerFriendly.equals("false") && !insertSubSkill && businessSkillList.size() > 0)
                {
                    skillsList.addAll(counter+1, businessSkillList);
                }
                businessSkillList.clear();
                businessSkillList.addAll(skillsList);
        
            }else {
                if(!removeSkills){
                MapList combinedList = new MapList();
                //following removes skills from skillList away from skills in skillsList
                Iterator skillsListItr = skillsList.iterator();
                while(skillsListItr.hasNext()) {
                    boolean foundSkill = false;
                    Map skillsMap = (Map) skillsListItr.next();
                    String skillsId = (String) skillsMap.get(businessSkill.SELECT_ID);
                    Iterator skillListItr = businessSkillList.iterator();

                    while(skillListItr.hasNext()) {
                        Map skillMap = (Map) skillListItr.next();
                        String skillId = (String) skillMap.get(businessSkill.SELECT_ID);
                        if(skillId.equals(objectId)) removeSkills= true;
                        if(skillsId.equals(skillId) && !skillId.equals(objectId)) {
                            foundSkill = true;
                            break;
                        }   
                    }

                    if(!foundSkill) {
                        combinedList.add(skillsMap);
                    }
                    
                    
                }
                //removeFinalSkillList = combinedList;
                
                // list needs to be updated to the new current list
                businessSkillList = combinedList;
                
            }       
            }
            
            //businessSkillList = removeFinalSkillList;
        }
    
        // only add parent if this is the first time to this page
        if(skillsList==null) {
            
            businessSkillList.add(topSkillMap);
        }
        
        }//end of hideSkill = true          
        else
        {
            //businessSkillList = businessSkill.getSubGoals(context,0, busSelects, false);
            businessSkillList.add(topSkillMap);
            MapList businessSubSkillList = businessSkill.getRelatedObjects(context, PropertyUtil.getSchemaProperty(context,"relationship_SubSkill"), PropertyUtil.getSchemaProperty(context,"type_BusinessSkill"), busSelects, DomainConstants.EMPTY_STRINGLIST, false, true, (short)0, DomainConstants.EMPTY_STRING, DomainConstants.EMPTY_STRING);
            Iterator businessSubSkillItr = businessSubSkillList.iterator(); 
            while(businessSubSkillItr.hasNext()){
                businessSkillList.add(businessSubSkillItr.next());
            }
            
        } //end if hideSkill = false        
    
        // modify businessSkillList to added EXPANDED value to the maps
        Iterator listIndexItr = businessSkillList.iterator();
        int listItrNum = 0;
        while (listIndexItr.hasNext()) {
            // index for dependencies
            Map listIndexObj = (Map) listIndexItr.next();
            String listId = (String) listIndexObj.get(businessSkill.SELECT_ID);
            // expanding and collapsing part
            String isExpanded = (String) listIndexObj.get("EXPANDED");
            
            if(!hideSkill.equals("true")) {
                listIndexObj.put("EXPANDED", "true");
                isExpanded = "false";
            } else if(isExpanded == null || isExpanded.equals("null")) {
                listIndexObj.put("EXPANDED", "false");
                isExpanded = "false";
            }
            
            if(listId.equals(objectId) && skillsList != null && !insertSubSkill && !refreshSelection) {
                if(isExpanded.equals("false")) {
                    listIndexObj.put("EXPANDED", "true");
                } else {
                    listIndexObj.put("EXPANDED", "false");
                }
            }
        }

    
    // set the session attribute to store the current business skill list
        if(setSkillList == null)
        {
            setSkillList = "true";
        }
        
        insertSubSkill = true;
    
    }//end of while topSkillItr
    
    session.setAttribute("searchSkillList", businessSkillList);
    boolean zeroLevelParent = false;
%>

<html>
<body>

   <form name="businessSkill" method="post" action="<%=XSSUtil.encodeForHTML(context, targetSearchPage)%>" target="_parent">
        <input type="hidden" name="personId" value="<xss:encodeForHTMLAttribute><%=personId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="targetSearchPage" value="<xss:encodeForHTMLAttribute><%=targetSearchPage%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="fieldName" value="<xss:encodeForHTMLAttribute><%=fieldName%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
        <input type="hidden" name="mode" value="<xss:encodeForHTMLAttribute><%=mode%></xss:encodeForHTMLAttribute>" />
       <table border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <img src="../common/images/iconSmallType.gif" border="0" width="16" height="16" />
                </td>
                <td nowrap>&nbsp;
                  <emxUtil:i18n localize="i18nId">
                    emxComponents.Common.BusinessSkills
                  </emxUtil:i18n>
                </td>
            </tr>
        </table>   
<%
     //initialize
     HashMap levelList = new HashMap();
%>	
					<!-- //XSSOK -->
                 <framework:ifExpr expr="<%= businessSkillList.size() > 0 %>">
                 	<!-- //XSSOK -->
                 <framework:mapListItr mapList="<%=businessSkillList%>" mapName="businessSkillMap">
<%
  String businessSkillId = (String) businessSkillMap.get(businessSkill.SELECT_ID);
    //To determine what level the current business goal is
    String parentId = (String) businessSkillMap.get(PARENT_SKILL_ID);
    String levelS = null;
    if (parentId != null && !parentId.equals("null") && !parentId.equals("")) {
       levelS = (String) levelList.get(parentId);
    }
    int level = 0;
    if (levelS != null && !levelS.equals("null") && !levelS.equals("")) {
      level = Integer.parseInt(levelS);
      level++;
    }
    levelS = "" + level;
    levelList.put(businessSkillId,levelS);
  
  
  
    String refreshURL = "emxComponentsBusinessSkillSearch.jsp?objectId=" + businessSkillId;
    refreshURL += "&jsTreeID=" + jsTreeID;
    refreshURL += "&mode=" + mode;
    refreshURL += "&multiSelect=" + multiSelect;
    refreshURL += "&fieldName=" + fieldName;
    refreshURL += "&targetSearchPage=" + targetSearchPage;
    refreshURL += "&expanded=" + businessSkillMap.get("EXPANDED") + "&personId=" + personId;
    refreshURL += "&hideSkill=" + hideSkill + "&setSkillList=" + setSkillList + "&topId=" + topId + "&isActive=true";
    boolean lastNode = false;
    boolean parentLastNode = false;
    if(level == 0){
        lastNode = isLastNode (businessSkillList, parentId, businessSkillId, true); 
    }else{ 
        lastNode = isLastNode (businessSkillList, parentId, businessSkillId, false);
        parentLastNode = isLastNode (businessSkillList, "Find", parentId, false);
    }
    
    int stopLevel = level;
    if(parentLastNode) stopLevel = level - 1;
    
    if(level == 1)
        zeroLevelParent = parentLastNode;

    String inputType = "type='Checkbox'";
    if(multiSelect.equalsIgnoreCase("false")){
        inputType= "type='Radio'";
    }else{
        inputType = "type='Checkbox'";
    }
    
    String selectName = "";
    //if(parentId == null || parentId.equalsIgnoreCase("null")){
    //  selectName = "Select";
    //}else
        selectName = "Select" + businessSkillId.replace('.', '_');
  %>
                  <table border="0" cellspacing="0" cellpadding="0">
                  <%int i = 0;if (zeroLevelParent && level > 1){i = 1;%>    
                  <td class="node"><img src="../common/images/utilSpacer.gif" width="19" height="19" border="0"/></td>
                  <%}for(; i < stopLevel; i++){%>
                  <td class="node"><img src="../common/images/utilTreeLineVert.gif" width="19" height="19" border="0"/></td>
                  <%}if(parentLastNode){%>
                  <td class="node"><img src="../common/images/utilSpacer.gif" width="19" height="19" border="0"/></td>
                  <%}%>
       				<!-- //XSSOK -->
                  <framework:ifExpr expr='<%=level == 0 && !(((String)businessSkillMap.get(HAS_SUB_SKILL)).equalsIgnoreCase("true")) && !lastNode%>'>
                    <td><img src="../common/images/utilTreeLineNode.gif" border="0" title="" alt="" border="0" width="19" height="19"/></td>
                  </framework:ifExpr>
                  <!-- //XSSOK -->
                  <framework:ifExpr expr='<%=level == 0 && !(((String)businessSkillMap.get(HAS_SUB_SKILL)).equalsIgnoreCase("true")) && lastNode%>'>
                    <td><img src="../common/images/utilTreeLineLast.gif" border="0" title="" alt="" border="0" width="19" height="19"/></td>
                  </framework:ifExpr>
                   
                     <framework:ifExpr expr="<%=level >= 0%>">
                        <!-- display correct amount of indention spaces -->
                        <!-- If the goal has a subgoal, show minus or plus icon -->
                        <!-- //XSSOK -->
                        <framework:ifExpr expr='<%=(((String)businessSkillMap.get(HAS_SUB_SKILL)).equalsIgnoreCase("true"))%>'>
                          <!-- //XSSOK -->
                          <framework:ifExpr expr='<%=(((String) businessSkillMap.get("EXPANDED")).equals("true")) && !printerFriendly.equals("true")%>'>
                              <td>
                              <framework:ifExpr expr='<%=!lastNode%>'>
                                <a href="<%=XSSUtil.encodeForHTML(context, refreshURL)%>"><img src="../common/images/utilTreeLineNodeOpen.gif" border="0" title="" alt="" border="0" width="19" height="19"/></a>
                              </framework:ifExpr>
                              <!-- //XSSOK -->
                              <framework:ifExpr expr='<%=lastNode%>'>
                                <a href="<%=XSSUtil.encodeForHTML(context, refreshURL)%>"><img src="../common/images/utilTreeLineLastOpen.gif" border="0" title="" alt="" border="0" width="19" height="19"/></a>
                              </framework:ifExpr>                              
                              </td>
                          </framework:ifExpr>
                          <!-- else if the goal is not expanded, show the plus icon -->
                          <!-- //XSSOK -->
                          <framework:ifExpr expr='<%=(((String) businessSkillMap.get("EXPANDED")).equals("false")) && !printerFriendly.equals("true")%>'>
                              <td>
                              <framework:ifExpr expr='<%=!lastNode%>'>
                                <a href="<%=XSSUtil.encodeForHTML(context, refreshURL)%>"><img src="../common/images/utilTreeLineNodeClosed.gif" border="0" title ="" alt="" border="0" width="19" height="19"/></a>
                              </framework:ifExpr>
                              <!-- //XSSOK -->
                              <framework:ifExpr expr='<%=lastNode%>'>
                                <a href="<%=XSSUtil.encodeForHTML(context, refreshURL)%>"><img src="../common/images/utilTreeLineLastClosed.gif" border="0" title ="" alt="" border="0" width="19" height="19"/></a>
                              </framework:ifExpr>                              
                              </td>
                          </framework:ifExpr>
                        </framework:ifExpr>
                    
                        <!-- Else if the goal does not have any subgoals, display connection icon -->
                        <td><!-- //XSSOK -->
                        <framework:ifExpr expr='<%=!(((String)businessSkillMap.get(HAS_SUB_SKILL)).equalsIgnoreCase("true")) && level!=0%>'>
                          <img src="../common/images/utilTreeLineLast.gif" border="0" alt="" border="0" width="19" height="19"/>
                        </framework:ifExpr>
                        <!-- //XSSOK -->
                        <framework:ifExpr expr='<%=!nonSelectList.contains(businessSkillMap.get(businessSkill.SELECT_ID))%>'>
                                <input <%=inputType%> name="businessSkills" value="<xss:encodeForHTMLAttribute><%=businessSkillId%></xss:encodeForHTMLAttribute>" onClick="selectChild(this.value);"/>
                                <input type="hidden" name="businessSkillName" value="<xss:encodeForHTMLAttribute><%=businessSkillMap.get(businessSkill.SELECT_NAME)%></xss:encodeForHTMLAttribute>"/>
                                <input type="hidden" name="<%=XSSUtil.encodeForHTML(context, selectName)%>" value="<xss:encodeForHTMLAttribute><%=level%></xss:encodeForHTMLAttribute>" />
                        </framework:ifExpr>
                        <!-- //XSSOK -->
                        <framework:ifExpr expr='<%=nonSelectList.contains(businessSkillMap.get(businessSkill.SELECT_ID))%>'>
                            <img src="../common/images/utilCheckOffDisabled.gif" border="0" alt="" border="0" width="13" height="13"/>
                        </framework:ifExpr>
                        </td>
                        <td>
                            <img src="../common/images/iconSmallSkill.gif" border="0" width="16" height="16" />
                        </td>     
                        <td nowrap>&nbsp;<%=XSSUtil.encodeForHTML(context, (String) businessSkillMap.get(businessSkill.SELECT_NAME)) %></td>
                     </framework:ifExpr>
              </table>
              </framework:mapListItr>
            </framework:ifExpr>
  			<!-- //XSSOK -->
            <framework:ifExpr expr="<%= businessSkillList.size() <=0 %>">
               <tr>
                 <td>&nbsp;</td>
               </tr>
               <tr>
                 <td>&nbsp;</td>
               </tr>
               <tr>
                 <td class="noresult" colspan="13" align="center">
                   <emxUtil:i18n localize="i18nId">
                     emxComponents.Common.BusinessSkillsNotFound
                   </emxUtil:i18n>
                 </td>
                </tr>
            </framework:ifExpr>
          
     </form>

     <form name="HiddenForm" method="post">
      <input type="hidden" name="mx.page.filter" value="<xss:encodeForHTMLAttribute><%=filterValue%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="initSource" value="<xss:encodeForHTMLAttribute><%=initSource%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="topId" value="<xss:encodeForHTMLAttribute><%=topId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="expanded" value="<xss:encodeForHTMLAttribute><%=expanded%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="hideSkill" value="<xss:encodeForHTMLAttribute><%=hideSkill%></xss:encodeForHTMLAttribute>"/>
     </form>
   </body>
  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers

    function doNext(){
<%if(mode != null && mode.equalsIgnoreCase("businessSkillSearch")){%>
    var skillId = "";
    var skillName = "";
    var multiSelect = <%=XSSUtil.encodeForJavaScript(context, multiSelect)%>;
    var objForm = document.forms[0];
    for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('businessSkills') > -1){
            if(objForm.elements[i].checked == true){
                if(multiSelect == true){
                    skillId += "#" + objForm.elements[i].value;
                    skillName += "," + objForm.elements[i+1].value;             
                }else{
                    skillId = objForm.elements[i].value;
                    skillName = objForm.elements[i+1].value;
                }
            }
        }
    }

    if(multiSelect == true){
        skillId = skillId.substring(1, skillId.length);
        skillName = skillName.substring(1, skillName.length);
    }

    objForm = parent.window.getWindowOpener().document.forms[0];
    objForm.<%=XSSUtil.encodeForJavaScript(context, fieldName)%>.value= skillName;
    objForm.<%=XSSUtil.encodeForJavaScript(context, fieldName)%>Id.value= skillId;
    closeWindow();
<%}else{%>
        if(doCheck()){
            document.forms[0].submit();
        }else{
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.SelectBusinessSkill</emxUtil:i18nScript>"); 
            return;
        }
 <%}%>
    }
    
    function doCheck() {
      var objForm = document.forms[0];
      var chkList = objForm.chkList;
      var selection = false;
      for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('businessSkills') > -1){
            if(objForm.elements[i].checked == true)
                selection = true;
        }
      }
      return selection;
      
    }
  
    function closeWindow() {
      window.closeWindow();
      return;
    }
    
    
    function selectChild(objValue){
        currentLevel = getNodeLevel(objValue);
        currentIndex = 0;
        var fieldStatus = false;
        var objForm = document.forms[0];
        for (var j=0; j < objForm.elements.length; j++){
            if (objForm.elements[j].name.indexOf('businessSkills') > -1){
                    if(objValue == objForm.elements[j].value){
                        currentIndex = j;
                        fieldStatus = objForm.elements[j].checked;
                        break;
                    }
            }
        }
        for (var j=currentIndex+1; j < objForm.elements.length; j++){
            if (objForm.elements[j].name.indexOf('businessSkills') > -1){
                nextNodeLevel = getNodeLevel(objForm.elements[j].value);
                if(nextNodeLevel > currentLevel){
                        objForm.elements[j].checked = fieldStatus;
                        objForm.elements[j].checked = fieldStatus;
                        objForm.elements[j].disabled = fieldStatus;
                }else
                    break;
            }
        }
    }
    
    
    
    function getNodeLevel(objValue){
        strName = "Select" + objValue;
        while(strName.indexOf(".") != -1){
            strName = strName.replace('.', '_');
        }
        return document.businessSkill.elements[strName].value; 
    }
    
    // Stop hiding here -->//]]>
  </script>
</html>
