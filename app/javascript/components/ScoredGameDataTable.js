import React from "react"
import PropTypes from "prop-types"
import { SortDirection } from "react-virtualized";
import Table from "@material-ui/core/Table";
import TableHead from "@material-ui/core/TableHead";
import TableBody from "@material-ui/core/TableBody";
import TableCell from "@material-ui/core/TableCell";
import TableRow from "@material-ui/core/TableRow";
import TableSortLabel from "@material-ui/core/TableSortLabel";


class ScoredGameDataTable extends React.Component {
  constructor(props){
    super( props );
    this.state = {
      sortBy: "term",
      sortDirection: SortDirection.DESC,
      columns: [
        {
          width: 100,
          flexGrow: 1.0,
          label: "Entered",
          dataKey: "term",
          numeric: false,
          sortable: true,
          visible: true,
          render_func: c => {
            return c.term;
          }
        },
        {
          width: 150,
          flexGrow: 1.0,
          label: "Definition",
          dataKey: "definition",
          numeric: false,
          sortable: true,
          visible: true,
          render_func: c => {
            return c.definition;
          }
        },
        {
          width: 100,
          flexGrow: 1.0,
          label: "Feedback",
          dataKey: "feedback",
          numeric: false,
          sortable: true,
          visible: true,
          render_func: c => {
            return c.feedback;
          }
        },
        {
          width: 100,
          flexGrow: 1.0,
          label: "Concept",
          dataKey: "concept",
          numeric: false,
          sortable: true,
          visible: true,
          render_func: c => {
            return c.concept;
          }
        }
      ]
    }
  }

  sortCandidates(key, direction, candidates) {
    const dataKey = key;
    const mod = direction == SortDirection.ASC ? -1 : 1;
    if( "concept" == dataKey ){
      candidates.sort((a, b) => {
        const a_val = a[ "concept" ] || "zz";
        const b_val = b[ "concept" ] || "zz";

        return mod * a_val.localeCompare(b_val);
      });

    } else {
      candidates.sort((a, b) => {
        return mod * a[dataKey].localeCompare(b[dataKey]);
      });
    }

  }

  sortEvent(event, dataKey) {
    const { sortBy, sortDirection } = this.state;
    const { candidates } = this.props;

    let direction = SortDirection.DESC;
    if (dataKey == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
    }
    this.sortCandidates(dataKey, direction, candidates);
    this.setState({
      candidates: candidates,
      sortDirection: direction,
      sortBy: dataKey
    });
  }

  render () {
    const direction = {
      [SortDirection.ASC]: "asc",
      [SortDirection.DESC]: "desc"
    };
    const { columns } = this.state;
    const { candidates } = this.props;
    return (
      <Table>
        <TableHead>
          <TableRow>
            {columns.map( cell => {
              if( cell.visible ){
                const header = cell.sortable ? (
                <TableSortLabel
                  active={cell.dataKey == this.state.sortBy}
                  direction={direction[this.state.sortDirection]}
                  onClick={() => this.sortEvent(event, cell.dataKey)}
                >
                  {cell.label}
                </TableSortLabel>
              ) : (
                cell.label
              );
              return (
                <TableCell width={cell.width} key={"h_" + cell.dataKey}>
                  {header}
                </TableCell>
              );
            }
                })}
          </TableRow>
        </TableHead>
        <TableBody>
              {null == candidates ? null : candidates
                .map(candidate => {
                  return (
                    <TableRow key={"r_" + candidate.id}>
                      {columns.map(cell => {
                        if (cell.visible) {
                          return (
                            <TableCell key={candidate.id + "_c" + cell.dataKey}>
                              {cell.render_func(candidate)}
                            </TableCell>
                          );
                        }
                      })}
                    </TableRow>
                  );
                })}

        </TableBody>
      </Table>

      
    );
  }
}

ScoredGameDataTable.propTypes = {
  candidates: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      concept: PropTypes.string,
      definition: PropTypes.string,
      term: PropTypes.string,
      feedback: PropTypes.string,
      feedback_id: PropTypes.number
    })
  )
};
export default ScoredGameDataTable
