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
        string public_key;
    }

    mapping (uint => actor) public actors;
    uint256 public actorCount = 0; // pointer in the last element in the map

    constructor (address authorityAddress) HealthCenter(authorityAddress){
        actorCount++;
        actors[actorCount] = actor(23, 11, "badro", address(0x6158ca8d2F4D51a88207C87c495E31079cb01c02), "test_public_key");
        actorCount++;
        actors[actorCount] = actor(25, 11, "bilal", address(0x275e9114f18A7751af2E743e181a50525af1b08a), "test_public_key");
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }
    
    /**
    * ////////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR CONTRACT INTERFACE
    * ////////////////////////////////////////////////////////////
    */

    function addHealthActor(uint _id, uint _centerID, string memory _name, address _account, string memory _pKey) public onlyAuthority{
        uint index = checkHealthActor(_id, _account);
        require(index == 0, "Actor id or account already exist !!");

        ( , bool centerExist) = checkHealthCenter(_centerID, address(0));
        require(centerExist==true, "center does not exist exist !!");

        actorCount++;
        actors[actorCount] = actor(_id, _centerID, _name, _account, _pKey);
    }

    function rmHealthActor(uint _id) public onlyAuthority{
        uint index = checkHealthActor(_id, address(0));
        require(index>0, "Actor does not exist !!");

        actors[index] = actors[actorCount];
        actorCount--;
    }

    // function to show if an actor exist
    // exist : return index of actor
    // n'exist pas : return 0
    function checkHealthActor(uint _id, address _address) view public returns (uint) {
        uint index = 1;
        for (index; index <= actorCount; index++){
            if (actors[index].id == _id || actors[index].addr == _address){
                return index;
            }
        }
        return 0;
    }

    
    // function should be call only inside solidity
    function getActor(address _address) view public returns (actor memory) {
        uint index = checkHealthActor(0, _address);
        require(index>0, string(abi.encodePacked("Actor does not exist !!",toAsciiString(_address))));

        return actors[index];
    }

    // return actor and center name 
    function getActorAndCenterName(uint _actorID) public view returns(string memory, string memory) {
        // get actor name and center id
        uint index = checkHealthActor(_actorID, address(0));
        actor memory tmp = actors[index];
        //get center name
        (uint c_index, ) = checkHealthCenter(tmp.centerID, address(0));
        (, string memory centerName,) = getCenterByIndex(c_index);
        return (tmp.name, centerName);
    }
    
}
