import React from "react"
import PropTypes from "prop-types"
import Timestamp from "react-timestamp"

class Countdown extends React.Component {

  constructor(props) {
    console.log("was created");
    super(props);
    this.tick = this.tick.bind(this);
  }

  componentDidMount() {
    console.log("did mount");
    this.timerID = setInterval(
      this.tick,
      1000
    );
  }

  componentWillUnmount() {
    clearInterval(this.timerID);
  }

  tick() {
    this.forceUpdate();
  }

  render() {
    return (
      <div>
        Cycle finishes <strong>
          < Timestamp time={this.props.next_deadline} precision={3} />
          </strong>
      </div>
    );
  }
}

export default Countdown