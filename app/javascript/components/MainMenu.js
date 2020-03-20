import React, { useState, Suspense, useEffect } from "react"
import PropTypes from "prop-types"
import IconButton from '@material-ui/core/IconButton';
import Link from '@material-ui/core/Link'
import Collapse from '@material-ui/core/Collapse'

import List from '@material-ui/core/List';
import Divider from '@material-ui/core/Divider';
import ListItem from '@material-ui/core/ListItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import SwipeableDrawer from '@material-ui/core/SwipeableDrawer'
// Icons
import ListIcon from '@material-ui/icons/List';
import HomeIcon from '@material-ui/icons/Home';
import AccountBoxIcon from '@material-ui/icons/AccountBox';
import InfoIcon from '@material-ui/icons/Info';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import SettingsApplicationsIcon from '@material-ui/icons/SettingsApplications';
import MenuIcon from '@material-ui/icons/Menu';
import MultilineChartIcon from '@material-ui/icons/MultilineChart';
import ContactSupportIcon from '@material-ui/icons/ContactSupport';
import RateReviewIcon from '@material-ui/icons/RateReview';
import AccountBalanceIcon from '@material-ui/icons/AccountBalance';
import SchoolIcon from '@material-ui/icons/School';
import ExpandLess from '@material-ui/icons/ExpandLess'
import ExpandMore from '@material-ui/icons/ExpandMore'

import DiversityCheck from './DiversityCheck'
import { useUserStore } from "./UserStore"
import { i18n } from './i18n'
import { useTranslation } from "react-i18next"

export default function MainMenu(props) {
  const [menuOpen, setMenuOpen] = useState(false)
  const [adminOpen, setAdminOpen] = useState(false)
  const [ t, i18n ] = useTranslation();
  const [user, userActions] = useUserStore();

  const toggleDrawer = event => {
    if (event && event.type === 'keydown' && (event.key === 'Tab' || event.key === 'Shift')) {
      return
    }
    if (menuOpen) {
      setAdminOpen(false);
    }
    setMenuOpen(!menuOpen)
  };

  const navTo = (url) => {
    window.location = url;
    return;
  }

  useEffect(() => {
    if (!user.loaded) {
      userActions.fetch(props.token);
    }
  }, []);

  const adminItems = user.is_instructor ?
    (
      <React.Fragment>
        <Divider />
        <ListItem button id='administration-menu' onClick={() => setAdminOpen(!adminOpen)}>
          <ListItemIcon>
            <SettingsApplicationsIcon fontSize='small' />
          </ListItemIcon>
          <ListItemText >
            {t('administration')} {adminOpen ? <ExpandLess /> : <ExpandMore />}
          </ListItemText>
        </ListItem>
        <Collapse in={adminOpen} timeout="auto" unmountOnExit>
          <Divider />
          <ListItem button id='courses-menu-item' onClick={navTo.bind(null, props.coursesUrl)}>
            <ListItemIcon>
              <SchoolIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('courses_edit')}
            </ListItemText>
          </ListItem>
          <ListItem button id='schools-menu-item' onClick={() => navTo(props.schoolsUrl)}>
            <ListItemIcon>
              <AccountBoxIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('schools_edit')}
            </ListItemText>
          </ListItem>

          <Divider />
        </Collapse>
        <ListItem button id='admin_rpt-menu' onClick={() => navTo(props.reportingUrl)}>
          <ListItemIcon>
            <MultilineChartIcon fontSize='small' />
          </ListItemIcon>
          <ListItemText>
            {t('reporting')}
          </ListItemText>
        </ListItem>

      </React.Fragment>
    ) : null;
  return (
    <React.Fragment>

      <IconButton id='main-menu-button' color='secondary' aria-controls="main-menu" aria-haspopup="true" onClick={toggleDrawer}>
        <MenuIcon />
      </IconButton>
      <SwipeableDrawer
        anchor="left"
        open={menuOpen}
        onClose={toggleDrawer}
        onOpen={toggleDrawer}
      >
        <List
          id='main-menu-list'
        >
          <ListItem id='home-menu-item' button onClick={() => navTo(props.homeUrl)}>
            <ListItemIcon>
              <HomeIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('home.title')}
            </ListItemText>
          </ListItem>
          <ListItem id='profile-menu-item' button onClick={() => navTo(props.profileUrl)}>
            <ListItemIcon>
              <AccountBoxIcon />
            </ListItemIcon>
            <ListItemText>
              {t('profile')}
            </ListItemText>
          </ListItem>
          <DiversityCheck token={props.token} diversityScoreFor={props.diversityScoreFor} />
          {adminItems}
          <ListItem id='support-menu-item' button onClick={() => navTo('mailto:' + props.supportAddress)}>
            <ListItemIcon>
              <ContactSupportIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('support_menu')}
            </ListItemText>
          </ListItem>
          <Divider />
          <ListItem id='about-menu-item' button onClick={() => navTo(props.moreInfoUrl)}>
            <ListItemIcon>
              <InfoIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('about')}
            </ListItemText>
          </ListItem>
          <ListItem id='demo-menu-item' button onClick={() => navTo(props.demoUrl)}>
            <ListItemIcon>
              <RateReviewIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('titles.demonstration')}
            </ListItemText>
          </ListItem>
          <ListItem id='logout-menu-item' button onClick={() => navTo(props.logoutUrl)}>
            <ListItemIcon>
              <ExitToAppIcon fontSize='small' />
            </ListItemIcon>
            <ListItemText>
              {t('logout')}
            </ListItemText>
          </ListItem>

        </List>

      </SwipeableDrawer>
    </React.Fragment>
  );
}

MainMenu.propTypes = {
  token: PropTypes.string.isRequired,
  homeUrl: PropTypes.string.isRequired,
  profileUrl: PropTypes.string.isRequired,
  diversityScoreFor: PropTypes.string.isRequired,
  adminUrl: PropTypes.string,
  coursesUrl: PropTypes.string,
  schoolsUrl: PropTypes.string,
  conceptsUrl: PropTypes.string,
  reportingUrl: PropTypes.string,
  demoUrl: PropTypes.string.isRequired,
  logoutUrl: PropTypes.string.isRequired,
  supportAddress: PropTypes.string.isRequired,
  moreInfoUrl: PropTypes.string.isRequired
};
