import React from "react";
import { Link, useLocation } from 'react-router';
import { BreadCrumb } from "primereact/breadcrumb";
import { iconForType } from "../ActivityLib";
import { useTranslation } from "react-i18next";

const activityTypesWithoutListings = [
    "bingo_game",
    "experience",
    "project",
    "assignment"
];
const isActivityId = (segment: string) => /^\d+$/.test(segment) || segment === "new";

export default function AppBreadCrumb() {
    const endpointSet = "";
    const [t] = useTranslation( endpointSet);
    const location = useLocation();

    const pathSegments = location.pathname.split('/')
        .filter((crumb) => crumb.length > 0)
        .map((crumb, index, array) => {
            const combineWithNext =
                activityTypesWithoutListings.includes(crumb.toLowerCase()) &&
                isActivityId(array[index + 1] ?? "");
            const skip =
                index > 0 &&
                activityTypesWithoutListings.includes(array[index - 1].toLowerCase()) &&
                isActivityId(crumb);
            const url = '/' + array.slice(0, index + (combineWithNext ? 2 : 1)).join('/');
            return {
                label: crumb,
                url,
                skip,
                template: ( item: any, options: any) => (
                    <Link to={url}
                        className={options.className}>
                            {iconForType(crumb, t)}
                            {combineWithNext && <>&nbsp;{iconForType(array[index + 1], t)}</>}
                    </Link>
                )
            };
        })
        .filter((crumb) => !crumb.skip);
    
    const homeItem = 
        {
            icon: 'pi pi-home',
            url: "/home",
            template: ( item: any, options: any) => (
                <Link to={"/home"}
                    className={options.className}>
                        {t('title')}&nbsp;<span className="pi pi-home" title={t('breadcrumbs.home')}></span>
                </Link>
            )
        };

    const modelItems = "home" === pathSegments[0]?.label ? pathSegments.slice(1) : pathSegments;
    return (
            <BreadCrumb model={modelItems} home={homeItem} />
    )
}
