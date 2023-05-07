# EHR-SHARE-SYS
System to share Electronic Health Record using Etherum Blockchain

## How to use

###### step 1: install requirement
###### 1 - Update Package Manager:
    sudo apt update

###### 2 - Install Node.js and npm:
    sudo apt get install nodejs npm

###### 3 - Verify the Installation:
    node --version
    npm --version

###### 4 - Install Truffle and verify it:
    sudo npm install -g truffle
    truffle version

#### step 2: install ganache
###### 1 - Download Ganache:
    from : https://trufflesuite.com/ganache/

###### 2 - Install Ganache:
    chmod +x ganache-<version>.AppImage

###### 3 - Run Ganache:
    ./ganache-<version>.AppImage

#### step 3: install metamask
###### 1 - Install the Metamask browser extension:
    from : https://metamask.io/
###### 2 - Add Metamask to your browser:
        Follow the on-screen instructions to add Metamask to your browser. 
        Once the extension is installed, you should see the Metamask icon in your browser toolbar.

###### 3 - Configure Metamask:
        Click on the Metamask icon in your browser toolbar to open the extension. 
        Follow the setup wizard to create a new wallet or import an existing one. 
        You may be prompted to agree to terms and conditions and set a password.

###### 4 - Connect Metamask to Ganache:
        In the Metamask extension, click on the network selection dropdown (default is "Main Ethereum Network") 
        and choose "Custom RPC". Provide the following details:

            Network Name: Ganache (or any name you prefer)
            New RPC URL: http://localhost:7545 (assuming Ganache is running on the default port)
        Click "Save" to connect Metamask to your local Ganache blockchain.

#### step 4: deploy smart contract
    truffle migrate --reset

#### step 5: run a client web app:
    cd client
    npm install
    npm run dev
