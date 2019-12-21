import { createStore, createSubscriber, createHook } from "react-sweet-state";

const Store = createStore({
  initialState: {
    id: 0,
    first_name: "",
    last_name: "",
    theme: "",
    timezone: "UTC",
    language: "en",
    loading: false,
    loaded: false,
    error: null
  },
  actions: {
    fetch: token => ({ setState, getState }) => {
      if (!getState().loaded && !getState().loading) {
        setState({ loading: true });
        fetch("/infra/simple_profile.json", {
          method: "GET",
          credentials: "include",
          headers: {
            "Content-Type": "application/json",
            Accepts: "application/json",
            "X-CSRF-Token": token
          }
        })
          .then(response => {
            if (response.ok) {
              return response.json();
            } else {
              console.log("error");
              setState({ error: response });
            }
          })
          .then(data => {
            setState({
              id: data.id,
              first_name: data.first_name,
              last_name: data.last_name,
              theme: data.theme,
              timezone: data.timezone,
              language: data.language,
              loading: false
            });
          });
      }
    }
  },
  name: "user"
});

export const UserStoreSubscriber = createSubscriber(Store);
// or
export const useUserStore = createHook(Store);
