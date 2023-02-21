


App = {
    loading: false,
    contracts: {},
  
    setLoading: (boolean) => {
      App.loading = boolean
      const loader = $('#loader')
      const content = $('#content')
      if (boolean) {
        loader.show()
        content.hide()
      } else {
        loader.hide()
        content.show()
      }
    },
  
  
    //////////////////// WEB3 PURPOSES ////////////////////
    load: async () => {
      await App.loadWeb3();
      await App.loadAccount();
      await App.loadContract();
      await App.render();
    },
  
    loadWeb3: async () => {
      if (window.ethereum) {
        // Modern dapp browsers...
        App.web3Provider = window.ethereum;
        window.web3 = new Web3(ethereum);
  
        // console.log("create web3 obj succeflly :", window.web3)
      }
      else if (window.web3) {
        // Legacy dapp browsers...
        App.web3Provider = web3.currentProvider;
        window.web3 = new Web3(web3.currentProvider);
      }
      else {
        // Non-dapp browsers...
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
      }
    },
  
    loadAccount: async () => {
      // Set the current blockchain account
      App.account = web3.eth.accounts[0];
      web3.eth.defaultAccount = App.account;
  
      console.log("your account : ", App.account)
    },
  
    loadContract: async () => {
        // Create a JavaScript version of the smart contract
        const actor = await $.getJSON('HealthActor.json')
        App.contracts.Actor = TruffleContract(actor)
        App.contracts.Actor.setProvider(App.web3Provider)

        // Hydrate the smart contract with values from the blockchain
        App.actor = await App.contracts.Actor.deployed()
        console.log(App.actor)
    },


  
    ////////// MAKE CHANGE IN HTML PAGE
    render: async () => {
      // Prevent double render
      if (App.loading) {
        return
      }
  
      // Update app loading state
      App.setLoading(true);
  
      // Render Account
      $('#account').html(App.account);
   
      // Update loading state
      App.setLoading(false);
    },

    sendRequest: async () => {
        const patientID = $('#inputPatient').val();
        const type = $('');
    },

    shareEHR: async () => {

    },

    consultEHR: async () => {

    }
}

$(() => {
    $(window).load(() => {
        App.load();
    })
})