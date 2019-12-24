import i18n from "i18next";
import LngDetector from "i18next-browser-languagedetector";
import { initReactI18next } from "react-i18next";

import Cache from 'i18next-localstorage-cache';
import Fetch from "i18next-fetch-backend";

  i18n
    .use(LngDetector) //language detector
    .use(Cache)
    .use(Fetch)
    .use(initReactI18next)
    .init({
      backend: {
        loadPath: "/infra/locales/{{ns}}.json",
        // path to post missing resources
        addPath: "locales/add/{{ns}}",
        // define how to stringify the data when adding missing resources
        stringify: JSON.stringify
      },
      cache: {
        enabled: true,
        prefix: 'i18next_translations_',
        expirationTime: 24*60*60*1000 //one day
      },
      defaultNS: "base",
      fallbackLng: "en",
      initImmediate: true,
      ns: 'base',
      debug: true
    });

export default i18n;

