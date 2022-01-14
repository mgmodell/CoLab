import React, { Suspense } from "react";
import PropTypes from "prop-types";
import Button from "@mui/material/Button";
import Link from "@mui/material/Link";
import ListItem from "@mui/material/ListItem";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
import Table from "@mui/material/Table";
import TableHead from "@mui/material/TableHead";
import TableBody from "@mui/material/TableBody";
import TableCell from "@mui/material/TableCell";
import TableRow from "@mui/material/TableRow";
import TextField from "@mui/material/TextField";
import Dialog from "@mui/material/Dialog";
import DialogActions from "@mui/material/DialogActions";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogTitle from "@mui/material/DialogTitle";

import { i18n } from "./infrastructure/i18n";
import { Translation } from "react-i18next";

import CompareIcon from "@mui/icons-material/Compare";
import axios from "axios";

//const t = get_i18n("base");

class DiversityCheck extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dialogOpen: false,
      emails: "",
      diversity_score: null,
      found_users: []
    };
    this.openDialog = this.openDialog.bind(this);
    this.closeDialog = this.closeDialog.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleClear = this.handleClear.bind(this);
    this.calcDiversity = this.calcDiversity.bind(this);
  }
  calcDiversity() {
    const url = this.props.diversityScoreFor + ".json";
    axios.post( url,{
        emails: this.state.emails
    })
      .then(response => {
        const data = response.data;
        this.setState({
          diversity_score: data.diversity_score,
          found_users: data.found_users
        });
      })
      .catch( error =>{
          console.log("error", error );
          return [{ id: -1, name: "no data" }];

      });
  }
  handleClear(event) {
    this.setState({
      emails: "",
      diversity_score: null,
      found_users: []
    });
  }
  handleChange(event) {
    this.setState({
      emails: event.target.value
    });
  }

  openDialog() {
    console.log("hi");
    this.setState({
      dialogOpen: true
    });
  }

  closeDialog() {
    this.setState({
      dialogOpen: false
    });
  }

  render() {
    return (
      <Suspense fallback={<div>Loading...</div>}>
        <Translation>
          {t => (
            <React.Fragment>
              <ListItem button onClick={() => this.openDialog()}>
                <ListItemIcon>
                  <CompareIcon fontSize="small" />
                </ListItemIcon>
                <ListItemText>{t("calc_diversity")}</ListItemText>
              </ListItem>
              <Dialog
                open={this.state.dialogOpen}
                onClose={() => this.closeDialog()}
                aria-labelledby={t("calc_it")}
              >
                <DialogTitle>{t("calc_it")}</DialogTitle>
                <DialogContent>
                  <DialogContentText>{t("ds_emails_lbl")}</DialogContentText>
                  <TextField
                    value={this.state.emails}
                    onChange={() => this.handleChange(event)}
                  />

                  {this.state.found_users.length > 0 ? (
                    <Table>
                      <TableBody>
                        <TableRow>
                          <TableCell>
                            {this.state.found_users.map(user => {
                              return (
                                <a
                                  key={user.email}
                                  href={"mailto:" + user.email}
                                >
                                  {user.name}
                                  <br />
                                </a>
                              );
                            })}
                          </TableCell>
                          <TableCell valign="middle" align="center">
                            {this.state.diversity_score}
                          </TableCell>
                        </TableRow>
                      </TableBody>
                    </Table>
                  ) : null}
                  <DialogActions>
                    <Button
                      variant="contained"
                      onClick={() => this.calcDiversity()}
                    >
                      {t("calc_diversity_sub")}
                    </Button>
                    <Button
                      variant="contained"
                      onClick={() => this.handleClear()}
                    >
                      Clear
                    </Button>
                  </DialogActions>
                </DialogContent>
              </Dialog>
            </React.Fragment>
          )}
        </Translation>
      </Suspense>
    );
  }
}

DiversityCheck.propTypes = {
  diversityScoreFor: PropTypes.string.isRequired
};
export default DiversityCheck;
