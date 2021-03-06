import React   from "react"


import RefreshIndicator from "material-ui/RefreshIndicator"

export default class LoadingImage extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  render() {
    return (
      <span className={this.props.className} style={{position:"relative"}} >
        <RefreshIndicator
          left={this.props.left}
          top={this.props.top}
          status={this.props.status}
          size={this.props.size}
           />
      </span>
    );
  }
}
LoadingImage.propTypes = {
  className: React.PropTypes.string,
  status: React.PropTypes.string,
  left: React.PropTypes.number,
  top: React.PropTypes.number,
  size: React.PropTypes.number
};
LoadingImage.defaultProps = {
  className: "",
  status: "loading",
  left: 0,
  top: 0,
  size: 40
};
