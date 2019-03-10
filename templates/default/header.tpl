<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://cdnjs.cloudflare.com/ 'unsafe-inline'; img-src 'self' www.gravatar.com *;">

    <title>{{ sitename }} :: {{ pagetitle }}</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-alpha.6/css/bootstrap.min.css" integrity="sha256-rr9hHBQ43H7HSOmmNkxzQGazS/Khx+L8ZRHteEY1tQ4=" crossorigin="anonymous" />

    <link href="{{ url('assets/style.css') }}" rel="stylesheet">

    <!-- Bootstrap core JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha256-gL1ibrbVcRIHKlCO5OXOPC/lZz/gpdApgQAzskqqXp8=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-alpha.6/js/bootstrap.min.js" integrity="sha256-+kIbbrvS+0dNOjhmQJzmwe/RILR/8lb/+4+PUNVW09k=" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.16.0/jquery.validate.min.js" integrity="sha256-UOSXsAgYN43P/oVrmU+JlHtiDGYWN2iHnJuKY9WD+Jg=" crossorigin="anonymous"></script>
  </head>

  <body>
    {% block navbar %}
    <nav class="navbar navbar-toggleable-md navbar-inverse fixed-top bg-inverse">
      <button class="navbar-toggler navbar-toggler-right hidden-lg-up" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <a class="navbar-brand" href="{{ url('/') }}">{{ sitename }}</a>

      <div class="collapse navbar-collapse" id="navbar">
      	{{ showHeaderMenu() }}

        <div class="navbar-nav">
          {% if impersonating %}
              <a href="{{ url('/impersonate/cancel') }}" class="btn btn-danger my-2 my-sm-0 mr-sm-2">Cancel Impersonation</a>
          {% endif %}

          {% if user or domainkey %}
          <div class="dropdown">
            <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
              {% if user %}
                {% if user.avatar == 'gravatar' %}
                  <img src="{{ user.email | gravatar }}" alt="{{ user.realname }}" class="avatar miniavatar" />&nbsp;
                {% elseif user.avatar == 'none' %}
                  <img src="{{ 'none' | gravatar }}" alt="{{ user.realname }}" class="avatar miniavatar" />&nbsp;
                {% else %}
                  <img src="{{ user.avatar }}" alt="{{ user.realname }}" class="avatar miniavatar" />&nbsp;
                {% endif %}
                {{ user.realname }}
              {% elseif domainkey %}
                DomainKey :: {{ domainkey.domain }} :: {{ domainkey.description }}
              {% endif %}
            </button>
            <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
              {% if user %}
                <a class="dropdown-item" href="{{ url('/profile') }}">Profile</a>
                <div class="dropdown-divider"></div>
              {% endif %}
              <a class="dropdown-item" href="{{ url('/logout') }}">Logout</a>
            </div>
          </div>
          {% endif %}
        </div>
      </div>
    </nav>
    {% endblock %}

    <div class="container-fluid">
      <div class="row">
        {% if nosidebar is defined and nosidebar %}
          {% set showsidebar = false %}
        {% elseif user or domainkey %}
          {% set showsidebar = true %}
        {% else %}
          {% set showsidebar = false %}
        {% endif %}

        {% if showsidebar %}
            <nav class="col-sm-3 col-md-2 hidden-xs-down bg-faded sidebar" id="sidebar">
              {{ showSidebar() }}
            </nav>

          <main class="col-sm-9 offset-sm-3 col-md-10 offset-md-2 pt-3">
        {% else %}
          <main class="col-sm-12 pt-3">
        {% endif %}
        {% block contenttop %}{% endblock %}
        {{ flash() }}
