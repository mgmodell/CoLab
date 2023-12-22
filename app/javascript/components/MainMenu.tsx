import React, { useMemo, useRef, useState } from "react";
import { useDispatch } from "react-redux";

import { useNavigate } from "react-router-dom";

import { useTranslation } from "react-i18next";

import { useTypedSelector } from "./infrastructure/AppReducers";
import { signOut } from "./infrastructure/ContextSlice";
import { Sidebar } from "primereact/sidebar";
import { Button } from "primereact/button";
import { Menu } from "primereact/menu";
import { TieredMenu } from "primereact/tieredmenu";
import DiversityCheck from "./DiversityCheck";

type Props = {
  diversityScoreFor: string;
  reportingUrl: string;
  supportAddress: string;
  moreInfoUrl: string;
};

export default function MainMenu(props: Props) {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const [adminOpen, setAdminOpen] = useState(false);
  const [t, i18n] = useTranslation();
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const user = useTypedSelector(state => state.profile.user);

  const menuButton = useRef(null);

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
    setMenuOpen(false);
    navigate(url);
  };


  const buildMyMenu = () => {
    let builtMenu =
      [{
        label: t("home.title"),
        icon: "pi pi-fw pi-home",
        id: "home-menu-item",
        command: () => navTo("/home")
      }];

    console.log("user", user);
    console.log("isLoggedIn", isLoggedIn);
    if (isLoggedIn) {
      builtMenu.push({
        label: t("profile"),
        icon: "pi pi-fw pi-user",
        id: "profile-menu-item",
        command: () => navTo("/profile")
      });
      if (user.is_instructor || user.is_admin) {
        let adminItems =
          [
            {
              label: t("courses_edit"),
              icon: "pi pi-fw pi-book",
              id: "courses-menu-item",
              command: () => navTo("/admin/courses")
            },
            {
              label: t("reporting"),
              icon: "pi pi-fw pi-chart-bar",
              id: "reporting-menu-item",
              command: () => navTo("/admin/reporting"),
            },
            {
              label: t("rubrics_edit"),
              icon: "pi pi-fw pi-table",
              id: "rubrics-menu-item",
              command: () => navTo("/admin/rubrics"),
            },
          ];
        if (user.is_admin) {
          adminItems.push(
            {
              label: t("concepts_edit"),
              icon: "pi pi-fw pi-tags",
              id: "concepts-menu-item",
              command: () => navTo("/admin/concepts")
            },
            {
              label: t("schools_edit"),
              icon: "pi pi-fw pi-users",
              id: "schools-menu-item",
              command: () => navTo("/admin/schools")
            },
            {
              label: t("consent_forms_edit"),
              icon: "pi pi-fw pi-file",
              id: "consent-forms-menu-item",
              command: () => navTo("/admin/consent_forms")
            }

          );
        }
          builtMenu.push(
            {
              separator: true
            },

            {
              label: t("administration"),
              items: adminItems,
              id: "administration-menu",
            }
          );
      }
    }
    builtMenu.push(
      {
        separator: true
      },
      {
        template: (<DiversityCheck diversityScoreFor={props.diversityScoreFor} />),
      },
      {
        label: t('titles.demonstration'),
        icon: "pi pi-fw pi-play",
        id: "demo-menu-item",
        command: () => navTo("/demo")
      },
      {
        label: t("support_menu"),
        icon: "pi pi-fw pi-question-circle",
        id: "support-menu-item",
        command: () => {
          window.location.href = `mailto:${props.supportAddress}`;
        }
      },
      {
        label: t("about"),
        icon: "pi pi-fw pi-info-circle",
        id: "about-menu-item",
        command: () => {
          navTo(props.moreInfoUrl);
        }
      }
    )

    if (isLoggedIn) {
      builtMenu.push(
        {
          label: t("logout"),
          icon: "pi pi-fw pi-sign-out",
          id: "logout-menu-item",
          command: () => {
            dispatch(signOut());
            setMenuOpen(false);
          }
        }
      );
    }


    return builtMenu;
  }

  const genericOpts = [
    {
      label: t('titles.demonstration'),
      icon: "pi pi-fw pi-play",
      command: () => navTo("/demo")
    },
    {
      label: t("support_menu"),
      icon: "pi pi-fw pi-question-circle",
      command: () => {
        window.location.href = `mailto:${props.supportAddress}`;
      }
    },
    {
      label: t("about"),
      icon: "pi pi-fw pi-info-circle",
      commant: () => {
        navTo(props.moreInfoUrl);
      }
    }

  ]

  //  const menuItems = useMemo(() => {buildMyMenu()}, [user, isLoggedIn, i18n.language]);


  return (
    <React.Fragment>
      <Button
        id="main-menu-button"
        icon="pi pi-bars"
        //onClick={(event) => setMenuOpen(!menuOpen)}
        onClick={(event) => menuButton.current.toggle(event)}
        className="p-mr-2"
      />
      <TieredMenu
        popup
        ref={menuButton}
        appendTo={'self'}
        submenuIcon="pi pi-fw pi-cog"

        model={
          buildMyMenu()
        }
      />
      {/*
      <Menu
        popup
        appendTo={'self'}
        closeOnEscape
        ref={menuButton}
        model={
          buildMyMenu()
        }
      />
        */}

    </React.Fragment>
  );
}

