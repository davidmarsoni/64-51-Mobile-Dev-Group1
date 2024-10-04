# valais_roll

A bike renting app for the Valais region in Switzerland.

## Getting Started

### Setup the google api key

1. copy the file `env.example` to `.env` and replace the value of `GOOGLE_MAPS_API_KEY` with your own google api key.

```env
GOOGLE_MAPS_API_KEY=your_google_api_key
```

2. create a file name `secrets.xml` in the `android/app/src/main/res/values/` directory and add the following content: 

```xml
<resources>
    <string name="google_api_key">your_google_maps_api_key</string>
</resources>
```
