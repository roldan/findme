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
        <div class="container">

            <h1>Find Me!</h1>
            <p>Welcome to Find Me! Connect with Facebook to start!</p>

            <img id="fb-connect" src="/images/fb_connect.png" />

            <div id="fb-root"></div>
        </div>
        <script type="text/javascript" src="/js/bootstrap.min.js"></script>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
        <script type="text/javascript">
            window.fbAsyncInit = function() {
                FB.init({
                    appId      : '414395191956343', // App ID
                    status     : true, // check login status
                    cookie     : true, // enable cookies to allow the server to access the session
                    xfbml      : true  // parse XFBML
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
            
            $("#fb-connect").click(function(e)
            {
                FB.login(function(response) {
               
                    if (response.status === 'connected') {
                        var uid = response.authResponse.userID;
                        var accessToken = response.authResponse.accessToken;
                        
                        alert(uid);
                        
                    } else if (response.status === 'not_authorized') {
                        // the user is logged in to Facebook, 
                        // but has not authenticated your app
                    } else {
                        // the user isn't logged in to Facebook.
                    }
               
                }, {scope: 'user_events,publish_actions'});
            });
        </script>
    </body>
</html>
