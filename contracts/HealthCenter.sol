// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


import {HealthAuthority} from  "./HealthAuthority.sol";


/** 
 * @title HealthCenter
 * @dev Implements center methods
 */
contract HealthCenter {

    HealthAuthority authority; // associated authority

    struct center {
        uint id;
        string name;
        address addr;
    }

    // array content all center
    center[] centers;

    modifier isAccount() {
        (uint index, bool exist) = authority.checkHealthAuthority(msg.sender);
        require(exist, "Caller have not permession");
        _;
    } 


    constructor(address AuthorityAddress) {
        authority = HealthAuthority(AuthorityAddress);
    }

    function getNumberOfCenters() view public returns (uint) {
        uint len = centers.length;
        return len;
    }

    function getCenterByIndex(uint _index) view public returns (uint, string memory, address) {
        require(_index>=0 && _index<centers.length, "Wrong Index !!");
        return (centers[_index].id, centers[_index].name, centers[_index].addr); 
    }
    

    /**
    * ////////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR CONTRACT INTERFACE
    * ////////////////////////////////////////////////////////////
    */

    function checkHealthCenter(uint _id, address _address)  view internal returns (uint, bool) {
        uint index = 0;
        bool exist = false;
        for (uint i = 0; i < centers.length ; i++){
            if (centers[i].id == _id || centers[i].addr == _address){
                exist = true;
                index = i;
                break;
            }
        }
        return (index, exist);
    }

    function addHealthCenter(uint _id, string memory _name, address _account) public isAccount{
        (uint index, bool exist) = checkHealthCenter(_id, _account);
        require(exist==false, "center id or account already exist !!");

        centers.push(center(_id, _name, _account));
    }

    function rmHealthCenter(uint _id) public isAccount{
        (uint index, bool exist) = checkHealthCenter(_id, address(0));
        require(exist==true, "center does not exist !!");

        centers[index] = centers[centers.length-1];
        centers.pop();
    }
}