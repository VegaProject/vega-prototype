// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";
// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import vega_artifacts from '../../build/contracts/VegaToken.json';
import club_artifacts from '../../build/contracts/Club.json';

// MetaCoin is our usable abstraction, which we'll use through the code below.
var VegaToken = contract(vega_artifacts);

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
var accounts;
var account;
