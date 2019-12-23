import i18n from "i18next";
import LngDetector from "i18next-browser-languagedetector";
import { initReactI18next } from "react-i18next";

import Fetch from "i18next-fetch-backend";

  i18n
    .use(LngDetector) //language detector
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
      defaultNS: "home",
      fallbackLng: "en",
      debug: false,
      initImmediate: false
    });

export default i18n;

