import React from "react"
import { makeStyles } from '@material-ui/core/styles';
import PropTypes from "prop-types"
import AppBar from '@material-ui/core/AppBar';
import MenuItem from '@material-ui/core/MenuItem';
import Menu from '@material-ui/core/Menu';
import Toolbar from '@material-ui/core/Toolbar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import MenuIcon from '@material-ui/icons/Menu';
import {ThemeProvider} from '@material-ui/core/styles';
import {createMuiTheme} from '@material-ui/core/styles';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from "react-router-dom";

import Quote from '../components/Quote'


class CPanel extends React.Component {
  constructor( props ){
    super( props );

    const theme = createMuiTheme({
      palette: {
        primary: {
          main: this.props.theme.primary,
        },
        secondary: {
          main: this.props.theme.secondary,
        },
      },
    });
    const styles = makeStyles( theme=> ({
      root: {
        flexGrow: 1,
      },
      menuButton: {
        marginRight: theme.spacing(2),
      },
      title: {
        flexGrow: 1,
      },
    } ) );
    this.state = {
      theme: theme,
      styles: styles
    }
  }

  render () {
  return (
    <Router>
    <ThemeProvider theme={this.state.theme}>
    <AppBar color="primary" position='static'>
      <Toolbar>
        <IconButton edge="start" className={this.state.styles.menuButton} color="inherit" aria-label="menu">
          <MenuIcon/>
        </IconButton>
        <Typography variant="h6" className={this.state.styles.title}>
          CoLab
        </Typography>
        <IconButton className={this.state.styles.menuButton}
        color="inherit" aria-label="app">
        <img align="right" src={this.props.logo} />
        </IconButton>
      </Toolbar>
    </AppBar>
        <Typography align='center' variant='caption' >
          <Quote url={this.props.quote_path} token={this.props.token} />
        </Typography>
    </ThemeProvider>
      <div>
        <nav>
          <ul>
            <li>
              <Link to={ "/" + this.props.base + "/"}>Home</Link>
            </li>
            <li>
              <Link to={ "/" + this.props.base + "/about"}>About</Link>
            </li>
            <li>
              <Link to={ "/" + this.props.base + "/users" }>Users</Link>
            </li>
          </ul>
        </nav>

        {/* A <Switch> looks through its children <Route>s and
            renders the first one that matches the current URL. */}
        <Switch>
          <Route path={ "/" + this.props.base + "/about" }>
            <About />
          </Route>
          <Route path={ "/" + this.props.base + "/users" }>
            <Users />
          </Route>
          <Route path={ "/" + this.props.base + "/" }>
            <Home />
          </Route>
        </Switch>
      </div>
    </Router>
  );
  }
}

CPanel.propTypes = {
  token: PropTypes.string.isRequired,
  base: PropTypes.string.isRequired,
  first_name: PropTypes.string.isRequired,
  last_name: PropTypes.string.isRequired,
  quote_path: PropTypes.string,
  logo: PropTypes.string,
  theme: PropTypes.shape({
    primary: PropTypes.string.isRequired,
    secondary: PropTypes.string.isRequired
  }),
  timezone: PropTypes.string.isRequired
};
export default CPanel


function Home() {
  return <h2>Home</h2>;
}

function About() {
  return <h2>About</h2>;
}

function Users() {
  return <h2>Users</h2>;
}

