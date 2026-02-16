{% block containerwrapper %}<div class="container">{% endblock %}
  {% block contenttop %}{% endblock %}
  {% block jumbotron %}
    <div class="row jumbotron">
      <div class="col">
        <h1>Welcome!</h1>
        <p class="lead">
          Welcome to {{sitename}}.
        </p>
        <p class="lead">
          Easy DNS Hosting with a comprehensive API and DNSSEC support.
        </p>
      </div>
      <div class="col-5">
        <form class="form-signin" method="post" action="{{ url('/login') }}">
          <h1 class="form-signin-heading">Please sign in</h1>
          <label for="inputEmail" class="visually-hidden">Email address</label>
          <input type="email" name="user" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
          <label for="inputPassword" class="visually-hidden">Password</label>
          <input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>

          <div class="d-grid mt-2 gap-2">
            <button class="btn btn-lg btn-primary" type="submit">Sign in</button>
          </div>
          <div class="float-start">
            <a href="{{ url('/forgotpassword') }}" class="">Forgot Password</a>
             -
            <a href="{{ url('/register') }}" class="">Register</a>
          </div>
        </form>
      </div>
    </div>
  {% endblock %}


  <div class="row">
    <div class="col">
      <h2>Open Source</h2>
      <p>
        All of the code behind the site is available under the MIT License on github if you want to see how it works, run your own instance, or contribute changes/improvements/feature-requests. Development is conducted entirely in the open with no closed-source components.
      </p>
      <p>
        <a class="btn btn-primary" href="https://github.com/mydnshost" role="button">Github &raquo;</a>
      </p>
    </div>

    <div class="col">
      <h2>Full API Access</h2>
      <p>
        Everything can be accessed and modified via a comprehensive JSON-Based REST API, with full documentation and examples. Access can be restricted by API Keys down to individual records for security purposes.
      </p>
      <p>
        <a href="https://letsencrypt.org/docs/client-options/">ACME</a> Clients (such as <a href="https://go-acme.github.io/lego/">LEGO</a> and <a href="https://acme.sh">acme.sh</a>) for use with services like <a href="https://letsencrypt.org">Let's Encrypt</a> are also <a href="{{ apiurl('/1.0/docs/') }}#acme-requests-httpreq-acmeproxy">supported</a>.
      </p>
      <p>
        <a class="btn btn-primary" href="{{ apiurl('/1.0/docs/') }}" role="button">API Documentation &raquo;</a>
      </p>
    </div>
  </div>

  <br>

  <div class="row">
    <div class="col">
      <h2>Shared domains</h2>
      <p>
        Easily grant other users read and/or write access to a single domain, without giving them access to all of your other domains. No more account-sharing needed.
      </p>
    </div>

    <div class="col">
      <h2>Modern Features</h2>
      <p>
        All Zones are automatically DNSSEC-signed, and support for modern record types like <a href="https://datatracker.ietf.org/doc/html/rfc8659">CAA</a>, <a href="https://datatracker.ietf.org/doc/html/rfc4255">SSHFP</a>, <a href="https://datatracker.ietf.org/doc/html/rfc6698">TLSA</a>, and <a href="https://datatracker.ietf.org/doc/html/draft-ietf-dnsop-svcb-https-08">SVCB/HTTPS</a> is available as standard.
      </p>
      <p>
        two-factor authentication is supported for all accounts and statistics on domain queries, <a href="{{ apiurl('/1.0/docs/') }}#custom-extensions">Custom Extensions</a> to make management of zones easier are also included.
      </p>
    </div>
  </div>
</div>
