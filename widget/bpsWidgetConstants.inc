<%--
emxWidgetConstants.inc - Constants used by Widgets.

Copyright(c) 1992 - 2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne, Inc.
Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program
--%>
<%@page import = "java.util.*,
                   com.matrixone.apps.domain.util.PropertyUtil,
                   com.matrixone.apps.domain.util.ContextUtil,
                   com.matrixone.apps.domain.util.EnoviaResourceBundle,
                   com.dassault_systemes.enovia.bps.widget.UIWidgetUtil,
                   matrix.db.Context,
                   matrix.util.MatrixException,
                   com.matrixone.apps.domain.util.XSSUtil,
                   java.net.URLEncoder" %>
<%
String sMyAppsURL, sRealURL, sQstring;
//IFWE is adding ?v=10 to URLS, we can't have this here...
sQstring = URLEncoder.encode(request.getQueryString().replace('?','&'), "UTF-8");


sMyAppsURL = PropertyUtil.getEnvironmentProperty(null, "MYAPPS_URL");
sRealURL = UIWidgetUtil.getSeverRealPath(request); //sRealURL e.g. http://servername.dsone.3ds.com:8080/enovia
final HttpServletRequest requestObj = request; // this is needed for Websphere & Weblogic.
ContextUtil.Callable callable = new ContextUtil.Callable() {
    public Object call(Context context) throws MatrixException {
        //just add the keys to the list for translations.  The javascript key will be the string after the last period.
        ArrayList<String> list = new ArrayList<String>(25);
        list.add("emxFramework.Widget.WidgetLabel");
        list.add("emxFramework.Widget.NoObjectsFound");
        list.add("emxFramework.Widget.AllObjectsFiltered");
        list.add("emxFramework.Widget.SortAscending");
        list.add("emxFramework.Widget.SortDescending");
        list.add("emxFramework.Widget.Apply");
        list.add("emxFramework.Widget.Cancel");
        list.add("emxFramework.Widget.Sorts");
        list.add("emxFramework.Widget.Loading");
        list.add("emxFramework.Widget.SortDirection");
        list.add("emxFramework.Widget.CollaborativeStorages");
        list.add("emxFramework.Widget.CollaborativeSpaces");
        list.add("emxFramework.Widget.Content");
        list.add("emxFramework.Widget.View.CHANNEL");
        list.add("emxFramework.Widget.View.LIST");
        list.add("emxFramework.Widget.View.CHART");
        list.add("emxFramework.Widget.View.TABLE");
        list.add("emxFramework.Widget.View.THUMBNAIL");
        list.add("emxFramework.Widget.Views");
        list.add("emxFramework.Widget.Rows");
        list.add("emxFramework.Widget.OptionsSelect");
        list.add("emxFramework.Widget.StorageSelect");
        list.add("emxFramework.Widget.SpaceSelect");
        list.add("emxFramework.Widget.NoPreferences");
        list.add("emxFramework.Widget.Error.WidgetNotFound");
        list.add("emxFramework.Widget.Error.WidgetNoAccess");
        list.add("emxFramework.Widget.Error.Unauthorized");
        list.add("emxFramework.Widget.Error.SystemError");
        list.add("emxFramework.Widget.Error.NetworkError");
        list.add("emxFramework.Widget.Error.WidgetUpdateError");
        list.add("emxFramework.ValidationError.CSRFError");
        list.add("emxFramework.Widget.Size");
        list.add("emxFramework.Widget.Small");
        list.add("emxFramework.Widget.Medium");
        list.add("emxFramework.Widget.Large");
        //toolbar text
        list.add("emxFramework.Widget.Toolbar.Preferences");
        list.add("emxFramework.Widget.Toolbar.Refresh");
        // Chart widget entries
        list.add("emxFramework.Widget.Chart.SUM");
        list.add("emxFramework.Widget.Chart.AVERAGE");
        list.add("emxFramework.Widget.Chart.MINIMUM");
        list.add("emxFramework.Widget.Chart.MAXIMUM");
        list.add("emxFramework.Widget.Chart.Items");
        //months to display on the calendar popup
        list.add("emxFramework.Calendar.January");
        list.add("emxFramework.Calendar.February");
        list.add("emxFramework.Calendar.March");
        list.add("emxFramework.Calendar.April");
        list.add("emxFramework.Calendar.May");
        list.add("emxFramework.Calendar.June");
        list.add("emxFramework.Calendar.July");
        list.add("emxFramework.Calendar.August");
        list.add("emxFramework.Calendar.September");
        list.add("emxFramework.Calendar.October");
        list.add("emxFramework.Calendar.November");
        list.add("emxFramework.Calendar.December");
        list.add("emxFramework.Calendar.Jan");
        list.add("emxFramework.Calendar.Feb");
        list.add("emxFramework.Calendar.Mar");
        list.add("emxFramework.Calendar.Apr");
        list.add("emxFramework.Calendar.May");
        list.add("emxFramework.Calendar.Jun");
        list.add("emxFramework.Calendar.Jul");
        list.add("emxFramework.Calendar.Aug");
        list.add("emxFramework.Calendar.Sep");
        list.add("emxFramework.Calendar.Oct");
        list.add("emxFramework.Calendar.Nov");
        list.add("emxFramework.Calendar.Dec");
        list.add("emxFramework.Calendar.Sunday");
        list.add("emxFramework.Calendar.Monday");
        list.add("emxFramework.Calendar.Tuesday");
        list.add("emxFramework.Calendar.Wednesday");
        list.add("emxFramework.Calendar.Thursday");
        list.add("emxFramework.Calendar.Friday");
        list.add("emxFramework.Calendar.Saturday");
        list.add("emxFramework.Calendar.Sun");
        list.add("emxFramework.Calendar.Mon");
        list.add("emxFramework.Calendar.Tue");
        list.add("emxFramework.Calendar.Wed");
        list.add("emxFramework.Calendar.Thu");
        list.add("emxFramework.Calendar.Fri");
        list.add("emxFramework.Calendar.Sat");
        list.add("emxFramework.Calendar.Month");
        list.add("emxFramework.Calendar.Day");
        list.add("emxFramework.Calendar.Year");
        list.add("emxFramework.Calendar.Week");

        String language = requestObj.getHeader("Accept-Language");
        if(language == null) {
            language = "en-us";
        }
        Map<String, String> translations = EnoviaResourceBundle.getProperties(context, "Framework", list, language);
        return translations;
    }
};

Map<String, String> translations = null;
try {
    translations = (Map<String, String>) ContextUtil.runInAnonymousContext(callable);
} catch(Exception e) {
    translations = new HashMap<String, String>(0);
    e.printStackTrace();
}

Set keys = translations.keySet();
Iterator<String> itr = keys.iterator();

StringBuffer sBuff = new StringBuffer(1000);
sBuff.append("bpsWidgetConstants = {\n");  //making constants as global.
sBuff.append("str: {\n");

while(itr.hasNext()) {
    String key = itr.next();
    String value = translations.get(key);
    key = key.substring(key.lastIndexOf('.') + 1);
    sBuff.append(key + ": \"" + value + "\",\n");
}

sBuff.append("total: " + translations.size());
sBuff.append(", language: \"" + request.getHeader("Accept-Language") + "\"");
sBuff.append("}\n");
sBuff.append("};");
String widgetConst = sBuff.toString();
%>
