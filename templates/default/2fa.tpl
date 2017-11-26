<div class="container">
{% block contenttop %}{% endblock %}
<form class="form-signin small" method="post" action="{{ url('/login') }}">
  <h1 class="form-signin-heading">2FA Required</h1>
  <label for="input2FAKey" class="sr-only">2FA Code</label>
  <input type="text" name="2fakey" id="input2FAKey" class="form-control" placeholder="2FA Code">

  <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
</form>
</div>
