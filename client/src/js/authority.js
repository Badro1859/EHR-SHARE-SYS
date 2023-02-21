$(".nav-link").on("click", function(){
    $(".navbar").find(".active").removeClass("active");
    $(this).addClass("active");
});

 

///////////////////////////////////////// SMART CONTRACT //////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


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
    await App.loadWeb3()
    await App.loadAccount()
    await App.loadContract()
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

    // console.log("your account : ", App.account)
  },

  loadContract: async () => {
    await App.loadHAuthority();
    await App.loadHActor();
    await App.loadPatient();
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

    // Render Authority Accounts
    // await App.renderAuthList();

    // Render Centers Accounts
    // await App.renderCenters();

    // Render Actors Accounts
    // await App.renderActors();

    // Render Actors Accounts
    await App.renderPatients();

    // Update loading state
    App.setLoading(false);
  },



  ///////////////// AUTHORITY SMART CONTRACT /////////////////
  loadHAuthority: async () => {
    // Create a JavaScript version of the smart contract
    const authority = await $.getJSON('HealthAuthority.json')
    App.contracts.Authority = TruffleContract(authority)
    App.contracts.Authority.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.authority = await App.contracts.Authority.deployed();
    // console.log("authority smart contract is :", App.authority)
  },

  renderAuthList: async () => {
    // Load the total authority count from the blockchain
    const authorityCount = await App.authority.authCount();
    const $authorityRow = $('.authorityRow')
    
    // Render out each authority with a new task templateol
    for (var i = 1; i <= authorityCount.toNumber(); i++) {
      // Fetch the authority address from the blockchain
      const auth = await App.authority.authorities(i);

      // Create the html for the authority
      const $newAuthorityRow = $authorityRow.clone()

      $newAuthorityRow.find('.index').html(i)
      $newAuthorityRow.find('.address').html(auth)
      $newAuthorityRow.find('button')
                      .prop('name', auth)
                      .on('click', App.deleteAuthority)

      // Put the authority in the list
      $('#authorityList').append($newAuthorityRow)

      // Show the task
      $newAuthorityRow.show()
    }
  },

  addAuthority: async () => {
    App.setLoading(true)
    const content = $('#newAuthority').val();
    await App.authority.addAccount(content);
    window.location.reload()
  },

  deleteAuthority: async (event) => {
    App.setLoading(true);
    const authAddress = event.target.name;
    await App.authority.rmAccount(authAddress);
    window.location.reload();
  },


  ///////////////// HEALTH Actor SMART CONTRACT /////////////////
  loadHActor: async () => {
    // Create a JavaScript version of the smart contract
    const actor = await $.getJSON('HealthActor.json')
    App.contracts.Actor = TruffleContract(actor)
    App.contracts.Actor.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.actor = await App.contracts.Actor.deployed()
    // console.log(App.actor)
  },

  renderCenters: async () => {
    // Load the total authority count from the blockchain
    const centerCount = await App.actor.getNumberOfCenters();
    // console.log("number of centers : ", centerCount.toNumber());
    const $centerRow = $('.centerRow');
    
    // Render out each authority with a new task templateol
    for (var i = 0; i < centerCount.toNumber(); i++) {
      // Fetch the authority address from the blockchain
      const cent = await App.actor.getCenterByIndex(i);
      // console.log("center ", i, cent)
      // Create the html for the authority
      const $newCenterRow = $centerRow.clone()

      $newCenterRow.find('.index').html(i+1);
      $newCenterRow.find('.identifier').html(cent[0].toNumber())
      $newCenterRow.find('.name').html(cent[1])
      $newCenterRow.find('.account').html(cent[2])
      $newCenterRow.find('button')
                      .prop('name', cent[0].toNumber())
                      .on('click', App.deleteCenter)

      // Put the authority in the list
      $('#centersList').append($newCenterRow)

      // Show the task
      $newCenterRow.show()
    }
  },

  addCenter: async () => {
    App.setLoading(true)
    const identifier = $('#inputIdentifier').val();
    const name = $('#inputName').val();
    const account = $('#inputAdd').val();
    await App.actor.addHealthCenter(identifier, name, account);
    window.location.reload()
  },

  deleteCenter: async (event) => {
    App.setLoading(true);
    const centerID = event.target.name;
    await App.actor.rmHealthCenter(centerID);
    window.location.reload();
  },


  renderActors: async () => {
    // Load the total authority count from the blockchain
    const actorCount = await App.actor.actorCount();
    console.log("number of actors : ", actorCount.toNumber());
    const $actorRow = $('.actorRow');
    
    // Render out each authority with a new task templateol
    for (var i = 1; i <= actorCount.toNumber(); i++) {
      // Fetch the authority address from the blockchain
      const actor = await App.actor.actors(i);
      console.log("center ", i, actor)
      // Create the html for the authority
      const $newActorRow = $actorRow.clone()

      $newActorRow.find('.actIndex').html(i);
      $newActorRow.find('.actorID').html(actor[0].toNumber())
      $newActorRow.find('.actCentID').html(actor[1].toNumber())
      $newActorRow.find('.actName').html(actor[2])
      $newActorRow.find('.actAccount').html(actor[3])
      $newActorRow.find('button')
                      .prop('name', actor[0].toNumber())
                      .on('click', App.deleteActor)

      // Put the authority in the list
      $('#actorsList').append($newActorRow)

      // Show the task
      $newActorRow.show()
    }
  },

  addActor: async () => {
    App.setLoading(true)
    const identifier = $('#inputActorIdent').val();
    const name = $('#inputActorName').val();
    const centerID = $('#inputActorCenter').val();
    const account = $('#inputActorAddr').val();
    await App.actor.addHealthActor(identifier,centerID, name, account);
    window.location.reload()
  },

  deleteActor: async (event) => {
    App.setLoading(true);
    const actorID = event.target.name;
    await App.actor.rmHealthActor(actorID);
    window.location.reload();
  },
    

  ///////////////// PATIENT SMART CONTRACT /////////////////
  loadPatient: async () => {
    // Create a JavaScript version of the smart contract
    const patient = await $.getJSON('Patient.json')
    App.contracts.Patient = TruffleContract(patient)
    App.contracts.Patient.setProvider(App.web3Provider)

    // Hydrate the smart contract with values from the blockchain
    App.patient = await App.contracts.Patient.deployed()
    // console.log(App.todoList)
  },

  renderPatients: async () => {
    // Load the total authority count from the blockchain
    const patientCount = await App.patient.getNumberOfPatient();
    // console.log("number of patients : ", patientCount.toNumber());
    const $patientRow = $('.patientRow');
    
    // Render out each authority with a new task templateol
    for (var i = 0; i < patientCount.toNumber(); i++) {
      // Fetch the authority address from the blockchain
      const patient = await App.patient.getPatientByIndex(i);
      // console.log("center ", i, patient)

      // Create the html for the authority
      const $newPatientRow = $patientRow.clone()

      $newPatientRow.find('.patIndex').html(i+1);
      $newPatientRow.find('.patID').html(patient[0].toNumber())
      $newPatientRow.find('.patName').html(patient[1])
      $newPatientRow.find('.patAddr').html(patient[2])
      $newPatientRow.find('button')
                      .prop('name', patient[0].toNumber())
                      .on('click', App.deletePatient)

      // Put the authority in the list
      $('#patientsList').append($newPatientRow)

      // Show the task
      $newPatientRow.show()
    }
  },

  addPatient: async () => {
    App.setLoading(true)
    const identifier = $('#inputPatIdent').val();
    const name = $('#inputPatName').val();
    const account = $('#inputPatAddr').val();
    await App.patient.addPatient(identifier, name, account);
    window.location.reload()
  },

  deletePatient: async (event) => {
    App.setLoading(true);
    const patID = event.target.name;
    await App.patient.rmPatient(patID);
    window.location.reload();
  },


}
  
$(() => {
  $(window).load(() => {
    App.load();
  })
})