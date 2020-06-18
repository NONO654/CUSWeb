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
            // These globals are NOT guaranteed to exist in prod
            // therefore should not be used by widgets code
            var ds        = {
                                "anonymous": $anonymous$
                            },
                dsx       = {},
                dsPrefix  = '$prefix$',
                dsLang    = '$lang$',
                dsVersion = '$version$',
                dsDefaultLoadedBundles = null,

                dsBaseUrl = '$dsBaseUrl$',
                dsResourceUrl = '$dsResourceUrl$',
                dsUntrustedBaseUrl = '$dsUntrustedBaseUrl$',
                dsDefaultWebappsBaseUrl = dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/webapps',

                dsUserLogin   = '$userLogin$',
                dsUserGranted = $if(userGranted)$true$else$false$endif$,
                dsCsrfOptions = $csrfOptions$,
                dsPlatformPrefixUrlEnabled = $platformPrefixUrlEnabled$,

                // Bundles configurations
                bundles = {
                    $bundles:{bundle|"$bundle.name$":[$bundle.dependencies:{dep|"$dep.name$"};separator=","$]};separator=",\n"$
                },

                // Widget App Platform global variables
                wap = {
                    widgetInstancesCacheId : '$defaultContextCacheId$'
                },

                // UWA configurations
                UWA = {
                    $if(debugMe)$debug: true,$endif$
                    hosts: {
                        uwa: (dsResourceUrl + dsPrefix + '$resourcePath$/$version$/$lang$/wp'),
                        exposition: (dsBaseUrl + dsPrefix + 'api'),
                        untrustedExposition: (dsUntrustedBaseUrl + dsPrefix + 'api'),
                        proxies: {
                            passport: (dsBaseUrl + dsPrefix + 'api/proxy/passport')
                        }
                    }
                },

                // Require configurations
                require = {
                    baseUrl: dsDefaultWebappsBaseUrl,
                    paths: {
                        'ds': dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/wp/script',
                        'DS': dsDefaultWebappsBaseUrl,
                        $bundles:{bundle|"$bundle.name$":dsResourceUrl+"$prefix$$resourcePath$/$version$/$lang$/$bundle.name$/script"};separator=",\n"$
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
        </script>

        <!-- CSS FILES -->
        <!--[if IE]> $cssPackFiles:{file|<link rel="stylesheet" type="text/css" href="$dsBaseUrl$$prefix$$resourcePath$/$version$/$lang$/$file$"/>};separator="\n"$ <![endif]-->
        <!--[if !IE]> --> $cssFiles:{file|<link rel="stylesheet" type="text/css" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$"/>};separator="\n"$ <!-- <![endif]-->

    </head>

    <body>
        <!-- SCRIPT FILES -->
        $scriptFiles:{file|<script type="text/javascript" src="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$$queryOptions$"></script>};separator="\n"$

        <!-- PLATFORM INIT -->
        <script type="text/javascript">
            $if(!debugMe)$UWA.log = function(){};$endif$

            require(['ds/AMD', 'DS/WebappsUtils/WebappsUtils', 'DS/WebappsUtils/Console'], function (amd, WebappsUtils, console) {
                WebappsUtils._setWebappsBaseUrl(dsDefaultWebappsBaseUrl);

                var initModuleName = '$initModuleName$',
                    envModuleName = '$environmentModuleName$';

                define('DS/UWPClientCode/UWA/Environment', [envModuleName, 'DS/Logger/Logger'],
                function (Env, Logger) {
                    Logger.info('Create virtual module "DS/UWPClientCode/UWA/Environment" -> "' + envModuleName + '"');
                    return Env;
                });

                require(
                [
                    'UWA/Core',
                    'DS/UWPClientCode/Bootstrap',
                    'DS/UWPClientCode/DebugMe',
                    'DS/UWPClientCode/PublicAPI',
                    'DS/UWPClientCode/Fingerprint',
                    initModuleName
                ],

                function (Core, Bootstrap, DebugMe, PublicAPI, Fingerprint, Product) {
                    $if(!debugMe)$Core.log = function(){};$endif$
                    PublicAPI._setUser(JSON.parse("$user$"));
                    PublicAPI.applicationConfigurations = JSON.parse("$appConfiguration$");
                    PublicAPI._initUserContexts(JSON.parse("$contexts$"));
                    Fingerprint.setAll(JSON.parse("$fingerprints$"));
                    PublicAPI._initSandbox();
                    Bootstrap.start(Product, "$navigationMode$");
                },

                console.error);
            });
        </script>
    </body>
</html>
