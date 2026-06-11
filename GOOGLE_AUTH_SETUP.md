# Google Sign-In setup

The application exchanges a Google ID token for the existing Adidas Store JWT.
Flutter reads the Google OAuth Web Client ID from the .NET backend.

## Google Cloud

1. Open Google Cloud Console > APIs & Services.
2. Configure the OAuth consent screen.
3. Create an OAuth 2.0 Client ID with application type **Web application**.
4. Add these Authorized JavaScript origins:
   - `http://localhost`
   - `http://localhost:52095`
5. Copy the Client ID ending in `.apps.googleusercontent.com`.

## Backend

Run:

```powershell
backend\AdidasShoesStore.Api\configure-google-auth.ps1
```

Paste the Web Client ID when prompted. It is stored in .NET user-secrets.

## Flutter Web

Windows must have Developer Mode enabled because Flutter plugins use symlinks.

Run:

```powershell
cd fontend
.\run-web.ps1
```

The fixed port must match an Authorized JavaScript origin in Google Cloud.

## Android

Create an Android OAuth client in the same Google Cloud project using the app
package name and SHA-1 certificate. The app reads the backend/server Web Client
ID from the API.

## iOS

Create an iOS OAuth client and pass it separately:

```powershell
flutter run --dart-define=GOOGLE_IOS_CLIENT_ID=YOUR_IOS_CLIENT_ID
```
