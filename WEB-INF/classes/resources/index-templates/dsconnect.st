<!DOCTYPE html>
<html>
    <head>
        <!-- METAS -->
        <meta http-equiv="X-UA-Compatible" content="IE=11; IE=10; IE=9; IE=8; chrome=1">
        <meta name="apple-mobile-web-app-title" content="$title$">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.8" />
        <title>$title$</title>

        <!-- FAVICONS -->
        <link rel="shortcut icon" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$favicon$" />
        <link rel="apple-touch-icon" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$touchIcon$" />

        <!-- CSS FILES -->
        <link rel="stylesheet" type="text/css" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/webapps/WebUiResult/WebUiResult.css"/>
        <!--[if IE]> $cssPackFiles:{file|<link rel="stylesheet" type="text/css" href="$prefix$$resourcePath$/$version$/$lang$/$file$"/>};separator="\n"$ <![endif]-->
        <!--[if !IE]> --> $cssFiles:{file|<link rel="stylesheet" type="text/css" href="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$$queryOptions$"/>};separator="\n"$ <!-- <![endif]-->

        <!-- GLOBAL JS VARIABLES -->
        <script type="text/javascript">
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

                dsUserLogin   = '$userLogin$',
                dsUserGranted = $if(userGranted)$true$else$false$endif$,
                dsCsrfOptions = $csrfOptions$,
                dsPlatformPrefixUrlEnabled = $platformPrefixUrlEnabled$,

                // Bundles configurations
                bundles = {
                    $bundles:{bundle|"$bundle.name$":[$bundle.dependencies:{dep|"$dep.name$"};separator=","$]};separator=",\n"$
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

                // Curl configurations
                curl = {
                    overwriteApi: false,
                    apiName:'curl_require',
                    defineName: 'curl_define',
                },

                // Require configurations
                require = {
                    paths: {
                        'ds': dsResourceUrl + '$prefix$$resourcePath$/$version$/$lang$/wp/script',
                        $bundles:{bundle|"$bundle.name$":dsResourceUrl+"$prefix$$resourcePath$/$version$/$lang$/$bundle.name$/script"};separator=",\n"$
                    },
                    config: {
                        i18n: {
                            locale: '$lang$'
                        }
                    },
                    $if(debugMe)$urlArgs: 'debug_me',$endif$
                    skipDataMain: true
                };
        </script>
    </head>

    <body>
        <!-- SCRIPT FILES -->
        $scriptFiles:{file|<script type="text/javascript" src="$dsResourceUrl$$prefix$$resourcePath$/$version$/$lang$/$file$$queryOptions$"></script>};separator="\n"$
        <script type="text/javascript">
            require([
                // UWA
                'UWA/Core'

            ], function (UWA) {
                'use strict';

                /**
                 * Takes the result message send by passport.
                 * @param {String} message - Message result send by passport.
                 */
                function takeMessage (message) {
                    var parameters, resultParam,
                        message = document.location.hash;

                    if (message.length) {
                        message = message.substr(1);

                        parameters = parseParameters(message);
                        resultParam = parameters.result;

                        if (resultParam) {
                            dispatchMessage(resultParam);
                        }
                    }
                }


                /**
                 * Dispatch event depending on message recieve from passport to top document.
                 * @param {String} message - Message recieve from passport.
                 */
                function dispatchMessage (message) {
                    try {
                        top.require(['DS/PubSub/PubSub'],
                        function (PubSub) {
                            PubSub.dispatch('myprofile:updated', message);
                        });

                    } catch (e) {
                        UWA.log('Error while requiring top.PubSub from dsconnect.st');
                        Log.error(e);
                    }
                }

                /**
                 * Parse passport message result.
                 * @param  {String} message    - Message result send by passport.
                 * @return {Object} dictionary - Message result in Object format.
                 */
                function parseParameters (message) {
                    var dictionary = [],
                        nameVal = message.split('=');

                    dictionary[nameVal[0]] = nameVal[1];
                    return dictionary;
                }

                takeMessage();
            });
        </script>
    </body>
</html>
