// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/** 
 * @title EHR
 * @dev Implements EHR methods
 */
contract EHR {

    enum RequestType {
        PUBLISH,
        CONSULT
    }

    struct request {
        uint actorID;
        RequestType rType;
        bool accepted;
        uint ReadyTime;
    }
    request[] requests;

    enum EHRType {
        examen,
        SCANNER
    }

    struct EHRAbstract {
        // uint id; index in the array of EHRAbstract
        uint actorID;
        // EHRType eType;
        string ehrHash;
        string ipfsHashAddress;
        string secretKey;
        // uint date; // TODO
    }
    // EHRAbstract[] ehrArray;
    mapping(uint256 => EHRAbstract) public ehrArray;
    uint256 public ehrCount = 0;

    
    constructor () {
        ehrCount++;
        ehrArray[ehrCount] = EHRAbstract(0, "test", "test", "test");
    }


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR REQUEST PURPOSE 
    * /////////////////////////////////////////////////////////
    */
    function getNumberOfRequest() public view returns (uint) {
        return requests.length;
    }

    function getRequestByIndex(uint _index) public view returns (uint, RequestType, bool) {
        require(_index >= 0 && _index < requests.length, "WRONG INDEX FOR REQUEST !!");
        return (requests[_index].actorID, requests[_index].rType, requests[_index].accepted);
    }

    function setRequest(uint _actorID, RequestType _type) public returns (uint){
        uint index = requests.length;
        bool accepted = false;

        requests.push(request(_actorID,  _type, accepted, 0));

        return index;
    }

    function checkRequest(uint _requestID) view public returns (bool, bool) {
        bool exist = false;
        bool accepted = false;
        if (requests.length > _requestID) {
            exist = true;
            accepted = requests[_requestID].accepted;
        }

        return (exist, accepted);
    }

    function setResponse(uint _requestID) public {
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist, "Request does not exist !!");

        requests[_requestID].accepted = true;
        // TODO: readyTime
    }


    /**
    * /////////////////////////////////////////////////////////
    *           PUBLIC METHODS FOR EHR PURPOSE 
    * /////////////////////////////////////////////////////////
    */

    ////////////////////// FOR OWNER
    function getEHRAbstract(uint _ehrID) view public returns (EHRAbstract memory) {
        require(_ehrID > 0 && _ehrID <= ehrCount, "EHR does not exist !!");

        return ehrArray[_ehrID];
    } 

    ////////////////////// FOR ACTOR
    function addEHRAbstract(uint _requestID, uint _actorID, string memory _hash, string memory _ipfsAddr, string memory _secretKey ) public returns (uint _ehrID) {

        // 1 - check the request 
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist && accepted, "Request does not exist or does not accepted !!");

        // 2 - check if actor is the same in the request 
        require(requests[_requestID].actorID == _actorID, "permission denied !!");

        // 3 - check the type of request (publish)
        require(requests[_requestID].rType == RequestType.PUBLISH, "permission denied !!");


        // share the EHR
        ehrCount++;
        ehrArray[ehrCount] = EHRAbstract(_actorID, _hash, _ipfsAddr, _secretKey);
    }

    // function checkEHR(uint _ehrID) view public returns (bool) {
    //     if (ehrArray.length > _ehrID){
    //         return true;
    //     }
    //     return false;
    // }


    function getEHRbyActor(uint _requestID, uint _actorID, uint _ehrID) view public returns (EHRAbstract memory) {
        // 1 - check the request 
        (bool exist, bool accepted) = checkRequest(_requestID);
        require(exist && accepted, "Request does not exist or does not accepted !!");

        // 2 - check if the same actor 
        require(requests[_requestID].actorID == _actorID, "permission denied !!");

        // 3 - check the type of request (consult)
        require(requests[_requestID].rType == RequestType.CONSULT, "permission denied !!");

        return getEHRAbstract(_ehrID);
    }
    
}