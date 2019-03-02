import React from "react";
import PropTypes from "prop-types";
import FormControl from "@material-ui/core/FormControl";
import InputLabel from "@material-ui/core/InputLabel";
import NativeSelect from "@material-ui/core/NativeSelect";
class SelectFrom extends React.Component {
  constructor(props) {
    super(props);
    let opts = Object.values(this.props.options);
    opts.sort((a, b) => {
      if (a.name_en > b.name_en) {
        return 1;
      }
      if (a.name_en < b.name_en) {
        return -1;
      }
      return 0;
    });
    this.state = {
      opts: opts
    };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange = event => {
    this.props.selectFunction(this.props.itemId, event.target.value);
  };
  render() {
    return (
      <FormControl>
        <NativeSelect
          value={Math.max(this.props.selectedValue, 0)}
          onChange={this.handleChange}
          name={this.props.selectLbl}
          id={this.props.controlId}
        >
          <option value="0" disabled>
            {this.props.selectLbl}
          </option>
          {this.state.opts.map(option => {
            return (
              <option key={option.id} value={option.id}>
                {option.name_en}
              </option>
            );
          })}
        </NativeSelect>
      </FormControl>
    );
  }
}
SelectFrom.propTypes = {
  options: PropTypes.object.isRequired,
  selectLbl: PropTypes.string,
  itemId: PropTypes.number.isRequired,
  selectedValue: PropTypes.string,
  controlId: PropTypes.string.isRequired,
  selectFunction: PropTypes.func.isRequired
};
export default SelectFrom;
