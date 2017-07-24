# demo-ocsigen-contacts
Demo app for accessing contacts from an Eliom mobile app
## how to compile
```
make db-init
make db-start
make db-create
make db-schema
make test.byte
```

## Install on your android/iOS device
```
make run-android
# or
# make run-ios # to be tested
```

## Install the necessary plugins  
Add in your `mobile/config.xml.in` file :

```xml

  <plugin name="cordova-plugin-contacts" spec="https://github.com/apache/cordova-plugin-contacts.git" />
  <plugin name="cordova-plugin-calendar" spec="https://github.com/EddyVerbruggen/Calendar-PhoneGap-Plugin.git" />
  <plugin name="cordova-plugin-intent" spec="https://github.com/krzischp/cordova-plugin-intent.git"/>
  <platform name="android">
  <config-file target="AndroidManifest.xml" parent="./application/activity/[@android:name='MainActivity']"
               xmlns:android="http://schemas.android.com/apk/res/android">
       <intent-filter>
         <action android:name="android.intent.action.SEND"/>  
         <category android:name="android.intent.category.DEFAULT"/>  
         <data android:mimeType="text/plain"/>  
       </intent-filter>
       <intent-filter>
         <action android:name="android.intent.action.SEND" />  
         <action android:name="android.intent.action.SEND_MULTIPLE" />  
         <category android:name="android.intent.category.DEFAULT" />  
         <data android:mimeType="image/*" />  
         <data android:mimeType="video/*" />  
       </intent-filter>
     </config-file>
  </platform>
```
  
## Install the ocaml bindings
```
opam -y pin add ocaml-cordova-plugin-intent.dev https://github.com/krzischp/ocaml-cordova-plugin-intent.git
opam -y pin add ocaml-cordova-plugin-contacts.dev https://github.com/apache/cordova-plugin-contacts.git
opam -y pin add cordova-ocaml-plugin-calendar.dev https://github.com/krzischp/cordova-ocaml-plugin-calendar.git
```

And add in your `Makefile.options` to `CLIENT_PACKAGES` value:

```
gen_js_api ... cordova-plugin-contacts cordova-plugin-calendar cordova-plugin-intent
```


## How does it work?  
This project contains demos for:

- the contacts selection in your contacts directory
- the exportation of an event in a given format to your default calendar
- the use of intents to share files from/to Ocsigen start





