/*
 * This code was largely adapted from j-toker.
 * https://github.com/lynndylanhurley/j-toker
 */
import axios from "axios";
import { Cookies } from "react-cookie-consent";

import {
  fetchProfile,
  setRetrievedProfile,
  clearProfile
} from "./ProfileSlice";
import { addMessage, Priorities } from "./StatusSlice";
import i18n from "./i18n";
import { createAsyncThunk, createSlice } from "@reduxjs/toolkit";

const category = "devise";
const t = i18n.getFixedT(null, category);
const cookiesEnabled = navigator.cookieEnabled;

const CONFIG = {
  SAVED_CREDS_KEY: "colab_authHeaders",
  API_URL: "/auth",
  SIGN_OUT_PATH: "/auth/sign_out",
  EMAIL_SIGNIN_PATH: "/auth/sign_in",
  EMAIL_REGISTRATION_PATH: "/auth",

  //Cooke paths
  cookieExpiry: 14,
  cookiePath: "/",

  tokenFormat: {
    "access-token": "{{ access-token }}",
    "token-type": "Bearer",
    client: "{{ client }}",
    expiry: "{{ expiry }}",
    uid: "{{ uid }}"
  },

  parseExpiry: function(headers) {
    // convert from ruby time (seconds) to js time (millis)
    return parseInt(headers["expiry"], 10) * 1000 || null;
  },

  /**
   * This function is used as an axios send interceptor.
   *
   * @param config what has already been configured to be sent.
   * @returns
   */
  appendAuthHeaders: function(config: any) {
    const storedHeaders = CONFIG.retrieveData(CONFIG.SAVED_CREDS_KEY);

    if (CONFIG.isApiRequest(config.url) && storedHeaders) {
      // bust IE cache
      config["headers"]["If-Modified-Since"] = "Mon, 26 Jul 1997 05:00:00 GMT";

      // set header for each key in `tokenFormat` config
      for (var key in CONFIG.tokenFormat) {
        config["headers"][key] = storedHeaders[key];
      }
    }
    return config;
  },

  /**
   * This function is used as an axios receive interceptor.
   *
   * @param response
   * @returns
   */
  storeRetrievedCredentials: function(response: any) {
    if (CONFIG.isApiRequest(response["config"]["url"])) {
      let newHeaders = {};
      let blankHeaders = true;

      for (var key in CONFIG.tokenFormat) {
        newHeaders[key] = response["headers"][key];
        if (newHeaders[key]) {
          blankHeaders = false;
        }
      }

      if (!blankHeaders) {
        CONFIG.persistData(CONFIG.SAVED_CREDS_KEY, newHeaders);
      }
    }
    return response;
  },

  isApiRequest: function(url: string) {
    //Maybe we'll do something meaningful here later
    return true;
  },

  retrieveData(key) {
    var val = null;

    if (cookiesEnabled) {
      val = Cookies.get(key);
    } else {
      val = localStorage.getItem(key);
    }

    // if value is a simple string, the parser will fail. in that case, simply
    // unescape the quotes and return the string.
    try {
      // return parsed json response
      return JSON.parse(val);
    } catch (err) {
      // unescape quotes
      return val && val.replace(/("|')/g, "");
    }
  },

  persistData: function(key: string, val) {
    let data = JSON.stringify(val);

    if (cookiesEnabled) {
      Cookies.set(key, data, {
        expires: CONFIG.cookieExpiry,
        path: CONFIG.cookiePath
      });
    } else {
      localStorage.setItem(key, data);
    }
  },

  deleteData: function(key: string) {
    if (cookiesEnabled) {
      Cookies.remove(key);
    }
    localStorage.removeItem(key);
  },

  retrieveResources: function(dispatch: Function, getState: Function) {
    const endPointsUrl = getState()["context"]["config"]["endpoint_url"];

    return axios
      .get(endPointsUrl + ".json", { withCredentials: true })
      .then(resp => {
        if (resp["data"]["logged_in"]) {
          dispatch(
            setLoggedIn({
              lookups: resp["data"]["lookups"],
              endpoints: resp["data"]["endpoints"]
            })
          );
          dispatch(setRetrievedProfile(resp["data"]["profile"]["user"]));
          //dispatch( fetchProfile( ) );
        } else {
          dispatch(setLoggedOut({}));
          dispatch(setLookups(resp["data"]["lookups"]));
          dispatch(setEndPoints(resp["data"]["endpoints"]));
          dispatch(clearProfile({}));
          CONFIG.deleteData(CONFIG.SAVED_CREDS_KEY);
        }
      });
  }
};

export interface ContextRootState {
  status: {
    initialised: boolean;
    loggingIn: boolean;
    loggedIn: boolean;
    endpointsLoaded: boolean;
    lookupsLoaded: boolean;
  };
  config: {
    localStorage?: boolean;
    endpoint_url?: string;
    debug: boolean;
  };
  lookups: {
    [key: string]: {
      [key: string]: Object;
    };
  };
  endpoints: {
    [key: string]: {
      [key: string]: string;
    };
  };
}

const initialState: ContextRootState = {
  status: {
    initialised: false,
    loggingIn: false,
    loggedIn: false,
    endpointsLoaded: false,
    lookupsLoaded: false
  },
  config: {
    localStorage: null,
    endpoint_url: null,
    debug: false,
  },
  lookups: {
    behaviors: {},
    countries: {},
    languages: {},
    cip_codes: {},
    genders: {},
    themes: {},
    timezones: {},
    schools: {}
  },
  endpoints: {}
};

const contextSlice = createSlice({
  name: "context",
  initialState: initialState,
  reducers: {
    setInitialised(state, action) {
      state.status.initialised = true;
    },
    setEndPointUrl(state, action) {
      state.config.endpoint_url = action.payload;
    },
    setLoggingIn(state, action) {
      state.status.loggingIn = true;
      state.status.loggedIn = false;
    },
    setLoggedIn: {
      reducer(state, action) {
        state.status.loggingIn = false;
        state.status.loggedIn = true;
        state.lookups = action.payload.lookups;
        state.endpoints = action.payload.endpoints;
        state.status.endpointsLoaded = true;
        state.status.lookupsLoaded = true;
      },
      prepare(payload: {
        lookups: object;
        endpoints: object;
      }): {
        payload: { lookups: object; endpoints: object };
        meta: any;
        error: any;
      } {
        return {
          payload: {
            lookups: payload.lookups,
            endpoints: payload.endpoints
          },
          meta: null,
          error: null
        };
      }
    },
    setLoginFailed(state, action) {
      state.status.loggingIn = false;
    },
    setLoggedOut(state, action) {
      state.status.loggingIn = false;
      state.status.loggedIn = false;
      state.lookups = {};
      state.endpoints = {};
      state.status.endpointsLoaded = true;
      state.status.initialised = false;
    },
    setEndPoints(state, action) {
      state.endpoints = action.payload;
      state.status.endpointsLoaded = true;
    },
    setLookups(state, action) {
      state.lookups = action.payload;
      state.status.lookupsLoaded = true;
    },
    setDebug(state, action) {
      state.config.debug = action.payload;
    }
  }
});

export const getContext = createAsyncThunk(
  "context/getContext",
  async (endPointsUrl: string, thunkAPI) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    dispatch(setEndPointUrl(endPointsUrl));

    dispatch(setLoggingIn({}));
    axios.interceptors.request.use(CONFIG.appendAuthHeaders);
    axios.interceptors.response.use(CONFIG.storeRetrievedCredentials);

    //Add ProcessLocationBar later

    //Pull the resources
    CONFIG.retrieveResources(dispatch, getState).then(() => {
      dispatch(setInitialised({}));
    });
  }
);

//TODO: Inefficient, but should be OK for now
export const refreshSchools = createAsyncThunk(
  "context/refreshSchools",
  async (_, thunkAPI) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;
    CONFIG.retrieveResources(dispatch, getState);
  }
);

export const emailSignIn = createAsyncThunk(
  "context/emailSignIn",
  async (params, thunkAPI) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    dispatch(setLoggingIn({}));

    if (!params.email || !params.password) {
      dispatch(setLoginFailed());
    } else {
      return axios
        .post(CONFIG.EMAIL_SIGNIN_PATH, {
          email: params.email,
          password: params.password
        })
        .then(resp => {
          //TODO resp contains the full user info

          dispatch(
            addMessage(t("sessions.signed_in"), new Date(), Priorities.INFO)
          );
          CONFIG.retrieveResources(dispatch, getState).then(response => {
            dispatch(fetchProfile());
          });
        })
        .catch(error => {
          //Handle a failed login properly
          console.log("error", error);
        });
    }
  }
);

//Untested
export const emailSignUp = createAsyncThunk(
  "context/emailSignUp",
  async (params, thunkAPI) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    dispatch(setLoggingIn({}));

    if (!params.email) {
      dispatch(setLoginFailed());
    } else {
      return axios
        .post(CONFIG.EMAIL_REGISTRATION_PATH + ".json", {
          email: params.email,
          first_name: params.firstName,
          last_name: params.lastName
        })
        .then(resp => {
          const data = resp.data;
          const priority = data.error ? Priorities.ERROR : Priorities.INFO;
          dispatch(addMessage(t(data.message), new Date(), priority));
        })
        .catch(error => {
          console.log("error", error);
        });
    }
  }
);

export const oAuthSignIn = createAsyncThunk(
  "context/oAuthSignIn",
  async (token: string, thunkAPI) => {
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;
    dispatch(setLoggingIn({}));

    const url = getState().context.endpoints["home"].oauthValidate + ".json";

    axios
      .post(url, {
        id_token: token
      })
      .then(resp => {
        //TODO resp contains the full user info
        dispatch(addMessage(resp.data["message"], new Date(), Priorities.INFO));
        CONFIG.retrieveResources(dispatch, getState).then(response => {
          dispatch(fetchProfile());
        });
      })
      .catch(error => {
        //Handle a failed login properly
        console.log("error", error);
      });
  }
);

export const signOut = createAsyncThunk(
  "context/signOut",
  async (_, thunkAPI) => {
    var count = 0;
    const dispatch = thunkAPI.dispatch;
    const getState = thunkAPI.getState;

    if (getState().context.status.loggedIn) {
      return axios.delete(CONFIG.SIGN_OUT_PATH, {}).then(resp => {
        var counter = 0;
        dispatch(clearProfile({}));
        dispatch(setLoggedOut({}));
        CONFIG.deleteData(CONFIG.SAVED_CREDS_KEY);
        CONFIG.retrieveResources(dispatch, getState).then(() => {
          dispatch(setInitialised({}));
        });
      });
    }
  }
);

const { actions, reducer } = contextSlice;
export const {
  setEndPoints,
  setDebug,
  setEndPointUrl,
  setLoggedIn,
  setLoggedOut,
  setLoggingIn,
  setLookups,
  setInitialised,
  setLoginFailed
} = actions;
export default reducer;
