<div class="container">
{% block contenttop %}{% endblock %}
<form class="form-signin small" method="post">
  <h1 class="form-signin-heading">Please sign in</h1>
  <label for="inputEmail" class="visually-hidden">Email address</label>
  <input type="email" name="user" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
  <label for="inputPassword" class="visually-hidden">Password</label>
  <input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>

  <div class="d-grid">
    <button class="btn btn-lg btn-primary" type="submit">Sign in</button>
  </div>

      <div class="float-left">
        <a href="{{ url('/forgotpassword') }}" class="">Forgot Password</a>
         -
        <a href="{{ url('/register') }}" class="">Register</a>
      </div>
</form>
</div>
