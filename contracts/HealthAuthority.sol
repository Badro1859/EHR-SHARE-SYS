// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/**
 * @title HealthAuthority
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy.ts // il faut modifier
 */

contract HealthAuthority {

    // variable store all account in authority
    // address[] authorities;

    uint256 public authCount = 0;
    mapping(uint => address) public authorities;
    
    constructor() {
        authCount++;
        authorities[authCount] = msg.sender;
    }


    ///////////////////////////////// GETTERS /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////

    // modifier to check if caller is account in authorty
    modifier isAccount() {
        (uint index, bool exist) = checkHealthAuthority(msg.sender);
        require(exist, "Caller have not permession");
        _;
    }

    function checkHealthAuthority(address _address) view public returns (uint, bool) {
        uint index = 0;
        bool exist = false;
        for (uint i = 1; i <= authCount ; i++){
            if (authorities[i] == _address ){
                exist = true;
                index = i;
                break;
            }
        }
        return (index, exist);
    }



    ///////////////////////////////// SETTERS /////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////

    /**
    * @dev add new account to authority
    * @param _address address to added
    */
    function addAccount(address _address) public isAccount {
        authCount++;
        authorities[authCount] = _address;
    }

    /**
    * @dev remove account from authority
    * @param _address address to remove
    */
    function rmAccount(address _address) public isAccount {
        (uint index, bool exist) = checkHealthAuthority(_address);
        require(exist==true, "center does not exist !!");

        authorities[index] = authorities[authCount];
        authCount--;
    }
}