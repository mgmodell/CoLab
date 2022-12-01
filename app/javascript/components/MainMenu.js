import React, { useState, useEffect } from "react";
import { useDispatch } from "react-redux";

import PropTypes from "prop-types";
import { useNavigate } from "react-router-dom";

import IconButton from "@mui/material/IconButton";
import Collapse from "@mui/material/Collapse";

import List from "@mui/material/List";
import Divider from "@mui/material/Divider";
import ListItem from "@mui/material/ListItem";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
import SwipeableDrawer from "@mui/material/SwipeableDrawer";
// Icons
import HomeIcon from "@mui/icons-material/Home";
import AccountBoxIcon from "@mui/icons-material/AccountBox";
import InfoIcon from "@mui/icons-material/Info";
import ExitToAppIcon from "@mui/icons-material/ExitToApp";
import SettingsApplicationsIcon from "@mui/icons-material/SettingsApplications";
import MenuIcon from "@mui/icons-material/Menu";
import MultilineChartIcon from "@mui/icons-material/MultilineChart";
import ContactSupportIcon from "@mui/icons-material/ContactSupport";
import RateReviewIcon from "@mui/icons-material/RateReview";
import SchoolIcon from "@mui/icons-material/School";
import ExpandLess from "@mui/icons-material/ExpandLess";
import ExpandMore from "@mui/icons-material/ExpandMore";
import FindInPageIcon from "@mui/icons-material/FindInPage";
import DynamicFeedIcon from "@mui/icons-material/DynamicFeed";

import DiversityCheck from "./DiversityCheck";
import { useTranslation } from "react-i18next";

import { useTypedSelector } from "./infrastructure/AppReducers";
import { signOut } from "./infrastructure/ContextSlice";

export default function MainMenu(props) {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const [adminOpen, setAdminOpen] = useState(false);
  const [t, i18n] = useTranslation();
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const user = useTypedSelector(state => state.profile.user);

  const dispatch = useDispatch();

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
    navigate(url);
    setMenuOpen(false);
  };

  useEffect(() => {
    if (!isLoggedIn) {
      navTo("/");
    }
  }, [isLoggedIn]);

  const adminItems =
    isLoggedIn && (user.is_instructor || user.is_admin) ? (
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
            onClick={() => navTo("/admin/courses")}
          >
            <ListItemIcon>
              <SchoolIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("courses_edit")}</ListItemText>
          </ListItem>
          <ListItem
            button
            id="admin_rpt-menu"
            onClick={() => navTo("/admin/reporting")}
          >
            <ListItemIcon>
              <MultilineChartIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("reporting")}</ListItemText>
          </ListItem>
          {user.is_admin ? (
            <React.Fragment>
              <ListItem
                button
                id="concepts-menu-item"
                onClick={() => navTo("/admin/concepts")}
              >
                <ListItemIcon>
                  <DynamicFeedIcon fontSize="small" />
                </ListItemIcon>
                <ListItemText>{t("concepts_edit")}</ListItemText>
              </ListItem>
              <ListItem
                button
                id="schools-menu-item"
                onClick={() => navTo("/admin/schools")}
              >
                <ListItemIcon>
                  <AccountBoxIcon fontSize="small" />
                </ListItemIcon>
                <ListItemText>{t("schools_edit")}</ListItemText>
              </ListItem>
              <ListItem
                button
                id="consent_forms-menu-item"
                onClick={() => navTo("/admin/consent_forms")}
              >
                <ListItemIcon>
                  <FindInPageIcon fontSize="small" />
                </ListItemIcon>
                <ListItemText>{t("consent_forms_edit")}</ListItemText>
              </ListItem>
            </React.Fragment>
          ) : null}

          <Divider />
        </Collapse>
      </React.Fragment>
    ) : null;

  const basicOpts = isLoggedIn ? (
    <React.Fragment>
      <ListItem id="home-menu-item" button onClick={() => navTo("/")}>
        <ListItemIcon>
          <HomeIcon fontSize="small" />
        </ListItemIcon>
        <ListItemText>{t("home.title")}</ListItemText>
      </ListItem>
      <ListItem id="profile-menu-item" button onClick={() => navTo("/profile")}>
        <ListItemIcon>
          <AccountBoxIcon />
        </ListItemIcon>
        <ListItemText>{t("profile")}</ListItemText>
      </ListItem>
      <DiversityCheck diversityScoreFor={props.diversityScoreFor} />
    </React.Fragment>
  ) : (
    <ListItem id="home-menu-item" button onClick={() => navTo("/")}>
      <ListItemIcon>
        <HomeIcon fontSize="small" />
      </ListItemIcon>
      <ListItemText>{t("home.title")}</ListItemText>
    </ListItem>
  );
  const logoutItem = isLoggedIn ? (
    <ListItem
      id="logout-menu-item"
      button
      onClick={() => {
        dispatch(signOut());
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
        size="large"
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
          <ListItem id="demo-menu-item" button onClick={() => navTo("/demo")}>
            <ListItemIcon>
              <RateReviewIcon fontSize="small" />
            </ListItemIcon>
            <ListItemText>{t("titles.demonstration")}</ListItemText>
          </ListItem>
          <ListItem
            id="support-menu-item"
            button
            onClick={() => {
              window.location = "mailto:" + props.supportAddress;
            }}
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
