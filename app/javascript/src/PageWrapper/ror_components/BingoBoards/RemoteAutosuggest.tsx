import React, { useState } from "react";

import axios from "axios";
import { AutoComplete } from "primereact/autocomplete";

type Props = {
  inputLabel: string | null;
  itemId: number;
  enteredValue: string | null;
  controlId: string | null;
  dataUrl: string;
  rootPath: string | null;
  setFunction: (number, string) => void;
};

export default function RemoteAutosuggest(props: Props) {
  const [items, setItems] = useState([]);

  const getData = value => {
    if (value.length > 2) {
      const url =
        props.rootPath === undefined
          ? `${props.dataUrl}.json?search_string=${value}`
          : `/${props.rootPath}${props.dataUrl}.json?search_string=${value}`;

      axios
        .get(url, {})
        .then(response => {
          const data = response.data;
          let suggestions = [];
          data.map(item => {
            suggestions.push(item.name);
          });
          setItems(suggestions);
        })
        .catch(error => {
          console.log("error", error);
          return [{ id: -1, name: "no data" }];
        });
    }
  };

  return (
    <AutoComplete
      id={props.controlId}
      value={props.enteredValue}
      onChange={e => {
        props.setFunction(props.itemId, e.value);
      }}
      completeMethod={e => {
        getData(e.query);
      }}
      suggestions={items}
    />
  );
}
