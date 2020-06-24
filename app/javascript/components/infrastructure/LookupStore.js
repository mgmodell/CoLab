import { createStore, createSubscriber, createHook } from "react-sweet-state";

const Store = createStore({
  initialState: {
    lookups: {},
    lookupStatus: {}
  },
  actions: {
    set: (key, data ) => {
      const all = getState().lookups;
      const allStatus = getState().lookupStatus;

      all[ key ] = data;
      allStatus[ key ] = 'loaded';
      setState({
        lookups: all,
        lookupStatus: allStatus
      })

    },
    fetch: (lookupsNeededParam, lookupUrl, token) => ({ setState, getState }) => {
      const allStatus = getState().lookupStatus;
      const keys = Object.keys( allStatus )

      var lookupsNeeded = [];
      lookupsNeeded = lookupsNeeded.concat( lookupsNeededParam );

      lookupsNeeded.filter((lookup)=>{
        return !keys.includes( lookupsNeeded );
      })

      if (lookupsNeeded.length > 0 ) {
        //Let everyone know we're loading
        lookupsNeeded.forEach(element => {
          allStatus[ element ] = 'loading';
        });
        setState({
          lookupStatus: allStatus
        });

        const queryParams = lookupsNeeded.map((curVal) =>{
          return 'requested[]=' + encodeURI( curVal );
        })

        fetch(lookupUrl + '.json?' + queryParams.join('&'), {
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
            const tmpEndpoints = getState().lookups;
            //allStatus = getState().lookupStatus;

            if (undefined != data) {
              lookupsNeeded.forEach(element => {
                tmpEndpoints[ element ] = data[ element ];
                allStatus[ element ] = 'loading';
              });
            }
            setState({
              lookups: tmpEndpoints,
              lookupStatus: allStatus
            });
          });
      }
    }
  },
  name: "endpoints"
});

export const LookupStoreSubscriber = createSubscriber(Store);
// or
export const useLookupStore = createHook(Store);
