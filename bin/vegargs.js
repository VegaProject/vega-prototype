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
    .demand(['vega', 'receiver', 'amount', 'account'])
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
    .demand(['vega', 'receiver', 'amount', 'account'])
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
    .demand(['vega', 'spender', 'amount', 'account'])
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
    .demand(['vega', 'account'])
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
  let {host, port, vega, account, receiver, amount} = argv
  let vegaFund = initializeLib(host, port, vega, account)
  vegaFund.transfer(amount, receiver)
    .then(() => console.log('Made transfer of ' + amount))
}

if (command === 'transferFrom') {
  let {host, port, vega, account, receiver, amount} = argv
  let vegaFund = initializeLib(host, port, vega, account)
  vegaFund.transferFrom(account, receiver, amount)
    .then(() => console.log('Made transfer of ' + amount))
    .catch((e) => console.log(e))
}

if (command === 'approve') {
  let { host, port, vega, account, spender, amount } = argv
  let vegaFund = initializeLib(host, port, vega, account)
  vegaFund.approve(amount, spender)
    .then(() => console.log('Approved transfer of ' + amount + ' for ' + spender))
    .catch((e) => console.log(e))    
}

if (command === 'balance') {
  let { host, port, vega, account } = argv
  let vegaFund = initializeLib(host, port, vega, account)
  vegaFund.balanceOf(account)
    .then((result) => console.log('Account ' + account + " has " + result.c ))
    .catch((e) => console.log(e))    
}
