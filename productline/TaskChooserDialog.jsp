<%--  TaskChooserDialog.jsp

  Project Chooser Dialog Page

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "matrix.db.Context"%>
<%@ page import = "java.util.List"%>
<%@ page import = "java.util.Map"%>
<%@ page import = "java.util.HashMap"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>

<%
try{

        //Get the list of Tasks and Projects from the session
        List lstObjectList = (List)session.getAttribute("TaskList");
        session.removeAttribute("TaskList");
        //For Localized Values
        String strLanguage = request.getHeader("Accept-Language");
        String strIcon = "";
        /* form the Key to get the associated program objects's Id  from the Maplist*/
        StringBuffer sbSelProgramId = new StringBuffer("to[");
        sbSelProgramId.append(ProductLineConstants.RELATIONSHIP_PROGRAM_PROJECT);
        sbSelProgramId.append("].from.");
        sbSelProgramId.append(DomainConstants.SELECT_ID);
        
       /* form the Key to get the associated program objects's Name  from the Maplist*/
        StringBuffer sbSelProgramName = new StringBuffer("to[");
        sbSelProgramName.append(ProductLineConstants.RELATIONSHIP_PROGRAM_PROJECT);
        sbSelProgramName.append("].from.");
        sbSelProgramName.append(DomainConstants.SELECT_NAME);
        /* form the select clause to get the Parent of the task (connected through Subtask) */
        StringBuffer sbSelParentId = new StringBuffer("to[");
        sbSelParentId.append(ProductLineConstants.RELATIONSHIP_SUBTASK);
        sbSelParentId.append("].from.");
        sbSelParentId.append(DomainConstants.SELECT_ID);
        //Get the Icon for the Program Node
        String strProgramIcon =(String) UINavigatorUtil.getTypeIconProperty(context, 
                                                                           application, 
                                                                           ProductLineConstants.TYPE_PROGRAM);
        strProgramIcon  = "../common/images/" + strProgramIcon;
        String strCurProgramId = "";
        int iParentNodeCount = 0;
        int iNodeIndex;
        int iPrevLevel=1;
%>
        <script language="javascript" type="text/javaScript">
        //<![CDATA[

        //Get reference to the tree object
        var tree = parent.tree;

        arrTreeNodes = new Array(<xss:encodeForJavaScript><%=lstObjectList.size()%></xss:encodeForJavaScript>);

        //Set the current frame to the display frame
        tree.displayFrame = self.name;

        //To display the checkboxes
        tree.multiSelect = true;

        
        
<%
        if (lstObjectList != null && (lstObjectList.size() > 0)){
%>
            //Create the root for the tree
           tree.createRoot( "<framework:i18n localize='i18nId'>emxProduct.Label.TasksProjects</framework:i18n>",
                                    "../common/images/iconSmallContent.gif", 
                                    "none");
           
<% 
            Map mapProgramNodes = new HashMap();
            /* Iterate through the objects list and display all the Program,Projects and Tasks
               in the tree structure */
            for (int i=0;i<lstObjectList.size();i++){
                    
                    
                    Map objMap = (Map)lstObjectList.get(i);
                    //Get the id, type and name of the Parent
                    String strCurName = (String)objMap.get(DomainConstants.SELECT_NAME);
                    String strCurId = (String)objMap.get(DomainConstants.SELECT_ID);
                    String strCurType = (String)objMap.get(DomainConstants.SELECT_TYPE);
                    String strCurLevel = (String)objMap.get(DomainConstants.KEY_LEVEL);
                    String strParentId = (String)objMap.get(sbSelParentId.toString());
                    String strSelectable = (String)objMap.get("Selectable");
                    strIcon =(String) UINavigatorUtil.getTypeIconProperty(context, 
                                                                          application, 
                                                                          strCurType);
                    strIcon  = "../common/images/" + strIcon;
                    int iCurLevel = Integer.parseInt(strCurLevel);
                    if (iCurLevel==1){
                      String strProgramId = (String)objMap.get(sbSelProgramId.toString());
                      if (strProgramId!=null)
                        {//if project has a associated Program
                          String strProgramName = (String)objMap.get(sbSelProgramName.toString());
                          
                          //Program node is not added to the tree
                          if (!mapProgramNodes.containsKey(strProgramId))
                            {
                              mapProgramNodes.put(strProgramId,new Integer(iParentNodeCount));
%>
                              //add the Program Node
                               objProgramNode = tree.root.addChild("<xss:encodeForJavaScript><%=strProgramName%></xss:encodeForJavaScript>", 
                                                                  "<xss:encodeForJavaScript><%=strProgramIcon%></xss:encodeForJavaScript>", 
                                                                  false, 
                                                                  "", 
                                                                  "checkbox",
                                                                  "<xss:encodeForJavaScript><%=strProgramId%></xss:encodeForJavaScript>");
                              objProgramNode.selectable = false;
                              arrTreeNodes[<xss:encodeForJavaScript><%=iParentNodeCount%></xss:encodeForJavaScript>] = objProgramNode;
<%
                              iParentNodeCount++;
%>
                            //now add the Project Node
                            objParentNode=objProgramNode.addChild("<xss:encodeForJavaScript><%=strCurName%></xss:encodeForJavaScript>", 
                                                                     "<xss:encodeForJavaScript><%=strIcon%></xss:encodeForJavaScript>", 
                                                                     false, 
                                                                     "", 
                                                                     "checkbox",
                                                                     "<xss:encodeForJavaScript><%=strCurId%></xss:encodeForJavaScript>");
                              objParentNode.selectable = false;
                              arrTreeNodes[<xss:encodeForJavaScript><%=iParentNodeCount%></xss:encodeForJavaScript>] = objParentNode;
<%                            mapProgramNodes.put(strCurId,new Integer(iParentNodeCount));
                              iParentNodeCount++;
                            }else{//Program node is already added to the tree
                                iNodeIndex = ((Integer)mapProgramNodes.get(strProgramId)).intValue();
                                mapProgramNodes.put(strCurId,new Integer(iParentNodeCount));
                                
%>
                                objProgramNode=arrTreeNodes[<xss:encodeForJavaScript><%=iNodeIndex%></xss:encodeForJavaScript>];
                                objParentNode = objProgramNode.addChild("<xss:encodeForJavaScript><%=strCurName%></xss:encodeForJavaScript>", 
                                                                        "<xss:encodeForJavaScript><%=strIcon%></xss:encodeForJavaScript>", 
                                                                        false, 
                                                                        "", 
                                                                        "checkbox",
                                                                        "<xss:encodeForJavaScript><%=strCurId%></xss:encodeForJavaScript>");
                                objParentNode.selectable = false;
                                arrTreeNodes[<xss:encodeForJavaScript><%=iParentNodeCount%></xss:encodeForJavaScript>] = objParentNode;
<%
                                iParentNodeCount++;
                            }
                        }else{//If Project doesn't have Program
                              mapProgramNodes.put(strCurId,new Integer(iParentNodeCount));
%>
                             objParentNode = tree.root.addChild("<xss:encodeForJavaScript><%=strCurName%></xss:encodeForJavaScript>", 
                                                               "<xss:encodeForJavaScript><%=strIcon%></xss:encodeForJavaScript>", 
                                                               false, 
                                                                "", 
                                                               "checkbox",
                                                               "<xss:encodeForJavaScript><%=strCurId%></xss:encodeForJavaScript>");
                            objParentNode.selectable = false;
                            arrTreeNodes[<xss:encodeForJavaScript><%=iParentNodeCount%></xss:encodeForJavaScript>] = objParentNode;
<%
                        iParentNodeCount++;
                     }
               }else{//end iCurLevelel==1 that is,not a Project Node
                        mapProgramNodes.put(strCurId,new Integer(iParentNodeCount));
                        //get the Parent node's reference
                        iNodeIndex = ((Integer)mapProgramNodes.get(strParentId)).intValue();
                    
%>
                        objParentNode=arrTreeNodes[<xss:encodeForJavaScript><%=iNodeIndex%></xss:encodeForJavaScript>];
                        objTaskNode = objParentNode.addChild("<xss:encodeForJavaScript><%=strCurName%></xss:encodeForJavaScript>", 
                                                             "<xss:encodeForJavaScript><%=strIcon%></xss:encodeForJavaScript>", 
                                                             false, 
                                                             "", 
                                                             "checkbox",
                                                             "<xss:encodeForJavaScript><%=strCurId%></xss:encodeForJavaScript>");
                        //XSSOK
                        if("<%=strSelectable%>"=="false"){
                        //Graying out the Task node if it is already connected to the Product
                        objTaskNode.selectable = false;
                        }
                        arrTreeNodes[<xss:encodeForJavaScript><%=iParentNodeCount%></xss:encodeForJavaScript>] = objTaskNode;

<%
                        iParentNodeCount++;
               }
        }//end main for
        }else{
%>
            //If no Tasks are found then display the "Objects Not Found" message
            tree.createRoot( "<framework:i18n localize='i18nId'>emxProduct.Error.NoObjects</framework:i18n>",     
                                    "../common/images/iconSmallContent.gif", 
                                    "none");
<%
        
    }
}catch(Exception e){
}

%>
//Added by Vibhu,Enovia MatrixOne for Bug 308792 on 10/3/2005
tree.propagate = false;

//Draw the tree
tree.draw();
</script>

   


   
