// https://www.w3schools.com/react/react_hooks.asp

import React, { useState } from "react";
// import ReactDOM from "react-dom/client";

export default function Message(props) {
  const [color, setColor] = useState("red");
  const [val, setVal] = useState(11);

  const colorHandler = (color) => {
    setColor("[" + color +"]")
  }


  return (
    <>
      <h1>{props.name} My favorite color is {color} value {val}!</h1>
      <button
        type="button"
        onClick={() => colorHandler("blue")}
      >Blue</button>
      <button
        type="button"
        onClick={() => colorHandler("red")}
      >Red</button>
      <button
        type="button"
        onClick={() => setVal(2222)}
      >Pink</button>
      <button
        type="button"
        onClick={() => setVal(3333)}
      >Green</button>
    </>
  );
}

