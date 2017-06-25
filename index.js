import { default as VegaTokenLib } from './lib/vega_token'
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

const VegaToken = contract(require('./build/contracts/VegaToken.json'))
const Project = contract(require('./build/contracts/Project.json'))

export default function (host, port, vegaAddress, projectAddress, fromAddress) {
  let provider = new Web3.providers.HttpProvider(`http:\/\/${host}:${port}`)
  return new VegaTokenLib(
      VegaToken,
      vegaAddress,
      Project,
      projectAddress,
      provider,
      fromAddress
  )
}