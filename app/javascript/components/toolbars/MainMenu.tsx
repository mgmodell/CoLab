import React, { useRef, useState } from "react";
import { useDispatch } from "react-redux";

import { useNavigate } from "react-router-dom";

import { useTranslation } from "react-i18next";

import { useTypedSelector } from "../infrastructure/AppReducers";
import { signOut } from "../infrastructure/ContextSlice";
import { Sidebar } from "primereact/sidebar";
import { Button } from "primereact/button";
import { Menu } from "primereact/menu";
import DiversityCheck from "../DiversityCheck";
import Logo from "../Logo";

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
  const [aboutOpen, setAboutOpen] = useState(false);
  const [t, i18n] = useTranslation();
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);
  const user = useTypedSelector(state => state.profile.user);

  const working = useTypedSelector(state => {
    let accum = 0;
    if (undefined === props.identifier) {
      accum = state.status.tasks[props.identifier];
    } else {
      accum = Number(
        Object.values(state.status.tasks).reduce((accum, nextVal) => {
          return Number(accum) + Number(nextVal);
        }, accum)
      );
    }
    return accum > 0;
  });

  const menuButton = useRef(null);
  enum MENUS {
    ADMIN = "admin",
    ABOUT = "about"
  };

  const toggleMenu = (menu: MENUS) => {
    switch (menu) {
      case MENUS.ADMIN:
        setAdminOpen(!adminOpen);
        setAboutOpen(false);
        break;
      case MENUS.ABOUT:
        setAboutOpen(!aboutOpen);
        setAdminOpen(false);
        break;
      default:
        setAboutOpen(false);
        setAdminOpen(false);
        break;
    }
  }

  const dispatch = useDispatch();


  const navTo = url => {
    setMenuOpen(false);
    navigate(url);
  };

  const buildMyMenu = () => {
    let builtMenu = [
      {
        label: t("home.title"),
        icon: "pi pi-fw pi-home",
        id: "home-menu-item",
        command: () => navTo("/home")
      }
    ];

    if (isLoggedIn) {
      builtMenu.push({
        label: t("profile"),
        icon: "pi pi-fw pi-user",
        id: "profile-menu-item",
        command: () => navTo("/profile")
      });
      if (user.is_instructor || user.is_admin) {
        let adminItems = [
          {
            label: t("courses_edit"),
            icon: "pi pi-fw pi-book",
            id: "courses-menu-item",
            visible: adminOpen,
            command: () => navTo("/admin/courses")
          },
          {
            label: t("reporting"),
            icon: "pi pi-fw pi-chart-bar",
            id: "reporting-menu-item",
            visible: adminOpen,
            command: () => navTo("/admin/reporting")
          },
          {
            label: t("rubrics_edit"),
            icon: "pi pi-fw pi-table",
            id: "rubrics-menu-item",
            visible: adminOpen,
            command: () => navTo("/admin/rubrics")
          }
        ];
        if (user.is_admin) {
          adminItems.push(
            {
              label: t("concepts_edit"),
              icon: "pi pi-fw pi-tags",
              id: "concepts-menu-item",
              visible: adminOpen,
              command: () => navTo("/admin/concepts")
            },
            {
              label: t("schools_edit"),
              icon: "pi pi-fw pi-users",
              id: "schools-menu-item",
              visible: adminOpen,
              command: () => navTo("/admin/schools")
            },
            {
              label: t("consent_forms_edit"),
              icon: "pi pi-fw pi-file",
              id: "consent-forms-menu-item",
              visible: adminOpen,
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
            icon: "pi pi-fw pi-cog",
            id: "administration-menu",
            command: () => {
              toggleMenu(MENUS.ADMIN);
            }
          }
        );
        adminItems.forEach(menuItem => {
          builtMenu.push(menuItem);
        });
      }
    }
    builtMenu.push(
      {
        separator: true
      },
      {
        template: <DiversityCheck diversityScoreFor={props.diversityScoreFor} />
      },
      {
        label: t("titles.demonstration"),
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
      /*
      {
        separator: true
      },
      */
      {
        label: t("about"),
        icon: "pi pi-fw pi-info-circle",
        id: "about-menu-item",
        command: () => {
          navTo(props.moreInfoUrl);
          //toggleMenu(MENUS.ABOUT);
        }
      },
      /*
      {
        separator: true
      },
      */
    );

    if (isLoggedIn) {
      builtMenu.push({
        label: t("logout"),
        icon: "pi pi-fw pi-sign-out",
        id: "logout-menu-item",
        command: () => {
          dispatch(signOut());
          setMenuOpen(false);
        }
      });
    }

    return builtMenu;
  };


  //  const menuItems = useMemo(() => {buildMyMenu()}, [user, isLoggedIn, i18n.language]);

  return (
    <React.Fragment>
      <Button
        id="main-menu-button"
        text
        onClick={() => {
          setMenuOpen(!menuOpen);
        }}
        className="p-mr-2"
      >
        <Logo height={48} width={48} spinning={working} />
      </Button>
      <Sidebar
        visible={menuOpen}
        onHide={() => setMenuOpen(false)}
        modal
        position={"left"}
        style={{ width: "15rem" }}
        baseZIndex={1000000}
      >
        <Menu
          appendTo={"self"}
          closeOnEscape
          ref={menuButton}
          model={buildMyMenu()}
        />
      </Sidebar>
    </React.Fragment>
  );
}
