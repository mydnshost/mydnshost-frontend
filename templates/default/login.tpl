<div class="container">
{% block contenttop %}{% endblock %}
<form class="form-signin small" method="post">
  <h1 class="form-signin-heading">Please sign in</h1>
  <label for="inputEmail" class="sr-only">Email address</label>
  <input type="email" name="user" id="inputEmail" class="form-control" placeholder="Email address" required autofocus>
  <label for="inputPassword" class="sr-only">Password</label>
  <input type="password" name="pass" id="inputPassword" class="form-control" placeholder="Password" required>

  <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>

      <div class="float-left">
        <a href="{{ url('/forgotpassword') }}" class="">Forgot Password</a>
         -
        <a href="{{ url('/register') }}" class="">Register</a>
      </div>
</form>
</div>
