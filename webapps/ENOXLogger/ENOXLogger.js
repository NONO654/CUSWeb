/**
* @license Copyright 2017 Dassault Systemes. All rights reserved.
*
* @overview : Logger of the UX Scaffolding
*
* @author H9M
*/

define('DS/ENOXLogger/Logger',
[
  'UWA/Core'
],

function (UWACore) {
  'use strict';

// Top level module for the global, static logger instance, also manages contextual loggers
var Logger = {};

// Function which handles all incoming log messages.
var logHandler;

var globalLogger, loggerContext = {};

// Map of ContextualLogger instances by name; used by Logger.get() to return the same named instance.
var contextualLoggersByNameMap = {};

// Helper to define a logging level object; helps with optimisation.
var defineLogLevel = function(value, name) {
  return { value: value, name: name };
};

// Predefined logging levels.
Logger.LEVEL = {};
Logger.LEVEL.OFF = defineLogLevel(99, 'OFF');
Logger.LEVEL.DEBUG = defineLogLevel(1, 'DEBUG');
Logger.LEVEL.INFO = defineLogLevel(2, 'INFO');
Logger.LEVEL.WARN = defineLogLevel(3, 'WARN');
Logger.LEVEL.ERROR = defineLogLevel(4, 'ERROR');

// Helper to define a handler
var defineHandler = function(value, name) {
  return { value: value, name: name };
};

// Predefined handlers
Logger.HANDLER = {};
Logger.HANDLER.CONSOLE = defineHandler(1, 'CONSOLE');
Logger.HANDLER.SERVER = defineHandler(2, 'FILE');

// Default message formatter: Prepend the logger's name to the log message for easy identification.
var defaultFormatter = function (messages, context) {
  if (context.name) {
    messages.unshift("[" + context.name + "]");
  }
};

// handler to print logs to console
var consoleHandler = function (messages, context) {
  // Convert arguments object to Array.
  messages = Array.prototype.slice.call(messages);
  var hdlr = console.log.bind(console);
  // Delegate through to custom loggers if present on the console.
  if (context.printLevel === Logger.LEVEL.WARN && console.warn) {
    hdlr = console.warn.bind(console);
  } else if (context.printLevel === Logger.LEVEL.ERROR && console.error) {
    hdlr = console.error.bind(console);
  } else if (context.printLevel === Logger.LEVEL.INFO && console.info) {
    hdlr = console.info.bind(console);
  } else if (context.printLevel === Logger.LEVEL.DEBUG && console.debug) {
    hdlr = console.debug.bind(console);
  }
  defaultFormatter(messages, context.loggerContext);
  hdlr(messages);
};

// handler to store logs to server
var serverHandler = function (messages, context) {
//TODO
};

var setHandler = function (handler) {
  var fn;
  if (handler === Logger.HANDLER.CONSOLE) {
    fn = consoleHandler;
  }
  else if (handler === Logger.HANDLER.SERVER) {
    fn = fileHandler;
  }
  return fn;
};

// ContextualLogger instances can be configured independently of each other
var ContextualLogger = function (defaultContext) {
  var self = this;
  self.context = defaultContext;

  // Is the logger configured to output messages at the supplied level?
  var enabledFor = function (lvl) {
    var filterLevel = self.context.level;
    return lvl.value >= filterLevel.value;
  };

  // Invokes the logger callback if it's not being filtered.
  var invoke = function (level, msgArgs) {
    if (logHandler && enabledFor(level)) {
      logHandler(msgArgs, { loggerContext:self.context, printLevel:level } );
    }
  };

  return {
    setLevel: function (newLevel) {
      self.context.level = newLevel;
    },
    debug: function () {
      invoke(Logger.LEVEL.DEBUG, arguments);
    },
    info: function () {
      invoke(Logger.LEVEL.INFO, arguments);
    },
    warn: function () {
      invoke(Logger.LEVEL.WARN, arguments);
    },
    error: function () {
      invoke(Logger.LEVEL.ERROR, arguments);
    },
  };

};

// Default Configuration of Logger
var defaultConfig = {
  name: 'MAIN',
  level: Logger.LEVEL.OFF,
  handler: Logger.HANDLER.CONSOLE,
};

globalLogger = new ContextualLogger({ name: defaultConfig.name , level: defaultConfig.level });
logHandler = setHandler(defaultConfig.handler);

Logger.init = function (options) {
  logHandler = setHandler(options && options.handler || defaultConfig.handler);
  loggerContext.level = options && options.level || defaultConfig.level;
  globalLogger.setLevel(loggerContext.level);

  if(options && options.loggers) {
    options.loggers.forEach(function(element){
      if(element.name) {
        contextualLoggersByNameMap[element.name] = new ContextualLogger(element);
      }
    })
  }
};

Logger.get = function (name) {
  return contextualLoggersByNameMap[name] ||
  (contextualLoggersByNameMap[name] = new ContextualLogger({ name: name, level: loggerContext.level}) );
};

Logger.debug = globalLogger.debug;
Logger.info = globalLogger.info;
Logger.warn = globalLogger.warn;
Logger.error = globalLogger.error;

return Logger;
});
