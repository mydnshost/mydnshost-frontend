<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://cdnjs.cloudflare.com/ https://www.gstatic.com/ 'unsafe-inline' https://www.google.com/recaptcha/; img-src 'self' www.gravatar.com *;">

    <title>{{ sitename }} :: {{ pagetitle }}</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.0/css/bootstrap.min.css" integrity="sha512-rO2SXEKBSICa/AfyhEK5ZqWFCOok1rcgPYfGOqtX35OyiraBg6Xa4NnBJwXgpIRoXeWjcAmcQniMhp22htDc6g==" crossorigin="anonymous" />

    <link href="{{ url('assets/style.css') }}" rel="stylesheet">

    <!-- Bootstrap core JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js" integrity="sha512-bLT0Qm9VnAYZDflyKcBaQ2gg0hSYNQrJ8RilYldYQ1FxQYoCLtUjuuRuZo+fjqhx/qtq/1itJ0C2ejDxltZVFg==" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js" integrity="sha512-hCP3piYGSBPqnXypdKxKPSOzBHF75oU8wQ81a6OiGXHFMeKs9/8ChbgYl7pUvwImXJb03N4bs1o1DzmbokeeFw==" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha512-I5TkutApDjnWuX+smLIPZNhw+LhTd8WrQhdCKsxCFRSvhFx2km8ZfEpNIhF9nq04msHhOkE8BMOBj5QE07yhMA==" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.16.0/jquery.validate.min.js" integrity="sha256-UOSXsAgYN43P/oVrmU+JlHtiDGYWN2iHnJuKY9WD+Jg=" crossorigin="anonymous"></script>
  </head>

  <body>
    {% block navbar %}
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <a class="navbar-brand" href="{{ url('/') }}">{{ sitename }}</a>
      <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>

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
            <nav class="col-sm-3 col-md-2 hidden-xs-down bg-light sidebar" id="sidebar">
              {{ showSidebar() }}
            </nav>

          <main class="col-sm-9 offset-sm-3 col-md-10 offset-md-2 pt-3">
        {% else %}
          <main class="col-sm-12 pt-3">
        {% endif %}
        {% block contenttop %}{% endblock %}
        {{ flash() }}
