<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.Request"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<%!
/**
 * Encode the given string for JavaScript if necessary.
 * 
 * If the string contains any non ASCII value, this method will return the JS
 * code necessary to decode the value returned by XSSUtil.encodeForJavaScript
 * otherwise, it will return the value wrapped in single quotes
 * @param str String to encode 
 */
 private String encodeIfNecessary(Context context, String str) {
    String empty = "''";
    String encoded;
    if (str == null) {
        return empty;
    }

    String encodedStr = XSSUtil.encodeForJavaScript(context, str);
    if (str.equals(encodedStr)) {
        encoded = "'" + str + "'";
    } else {
        encoded = "decodeURIComponent('" + XSSUtil.encodeForJavaScript(context, str) + "')";
    }

    return encoded;
}
/**
 * Return a serialized JSON structure containing info about a search result
 * @param objectId object ID of the search result
 */
public String getResultInfo (Context context, String objectId) {
    // References:
    // ENOFramework/ENOAEFframework.mj/src/com/matrixone/apps/domain/DomainConstants.java
    // SMASLMFoundation/SMASLMCommon.mj/src/com/dassault_systemes/smaslm/matrix/common/SimulationConstants.java
    // SMASLMFoundation/SMASLMFoundation.mj/src/com/dassault_systemes/smaslm/matrix/server/SimulationUIUtil.java
    StringBuilder resultInfo = new StringBuilder();

    try {
        DomainObject DO    = DomainObject.newInstance(context, objectId);
        String physicalId  = encodeIfNecessary(context, DO.getInfo(context,"physicalid"));
        String type        = encodeIfNecessary(context, DO.getInfo(context, DomainConstants.SELECT_TYPE));
        String modified    = encodeIfNecessary(context, DO.getInfo(context, DomainConstants.SELECT_MODIFIED));
        String description = encodeIfNecessary(context, DO.getInfo(context, DomainConstants.SELECT_DESCRIPTION));
        String title = DO.getAttributeValue(context, DomainConstants.ATTRIBUTE_TITLE);
      
        if(title == null || title.equals("")){ 
			title = DO.getInfo(context, SimulationConstants.SELECT_ATTRIBUTE_VPM_NAME);
		}
        title       = encodeIfNecessary(context, title);
        String encodedOId  = encodeIfNecessary(context, objectId);

        resultInfo.append("{")
            .append("objectid: ").append(encodedOId).append(", ")
            .append("physicalid: ").append(physicalId).append(", ")
            .append("title: ").append(title).append(", ")
            .append("type: ").append(type).append(", ")
            .append("modified: ").append(modified).append(", ")
            .append("description: ").append(description)
            .append("}");
            // label
            // identifier
            // created
            // responsible
    } catch (FrameworkException e) {
        // skip result, do not expose exception
    }
    return resultInfo.toString();
}
%>
<%
// We get search result objet id from the emxTableRowId parameter. 
// This parameter can be set multiples times, in which case it is repeated
// - single: emxTableRowId:|26736.56244.41184.51159||0,2
// - multiple:
//  * emxTableRowIdActual:|26736.56244.52000.12683||0,0
//  * emxTableRowIdActual:|26736.56244.5144.3187||0,4
String[] memberIDs = Request.getParameterValues(request, "emxTableRowId");
String sourceId = Request.getParameter(request, "searchSourceId");
StringBuilder results = new StringBuilder();
Boolean appendComma = false;

if (memberIDs == null) {
    memberIDs = new String[0];
}
if (sourceId == null || sourceId.isEmpty()) {
    sourceId = "";
}

for (String tableRowId : memberIDs) {
    if (tableRowId == null || tableRowId.isEmpty()) {
        continue;
    }
    if (appendComma) {
        results.append(",\n");
        appendComma = false;
    }

    String parsedTableRow[] = tableRowId.split("\\|");
    if (parsedTableRow.length > 1 ) {
        String id = parsedTableRow[1];
        // original behavior: output IDs as sent by search JSP
        // String escapedId = XSSUtil.encodeForJavaScript(context, id);
        // results.append("'").append(escapedId).append("'");
        String resultInfo = getResultInfo(context, id);
        results.append(resultInfo);
        appendComma = true;
    }
}
%>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript">
    var message, messageWindow; 
    message = JSON.stringify({
        operation: 'plmSearch',
        selectedObjects: [<%=results%>],
        searchSourceId: <%=encodeIfNecessary(context, sourceId)%>
    });
    messageWindow = getTopWindow().getWindowOpener() || getTopWindow().top;
    if (messageWindow) {
        messageWindow.postMessage(message, "*");
    } else {
        window.console.warn('smaSpSearch: failed to get reference to window opener');
    }
    closeWindow();
 </script>
 <body></body>
 </html>

