import {
  Elm
} from '../LoginPage'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.createElement('div')

  const props = document.getElementById("login_props");
  const flags = JSON.parse(props.getAttribute("data-props"));

  const csrf = document.getElementsByName("csrf-token")[0];
  const csrfToken = csrf.getAttribute("content");
  flags['urls']['csrfToken'] = csrfToken;

  document.body.appendChild(target)
  Elm.LoginPage.init({
    node: target,
    flags: flags
  })
})