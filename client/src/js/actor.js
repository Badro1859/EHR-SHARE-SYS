


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
  
    //   console.log("your account : ", App.account)
    },
  
    loadContract: async () => {
        // Create a JavaScript version of the smart contract
        const pat = await $.getJSON('Patient.json')
        App.contracts.Patient = TruffleContract(pat)
        App.contracts.Patient.setProvider(App.web3Provider)

        // Hydrate the smart contract with values from the blockchain
        App.patient = await App.contracts.Patient.deployed()
        // console.log(App.patient)
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
        const type = $('input[name=flexRadioDefault]:checked', '#reqForm').val(); // PUBLISH: 0, CONSULT: 1
        console.log(patientID, type)

        await App.patient.sendRequest(patientID, type);
        window.location.reload();
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