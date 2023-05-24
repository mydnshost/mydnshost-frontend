<!DOCTYPE html>

<html lang="en" {% if sitethemedata.bstheme != '' %}data-bs-theme="{{ sitethemedata.bstheme }}"{% endif %}>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://cdnjs.cloudflare.com/ https://cdn.jsdelivr.net/ https://www.gstatic.com/ 'unsafe-inline' https://www.google.com/recaptcha/; img-src data: 'self' www.gravatar.com *;">

    <title>{{ sitename }} :: {{ pagetitle }}</title>

    {% if sitetheme == 'night' %}
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.3/css/bootstrap.min.css" integrity="sha512-GQGU0fMMi238uA+a/bdWJfpUGKUkBdgfFdgBm72SUQ6BeyWjoY/ton0tEjH+OSH9iP4Dfh+7HM0I9f5eR0L/4w==" crossorigin="anonymous" referrerpolicy="no-referrer" />
      <link href="https://cdn.jsdelivr.net/npm/bootstrap-dark-5@1.1.3/dist/css/bootstrap-night.min.css" rel="stylesheet">
    {% elseif sitetheme == 'cyborg' %}
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.1.3/dist/cyborg/bootstrap.min.css" integrity="sha256-fO58jx4RDvdVgLJ4VWCNdWLLQF5cXb34EtdoGxlcJ68=" crossorigin="anonymous">
    {% elseif sitethemedata.bsversion == '5.3' %}
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-GLhlTQ8iRABdZLl6O3oVMWSktQOp6b7In1Zl3/Jr59b6EGGoI1aFkw7cmDA6j6gD" crossorigin="anonymous">
    {% else %}
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.3/css/bootstrap.min.css" integrity="sha512-GQGU0fMMi238uA+a/bdWJfpUGKUkBdgfFdgBm72SUQ6BeyWjoY/ton0tEjH+OSH9iP4Dfh+7HM0I9f5eR0L/4w==" crossorigin="anonymous" referrerpolicy="no-referrer" />
    {% endif %}

    <link href="{{ url('assets/style.css') }}" rel="stylesheet">
    {% if sitethemedata.extracss != '' %}
      <link href="{{ url('assets/theme/' ~ sitethemedata.extracss ~ '.css') }}" rel="stylesheet">
    {% endif %}

    <!-- MyDNSHost core JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js" integrity="sha512-bLT0Qm9VnAYZDflyKcBaQ2gg0hSYNQrJ8RilYldYQ1FxQYoCLtUjuuRuZo+fjqhx/qtq/1itJ0C2ejDxltZVFg==" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.16.0/jquery.validate.min.js" integrity="sha256-UOSXsAgYN43P/oVrmU+JlHtiDGYWN2iHnJuKY9WD+Jg=" crossorigin="anonymous"></script>

    <!-- Bootstrap core JavaScript -->
    {% if sitethemedata.bsversion == '5.3' %}
      <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz9ATKxIep9tiCxS/Z9fNfEXiDAYTujMAeBAsjFuCZSmKbSSUnQlmh/jp3" crossorigin="anonymous"></script>
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.min.js" integrity="sha384-mQ93GR66B00ZXjt0YO5KlohRA5SY2XofN4zfuZxLkoj1gXtW8ANNCe9d5Y3eG5eD" crossorigin="anonymous"></script>
    {% else %}
      <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/2.10.2/umd/popper.min.js" integrity="sha512-nnzkI2u2Dy6HMnzMIkh7CPd1KX445z38XIu4jG1jGw7x5tSL3VBjE44dY4ihMU1ijAQV930SPM12cCFrB18sVw==" crossorigin="anonymous"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.1.3/js/bootstrap.min.js" integrity="sha512-OvBgP9A2JBgiRad/mM36mkzXSXaJE9BEIENnVEmeZdITvwT09xnxLtT4twkCa8m/loMbPHsvPl0T8lRGVBwjlQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    {% endif %}


  </head>

  <body>
    {% block navbar %}
    <nav class="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
      <div class="container-fluid">
        <a class="navbar-brand" href="{{ url('/') }}">{{ sitename }}</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
          <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbar">
        	{{ showHeaderMenu() }}

          <div class="navbar-nav">
            {% if impersonating %}
                <a href="{{ url('/impersonate/cancel') }}" class="btn btn-danger my-2 my-sm-0 me-sm-2">Cancel Impersonation</a>
            {% endif %}

            {% if user or domainkey %}
            <div class="dropdown">
              <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButton" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
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
            <nav class="col-sm-3 col-md-2 hidden-xs-down bg-light sidebar nav d-block" id="sidebar">
              {{ showSidebar() }}
            </nav>

          <main class="col-sm-9 offset-sm-3 col-md-10 offset-md-2 pt-3">
        {% else %}
          <main class="col-sm-12 pt-3">
        {% endif %}
        {% block contenttop %}{% endblock %}
        {{ flash() }}
