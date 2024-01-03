import React, { useState, useEffect } from "react";
import axios from "axios";

type Props = {
  url: string;
};

export default function Quote(props : Props) {
  const [quote, setQuote] = useState({ text: "", attribution: "" });

  const updateQuote = () => {
    axios
      .get(props.url + ".json", {})
      .then(response => {
        const data = response.data;
        setQuote({ text: data.text_en, attribution: data.attribution });
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  useEffect(() => updateQuote(), []);

  return (
    <span onClick={() => updateQuote()} className="quotes">
      {quote.text} ({quote.attribution})
    </span>
  );
}
