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

            <div style="display: none;" id="fb_user_data">

            </div>

            <hr />

            <div style="display: none;" id="fb_events">
                <h4>Select an event!</h4>
                <ul>

                </ul>
            </div>

            <div style="display: none;" id="fb_selected_event">

            </div>

        </div>
        <script type="text/javascript" src="/js/bootstrap.min.js"></script>
        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js"></script>
        <script src="/js/api.js"></script>
        <script type="text/javascript">
            
            var uid;
            var accessToken;
            var actualAttendings = new Array();
            
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
                        
                        create(uid, function(){});
                        
                        // Cargo datos de usuario (nombre y perfil)
                        loadUserData(uid);
                        
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
                        
                        create(uid, function() {});
                        
                        /*
                         * Hide fb connect button
                         */
                        $("#fb-connect").hide();
                        
                        /*
                         * Cargo eventos
                         */
                        loadUserEvents(uid);
                        
                    } else 
                    {
                        alert("An error was ocurred when trying to connect with Facebook");
                    }
               
                }, {scope: 'user_events,publish_actions'});
            });
            
            /*
             * Load user data
             */
            function loadUserData(uid)
            {
                FB.api('/' + uid, function(response) {
                    $("#fb_user_data")
                    .append("<img width='50' src='https://graph.facebook.com/" + uid + "/picture' />")
                    .append("<h4>" + response.name + "</h4>");
                });
                
                $("#fb_user_data").show();
            }
            
            /*
             * Load user events
             */
            function loadUserEvents(uid)
            {
                FB.api('/' + uid + '/events?since=today&until=tomorrow', function(r1) 
                {
                    var events = r1.data;
                    
                    $.each(events, function(index, value)
                    {
                        // Traigo foto del evento
                        FB.api('/' + value.id + '/picture', function(r2) {
                            var data = r2.data;
                            $("#fb_events ul").append("<li id='event_" + value.id + "' class='event-item'><img width='50' src='" + data.url + "'/>" + value.name + "<br /><a href='#'>Play!</a><div class='fb_event_play'></div></li>");
                        });
                        
                    });
                });
                
                $("#fb_events").show();
            }
            
            // Botón "Play" de cada evento
            $(".event-item a").live("click", function(e)
            {
                e.preventDefault();
                
                loadAttendingUsers($(this).parent().attr("id").replace("event_", ""));
            })
            
            
            /*
             * Load attending users of an event
             */
            function loadAttendingUsers(eid)
            {
                actualAttendings = [];
                
                // Vacío detalle de evento
                $(".fb_event_play").html("");
                
                // Muestro todos los botones play y oculto el actual
                $(".event-item a").show();
                $("#event_" + eid + " a").hide();
                
                // Traigo attendings
                FB.api('/' + eid + '/attending', function(r1) 
                {
                    attending_users = r1.data;

                    $.each(attending_users, function(index, value)
                    {
                        console.log(value + "  " + uid);
                        
                        exists(value.id, function(data)
                        {
                            console.log(value.id + "  " + uid);
                            
                            
                            if(data.exists == true)
                            {
                                actualAttendings.push(data.id);
                            }
                        });
                    });
                    
                    var total_validated_attendings = actualAttendings.length;
                    
                    if(total_validated_attendings > 0)
                    {
                        for(i = 0; i <= total_validated_attendings; i++)
                        {
                            $("#event_" + eid + " .fb_event_play").append(value.name + "<br />");
                        }
                    }
                    else
                    {
                        $(".event-item a").show();
                        alert("There is no attending users using Find Me!");
                    }
                    
                });
                
                $("#fb_selected_event").show();
            }
            
        </script>
    </body>
</html>
