import { default as yargs } from 'yargs'
import { default as initializeLib } from '../index'

const RPC_HOST = 'localhost'
const RPC_PORT = '8545'

var args = yargs
  .command('transfer', 'Transfer from the account specified to the recepient', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })     
    .option('receiver', {
      description: 'The address to send funds to',
      alias: 'r',
      type: 'string'
    })
    .option('amount', {
      description: 'The amount to transfer',
      alias: 'c',
      type: 'string'
    })
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })          
    .demand(['vega', 'project', 'receiver', 'amount', 'account'])
  })
  .command('transferFrom', 'Transfer from the account specified to the recepient', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })     
    .option('receiver', {
      description: 'The address to send funds to',
      alias: 'r',
      type: 'string'
    })
    .option('amount', {
      description: 'The amount to transfer',
      alias: 'c',
      type: 'string'
    })
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })           
    .demand(['vega', 'project,', 'receiver', 'amount', 'account'])
  })  
  .command('approve', 'Authorize a transfer', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })
    .option('amount', {
      description: 'The amount to transfer',
      alias: 'c',
      type: 'string'
    })
    .option('spender', {
      description: 'The address to approve spending from',
      alias: 's',
      type: 'string'
    })
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })                     
    .demand(['vega', 'project', 'spender', 'amount', 'account'])
  })
  .command('balance', 'Get balance for account', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })        
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })           
    .demand(['vega', 'project', 'account'])
  })  
  .command('offer', 'Offer', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })
    .option('recipient', {
      description: 'The receipient of the offer',
      alias: 'r',
      type: 'string'
    })
    .option('amount', {
      description: 'The amount to transfer',
      alias: 'c',
      type: 'string'
    })           
    .option('token', {
      description: 'The token the offer is on',
      alias: 't',
      type: 'string'
    })              
    .option('description', {
      description: 'Description of the project offer is on',
      alias: 'd',
      type: 'string'
    })              
    .option('openfor', {
      description: 'How long the offer will be open',
      alias: 'o',
      type: 'string'
    })              
    .option('offerhash', {
      description: 'The hash for the offer',
      alias: 'f',
      type: 'string'
    })
    .option('num', {
      description: 'The hash for the offer',
      alias: 'u',
      type: 'string'
    })
    .option('den', {
      description: 'The hash for the offer',
      alias: 'e',
      type: 'string'
    })           
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })              
    .demand(['vega','project', 'account', 'recipient', 'amount', 'token', 'description', 'openfor', 'offerhash', 'num', 'den'])
  })
  .command('generic', 'Placeholder', (yargs) => {
    return yargs.option('host', {
      description: 'HTTP host of Ethereum node',
      alias: 'h',
      default: RPC_HOST
    })
    .option('port', {
      description: 'HTTP port',
      alias: 'p',
      default: RPC_PORT
    })
    .option('vega', {
      description: 'The address of vega-token',
      alias: 'v',
      type: 'string'
    })
    .option('account', {
      description: 'The account to be used',
      alias: 'a',
      type: 'string'
    })            
    .option('project', {
      description: 'The project contract address',
      alias: 'j',
      type: 'string'
    })    
    .demand(['vega', 'account'])
  })
  .help()
  .usage('Usage: $0 [command] [options]')

let { argv } = args

if (argv._.length === 0) {
  args.showHelp()
}

let command = argv._[0]

if (command === 'transfer') {
  let {host, port, vega, project, account, receiver, amount} = argv
  let vegaFund = initializeLib(host, port, vega, project, account)
  vegaFund.transfer(amount, receiver)
    .then(() => console.log('Made transfer of ' + amount))
}

if (command === 'transferFrom') {
  let {host, port, vega, project, account, receiver, amount} = argv
  let vegaFund = initializeLib(host, port, vega, project, account)
  vegaFund.transferFrom(account, receiver, amount)
    .then(() => console.log('Made transfer of ' + amount))
    .catch((e) => console.log(e))
}

if (command === 'approve') {
  let { host, port, vega, project, account, spender, amount } = argv
  let vegaFund = initializeLib(host, port, vega, project, account)
  vegaFund.approve(amount, spender)
    .then(() => console.log('Approved transfer of ' + amount + ' for ' + spender))
    .catch((e) => console.log(e))    
}

if (command === 'balance') {
  let { host, port, vega, project, account } = argv
  let vegaFund = initializeLib(host, port, vega, project, account)
  vegaFund.balanceOf(account)
    .then((result) => console.log('Succesfully checked balance of  ' + account ))
    .catch((e) => console.log(e))    
}

if (command === 'offer') {
  let { host, port, vega, project, account , recipient, amount, token, description, openfor, offerhash, num, den} = argv
  let vegaFund = initializeLib(host, port, vega, project, account)
  vegaFund.newOffer(recipient, amount, token, description, openfor, offerhash, num, den)
    .then((result) => console.log('Succesfully created offer  ' + result ))
    .catch((e) => console.log(e))    
}

