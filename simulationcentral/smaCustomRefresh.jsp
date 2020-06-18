<%--(c)Dassault Systemes 2013
Author  VE4 

This is a custom JSP specifically designed to provide
a fix for HF-159833.

LOGIC (What are we attempting to do here?)  We are interested in getting the latest updated files / changes 
from the back end and display these in the Category tree of Simulation Process/Simulation Activity. 
The behavior has to be consistent whether we are dealing with Versioned /Non-Versioned Docs. 
Also, it has to be consistent for Upload/Check-in at Doc and file level. Hence, whatever changes we would 
be making would be at DOC level, even if we do an operation at FILE level.

How are we going about these at code level?  There are 2 broad use cases here:

a)  For actions performed at DOC level :
 
   We detect the current selected DOC and store its drID
   We then get the parent ID of this DOC (could be either a Category or a Simulation Folder) Store it as crID
   We do a remove operation on the drID using frame.removeRows api
   Next we add this row again. Why we are doing this is because we are getting fresh data from DB. Hence, we make another call to back end. This is performed using sbAddToSelected api.
   Finally we are focusing the newly added DOC using frame.toggle() api.

b)  For actions performed at FILE level:
   There is only one extra step here. As we are at FILE level, we need to go 2 levels up to reach the container
   instead of 1 level up as in case of DOCS. So, in this case the smaCustomRefresh.jsp will be called 3 times.
   Rest of steps are same as above for DOCS.

Important point here is  while doing the action removeRow on the selected DOC, we are in 
essence breaking the link / relationship between the DOC and the its parent (Category/Folder). 
For performing any actions on DOC like remove/export etc.. we need this relID. 
Hence, same has to be taken care at code level to explicitly find it again and pass it in the sXML to refresh action.

KEY :
oid --> objectID
rowID --> rowID of selected row
toggleID --> toggle ID of added row
relid --> relatonship ID
sXML --> XML being constructed  finally using StructureBrowserUtil.convertToXMLString method

recursiveRowId --> this would be the rowID which would be set during the recursive call to ths page

--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>


<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.StructureBrowserUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>

<script type="text/javascript" 
src="../common/scripts/emxUIConstants.js"></script>

<script type="text/javascript" 
src="../common/scripts/emxUICore.js"></script>

<script type="text/javascript" 
src="../common/scripts/emxUIFreezePane.js"></script>

<script type="text/javascript"
src="../simulationcentral/smaStructureBrowser.js"></script>


<%
  //TODO VE4
  // Recursive calls to the same JSP and legacy JS needs to be re-thought.
  //TODO VE4
  
  
  String sXML         = "";
  String toggleID     = "";
  String relid        = "";
  String refreshFrame = "detailsDisplay";
  
  //on the recursive JSP call take value from session
  String rowID        = (String)session.getAttribute("recursiveRowId");
  // if not take it from the checked box
  if(rowID==null)
  {
      try
      {
            
      String[] rowIDs     = request.getParameterValues("emxTableRowId");
      
      //If multiple '?' character exists in any of the row IDs (string) 
      //then remove the part of string from second occurence of '?' 
      //till end its end 
      for(int i = 0; i<rowIDs.length; i++) {
          
          String currentRowID = rowIDs[i],
                 undesiredCharacter = "?";
          if(currentRowID.contains(undesiredCharacter)) {
              
              int indexOfQuestionMark = currentRowID.indexOf(undesiredCharacter);
              currentRowID = currentRowID.substring(0, indexOfQuestionMark);
              rowIDs[i] = currentRowID;
          }
      }

      rowID            = FrameworkUtil.join(rowIDs,"\\|");
           
      session.setAttribute("recursiveRowId",rowID);
      session.setAttribute("specialRowID",rowID);
      }
      catch(Exception cleansession)
      {
          rowID               = (String)session.getAttribute("specialRowID");
          session.removeAttribute("specialRowID");
      }
  }
  // remove session stuff when done
  else
      session.removeAttribute("recursiveRowId");
  Boolean isDoc    = SimulationUIUtil.checkDoc(context,rowID);
  String t[]       = SimulationUIUtil.getParentInfoForSBNode(context,rowID);
  // container row id
  String crid      = emxGetParameter(request, "containerRowID");
  if(crid!=null && !"".equals(crid))
     session.setAttribute("crid",crid);
  // document row id
  String drid      = emxGetParameter(request, "docRowID");
  String doclevel;
  String containerlevel;
  if(isDoc)
  {
      doclevel       = t[0];
      containerlevel = t[1];
  }
  else
  {
      doclevel       = t[1];
      containerlevel = t[3];
  }
  if(drid != null)
      rowID = drid;
  if(crid==null && drid == null)
  {
   
      %>
        <script>
        var containerRowid = null;
        var frame        = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
        <%-- get the container id from DOM structure --%>
        // for doc this is like specification or activity row
        var containerrow  = emxUICore.selectSingleNode(frame.oXML.documentElement,
        "/mxRoot/rows//r[@id = '<%=containerlevel%>']");
        // for doc this is like folder or category.
        var parentRow  = emxUICore.selectSingleNode(frame.oXML.documentElement,
        "/mxRoot/rows//r[@id = '<%=doclevel%>']");
        if(parentRow && parentRow.parentNode && containerrow && containerrow.parentNode)
        {
            containerRowid      =  parentRow.parentNode.getAttribute("r")
                                 + "|" + parentRow.parentNode.getAttribute("o")
                                 + "|" + containerrow.parentNode.getAttribute("o")
                                 + "|" + parentRow.parentNode.getAttribute("id");
                                 
        }
        <%-- Call the JSP again passing JS values to Java variables --%>
        window.location =
        ("../simulationcentral/smaCustomRefresh.jsp?containerRowID="+containerRowid);
        </script>
      <%
  }
  if(!isDoc && crid!=null && drid == null)
  {
      %>
      <script>
      var containerRowid = null;
      var frame        = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
      <%-- get the container id from DOM structure --%>
      // for doc this is like specification or activity row
      var containerrow  = emxUICore.selectSingleNode(frame.oXML.documentElement,
      "/mxRoot/rows//r[@id = '<%=t[1]%>']");
      // for doc this is like folder or category.
      var parentRow  = emxUICore.selectSingleNode(frame.oXML.documentElement,
      "/mxRoot/rows//r[@id = '<%=t[0]%>']");
      if(parentRow && parentRow.parentNode && containerrow && containerrow.parentNode)
      {
          containerRowid      =  parentRow.parentNode.getAttribute("r")
                               + "|" + parentRow.parentNode.getAttribute("o")
                               + "|" + containerrow.parentNode.getAttribute("o")
                               + "|" + parentRow.parentNode.getAttribute("id");
                               
      }
      <%-- Call the JSP again passing JS values to Java variables --%>
      window.location =
      ("../simulationcentral/smaCustomRefresh.jsp?docRowID="+containerRowid);
      </script>
      <%
  }
  %>
  <script>
  var frame        = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
  var rowsToRemove = new Array();
  rowsToRemove[0]  = "<%=rowID%>";
  frame.removeRows(rowsToRemove);
  </script>
  <%
  String newFile = SimulationUIUtil.getOID(context,rowID);

  if(drid!=null)
  {
      crid = (String)session.getAttribute("crid");
      session.removeAttribute("crid");    
  }
  String cid = null;
  if(crid!=null)
	cid = SimulationUIUtil.getOID(context,crid);
  
  if(cid!=null && !"".equals(cid) && !newFile.contains("~"))
    relid = SimulationUIUtil.getParentContainerRelationship(context,cid,newFile);
  
  //make xml format to submit to the SB                                                             
  StringList content = new StringList();
  content.addElement(newFile+"|"+relid);
  
  // get the toggleID of the added row
  toggleID = SimulationUIUtil.getToggleID(context,rowID);
  
  
      
      sXML = StructureBrowserUtil.convertToXMLString
      (context,"add","",crid,content,refreshFrame,true);
      
   if(toggleID!=null && !"".equals(toggleID))
       sXML = SimulationUIUtil.formatForToggle(context,sXML,toggleID);
  
%>
<%=sXML%>

