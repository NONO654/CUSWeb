
<%@ page import="com.dassault_systemes.vplmposadminservices.NLSCatalog" %>
<%@ page import="com.dassault_systemes.vplmposadminservices.DefaultCatalogHandler" %>
<%@ page import="com.dassault_systemes.vplmposadminservices.HtmlCatalogHandler" %>
<%@ page import="com.dassault_systemes.vplmposadminservices.ICatalogHandler" %>
<%@ page import="com.dassault_systemes.plmsecurity.util.Logger" %>
<%@ page import="com.matrixone.jsystem.util.Sys" %>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.MissingResourceException"%>
<%@ page import="java.util.Locale" %>

<%!
    private HashMap            _i18_map    = new HashMap();
    private NLSCatalog         myNLS       = null;
    private ICatalogHandler    myNLSHdlr   = new DefaultCatalogHandler();
    private static Logger _trace      = null;
    private static boolean     _bDebug     = false;
    private static boolean     _bDebugNLS  = false;

    // ---------------------------------------------------------------------
    // initializes NLS catalog of formatted messages
    // ---------------------------------------------------------------------
    public void initNLSCatalog(String name, HttpServletRequest request)
    {
        // check if catalog is already stored on session
        Locale locale = request.getLocale();
        if (locale==null) locale = Locale.getDefault();
        String sLocale = (locale==null) ? "" : locale.getLanguage();
        String keySession = "NLS."+sLocale+"."+name;
        HttpSession reqSession = request.getSession();
        myNLS = (NLSCatalog)reqSession.getAttribute(keySession);
        if (myNLS == null) {
            myNLS = new NLSCatalog(name, locale);
            String sDebugNLS = Sys.getEnvEx("CATNlsTest");
            if (sDebugNLS!=null && sDebugNLS.length()>0) {
                _bDebugNLS = true;
                if (_bDebug) dbg("initNLSCatalog("+name+",locale="+sLocale+") [new] (CATNlsTest mode)");
                myNLS.setCatalogHandler(new HtmlCatalogHandler());
            }
            else {
                if (_bDebug) dbg("initNLSCatalog("+name+",locale="+sLocale+") [new]");
            }
            reqSession.setAttribute(keySession, myNLS);
        }
        else {
            if (_bDebug) dbg("initNLSCatalog("+name+",locale="+sLocale+") [already set]");
        }
    }

    // ---------------------------------------------------------------------
    // get NLS catalog
    // ---------------------------------------------------------------------
    public NLSCatalog getNLSCatalog()
    {
        return myNLS;
    }

    //----------------------------------------------------------------------
	// method to get NLS labels
    //----------------------------------------------------------------------
	public String getNLSOrDefault(String tag, String default_value)
	{
        String value = default_value;
        if (myNLS != null) {
            // look in cache
            String key = getNLSKey(tag);
            if (_i18_map.containsKey(key)) return (String)_i18_map.get(key);
            // not found : look in catalog (if any)
            try {
                value = myNLS.getMessageEx(tag);
            }
            catch (MissingResourceException ex) {}
            // add to cache
            _i18_map.put(key,value);
        }
        return value;
    }

    //----------------------------------------------------------------------
	// method to get NLS labels with some parameters
    //----------------------------------------------------------------------
    public String getNLSWithParameters(String tag, String[] parameters)
    {
        // NOTE: do not check/manage cache here, because the message
        // is not constant (it depends on parameters)
        String value = tag;
        if (myNLS != null) {
            try {
                value = myNLS.getMessage(tag,parameters);
            }
            catch (MissingResourceException ex) {}
        }
        return value;
    }

    //----------------------------------------------------------------------
	// method to get NLS labels
    //----------------------------------------------------------------------
	public String getNLS(String tag)
	{
        return getNLSOrDefault(tag,tag);
    }

    //----------------------------------------------------------------------
	// method to get NLS labels in a safe way (no HTML handler)
    //----------------------------------------------------------------------
	public String getSafeNLS(String tag)
	{
        if (myNLS==null) return tag;
        ICatalogHandler hdr = myNLS.getCatalogHandler();
        myNLS.setCatalogHandler(myNLSHdlr);
        String result = _bDebugNLS ? tag+"="+getNLSOrDefault(tag,tag) : getNLSOrDefault(tag,tag);
        myNLS.setCatalogHandler(hdr);
        return result;
    }

    //----------------------------------------------------------------------
	// get NLS key in cache
    //----------------------------------------------------------------------
    private String getNLSKey(String tag) {
        String sLocale = "";
        if (myNLS != null) {
            Locale locale = myNLS.getLocale();
            if (locale!=null) sLocale = locale.getLanguage();
        }
        return sLocale+"/"+tag;
    }

    //----------------------------------------------------------------------
	// debug methods
    //----------------------------------------------------------------------
    public void initTrace(String name)
    {
        if (_trace==null) {
            _trace = Logger.getLogger(name);
            _bDebug = _trace.isTracing(1);
        }
    }
    public void traceIn(String entry_msg)
    {
		if (_bDebug)
		{
			_trace.traceText(entry_msg);
			_trace.traceText("{");
			_trace.traceIndent();
		}
    }
    public void traceOut()
    {
		if (_bDebug)
		{
            _trace.traceUnindent();
			_trace.traceText("}");
		}
    }
    public boolean dbgActive()
    {
        return _bDebug;
    }
    public boolean dbgActive(int level)
    {
        return _trace.isTracing(level);
    }
    public void dbg(String message)
    {
        if (_bDebug && _trace!=null) _trace.traceText(message);
    }

%>
