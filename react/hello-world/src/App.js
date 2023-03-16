// import logo from './logo.svg';
import './App.css';
// import Greet from './components/Greet';
// import Welcome from './components/Welcome';
// import Message from './components/Message';
// import MyChart from "./MyChart.js";

// import CanvasJSReact from './canvasjs.react';


//  import AppexTest1 from './ApexTest1.js' ;
// import ApexChart from './ApexTest2.js' ;

 import ApexChart from './ApexTest3.js' ;


//var CanvasJSReact = require('./canvasjs.react');
// var CanvasJS = CanvasJSReact.CanvasJS;
// var CanvasJSChart = CanvasJSReact.CanvasJSChart;


// const options = {
//   title: {
//     text: "Basic Column Chart in React"
//   },
//   data: [{
//     type: "column",
//     dataPoints: [
//       { label: "Apple", y: 10 },
//       { label: "Orange", y: 15 },
//       { label: "Banana", y: 25 },
//       { label: "Mango", y: 30 },
//       { label: "Grape", y: 28 }
//     ]
//   }]
// };

function App() {
  return (
    <div className="App">
      <h1>My App</h1>
      <ApexChart />
    </div>
  );
}

export default App;
