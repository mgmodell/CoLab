import { createStore, createSubscriber, createHook } from "react-sweet-state";

const Store = createStore({
  initialState: {
    endpoints: {},
    endpointStatus: {}
  },
  actions: {
    fetch: (unit, endpointUrl, token) => ({ setState, getState }) => {
      var allStatus = getState().endpointStatus;

      if (null == allStatus[unit]) {
        //Let everyone know we're loading
        allStatus[unit] = "loading";
        setState({
          endpointStatus: allStatus
        });

        fetch(endpointUrl + unit + ".json", {
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
              setState({ error: response });
            }
          })
          .then(data => {
            const tmpEndpoints = getState().endpoints;
            allStatus = getState().endpointStatus;

            if (undefined != data) {
              tmpEndpoints[unit] = data;
              allStatus[unit] = "loaded";
            }
            setState({
              endpoints: tmpEndpoints,
              endpointStatus: allStatus
            });
          });
      }
    }
  },
  name: "endpoints"
});

export const EndpointStoreSubscriber = createSubscriber(Store);
// or
export const useEndpointStore = createHook(Store);
