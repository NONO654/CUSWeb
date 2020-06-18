
var getJavaState = function () {
    var maxJavaMajorVersion = 0, maxJavaMinorVersion = 0,
        updates = {},
        pluginName = 'Java(TM)',
        name,
        i, l,
        plugin, pluginTag, jvms,
        saveVersion = function (major, minor) {
            if (major >= maxJavaMajorVersion) {
                maxJavaMajorVersion = major;
                if (!updates[major]) {
                    updates[major] = [];
                }
                updates[major].push(parseInt(minor, 10));
            }
        };

    if (navigator.plugins && navigator.plugins.length) {
        for (i = 0, l = navigator.plugins.length; i < l; i++) {
            name = navigator.plugins[i].name;
            //The version of the plugin is only contained in the name with the following format "Java(TM) Platform SE 6 U20"
            if (name.indexOf(pluginName) !== -1) {
                saveVersion(parseInt(name[21], 10), parseInt(name.substring(24), 10));
            }
        }
    } else {
        // No plugins, we are very probably in IE
        pluginTag = '<' +
                'object classid="clsid:CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA" ' +
                'id="deployJavaPlugin" width="0" height="0">' +
                '<' + '/' + 'object' + '>';
        document.write(pluginTag);
        plugin = document.getElementById('deployJavaPlugin');
        jvms = plugin.jvms;
        if (jvms) {
            for (i = 0, l = jvms.getLength(); i < l; i++) {
                name = jvms.get(i).version;
                saveVersion(parseInt(name[2], 10), parseInt(name.substring(6), 10) || 0);
            }
        }
    }
    maxJavaMinorVersion = Math.max(Math.max.apply(Math, updates[maxJavaMajorVersion] || [0]), 0);
    
    
    //case where no java plugin has been found
    if (0 === maxJavaMajorVersion && 0 === maxJavaMinorVersion) {
        return {state: 'nojava'};
    }
    // Min Java version is V7 U17
    if (maxJavaMajorVersion < 7) {
        return {state: 'outdated'};
    }

    if ((maxJavaMajorVersion === 7) && (maxJavaMinorVersion < 11)) {
        return {state: 'outdated'};
    }
    return {
        state: 'ok',
        version: maxJavaMajorVersion,
        update: maxJavaMinorVersion
    };
};


