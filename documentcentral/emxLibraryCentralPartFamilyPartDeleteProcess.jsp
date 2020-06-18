<%--  Page Name   -   Brief Description
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of
   MatrixOne, Inc.
   Copyright notice is precautionary only and does not evidence any
   actual or intended publication of such program

   Description: Disconnects Child objects from Parent
   Parameters : ObjectId-parent objectId
                ChildIds to be Disconnected

   static const char RCSID[] = "$Id: emxLibraryCentralPartFamilyPartDeleteProcess.jsp.jsp.rca R418 Tue Aug 30 12:36:00 2016 j62 Experimental $";
--%>


<%--

   [PSA11]: New file created for Part Deletion as present in 16x. Please look for IR-567953 for additional details.
   THIS IS A COPY OF components/emxCommomPartDeleteProcess.jsp (NOT EXACT COPY)

 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc" %>
<%@ include file = "../common/emxTreeUtilInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js" type="text/javascript">
</script>

<%

    String strFinalerrMsg    = "";
    Vector vecObjectIds      = new Vector();

    String parentId          = emxGetParameter(request, "objectId");
    String childIds[]        = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
    String sObjId            = "";
    String strSearchType     = "";


   if(childIds!= null) {
        for(int i=0;i<childIds.length;i++) {
            RelationshipType relType = new RelationshipType(DomainConstants.RELATIONSHIP_CLASSIFIED_ITEM);          
            DomainObject parentObj = new DomainObject(parentId);
            //Part doPart = (Part)DomainObject.newInstance(context,childIds[i]);
            // Create common part bean instance if object being deleted in of type Part
            try {
                //ContextUtil.pushContext(context);
                if( (DomainObject.newInstance(context,childIds[i])).isKindOf(context,DomainConstants.TYPE_PART)){
                	com.matrixone.apps.common.Part doPart = (com.matrixone.apps.common.Part)DomainObject.newInstance(context,childIds[i]);
                    doPart.deleteObject(context);
                }else{
                    DomainObject doPart = (DomainObject)DomainObject.newInstance(context,childIds[i]);
                    doPart.deleteObject(context);           
                }
                
                vecObjectIds.addElement(childIds[i]);               
                
            } catch(Exception e) {              
                        
                String error = e.getMessage();
               if(error.indexOf("java.lang.Exception:") != -1)
               {
               int firstIndex = error.indexOf("java.lang.Exception:");
               error = error.substring(firstIndex+20);
               int endIndex = error.indexOf("Warning:");
               if(endIndex != -1)
                   error = (error.substring(0,endIndex)).trim(); 
                endIndex = error.indexOf("Severity:");
               if(endIndex != -1)
                  error = (error.substring(0,endIndex)).trim(); 
              }
              else if(error.trim().length() == 0)
              {
                error =EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.NoDeleteAccess");
              }
              if(strFinalerrMsg != null && !strFinalerrMsg.trim().equalsIgnoreCase(""))
              {
                  if(error != null && error.indexOf("'") != -1){
                        error = error.substring(error.indexOf("'"),error.lastIndexOf("'")+1);
                  }
                   strFinalerrMsg = strFinalerrMsg+","+error;
              }else{
                strFinalerrMsg = error;
              }
                if(strFinalerrMsg != null && strFinalerrMsg.indexOf(":") != -1)
                {
                    strFinalerrMsg = strFinalerrMsg.substring(strFinalerrMsg.indexOf(":")+1);
                }
                    session.setAttribute("error.message",strFinalerrMsg);
            }
            finally
             {
                 //ContextUtil.popContext(context);
             }
        }
    }

%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   <script language="javascript" src="../components/emxComponentsTreeUtil.js"></script>
   <script language="javascript" src="../documentcentral/emxLibraryCentralUtilities.js"></script>
   <script language="javascript">
       // Changes added by PSA11 start(IR-567953-3DEXPERIENCER2018x).
       updateCountAndRefreshTreeLBC("<%=appDirectory%>", getTopWindow());
	   // Changes added by PSA11 end.
       getTopWindow().refreshTablePage();
   </script>
