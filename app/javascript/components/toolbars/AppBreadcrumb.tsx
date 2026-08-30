import React from "react";
import { Link, useLocation } from 'react-router';
import { BreadCrumb } from "primereact/breadcrumb";
import { iconForType } from "../ActivityLib";
import { useTranslation } from "react-i18next";

export default function AppBreadCrumb() {
    const endpointSet = "";
    const [t] = useTranslation( endpointSet);
    const location = useLocation();
    console.log("AppBreadCrumb location", location);

    const crumbs = location.pathname.split('/')
        .filter((crumb) => crumb.length > 0)
        .map((crumb, index, array) => {
            const url = '/' + array.slice(0, index + 1).join('/');
            return {
                label: crumb,
                url,
                template: ( item: any, options: any) => (
                    <Link to={url}
                        className={options.className}>
                            {iconForType(crumb)}
                    </Link>
                )
            };
        });
    
    console.log("AppBreadCrumb crumbs", crumbs);
    const homeItem = 
        {
            icon: 'pi pi-home',
            url: "/home",
            template: ( item: any, options: any) => (
                <Link to={"/home"}
                    className={options.className}>
                        {t('title')}&nbsp;<span className="pi pi-home"></span>
                </Link>
            )
        };

    const modelItems = "home" === crumbs[0]?.label ? crumbs.slice(1) : crumbs;
    return (
            <BreadCrumb model={modelItems} home={homeItem} />
    )
}
