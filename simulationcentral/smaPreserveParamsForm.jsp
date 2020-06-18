<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@ page import="com.dassault_systemes.smaslm.matrix.web.Parameters" %>
<%@ page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil" %>

<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>

<%
// the names of the parameters accepted by this page
final Set PAGE_PARAM_NAMES_SET =
    new HashSet(Arrays.asList(
        new String[]
        {
            "smaPreserveParamsFormName",
            "smaPreserveParamsFormAction",
            "smaPreserveParamsIncludeQueryParams",
            "smaPreserveParamsSubmitForm",
            "smaPreserveParamsConfirmMessage"
        }));

// get the desired form name
String formName = emxGetParameter(request, "smaPreserveParamsFormName");
if (formName == null)
{
    // default form name
    formName = "smaPreserveParamsForm";
}

// get the form action
String formAction = emxGetParameter(request, "smaPreserveParamsFormAction");
if (formAction == null)
{
    // default is no action
    formAction = "";
}

// include query parameters in the form?
boolean includeQueryParams = true;
String includeQueryParamsString =
    emxGetParameter(request, "smaPreserveParamsIncludeQueryParams");
if (includeQueryParamsString != null)
{
    includeQueryParams = Boolean.parseBoolean(includeQueryParamsString);
}

// automatically submit the form?
boolean submitForm = true;
String submitFormString = 
    emxGetParameter(request, "smaPreserveParamsSubmitForm");
if (submitFormString != null)
{
    submitForm = Boolean.parseBoolean(submitFormString);
}

// confirmation message; only applies to automatic submission of form
String confirmMsg = emxGetParameter(request, "smaPreserveParamsConfirmMessage");
%>

<!-- start the form -->
<form name="<%= formName %>" action="<%= formAction %>" method="POST">
<%
Map queryParams = null;
if (!includeQueryParams)
{
    queryParams = SlmUIUtil.getQueryStringParameterMap(request);
%>
    <!--  NOTE: query parameters excluded from form -->
<%
}

// add the rest of the parameters to the form
for (Iterator iter = Parameters.getParameterList(request).iterator();
     iter.hasNext();)
{
    // get the next parameter
    Parameters.Parameter param = (Parameters.Parameter) iter.next();

    // get the parameter name
    String paramName = param.getName();

    // skip params for this JSP
    if (PAGE_PARAM_NAMES_SET.contains(paramName))
    {
        continue;
    }

    // skip query parameters if instructed to do so
    if (!includeQueryParams)
    {
        // get the query parameter values
        String[] queryParamValues = (String[]) queryParams.get(paramName);

        // do not repeat query parameter values
        if (queryParamValues != null &&
            Arrays.asList(queryParamValues).contains(param.getValue()))
        {
            continue;
        }
    }
%>
    <!-- add the parameter to the form as a hidden input -->
    <%= getHiddenInput(paramName, param.getValue()) %>
<%
}
%>
<!-- end the form -->
</form>

<%
// submit the form automatically if desired
if (submitForm)
{
%>
<script language="JavaScript">
<%
    // optionally required confirmation prior to sumbit
    if (confirmMsg != null)
    {
%>
if (confirm('<%= confirmMsg %>'))
{
<%
    }
%>
    document.<%= formName %>.submit();
<%
    if (confirmMsg != null)
    {
%>
}
<%
    }
%>
</script>
<%
}
%>

<%!
/**
 * Private buffer to speed up construction of the hidden input HTML
 * strings.
 */
private final StringBuilder HIDDEN_INPUT_BUF = new StringBuilder();

/**
 * @param name The hidden input name.
 * @param value The hidden input value.
 * <br><br>
 * If <code>null</code> no value attribute will be added.
 * @return The HTML for an input of type=hidden with the specified
 * name and value.
 */
private synchronized String getHiddenInput(String name, String value)
{
    HIDDEN_INPUT_BUF.delete(0, HIDDEN_INPUT_BUF.length()).
        append("<input type=\"hidden\"").
        append(" name=\"").
        append(UINavigatorUtil.htmlEncode(name)).
        append('"');
    
    if (value != null)
    {
        HIDDEN_INPUT_BUF.append(" value=\"").
            append(UINavigatorUtil.htmlEncode(value)).
            append('"');
    }
    
    return HIDDEN_INPUT_BUF.append("/>").toString();
}
%>
