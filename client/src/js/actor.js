


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
      const patID = $('#inputPatID').val();
      const reqID = $('#inputReqID').val();
      const hash = $('#inputHash').val();
      const ipfs = $('#inputipfs').val();
      const secret = $('#inputSecKey').val();

      await App.patient.shareEHR(patID, reqID, hash, ipfs, secret);
      window.location.reload();
    },

    consultEHR: async () => {
      const patID = $('#inputpat').val();
      const reqID = $('#inputreq').val();

      // Load the total ehr count from the blockchain
      const ehrCount = await App.patient.getNbOfEHRByActor(patID);
      const $ehrRow = $('.ehrRow');
      
      // Render out each request with a new task template
      for (var i = 1; i <= ehrCount.toNumber(); i++) {
        // Fetch the authority address from the blockchain
        const ehr = await App.patient.getEHRbyActor(patID, reqID, i);

        // Create the html for the authority
        const $newEhrRow = $ehrRow.clone()

        $newEhrRow.find('.ehrID').html(i);
        $newEhrRow.find('.ehrActor').html(ehr[0].toNumber());
        $newEhrRow.find('.ehrHash').html(ehr[1]);
        $newEhrRow.find('.ehrIPFS').html(ehr[2]);
        $newEhrRow.find('.ehrSecKey').html(ehr[3]);


        // Put the authority in the list
        $('#ehrList').append($newEhrRow)

        // Show the task
        $newEhrRow.show()
      }

    }
}

$(() => {
    $(window).load(() => {
        App.load();
    })
})