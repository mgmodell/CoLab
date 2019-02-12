import React from "react"
import PropTypes from "prop-types"
import Paper from "@material-ui/core/Paper"
import ConceptChips from './ConceptChips'
import BingoGameDataAdminTable from './BingoGameDataAdminTable'

class BingoGameDataAdmin extends React.Component {
  constructor( props ){
    super( props )
  }

  componentDidMount( ){
    this.getBingoGameData( )
  }

  getBingoGameData() {
    fetch(this.props.bingoGameUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": this.props.token
      }
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
          bingo_game: data,
        });
      });
  }

  render () {
    return (
      <div>
        Bingo Game Url: {this.props.bingoGameUrl}<br/>
        Token: {this.props.token}<br/>
        Concept Url: {this.props.conceptUrl}<br/>
        Game Results Url: {this.props.gameResultsUrl}<br/>

        <ConceptChips
          token={this.props.token}
          url={this.props.conceptUrl}
        />
        <BingoGameDataAdminTable
          token={this.props.token}
          gameResultsUrl={this.props.gameResultsUrl}
        />

      </div>
    );
  }
}

BingoGameDataAdmin.propTypes = {
  bingoGameUrl: PropTypes.string.isRequired,
  token: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  gameResultsUrl: PropTypes.string.isRequired
};
export default BingoGameDataAdmin
