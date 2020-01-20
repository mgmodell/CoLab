import React, { Suspense } from "react";
import PropTypes from "prop-types";
import Button from "@material-ui/core/Button";
import Table from "@material-ui/core/Table";
import TableHead from "@material-ui/core/TableHead";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableRow from "@material-ui/core/TableRow";
import TextField from "@material-ui/core/TextField";
import Dialog from "@material-ui/core/Dialog";
import DialogActions from "@material-ui/core/DialogActions";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogTitle from "@material-ui/core/DialogTitle";

import "./i18n";
import { Translation } from "react-i18next";

import CompareIcon from "@material-ui/icons/Compare";

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
    fetch(this.props.diversityScoreFor + ".json", {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      },
      body: JSON.stringify({
        emails: this.state.emails
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        this.setState({
          diversity_score: data.diversity_score,
          found_users: data.found_users
        });
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
              <Button
                variant="contained"
                size="small"
                onClick={() => this.openDialog()}
              >
                <CompareIcon />
                {t("calc_diversity")}
              </Button>
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
  token: PropTypes.string.isRequired,
  diversityScoreFor: PropTypes.string.isRequired
};
export default DiversityCheck;
