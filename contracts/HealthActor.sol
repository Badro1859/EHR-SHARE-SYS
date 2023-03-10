// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import {HealthCenter} from  "./HealthCenter.sol";


/** 
 * @title HealthActor
 * @dev Implements actor methods
 */
contract HealthActor is HealthCenter {

    struct actor {
        uint id;
        uint centerID;
        string name;
        address addr;
    }
    //actor[] actors;

    mapping (uint => actor) public actors;
    uint256 public actorCount = 0; // pointer in the last element in the map

    constructor (address authorityAddress) HealthCenter(authorityAddress){

        actorCount++;
        actors[actorCount] = actor(23, 11, 'badro', address(0x6158ca8d2F4D51a88207C87c495E31079cb01c02));
    }

    
    /**
    * ////////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR CONTRACT INTERFACE
    * ////////////////////////////////////////////////////////////
    */

    
    function addHealthActor(uint _id, uint _centerID, string memory _name, address _account) public isAccount{
        uint index = checkHealthActor(_id, _account);
        require(index == 0, "Actor id or account already exist !!");

        (uint cid, bool centerExist) = checkHealthCenter(_centerID, address(0));
        require(centerExist==true, "center does not exist exist !!");

        actorCount++;
        actors[actorCount] = actor(_id, _centerID, _name, _account);
    }

    function rmHealthActor(uint _id) public isAccount{
        uint index = checkHealthActor(_id, address(0));
        require(index>0, "Actor does not exist !!");

        actors[index] = actors[actorCount];
        actorCount--;
    }

    // function to show if an actor exist
    // exist : return index of actor
    // n'exist pas : return 0
    function checkHealthActor(uint _id, address _address)  view public returns (uint) {
        uint index = 1;
        for (index; index <= actorCount; index++){
            if (actors[index].id == _id || actors[index].addr == _address){
                return index;
            }
        }
        return 0;
    }

    function getActorID(address _address) view public returns (uint) {
        uint index = checkHealthActor(0, _address);
        require(index>0, string(abi.encodePacked("Actor does not exist !!",_address)));

        return actors[index].id;
    }
    
}
