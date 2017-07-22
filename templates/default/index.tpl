<div class="container">
  {% block contenttop %}{% endblock %}
  <div class="row jumbotron">
    <div class="col">
      <h1>Welcome!</h1>
      <p class="lead">
        Welcome to {{sitename}}.
      </p>
      <p class="lead">
        Easy DNS Hosting with a comprehensive API.
      </p>
    </div>
    <div class="col-5">
      <form class="form-signin" method="post" action="{{ url('/login') }}">
        <h1 class="form-signin-heading">Please sign in</h1>
        <label for="inputEmail" class="sr-only">Email address</label>
        <input type="email" name="user" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
        <label for="inputPassword" class="sr-only">Password</label>
        <input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>
        <label for="input2FAKey" class="sr-only">2FA Code (If required)</label>
        <input type="text" name="2fakey" id="input2FAKey" class="form-control" placeholder="2FA Code (If required)">

        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
        <div class="float-left">
          <a href="{{ url('/forgotpassword') }}" class="">Forgot Password</a>
           -
          <a href="{{ url('/register') }}" class="">Register</a>
        </div>
      </form>
    </div>
  </div>


  <div class="row">
    <div class="col">
      <h2>Unlimited everything</h2>
      <p>Host all your domains, with no limits to the amount of domains, records or queries.</p>
      <p><a class="btn btn-primary" href="{{ url('/register') }}" role="button">Get started &raquo;</a></p>
    </div>

    <div class="col">
      <h2>Full API Access</h2>
      <p>Everything can be accessed and modified via a comprehensive JSON API, with full documentation and examples.</p>
      <p><a class="btn btn-primary" href="{{ apiurl('/1.0/docs/') }}" role="button">API Documentation &raquo;</a></p>
    </div>
  </div>
  <br>
  <div class="row">
    <div class="col">
      <h2>Open Source</h2>
      <p>The code behind the site is available on github if you want to run your own instance or contribute changes/improvements.</p>
      <p><a class="btn btn-primary" href="https://github.com/mydnshost" role="button">Github &raquo;</a></p>
    </div>

    <div class="col">
      <h2>Sharing is caring</h2>
      <p>Easily grant other users access to a domain, without giving them access to all of your other domains.</p>
    </div>
  </div>
</div>
