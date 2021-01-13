import React, { useState, Suspense, useEffect } from "react";
import { useDispatch } from 'react-redux';

import PropTypes from "prop-types";
import { BrowserRouter as Router, useHistory } from "react-router-dom";

import IconButton from "@material-ui/core/IconButton";
import Collapse from "@material-ui/core/Collapse";

import List from "@material-ui/core/List";
import Divider from "@material-ui/core/Divider";
import ListItem from "@material-ui/core/ListItem";
import ListItemIcon from "@material-ui/core/ListItemIcon";
import ListItemText from "@material-ui/core/ListItemText";
import SwipeableDrawer from "@material-ui/core/SwipeableDrawer";
// Icons
import ListIcon from "@material-ui/icons/List";
import HomeIcon from "@material-ui/icons/Home";
import AccountBoxIcon from "@material-ui/icons/AccountBox";
import InfoIcon from "@material-ui/icons/Info";
import ExitToAppIcon from "@material-ui/icons/ExitToApp";
import SettingsApplicationsIcon from "@material-ui/icons/SettingsApplications";
import MenuIcon from "@material-ui/icons/Menu";
import MultilineChartIcon from "@material-ui/icons/MultilineChart";
import ContactSupportIcon from "@material-ui/icons/ContactSupport";
import RateReviewIcon from "@material-ui/icons/RateReview";
import AccountBalanceIcon from "@material-ui/icons/AccountBalance";
import SchoolIcon from "@material-ui/icons/School";
import ExpandLess from "@material-ui/icons/ExpandLess";
import ExpandMore from "@material-ui/icons/ExpandMore";
import FindInPageIcon from "@material-ui/icons/FindInPage";
import DynamicFeedIcon from '@material-ui/icons/DynamicFeed';

import DiversityCheck from "./DiversityCheck";
import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import { useTypedSelector } from "./infrastructure/AppReducers";
import {signOut} from './infrastructure/AuthenticationActions'

export default function MainMenu(props) {
  const history = useHistory();
  const [menuOpen, setMenuOpen] = useState(false);
  const [adminOpen, setAdminOpen] = useState(false);
  const [t, i18n] = useTranslation();
  const isLoggedIn = useTypedSelector( state => { return state['login'].isLoggedIn }) 
  const user = useTypedSelector( state => { return state['login'].profile }) 
  const dispatch = useDispatch( );

  const toggleDrawer = event => {
    if (
      event &&
      event.type === "keydown" &&
      (event.key === "Tab" || event.key === "Shift")
    ) {
      return;
    }
    if (menuOpen) {
      setAdminOpen(false);
    }
    setMenuOpen(!menuOpen);
  };

  const navTo = url => {
    history.push(url);
    setMenuOpen(false);
  };


  const adminItems = user.is_instructor ? (
    <React.Fragment>
      <Divider />
      <ListItem
        button
        id="administration-menu"
        onClick={() => setAdminOpen(!adminOpen)}
      >
        <ListItemIcon>
          <SettingsApplicationsIcon fontSize="small" />
        </ListItemIcon>
        <ListItemText>
          {t("administration")} {adminOpen ? <ExpandLess /> : <ExpandMore />}
        </ListItemText>
      </ListItem>
      <Collapse in={adminOpen} timeout="auto" unmountOnExit>
        <Divider />
        <ListItem
          button
          id="courses-menu-item"
          onClick={()=> navTo('/admin/courses')}
        >
          <ListItemIcon>
            <SchoolIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>{t("courses_edit")}</ListItemText>
        </ListItem>
      <ListItem
        button
        id="admin_rpt-menu"
        onClick={() => navTo(props.reportingUrl)}
      >
        <ListItemIcon>
          <MultilineChartIcon fontSize="small" />
        </ListItemIcon>
        <ListItemText>{t("reporting")}</ListItemText>
      </ListItem>
      { user.is_admin
          ? (
            <React.Fragment>
        <ListItem
          button
          id="concepts-menu-item"
          onClick={() => navTo('/admin/concepts')}
        >
          <ListItemIcon>
            <DynamicFeedIcon fontSize='small' />
          </ListItemIcon>
          <ListItemText>{t("concepts_edit")}</ListItemText>
        </ListItem>
        <ListItem
          button
          id="schools-menu-item"
          onClick={() => navTo('/admin/schools')}
        >
          <ListItemIcon>
            <AccountBoxIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>{t("schools_edit")}</ListItemText>
        </ListItem>
        <ListItem
          button
          id="consent_forms-menu-item"
          onClick={() => navTo('/admin/consent_forms')}
        >
          <ListItemIcon>
            <FindInPageIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>{t("consent_forms_edit")}</ListItemText>
        </ListItem>
            </React.Fragment>

          ) : null

      }

        <Divider />
      </Collapse>
    </React.Fragment>
  ) : null;

  const basicOpts = isLoggedIn
    ? (
        <React.Fragment>

          <ListItem
            id="home-menu-item"
            button
            onClick={() => navTo('/')}
          >
            <ListItemIcon>
              <HomeIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("home.title")}</ListItemText>
          </ListItem>
          <ListItem
            id="profile-menu-item"
            button
            onClick={() => navTo('/profile')}
          >
            <ListItemIcon>
              <AccountBoxIcon />
            </ListItemIcon>
            <ListItemText>{t("profile")}</ListItemText>
          </ListItem>
          <DiversityCheck
            diversityScoreFor={props.diversityScoreFor}
          />
        </React.Fragment>

    )
    :
    (
          <ListItem
            id="home-menu-item"
            button
            onClick={() => navTo('/')}
          >
            <ListItemIcon>
              <HomeIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("home.title")}</ListItemText>
          </ListItem>

    )
    const logoutItem = isLoggedIn ? 
    (
          <ListItem
            id="logout-menu-item"
            button
            onClick={() => {
              dispatch( signOut( ))
              setMenuOpen(false);
            }}
          >
            <ListItemIcon>
              <ExitToAppIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("logout")}</ListItemText>
          </ListItem>

    ) : null;
    

  return (
    <React.Fragment>
      <IconButton
        id="main-menu-button"
        color="secondary"
        aria-controls="main-menu"
        aria-haspopup="true"
        onClick={toggleDrawer}
      >
        <MenuIcon />
      </IconButton>
      <SwipeableDrawer
        anchor="left"
        open={menuOpen}
        onClose={toggleDrawer}
        onOpen={toggleDrawer}
      >
        <List id="main-menu-list">
        {basicOpts}
          {adminItems}
          <Divider />
          <ListItem
            id="demo-menu-item"
            button
            onClick={() => navTo('/demo')}
          >
            <ListItemIcon>
              <RateReviewIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("titles.demonstration")}</ListItemText>
          </ListItem>
          <ListItem
            id="support-menu-item"
            button
            onClick={() => { window.location = "mailto:" + props.supportAddress }}
          >
            <ListItemIcon>
              <ContactSupportIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("support_menu")}</ListItemText>
          </ListItem>
          <ListItem
            id="about-menu-item"
            button
            onClick={() => {
              window.location.href = props.moreInfoUrl;
            }}
          >
            <ListItemIcon>
              <InfoIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("about")}</ListItemText>
          </ListItem>
          {logoutItem}
        </List>
      </SwipeableDrawer>
    </React.Fragment>
  );
}

MainMenu.propTypes = {
  diversityScoreFor: PropTypes.string.isRequired,
  reportingUrl: PropTypes.string,
  supportAddress: PropTypes.string.isRequired,
  moreInfoUrl: PropTypes.string.isRequired
};
