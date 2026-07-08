import React, { useMemo } from 'react';

import axios from 'axios';
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { startTask, endTask, addMessage, Priorities } from "../infrastructure/StatusSlice";

import { Dropdown } from "primereact/dropdown";
import { Skeleton } from "primereact/skeleton";
import { InputText } from "primereact/inputtext";
import { FloatLabel } from "primereact/floatlabel";
import { Button } from 'primereact/button';
import { ButtonGroup } from 'primereact/buttongroup';
import { Panel } from "primereact/panel";
import { Col, Container, Row } from 'react-grid-system';
import { DataTable } from 'primereact/datatable';
import { Column } from 'primereact/column';
import { Dialog } from 'primereact/dialog';
import { Checkbox } from 'primereact/checkbox';
import { refreshSchools } from '../infrastructure/ContextSlice';

interface Props {
}

export default function UsersDataAdmin(props: Props) {
    const category = "user";
    const endpoints = useTypedSelector(
        state => state.context.endpoints[category]
    );
    const endpointStatus = useTypedSelector(
        state => state.context.status.endpointsLoaded
    );
    const { t } = useTranslation(`${category}s`);
    const dispatch = useDispatch();

    const schools: { id: number; name: string; user_count: number }[] = useTypedSelector(state => state.context.lookups["schools"]);

    const [selectedSchool, setSelectedSchool] = React.useState<number>(-1);
    const [searchText, setSearchText] = React.useState<string>('');
    const [predatorEmail, setPredatorEmail] = React.useState<string>('');
    const [preyEmail, setPreyEmail] = React.useState<string>('');
    const user = useTypedSelector(state => state.profile.user);
    const [foundUsers, setFoundUsers] = React.useState<Array<{
        id: number,
        first_name: string,
        last_name: string,
        email: string,
        school_id: number,
        status: string
    }>>([]);

    const [userDetails, setUserDetails] = React.useState<{
        first_name: string,
        last_name: string,
        email: string,
        school_id: number,
        status: string,
        roles: {
            is_admin: boolean;
            is_instructor: boolean;
            is_researcher: boolean;
        }
    } | null>(null);
    const [showMergeDialog, setShowMergeDialog] = React.useState<boolean>(false);
    const [showUserViewDialog, setShowUserViewDialog] = React.useState<[boolean, string]>([false, '']);

    const userCount = useMemo(() => {
        let user_count_returned = 0;
        if (user.is_admin) {
            user_count_returned = selectedSchool !== -1 ?
                schools.find(s => s.id === selectedSchool)?.user_count || 0 :
                schools.reduce((accum, next) => accum + next.user_count, 0);
        } else if (user.is_researcher) {
            user_count_returned = schools.reduce((accum, next) => accum + next.user_count, 0);
        } else if (user.is_instructor) {
            setSelectedSchool(Number(user.school_id));
            user_count_returned = schools.find(s => s.id === Number(user.school_id))?.user_count || 0;
        }
        return user_count_returned;
    },
    [selectedSchool, schools, user]);

    const searchUsers = () => {
        dispatch(startTask("searching_users"));
        axios.post(`${endpoints.directorySearchUrl}.json`,
            {
                school_id: selectedSchool,
                search_term: searchText
            }
        )
            .then(response => {
                const data = response.data;
                console.log("Response from searchUsers:", data);
                setFoundUsers(data.users);
            })
            .catch(error => {
                console.error("Error searching users:", error);
            })
            .finally(() => {
                dispatch(endTask("searching_users"));
            });
    }

    const viewUser = (email: string) => {
        dispatch(startTask("user_details"));
        axios.post(`${endpoints.viewUserUrl}.json`,
            {
                email: email
            }
        )
            .then(response => {
                const data = response.data;
                setUserDetails(data.user);
            })
            .catch(error => {
                console.error("Error viewing user:", error);
                dispatch(addMessage(t(error.response.data.message), new Date(), Priorities.ERROR));
            })
            .finally(() => {
                dispatch(endTask("user_details"));
            });
        setFoundUsers([]);
        setShowUserViewDialog([false, '']);
        setShowMergeDialog(false);
    }

    const deletionAction = (email: string, deleteUser: boolean) => {
        dispatch(startTask("deleting_user"));

        axios.post(`${endpoints.deleteUserUrl}.json`,
            {
                email: email,
                delete: deleteUser
            }
        )
            .then(response => {
                console.log("Response from deletionAction:", response);

                const data = response.data;
                setFoundUsers(data.users);
                dispatch(addMessage(t(data.message), new Date(), Priorities.INFO));
            })
            .catch(error => {
                console.error("Error searching users:", error);
                dispatch(addMessage(t(error.response.data.message), new Date(), Priorities.ERROR));
            })
            .finally(() => {
                dispatch(endTask("deleting_user"));
            });
        setFoundUsers([]);
        setShowUserViewDialog([false, '']);
        setShowMergeDialog(false);
        dispatch( refreshSchools() );
    }

    const roleChangeAction = (email: string, newRole: string, set: boolean) => {
        dispatch(startTask("setting_role"));
        axios.post(`${endpoints.setRoleUrl}.json`,
            {
                email: email,
                role: newRole,
                set: set
            })
            .then(response => {
                const data = response.data;
                dispatch(addMessage( t(`${newRole}_${set ? 'true' : 'false'}_result_msg`), new Date(), Priorities.INFO ));
            })
            .catch(error => {
                console.error("Error searching users:", error);
                dispatch(addMessage(t(error.response.data.message), new Date(), Priorities.ERROR));
            })
            .finally(() => {
                dispatch(endTask("setting_role"));
            });
    }

    const mergeUsersAction = (predatorEmail: string, preyEmail: string) => {
        dispatch(startTask("merging_users"));
        axios.post(`${endpoints.mergeUsersUrl}.json`,
            {
                predator_email: predatorEmail,
                prey_email: preyEmail
            }
        )
            .then(response => {
                const data = response.data;
                setFoundUsers(data.users);
            })
            .catch(error => {
                console.error("Error merging users:", error);
            })
            .finally(() => {
                dispatch(endTask("merging_users"));
            });
    }


    return (
        <Panel header={t("users_search")} className="mb-2">
            <Container fluid>
                <Row>

                    {user.is_admin && schools.length > 0 ? (
                        <Col xs={12} sm={12} md={3} lg={3} xl={3}>

                            <Dropdown
                                id="course_school"
                                value={selectedSchool}
                                options={[{ id: -1, name: t("no_selected_school") }, ...schools]}
                                onChange={event => {
                                    const changeTo = Number(event.target.value);
                                    setSelectedSchool(changeTo);
                                }}
                                optionLabel="name"
                                optionValue="id"
                                placeholder={t("select_school")}
                                showClear={false}
                            />
                        </Col>
                    ) : (
                        null
                    )}
                    <Col xs={12} sm={12} md={7} lg={7} xl={7}>
                        <FloatLabel>
                            <InputText
                                id="search_text"
                                itemID="search_text"
                                name="search_text"
                                style={{ width: "100%" }}
                                value={searchText}
                                onChange={event => {
                                    setSearchText(event.target.value);
                                }}
                            />
                            <label htmlFor="search_text">{t("search_text_inpt")}</label>

                        </FloatLabel>
                    </Col>
                    <Col xs={12} sm={12} md={2} lg={2} xl={2}>
                        <ButtonGroup>
                        <Button
                            label={t("search_btn")}
                            icon="pi pi-search"
                            disabled={searchText.length === 0}
                            onClick={() => {
                                searchUsers();
                            }}
                        />
                        <Button
                            label={t("clear_btn")}
                            icon="pi pi-times-circle"
                            className="p-button-secondary p-ml-2"
                            onClick={() => {
                                setSearchText('');
                                setFoundUsers([]);
                            }}
                        />
                        </ButtonGroup>
                    </Col>

                </Row>
                <Row>
                    <Col xs={12} sm={12} md={10} lg={10} xl={10}>
                        <p>{t("user_stats_msg", { user_count: userCount })}</p>
                    </Col>
                    <Col xs={12} sm={12} md={2} lg={2} xl={2}>
                        {user.is_admin ? (
                            <Button
                                label={t("init_merge_users_btn")}
                                disabled={!user.is_admin}
                                onClick={() => {
                                    setShowMergeDialog(true);
                                }}
                            />
                        ) : null}
                    </Col>
                </Row>
            </Container>
            <DataTable
                value={foundUsers}
                resizableColumns
                tableStyle={{ minWidth: '50rem' }}
                reorderableColumns
                paginator
                rows={5}
                rowsPerPageOptions={[5, 10, 20]}
                sortField="last_name"
                sortOrder={1}
                onRowSelect={(e) => {
                    viewUser(e.data.email);
                    setShowUserViewDialog([true, e.data.email]);
                }}
                selectionMode="single"
                selection={showUserViewDialog[0] ? foundUsers.find(u => u.email === showUserViewDialog[1]) : null}
                paginatorDropdownAppendTo={'self'}
                paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
                currentPageReportTemplate="{first} to {last} of {totalRecords}"
                dataKey="id"
            >
                <Column header={t("table.first_name")} field="first_name" sortable filter key="first_name" />
                <Column header={t("table.last_name")} field="last_name" sortable filter key="last_name" />
                {
                    !user.is_researcher && (
                        <Column header={t("table.email")} field="email" sortable filter key="email" />
                    )
                }
                <Column header={t("table.school")}
                    field="school_id"
                    sortable
                    filter
                    key="school_id"
                    body={(rowData) => {
                        const school = schools.find(s => s.id === rowData.school_id);
                        return school ? school.name : t("no_selected_school");
                    }}
                />
                <Column
                    header={t("table.status")}
                    field="status"
                    sortable
                    filter
                    body={(rowData) => {
                        return rowData.status ? t('table.active_user') : t('table.inactive_user');
                    }}
                    key="status" />
                {user.is_admin && (
                    <Column
                        header={t("table.actions")}
                        field="school_id"
                        body={(rowData) => {

                            return (
                                <div>
                                    <Button
                                        label={rowData.status ? t('deactivate_user_btn') : t('activate_user_btn')}
                                        className="p-button-danger p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            deletionAction(rowData.email, rowData.status)
                                        }}
                                    />
                                    <Button
                                        label={rowData.is_admin ? t("revoke_admin_btn") : t("grant_admin_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(rowData.email, "admin", !rowData.is_admin);
                                        }
                                        }
                                    />
                                    <Button
                                        label={rowData.is_instructor ? t("revoke_instructor_btn") : t("grant_instructor_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(rowData.email, "instructor", !rowData.is_instructor);
                                        }
                                        }
                                    />
                                    <Button
                                        label={rowData.is_researcher ? t("revoke_researcher_btn") : t("grant_researcher_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(rowData.email, "researcher", !rowData.is_researcher);
                                        }
                                        }
                                    />

                                </div>
                            );
                        }}
                    />
                )}
            </DataTable>
            <Dialog
                header={t("merge_users_dialog_header")}
                visible={showMergeDialog}
                onHide={() => setShowMergeDialog(false)}
                style={{ width: '50%' }}
            >
                <p>{t("merge_users_dialog_content")}</p>
                <FloatLabel>
                    <InputText
                        id="predator_email"
                        itemID="predator_email"
                        name="predator_email"
                        style={{ width: "100%" }}
                        value={predatorEmail}
                        onChange={event => {
                            setPredatorEmail(event.target.value);
                        }}
                    />
                    <label htmlFor="predator_email">{t("predator_email_inpt")}</label>

                </FloatLabel>
                <FloatLabel>
                    <InputText
                        id="prey_email"
                        itemID="prey_email"
                        name="prey_email"
                        style={{ width: "100%" }}
                        value={preyEmail}
                        onChange={event => {
                            setPreyEmail(event.target.value);
                        }}
                    />
                    <label htmlFor="prey_email">{t("prey_email_inpt")}</label>


                </FloatLabel>
                <Button
                    label={t("merge_users_btn")}
                    disabled={predatorEmail.length === 0 || preyEmail.length === 0}
                    onClick={() => {
                        mergeUsersAction();
                        setShowMergeDialog(false);
                    }}
                />
                <Button
                    label={t("cancel_btn")}
                    className="p-button-secondary p-ml-2"
                    onClick={() => {
                        setShowMergeDialog(false);
                    }}
                />
            </Dialog>

            <Dialog
                header={t("user_view_dialog_header", { user_email: showUserViewDialog[1] })}
                visible={showUserViewDialog[0]}
                onHide={() => setShowUserViewDialog([false, ''])}
                style={{ width: '50%' }}
            >
                <p>{t("user_view_name_lbl", { user_first_name: userDetails?.first_name, user_last_name: userDetails?.last_name })}</p>
                <p>{t("user_view_school_lbl", { user_school: userDetails?.school })}</p>

                {(user.is_admin || user.is_instructor) && (
                <Container fluid>
                    <Row>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            <label htmlFor="is_active">{t("user_view_status_lbl")}</label>
                            <Checkbox
                                inputId="is_active"
                                checked={null !== userDetails && userDetails.status}
                                disabled
                            />
                        </Col>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            {
                                null !== userDetails && user.is_admin && (
                                    <Button
                                        label={userDetails.status ? t('deactivate_user_btn') : t('activate_user_btn')}
                                        className="p-button-danger p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            deletionAction(userDetails.email, !userDetails.status)
                                        }}
                                    />
                                )}

                        </Col>
                    </Row>
                    <Row>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            <label htmlFor="is_admin">{t("user_view_admin_lbl")}</label>
                            <Checkbox
                                inputId="is_admin"
                                checked={userDetails?.roles.is_admin || false}
                                disabled
                            />
                        </Col>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            {
                                null !== userDetails && user.is_admin && (
                                    <Button
                                        label={userDetails.is_admin ? t("revoke_admin_btn") : t("grant_admin_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(userDetails.email, "admin", !userDetails.is_admin);
                                        }
                                        }
                                    />
                                )
                            }
                        </Col>
                    </Row>
                    <Row>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            <label htmlFor="is_instructor">{t("user_view_instructor_lbl")}</label>
                            <Checkbox
                                inputId="is_instructor"
                                checked={userDetails?.roles.is_instructor || false}
                                disabled
                            />
                        </Col>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            {
                                null !== userDetails && user.is_admin && (
                                    <Button
                                        label={userDetails.is_instructor ? t("revoke_instructor_btn") : t("grant_instructor_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(userDetails.email, "instructor", !userDetails.is_instructor);
                                        }
                                        }
                                    />
                                )
                            }
                        </Col>
                    </Row>
                    <Row>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            <label htmlFor="is_researcher">{t("user_view_researcher_lbl")}</label>
                            <Checkbox
                                inputId="is_researcher"
                                checked={userDetails?.roles.is_researcher || false}
                                disabled
                            />
                        </Col>
                        <Col xs={12} sm={12} md={6} lg={6} xl={6}>
                            {
                                null !== userDetails && user.is_admin && (
                                    <Button
                                        label={userDetails.is_researcher ? t("revoke_researcher_btn") : t("grant_researcher_btn")}
                                        className="p-button-info p-mr-2"
                                        size='small'
                                        onClick={() => {
                                            roleChangeAction(userDetails.email, "researcher", !userDetails.is_researcher);
                                        }
                                        }
                                    />
                                )}
                        </Col>
                    </Row>
                </Container>
                    ) }
                <h5>{t("user_view_courses_lbl", { course_count: userDetails?.courses?.length || 0 })}</h5>
                {
                    userDetails?.courses && userDetails.courses.length > 0 ? (
                        <ul>
                            {userDetails.courses.map(course => (
                                <li key={course.course_id}><strong>{course.course_number}</strong>: {course.course_name}</li>
                            ))}
                        </ul>
                    ) : (
                        <p>{t("no_courses_msg")}</p>
                    )
                }
            </Dialog>
        </Panel>
    )
}