import React, { useState, Suspense, useEffect } from "react"
import PropTypes from "prop-types"
import IconButton from '@material-ui/core/IconButton';

// Icons
import HelpIcon from '@material-ui/icons/Help';

import { i18n } from './i18n'
import { useTranslation } from "react-i18next"

export default function HelpMenu(props) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [ t, i18n ] = useTranslation();


  return (
    <React.Fragment>

      <IconButton id='help-menu-button' color='secondary' aria-controls="help-menu" aria-haspopup="true" >
        <HelpIcon />
      </IconButton>
    </React.Fragment>
  );
}

HelpMenu.propTypes = {
  token: PropTypes.string.isRequired,
};
