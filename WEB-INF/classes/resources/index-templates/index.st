<!DOCTYPE html>
<html>
    <head>
        <!-- METAS -->
        <meta http-equiv="X-UA-Compatible" content="IE=11; IE=10; IE=9; IE=8; chrome=1">
        <meta name="apple-mobile-web-app-title" content="$title$">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.8" />
        <meta name="description" content="$description$">
        <title>$title$</title>

        <!-- FAVICONS -->
        <link rel="shortcut icon" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$favicon$" />
        <link rel="apple-touch-icon" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$touchIcon$" />

        <!-- GLOBAL JS VARIABLES -->
        <script>
            // these globals are NOT guaranteed to exist in prod and should not be used
            // by widgets code
            var ds  = {
                    "anonymous": $anonymous$
                },
                dsx = {},
                dsPrefix    = '$prefix$',
                dsLang      = '$lang$',
                dsVersion   = '$version$',
                dsBaseUrl   = '$dsBaseUrl$',
                dsResourceUrl = '$dsResourceUrl$',
                dsUserLogin = '$userLogin$',
                dsUserGranted = $if(userGranted)$true$else$false$endif$,
                dsCsrfOptions = $csrfOptions$,
                dsUntrustedBaseUrl = '$dsUntrustedBaseUrl$',
                dsDefaultWebappsBaseUrl = dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/webapps',
                dsDefaultLoadedBundles = [$productBundles:{bundle|'$bundle.name$'};separator=","$],
                dsPlatformPrefixUrlEnabled = $platformPrefixUrlEnabled$,

                // Bundles configurations
                bundles = {
                    $bundles:{bundle|'$bundle.name$':[$bundle.dependencies:{dep|'$dep.name$'};separator=","$]};separator=",\n"$
                },

                // Widget App Platform global variables
                wap = {
                    widgetInstancesCacheId : '$defaultContextCacheId$'
                },

                // UWA configurations
                UWA = {
                    $if(debugMe)$debug: true,$endif$
                    hosts: {
                        uwa: (dsResourceUrl + dsPrefix + 'resources/$version$/$lang$/wp'),
                        exposition: (dsBaseUrl + dsPrefix + 'api'),
                        untrustedExposition: (dsUntrustedBaseUrl + dsPrefix + 'api'),
                        proxies: {
                            passport: (dsBaseUrl + dsPrefix + 'api/proxy/passport')
                        }
                    }
                },

                // Require configurations
                require = {
                    baseUrl: dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/webapps',
                    paths: {
                        'ds': dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/wp/script',
                        'DS': dsDefaultWebappsBaseUrl,
                        $bundles:{bundle|'$bundle.name$':dsResourceUrl+'$prefix$$resourcePath$/$version$/$lang$/$bundle.name$/script'};separator=",\n"$
                    },
                    config: {
                        i18n: {
                            locale: '$lang$'
                        },
                        'DS/Logger/Logger': {
                            disableLog: !$debugMe$
                        }
                    },
                    $if(debugMe)$urlArgs: 'debug_me',$endif$
                    skipDataMain: true
                };
                window.performance && performance.mark && performance.mark("wp_index_config_loaded");
        </script>

        <!-- CSS FILES -->
        $cssPackFiles:{file|<link rel="stylesheet" type="text/css" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$"/>};separator="\n"$

    </head>

    <body>
        <!-- SCRIPT FILES -->
        $if(productBundlesWithFallback)$
            $productBundlesWithFallback:{file|<script src="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$"></script>};separator="\n"$
        $else$
            $productBundles:{bundle|<script src="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$bundle.name$/bundle$if(!debugMe)$-min$endif$.js"></script>};separator="\n"$
        $endif$

        <!-- PLATFORM INIT -->
        <script>
            $if(!debugMe)$UWA.log = function(){};$endif$
            window.performance && performance.mark && performance.mark('wp_index_bundles_loaded');

            var initModuleName = '$initModuleName$',
                envModuleName = '$environmentModuleName$';

                define('DS/UWPClientCode/UWA/Environment', [envModuleName, 'DS/Logger/Logger'],
                function (Env, Logger) {
                    Logger.info('Create virtual module "DS/UWPClientCode/UWA/Environment" -> "' + envModuleName + '"');
                    return Env;
                });

            require(['ds/AMD', 'DS/WebappsUtils/WebappsUtils', 'DS/WebappsUtils/Console'],
            function (amd, WebappsUtils, console) {
                WebappsUtils._setWebappsBaseUrl(dsDefaultWebappsBaseUrl);

                require(
                [
                    'UWA/Core',
                    'DS/WebappsUtils/Performance',
                    'DS/UWPClientCode/Bootstrap',
                    'DS/UWPClientCode/DebugMe',
                    'DS/UWPClientCode/PublicAPI',
                    'DS/UWPClientCode/Fingerprint',
                    initModuleName
                ],

                function (Core, Performance, Bootstrap, DebugMe, PublicAPI, Fingerprint, Product) {
                    $if(!debugMe)$Core.log = function(){};$endif$
                    PublicAPI._setUser(JSON.parse("$user$"));
                    PublicAPI.applicationConfigurations = JSON.parse("$appConfiguration$");
                    PublicAPI._initUserContexts(JSON.parse("$contexts$"));
                    Fingerprint.setAll(JSON.parse("$fingerprints$"));
                    Performance.mark('wp_index_bootstrap_start');
                    PublicAPI._initSandbox();
                    Bootstrap.start(Product, "$navigationMode$");
                },

                console.error);
            });
        </script>
    </body>
</html>
