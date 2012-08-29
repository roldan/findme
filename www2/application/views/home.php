<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="title" content="Find Me!" />
        <title>Find Me!</title>
        <link rel="stylesheet" type="text/css" media="screen" href="/css/bootstrap.min.css" />
        <link rel="stylesheet" type="text/css" media="screen" href="/css/style.css" />
    </head>
    <body>

        <div id="fb-root"></div>

        <div class="container">

            <h1>Find Me!</h1>

            <p>Welcome to Find Me! Connect with Facebook to start!</p>

            <img id="fb-connect" src="/images/fb_connect.png" />

            <div style="display: none;" id="fb_events">
                <ul>

                </ul>
            </div>


        </div>
        <script type="text/javascript" src="/js/bootstrap.min.js"></script>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
        <script type="text/javascript">
            
            var uid, accessToken;
            
            window.fbAsyncInit = function() {
                FB.init({
                    appId      : '414395191956343', // App ID
                    status     : true, // check login status
                    cookie     : true, // enable cookies to allow the server to access the session
                    xfbml      : true  // parse XFBML
                });
                
                /*
                 * Check user status
                 */
                FB.getLoginStatus(function(response) {
                    if (response.status === 'connected') 
                    {
                        // Oculto botón
                        $("#fb-connect").hide();
                        
                        // Seteo variables
                        uid = response.authResponse.userID;
                        accessToken = response.authResponse.accessToken;
                        
                        // Cargo eventos del usuario
                        loadUserEvents(uid);
                    }
                });
            };
            // Load the SDK Asynchronously
            (function(d){
                var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
                if (d.getElementById(id)) {return;}
                js = d.createElement('script'); js.id = id; js.async = true;
                js.src = "//connect.facebook.net/en_US/all.js";
                ref.parentNode.insertBefore(js, ref);
            }(document));
            
            /*
             * FB Connect button
             */
            $("#fb-connect").click(function(e)
            {
                FB.login(function(response) 
                {
                    if (response.status === 'connected') 
                    {
                        uid = response.authResponse.userID;
                        accessToken = response.authResponse.accessToken;
                        
                        /*
                         * Hide fb connect button
                         */
                        $("#fb-connect").hide();
                        
                        /*
                         * TODO: Valido en servidor, y obtengo hash
                         */ 
                        
                        /*
                         * Cargo eventos
                         */
                        loadUserEvents(uid);
                        
                    } else 
                    {
                        alert("Could not connect with Facebook");
                    }
               
                }, {scope: 'user_events,publish_actions'});
            });
            
            /*
             * Load user events
             */
            function loadUserEvents(uid)
            {               
                FB.api(
                {
                    method: 'fql.query',
                    query: 'SELECT uid, first_name, last_name FROM user WHERE uid = ' + uid
                },
                function(data) {
                    console.log(data);
                }
            );
            }
            
        </script>
    </body>
</html>
