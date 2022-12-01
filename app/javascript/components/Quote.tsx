import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";
import axios from "axios";

export default function Quote(props) {
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
Quote.propTypes = {
  url: PropTypes.string
};
