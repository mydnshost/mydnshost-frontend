<!DOCTYPE html>

<html lang="en" {% if sitethemedata.bstheme != '' %}data-bs-theme="{{ sitethemedata.bstheme }}"{% endif %}>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://cdnjs.cloudflare.com/ https://cdn.jsdelivr.net/ https://www.gstatic.com/ 'unsafe-inline' https://www.google.com/recaptcha/; img-src data: 'self' www.gravatar.com *;">

    <title>{{ sitename }} :: {{ pagetitle }}</title>

    {% for css in sitethemedata.bscss %}
      <link rel="stylesheet" href="{{ css.url }}"{% if css.integrity is defined %} integrity="{{ css.integrity }}" crossorigin="anonymous"{% endif %}>
    {% endfor %}
    {% if sitethemedata.externalcss is defined %}
      {% for css in sitethemedata.externalcss %}
        <link rel="stylesheet" href="{{ css.url }}"{% if css.integrity is defined %} integrity="{{ css.integrity }}" crossorigin="anonymous"{% endif %}>
      {% endfor %}
    {% endif %}

    <link href="{{ url('assets/style.css') }}" rel="stylesheet">
    {% if sitethemedata.extracss != '' %}
      <link href="{{ url('assets/theme/' ~ sitethemedata.extracss ~ '.css') }}" rel="stylesheet">
    {% endif %}

    <!-- MyDNSHost core JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js" integrity="sha512-bLT0Qm9VnAYZDflyKcBaQ2gg0hSYNQrJ8RilYldYQ1FxQYoCLtUjuuRuZo+fjqhx/qtq/1itJ0C2ejDxltZVFg==" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.16.0/jquery.validate.min.js" integrity="sha256-UOSXsAgYN43P/oVrmU+JlHtiDGYWN2iHnJuKY9WD+Jg=" crossorigin="anonymous"></script>

    <!-- Bootstrap core JavaScript -->
    {% for js in sitethemedata.bsjs %}
      <script src="{{ js.url }}"{% if js.integrity is defined %} integrity="{{ js.integrity }}" crossorigin="anonymous"{% endif %}></script>
    {% endfor %}


  </head>

  <body>
    {% block navbar %}
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
      <div class="container-fluid">
        <a class="navbar-brand" href="{{ url('/') }}">{{ sitename }}</a>
        {% if user or domainkey %}
          <button class="btn btn-sm btn-outline-light d-lg-none ms-2 me-auto" type="button" data-bs-toggle="collapse" data-bs-target="#sidebar" aria-controls="sidebar" aria-expanded="false" aria-label="Toggle sidebar">
            &#9776;
          </button>
        {% endif %}
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
            <nav class="collapse d-lg-block bg-light sidebar nav" id="sidebar">
              {{ showSidebar() }}
            </nav>

          <main class="pt-3 sidebar-main">
        {% else %}
          <main class="col-sm-12 pt-3">
        {% endif %}
        {% block contenttop %}{% endblock %}
        {{ flash() }}
