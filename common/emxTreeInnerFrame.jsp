<%--  emxTreeInnerFrame.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
<!DOCTYPE html>

<html>
<%

    String strMode = emxGetParameter(request,"treemode");
    String rootStructureId = emxGetParameter(request,"rootStructureId");
    String objectId =emxGetParameter(request,"objectId");

    String strAction = emxGetParameter(request,"treeaction");
    if(strAction == null)
    strAction="";
    String appendParams = XSSUtil.encodeURLwithParsing(context, request.getQueryString());
    String structureTreeName = emxGetParameter(request,"structureTreeName");
    boolean showDropDown = false;
    if(structureTreeName != null && !"".equals(structureTreeName)) {
      MapList sMapList = UIMenu.getOnlyCommands(context, structureTreeName,PersonUtil.getAssignments(context));
        if(sMapList != null && sMapList.size() > 1) {
          showDropDown=true;
        }
    }
    String selectedStructure = emxGetParameter(request,"selectedStructure");
    String structureLoaded = emxGetParameter(request,"structureLoaded");

    if (objectId == null || "".equals(objectId) || "null".equals(objectId))
    {
        appendParams = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(appendParams);
    }
    String treeDisplayURL = "../common/emxTreeDisplay.jsp?" + appendParams;
    //appendParams = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(context, appendParams);
    //treeDisplayURL = com.matrixone.apps.domain.util.XSSUtil.encodeForURL(context,treeDisplayURL);

%>
<script language="javascript" type="text/javascript" src="scripts/emxUICore.js"></script>
<script language="Javascript">
var frameDisplay="";
var currentMode;
var sAction;
var sMode;
var menuName;
var selectedStructure;
var treemode ="<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
//XSSOK
var showDropDown = <%=showDropDown%>;
var structTreeName ="<xss:encodeForJavaScript><%=structureTreeName%></xss:encodeForJavaScript>";
var selectedStruct ="<xss:encodeForJavaScript><%=selectedStructure%></xss:encodeForJavaScript>";
var structureLoaded ="<xss:encodeForJavaScript><%=structureLoaded%></xss:encodeForJavaScript>";
var rootStructureId ="<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
var showNavPanel="Yes";
var currentButton="Close";
  <% if ("structure".equals(strMode)) { %>
     sMode="structure";
  <% } else { %>
     sMode="details";
  <% } %>
  <% if ("refresh".equals(strAction)) { %>
     sAction=true;
  <% } else { %>
     sAction=false;
  <% } %>

 if(getTopWindow().objStructureTree.structureMode)
  currentMode=getTopWindow().objStructureTree.structureMode;
 if(getTopWindow().objStructureTree.menuName)
  menuName=getTopWindow().objStructureTree.menuName;
 if(getTopWindow().objStructureTree.selectedStructure)
  selectedStructure=getTopWindow().objStructureTree.selectedStructure;


    if(getTopWindow().objStructureTree.root)
     rootStructureId=getTopWindow().objStructureTree.root.objectID;

    var queryst="";
  if(menuName != null && menuName !="" && selectedStructure !="" && selectedStructure != null && selectedStructure !="undefined" && menuName != "undefined"){
    if(sAction)
    {
       if(currentMode != "undefined" && (currentMode) && currentMode != null && currentMode !="")
         {
           sMode=currentMode;
         }

        structureLoaded="true";
        structTreeName =menuName;
        selectedStruct =selectedStructure;
    }else{
        queryst="&structureLoaded=true";
         if(currentMode != "undefined" && (currentMode) && currentMode != null && currentMode !="")
         {
           sMode=currentMode;
         }
        structureLoaded="true";
        structTreeName =menuName;
        selectedStruct =selectedStructure;
    }
  }
  if(showDropDown) {
      frameDisplay+="<frameset rows=\"25,*\" framespacing=\"0\" frameborder=\"no\">";
  } else {
  frameDisplay+="<frameset rows=\"0,*\" framespacing=\"0\" frameborder=\"no\">";
  }
  //XSSOK
  frameDisplay+="<frame name=\"emxUITreeBar\" src=\"emxTreeBar.jsp?treemode="+sMode+"&structureLoaded="+structureLoaded+"&selectedStructure="+selectedStruct+"&structureTreeName="+structTreeName+"&rootStructureId="+rootStructureId+"&<%=appendParams%>\" noresize=\"noresize\" scrolling=\"no\" frameborder=\"no\"  marginwidth=\"0\" marginheight=\"0\"/>";
  frameDisplay+="<frameset rows=\"*,0\" frameborder=\"no\" framespacing=\"0\">";
  frameDisplay+="<frame name=\"emxUIStructureTree\" src=\"emxTreeRefresh.jsp?tree=structure\" marginwidth=\"8\" marginheight=\"8\" />";
  frameDisplay+="<frame name=\"treeDisplay\" src=\"emxBlank.jsp\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" frameborder=\"0\"/>";
  frameDisplay+="</frameset>";
  frameDisplay+="</frameset>";
  /*if(sAction){
                    frameDisplay+="<frameset rows=\"25,*\" framespacing=\"0\" frameborder=\"yes\">";
                    frameDisplay+="<frame name=\"emxUITreeBar\" src=\"emxTreeBar.jsp?treemode="+sMode+"&structureLoaded="+structureLoaded+"&selectedStructure="+selectedStruct+"&structureTreeName="+structTreeName+"&rootStructureId="+rootStructureId+"&<%=appendParams%>\" noresize=\"noresize\" scrolling=\"no\" frameborder=\"no\"  marginwidth=\"0\" marginheight=\"0\"/>";
                    frameDisplay+="<frameset rows=\"200,*\" frameborder=\"yes\" framespacing=\"5\">";
                    frameDisplay+="<frame name=\"emxUIStructureTree\" src=\"emxTreeRefresh.jsp?tree=structure\" marginwidth=\"8\" marginheight=\"8\" />";
                    frameDisplay+="<frame name=\"treeDisplay\" src=\"emxTreeRefresh.jsp?tree=details\" marginwidth=\"0\" marginheight=\"0\" />";
                    frameDisplay+="</frameset>";
                    frameDisplay+="</frameset>";
 } else {
                    frameDisplay+="<frameset rows=\"25,*\" framespacing=\"0\" frameborder=\"yes\">";
                    frameDisplay+=" <frame name=\"emxUITreeBar\" src=\"emxTreeBar.jsp?treemode="+sMode+queryst+"&selectedStructure="+selectedStruct+"&structureTreeName="+structTreeName+"&rootStructureId="+rootStructureId+"&<%=appendParams%>\" noresize=\"noresize\" scrolling=\"no\" frameborder=\"no\"  marginwidth=\"0\" marginheight=\"0\"/>";
                    frameDisplay+="<frameset rows=\"200,*\" frameborder=\"yes\" framespacing=\"5\">";
                    frameDisplay+="<frame name=\"emxUIStructureTree\" src=\"emxTreeRefresh.jsp?tree=structure\" marginwidth=\"8\" marginheight=\"8\" />";
                    frameDisplay+="<frame name=\"treeDisplay\" src=\"<%=treeDisplayURL%>\" marginwidth=\"0\" marginheight=\"0\" />";
                    frameDisplay+="</frameset>";
                    frameDisplay+="</frameset>";
    }*/
document.write(frameDisplay);

</script>
</html>
