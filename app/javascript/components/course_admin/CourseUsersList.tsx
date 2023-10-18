import React, { useState, useEffect, useMemo, Fragment } from "react";
import { useDispatch } from "react-redux";

import WorkingIndicator from "../infrastructure/WorkingIndicator";

import PersonAddIcon from "@mui/icons-material/PersonAdd";

import HelpOutlineIcon from "@mui/icons-material/HelpOutline";
import NotInterestedIcon from "@mui/icons-material/NotInterested";
import CheckCircleOutlineIcon from "@mui/icons-material/CheckCircleOutline";
import SupervisedUserCircleIcon from "@mui/icons-material/SupervisedUserCircle";
import ClearIcon from "@mui/icons-material/Clear";

import EmailIcon from "@mui/icons-material/Email";
import CheckIcon from "@mui/icons-material/Check";

import Link from "@mui/material/Link";
import Tooltip from "@mui/material/Tooltip";
import IconButton from "@mui/material/IconButton";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useTranslation } from "react-i18next";
import {
  DataGrid,
  GridRowModel,
  GridColDef,
  GridRenderCellParams
} from "@mui/x-data-grid";
import CourseUsersListToolbar from "./CourseUsersListToolbar";
import { renderTextCellExpand } from "../infrastructure/GridCellExpand";

const DropUserButton = React.lazy(() => import("./DropUserButton"));
const BingoDataRepresentation = React.lazy(() =>
  import("../BingoBoards/BingoDataRepresentation")
);

enum UserListType {
  student = "student",
  instructor = "instructor",
  invited_student = "invited_student",
  assistant = "assistant",
  enrolled_student = "enrolled_student",
  requesting_student = "requesting_student",
  rejected_student = "rejected_student",
  dropped_student = "dropped_student",
  declined_student = "declined_student"
}

type StudentData = {
  assessment_performance: number;
  bingo_data: Array<number>;
  bingo_performance: number;
  drop_link: string;
  email: string;
  experience_performance: number;
  first_name: string;
  id: number;
  last_name: string;
  reinvite_link: string;
  status: UserListType;
};

type Props = {
  courseId: number;
  retrievalUrl: string;
  usersList: Array<StudentData>; //Need an interface for the users
  usersListUpdateFunc: (usersList: Array<StudentData>) => void;
  userType: UserListType;
  addMessagesFunc: ({}) => void;
};

export default function CourseUsersList(props: Props) {
  const category = "courses";
  const { t } = useTranslation(category);

  const [addUsersPath, setAddUsersPath] = useState("");
  const [procRegReqPath, setProcRegReqPath] = useState("");
  const [addDialogOpen, setAddDialogOpen] = useState(false);
  const [newUserAddresses, setNewUserAddresses] = useState("");

  const dispatch = useDispatch();

  const getUsers = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        if ("student" == props.userType) {
          setAddUsersPath(data.add_function.students + ".json");
        } else {
          setAddUsersPath(data.add_function.instructor + ".json");
        }
        setProcRegReqPath(data.add_function.proc_self_reg + ".json");
        props.usersListUpdateFunc(data.users);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const refreshFunc = newMessages => {
    getUsers();
    props.addMessagesFunc(newMessages);
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getUsers();
    }
  }, []);

  const userColumns: GridColDef[] = [
    {
      headerName: t("first_name"),
      field: "first_name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("last_name"),
      field: "last_name",
      renderCell: renderTextCellExpand
    },
    {
      headerName: t("email"),
      field: "email",
      renderCell: (params: GridRenderCellParams) => {
        return <Link href={"mailto:" + params.value}>{params.value}</Link>;
      }
    },
    {
      headerName: t("bingo_progress"),
      field: "bingo_data",
      renderCell: (params: GridRenderCellParams) => {
        const data = params.row.bingo_data;

        return (
          <BingoDataRepresentation
            height={30}
            width={70}
            value={Number(params.value)}
            scores={data}
          />
        );
      }
    },
    {
      headerName: t("assessment_progress"),
      field: "assessment_performance",
      renderCell: (params: GridRenderCellParams) => {
        return `${params.value}%`;
      }
    },
    {
      headerName: t("experience_progress"),
      field: "experience_performance",
      renderCell: (params: GridRenderCellParams) => {
        return `${params.value}%`;
      }
    },
    {
      headerName: t("status"),
      field: "status",
      renderCell: (params: GridRenderCellParams) => {
        return iconForStatus(params.value);
      }
    },
    {
      headerName: t("actions"),
      field: "id",
      renderCell: (params: GridRenderCellParams) => {
        const user = props.usersList.filter(user => {
          return params.id === user.id;
        })[0];
        const btns = [];
        switch (user.status) {
          case UserListType.invited_student:
            btns.push(
              <Tooltip key="re-send-invite" title={t("re-send_invitation")}>
                <IconButton
                  aria-label={t("re-send_invitation")}
                  onClick={event => {
                    dispatch(startTask("inviting"));
                    axios
                      .get(user.reinvite_link, {})
                      .then(response => {
                        const data = response.data;
                        refreshFunc(data.messages);
                        dispatch(endTask("inviting"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                  size="large"
                >
                  <EmailIcon />
                </IconButton>
              </Tooltip>
            );
          case UserListType.instructor:
          case UserListType.assistant:
          case UserListType.enrolled_student:
            btns.push(
              <DropUserButton
                key="drop-student-button"
                dropUrl={user.drop_link}
                refreshFunc={refreshFunc}
              />
            );
            break;
          case UserListType.requesting_student:
            const acceptLbl = t("accept_student");
            const lbl2 = t("decline_student");
            btns.push(
              <Tooltip key="accept" title={acceptLbl}>
                <IconButton
                  aria-label={acceptLbl}
                  onClick={event => {
                    dispatch(startTask("accepting_student"));
                    axios
                      .patch(procRegReqPath, {
                        roster_id: user.id,
                        decision: true
                      })
                      .then(response => {
                        const data = response.data;
                        refreshFunc(data.messages);
                        dispatch(endTask("accepting_student"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                  size="large"
                >
                  <CheckIcon />
                </IconButton>
              </Tooltip>
            );
            btns.push(
              <Tooltip key="decline" title={lbl2}>
                <IconButton
                  aria-label={lbl2}
                  onClick={event => {
                    dispatch(startTask("decline_student"));
                    axios
                      .patch(procRegReqPath, {
                        roster_id: user.id,
                        decision: false
                      })
                      .then(response => {
                        const data = response.data;
                        refreshFunc(data.messages);
                        dispatch(endTask("decline_student"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                  size="large"
                >
                  <ClearIcon />
                </IconButton>
              </Tooltip>
            );
            break;
          case UserListType.rejected_student:
          case UserListType.dropped_student:
          case UserListType.declined_student:
            const lbl = "Re-Add Student";
            btns.push(
              <Tooltip key="re-add" title={lbl}>
                <IconButton
                  aria-label={lbl}
                  onClick={event => {
                    dispatch(startTask("re-adding"));
                    axios
                      .put(addUsersPath, {
                        addresses: user.email
                      })
                      .then(response => {
                        const data = response.data;
                        refreshFunc(data.messages);
                        dispatch(endTask("re-adding"));
                      })
                      .catch(error => {
                        console.log("error", error);
                      });
                  }}
                  size="large"
                >
                  <PersonAddIcon />
                </IconButton>
              </Tooltip>
            );
            break;
          default:
            console.log("Status not found: " + user.status);
        }

        return btns;
      }
    }
  ];

  const closeDialog = () => {
    setNewUserAddresses("");
    setAddDialogOpen(false);
  };

  const iconForStatus = status => {
    var icon;
    switch (status.toLowerCase()) {
      case "enrolled":
      case "enrolled_student":
        icon = (
          <Tooltip title="Enrolled">
            <CheckCircleOutlineIcon />
          </Tooltip>
        );
        break;
      case "undetermined":
      case "invited_student":
      case "requesting_student":
        icon = (
          <Tooltip title="Awaiting Response">
            <HelpOutlineIcon />
          </Tooltip>
        );
        break;
      case "dropped":
      case "rejected_student":
      case "dropped_student":
      case "declined_student":
        icon = (
          <Tooltip title="Not Enrolled">
            <NotInterestedIcon />
          </Tooltip>
        );
        break;
      case "instructor":
      case "assistant":
        icon = (
          <Tooltip title="Instructor or Assistant">
            <SupervisedUserCircleIcon />
          </Tooltip>
        );
        break;
      default:
        console.log("status not found: " + status);
    }
    return icon;
  };

  const newUserList = useMemo(() => {
    return (
      <DataGrid
        columns={userColumns}
        getRowId={(model: GridRowModel) => {
          return model.id;
        }}
        rows={props.usersList.filter(user => {
          const checkType =
            UserListType.instructor !== user.status &&
            UserListType.assistant !== user.status;
          return UserListType.instructor === props.userType
            ? !checkType
            : checkType;
        })}
        initialState={{
          columns: {
            columnVisibilityModel: {
              first_name: true,
              last_name: true,
              bingo_data: props.userType === UserListType.student,
              assessment_performance: props.userType === UserListType.student,
              experience_performance: props.userType === UserListType.student,
              email: false,
              status: true
            }
          },
          pagination: {
            paginationModel: { page: 0, pageSize: 5 }
          }
        }}
        slots={{
          toolbar: CourseUsersListToolbar
        }}
        pageSizeOptions={[5, 10, 25, 100]}
        slotProps={{
          toolbar: {
            courseId: props.courseId,
            userType: props.userType,
            usersListUpdateFunc: props.usersListUpdateFunc,
            retrievalUrl: props.retrievalUrl,
            addMessagesFunc: props.addMessagesFunc,
            refreshUsersFunc: getUsers,
            addUsersPath: addUsersPath
          }
        }}
      />
    );
  }, [props.usersList]);

  return (
    <Fragment>
      <WorkingIndicator identifier="loading_users" />
      {newUserList}
    </Fragment>
  );
}

export { UserListType, StudentData };
