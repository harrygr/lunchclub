import config from './config'
import axios from 'axios'

function loadScript(path, scriptLoadedCallback){
  const $element = document.createElement('script')
  $element.setAttribute("type","text/javascript")
  $element.setAttribute("src", path)

  if (typeof(scriptLoadedCallback) == 'function') {
    $element.onload = function() {
      return scriptLoadedCallback(true, path)
    }

    $element.onerror = function() {
      this.parentNode.removeChild(this)
      return scriptLoadedCallback(false, path)
    }
  }
  document.head.appendChild($element)
}

function initAuth(){
  gapi.load('auth2', () => {
    console.log('init script loaded', config.google_app_id)
    gapi.auth2.init({
      client_id: config.google_app_id
    }).then(renderButton)
  })
}

function onSuccess(googleUser) {
  const googleToken = googleUser.getAuthResponse().id_token
  axios.get(`/auth/google/callback?code=${googleToken}&provider=google`, {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }).then(response => console.log(response))
}

function onFailure(error) {
  console.log(error);
}

function signOut() {
  const auth2 = gapi.auth2.getAuthInstance()
  auth2.signOut().then(() => {
    console.log('User signed out.')
  })
}

function renderButton() {
  gapi.signin2.render('my-signin2', {
    'scope': 'profile email',
    'width': 240,
    'height': 50,
    'longtitle': true,
    'theme': 'dark',
    'onsuccess': onSuccess,
    'onfailure': onFailure
  });
}

function renderSignOutButton () {
  const $button = document.createElement('button')
  $button.innerText = 'Sign Out'
  $button.onclick = signOut

  document.body.appendChild($button)
}

loadScript('https://apis.google.com/js/platform.js', initAuth)
renderSignOutButton()