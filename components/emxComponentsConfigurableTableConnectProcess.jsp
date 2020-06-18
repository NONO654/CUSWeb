<%-- emxComponentsConfigurableTableConnectProcess.jsp - Used to connect object(s) 

static const char RCSID[] = $Id: emxComponentsConfigurableTableConnectProcess.jsp.rca 1.3.2.1.7.4 Wed Oct 22 16:18:39 2008 przemek Experimental przemek $

--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>


<% 
  DomainObject domObj = new DomainObject();
  String objectId = emxGetParameter(request,"objectId");
  String [] selectedObjs = emxGetParameterValues(request,"emxTableRowId");
  String strSymbolicRelationship = emxGetParameter(request,"rel");
  String strRelationship = PropertyUtil.getSchemaProperty(context, strSymbolicRelationship);
  String strDirection = emxGetParameter(request,"direction");
  boolean toSideObject = true;
  /*boolean createWorkflow = false;
  String strCreateWorkflow = emxGetParameter(request,"createWorkflow");
  if(strCreateWorkflow!=null && strCreateWorkflow.equalsIgnoreCase("true")) {
      createWorkflow = true;
  }*/

  if(objectId==null) {
      //creation of workflow. 
      //System.out.println("Process page-> Start");
      //String strContent = emxGetParameter(request, "content");
      StringBuffer sbfContent = new StringBuffer();
      String []selectedContent = emxGetParameterValues(request, "emxTableRowId");
      /*if(strContent!=null && !"null".equalsIgnoreCase(strContent) && !"".equals(strContent) ) {
              sbfContent.append(strContent);
              sbfContent.append(",");
      }*/
      if(selectedContent!=null) {
          for(int count=0; count<selectedContent.length; count++) {
              sbfContent.append(selectedContent[count]);
              sbfContent.append(",");
          }
      }
      String strContent = sbfContent.toString();
      if(strContent.length()>0) {
          strContent = strContent.substring(0, strContent.length()-1);
      }
      //System.out.println("Process -> strContent="+strContent);
      //Get already connected content and update it in session
      HashMap workflowMap = (HashMap)session.getAttribute("workflowMap");
      String addedContent = (String)workflowMap.get("content");
      if(addedContent!=null && !"null".equalsIgnoreCase(addedContent) && !"".equals(addedContent)) {
          addedContent += ","+strContent;
      } else {
          addedContent = strContent;
      }
      workflowMap.put("content",addedContent);
      session.setAttribute("workflowMap",workflowMap);
      //System.out.println("process page :"+workflowMap);
  } else {
      //Adding content to workflow object
      if(strDirection != null && !"null".equals(strDirection) && !"".equals(strDirection)) {
          if(strDirection.equals("to")) {
              toSideObject = true;
          } else {
              toSideObject = false;
          }
      }

        
        // connect context object(s) with specified relationship
        try
        {
            // set Id for the object
            domObj.setId(objectId);
            if(selectedObjs != null)
            {
            	boolean ispushed = false;
                try
                {	                
	            	if(strRelationship.equals(PropertyUtil.getSchemaProperty(context, "relationship_WorkflowContent")))
	                {
	                	ContextUtil.pushContext(context);
	                	ispushed = true;
	                }
	            	domObj.addRelatedObjects(context,
	                                           new RelationshipType(strRelationship),
	                                           toSideObject,
	                                           selectedObjs);
                }
                catch(Exception ex)
                {
                	throw new FrameworkException(ex.getMessage());
                }
                finally
                {
                	if(ispushed)
                	{
                		ContextUtil.popContext(context);
                	}
                }

            }
        } catch(Exception Ex)  {
            //System.out.println("Unable to connect..."+Ex);
            session.setAttribute("error.message",Ex.getMessage());
        }
  }
%>

<script language="javascript">
      parent.window.getWindowOpener().parent.location.href =parent.window.getWindowOpener().parent.location.href;
	  window.closeWindow();
</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
