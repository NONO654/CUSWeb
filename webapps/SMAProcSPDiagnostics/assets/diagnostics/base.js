
let console = window.parent.console;

export default class DiagnosticsBase {
  init () {
    // set the app name and id
    this.$appName = window.widget.options.title.toLowerCase().replace(/\s/, '_').trim();
    this.$appId = window.widget.data.appId;
    
    // check if $requestContext handler is present
    !this._$contextRequest && console.warn('Missing _$contextRequest method. Include this method in your class');
        
    // if this is the first call
    if (!this.state) {
      // broadcast channel is used only to receive messages
      this.bc = new BroadcastChannel('sp-diagnostics');
      this.bc.onmessage = ev => {
        // if this is connected to diagnostics widget and there is an action to perform call the action
        if (window._diagnostics_.connected && this[ev.data.$action]) {
          this[ev.data.$action].call(this, ev.data);
        }
      };
      this.state = 'initialized';

      // listen to post messages on frame
      window.addEventListener('message', this._$handShake.bind(this));
    }
  }

  getDateTime () {
    const today = new Date(); 
    return (today.getMonth()+1) + '/'
          + today.getDate() + '/'
          + today.getFullYear() + ' @ '
          + today.getHours() + ':'  
          + today.getMinutes() + ':'
          + today.getSeconds();
  }

  send (data) {
    // post the message only if its connected
    if (window._diagnostics_.connected) {
      // to append the timestamp with data
      const $dateTime = this.getDateTime();

      // add appName, appId and dateTime of this message to the data
      data = {...data, $appName: this.$appName, $appId: this.$appId, $dateTime};

      window.parent.postMessage(data, '*');
    }
  }

  // makes the array of data as transferrable data (can use JSON.stringify to see if its transferrable)
  static makeItTransferrable(data) {
    // typeof(data) !== Array && console.warn('Only array is supported', data);

    // check if it is an HTMLElement (then pass that element's name and value pair as attributes)

    return data.map(item => {
      let itemType;
      let res;

      // check if it is an HTMLElement
      itemType = item instanceof HTMLElement ? 'HTMLElement' : '';
              
      switch (itemType) {
        case 'HTMLElement':
          const tag = item.tagName.toLowerCase();
          
          const attrs = Object.keys(item.attributes).map(key => {
            const {name, value} = item.attributes[key];
            return `${name}="${value}"`;
          });
          res = `<${tag} ${attrs.join(' ')}></${tag}>`;
          break;

        default:
          res = item;
      }

      return res;
    });
  }

  static getStackInfo() {
    let origin = '';
    let stack = '';

    try {
      stack = (new Error()).stack.split(/\n/g).splice(3);
      stack.forEach(str => {
        const splitted = str.split(/\//);
        const found = splitted[splitted.length - 1].split(/:|\?/)[0];

        // if origin is empty or its not one of these well known names
        if(!origin || !'polymer.html|base.js|'.contains(found)) {
          origin = found;
        }
      });
    } catch (ex) {
      console.warn('Unable to find origin', ex);
    }

    //TODO: send the URL of origin
       
    return {stack, origin};
  }
  
  // internal method
  _$handShake () {
    const handShake = {$action: '_$handShake', $appName: this.$appName};
    this.send(handShake);
  }

  // should these methods must be idempotent? (maybe not because toggle behavior)
  $recordConsole (data) {
    const {$action} = data;

    // send method
    const send = this.send.bind(this);

    // override window.console (25 methods/properties)
    function _handle (method) {        
      // build the parameters from arguments
      const args = [].splice.call(arguments, 1);
      let params = Object.keys(args).map(key => args[key]);
      params = DiagnosticsBase.makeItTransferrable(params);

      // send the message if its a log, info, debug, warn
      if (method.search(/^(info|log|debug|warn|error)$/g) > -1) {
        const title = params[0];
        const msgType = method;
        const {stack, origin} = DiagnosticsBase.getStackInfo();

        // const callStack = 'TODO - ADD THIS WHEN IT IS AN ERROR FOR CONSOLE';
        let content = msgType === 'error' ? stack.join('\n') : '';

        // if status is on then send
        data.$status && send({$action, title, content, origin, msgType});
      }
      
      // call the original console method
      return window.parent.console[method].apply(window.parent.console, args);
    }
    
    // preserve the original console
    // const console = window.parent.console;
    
    // override the methods in console
    Object.keys(window.console).forEach(key => {
      window.console[key] = _handle.bind(window.console, key);
    });
  }

  $recordXMLHTTPRequests (data) {
    const {$action} = data;

    const Xhr = window.XMLHttpRequest;

    // send method
    const send = this.send.bind(this);
    
    class XhrProxy extends Xhr {
      async open(verb, uri) {
        super.open(verb, uri);

        // persist
        this._verb = verb;
        this._uri = uri;

        // get the origin from stack info
        const {origin} = DiagnosticsBase.getStackInfo();
        this._origin = origin;
      }
        
      _onResponse(callback) {									
        if (this.readyState === this.DONE) {
          // send({$action, uri: this._uri, verb: this._verb});

          // GET https://example.com STATUS=200
          const title = `${this._verb} ${this._uri} STATUS=${this.status} `;
          const requestHeaders = Object.keys(this._headers).map(header => header + ':' + this._headers[header]).join('\n');
          const responseHeaders = this.getAllResponseHeaders().trim();

          let content = 'Request Headers\n' + requestHeaders;
          content += responseHeaders ? '\n\nResponse Headers\n' + responseHeaders : '';
                             

          const origin = this._origin || 'sp-webservice.js';
          const msgType = this.status === 200 ? 'info' : 'error';
         
          // if status is on then send
          data.$status && send({$action, title, content, origin, msgType});

          callback();
        }
      }

      setRequestHeader(header, value) {
        super.setRequestHeader(header, value);

        // preserve the header
        this._headers = this._headers || {};
        this._headers[header] = value;
      }
  
      set onreadystatechange(callback) {
        super.onreadystatechange = this._onResponse.bind(this, callback);
      }
    }
    
    //override
    window.XMLHttpRequest = XhrProxy;
  }
  
}
