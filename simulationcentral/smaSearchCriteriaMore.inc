<%-- (c) Dassault Systemes, 2007, 2008 --%>

<%
    // Search page include file:
    //     Used when the standard M1 "More" functionality is needed
    //     on a search page.  CURRENTLY NOT USED.
    //
    // Variables needed to be declared in parent JSP:
    //     simBean  - Java bean for class smaSearchSimulation
    //
    // Only show this field if it is included in a global search JSP
    // Otherwise user can search for activities, open the search
    // for sims page, from that page open the sim types search page,
    // from there he can open the search simulations page, from there
    // the user can...  We have to stop it somewhere and this is 
    // where.
    // NOTE: WE SHOULD REALLY JUST DISABLE THE CHOOSER BUTTON AND ALLOW
    // THE USER TO TYPE DATA INTO THIS FIELD.
%>
    <!--  More table  -->
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
        <td width="150">
            <img id="imgMore" src="../common/images/utilSearchPlus.gif"
                width="15" height="15" align="texttop" border="0">
            <input type="hidden" name="MoreExclude" 
                value="owner,originated,modified,description">
            <a href="#" 
                onclick="javascript:localCalendars = new Array;toggleMore(); return false;">
                <%=simBean.getMoreLabel()%>
            </a>
        </td>
        <td>&nbsp;</td>
    </tr>
    </table>

    <input type="image" name="inputImage" height="1" width="1" 
        src="../common/images/utilSpacer.gif" hidefocus="hidefocus" 
        style="-moz-user-focus: none" />

    <!--  "MORE" ATTRIBUTES  -->
    <!-- the following div MUST come just before closing form tag -->
    <div id="divMore" style="display:none"></div>
