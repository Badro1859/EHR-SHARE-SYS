


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

      // get all EHR
    //   await App.renderEHR();


      // get all requests
      await App.renderRequests();
   
      // Update loading state
      App.setLoading(false);
    },

    renderRequests: async () => {
        // Load the total request count from the blockchain
        const reqCount = await App.patient.getNumberOfRequest();
        const $reqRow = $('.reqRow');
        
        // Render out each request with a new task template
        for (var i = 0; i < reqCount.toNumber(); i++) {
            // Fetch the authority address from the blockchain
            const req = await App.patient.getRequestByIndex(i);

            // Create the html for the authority
            const $newReqRow = $reqRow.clone()

            $newReqRow.find('.reqIndex').html(i);
            $newReqRow.find('.reqActor').html(req[0].toNumber());
            let type = "CONSULT";
            if(req[1].toNumber() === 0){
                type = "SHARE";
            }
            $newReqRow.find('.reqType').html(type);
            let btn = $newReqRow.find('button')
                                .prop('name', i)
            if (req[2]) {
                btn.prop('disabled', true).html('Accepted');
            } else {
                btn.on('click', App.acceptRequest);
            }

            // Put the authority in the list
            $('#reqList').append($newReqRow)

            // Show the task
            $newReqRow.show()
        }
    },

    acceptRequest: async (event) => {
        const reqID = event.target.name;
        await App.patient.setResponse(reqID);
        window.location.reload()
    },

    renderEHR: async () => {

    }
}

$(() => {
    $(window).load(() => {
        App.load();
    })
})