import React, { useState, useEffect } from "react";
import PropTypes from "prop-types";

export default function Quote(props) {
  const [quote, setQuote] = useState({ text: "", attribution: "" });

  const updateQuote = () => {
    fetch(props.url, {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
        }
      })
      .then(data => {
        setQuote({ text: data.text_en, attribution: data.attribution });
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
  url: PropTypes.string,
  token: PropTypes.string
};
