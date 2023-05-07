

// If you have node.js, you can do this in node
var keyth=require('keythereum')

//install keythereum by runing "npm install keythereum"
var keyobj=keyth.importFromFile('0x7bd20cf7a890c8eac5134d834a47787a6f563fe1','.')

//'./Appdata/roaming/ethereum' is the folder contains 'keystore'. importFile looks for 'keystore' in that folder.

var privateKey=keyth.recover('karamela',keyobj) //this takes a few seconds to finish

privateKey.toString('hex')

console.log(privateKey.toString('hex'))