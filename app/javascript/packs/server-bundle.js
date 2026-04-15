import ReactOnRails from "react-on-rails";

import PageWrapper from "../components/PageWrapper";
import TimeSetter from "../components/TimeSetter";

// This is how react_on_rails can see the HelloWorld in the browser.
ReactOnRails.register({
  PageWrapper,
  TimeSetter
});
