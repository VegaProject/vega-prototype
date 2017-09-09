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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })           
    .demand(['vega', 'project', 'receiver', 'amount', 'account', 'cdr'])
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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })           
    .demand(['vega', 'project,', 'receiver', 'amount', 'account', 'cdr'])
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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })                     
    .demand(['vega', 'project', 'spender', 'amount', 'account', 'cdr'])
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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })         
    .demand(['vega', 'project', 'account', 'cdr'])
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
    .option('salt', {
      description: 'The hash for the offer',
      alias: 's',
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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })              
    .demand(['vega','project', 'account', 'recipient', 'amount', 'token', 'description', 'openfor', 'salt', 'num', 'den', 'cdr'])
  })
  .command('vote', 'Vote', (yargs) => {
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
    .option('support', {
      description: 'The hash for the offer',
      alias: 's',
      type: 'boolean'
    })
    .option('id', {
      description: 'The hash for the offer',
      alias: 'i',
      type: 'string'
    })
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })            
    .demand(['vega', 'project', 'account', 'id', 'support', 'cdr'])
  })
  .command('count', 'Count', (yargs) => {
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
    .option('id', {
      description: 'The hash for the offer',
      alias: 'i',
      type: 'string'
    })
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })            
    .demand(['vega', 'project', 'account', 'id', 'cdr'])
  })
  .command('status', 'Status', (yargs) => {
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
    .option('id', {
      description: 'The hash for the offer',
      alias: 'i',
      type: 'string'
    })
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })            
    .demand(['vega', 'project', 'account', 'id', 'cdr'])
  })     
  .command('execute', 'Execute', (yargs) => {
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
    .option('salt', {
      description: 'The hash for the offer',
      alias: 's',
      type: 'string'
    })
    .option('id', {
      description: 'The hash for the offer',
      alias: 'i',
      type: 'string'
    })
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })            
    .demand(['vega', 'project', 'account', 'id', 'salt', 'cdr'])
  })
  .command('cdr', 'Decision Rewards', (yargs) => {
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
    .option('currentValue', {
      description: 'The current value of the decision',
      alias: 'cv',
    })
    .option('startingValue', {
      description: 'The starting value of the decision',
      alias: 's',
    })
    .option('vegaPeriod', {
      description: 'The set period of the decision',
      alias: 'vp',
    })
    .option('stake', {
      description: 'The individual stake of the actor',
      alias: 'k',
    })
    .option('absTotalRewards', {
      description: 'The total rewards value of the decision',
      alias: 'abs',
    })  
    .option('tokenConversion', {
      description: 'The token converstion rate for the decision',
      alias: 't',
    })
    .option('currentBalance', {
      description: 'The current balance of the decision',
      alias: 'cb',
    })
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })                        
    .demand(['vega', 'project', 'account','currentValue', 'startingValue', 'vegaPeriod', 'stake', 'absTotalRewards', 'tokenConversion', 'currentBalance', 'cdr'])
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
    .option('cdr', {
      description: 'The CDR contract address',
      alias: 'cdr',
      type: 'string'
    })       
    .demand(['vega', 'project', 'account', 'cdr'])
  })  
  .help()
  .usage('Usage: $0 [command] [options]')
let { argv } = args

if (argv._.length === 0) {
  args.showHelp()
}

let command = argv._[0]

if (command === 'transfer') {
  let {host, port, vega, project, account, receiver, amount, cdr} = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.transfer(amount, receiver)
    .then(() => console.log('Made transfer of ' + amount))
}

if (command === 'transferFrom') {
  let {host, port, vega, project, account, receiver, amount, cdr} = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.transferFrom(account, receiver, amount)
    .then(() => console.log('Made transfer of ' + amount))
    .catch((e) => console.log(e))
}

if (command === 'approve') {
  let { host, port, vega, project, account, spender, amount, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.approve(amount, spender)
    .then(() => console.log('Approved transfer of ' + amount + ' for ' + spender))
    .catch((e) => console.log(e))    
}

if (command === 'balance') {
  let { host, port, vega, project, account, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.balanceOf(account)
    .then((result) => console.log('Succesfully checked balance of  ' + account ))
    .catch((e) => console.log(e))    
}

if (command === 'offer') {
  let { host, port, vega, project, account , recipient, amount, cdr, token, description, openfor, salt, num, den} = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.newOffer(num, den, amount, openfor, recipient, token, description, salt)
    .then((result) => console.log('Succesfully created offer  ' ))
    .catch((e) => console.log(e))    
}


if (command === 'vote') {
  let { host, port, vega, project, account, support, id, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.vote( id, support )
    .then((result) => {
      console.log('Succesfully created offer  ' )
    })
    .catch((e) => console.log(e))    
}

if (command === 'count') {
  let { host, port, vega, project, account, id, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.countVotes( id )
    .then((result) => {
      console.log('Succesfully created offer  ' )
    })
    .catch((e) => console.log(e))    
}

if (command === 'status') {
  let { host, port, vega, project, account, id, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.getOfferStatus( id )
    .then((result) => {
      console.log('Succesfully created offer  ' )
    })
    .catch((e) => console.log(e))    
}


if (command === 'execute') {
  let { host, port, vega, project, account, salt, id, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.execute( id, salt )
    .then((result) => 
    {
      console.log('Succesfully executed offer  ' )
    })
    .catch((e) => console.log(e))    
}


if (command === 'cdr') {
  let { host, port, vega, project, account, id, currentValue, startingValue, vegaPeriod, stake, absTotalRewards, tokenConversion, currentBalance, cdr } = argv
  let vegaFund = initializeLib(host, port, vega, project, account, cdr)
  vegaFund.calcCDR( currentValue, startingValue, vegaPeriod, stake, absTotalRewards, tokenConversion, currentBalance )
    .then((result) => 
    {
      console.log('Succesfully checked CDR' )
    })
    .catch((e) => console.log(e))    
}
