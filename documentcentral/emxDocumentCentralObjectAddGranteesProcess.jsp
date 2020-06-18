<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<%--
  emxDocumentCentralObjectAddGranteesProcess.jsp

  Copyright (c) 1992-2016 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any
  actual or intended publication of such program

  Description: Post Processing of the Person Chooser Rresults page
               where Folder Access is added for the selected members

  Parameters : String whoId          - Script/JSP
               String whoIdValue     - JspName
               String callPage       - access
               String objectId       - Expects the Id of the Folder object
               String jsTreeID       - Expects the jsTree Id of the object.

  Author     : PKarthick

  Date       : 01/10/2003

  History    : Version 1.6 - 02/08/2003
               Karthick - Code Clean up to improve Performance.

               Version 1.5 - 02/04/2003
               Karthick - Modified for Folder Access.

  static const char RCSID[] = "$Id: emxDocumentCentralObjectAddGranteesProcess.jsp.rca 1.14 Wed Oct 22 16:02:19 2008 przemek Experimental przemek $";

--%>

<%@ include file="../emxUICommonAppInclude.inc"%>
<%@ include file="emxLibraryCentralUtils.inc"%>

<%
    String sUITable = emxGetParameter(request,"whoIdValue");
    String callPage = emxGetParameter(request,"callPage");
    String objectId = emxGetParameter(request,"objectId");
    String jsTreeID = emxGetParameter(request,"jsTreeID");

    //Get the selected persons/roles/groups from the results page.

    String [] memberIds  = emxGetParameterValues(request,"selectedMember");

    try
    {
        if(callPage != null && callPage.equalsIgnoreCase("Access"))
        {
            Map memberAccess = new HashMap();

            /*
              Build a map which contains the selected Person,Role or Group &
              their corresponding access.This Map is later passed to the bean
              which in turn do the processing of adding access to the Folder
              object.
            */

            if(memberIds != null)
            {
                for(int i=0;i<memberIds.length;i++)
                {

                    //Get the corresponding access for the selected person.

                    String accessPersonList = (emxGetParameterValues(request,
                                          "attribute_Access"+memberIds[i]))[0];
                    memberAccess.put(memberIds[i],accessPersonList);
                }
            }

            // Adding Access by calling the bean.

            if(memberAccess.size() > 0)
            {
                DCWorkspaceVault dcWorkSpaceVault =
                       new DCWorkspaceVault(objectId);
                dcWorkSpaceVault.open(context);
                dcWorkSpaceVault.addGrantees(context,memberAccess);
                dcWorkSpaceVault.close(context);
            }

            //Removing the UITable bean from the session.

            session.removeAttribute(sUITable);
        }

    }

    catch(Exception e)
    {
        session.setAttribute("error.message",
                                          getSystemErrorMessage(e.toString()));
    }

    finally
    {

        //Removes all the Maplists from the session.

        session.removeAttribute("personMapList");
        session.removeAttribute("roleMapList");
        session.removeAttribute("groupMapList");
        session.removeAttribute("resultMapList");
    }
%>

<script language="javascript" type="text/JavaScript">//<![CDATA[
   <!-- hide JavaScript from non-JavaScript browsers
  window.getWindowOpener().parent.location.href=window.getWindowOpener().parent.location.href;
  closeWindow();

 //Stop hiding here -->//]]>
</script>

