$(".nav-link").on("click", function(){
    $(".navbar").find(".active").removeClass("active");
    $(this).addClass("active");
 });

 

 ///////////////////////////////////////// SMART CONTRACT //////////////////////////////////////////////
 ///////////////////////////////////////////////////////////////////////////////////////////////////////


App = {
    loading: false,
    contracts: {},
    
    load: async () => {
      await App.loadWeb3()
      await App.loadAccount()
      await App.loadContract()
    },

    loadWeb3: async () => {
      if (window.ethereum) {
        // Modern dapp browsers...
        App.web3Provider = window.ethereum;
        window.web3 = new Web3(ethereum);
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
    },
  
    loadContract: async () => {
      await App.loadHAuthority();
    //   await App.loadHActor();
    //   await App.loadPatient();

      App.setLoading(true);
    },

    loadHAuthority: async () => {
      // Create a JavaScript version of the smart contract
      const autority = await $.getJSON('HealthAuthority.json')
      App.contracts.Authority = TruffleContract(autority)
      App.contracts.Authority.setProvider(App.web3Provider)

      // Hydrate the smart contract with values from the blockchain
      App.autority = await App.contracts.Authority.deployed()
      // console.log(App.todoList)
    },

    loadHActor: async () => {
      // Create a JavaScript version of the smart contract
      const actor = await $.getJSON('HealthActor.json')
      App.contracts.Actor = TruffleContract(actor)
      App.contracts.Actor.setProvider(App.web3Provider)

      // Hydrate the smart contract with values from the blockchain
      App.actor = await App.contracts.Actor.deployed()
      // console.log(App.todoList)
    },

    loadPatient: async () => {
      // Create a JavaScript version of the smart contract
      const patient = await $.getJSON('Patient.json')
      App.contracts.Patient = TruffleContract(patient)
      App.contracts.Patient.setProvider(App.web3Provider)

      // Hydrate the smart contract with values from the blockchain
      App.patient = await App.contracts.Patient.deployed()
      // console.log(App.todoList)
    },









  
    render: async () => {
      // Prevent double render
      if (App.loading) {
        return
      }
  
      // Update app loading state
      App.setLoading(true)
  
      // Render Account
      $('#account').html(App.account)
  
      // Render Tasks
      await App.renderTasks()
  
      // Update loading state
      App.setLoading(false)
    },
  
    renderTasks: async () => {
      // conse.log("start rendering the tasks : ", taskCount.toNumber())
      
      // Load the total task count from the blockchain
      const taskCount = await App.todoList.taskCount()
      const $taskTemplate = $('.taskTemplate')
      
      // Render out each task with a new task templateol
      for (var i = 1; i <= taskCount; i++) {
        // Fetch the task data from the blockchain
        const task = await App.todoList.tasks(i)

        const taskId = task[0].toNumber()
        const taskContent = task[1]
        const taskCompleted = task[2]
  
        // Create the html for the task
        const $newTaskTemplate = $taskTemplate.clone()
        $newTaskTemplate.find('.content').html(taskContent)
        $newTaskTemplate.find('input')
                        .prop('name', taskId)
                        .prop('checked', taskCompleted)
                        .on('click', App.toggleCompleted)
  
        // Put the task in the correct list
        if (taskCompleted) {
          $('#completedTaskList').append($newTaskTemplate)
        } else {
          $('#taskList').append($newTaskTemplate)
        }
  
        // Show the task
        $newTaskTemplate.show()
      }
    },
  
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

    createTask: async () => {
      App.setLoading(true)
      const content = $('#newTask').val();
      console.log(content);
      await App.todoList.createTask(content);
      window.location.reload()
    },

    toggleCompleted: async (event) => {
      App.setLoading(true);
      const taskId = event.target.name;
      await App.todoList.toggleCompleted(taskId);
      window.location.reload();
    }
}
  
$(() => {
    $(window).load(() => {
      App.load();
    })
})