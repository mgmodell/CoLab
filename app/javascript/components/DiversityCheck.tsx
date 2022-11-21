import React, { useState, Suspense } from "react";
import PropTypes from "prop-types";
import Button from "@mui/material/Button";
import ListItem from "@mui/material/ListItem";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
import Table from "@mui/material/Table";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import TextField from "@mui/material/TextField";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogTitle from "@mui/material/DialogTitle";

import { useTranslation } from "react-i18next";

import CompareIcon from "@mui/icons-material/Compare";
import axios from "axios";

export default function DiversityCheck(props) {
  const [emails, setEmails] = useState("");
  const [dialogOpen, setDialogOpen] = useState(false);
  const [diversityScore, setDiversityScore] = useState(null);
  const [foundUsers, setFoundUsers] = useState([]);

  const [t] = useTranslation();

  function calcDiversity() {
    const url = props.diversityScoreFor + ".json";
    axios
      .post(url, {
        emails: emails
      })
      .then(response => {
        const data = response.data;
        setDiversityScore(data.diversity_score);
        setFoundUsers(data.found_users);
      })
      .catch(error => {
        console.log("error", error);
        return [{ id: -1, name: "no data" }];
      });
  }
  function handleClear() {
    setEmails("");
    setDiversityScore(null);
    setFoundUsers([]);
  }

  function openDialog() {
    setDialogOpen(true);
  }

  function closeDialog() {
    setDialogOpen(false);
  }

  function handleChange(event) {
    setEmails(event.target.value);
  }

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <React.Fragment>
        <ListItem button onClick={() => openDialog()}>
          <ListItemIcon>
            <CompareIcon fontSize="small" />
          </ListItemIcon>
          <ListItemText>{t("calc_diversity")}</ListItemText>
        </ListItem>
        <Dialog
          open={dialogOpen}
          onClose={() => closeDialog()}
          aria-labelledby={t("calc_it")}
        >
          <DialogTitle>{t("calc_it")}</DialogTitle>
          <DialogContent>
            <DialogContentText>{t("ds_emails_lbl")}</DialogContentText>
            <TextField value={emails} onChange={handleChange} />

            {foundUsers.length > 0 ? (
              <Table>
                <TableBody>
                  <TableRow>
                    <TableCell>
                      {foundUsers.map(user => {
                        return (
                          <a key={user.email} href={"mailto:" + user.email}>
                            {user.name}
                            <br />
                          </a>
                        );
                      })}
                    </TableCell>
                    <TableCell valign="middle" align="center">
                      {diversityScore}
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            ) : null}
            <DialogActions>
              <Button variant="contained" onClick={calcDiversity}>
                {t("calc_diversity_sub")}
              </Button>
              <Button variant="contained" onClick={handleClear}>
                {t("clear")}
              </Button>
            </DialogActions>
          </DialogContent>
        </Dialog>
      </React.Fragment>
    </Suspense>
  );
}

DiversityCheck.propTypes = {
  diversityScoreFor: PropTypes.string.isRequired
};
