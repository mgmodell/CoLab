import i18n from "i18next";
import LngDetector from 'i18next-browser-languagedetector';
import Fetch from 'i18next-fetch-backend';

const backend_opts = {
  loadPath: '/infra/locales/{{lng}}/{{ns}}.json',
  // path to post missing resources
  addPath: 'locales/add/{{lng}}/{{ns}}',
  // define how to stringify the data when adding missing resources
  stringify: JSON.stringify,
}

export default function get_i18n( namespace ) {
  i18n
    .use(LngDetector) //language detector
    .use(Fetch)
    .init({
      backend: backend_opts,
      ns: namespace,
      defaultNS: 'home',
      fallbackLng: 'en',
      debug: false,
      initImmediate: false,
  
    });
  return i18n.getFixedT( i18n.language, namespace )
}

