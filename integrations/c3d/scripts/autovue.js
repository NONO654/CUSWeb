/** AutoVue JavaScript API */

/** Support For old browsers */
Number.isInteger = Number.isInteger || function(value){
    return typeof value === "number" && isFinite(value) &&  Math.floor(value) === value;
};

/** AutoVue Object */
function AutoVue(JNLP_HOST, CODEBASE_HOST, CLIENT_PORTS, INIT_PARAMS, ENCRYPT_COOKIES, VERBOSITY, STARTUP_DELAY){
    // Event Types: Bitflags used for filtering in the API setEventListener
    this.EVENTFILTER_FILE   = 0x01;
    this.EVENTFILTER_MARKUP = 0x02;
    this.EVENTFILTER_PRINT  = 0x10;

    this.EVENTFILTER_ALL    = this.EVENTFILTER_FILE  | this.EVENTFILTER_MARKUP | this.EVENTFILTER_PRINT;

    // Rendez-Vous Request Formats
    AutoVue.RDVFORMAT_JSON     = 'application/json';
    AutoVue.RDVFORMAT_URLFORM  = 'application/x-www-form-urlencoded';


    // JNLP Servlet Host
    if( JNLP_HOST != null ){
        this.JNLP_HOST = JNLP_HOST;        
    }

    // Codebase Host: Location of AutoVue Client JARS (jVue.jar, jsonrpc4j.jar, jogl.jar, gluegen_rt.jar)
    if( CODEBASE_HOST != null ){
        this.CODEBASE_HOST = CODEBASE_HOST;        
    }

    // Rendez-Vous Host
    this.RDV_FORMAT = AutoVue.RDVFORMAT_JSON;
    this.RDV_HOST = null;
    if( INIT_PARAMS != null ){
        if( INIT_PARAMS['RDVFORMAT'] != null ){
            this.RDV_FORMAT = INIT_PARAMS['RDVFORMAT'];
        }
        if( INIT_PARAMS['RDVSERVLET'] != null ){
            this.RDV_HOST = INIT_PARAMS['RDVSERVLET'];
            if( document.location.protocol.toUpperCase() == 'HTTPS:'){
                // Always use Rendez-Vous approach in SSL mode when a Rendez-Vous servlet
                // is provided. It prevents the need to import a localhost certificate.
                this.CLIENT_PORTS = CLIENT_PORTS = null;
            }
        }
    }

    // Port used for communication between browser and AutoVue Client (loopback connection) 
    this.CLIENT_PORTS = null;
    if( CLIENT_PORTS != null ){
        storePorts(this, CLIENT_PORTS);
        if( document.location.protocol.toUpperCase() == 'HTTP:'){
            // Always use loopback connection in clear mode when localhost ports are provided.
            // It allows sending encrypted cookies and decrypting them by Autovue.
            this.RDV_HOST = null;
        }
    }
    if( this.RDV_HOST == null ){
        // Set the request format to JSON in the loopback connection because it is the only one supported by the AV-embedded JSON_RPC server
        this.RDV_FORMAT = 0;
    }

    // AutoVue Client Parameters (Initialization Parameters)
    this.INIT_PARAMS = null;
    if( INIT_PARAMS != null ){
        this.INIT_PARAMS = JSON.parse(JSON.stringify(INIT_PARAMS));    // Portable Clone
    }

    // Verbosity Mode:  0: None 
    //                  1: Browser Console 
    //                  2: JavaScript alert popup
    //                  3: Both Browser Console and JavaScript alert popup
    this.VERBOSITY = 1;
    if( VERBOSITY != null ){
        this.VERBOSITY = VERBOSITY;
    }

    // Security setup: Should we encrypt the cookies passed in the JNLP File
    this.ENCRYPT_COOKIES = true;
    if( this.RDV_HOST != null ){
        // Never encrypt the cookies under the Rendez-Vous communication 
        // protocol since we cannot safely transmit the decryption key
        if( ENCRYPT_COOKIES == true ){
            var error = 'Cookies encryption is not supported under the "Rendez-Vous" communication protocol. Disabe cookies '
                      + 'encryption or use the loopback connection protocol. Review AutoVue documentation for more details.';
            errMsg(this, error);
            throw error;
        }
        ENCRYPT_COOKIES = false;
    }
    if( ENCRYPT_COOKIES != null ){
        this.ENCRYPT_COOKIES = ENCRYPT_COOKIES;        
    }

    // Delay required before assuming AutoVue startup failure
    this.STARTUP_DELAY = 30; // Seconds
    if( STARTUP_DELAY != null ){
        this.STARTUP_DELAY = STARTUP_DELAY;
    }

    /**
     * Start AutoVue Client
     * @param onInit    JavaScript Callback to call when AutoVue finished starting and is ready for scripting
     * @param onFail    JavaScript Callback to call if AutoVue failed to start-up. An example that notifies the server 
     *                  administrator by e-mail is provided in av_jnlp.html
     * @param user_data User Data to retrieve within failure notification if the browser fails to communicate with AutoVue
     */
    this.start = function(onInit, onFail, user_data){
        var av = this;
        if( av.script_connection == null ){
            launch(av, onInit, onFail, user_data);
        } else {    // The instance has already a connection
            // Check whether AutoVue is already running and restart
            // it if not, starting with the port previously selected
            av.portsDone = true;
            reorderPorts(av);
            initScriptService(av, onInit, function(){launch(av, onInit, onFail, user_data)});
        }
    }

    /**
     * Switch the document to a given page on the target frame
     * @param page    Index of the page to set (Number, 1-based)
     * @param frameID User identifier of the target frame
     */
    this.setPage = function(page, frameID){
        processScriptMethod(this, 'setPage', [page, frameID]);
    }

    /**
     * Open a file in AutoVue on the target frame
     * @param file    URL of the file to load
     * @param frameID User identifier of the target frame
     */
    this.setFile = function(file, frameID){
        processScriptMethod(this, 'setFile', [file, frameID]);
    }

    /**
     * Customize AutoVue User Interface  on the target frame, by providing a UI configuration file
     * @param guiFile   Local path of the UI configuration file to set (file://<path>)
     * @param frameID   User identifier of the target frame
     */
    this.setGUI = function(guiFile, frameID){
        processScriptMethod(this, 'setGUI', [guiFile, frameID]);
    }

    /**
     * Open a Markup on the target frame
     * @param markup    Optional. Semicolon (;) separated key-value list (name1=value1;name2=value2) holding
     *                  the markup attributes. If not provided, AutoVue will simply start a new empty markup
     * @param frameID   User identifier of the target frame
     */
    this.openMarkup = function(markup, frameID){
        if( markup == null ){
            markup = ' ';
        }
this.inc=1;
this.setPage(2, frameID);
this.setPage(1, frameID);
this.setPage(2, frameID);
this.inc=-3;
        processScriptMethod(this, 'openMarkup', [markup, frameID]);
this.inc=0;
    }

    /**
     * Save the active markup with the given property, on the target frame
     * @param markup    Optional. Semicolon (;) separated key-value list
     *                  (name1=value1;name2=value2) holding the markup attributes.
     * @param frameID   User identifier of the target frame
     */
    this.saveActiveMarkup = function(markup, frameID){
       processScriptMethod(this, 'saveActiveMarkup', [markup, frameID]);
    }

    /**
     * Prompt the user to save the markups modified  on the target frame
     * since last save operation if any change on them occurred since 
     * then, otherwise; this function will do nothing.
     * @param mayCancel Whether user will be given the option to cancel
     * @param frameID   User identifier of the target frame
     */
    this.saveModifiedMarkups = function(mayCancel, frameID){
        if( mayCancel == null){
            mayCancel = true;
        }
        processScriptMethod(this, 'saveModifiedMarkups', [mayCancel, frameID]);
    }

    /**
     * Check whether there are modified markups to save.
     * @param frameID   User identifier of the target frame
     * @return Whether there are modified markups to save
     * @throw An error if called asynchronously. It is supported
     *        only in synchronous mode, under loopback protocol
     */
    this.checkModifiedMarkups = function(frameID){
        var bModified = null;
        processScriptMethod(this, 'checkModifiedMarkups', [frameID], function(ret){ bModified = ret }, false);
        if( bModified == null ){
            throw 'checkModifiedMarkups is not supported asynchronousely. Must switch to loopback protocol and synchronous mode to use this API';
        }
            return bModified;
        }

    /**
     * Load a file in compare mode to compare with the current file on the target frame
     * @param file      URL of the file to compare with
     * @param frameID   User identifier of the target frame
     */
    this.setCompareFile = function(file, frameID){
        processScriptMethod(this, 'setCompareFile', [file, frameID]);
    }

    /**
     * Print the document with the given printing options, on the target frame
     * @param printOptions JavaScript object. The object is expected to have the attributes below:
     *        printer           Name of the printer to output to (No default defined)
     *        forceToBlack      Whether to apply "Force to Black" rendering in the print out (Default: false)
     *        pages             Sub-object holding information about the pages to print. It holds the attributes below:
     *            choice        0: All, 1: Current, 2: Range (Default: 1-Current)
     *            from          First page to print (Default: 1). Used only when printOptions.pages.choice = 2 (Range)
     *            to            Last page to print (Default: 1). Used only when printOptions.pages.choice = 2 (Range)
     *        scale             Sub-object holding information about the paper to use. It holds the attributes below:
     *            value         Scaling type, value could be "FIT", a string "<percentage>%" indicates a scale or a
     *                          string "<factor>" indicates scaling to a factor (Default: "FIT")
     *            units         Scaling Units (1: in, 2: mm)
     *        paper             Sub-object holding information about the paper to use. It holds the attributes below:
     *            choice        See AutoVue Documentation about supported paper sizes in PrintProperties class (Default: 1-Letter)
     *            orientation   0: Portrait, 1: Landscape, 2: Auto (Default: 0-Portrait)
     *        margins           Sub-object holding information about the margins to set. It holds the attributes below:
     *            top           float (Default 0.25)
     *            bottom        float (Default 0.21)
     *            left          float (Default 0.25)
     *            right         float (Default 0.25)
     *            units         Units in which the margin values above are given (1: in, 2: mm)
     *        headers           Sub-object holding additional information about the headers to add to the output. It holds the attributes below:
     *            lh            Left header text
     *            ch            Center header text
     *            rh            Right header text
     *            lf            Left footer text
     *            cf            Center footer text
     *            rf            Right footer text
     *        pen_settings      Sub-object holding pen settings to apply in the print operation
     *            pens          JSon object holding the list of pens and their respective thicknesses settings where the fields are
     *                          the names of the pens and the values are the pen thicknesses settings {pen1:value1,pen2:value2,...}.
     *                          The values are themselves JSon objects where the fiedls are the color indices and the values are the
     *                          associated thicknesses to apply during the print operation {color1:thickness1, color2:thickness2,...}.
     *                          The color indices are integers between and 0 and 255.
     *                          E.g.: pens['myPen1']['2'] = 0.1; pens['myPen1']['3'] = 0.2; pens['myPen1']['7'] = 0.3;
     *                                pens['myPen2']['1'] = 0.1; pens['myPen3']['6'] = 0.2; pens['myPen3']['7'] = 0.1;
     *                                pens['myPen3']['3'] = 0.2; pens['myPen2']['4'] = 0.3;
     *            selected      name of the selected pen. E.g.:  pens['selected'] = 'myPen2'
     * @param useDefaultPrinter Boolean. Whether to use directly the print settings for the required printing operation or to let user updating them.
     * @param frameID User identifier of the target frame
     * @Note  printOptions are first initialized from INI file, then overwritten by the following options
     */
    this.printFile = function(printOptions, useDefaultPrinter, frameID){
        if( useDefaultPrinter == null ){
            useDefaultPrinter = true;
        }
        processScriptMethod(this, 'printFile', [printOptions, useDefaultPrinter, frameID]);
    }

    /**
     * Print a list of files on the target frame
     * @param fileList          List of URLs of the files to print provided into a JavaScript array
     * @param printOptions      Printing options to apply during the printing operation (Same structure as printFile).
     * @param openAllMarkups    Boolean. Whether to include all associated markups during the printing operation.
     * @param useDefaultPrinter Boolean. Whether to use directly the print settings for the required printing operation or to let user updating them.
     * @param frameID           User identifier of the target frame
     */
    this.batchPrint = function(fileList, printOptions, openAllMarkups, useDefaultPrinter, frameID){
        processScriptMethod(this, 'batchPrint', [fileList, printOptions, openAllMarkups, useDefaultPrinter, frameID]);
    }

    /**
     * Convert the file based on given Convert Options, on the target frame
     * @param convertOptions JavaScript object. The object is expected to have the attributes below:
     *        file              *Mandatory. Sub-object holding information about the conversion file.
     *                          It holds the attributes below:
     *            format        'PCRS_BMP' or 'PCRS_TIF' or 'PCVC_PDF'
     *            subFormat:    Format flavour: Specific to Tif (Currently ignored for the others)
     *                          PCRS_TIF => 0: Uncompressed, 1: PackBits, 2: Fax III, 3: Fax IV)
     *            filePath      Path of the destination file
     *        pages             Sub-object holding information about the pages to convert. Used in
     *                          multi-page formats (PCRS_TIF, PCVC_PDF). It holds the attributes below:
     *            choice        0: All, 1: Range, 2: Current
     *            from          First page to convert. used only when printOptions.pages.choice = 1 (Range)
     *            to            Last page to convert. used only when printOptions.pages.choice = 1 (Range)
     *        output            Sub-object holding information about conversion output settings:
     *            colorDepth    Color depth
     *            fgColor       Foreground color (in windows RGB)
     *            stepsPerInch  Steps per inch value. For rasters this will contain DPI value
     * @param frameID User identifier of the target frame
     */
    this.convertFile = function(convertOptions, frameID){
        processScriptMethod(this, 'convertFile', [convertOptions, frameID]);
    }

    /**
     * Load an EDA file in cross-probe mode to cross-probe
     * with the current EDA file, on the target frame
     * @param file    URL of the file to cross-probe
     * @param frameID User identifier of the target frame
     */
    this.crossProbe = function(file, frameID){
        processScriptMethod(this, 'crossProbe', [file, frameID]);
    }

    /**
     * Import a 3D file in the current 3D model (DMU), on the target frame
     * @param file	URL of the 3D file to import
     * @param transform 4x4 transformation matrix (HMatrix). The API expects 4-size JavaScript array containing
     *                  the rows of the matrix. So each entry is expected to be 4-size array of floats
     * @param frameID   User identifier of the target frame
     */
    this.import3DFile = function(file, transform, frameID){
        processScriptMethod(this, 'import3DFile', [file, transform, frameID]);
    }

    /**
     * Overlay a file onto the current one (2D) on the target frame
     * @param file    URL of the file to overlay
     * @param frameID User identifier of the target frame
     */
    this.addOverlay = function(file, frameID){
        processScriptMethod(this, 'addOverlay', [file, frameID]);
    }

    /**
     * Invoke a VueAction  on the target frame
     * (E.g.: VueActionOptionsConfiguration will trigger AutoVue Configuration dialog)
     * @param actionClassStr    VueAction string name
     * @param frameID           User identifier of the target frame
     */
    this.invokeAction = function(actionClassStr, frameID){
        processScriptMethod(this, 'invokeAction', [actionClassStr, frameID]);
    }

    /**
     * Close the current document on the target frame
     * @param frameID User identifier of the target frame
     */
    this.closeDocument = function(frameID){
        processScriptMethod(this, 'closeDocument', [frameID]);
    }

    /** Close AutoVue Client */
    this.closeAutoVue = function(){
        processScriptMethod(this, 'closeAutoVue');

        // Update the state of AutoVue object to reflect the closure of AutoVue client
        this.script_connection = null;
    }

    /**
     * Set the method to call with script execution status progress, on the target frame
     * @param listener  Name of a JavaScript method to call each time a script
     *                  command gets executed. The method takes 3 parameters
     *                  that indicate the Script command  completed, its results
     *                  and the number of commands still pending.
     *                  If set to <code>null</code>, status notifications are
     *                  disabled (this the default)
     * @param caller    Caller's Window Object (window) needed to callback
     * @param frameID   User identifier of the target frame
     *
    this.setStatusListener = function(listener, frameID, caller){
        getNextEvents(this, caller);
        processScriptMethod(this, 'setStatusListener', [listener, frameID]);
    } Working but Disabled */

    /**
     * Enable event notifications by registering a listener to AutoVue frame events.
     * @param listener  Name of a JavaScript method to call each time an event is
     *                  fired and caught by Autovue Frame. The callback should have
     *                  the following signature: function onEvent(type, event), where:
     *                  type: 	Type of the event (Model, View, Markup...)
     *                  event: 	JavaScript Object wrapping the event information
     *                  If set to <code>null</code>, event notifications are
     *                  disabled (this the default)
     * @param caller    Caller's Window Object (window) needed to callback
     * @param filter    Bit-Flags to specify which events to listen to
     */
    this.setEventListener = function(listener, filter, caller){
        if( filter == null ){
            filter = this.EVENTFILTER_ALL
        }
        if( (filter & this.EVENTFILTER_ALL) != filter ){
            filter &= this.EVENTFILTER_ALL;
            errMsg(this, 'Event filter will be trimmed to the supported part: ' + filter);
        }
        getNextEvents(this, caller);
        processScriptMethod(this, 'setEventListener', [listener, filter]);
    }

    /**
     * Set the hotspot handler for the given hotspot definition, on the target frame
     * This method should typically be called before the file session. It will
     * initialize the hotspots in the file of AutoVue based on external application data
     * @param definitionType  Hotspot definition type (Native WebCGM, Text Search, Attribute search...)
     * @param definitionKey   Hotspot definition key string, used to refer to this definition later
     * @param definition      Semicolon (";") separated key-value string specifying hotspot definition
     *                        parameters (name1 = value1; name2 = value2).
     * @param caller          Caller's Window Object (window) needed to callback
     * @param frameID         User identifier of the target frame
     */
    this.setHotSpotHandler = function(definitionType, definitionKey, definition, frameID, caller){
        getNextEvents(this, caller);
        processScriptMethod(this, 'setHotSpotHandler', [definitionType, definitionKey, definition, frameID]);
    }

    /**
     * Perform a hotspot action on the given hotspot, on the target frame
     * This method should only be called during the file session when the hotspots
     * have been already initialized.
     * @param definitionKey Hotspot definition key string provided by the integrator at creation.
     * @param hotspotKey    Hotspot property key string identifying it, to interpret based on the
     *                      definition key.
     * @param action        Action to perform on the hotspot
     * @param params        Semicolon (";") separated key-value string specifying hotspot action
     *                      parameters (name1 = value1; name2 = value2).
     * @param frameID       User identifier of the target frame
     */
    this.performHotSpot = function(definitionKey, hotspotKey, action, params, frameID){
        processScriptMethod(this, 'performHotSpot', [definitionKey, hotspotKey, action, params, frameID]);
    }

    /**
     * Get the requested info on the target frame
     * @param info      Identifies the requested info. The cases currently supported are:
     *                  - "Custom Properties"
     * @param callback  Callback to invoke asynchronously when the requested info is ready
     * @param caller    Caller's Window Object (window) needed to callback
     * @param frameID   User identifier of the target frame
     */
    this.getInfo = function(info, frameID, callback, caller){
        getNextEvents(this, caller);
        processScriptMethod(this, 'getInfo', [info, callback, frameID]);
    }

    /**
     * Initiates a collaboration session on the target frame
     * @param session Property string describing collaboration session in following format:
     *                  CSI_ClbSessionID=987654321;CSI_ClbDMS=dmsIndex;CSI_ClbSessionData=123456789;
     *                  CSI_ClbSessionSubject=Subject;CSI_ClbSessionType=public|private;CSI_ClbUsers=user1,user2,x;
     * @param frameID User identifier of the target frame
     */
    this.collaborationInit = function(session, frameID){
        processScriptMethod(this, 'collaborationInit', [session, frameID]);
    }

    /**
     * Join a collaboration session on the target frame
     * @param session Property string describing collaboration session in following format:
     *                  CSI_ClbSessionID=987654321;CSI_ClbDMS=dmsIndex;CSI_ClbSessionData=123456789;
     * @param frameID User identifier of the target frame
     */
    this.collaborationJoin = function(session, frameID){
        processScriptMethod(this, 'collaborationJoin', [session, frameID]);
    }

    /** Wait for last method called on the target frame in AutoVue to finish *
    this.waitForLastMethod = function(callback, frameID){
        return processScriptMethod(this, 'waitForLastMethod', [frameID], callback, true);
    } Working but Disabled */

    /** 
     * Set Encryption key pair.
     * If both keys are not provided, they will be hard-coded to Oracle default ones
     * @param public_key Encryption Public Key
     */
    this.setEncryptionKeyPair = function(public_key, private_key){
        // Hard-code the Encryption key-pair if not provided
        if( public_key == null || private_key == null ){
            errMsg(this, 'Failed to set encryption keys: Need to provide both RSA public and private keys');
        }

        // Encode the keys using Base64
        this.public_key  = public_key;
        this.private_key = private_key;
    }

    /**
     * Connect to an AutoVue Client already running
     * @param onInit    JavaScript Callback to call when AutoVue finished starting and is ready for scripting
     * @param onFail    JavaScript Callback to call if AutoVue failed to start-up. An example that notifies the server 
     *                  administrator by e-mail is provided in av_jnlp.html
     * @param user_data User Data to retrieve within failure notification if the browser fails to communicate with AutoVue
     */
    this.connect = function(onInit, onFail, user_data){
        var av = this;
        av.portsDone = false;
        if( onFail == null ){
            onFail = function(http, error_msg){
                errMsg(av, 'Failed to connect to AutoVue. Status: ' + http.status + ' (' + error_msg + ')');
            };
        }
        initScriptService(av, onInit, function(http, error_msg){
                            errMsg(av, 'Failed to connect to AutoVue. Status: ' + http.status + ' (' + error_msg + ')');
                            if( onFail != null){
                                onFail(http, error_msg, user_data);
                            }
                          });
    }

    /*************************** Helper  Functions ***************************/
    /*************************************************************************/

    /** Launch Autovue from scratch */
    function launch(av, onInit, onFail, user_data){
        if( av.starting == true && av.ticket != null ){
            av.startProcessing = null;
            av.currentCommandID = null;
            alert('Please wait for AutoVue to load');
            return;
        }
        if( onFail == null ){
            onFail = function(http, message){
                errMsg(av, message);
            };
        }

        // Ensure that the URL of VueJNLPServlet and Codebase are initialized
        if( av.JNLP_HOST == null ){
            onFail(null,'Failed to start AutoVue Client because the URL of the JNLP file generator (JNLP_HOST) is not set');
            return;
        }
        if( av.CODEBASE_HOST == null ){
            onFail(null, 'Failed to start AutoVue Client because the URL of the client codebase (CODEBASE_HOST) is not set');
            return;
        }

        // JNLP Servlet Parameters
        var avParams = '?CodebaseHost=' + av.CODEBASE_HOST;

        // Startup Parameters required to start AutoVue Client
        av.ticket = '' + Math.random();
        if( Array.isArray(av.CLIENT_PORTS) && av.CLIENT_PORTS.length > 0 ){
            avParams += '&TICKET=' + av.ticket + '&JSONRPC_PORT=' + buildPortArg(av.CLIENT_PORTS);
            av.sequential_id = null;    // Sequential commands mode not implemented by AutoVue embedded JSON-PRC server
        } else if( av.RDV_HOST != null ){
            avParams += '&TICKET=' + av.ticket + '&RDVSERVLET=' + av.RDV_HOST;
            av.sequential_id = 1;   // Used as identifier of the commands sent to the Rendez-Vous servlet

            // Session authentication (Need to create a session if there is none)
            av.isPinging = false;
            var res = initRDVSession(av);
            if( res == null ){
                console.log('"Rendez-Vous" Session initialized');
            } else {
                onFail(null, res);
                return;
            }
        } else {
            // No ports and no Rendez-Vous host provided. Cannot communicate with
            // Autovue. Start it in standalone mode without scripting capability
            av.ticket = null;
        }

        // Setup Encryption if requested
        if( av.ENCRYPT_COOKIES == true ){
            if( av.private_key == null ){
                errMsg(av, 'Cookies encryption requested but private encryption key not set.'
                         + 'AutoVue will not be able to decrypt the cookies');
            } else {
                if( av.INIT_PARAMS == null ){
                    av.INIT_PARAMS = {};
                }
                av.INIT_PARAMS['EncryptionKey'] = serializeKey(av.private_key);
            }

            // When encryption is requested, make sure to ALWAYS send a key, even if it is empty.
            // Otherwise, servlet code does not know whether it should send the cookies or not.
            avParams += '&EncryptionKey=';
            if( av.public_key != null ){
                // Base 64 uses codes that need to be escaped with url encode.
                // So, don't use it for public key (passed in servlet URL)
                avParams += serializeKey(av.public_key);
            } else {
                errMsg(av, 'Encryption requested but Public Encryption Key not set. Cookies cannot be sent to AutoVue')
            }
        }

        // Call Java Web Start with jnlp file generated dynamically by VueJNLPServlet
        av.starting  = true;
        av.bLongPooling = false;
        console.log('connecting to: ' + av.JNLP_HOST + encodeURI(avParams))
        var jnlp = window.open(av.JNLP_HOST + encodeURI(avParams));
        if( jnlp == null || typeof(jnlp) == 'undefined' || jnlp.closed || typeof(jnlp.closed) == 'undefined' ){
            alert('Your browser popup blocker prevented AutoVue to start. Need to disable it, at least for the site ' + av.JNLP_HOST);
        }

        // Intialize the connection to AutoVue Script Service when possible
        if( av.ticket == null ){
            // Inform the HTML client that AutoVue started in standalone mode
            onFail(null, 'Neither a Rendez-Vous host nor valid localhost port ranges provided. '
                       + 'Starting AutoVue in standalone mode without scripting capability');
        } else {
            av.connect_start = new Date().getTime();
            av.connect(onInit, onFail, user_data);
        }
    }

    /** Rendez-Vous Session Authentication: Create a session if there is none */
    function initRDVSession(av){
        var http = new XMLHttpRequest();
        http.open('POST', av.RDV_HOST + '?RequestType=INIT_SESSION', false);
        http.setRequestHeader('Content-type', AutoVue.RDVFORMAT_URLFORM);
        http.overrideMimeType(AutoVue.RDVFORMAT_URLFORM);
        try {
            http.send();
        } catch( error ){
            return 'Failed to communicate with the "Rendez-Vous" servlet: ' +  error.message;
        }

        if( http.status == 200 ){
            // Success
            return null;
        }
        return 'Failed to initialize a "Rendez-Vous" session. Request to the "Rendez-Vous" '
             + 'servlet (' + av.RDV_HOST + ') returned with status: "' + http.status;
    }

    /** Connect to AutoVue Client and initialize it's Scripting Service */
    function initScriptService(av, onInit, onFail, iPort, id){
        // Start with the first given port if any otherwise nothing to do
        if( Array.isArray(av.CLIENT_PORTS) && av.CLIENT_PORTS.length > 0 ){
            if( iPort == null ){
                iPort = 0;
            }
            // Send the scripting commands directly to Autovue client through localhost socket ("Direct" Approach)
            av.script_connection = document.location.protocol + '//localhost:' + getPort(av, iPort);
        } else if( av.RDV_HOST != null ){
            // Send the scripting commands to a Rendez-Vous server ("Rendez-Vous" Approach)
            av.script_connection = av.RDV_HOST + '?Ticket=' + av.ticket + '&RequestType=SCRIPT';
            av.iPort = null;
        } else {
            onFail(null, 'Cannot connect to AutoVue. Neither localhost port ranges nor Rendez-Vous host provided');
            return;
        }

        // Send an XML http request (init) to AutoVue and verify whether AutoVue Script Service is running
        var http = new XMLHttpRequest();
        http.onreadystatechange = function() {
            if( http.readyState == XMLHttpRequest.DONE ){
                if( http.status == 200 && http.responseText != null && http.responseText.indexOf('{"jsonrpc":"2.0"') == 0 ){
                    // Success code with a valid response message. Must be AutoVue response
                    if( iPort == null ){
                        console.log('Established "Rendez-Vous" communication with AutoVue Client');
                    } else {
                        av.iPort = iPort;
                        console.log('Established connection with AutoVue Client on port: ' + getPort(av, iPort));
                    }
                    av.starting = false;
                    // Notify the success callback
                    if( onInit != null ){
                        onInit();
                    }
                } else {
                    if( iPort != null ){    // Never reset the connection in the Rendez-Vous communication case
                        av.script_connection = null;
                    }

                    // What could have gone wrong?
                    var error = null;
                    switch( http.status ){
                    case 0:
                        if( iPort == null ){
                            // Rendez-Vous servlet is down
                            error = 'Cannot communicate with the "Rendez-Vous" servlet';
                            break;
                        } else if( new Date().getTime() - av.connect_start < 1000*av.STARTUP_DELAY ){
                            // Startup Delay not expired: Wait 1s and try again (Maybe Autovue is not ready yet)
                            setTimeout(function(){initScriptService(av, onInit, onFail)}, 1000);
                        } else {
                            // Loopback connection Approach. Move to the next port
                            connectOnAlternativePort(av, onInit, onFail, iPort, http)
                        }
                        return;
                    case 200:   // Success with an unexpected response: Another server responding (Not AutoVue)
                        if( iPort != null ){
                            // Move to the next port
                            console.log('Some server is using port ' + getPort(av, iPort) + ', skipping it');
                            connectOnAlternativePort(av, onInit, onFail, iPort, http)
                            return;
                        } else {
                            error = 'Unexpected request response. Could be caused by "Rendez-Vous" URL conflict.\n'
                                  + 'The "Rendez-Vous"  servlet response is not expected: ' + http.responseText;
                        }
                        break;
                    case 202:
                        // Rendez-Vous communication case: Wait a bit and ping again the server
                        setTimeout(function(){initScriptService(av, onInit, onFail, iPort, id)}, 500);
                        return;
                    case 409: // Conflict: Used by JSON-SRV servlet to indicate Session Authentication Failure
                        if( iPort != null ){
                            // AutoVue Wrong Ticket: Move to the next port
                            console.log('Another AutoVue instance is using port ' + getPort(av, iPort) + ', skipping it');
                            connectOnAlternativePort(av, onInit, onFail, iPort, http);
                            return;
                        }
                        break;
                    case 503:   // Service Unavailable: Used by the Rendez-Vous servlet to indicate that AutoVue is not running
                        if( iPort == null ){
                            if( new Date().getTime() - av.connect_start < 1000*av.STARTUP_DELAY ){
                                // Startup Delay not expired: Wait 1s and try again (Maybe Autovue is not ready yet)
                                setTimeout(function(){initScriptService(av, onInit, onFail, iPort, id)}, 1000);
                                return;
                            } else {
                                // Rendez-Vous Approach: Failed to communicate with AutoVue
                                http.status = 0;
                                if( http.responseText != null && http.responseText.length > 0 ){
                                    error = http.responseText;
                                } else {
                                    error = 'AutoVue is still not responding';
                                }
                                error = 'Delay expired but ' + error;
                            }
                        }
                        break;
                    default:
                        if( iPort != null ){
                            // Unexpected error. Move to the next port in the case of loopback connection approach
                            console.log('From port ' + getPort(av, iPort) + '. Assuming the port to be used by another service and skipping it');
                            connectOnAlternativePort(av, onInit, onFail, iPort, http)
                            return;
                        }
                    }
                    av.starting = false;
                    
                    av.currentCommandID = null;
                    if( error == null ){
                        error = 'Connection request returned with an unexpected status: ' + http.status;
                        if( http.responseText != null && http.responseText.length > 0 ){
                            error += ' (' + http.responseText + ')';
                        }
                    }
                    onFail(http, error);
                }
            }
        }

        var prms = '{"jsonrpc":"2.0", "id":0, "method":"init", "params": [' + JSON.stringify(av.INIT_PARAMS) + ']}';
        var url = av.script_connection;
        if( av.sequential_id != null ){
            url += "&Id=1";
        }
        http.open('POST', url);
        http.setRequestHeader('Content-type', av.RDV_FORMAT);
        http.overrideMimeType(av.RDV_FORMAT);
        if( iPort != null ){
            http.setRequestHeader('AV-Session-Ticket', av.ticket);
        }
        if( av.RDV_FORMAT == AutoVue.RDVFORMAT_URLFORM ){
            prms = 'AutoVueMessage=' + encodeURIComponent(prms);
        }
        http.withCredentials = true;
        http.timeout = 45000;   // Timeout the request after 45s to prevent having it for example stuck in some service running on the target port
        //console.log("Trying to connect to AutoVue on port: " + getPort(av, iPort));
        http.send(prms);
        //console.log('AutoVue Connection Attempt: ' + prms);
    }

    /** Process Scripting method */
    function processScriptMethod(av, method, parameters, onSuccessCallback, asynch, id){
        if( av.ticket == null ){
            errMsg(av, 'Cannot connect to AutoVue');
            return;
        }

        // Prevent sending asynchronous commands simmultaneousely to ensure preserving their order
        if( av.sequential_id != null && method != 'getNextEvents' ){
            // Register the time we start processing a command to prevent an infinite pinging loop
            var AV_TIMEOUT = 5000;  // 5 seconds: Could be lengthy if we are reporting file events
            var now = new Date().getTime();
            if( av.startProcessing != null && av.currentCommandID != id ){
                if( (now - av.startProcessing) > (AV_TIMEOUT + av.STARTUP_DELAY) ){ // Just in case
                    // We are pinging since a while. Somethng went wrong.
                    av.startProcessing = null;
                    av.currentCommandID = null;
                    errMsg(av, "Abort waiting for AutoVue response to the command " + method +
                               " with ID:" + id + " . The command encountered some problem.");
                }
                // AutoVue is already processing a command. Post this one
                setTimeout(function(){processScriptMethod(av, method, parameters, onSuccessCallback, asynch, id)}, 500);
                return;
            }

            if( id == null ){
                av.currentCommandID = id = ++av.sequential_id;
            }
            if( av.startProcessing == null ){
                av.startProcessing = now;
            } else if( (now - av.startProcessing) > AV_TIMEOUT ){
                // We are processing the current command since a while. 
                // Something wrong with the Rendez-Vous servlet. Get out of the loop
                av.startProcessing = null;
                av.currentCommandID = null;
                errMsg(av, "Abort waiting for AutoVue response to the command " + method + " with ID:" + id
                         + " because it is taking too long. Review AutoVue logs to diagnostic the problem.");
                return;
            }
        }

        // Reconnect if needed
        if( av.script_connection == null ){
            // AutoVue not running. Start it first then call the required script method
            launchAndProcess(av, method, parameters, onSuccessCallback, asynch, id);
            return;
        }

        // Prepare an XML request wrapping the script command
        var error = null;
        var http = new XMLHttpRequest();
        http.onreadystatechange = function() {
            if( http.readyState == XMLHttpRequest.DONE ){
                if( method == 'getNextEvents' ){
                    // Backward Channel
                    av.bLongPooling = false;
                }
                if( http.status == 200 ){   // Success
                    if( method != 'getNextEvents' ){
                        av.startProcessing = null;
                        av.currentCommandID = null;
                    }
                    if( onSuccessCallback != null && http.responseText != null ){
                        console.log('callback: ' + http.responseText);
                        onSuccessCallback(JSON.parse(http.responseText).result);
                    }
                } else {    // Server failed processing the request
                    switch( http.status ){
                    case 0:
                        if( av.iPort == null ){
                            // Rendez-Vous servlet is down
                            error = 'Failed to communicate with the "Rendez-Vous" servlet (NetworkError)';
                        } else {
                            // AutoVue is down. Restart it and call again
                            launchAndProcess(av, method, parameters, onSuccessCallback, asynch, id);
                            return;
                        }
                        break;
                    case 202:
                        // Rendez-Vous communication case: Wait a bit and ping again the server
                        setTimeout(function(){av.isPinging = true; processScriptMethod(av, method, parameters, onSuccessCallback, asynch, id)}, 500);
                        return;
                    case 404:   // Not Found: Script Command not supported by AutoVue
                        error += 'HTTP Request returned with status 404 (Unsupported Script Command). Review the command name';
                        break;
                    case 409:  // Conflict: Used by JSON-SRV servlet to indicate Session Authentication Failure
                        if( av.iPort != null ){
                            error = 'HTTP Request returned with status 409 because AutoVue failed '
                                  + 'to authenticate the session started previousely on port '
                                  + getPort(av) + '. Ensure that cookies are enabled on the browser';
                        }
                        break;
                    case 410:   // Gone: Used by the Rendez-Vous servlet to signal that AutoVue stoppped responding during the process
                        if( av.iPort == null ){
                            // Call again to get eventually 'Service Unavailable (503)' response status and restart AutoUue
                            av.isPinging = true;
                            processScriptMethod(av, method, parameters, onSuccessCallback, asynch, id);
                            return;
                        }
                        break;
                    case 503:   // Service Unavailable: Used by the Rendez-Vous servlet to signal that AutoVue is not running
                        if( av.iPort == null ){
                            // Restart AutoVue and call again
                            launchAndProcess(av, method, parameters, onSuccessCallback, asynch, id);
                            return;
                        }
                    default:
                        // 400: Bad request
                        // 412: Session not intialized
                        // 500: Server has encountered a situation it doesn't know how to handle
                    }
                    av.startProcessing = null;
                    av.currentCommandID = null;
                    if( error == null ){
                        error = 'HTTP Request returned with status ' + http.status;
                        if( http.responseText != null && http.responseText.length > 0 ){
                            error += ' (' + http.responseText + ')';
                        }                        
                    }
                    error = 'AutoVue Scripting Error (' + method + '): ' + error;
                    errMsg(av, error);
                }
            }
        }

        // Send the command
        var params = '{"jsonrpc":"2.0", "id":0, "method":"' + method + '", "params":' + getParametersString(parameters) + '}';
        var url = av.script_connection;
        var msg = 'Sending script command';
        if( id != null ){
            url += "&Id=" + id;
            msg += " (ID:" + id + ")";
        }
        if( av.isPinging != true ){
            console.log(msg + ': ' + params);
        }
        av.isPinging = false;
        if( asynch == null ){
            // By default, send asynchronous requests under Rendez-Vous Communication, otherwise, send them
            // synchronousely to ensure that they are treated sequentially by the target embedded Jetty server.
            // Note: Send always the command closeAutoVue in synchronous mode to ensure closing AutoVue on page unload
            asynch = (av.iPort == null) && (method != 'closeAutoVue');
        }
        http.open('POST', url, asynch);
        http.setRequestHeader('Content-type', av.RDV_FORMAT);
        http.overrideMimeType(av.RDV_FORMAT);
        if( av.RDV_FORMAT == AutoVue.RDVFORMAT_URLFORM ){
            params = 'AutoVueMessage=' + encodeURIComponent(params);
        }
        http.withCredentials = true;
        try {
            http.send(params);
        } catch( exception ){
            if( !asynch && av.iPort != null && exception.name == 'NetworkError' && http.status == 0 ){
                // Network Error of direct locahost connection in synchronous mode.
                // Most likely caused by AutoVue not running. Launch and call again
                launchAndProcess(av, method, parameters, onSuccessCallback, false);
                return;
            }
            error = 'AutoVue Scripting Error (' + method + ')';
            if( exception.message != null && exception.message.length > 0 ){
                error += ': ' + exception.message;
            }
            errMsg(av, error);
        }
        if( error != null ){
            // Throw error if the request hits one (syncrhonous mode)
            // We should never get here in asynchronous mode
            throw {'status':http.status,'message':error};
        }
    }

    /** Initialize AutoVue Scripting Service on an alternative port if delay permits */
    function connectOnAlternativePort(av, onInit, onFail, iPort, http){
        if( av.portsDone == false ){
            // Try next port in the list
            iPort = nextPort(av, iPort);
            if( iPort == null ){    // Already tried with all alternative ports
                // Loop on the ports again only if the delay is not consumed yet
                av.portsDone = new Date().getTime() - av.connect_start > 1000*av.STARTUP_DELAY;
                initScriptService(av, onInit, onFail);  // Retry the first port
            } else {
                // Try with the next alternative port after 0.5s
                setTimeout(function(){initScriptService(av, onInit, onFail, iPort)}, 500);
            }
        } else {
            // Failed to communicate with AutoVue
            av.starting = false;
            onFail(http, 'Delay expired but AutoVue still not responding on all the given ports');
        }	
    }

    /** Launch AutoVue and process given scripting method */
    function launchAndProcess(av, method, parameters, onSuccessCallback, asynch, id){
        // Launch AutoVue only if there is effecdively something  to process
        if( method != 'closeAutoVue' && method != 'closeDocument' && method != 'getNextEvents' && (method != 'setEventListener') ){
            reorderPorts(av);
            if( av.startProcessing != null ){
               av.startProcessing += av.STARTUP_DELAY * 1000;
            }
            launch(av, function(){processScriptMethod(av, method, parameters, onSuccessCallback, asynch, id)});
        } else if( method == 'getNextEvents' ){
            // The backward channel should not trigger AutoVue launch but it should not
            // abort. It may be needed if the launch is triggered by something else.
            setTimeout(function(){av.isPinging = true; processScriptMethod(av, method, parameters, onSuccessCallback, asynch)}, 500);
        } else {
            if( av.currentCommandID == id ){
                av.startProcessing = null;
                av.currentCommandID = null;
            }
            if( method != 'closeAutoVue'){
                console.log('AutoVue is not running. Ignoring the command: ' + method);
            }
        }
    }

    /** Enable callbacks from AutoVue to JavaScript functions */
    function getNextEvents(av, caller){
        if( caller == null ){
            return;
        }
        if( !av.bLongPooling ){
            av.bLongPooling = true;
            processScriptMethod(av, 'getNextEvents', [], function(events){
                                                            getNextEvents(av, caller);
                                                            processCallbacks(caller, events);
                                                        }, true);
        }
    }

    /** Dispatch the received events to the correspoding callbacks */
    function processCallbacks(caller, events){
        if( events == null || events.length == 0 ){
            // Nothing to do
            return;
        }
        for( var i = 0; i < events.length; i++ ){
            var event = events[i];
            if( event == null ){
                errMsg(av, 'Skipping a null callback event sent by AutoVue (not expected)');
                continue;
            }
            var args = event.args;
            if( args == null ){
                args = [event.frameID];
            } else {
                args.push(event.frameID);
            }
            caller[event.callback].apply(null, event.args);
        }
    }

    /** Build JSON parameters string */
    function getParametersString(parameters){
        var ret = '[';
        if( parameters != null ){
            for( var i = 0; i < parameters.length; i++ ){
                if( i > 0 ) ret += ',';
                var parameter = parameters[i];
                if( typeof parameter == 'undefined' ){
                    parameter = null;
                } else if( typeof parameter == 'string' || parameter instanceof String ){
                    parameter = '"' + parameter + '"';
                } else if( typeof parameter == 'object' || parameter instanceof Object ||
                           typeof parameter == 'array' || parameter instanceof Array ){
                    parameter = JSON.stringify(parameter);
                }
                ret += parameter;
            }
        }
        return ret += ']';
    }

    /** Validate and store the given port ranges */
    function storePorts(av, ports){
        if( Number.isInteger(ports) ){
            av.CLIENT_PORTS = [[ports, ports]];
        } else if( Array.isArray(ports) ){
            av.CLIENT_PORTS = new Array();
            for( var i = 0; i < ports.length; i++ ){
                if( Number.isInteger(ports[i]) ){
                    av.CLIENT_PORTS.push([ports[i], ports[i]]);
                } else if( Array.isArray(ports[i]) && ports[i].length > 0 && Number.isInteger(ports[i][0]) ){
                    var end = ports[i][0];
                    if( ports[i].length > 1 ){
                        if( Number.isInteger(ports[i][1]) && ports[i][1] >= ports[i][0] ){
                            end = ports[i][1];
                            if( ports[i].length > 2 ){
                                console.log("Invalid port range: " + JSON.stringify(ports[i]) + ". Trimming it to " + JSON.stringify([ports[i][0], end]));
                            }
                        } else {
                            console.log("Invalid port range: " + ports[i] + ". Trimming it to " + ports[i][0]);
                        }
                    }
                    av.CLIENT_PORTS.push([ports[i][0], end]);
                } else if( !Array.isArray(ports[i]) ){
                    console.log("Invalid port range: " + JSON.stringify(ports[i]) + ". Skipping it");
                }
            }
            if( av.CLIENT_PORTS.length == 0 ){
                av.CLIENT_PORTS = null;
                errMsg(av, "No ports to try!");
            }
        } else {
            errMsg(av, "Invalid ports: " + JSON.stringify(ports));
        }
        if( av.CLIENT_PORTS != null ){
           console.log("The port ranges to try are: " + JSON.stringify(av.CLIENT_PORTS));
        }
    }

    /** Get the next port in the ports list */
    function nextPort(av, iPort){
        var ports = av.CLIENT_PORTS;
        var iRange = iPort & 0xFF;
        var index = iPort >> 16;
        if( (ports[iRange][0] + index) < ports[iRange][1] ){
            index++;
        } else {
            iRange++;
            index = 0;
        }
        if( iRange < ports.length ){
            return iRange + (index << 16);
        }
        return null;
    }

    /** Get the port of the given index in the port list */
    function getPort(av, iPort){
        if( iPort == null ){
            iPort = av.iPort;
        }
        if( iPort != null && (iPort & 0xFF) < av.CLIENT_PORTS.length && (iPort >> 16) >= 0 || (iPort >> 16) < av.CLIENT_PORTS[iPort & 0xFF][1] ){
            return av.CLIENT_PORTS[iPort & 0xFF][0] + (iPort >> 16);
        }
        errMsg(av, "No port in the given ports list maps to the port index " + iPort);
        return null;
    }

    /** Build the ports string argument to pass to AutoVue Client from an array of port ranges */
    function buildPortArg(ports){
        if( ports == null && ports.length == 0 ){
            return null;            
        }
        var str = '';
        for( var i = 0; i < ports.length; i++ ){
            if( i > 0 ){
                str += ';'
            }
            str += ports[i][0] + '-' + ports[i][1];
        }
        return str
    }

    /** Reorder ports pushing previous failed ones to the end */
    function reorderPorts(av){
        var ports = av.CLIENT_PORTS;
        if( ports != null && av.iPort != null && av.iPort > 0 ){
            var iRange = av.iPort & 0xFF;
            var index  = (av.iPort >> 16);
            var _ports = new Array();
            for( var i = 0; i <= ports.length; i++, iRange++ ){
                if( iRange == ports.length ){
                    iRange = 0;
                }
                var start = ports[iRange][0] + (i > 0 ? 0 : index);
                var end   = (i < ports.length ? ports[iRange][1] : (ports[iRange][0] + index - 1));
                if( end >= start ){
                    _ports.push([start, end]);
                }
            }
            av.CLIENT_PORTS = _ports;
            console.log("Reordered ports based on the previous search: " + JSON.stringify(_ports))
        }
        av.iPort = null;
    }

    /** Serialize an Encryption Key into a compact format */
    function serializeKey(key){
        // Serialize as hex code to make sure it is url compatible
        // json serialization is not as efficient
        var ret = '';
        for( i in key ){
            var str = (key[i]&255).toString(16);
            if( str.length == 1 ){
                str = '0' + str;
            }
            ret += str;
        }
        return ret;		
    }

    /** Output a message using the method selected by VERBOSITY */
    function errMsg(av, msg){
        errMsg.VERBOSE_CONSOLE = 0x01;
        errMsg.VERBOSE_ALERT   = 0x02;

        if( av.VERBOSITY & errMsg.VERBOSE_CONSOLE ){
            console.error(msg);
        }
        if( av.VERBOSITY & errMsg.VERBOSE_ALERT ){
            alert(msg);
        }   
    }
}
